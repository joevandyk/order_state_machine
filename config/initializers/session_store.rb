# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tmp_session',
  :secret      => '57dc499e33fcb5a3e3857c54ad42177a04af789f0f6509677c57ff31c58f4534bc5708e25c182a41bd62c18a0cdfd0e1bab31a4a256cb8b7dfeb1530337562d3'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
