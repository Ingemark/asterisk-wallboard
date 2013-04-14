#Asterisk Wallboard

##Introduction
Asterisk Wallboard is web-application for real time monitoring of Asterisk call center.  It uses [pbxis-ws]
(https://github.com/Inge-mark/pbxis-ws) web services to fetch queue and agent statuses from the Asterisk. 
It consists of three interfaces, one for each role: **Admin**, **Manager** and **Agent**.  

###Admin
Admin interface allows administrator to administer users and queues. Admin can create queues and users, and assign
agents to the queue. Admin interface is implemented using [Rails Admin](https://github.com/sferik/rails_admin) engine.

###Manager
Manager interface allows call center manager to monitor all queues and agents. He can see status of each agent in every
queue as well as his statistics and statistics of each queue.

Manager can do following actions on the queue:
* Log any agent off the queue
* Start recording any ongoing call ( *not implemented - pbxis doesn't support it yet* )
* Start eavesdropping of any ongoing call ( *not implemented - pbxis doesn't support it yet* )
* Start whisper on any ongoing call ( *not implemented - pbxis doesn't support it yet* )

###Agent
Agent interface allows agent to monitor only those queues he's assigned to by the administrator. He can log on/off to
any of the queues he's previously assigned to by the administrator.

##Access Control
Authentication is implemented using [Devise](https://github.com/plataformatec/devise), and authorization is
implemented using [CanCan](https://github.com/ryanb/cancan).

##Authorization
Authorization is implemented using [CanCan](https://github.com/ryanb/cancan). Abilities are defined in *app/models/ability.rb*

##Caching
Cache store used is [Dalli](https://github.com/mperham/dalli) client for [memcached](https://github.com/memcached/memcached). 
It is used for caching queue statistics to reduce number of requests done to the pbxis-ws. Cache is stored in memcached server
in defined namespace and for defined time. Settings are located in file *config/application.rb*

#Installation And Configuration
##Prerequisits
* [rvm](https://github.com/wayneeseguin/rvm)
* [Asterisk PBX](http://www.asterisk.org/)
* [pbxis-ws](https://github.com/Inge-mark/pbxis-ws)
* [memcached](https://github.com/memcached/memcached)

##Database
Database settings are located in file *config/database.yml*.
```
adapter: postgresql
    encoding: unicode
    database: wallboard_db
    pool: 5
    host: localhost
    port: 5432
    username: <username>
    password: <password>
```

To seed database run rake task:
```
rake db:seed
```

This task will seed database with admin user.

##Pbxis-ws
Settings for pbxis-ws are storred in file *config/settings.yml*.
```
pbxisws:
   host: <address>
   port: <port>
   refresh_interval: <seconds> # pbxis-ws queue stats refresh interval in seconds
```

##Memcached
Settings for memcached are stored in file *config/application.rb*.
```
# Global enable/disable all memcached usage
config.perform_caching = true
# The underlying cache store to use.
config.cache_store = :dalli_store, 
    'localhost:11211', # host address and port of pbxis-ws
    {:namespace => "AsteriskWallboard", # cache namespace
    :expires_in => 20.seconds, # seconds
    :compress => true }
```

Property `:expires_in` will override previous pbxis-ws property `refresh_interval` if it is greater.

##Devise
Initial user will be created by seeding database as shown earlier. Devise settings are located in devise initializer *config/initializers/devise.rb*. Here you can set email addres which will be shown in from field for `Devise::Mailer`.

##SMTP Settings
SMTP settings are located in file *config/application.rb*
```
# Action Mailer for SMTP
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
    :address              => "<host>",
    :port                 => <port>,
    :domain               => '<domain>',
    :user_name            => '<username>',
    :password             => '<password>',
    :authentication       => 'plain',
    :enable_starttls_auto => true  }
```

## TODO
