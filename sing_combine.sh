#/bin/sh

# Due to a bug, bash does not use the internal echo command, but /bin/echo.
# This seriously fuckes up escaping and stuff, so we correct it
[ ! -z "$BASH" ] && shopt -s xpg_echo

TEMP=$(mktemp -d)
cp sing_header.tex "$TEMP/sing_header.tex"

cp license.pdf "$TEMP/license.pdf"

( echo "\\\\newcommand{\\\\doctitle}{Singular spaces and the Poincaré-duality (Date: $(date +%d.%m.%Y))}"; \
  sed -e "s/\\\\chead{\\\\doctitle}//g; s/\\\\makelicense$//g" sing_header.tex; \
  echo "\\\\title{Notes for the lecture ”singular spaces and the Poincaré-duality“ by Markus Banagl}
\\\\author{Axel Wagner}
\\\\date{Date: $(date +%d.%m.%Y)}
\\\\maketitle
\\\\makelicense
\\\\tableofcontents
\\\\clearpage" ) > "${TEMP}/sing.tex"

for folder in $(find * -name "sing*.tex" -printf "%p\n" |
		sed 's/\(.*\)\..*/\1/' |
		sort)
do
	if [ "$folder" = "sing_header" ]
	then
		continue
	fi
	sed -e "s/\\\\newcommand{\\\\doctitle}{[[:print:]]*}//g;
		s/\\\\include{sing_header}//g;
		s/\\\\end{document}//g;
		s/\\\\section\*/\\\\section/g;
		s/\\\\subsection\*/\\\\subsection/g" $folder.tex > ${TEMP}/$folder.tex
	echo "\\\\include{$folder}" >> "${TEMP}/sing.tex"
done

echo "\\\\end{document}" >> "${TEMP}/sing.tex"

cd "${TEMP}"
pdflatex sing.tex && pdflatex sing.tex

cd -
cp "${TEMP}/sing.pdf" "./sing.pdf"

rm -rf "${TEMP}"
