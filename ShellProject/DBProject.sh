#!/usr/bin/bash
echo
echo "_________________________Welcome To DBMS Project_________________________"
echo 
function menus {
    echo "________________Main Menu________________"
    select choice in "Database Menu" "Table Menu"
    do 
    case $choice in 
    "Database Menu" ) 
    DBMenu ;;
    "Table Menu" )
    tableMenu ;;
    * )
    echo Invalid input;
    menus
    esac
    done
}

function DBMenu {
    echo "_________________Database Menu_________________"
    select choice in createDB listDB dropDB connectDB "Main Menu" exit
    do 
    case $choice in 
    createDB ) 
    createDB ;;
    listDB )
    listDB ;;
    dropDB )
    dropDB ;;
    connectDB )
    connectDB ;;
    "Main Menu" ) 
    menus ;;
    exit )
    exit 2 ;;
    * ) 
    echo Invalid input;
    DBMenu ;;  
    esac
    done
}

function createDB {
read -p "Enter Database name to create: " dbname
if [[ -d ./DB/$dbname ]]; then
    echo "$dbname Database already exists"
    createDB
else

    if echo $dbname | grep -qE '^[0-9]'; then
        echo "Invalid name entered. Name cannot start with a number."
        createDB
    elif echo $dbname | grep -qE " "; then
        echo "Invalid name entered. Name cannot contain spaces."
        createDB
    elif echo $dbname | grep -qE '[^[:alnum:][:space:]]'; then
        echo "Invalid name entered. Name cannot contain special characters."
        createDB
    else
        mkdir ./DB/$dbname
        if [[ $? == 0 ]];then
            echo "$dbname database created successfully"
        fi
    fi
fi

DBMenu
}

function listDB {
    echo "Databases: "
    ls -F ./DB | grep /
}

function dropDB {
read -p "Enter database name you want to drop: " dbname
if [ -d ./DB/$dbname ]; then
rm -r ./DB/$dbname
if [[ $? == 0 ]]; then
   echo "$dbname database dropped successfully"
fi
else
echo "Database name doesn't exist!"
    if echo "$dbname" | grep -qE '^[0-9]'; then
        echo "Invalid name entered. Name cannot start with a number."
        dropDB
    elif echo "$dbname" | grep -qE '[[:space:]]'; then
        echo "Invalid name entered. Name cannot contain spaces."
        dropDB
    elif echo "$dbname" | grep -qE '[^[:alnum:][:space:]]'; then
        echo "Invalid name entered. Name cannot contain special characters."
        dropDB
    else
        dropDB
    fi
fi
}

function connectDB {
    read -p "Enter Database name to connect: " dbname
    if [ -d ./DB/$dbname ]; then
    cd ./DB/$dbname
    echo "___________Welcome to $dbname database!___________"
    tableMenu 
    else
    echo "Database name doesn't exist!"
    if echo "$dbname" | grep -qE '^[0-9]'; then
        echo "Invalid name entered. Name cannot start with a number."
        connectDB
    elif echo "$dbname" | grep -qE '[[:space:]]'; then
        echo "Invalid name entered. Name cannot contain spaces."
        connectDB
    elif echo "$dbname" | grep -qE '[^[:alnum:][:space:]]'; then
        echo "Invalid name entered. Name cannot contain special characters."
        connectDB
    else
        connectDB
    fi
    fi
}

function tableMenu {
    echo "_________________Table Menu_________________"
    select choice in createTable listTable dropTable insertInto selectfrom delete update "Main Menu"
    do 
    case $choice in 
    createTable ) 
    createTable ;;
    listTable )
    listTable ;;
    dropTable )
    dropTable ;;
    insertInto )
    insertInto ;;
    selectfrom )
    selectfrom ;;
    delete ) 
    delete ;;
    update )
    update ;;
    "Main Menu" ) 
    menus ;;
    * ) 
    echo Invalid input;
    tableMenu ;;  
    esac
    done
}

function createTable {
read -p "Enter Table name to create: " tname

if [ -f $tname ]; then
    echo "$tname Table already exists"
    createTable
    
else
    if echo "$tname" | grep -qE '^[0-9]'; then
        echo "Invalid name entered. Name cannot start with a number."
        createTable
    elif echo "$tname" | grep -qE '[[:space:]]'; then
        echo "Invalid name entered. Name cannot contain spaces."
        createTable
    elif echo "$tname" | grep -qE '[^[:alnum:][:space:]]'; then
        echo "Invalid name entered. Name cannot contain special characters."
        createTable
    else
    touch .$tname
    touch $tname
    pk=""
    read -p "Enter number of columns: " ncol
    for ((i=1;i<=$ncol;i++))
    do
        read -p "Enter name of column: " colName
        read -p "Enter column datatype : [string/int]" datatype
        while [[ !($datatype == "int" || $datatype == "string") ]]; do
		    	echo "Invalid datatype";
			    read -p "Enter column datatype : [string/int]" datatype;
        done
        #first checking primary key, then start to assign all data in metadata file.
        if [[ $pk == "" ]]; then
            read -p "Is it primary key? (Enter y/n): " response
        fi
        if [ $response == 'y' ]; then
            pk="primaryKey";
            echo -e $colName":"$datatype":"$pk >> .$tname;
            response='n';
        else
            echo -e $colName":"$datatype >> .$tname
     
        fi
        #Redirect headers
        if [ $i -eq $ncol ]; then
            echo -n $colName >> $tname
        else
            echo -n $colName":" >> $tname
        fi
    done
    if [ $? == 0 ]; then
        echo "$tname table created successfully"
    fi
 
    fi
fi

tableMenu

}

