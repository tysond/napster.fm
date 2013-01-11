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


./export.sh "${namespaces[@]}"
js/closure-library/closure/bin/build/closurebuilder.py --root=js $namespaceArgs -n exports -n init --output_mode=compiled --compiler_jar=compiler.jar --compiler_flags="--compilation_level=ADVANCED_OPTIMIZATIONS" --output_file=js/napster.js


git add .
git commit -a -m 'deployment'
git push


cd ..
rm -rf build