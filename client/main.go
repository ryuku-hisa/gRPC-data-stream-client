package main

import (
	"context"
	"fmt"
	"log"
	"os"

	pb "github.com/ryuku-hisa/gRPC-data-stream-client/proto"
	"google.golang.org/grpc"
)

const (
	address = "192.168.15.32:50051"
)

func main() {
  if len(os.Args) < 2 {
    fmt.Println("ERROR: Specify the filename")
    os.Exit(1)
  }
	conn, err := grpc.Dial(address, grpc.WithInsecure())
	if err != nil {
		log.Fatalf("could not connect: %v", err)
	}
	defer conn.Close()
	uploadhalder := pb.NewUploadHandlerClient(conn)
	stream, err := uploadhalder.Upload(context.Background())
	if err != nil {
		fmt.Println(err)
	}
	err = Upload(stream)
	if err != nil {
		fmt.Println(err)
	}
}

func Upload(stream pb.UploadHandler_UploadClient) error {
  filename := os.Args[1]
  fp, err := os.Open(filename)
	if err != nil {
		return err
	}
	defer fp.Close()

	//fileinfo, err := fp.Stat()
	// if err != nil {
	// 	return err
	// }
	buf := make([]byte, 5096)

	for {
		n, err := fp.Read(buf)
		if n == 0 {
			break
		}
		if err != nil {
			return err
		}

		err = stream.Send(&pb.UploadRequest{
			VideoData: buf,
		})
		if err != nil {
			return err
		}

	}
//_ was resp//
	_, err = stream.CloseAndRecv()
	if err != nil {
		return err
	}
	//fmt.Println(resp.UploadStatus)
	return nil
}
