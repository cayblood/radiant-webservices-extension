class WebservicesExtension < Radiant::Extension
  version "0.1"
  description "Adds webservices radiant tags that allows to make remote queries " +
              "to your webservices and paste results on the pages"
  
  def activate
    tab "Content" do
      add_item "Webservices", "/admin/webservices", :after => "Pages" 
    end
    Page.send :include, WebserviceTags
  end
  
  def deactivate
  end
  
end
