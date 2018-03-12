# Setup/Usage

#### Install postgresql
```
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib
gem install pg
```

#### Set a root password
```
sudo -u postgres psql
\password
```

#### Create the tg_api role
```
create role tg_api with createdb login password 'adifferentpassword';
\q
```

#### Create the environment variable
Change back to your root user

```
su - yourrootusername
```

Navigate to /tg-api directory

```
TG_API_DATABASE_PASSWORD='adifferentpassword'
export TG_API_DATABASE_PASSWORD
printenv TG_API_DATABASE_PASSWORD
```

#### Load the JSON
Copy the JSON files to the /db/series/ directory

#### Run the migrations
```
rake db:setup
```

#### Test that everything is working
```
rails server
```

Navigate to http://localhost:3000/v1/episodes/

#### Using pgadmin
```
sudo apt-get install pgadmin3
```

Open pgadmin

Connect to localhost with the settings:
* Name: localhost
* Host: localhost
* Port: 5432
* Service:
* Maintenance DB: postgres
* Username: postgres
* Password: yournewpassword
