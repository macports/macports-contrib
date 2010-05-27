# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mpwa_session',
  :secret      => 'cec8b7b09f692ad0f1aec399a7ff4fd315a45c84fcce518333d58230778eb7c7102e625c4d3846bfb6c7f163fb89fde83f7e42303564cd506b0cc20c4ee02330'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
