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

## TODO
* Caching
* Clear statistics
