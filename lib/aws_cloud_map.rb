require 'right_aws'

module AWS
  def self.ec2
    @@ec2
  end
  
  def self.connect(aws_access_key_id, aws_secret_access_key)
    @@ec2 = RightAws::Ec2.new(aws_access_key_id, aws_secret_access_key)
  end

  class Image
    include AWS    
    
    def initialize(attributes)
      @attributes = attributes
    end
    
    def aws_architecture 
      @attributes[:aws_architecture] 
    end
    
    def aws_owner 
      @attributes[:aws_owner] 
    end
    
    def aws_id 
      @attributes[:aws_id] 
    end    
    
    def aws_image_type 
      @attributes[:aws_image_type] 
    end
    
    def aws_location 
      @attributes[:aws_location] 
    end
    
    def aws_kernel_id 
      @attributes[:aws_kernel_id] 
    end
    
    def aws_state 
      @attributes[:aws_state] 
    end
    
    def aws_ramdisk_id 
      @attributes[:aws_ramdisk_id] 
    end
      
    def aws_is_public 
      @attributes[:aws_is_public] 
    end

    alias_method :id, :aws_id
    alias_method :public?, :aws_is_public
  
    def instances
      @@ec2.describe_instances.select { |instance| instance[:aws_image_id] == id }.map { |instance| Instance.new(instance) }
    end
  
    def self.all
      @@ec2.describe_images_by_owner('self').map { |image| new(image) }
    end
    
    def self.find(image_id)
      new(@@ec2.describe_images([image_id]).first)
    end    
  end
  
  class Instance
    include AWS
    
    def initialize(attributes)
      @attributes = attributes
    end
    
    def aws_reservation_id
      @attributes[:aws_reservation_id]
    end
    
    def dns_name
      @attributes[:dns_name]
    end
    
    def aws_instance_type
      @attributes[:aws_instance_type]
    end
    
    def aws_groups
      @attributes[:aws_groups]
    end
    
    def private_dns_name
      @attributes[:private_dns_name]
    end
    
    def aws_kernel_id
      @attributes[:aws_kernel_id]
    end
    
    def aws_launch_time
      @attributes[:aws_launch_time]
    end
    
    def ami_launch_index
      @attributes[:ami_launch_index]
    end
    
    def aws_state
      @attributes[:aws_state]
    end
    
    def aws_owner
      @attributes[:aws_owner]
    end
    
    def ssh_key_name
      @attributes[:ssh_key_name]
    end
    
    def aws_ramdisk_id
      @attributes[:aws_ramdisk_id]
    end
    
    def aws_availability_zone
      @attributes[:aws_availability_zone]
    end
    
    def aws_image_id
      @attributes[:aws_image_id]
    end
    
    def aws_instance_id
      @attributes[:aws_instance_id]
    end
    
    def aws_product_codes
      @attributes[:aws_product_codes]
    end
    
    def aws_reason
      @attributes[:aws_reason]
    end
    
    def aws_state_code
      @attributes[:aws_state_code]
    end
    
    alias_method :id, :aws_instance_id

    def image
      @image ||= Image.find(aws_image_id)
    end

    def address
      #TODO
    end

    def volumes
      #TODO
      []
    end
    
    #TODO test
    def terminate!
      @@ec2.terminate_instances [id]
    end
    
    def self.all
      @@ec2.describe_instances.map { |instance| new(instance) }
    end
    
    def self.find(instance_id)
      new(@@ec2.describe_instances([instance_id]).first)
    end        
  end  
  
  class Volume
    include AWS

    def initialize(attributes)
      @attributes = attributes
    end
    
    def aws_created_at
      @attributes[:aws_created_at]
    end
    
    def aws_size
      @attributes[:aws_size]
    end
    
    def aws_device
      @attributes[:aws_device]
    end
    
    def aws_status
      @attributes[:aws_status]
    end
    
    def aws_instance_id
      @attributes[:aws_instance_id]
    end
    
    def zone
      @attributes[:zone]
    end
    
    def snapshot_id
      @attributes[:snapshot_id]
    end
    
    def aws_attachment_status
      @attributes[:aws_attachment_status]
    end
    
    def aws_id
      @attributes[:aws_id]
    end
    
    def aws_attached_at
      @attributes[:aws_attached_at]
    end
    
    alias_method :id, :aws_id

    #TODO test
    def instance
      return nil if aws_instance_id.nil?
      @instance ||= Instance.find(aws_instance_id)
    end

    def snapshots  
      #TODO
      []
    end
    
    def self.all
      @@ec2.describe_volumes.map { |volume| new(volume) }
    end
    
    def self.find(volume_id)
      new(@@ec2.describe_volumes([volume_id]).first)
    end        
  end

  class Snapshot
    include AWS

    def initialize(attributes)
      @attributes = attributes
    end
    
    def aws_progress
      @attributes[:aws_progress]
    end
    
    def aws_status
      @attributes[:aws_status]
    end
    
    def aws_volume_id
      @attributes[:aws_volume_id]
    end
  
    def aws_id
      @attributes[:aws_id]
    end
    
    def aws_started_at
      @attributes[:aws_started_at]
    end
    
    alias_method :id, :aws_id

    #TODO test
    def volume
      @volume ||= Volume.find(aws_volume_id)
    end
    
    #TODO test
    def create_volume(size, region)
      @@ec2.create_volume(id, size, region)
    end
    
    def self.all
      @@ec2.describe_snapshots.map { |snapshot| new(snapshot) }
    end
    
    def self.find(snapshot_id)
      new(@@ec2.describe_snapshots([snapshot_id]).first)
    end        
  end

  class Address
    include AWS

    def initialize(attributes)
      @attributes = attributes
    end
    
    def instance_id
      @attributes[:instance_id]
    end
    
    def public_ip
      @attributes[:public_ip]
    end

    #TODO test
    def associate!(instance_or_id)
      instance_id = case instance_or_id
        when Instance
          instance_or_id.id
        else
          instance_or_id        
      end
      
      @ec2.associate_address(instance_id, public_ip)
      
      # TODO refresh @attributes
    end

    def instance
      return nil if instance_id.nil?
      @instance ||= Instance.find(instance_id)
    end

    def self.all
      @@ec2.describe_addresses.map { |address| new(address) }
    end
    
    def self.find(ip)
      new(@@ec2.describe_addresses([ ip ]).first)
    end
  end  
end


