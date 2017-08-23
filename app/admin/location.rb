ActiveAdmin.register Location do
    permit_params :name 

    form do |f|
        f.semantic_errors *f.object.errors.keys
        f.input :name
        f.actions
    end
end