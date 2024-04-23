SHELL := /bin/bash

HTML_FILES := $(wildcard html/*.html)

# Variables
REMOTE_ALIAS := web-user
WORKSPACE := number.code-workspace

# Setup the local dir used.
LOCAL_BUILD_DIR = build/number
REMOTE_DIR := /var/www/projects/number-rsync
WWW_PAGE_ROOT := number

# src dir to creat if not already there.
SRC_DIRS := src/content/assets/css src/content/assets/images src/content/favicon/
# Check the Linux distribution and set variables accordingly
ifeq ($(shell lsb_release -is),Ubuntu)
	# Ubuntu path
	WEB_ROOT = /var/www/html
else
	# Default path for other Linux distributions
	WEB_ROOT = /srv/http
endif

.PHONY: build

build_menu:# From dif project, not used at min
	@echo "Building menu..."
	php build_sidebar.php

copy_assets:
	@echo ""
	@echo "Copying assets..."
	@mkdir -pv $(LOCAL_BUILD_DIR)/assets/images
	@mkdir -pv $(LOCAL_BUILD_DIR)/assets/css
	@cp -ur src/content/assets/images $(LOCAL_BUILD_DIR)/assets/images/
	@cp -urv src/content/assets/css/*.css $(LOCAL_BUILD_DIR)/assets/css/
	@cp -urv src/content/favicon $(LOCAL_BUILD_DIR)/
	@cp -urv src/content/new404.html $(LOCAL_BUILD_DIR)/
	@cp -urv src/content/.htaccess $(LOCAL_BUILD_DIR)/


# Rule to create directories if they don't exist
$(SRC_DIRS):
	@if [ ! -d $@ ]; then \
		mkdir -p $@; \
		echo "Created directory: $@"; \
	fi

build: $(HTML_FILES) $(SRC_DIRS)
	@echo ""
	@echo "Building static pages..."
	echo $(LOCAL_BUILD_DIR)/assets/images
	@mkdir -pv $(LOCAL_BUILD_DIR)/assets/images
	@mkdir -pv $(LOCAL_BUILD_DIR)/assets/css
	#php build_sidebar.php
	#@php build.php
	cp src/index.html $(LOCAL_BUILD_DIR)/
	@cp -ur src/content/assets/images/ $(LOCAL_BUILD_DIR)/assets/images/
	#@cp -urv src/content/assets/css/*.css $(LOCAL_BUILD_DIR)/assets/css/
	@cp -urv src/content/assets/css/*.css $(LOCAL_BUILD_DIR)/assets/css/ || true
#	@find src/content/assets/css -type f -name '*.css' -exec cp -urv {} $(LOCAL_BUILD_DIR)/assets/css/ \;
	@cp -urv src/content/favicon/ $(LOCAL_BUILD_DIR)/
	@cp -urv src/content/new404.html $(LOCAL_BUILD_DIR)/ || true
	@cp -urv src/content/.htaccess $(LOCAL_BUILD_DIR)/ || true

debug:
	@php -d display_errors=1 -d error_reporting=E_ALL test/test_dir_scan.php
	@cp -ur $(LOCAL_BUILD_DIR)/* /srv/http/kelda/

deploy_local: build
	rm -rf $(WEB_ROOT)/$(WWW_PAGE_ROOT)/*
	mkdir -p $(WEB_ROOT)/$(WWW_PAGE_ROOT)
	cp -ur $(LOCAL_BUILD_DIR)/* $(WEB_ROOT)/$(WWW_PAGE_ROOT)/
	#cp src/index.html /srv/http/number/

# Deployment rule using rsync
deploy: clean build
	rsync -avz --update $(LOCAL_BUILD_DIR)/ $(REMOTE_ALIAS):$(REMOTE_DIR)

clean:
	rm -rf docs/assets
	rm -rf docs/kelda
	rm -rf build/*

.PHONY: edit
edit:
	code-insiders --extensions-dir="../vscode/insiders/extensions" $(WORKSPACE)

start_apache:
	@echo "Starting Apache using shell script..."
	./start_apache.sh

install_components:
	composer require "twig/twig:^3.0"
	composer require "ezyang/htmlpurifier:^4.16.0"
