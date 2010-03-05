# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_semantic_hack_session',
  :secret => 'a1d710dbdfeea7a727cc9184881c3b9ec31d7ea8b167ccfd4e0cb8e571421ceeeebdaeefeb5ba6d01af08d893a3296e1fa31243d26784d9c11939b20f5671236'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
