#!/bin/bash

## Link to mysql password
source ~/.mysqlpw/mysql.conf

## Log that this script has started
mysql -u sam -p"$mysqlpw" wca_stats -e "INSERT INTO wca_stats.last_updated VALUES ('wcadevstsupd.sh', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;"

## Define the files
dbURL="https://www.worldcubeassociation.org/wst/wca-developer-database-dump.zip"
dbLocal=~/databasedownload/wca-developer-database-dump.zip
dbPath=~/databasedownload

## Get local and remote timestamps
URLStamp=$(date --date="$(curl -s -I "${dbURL}" | awk '/Last-Modified/ {$1=""; print $0}')" +%s)
localStamp=$(stat -c %Y "$dbLocal")

## compare the timestamps, if there's a newer one:
if [ ${localStamp} -lt ${URLStamp} ];
then
## update last_updated to note it's started
  mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET notes = 'Change noticed; developer database and wca_stats now being updated --- (${URLStamp} vs ${localStamp})' WHERE query = 'wcadevstsupd.sh'"
## post to discord that it's started
  ~/.mysqlpw/discord-notify.sh "Newer database available; developer database is now being downloaded"
## start timer
  start_timer=$(date +%s)
## download new database
  curl -sRo "${dbLocal}" "${dbURL}"
## unzip new database
  unzip -o "${dbLocal}" -d "${dbPath}"
## end timer and tell discord
  endtimer=$(date +%s)
  timer=$(($endtimer - $start_timer))
  ~/.mysqlpw/discord-notify.sh "Database downloaded.\n($(displaytime $timer))\nNow importing to \`wca_dev\`"
## log that wca_dev is now being updated
  mysql -u sam -p"$mysqlpw" wca_stats -e "INSERT INTO wca_stats.last_updated VALUES ('wca_dev', NOW(), NULL, '') ON DUPLICATE KEY UPDATE started=NOW(), completed = NULL;"
## import wca_dev and ping discord and last_updated once complete
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_dev < ~/databasedownload/wca-developer-database-dump.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "\`wca_dev\` has been updated to the latest developer export! :tada:\n($(displaytime $timer))\nThe tables in \`wca_stats\` are now being updated.\n\`results_extra\` is first!" && \
  mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW() WHERE query = 'wca_dev'"
## results_extra
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/results_extra.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "\`results_extra\` has been updated! :tada:\n($(displaytime $timer))\n\`all_attempts\` is now being updated."
## all_attempts
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/all_attempts.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "\`all_attempts\` has been updated! :tada:\n($(displaytime $timer))\nThe \`ranks\` and \`sor\` tables are now being updated."
## sum_of_ranks
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/sum_of_ranks.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "All the \`ranks\` and \`sor\` tables have been updated! :tada:\n($(displaytime $timer))\nThe \`kinch\` tables are now being updated."
## kinch
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/kinch.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "The \`world\`,\`continent\` and \`country_kinch\` tables have all been updated! :tada:\n($(displaytime $timer))\n\`uowc\` is now being updated."
## uowc
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/uowc.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "The \`uowc\` table has been updated! :tada:\n($(displaytime $timer))\n\`records\` is now being updated."
## records
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/records.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "\`records\` has been updated! :tada:\n($(displaytime $timer))\n\`championship_podiums\` is now being updated."
## championship_podiums
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/championship_podium.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "\`championship_podiums\` has been updated! :tada:\n($(displaytime $timer))\n\`concise_results\` is now being updated."
## concise_results
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/concise_results.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "\`concise_results\` has been updated! :tada:\n($(displaytime $timer))\n\`prs\` is now being updated."
## prs
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/prs.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "\`prs\` has been updated! :tada:\n($(displaytime $timer))\n\`pr_streak\` is now being updated."
## pr_streak
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/pr_streak.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "\`pr_streak\` has been updated! :tada:\n($(displaytime $timer))\n\`mbld_decoded\` is now being updated."
## mbld_decoded
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/mbld_decoded.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "\`mbld_decoded\` has been updated! :tada:\n($(displaytime $timer))\nThe \`relays\` tables are now being updated."
## relays
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/relays.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "The \`relay\` tables have been updated! :tada:\n($(displaytime $timer))\n\`registrations_extra\` is now being updated."
## registrations_extra
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/registrations_extra.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "\`registrations_extra\` has been updated! :tada:\n($(displaytime $timer))\n\`persons_extra\` is now being updated."
## persons_extra
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/persons_extra.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "\`persons_extra\` has been updated! :tada:\n($(displaytime $timer))\n\`competitions_extra\` is now being updated."
## competitions_extra
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/competitions_extra.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "\`competitions_extra\` has been updated! :tada:\n($(displaytime $timer))\n\`person_comps_extra\` is now being updated."
## person_comps_extra
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/person_comps_extra.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "\`person_comps_extra\` has been updated! :tada:\n($(displaytime $timer))\nThe \`current_averages\` tables are now being updated."
## seasons
#  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/seasons.sql && \ - not currently working
## current_averages
  starttimer=$(date +%s) && \
  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/current_averages.sql && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  timerall=$(($endtimer - $start_timer)) && \
  ~/.mysqlpw/discord-notify.sh "The \`seasons\` and \`current_averages\` tables been updated! :tada:\n($(displaytime $timer))\n\n :tada::tada::tada:\`wca_stats\` update complete!:tada::tada::tada:\nIn total it took $(displaytime $timerall)."
## world_rank_history
#  mysql -u sam -p"$mysqlpw" wca_stats < ~/WCA-Stats/tables/world_rank_history.sql && \
#  ~/.mysqlpw/discord-notify.sh "The last 5 weeks of \`world_rank_history\` have been recalculated! :tada:"
## log that wca_stats has finished updating
  mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW(), notes = 'Change noticed; developer database imported, wca_stats updated --- (${ldu1} vs ${ldu2})' WHERE query = 'wcadevstsupd.sh'" 
## run ghpages stats
  ~/WCA-Stats/bin/ghpagesupd.sh
## discord commit ghpages
  starttimer=$(date +%s) && \
  cd ~/pages/WCA-Stats/ && \
  commit=$(git log --format="%H" -n 1) && \
  endtimer=$(date +%s) && \
  timer=$(($endtimer - $starttimer)) && \
  ~/.mysqlpw/discord-notify.sh "http://sam596.github.io Updated with latest stats.\n($(displaytime $timer))\nView the changes here: https://github.com/sam596/WCA-Stats/commit/'"$commit"'.\n\nThat concludes the tri-daily spam of messages thanks to the WCA updating their developer database! :smiley: See you in three days :wink: Server is now restarting"
## reboot the server
  sudo reboot
 else
  mysql -u sam -p"$mysqlpw" wca_stats -e "UPDATE last_updated SET completed = NOW(), notes = 'no change noticed; no import made --- (${URLStamp} vs ${localStamp})' WHERE query = 'wcadevstsupd.sh'"
fi
