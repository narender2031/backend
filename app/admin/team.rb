ActiveAdmin.register Team do

    permit_params :name, :goal,
                    users_attributes: [:first_name, :last_name, :email, :phone, :password, :state, :id, :allow_destroy ]

    form do |f|
        f.semantic_errors *f.object.errors.keys
        f.input :name
        f.input :goal
        f.inputs do
            f.has_many :users, allow_destroy: true,
                               sortable: :position,
                               sortable_start: 1 do |u|
                u.input :first_name
                u.input :last_name
                u.input :email
                u.input :phone
                u.input :password
                u.input :state 
            end
        end
        f.actions
    end
end
