{env=""; if (NF<3) next; for (i=4; i<=NF; i++) {env=$i" "env}; print env "handlers/"$1 " " $2 " " $3;}