function listTable {
    echo Tables: 
    ls -F | grep -v /
    tableMenu
}

function dropTable {
    read -p "Enter table name to drop : " tname
    if [ -f $tname ]; then
        rm $tname
        rm .$tname
        if [ $? == 0 ]; then
            echo "$tname table dropped successfully"
        fi
    else 
        echo "Error , $tname table doesn't exist "
        dropTable
    fi
    tableMenu
}

function insertInto {

    # ask for table name
    # from metafile col.name 
    # pk col. check for unique, datatype
    # others check for datatype
    dataLine=""
    read -p "Enter table name to insert into: " tname 
    colsNumber=`awk 'END {print NR}' .$tname`
    rowsNumber=`awk 'END {print NR}' $tname`

    for (( i=1; i <= $colsNumber; i++ )); do
        colName=`awk 'BEGIN {FS=":"}{if( NR == '$i' ) print $1 }' .$tname`
        colType=`awk 'BEGIN {FS=":"}{if( NR == '$i' ) print $2 }' .$tname` 
        primaryKey=`awk 'BEGIN {FS=":"}{if( NR == '$i' ) print $3 }' .$tname` 
        read -p "Enter value of $colName: " nameVal 

        if [[ $primaryKey == "primaryKey" ]]; then
            for (( k=1; k <= $colsNumber; k++ )); do 
                field=`awk 'BEGIN {FS=":"}{if( NR == 1 ) print $'$k' }' $tname`
                if [[ $field == $colName ]]; then
                    fposition=$k
                fi 
                
            done

            for ((j=2; j <= $rowsNumber; j++ )); do 
                val=`awk 'BEGIN {FS=":"} {if (NR == '$j') print $'$fposition'}' $tname `
                if [[ $nameVal == $val ]]; then
                    echo "It's a unique column, and this value already exists, please try to enter value of $colName again: $nameVal";
                    insertInto
                    return
                fi
            done

        fi
    if [[ $colType == "int" ]]; then
        if [[ ! $nameVal =~ ^[0-9]+$ ]]; then
            echo "Error: $nameVal is not a valid integer for column $colName"
            insertInto
            return
        fi
    elif [[ $colType == "string" ]]; then
        if [[ ! $nameVal =~ ^[a-zA-Z]+$ ]]; then
            echo "Error: $nameVal is not a valid string for column $colName"
            insertInto
            return
       fi
   fi    
    
    if [[ $i -eq $colsNumber ]]; then
        dataLine+=$nameVal
    else
        dataLine+=$nameVal":"
    fi
    done
    echo -n $dataLine >> $tname
    echo "Values inserted successfully"
}


function selectfrom {
    echo "________________Select Menu________________"
    select choice in "select all" "select by column" "select by row" "Table Menu"
    do
    case $choice in
    "select all")
    select_all
    ;;
    "select by column")
    select_by_col
    echo "done"
    ;;
    "select by row")
    select_by_row
    echo "done"
    ;;
    "Table Menu" )
    tableMenu ;;
    *)
    echo "invalid choice."
    break
    ;;
    esac
    done


}

function select_all {
    read -p "Enter table name to select data : " tname
    rowsNumber=`awk 'END {print NR}' $tname`
    if [[ $rowsNumber -eq 1 ]]; then
        echo "$tname table is empty!";
        selectfrom
    fi
    cat $tname | column -t -s ':'
    echo ________________________________
    echo
    selectfrom
}

function select_by_col {
    read -p "Enter table name to select data : " tname
    read -p "Enter column name: " colname
    colsNumber=`awk 'END {print NR}' .$tname`
    rowsNumber=`awk 'END {print NR}' $tname`
    if [[ $rowsNumber -eq 1 ]]; then
        echo "$tname table is empty!";
        selectfrom
    fi
    fposition=0
    for (( k=1; k <= $colsNumber; k++ )); do 
        field=`awk 'BEGIN {FS=":"}{if( NR == 1 ) print $'$k' }' $tname`
        if [[ $field == $colname ]]; then
            fposition=$k;
            break
        fi
    done
    if [[ $fposition == 0 ]]; then
        echo "Error: $colname not found in $tname";
        selectfrom
    fi  
    awk 'BEGIN {FS=":"} { print $'$fposition' }' $tname
    echo ________________________________
    echo
    selectfrom
}


