# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_t11_session',
  :secret      => '1c5f2c1bfa261b57ca7853a1bbaf76b2038aaa9efb3644119b04e09aac85f36c8f5c8d3a0acd616557a34867cf581b9877dc7ac2b229a8dc63212eebde884bc9'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
