#!/bin/bash


namespaces=(`grep -l 'goog.provide' js/*.js | while read namespace ; do echo -n " ${namespace:3:${#namespace}-6} " ; done`)

namespaceArgs=''
for namespace in "${namespaces[@]}" ; do
	namespaceArgs+="-n ${namespace} "
done


git pull
mkdir build
cp -rfa .git build/
cd build
git checkout gh-pages
git pull . gh-pages
git push
rm -rf *
cd ..
cp -rfa `ls --ignore build` build/
cd build


ls *.html | while read file ; do cat "${file}" | tr '\n' ' ' | sed 's/<!-- COMPILE START -->.*<!-- COMPILE END -->/\<script src="js\/napster.js"\>\<\/script\>/' > "${file}.tmp" ; java -jar htmlcompressor.jar -o "${file}" "${file}.tmp" ; rm "${file}.tmp" ; done


cd css
ls *.css | while read file ; do java -jar ../yuicompressor.jar --type css -o "${file}.tmp" "${file}" ; mv "${file}.tmp" "${file}" ; done
cd ..


initText="`cat js/init.js`"
echo -e "goog.provide('init');\n\ngoog.require('exports');\n\n${initText}" > js/init.js

./export.sh "${namespaces[@]}"

js/closure-library/closure/bin/build/closurebuilder.py --root=js $namespaceArgs -n exports -n init --output_mode=compiled --compiler_jar=compiler.jar --compiler_flags="--compilation_level=WHITESPACE_ONLY" --compiler_flags="--externs=js/externs.js" --output_file=js/napster.js

# java -jar yuicompressor.jar --nomunge --type js -o js/napster.js.tmp js/napster.js
# mv js/napster.js.tmp js/napster.js


git add .
chmod 777 -R .
git commit -a -m 'deployment'
git push


cd ..
#rm -rf build
