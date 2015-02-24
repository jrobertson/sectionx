#!/usr/bin/env ruby

# file: sectionx.rb

require 'line-tree'
require 'rexle-builder'


class SectionX

  def initialize()
  end

  def import(raw_s)

    lines = raw_s.lines
    header = lines.shift
    id = header[/id=["']([^"']+)/,1] || 'sectionx'

    body, summary = lines.join.strip.split(/^----*$/).reverse
    nested = indent_heading("# summary\n%s\n# begin\n%s" % [summary,\
                                                                body.strip])
    a = LineTree.new(nested).to_a

    summary = a.shift.flatten(1)
    summary.shift

    section1 = a.shift.flatten(1)
    section1.shift

    xml = RexleBuilder.new

    a2 = xml.send(id) do 
      xml.summary do
        summary.each do |raw_x| 
          label, value = raw_x.split(/\s*:\s*/,2)
          xml.send(label.downcase.gsub(/\s+/,'_'), value)
        end
      end
      xml.sections do
        xml.section do
          xml.summary do 
            section1.each do |raw_x|
              label, value = raw_x.split(/\s*:\s*/,2)
              xml.send(label.downcase.gsub(/\s+/,'_'), value)
            end
          end
          xml.sections
        end
        a.each do |section_name, raw_rows|
          xml.section({title: section_name}) do
            xml.summary do
              raw_rows.each do |raw_x|
                label, value = raw_x.split(/\s*:\s*/,2)
                xml.send(label.downcase.gsub(/\s+/,'_'), value)
              end
            end
            xml.sections
          end
        end 
      end
    end

    @doc = Rexle.new a2

  end

  def to_xml(options)
    @doc.xml(options)
  end

  private


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
