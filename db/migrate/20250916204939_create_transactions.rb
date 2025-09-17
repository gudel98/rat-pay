class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.integer :amount,   null: false
      t.string  :currency, default: 'EUR'
      t.string  :status,   default: 'created'

      t.timestamps
    end
  end
end
