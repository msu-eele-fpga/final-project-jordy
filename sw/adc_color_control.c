#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>

#define	MAX 4096

int16_t fixed_point(int num)
{
	if (num > MAX) num = MAX;
    if (num < 0) num = 0;
	return (int16_t)(num << 2);		// 12 bit ADC to fit
}

int main (int argc, char **argv) {
	printf("\n***************\n* Read Register Values\n***************\n\n");

	FILE *file_adc_ch0 = fopen("/sys/devices/platform/ff200000.ADC/ch0_raw", "r");
	FILE *file_adc_ch1 = fopen("/sys/devices/platform/ff200000.ADC/ch1_raw", "r");
	FILE *file_adc_ch2 = fopen("/sys/devices/platform/ff200000.ADC/ch2_raw", "r");
	FILE *file_adc_ch3 = fopen("/sys/devices/platform/ff200000.ADC/ch3_raw", "r");

	FILE *file_red = fopen("/sys/devices/platform/ff24a820.rgb_controller_0/led_red", "rb+");
    FILE *file_green = fopen("/sys/devices/platform/ff24a820.rgb_controller_0/led_green", "rb+");
    FILE *file_blue = fopen("/sys/devices/platform/ff24a820.rgb_controller_0/led_blue", "rb+");
	FILE *file_cntl = fopen("/sys/devices/platform/ff24a820.rgb_controller_0/led_control", "rb+");

	int ch1;
	int ch2;
	int ch3;
	int ch4;


	int16_t fp1;
	int16_t fp2;
	int16_t fp3;
	int16_t fp4;


	char buffer1[6];
	char buffer2[6];
	char buffer3[6];
	char buffer4[6];

	if (argc != 2)
    {
		printf("Usage: %s <Decimal Value>\n", argv[0]);
		return 1;
	}

	while (1)
    {
		if (fread(buffer1,2,3, file_adc_ch0))
        {
			ch1 = atoi(buffer1);
			fp1 = fixed_point(ch1);
			printf("CH2 = %x\n", fp1);
			fprintf(file_red, "%d", fp1);
		}
		if (fread(buffer2,2,3, file_adc_ch1))
        {
			ch2 = atoi(buffer2);
			fp2 = fixed_point(ch2); // Convert by shifting by 2
			printf("CH3 = %x\n", fp2);
			fprintf(file_green, "%d", fp2);

		}
		if (fread(buffer3,2,3, file_adc_ch2))
        {
			ch3 = atoi(buffer3);
			fp3 = fixed_point(ch3);
			printf("CH4 = %x\n", fp3);
			fprintf(file_blue, "%d", fp3);
		}
		if (fread(buffer3,2,3, file_adc_ch3))
		{
			ch4 = atoi(buffer4);
			fp4 = fixed_point(ch4);
			printf("CH4 = %x\n", fp4);
			fprintf(file_cntl, "%d", fp4);
		}
		else
		{
			fseek(file_adc_ch0, 0, SEEK_SET);
            fseek(file_adc_ch1, 0, SEEK_SET);
			fseek(file_adc_ch2, 0, SEEK_SET);
			fseek(file_adc_ch3, 0, SEEK_SET);

			fseek(file_red, 0, SEEK_SET);
			fseek(file_green, 0, SEEK_SET);
			fseek(file_blue, 0, SEEK_SET);
			fseek(file_cntl, 0, SEEK_SET);


		}
	}

	fclose(file_adc_ch0);
	fclose(file_adc_ch1);
    fclose(file_adc_ch2);
    fclose(file_adc_ch3);
	fclose(file_red);
	fclose(file_green);
	fclose(file_blue);
	fclose(file_cntl);

	return 0;
}