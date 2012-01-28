#!/bin/bash
# ~/.bash_functions

extract()      # Handy Extract Program.
{
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xvjf $1     ;;
             *.tar.gz)    tar xvzf $1     ;;
             *.bz2)       bunzip2 $1      ;;
             *.rar)       unrar x $1      ;;
             *.gz)        gunzip $1       ;;
             *.tar)       tar xvf $1      ;;
             *.tbz2)      tar xvjf $1     ;;
             *.tgz)       tar xvzf $1     ;;
             *.zip)       unzip $1        ;;
             *.Z)         uncompress $1   ;;
             *.7z)        7z x $1         ;;
	     *.jar)       unzip $1	  ;;
             *)           echo "'$1' cannot be extracted via >extract<" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

install()
{
    if [ -f $1 ] ; then
        case $1 in
            *.deb)	sudo dpkg -i $1	;;
	    *)		echo "'$1' cannot be installed via >install<" ;;
	esac
    else
        echo "'$1' is not a valid file"
    fi
}

get-file(){
    if ! [ -z $1 ]; then
        echo ${1##*/}
    fi
}

#
get-base(){
    if ! [ -z $1 ]; then
	file=$(get-file $1)
        echo ${file%%.*} 
    fi
}

latex-pstricks(){
	file=$(get-base $1 )
	echo $file
	latex "$file.tex"
	dvips "$file.dvi"
	ps2pdf "$file.ps"	
}


# compress-avi
# compresses a raw AVI to a much smaller file format
compress-to-avi(){
    for arg in $*
    do
	input=$(get-file $arg)		# get input/output locations
	output="$(get-base $arg)_compressed.avi"
        if [ -f ${arg} ]; then
	    # encode input file to output file
	    # in:out
	    # audo 	mp3lame -> mp3
	    # video	lavc   -> mp4
            mencoder $input -o $output -oac mp3lame -ovc lavc -lavcopts acodec=mp3,1bitrate=128,vcodec=mpeg4,vbitrate=800,vhq,vm4v
	fi
    done
}

# compress-to-mp4-xbox
# compress a raw AVI to mp4 H.264 codec (xbox ready)
compress-to-mp4-xbox(){
	# make temporary FIFO
	mkfifo tmp.fifo.yuv

	mencoder -vf format=i420 -nosound -ovc raw -of rawvideo -ofps 23.976 -o tmp.fifo.yuv $1 2>&1 > /dev/null &
	x264 -o max-video.mp4 --fps 23.976 --crf 26 tmp.fifo.yuv 720x480

	# remove the FIFO
	rm tmp.fifo.yuv
}

# translate <word> <from> <to>
# my own version of the same thing
# wget -q -O - "http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=$( echo $2 | sed s/\ /%20/g )&langpair=en|$1" | sed 's/.*"translatedText":"\(.*\)"},.*/\1\n/')
# add some translation capability
translate(){
	wget -qO- "http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=$1&langpair=$2|${3:-en}" | sed 's/.*"translatedText":"\([^"]*\)".*}/\1\n/'
}

# copy-to
# alias for copying a file to a remote host
copy-to()
{
    if [ -d $2 ]; then
        scp -r $2 $1 
    else 
        if [ -f $2 ]; then
            scp $2 $1
        fi
    fi

} 

# alias for executing a remote command
execute-on()
{
  ssh $1 $2
}

# easy ssh_with auto-completed commonly used hosts
ssh_connect()
{
  ssh $1
}


# _execute-on - auto complete which just returns common hostnames
_execute-on()
{
	local cur; local hosts
	cur=${COMP_WORDS[COMP_CWORD]}

	if [ $COMP_CWORD == 1 ]; then
            COMPREPLY=( $(compgen -W "$( cat ~/.known_hosts) " -- $cur ))
	fi
}



# _copy-to - autocomplete function for copyto
# will return the possible hosts which this can be destinations
_copy-to()
{
#         local cur
#         local hosts
         cur=${COMP_WORDS[COMP_CWORD]}
         # $cur contains CURRENT word you are auto completing
         # $COMP_CWORD contains index of current word
         # $COMP_WORDS is array containing all current words

         # so will perform first
         if [ $COMP_CWORD == 1 ]; then
            hosts=$( cat ~/.known_hosts)
            COMPREPLY=( $( compgen -W "$( echo $hosts | sed 's/\ /:~\/\ /g' ):~/ " -- $cur ))
         else
	     _longopt -o filenames
         fi
}

complete -F _copy-to copy-to
complete -F _execute-on execute-on
complete -F _execute-on ssh_connect

# mv whole folder contents up a folder and remove the containing folder if empty
mv-up-folder(){
	local orig; orig=$PWD
	mv * ..
	if ["$(ls -A $orig)" ]; then
		echo 'All files not moved'
	else
		echo "Move successful: removed empty directory $orig"
		cd ..
		rm -rf $orig

	fi
}

# duplicate
duplicate(){
	for d in $* ; do
		if [ -f $d ]; then
			for i in $(seq 1 $1) ; do
				echo $i
				cp $d $d$i
			done
		fi
	done
}

# convert-jpg-mpg
convert-jpg-mpg(){
	convert $* m2v:movie.mpg
}

aa_256 ()
{
	( x=`tput op` y=`printf %$((${COLUMNS}-6))s`;
	for i in {0..256};
	do
		o=00$i;
		echo -e ${o:${#o}-3:3} `tput setaf $i;tput setab $i`${y// /=}$x;
	done )
}
