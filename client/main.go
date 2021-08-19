package main

import (
	"context"
	"fmt"
	"io"
	"os"

	pb "github.com/Ryuku-Hisa/gRPC-data-stream-client/proto"
	"google.golang.org/grpc"
)

const (
	address = "192.168.10.32"
)

func main() {
	conn, _ := grpc.Dial("address", grpc.WithInsecure())

	defer conn.Close()
	uploadhalder := pb.NewUploadHandlerClient(conn)
	stream, err := uploadhalder.Upload(context.Background())
	err = Upload(stream)
	if err != nil {
		fmt.Println(err)
	}
}

func Upload(stream pb.UploadHandler_UploadClient) error {
	file, _ := os.Open("./sample.mp4")
	defer file.Close()
	buf := make([]byte, 1024)

	for {
		_, err := file.Read(buf)
		if err == io.EOF {
			break
		}
		if err != nil {
			return err
		}
		stream.Send(&pb.UploadRequest{VideoData: buf})
	}

	resp, err := stream.CloseAndRecv()
	if err != nil {
		return err
	}
	fmt.Println(resp.UploadStatus)
	return nil
}
