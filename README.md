# Introducing the SectionX gem

The SectionX gem makes it convenient to store and retrieve hierarchical data in an XML format known as SectionX.

    require 'sectionx'

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

output:
<pre>
&lt;?xml version='1.0' encoding='UTF-8'?&gt;
&lt;personal&gt;
  &lt;summary&gt;
    &lt;title&gt;My Personal Profile&lt;/title&gt;
    &lt;tags&gt;profile personal&lt;/tags&gt;
  &lt;/summary&gt;
  &lt;sections&gt;
    &lt;section&gt;
      &lt;summary&gt;
        &lt;name&gt;John Smith&lt;/name&gt;
        &lt;age&gt;68&lt;/age&gt;
      &lt;/summary&gt;
      &lt;sections/&gt;
    &lt;/section&gt;
    &lt;section title='Employment'&gt;
      &lt;summary&gt;
        &lt;employer&gt;FQM R&S&lt;/employer&gt;
      &lt;/summary&gt;
      &lt;sections/&gt;
    &lt;/section&gt;
  &lt;/sections&gt;
&lt;/personal&gt;
</pre>

## Resources

* [sectionx](https://rubygems.org/gems/sectionx)
