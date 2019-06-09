# PersistentStore abstracts the underlying persistent data storage
class PersistentStore
   
   def PersistentStore.apn_certificate
      S3_BUCKET.object(Rails.application.secrets.apn_key_file).get.body 
   end

end