function select_by_row {
    read -p "Enter table name to select data : " tname
    read -p "Enter column name: " colname
    read -p "Enter value of $colname to select specific record: " colval
    colsNumber=`awk 'END {print NR}' .$tname`
    fposition=0
    for (( k=1; k <= $colsNumber; k++ )); do 
        field=`awk 'BEGIN {FS=":"}{if( NR == 1 ) print $'$k' }' $tname`
        if [[ $field == $colname ]]; then
            fposition=$k;
            break
        fi 
    done  
    if [[ $fposition == 0 ]]; then
        echo "Error: $colname not found in $tname";
        selectfrom
    fi
    rowToselect=`awk 'BEGIN {FS=":"} {if( $'$fposition' == "'$colval'" ) print $0}' $tname`
    if [[ -z $rowToselect ]]; then
        echo "Error: no rows found where $colname = $colval";
        selectfrom              
    fi
    awk 'BEGIN {FS=":"} {if( $'$fposition' == "'$colval'" ) print $0}' $tname
    echo ________________________________
    echo
    selectfrom
}

function update {
  read -p "Enter table name to update: " tname
  rowsNumber=$(awk 'END {print NR}' $tname)
  if [[ $rowsNumber -eq 1 ]]; then
    echo "$tname table is empty!";
    update
  fi
  read -p "Enter column name (where condition): " colname
  read -p "Enter value of $colname to update row (where condition): " colval

  colsNumber=$(awk 'END {print NR}' $tname)
  fposition=0
  for (( k=1; k<=$colsNumber; k++ )); do 
    field=$(awk 'BEGIN {FS=":"}{if (NR==1) print $'$k'}' $tname)
    if [[ $field == $colname ]]; then
      fposition=$k
      break
    fi 
  done  
  if [[ $fposition == 0 ]]; then
    echo "Error: $colname2 not found in $tname"
    echo
    update
  fi
  line=$(awk 'BEGIN {FS=":"} {if( $'$fposition' == "'$colval'" ) print NR}' $tname)
    
  read -p "Enter column name to update: " colname2
  read -p "Enter value of $colname2 to update column: " colval2


  fposition2=0
  for (( k=1; k<=$colsNumber; k++ )); do 
    field2=$(awk 'BEGIN {FS=":"}{if (NR==1) print $'$k'}' $tname)
    if [[ $field2 == $colname2 ]]; then
      fposition2=$k
      break
    fi 
  done  
  if [[ $fposition2 == 0 ]]; then
    echo "Error: $colname2 not found in $tname"
    update
  fi

  oldValue=$(awk 'BEGIN {FS=":"} {if(NR=='"$line"')print $0}' $tname)
  newrow=""
  count=1
  for value in $(echo $oldValue | tr ":" " "); do
      if [[ $count == $fposition2 ]]; then
          newrow="$newrow$colval2:"
      else
          newrow="$newrow$value:"
      fi
      count=$((count+1))
  done
  newrow=${newrow::-1}
  sed -i "s/$oldValue/$newrow/" $tname }
  if [[ $? == 0 ]]; then
    echo "$colname2 column updated successfully!"
    echo "old value: $oldValue => new value: $colval2"
    echo
  fi
  tableMenu
}

function delete {
    echo "________________Delete Menu________________"
    select choice in "delete all data" "delete on condition" "Table Menu"
    do
        case $choice in 
        "delete all data" )
         delete_all_data
         break
         ;;
        "delete on condition" )
         delete_on_condition
         break
         ;;
         "Table Menu" )
         tableMenu ;;
         * ) 
         echo "Invalid input";
         tableMenu ;;  
        esac
    done
}

function delete_all_data {
    read -p "Enter table name to delete from: " tname
    rowsNumber=`awk 'END {print NR}' $tname`
    if [[ $rowsNumber -eq 1 ]]; then
        echo "$tname table is empty!";
        delete
    else 
        sed -i '2,$d' $tname
        if [[ $? == 0 ]]; then
            echo "All data of $tname table deleted successfully"
            echo
        else
            echo "Error occurred during delete data!";
            echo
            delete_all_data
        fi
        delete
    fi
}

function delete_on_condition {
    read -p "Enter table name to delete from: " tname
    read -p "Enter column name: " colname
    read -p "Enter value of $colname to delete record: " colval
    colsNumber=`awk 'END {print NR}' .$tname`
    fposition=0
    for (( k=1; k <= $colsNumber; k++ )); do 
        field=`awk 'BEGIN {FS=":"}{if( NR == 1 ) print $'$k' }' $tname`
        if [[ $field == $colname ]]; then
            fposition=$k
            break
        fi 
    done  
    if [[ $fposition == 0 ]]; then
        echo "Error: $colname not found in $tname"
        echo
        delete
    fi
    rowToDelete=`awk 'BEGIN {FS=":"} {if( $'$fposition' == "'$colval'" ) print $0}' $tname`
    if [[ -z $rowToDelete ]]; then
        echo "Error: no rows found where $colname = $colval"
        echo
        delete              
    fi
    sed -i "/$rowToDelete/d" $tname
    if [[ $? == 0 ]]; then
        echo "Row matching $colname = $colval deleted from $tname"
        echo
    fi
}





DBMenu
