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
<?xml version='1.0' encoding='UTF-8'?>
<personal>
  <summary>
    <title>My Personal Profile</title>
    <tags>profile personal</tags>
  </summary>
  <sections>
    <section>
      <summary>
        <name>John Smith</name>
        <age>68</age>
      </summary>
      <sections/>
    </section>
    <section title='Employment'>
      <summary>
        <employer>FQM R&S</employer>
      </summary>
      <sections/>
    </section>
  </sections>
</personal>
</pre>

## Resources

* [sectionx](https://rubygems.org/gems/sectionx)
