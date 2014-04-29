SHELL = /bin/bash

# Specify your remote git repository (example: git@bitbucket.org:oriongroup/project-force-field.git)
GITORIGIN = 
# Specify your WordPress Plugin repository (example: http://plugins.svn.wordpress.org/project-force-field/)
WPORIGIN = 

# List your files and directories separated by commas (example: project-force-field.php,readme.txt,classes)
CPFILES = 

##
# Copy changes from git to wordpress, committing the changes to the WordPress plugin repo.
#
# This copies changes from the git repo to the WordPress trunk directory and a new tags
# directory (specified by `V`), Then commits the changes to the WordPress Plugin repo.
#
# Usage: $ make wp V=1.0.0
##
wp : wp-tag wp-trunk wp-ci

##
# Clones the git repo and the WordPress plugin repo.
#
# This clones the git repo into `git/` and wordpress repo into `wordpress/`.
#
# Usage: $ make init
##
init : init-git init-wp

##
# deletes the git and wordpress directories.
#
# Usage: $ make destroy
##
destroy : 
	rm -rf git wordpress

##
# deletes the git and wordpress directories, then clones them again.
#
# This is a nice way of reseting a local copy.
#
# Usage: $ make reset
##
reset : destroy init

##
# There be dragons here!
#
# Basically these are the make targets that do all of the work and
# are used as dependencies above. Read ahead if you want to.
##

wp-ci : 
	@echo "### Checking in changes to WordPress.org ###"
	cd wordpress; \
	svn ci -m "Uploading Version $(V)"

wp-trunk : 
	@echo "### Updating trunk files ###"
	cp -R git/{$(CPFILES)} wordpress/trunk

wp-tag : verify-tag
	@echo "### Copying files into new tag directory ###"
	mkdir wordpress/tags/$(V)
	cp -R git/{$(CPFILES)} wordpress/tags/$(V)
	cd wordpress; \
	svn add tags/$(V);

verify-tag : 
	@if [ -z "$(V)" ]; then \
        echo "Error: You need to specify a version number with V=<version>"; exit 2; \
	fi
	@if [ -d "wordpress/tags/$(V)" ]; then \
		echo "Error: The version number $(V) already exists"; exit 3; \
	fi

init-git : 
	git clone $(GITORIGIN) git

init-wp : 
	mkdir wordpress
	svn co $(WPORIGIN) wordpress

rm-tag :
	@if [ -z "$(V)" ]; then \
        echo "Error: You need to specify a version number with V=<version>"; exit 2; \
	fi
	@if [ ! -d "wordpress/tags/$(V)" ]; then \
		echo "Error: The version number $(V) doesn't exists"; exit 3; \
	fi
	rm -rf wordpress/tags/$(V)
