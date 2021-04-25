for file in mazecat-*.png; do
  [ -f "$file" ] || continue
  convert "$file" \( +clone -background black -shadow 50x1+4+4 \) +swap -background "#734d98" -layers merge +repage shadow-"$file"
done

