module WebserviceTags
  include Radiant::Taggable

  desc %{
    Makes remote request to webservice. It has only one special attribute - @name@. All other
    attributes will be used as input parameters before conversion of these parameters
    by Rule Scheme.

    *Usage:*

    <pre><code><r:webservice name="webservice_title" [other attributes...]>...</r:webservice></code></pre>
  }
  tag 'webservice' do |tag|
    webservice = Webservice.find_by_title(tag.attr.delete('name'))
    attrs = {}
    if Object.const_defined?("RouteHandlerExtension") && tag.locals.page.route_handler_params
      attrs.merge!(tag.locals.page.route_handler_params)
    end
    attrs.merge!(tag.attr)
    if webservice
      webservice.load!(attrs)
      webservice.get_data!
      tag.locals.webservice = webservice
    end
    tag.expand
  end

  # namespace for current_node
  tag 'webservice:current_node' do |tag|
    tag.expand
  end

  desc %{
    Shows some value from webservice response. It has only one attribute - @select@, 
    that contains XPath for getting values from response.
   
    *Usage: (within webservice tag)*
   
    <pre><code><r:webservice name="webservice_title" [other attributes...]>
      <r:webservice:content select="//some/xpath" />
    </r:webservice></code></pre>
  }
  tag 'webservice:content' do |tag|
    webservice = tag.locals.webservice
    webservice.get_value(tag.attr['select']) if webservice
  end

  desc %{
    Used to iterate over specific XML nodes.
   
    *Usage: (within webservice tag)*
   
    <pre><code><r:webservice name="webservice_title" [other attributes...]>
      <r:webservice:each_node select="/nested/xpath/elements">
        ...
      </r:webservice:each_node>
    </r:webservice></code></pre>
  }
  tag 'webservice:each_node' do |tag|
    result = ""
    webservice = tag.locals.webservice
    if webservice
      nodes = webservice.get_values(tag.attr['select'])
      tag.locals.nodes = nodes
      nodes.each do |node|
        tag.locals.node = node
        result << tag.expand
      end
    end
    result
  end

  desc %{
    Display the specified attribute for the current node.

    *Usage: (within webservice tag)*
   
    <pre><code><r:webservice name="webservice_title" [other attributes...]>
      <r:webservice:each_node select="/nested/xpath/elements">
        <r:webservice:current_node:attr name="myattr" />
      </r:webservice:each_node>
    </r:webservice></code></pre>
  }
  tag 'webservice:current_node:attr' do |tag|
    tag.locals.node[tag.attr['name']]
  end

  desc %{
    Display the text of the current node.

    *Usage: (within webservice tag)*
   
    <pre><code><r:webservice name="webservice_title" [other attributes...]>
      <r:webservice:each_node select="/nested/xpath/elements">
        <r:webservice:current_node:text />
      </r:webservice:each_node>
    </r:webservice></code></pre>
  }
  tag 'webservice:current_node:text' do |tag|
    tag.locals.node.text
  end

  desc %{
    Display the text of the current node.

    *Usage: (within webservice tag)*
   
    <pre><code><r:webservice name="webservice_title" [other attributes...]>
      <r:webservice:each_node select="/nested/xpath/elements">
        <r:webservice:current_node:children>
          <r:webservice:current_node:text />
        </r:webservice:current_node:children>
      </r:webservice:each_node>
    </r:webservice></code></pre>
  }
  tag 'webservice:current_node:children' do |tag|
    result = ""
    children = tag.locals.node.children
    children.each do |child_node|
      next if child_node.text.strip.empty?
      tag.locals.node = child_node
      result << tag.expand
    end
    result
  end
end