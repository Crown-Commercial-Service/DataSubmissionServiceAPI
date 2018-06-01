class CreateAgreement < ActiveRecord::Migration[5.2]
  def change
    create_table :agreements, id: :uuid do |t|
      t.references :framework, type: :uuid, null: false
      t.references :supplier, type: :uuid, null: false
    end
  end
end
