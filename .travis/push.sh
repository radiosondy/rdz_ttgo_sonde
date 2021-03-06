#!/bin/sh
setup_git() {
  git config --global user.email "dl9rdz@darc.de"
  git config --global user.name "dl9rdz (via Travis CI)"
}
generate_website_index() {
  echo "<html><head></head><body>" > download.html
  echo "<h1>Master repository</h1><ul>" >> download.html
  for i in `ls master`; do
    TS=`git log master/$i | grep "Date:" | head -1 | awk '{$1="";$2="";$7="";print substr($0,3,length($0)-3)}'`
    if [ -z "$TS" ]; then TS=`date`; fi
    echo "<li><a href=\"master/$i\">$i</a> ($TS)</li>\n" >> download.html;
  done
  echo "</ul><h1>Development repository</h1><ul>" >> download.html
  for i in `ls devel`; do
    TS=`git log devel/$i | grep "Date:" | head -1 | awk '{$1="";$2="";$7="";print substr($0,3,length($0)-3)}'`
    echo "<li><a href=\"devel/$i\">$i</a> ($TS)</li>\n" >> download.html;
  done
  echo "</ul></body></html>" >> download.html
  git add download.html
  git commit --message "Travis build: $TRAVIS_BUILD_NUMBER"
}
commit_website_files() {
  BRANCH=`git status | head -1 | awk '{print $NF}'`
  VERSION=`cat RX_FSK/version.h |  tail -1 |  egrep -o '".*"' | sed 's/"//g' | sed 's/ /_/g'`
  echo "On branch $BRANCH"
  echo "Version $VERSION"
  cd /tmp
  git clone https://github.com/dl9rdz/rdz_ttgo_sonde.git -b gh-pages
  cd rdz_ttgo_sonde
  cp ~/out.bin ${BRANCH}/${VERSION}-full.bin
  git add ${BRANCH}/${VERSION}-full.bin
  # git commit --message "Travis build: $TRAVIS_BUILD_NUMBER"
}
upload_files() {
  #git remote add origin-pages https://${GH_TOKEN}@github.com/MVSE-outreach/resources.git > /dev/null 2>&1
  #git push --quiet --set-upstream origin-pages gh-pages 
  git push --quiet
}
setup_git
commit_website_files
generate_website_index
upload_files
