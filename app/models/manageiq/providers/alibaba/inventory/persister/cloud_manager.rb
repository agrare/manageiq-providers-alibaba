class ManageIQ::Providers::Alibaba::Inventory::Persister::CloudManager < ManageIQ::Providers::Alibaba::Inventory::Persister
  include ManageIQ::Providers::Alibaba::Inventory::Persister::Definitions::CloudCollections

  def initialize_inventory_collections
    initialize_cloud_inventory_collections
  end
end
