# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_startup_weekend_session',
  :secret      => 'cb82f583bf294b8603b5034d3055a4a805a30bbb5e52a577a0e56877810834da3a873ad77d2852b0aa7df283de6e207e9e6db93b8cb2a71f9a7353cd7d37d8f6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
