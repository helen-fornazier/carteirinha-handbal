#!/bin/bash

MODELO=$(dirname $0)/modelo.jpeg

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters, usage $0 [csv_file] [pictures_folder_zip]"
fi

csv_file=$1
pictures_folder_zip=$2

tmp_dir=$(mktemp -d -t hand-XXXXXXXXXX)
echo "Tmp folder $tmp_dir"

unzip $pictures_folder_zip -d $tmp_dir
mkdir $tmp_dir/carteirinhas

# generate carteirinhas
#convert carteirinhas/*.png -background white -page a4 -append  carteirinhas.pdf
#convert modelo.png \( ~/Imagens/Captura\ de\ tela\ de\ 2023-01-17\ 19-45-07.png -resize 100x150\!  \) -gravity Center -geometry -380-1 -composite result.png


get_path () {
   jotform_link=$1
   file_name=${jotform_link##*/}
   path=$(find $tmp_dir -name $file_name)
   echo $path
}

generate_carteirinha () {
   nome=$1
   foto=$2
   rg=$3
   data=$4
   funcao=$5
   clube=$6

   convert "$MODELO" \
	   -fill white -gravity center -pointsize 30 \
	   -annotate -330-28 "$nome" \
	   -annotate -500+155 "$data" \
	   -annotate +510+146 "$rg" \
	   -annotate +510+5 "$clube" \
	   -pointsize 25 \
	   -annotate -190+155 "$funcao" \
	   \( "$foto" -resize 270x359.1\! \) -gravity Center -geometry -840+15 -composite \
	   $tmp_dir/carteirinhas/"$nome".jpeg
}


# read csv, ignore fist line and remove quotes
sed 1d $csv_file | sed 's/"//g' | while IFS=, read -r sub_date nome foto_link rg data funcao clube
do
    foto=$(get_path $foto_link)
    echo $foto

    echo "$nome / $foto / $rg / $data / $funcao / $clube"

    generate_carteirinha "${nome^^}" "$foto" "${rg^^}" "$data" "${funcao^^}" "${clube^^}"
done

convert  -background white -page a4 -append carteirinhas.pdf && see carteirinhas.pdf

convert $tmp_dir/carteirinhas/* $tmp_dir/carteirinhas_single.pdf
pdfjam $tmp_dir/carteirinhas_single.pdf -o carteirinhas_print.pdf --nup 1x4  --delta "2mm 10mm" && see carteirinhas_print.pdf
