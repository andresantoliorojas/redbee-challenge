#!/bin/bash

# Autor: Andres Antolio Rojas
# Descripción: Script en bash que devuelve Fecha de ultima modificación y nombre de una App
# Parámetros:   -h, --help  Muestra la ayuda y sale.
#               1.  -f      Archivo de entrada (requerido)
#               2.  -t      Ultimas X horas (requerido)
#               3.  -d      Listar puertos duplicados (opcional) 

# Variables globales

PROGNAME='JSON_FILTER'

# FUNCIONES

function helptext(){
#    -----------------------------------------------------------------------
#    Function to display help message for program
#        No arguments
#    -----------------------------------------------------------------------

    local tab=$(echo -en "\t\t")

    cat << _EOF_

    ${PROGNAME}
    Script en bash que devuelve Fecha de ultima modificación y nombre de una App

    $(usage)

    Options:

    -h, --help  Muestra la ayuda y sale.
    -f      Archivo de entrada (requerido)
    -t      Ultimas X horas (requerido)
    -d      Listar puertos duplicados (opcional) 


_EOF_
}    #fin de helptext

function graceful_exit(){
#  -----------------------------------------------------------------------
#    Function called for a graceful exit
#        No arguments
#  -----------------------------------------------------------------------

    #clean_up
    exit
}    #fin de graceful_exit

function usage(){
#    -----------------------------------------------------------------------
#    Function to display usage message (does not exit)
#        No arguments
#    -----------------------------------------------------------------------

    echo "Usage: ${PROGNAME} [-h | --help]" 
}    #fin de usage

function error_exit(){
#  -----------------------------------------------------------------------
#    Function for exit due to fatal program error
#        Accepts 1 argument:
#            string containing descriptive error message
#  -----------------------------------------------------------------------
    echo "${PROGNAME}: ${1:-"Unknown Error"}" >&2
    exit 1
}    #fin de error_exit

function fAppInfoFilter()
{

    local loc_INPUT_FILE=${1}
    local loc_HOUR_QUANTITY=${2}
    local loc_DUPLICATED=${3}
    local loc_DATETIME_FILTER=""

    if [ ${loc_HOUR_QUANTITY} -eq "1" ]; then
        loc_DATETIME_FILTER=$(date -d "1 hour ago" +'%Y-%m-%dT%H:%M:%S')
    elif [ ${loc_HOUR_QUANTITY} -gt "1" ]; then
        loc_DATETIME_FILTER=$(date -d "${loc_HOUR_QUANTITY} hours ago" +'%Y-%m-%dT%H:%M:%S')
    fi

    #Exec filter on file
    if [[ ${loc_DUPLICATED} == "yes" ]]; then
        jq '.apps | .[]? | select(.versionInfo.lastConfigChangeAt >= "'"${loc_DATETIME_FILTER}"'" ) | {lastConfigChangeAt: .versionInfo.lastConfigChangeAt, appName: .id, duplicatedPorts: [.container.portMappings[]?.servicePort]|group_by(.)| map(select(length>1) | .[0])}' ${loc_INPUT_FILE}
    else
        jq '.apps | .[]? | select(.versionInfo.lastConfigChangeAt >= "'"${loc_DATETIME_FILTER}"'" ) | {lastConfigChangeAt: .versionInfo.lastConfigChangeAt, id: .id}' ${loc_INPUT_FILE}
    fi

} # End of  fAppInfoFilter


# END OF FUNCIONES

##### Proceso de los argumentos #####
if [ "$1" = "--help" ]; then    # getops no procesa argumentos largos.
    helptext
    graceful_exit
fi
#  Recuperar opciones:
while getopts ":hf:t:d: " opt; do
    case $opt in
        h )    helptext
            graceful_exit ;;
        f ) INPUT_FILE=$OPTARG ;;
        t ) HOUR_QUANTITY=$OPTARG ;;
        d ) DUPLICATED=$OPTARG ;;
        * )    usage
        exit 1
    esac
done

if [ "${INPUT_FILE}" == "" ]; then
    error_exit "Debe especificar la opcion -f: Archivo de entrada (requerido)" 
fi

if [ "${HOUR_QUANTITY}" == "" ]; then
    error_exit "Debe especificar la opcion -t: Ultimas X horas (requerido)" 
elif [ "${HOUR_QUANTITY}" -le 0  ]; then
    error_exit "La opcion -t debe ser mayor que 0"
fi

if ! [[ -z "${DUPLICATED}" ]]; then
    if [[ "${DUPLICATED}" != "yes" ]]; then
        error_exit "La opcion -d solo admite como valor yes"
    fi
fi



##### FIN Proceso de los argumentos #####

##### Comienzo de los cambios en el sistema #####
fAppInfoFilter "${INPUT_FILE}" "${HOUR_QUANTITY}" "${DUPLICATED}"