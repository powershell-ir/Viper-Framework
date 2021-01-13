#!/bin/bash

PYTHON_PACKAGES=$(python3 -c "import sys;print('\n'.join(sys.path))" | grep -P "python3\.\d/dist-packages")
VIPER_PATH="$PYTHON_PACKAGES/viper"



function install_viper_framework {
	# Install prerequisite packages
	sudo apt-get install -y git \
		gcc \
		libffi-dev \
		python3-dev \
		python3-pip\

	# Install packages required for modules
	sudo apt-get install -y libssl-dev \
		swig \
		ssdeep \
		libfuzzy-dev \
		unrar-free \
		p7zip-full
		
	# Install the framework (locally)
	sudo pip3 install viper-framework
}

function install_viper_web {
	git clone https://github.com/viper-framework/viper-web.git
	sudo pip3 install ./viper-web/
	rm -rf ./viper-web/
}

function install_viper_modules {
	# Automatically install modules, because i'm lazy
	sudo git clone https://github.com/viper-framework/viper-modules.git $VIPER_PATH/modules
	cd $VIPER_PATH/modules/	# git doesn't like path specification
	sudo git submodule init
	sudo git submodule update
	sudo pip3 install -U -r requirements.txt
}


function install_postgres {
	# Create the file repository configuration:
	sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

	# Import the repository signing key:
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

	# Install the latest version of PostgreSQL.
	sudo apt-get update
	sudo apt-get -y install postgresql
}


function configure_postgres {
	# Install packages required for usage with python and administration
    sudo pip3 install psycopg2-binary
	sudo apt-get install -y pgadmin3

	# Create a database and user to connect with
    sudo -u postgres psql -c "CREATE DATABASE viperdb;"
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
	sudo -u postgres psql -c "CREATE USER viper WITH ENCRYPTED PASSWORD 'viper';"
	sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE viperdb TO viper;"
}	#/var/log/postgresql/postgresql-13-main.log


function configure_viper {
	# Modify the Viper configuration to connect the database, and use an alternate module path
    sudo sed -i 's\connection =\connection = postgresql://viper:viper@localhost:5432/viperdb\g' $VIPER_PATH/data/viper.conf.sample
    sudo sed -i "s\module_path =\module_path = $VIPER_PATH\g" $VIPER_PATH/data/viper.conf.sample
    sudo cp $VIPER_PATH/data/viper.conf.sample $VIPER_PATH/data/viper.conf
}



install_viper_framework
install_viper_web
install_viper_modules
install_postgres
configure_postgres
configure_viper
viper