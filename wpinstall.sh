#!/bin/bash
#
# Script for installing wordpress using wp-cli
#
# @package   wpinstall
# @author    ViewOne Sp. z o.o. <support@viewone.pl>
# @copyright 2014 ViewOne Sp. z o.o.
# @license   http://opensource.org/licenses/MIT MIT
# @link      https://github.com/viewone/wpinstall

# Create and move config
wp local core config
mv wordpress/wp-config.php wp-config.php

# Create database
wp local db create

# Install wordpress
wp local core install

# Create additional users
wp local user create k.karkoszka k.karkoszka@viewone.pl

# Hide welcome panel on dashboard for user 1 and 2
wp local db query "UPDATE wp_usermeta SET meta_value=0 WHERE (user_id=1 AND meta_key='show_welcome_panel') OR (user_id=2 AND meta_key='show_welcome_panel')"
echo -e "\e[32mSuccess:\e[39m Dashboard welcome panel hided"

# Hide useless metaboxes on dashboard for user 1 and 2
wp local db query "INSERT INTO wp_usermeta (user_id, meta_key, meta_value) VALUES (1, 'metaboxhidden_dashboard', 'a:1:{i:0;s:17:\\\"dashboard_primary\\\";}')"
wp local db query "INSERT INTO wp_usermeta (user_id, meta_key, meta_value) VALUES (2, 'metaboxhidden_dashboard', 'a:1:{i:0;s:17:\\\"dashboard_primary\\\";}')"

wp local db query "INSERT INTO wp_usermeta (user_id, meta_key, meta_value) VALUES (1, 'closedpostboxes_dashboard', 'a:0:{}')"
wp local db query "INSERT INTO wp_usermeta (user_id, meta_key, meta_value) VALUES (2, 'closedpostboxes_dashboard', 'a:0:{}')"
echo -e "\e[32mSuccess:\e[39m Dashboard metaboxes hided"

# Remove default blog description
wp local db query "UPDATE wp_options SET option_value='' WHERE option_name='blogdescription'"
echo -e "\e[32mSuccess:\e[39m Default blog description removed"

# Set language
wp local db query "UPDATE wp_options SET option_value='pl_PL' WHERE option_name='WPLANG'"
echo -e "\e[32mSuccess:\e[39m Language set"

# Set timezone
wp local db query "UPDATE wp_options SET option_value='Europe/Warsaw' WHERE option_name='timezone_string'"
echo -e "\e[32mSuccess:\e[39m Time zone set"

# Set time and date format
wp local db query "UPDATE wp_options SET option_value='H:i' WHERE option_name='time_format'"
wp local db query "UPDATE wp_options SET option_value='j F Y' WHERE option_name='date_format'"
echo -e "\e[32mSuccess:\e[39m Time and date format set"

# Turn off comments
wp local db query "UPDATE wp_options SET option_value='closed' WHERE option_name='default_comment_status'"
echo -e "\e[32mSuccess:\e[39m Comments disabled"

# Init rewrite
wp local rewrite structure %postname% --category-base=kategoria --tag-base=tag

# Activate all plugins
wp local plugin activate `wp plugin list --status=inactive --format=csv | cut -d',' -f1 | tail -n +2 | tr "\n" " "`
