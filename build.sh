for dir in `find . -type d -maxdepth 1 -not -path '*/\.*' -not -name '.'`
do
  cd ${dir}
  echo building ${dir}
  make build push
  echo built ${dir}
  cd ..
done
