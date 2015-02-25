#!/usr/bin/env ruby

# file: sectionx.rb

require 'line-tree'
require 'rexle-builder'
require 'rxfhelper'
require 'recordx'


class SectionX

  attr_reader :summary, :sections
  
  def initialize(x=nil)
    
    @doc = if x.is_a? String then
      buffer, _ = RXFHelper.read x
      Rexle.new buffer
    elsif x.is_a? Rexle::Element then x      
    end
    
    if @doc then
      @summary, @sections = parse_root_node @doc.root
    end
  end

  def import(raw_s)
    
    raw_buffer, type = RXFHelper.read(raw_s)

    lines = raw_buffer.lines
    header = lines.shift
    id = header[/id=["']([^"']+)/,1] || 'sectionx'

    body, summary = lines.join.strip.split(/^----*$/).reverse
    nested = indent_heading("# summary\n%s\n# begin\n%s" % [summary,\
                                                                body.strip])
    a = LineTree.new(nested).to_a

    raw_summary = a.shift.flatten(1)
    raw_summary.shift
    
    summary = raw_summary.inject({}) do |r,raw_x|
      label, value = raw_x.split(/\s*:\s*/,2)
      r.merge(label.downcase.gsub(/\s+/,'_').to_sym => value)
    end
    

    section1 = a.shift.flatten(1)
    section1.shift

    xml = RexleBuilder.new

    a2 = xml.send(id) do 
      xml.summary do
        summary.each {|label, value| xml.send(label, escape(value)) }
        xml.recordx_type 'sectionx'
      end
      xml.sections do
        xml.section do
          xml.summary do 
            section1.each do |raw_x|
              label, value = raw_x.split(/\s*:\s*/,2)
              xml.send(label.downcase.gsub(/\s+/,'_'), escape(value))
            end
          end
          xml.sections
        end
        a.each do |section_name, raw_rows|
          xml.section({title: section_name}) do
            xml.summary do
              raw_rows.each do |raw_x|
                label, value = raw_x.split(/\s*:\s*/,2)
                xml.send(label.downcase.gsub(/\s+/,'_'), escape(value))
              end
            end
            xml.sections
          end
        end 
      end
    end

    @doc = Rexle.new a2
    @summary, @sections = parse_root_node(@doc.root)    
    
    self
  end
  
  def recordx_type()
    @summary[:recordx_type]
  end  
  
  def save(filepath)
    File.write filepath, @doc.xml(pretty: true)
  end

  def to_xml(options={})
    @doc.xml(options)
  end
  
  def xpath(x)
    @doc.root.xpath(x)
  end
  
  def xslt=(value)
    
    self.summary.merge!({xslt: value})
    @xslt = value
  end    

  private

  def escape(v)
    v.gsub('&','&amp;').gsub('<','&lt;').gsub('>','&gt;')
  end
  
  def indent_heading(s, heading='#')

    a = s.split(/(?=^\s*#{heading}\s*\w)/).map do |x|

      heading_title = x[/^\s*#{heading}\s*(.*)/,1]

      if heading_title then

        lines = x.lines
        body = lines[1..-1].map{|y| y.prepend '  '}.join
        r = indent_heading(body, heading + '#')

        heading_title + "\n" + r
      else
        x
      end
    end

    a.join
  end

  
  def parse_root_node(e)
    
    summary = RecordX.new e.xpath('summary/*')
    summary_methods = (summary.keys - self.public_methods)
    
    summary_methods.each do |x|
      
      instance_eval "
      
        def #{x.to_sym}()
          @summary[:#{x}]
        end
      
        def #{x.to_s}=(v)
          @summary[:#{x}] = v
          @doc.root.element('summary/#{x.to_s}').text = v
        end
        "      
    end        
    
    sections =  e.xpath('sections/section').map do |section|
      SectionX.new section
    end
  
    [summary, sections]
  end
  
end

if __FILE__ == $0 then

s =<<EOF
<?sectionx id='personal'?>

title: My Personal Profile
tags: profile personal

----------------------------

name: John Smith
age: 68

# Employment
Employer: FQM R&S
EOF

  sx = SectionX.new
  sx.import s
  puts sx.to_xml pretty: true

end
