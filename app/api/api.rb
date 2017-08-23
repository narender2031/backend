require 'grape-swagger'
class API < Grape::API
   
    prefix 'api'
    version 'v1', using: :path
    default_format :json

    mount Invites::Data
  
    add_swagger_documentation(
        
        mount_path: '/docs',
        markdown: false,
        hide_documantation_path: true,
        api_version: '1.0'
       
        
        
    )
   
 

end