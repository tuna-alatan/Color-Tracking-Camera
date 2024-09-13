import cv2
import numpy as np
import serial

def send_integer_to_serial(integer_value, port_name='COM5', baud_rate=115200):
    try:
        # Open serial port
        ser = serial.Serial(port_name, baud_rate)

        # Convert integer to bytes
        byte_value = integer_value.to_bytes(1, byteorder='big')

        # Send byte over serial
        ser.write(byte_value)

        # Close serial port
        ser.close()

    except serial.SerialException as e:
        print()

def track_red():
    cap = cv2.VideoCapture(1)
    n_samples = 0
    total_angle = 0
    fov = 60
    prev_ang = 90
    total_samples = 6
    
    while True:
        ret, frame = cap.read()
        #frame = cv2.flip(frame, 1)

        if not ret:
            break

        # Convert BGR to HSV
        hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)

        # Define range of red color in HSV
        lower_red = np.array([0, 100, 100])
        upper_red = np.array([10, 255, 255])

        # Threshold the HSV image to get only red colors
        mask = cv2.inRange(hsv, lower_red, upper_red)

        vector = np.sum(mask, axis=0)     
        angle = min((((len(vector) - (np.argmax(vector))) / len(vector)) * fov) + (prev_ang - fov / 2), 180)

        

        if n_samples < total_samples:
            n_samples += 1
            total_angle += angle
        else:
            av_angle = max(total_angle / total_samples, 0)
            prev_ang = av_angle
            print(av_angle)
            send_integer_to_serial(int(av_angle))
            n_samples = 0
            total_angle = 0
        

        # Display the resulting frame
        cv2.imshow('Frame', frame)

        # Exit if 'q' is pressed
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    # Release the capture
    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    track_red()
