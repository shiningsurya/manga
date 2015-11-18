echo "Enter Manga name:"
read manga
manga=${manga,,} # Converting it to lower case
manga=${manga// /-} # Removing spaces and adding - in their places
echo "Enter the chapter range."
echo "Start:"
read chaps
echo "End:"
read chape
echo $manga >> .gitignore
sort -u -o .gitignore .gitignore
mkdir $manga
cd $manga
for chap in $(seq $chaps $chape);
do
	mkdir $chap
	cd $chap
	wget -O index.html -o log.txt www.mangareader.net/$manga/$chap
	if grep -q "not released yet" index.html; then
		echo "Chapter $chap of $manga is not released yet"
		cd ..
		rm -rf $chap
		break
	fi
	rm index.html
	## To determine the number of pages in a chapter
	echo "Finding out the number of pages in $chap of $ip_manga..."
	wget -o log.txt -O 1.html -c www.mangareader.net/$manga/$chap/1
	endder=`grep "option value" 1.html | wc -l`
	rm 1.html
	## Having found what we wanted to find. 
	## We proceed further.
	for i in `seq 1 $ennder`
	do
		echo "Downloading page $i of chapter $chap....."
		wget -o log.txt -O $i.html -c www.mangareader.net/$manga/$chap/$i
		grep 'src=\"http' $i.html | grep 'mangareader' > jump.txt
		link=$(head -n 1 jump.txt)
		starti="$(echo $link | grep -aob '"' | grep -oE '[0-9]+' | sed "11q;d")"
		endi="$(echo $link | grep -aob '"' | grep -oE '[0-9]+' | sed "12q;d")"
		if grep -q "Larger Image" $i.html; then
			starti="$(echo $link | grep -aob '"' | grep -oE '[0-9]+' | sed "9q;d")"
			endi="$(echo $link | grep -aob '"' | grep -oE '[0-9]+' | sed "10q;d")"
		fi
		length=$((endi-starti))
		image=${link:$((starti+1)):$((length-1))}
		length=${#image}
		if [[ "$length" -eq 0 ]]; then
			break
		fi
		imagename=0000$i
		wget -O ${imagename: -4}.jpg -o log.txt -c $image
	done
	echo "Converting to pdf..."
	chapno=0000$chap
	chapno=${chapno: -4}
	convert *.jpg ../chap$chapno.pdf
	echo "Cleaning up....."
	cd ..
	rm -rf $chap
done
