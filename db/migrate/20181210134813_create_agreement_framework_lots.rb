class CreateAgreementFrameworkLots < ActiveRecord::Migration[5.2]
  def change
    create_table :agreement_framework_lots, id: :uuid do |t|
      t.references :agreement, foreign_key: true, type: :uuid, null: false
      t.references :framework_lot, foreign_key: true, type: :uuid, null: false

      t.timestamps
    end
  end
end
