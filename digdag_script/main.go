package main

// cmd
// go run main.go Account ~/sfdc.csv

import (
        "bytes"
        "encoding/csv"
        "flag"
        "fmt"
        "io"
        "log"
        "os"
)

func main() {

        flag.Parse()
        args := flag.Args()

        if args[0] == "" {
                log.Fatal("require table name")
        }
        if args[1] == "" {
                log.Fatal("require csv path")
        }

        tableName := args[0]
        filePath := args[1]

        file, err := os.Open(filePath)
        if err != nil {
                log.Fatal(err)
        }
        defer file.Close()

        r := csv.NewReader(file)

        var query bytes.Buffer

        for {
                record, err := r.Read()
                if err == io.EOF {
                        break
                }
                if err != nil {
                        log.Fatal(err)
                }

                query.Write([]byte(fmt.Sprintf("%s", record[0])))
                query.Write([]byte{','})

        }

        queryStr := query.String()
        queryStr = queryStr[:len(queryStr)-1]

        fmt.Println(fmt.Sprintf("select %s From %s", queryStr, tableName))
}

