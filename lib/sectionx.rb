#!/usr/bin/env ruby

# file: sectionx.rb

require 'line-tree'
require 'rexle-builder'
require 'rxfhelper'
require 'recordx'


class SectionX

  attr_reader :attributes, :summary, :sections
  
  def initialize(x=nil)
    
    @doc = if x.is_a? String then
      buffer, _ = RXFHelper.read x
      Rexle.new buffer
    elsif x.is_a? Rexle::Element then x      
    end
    
    if @doc then
      @attributes, @summary, @sections = parse_root_node @doc.root
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
    
    raw_summary = a.shift
    raw_summary.shift # removes the redundant summary label
    
    
    section1 = a.shift # get the 1st section
    section1[0] = nil  # nilify the section heading 'begin'

    xml = RexleBuilder.new

    a2 = xml.send(id) do 
      
      xml.summary do
        build_rows xml, raw_summary
        xml.recordx_type 'sectionx'
      end
      
      xml.sections do

        build_section xml, section1

        a.each {|raw_rows| build_section xml, raw_rows }

      end
    end

    @doc = Rexle.new a2
    @attributes, @summary, @sections = parse_root_node(@doc.root)    
    
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
  
  def build_rows(xml, raw_rows)
    
    raw_rows.each do |raw_x|
      label, value = raw_x[0].split(/\s*:\s*/,2)
      xml.send(label.downcase.gsub(/\s+/,'_'), escape(value))
    end    
  end
  
  def build_section(xml, raw_rows)
    
    section_name  = raw_rows.shift    

    attr = section_name ? {title: section_name} : {}
    
    xml.section(attr) do
      
      rows, sections = raw_rows.partition {|x| x.length == 1}
      build_summary xml, rows
      
      xml.sections do
        sections.each {|section| build_section xml, section }
      end
    end

  end  

  def build_summary(xml, raw_rows)

    xml.summary { build_rows xml, raw_rows }

  end  
  
  def escape(v)
    v.gsub('&','&amp;').gsub('<','&lt;').gsub('>','&gt;')
  end
  
  def indent_heading(s, heading='#')

    a = s.split(/(?=^\s*#{heading}\s*\w)/).map do |x|

      heading_title = x[/^\s*#{heading}\s*.*/]

      if heading_title then

        lines = x.lines
        body = lines[1..-1]\
                      .map{|y| y.strip.length > 0 ? y.prepend('  ') : y }.join
        r = indent_heading(body, heading + '#')

        heading_title.sub(/#+\s*/,'') + "\n" + r

      else
        x
      end
    end

    a.join
  end

  
  def parse_root_node(e)

    attributes = e.attributes
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
    
    a = e.xpath('sections/section')

    return [attributes, summary] if a.empty?
    
    sections = {}
    
    if a[0] and a[0].attributes.empty? then
      section1 = a.shift
      sections = {'' => SectionX.new(section1)}
    end
    
    sections =  a.inject(sections) do |r, section|
      
      h = section.attributes
      name = (h[:id] || h[:title].gsub(/\s+/,'_')).downcase
      
      instance_eval "def #{name}() self.sections[:#{name}] end"
      r.merge(name.downcase.to_sym => SectionX.new(section))
    end    
  
    [attributes, summary, sections]
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
