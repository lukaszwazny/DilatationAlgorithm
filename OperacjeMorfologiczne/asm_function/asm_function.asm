
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Temat projektu: Przekształcenia morfologiczne obrazów binarnych
;Autor: Łukasz Ważny
;Przedmiot: Języki Asemblerowe
;Informatyka
;Semestr: 5
;Grupa dziekańska: 1
;Sekcja: 2
;Data wykonania projektu: 07.11.2020
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Changelog:
;
;v. 0.1 
;Dodanie pliku asm 64 bitowym z prostym sprawdzeniem czy argumenty są przesyłane do pliku dll, 
;pomyślna kompilacja procedury, próba zwracania argumentów procedury do języka wysokiego poziomu
;w celu sprawdzenia, czy funkcja odpowiednio zwraca wartości oraz, czy argumenty są dobrze wczytane
;
;v. 0.2
;Dodanie opisu procedury dilatationAsm
;
;v. 0.3
;Implementacja kopiowania obrazu spod wskaźnika źródłowego do docelowego obszaru pamięci
;
;v. 0.4
;Początek implementacji algorytmu dylatacji - napisanie szkieletu, czyli dwie pętle (petla3, petla4)
;rozpatrujące każdy piksel obrazu oraz 4 instrukcje warunkowe wewnątrz pętli, dla różnych przypadków umiejscowienia
;piksela w obrazie (głównie prypadki krańcowe)
;
;v. 0.5
;Kontynuacja implementacji algorytmu dylatacji - stworzenie dwóch pętli wewnątrz każdej instrukcji warunkowej,
;które badają, czy w obrębie elementu strukturalnego znajduje się przynajmniej jeden czarny piksel, a jeżeli tak
;przypisują do badanego piksela w głównej pętli - wartość 0 (aby był czarny), w każdej instrukcji warunkowej
;napisane pętle różnią się niezancznie ze względu na inne umiejscowienie na obrazie badanego piksela
;
;v. 0.6
;Napotkanie problemu - przy większej ilości wątków występują błędnie obliczone piksele. Analiza błędnie obliczonych
;pikseli na podstawie alogytmu napisanego w C (ze względu na prostsze znalezienie błedu), rozwiązanie problemu
;poprzez manipulację liczby wykonanych iteracji w pętlach o wartości współrzędnych punktu centralnego w elemencie
;strukturalnym, następnie przepisanie dokonanych poprawek w C do procedury w asemblerze
;
;v. 0.7
;Napotkanie problemu - przy większych obrazach występują błędnie obliczone piksele, ale tylko używając biblioteki
;asemblerowej. Rozwiązanie problemu poprzez podmianę używanych instrukcji wektorowych na takie, które operują na 
;większych typach zmiennych (np. zmiana paddusw na paddq, psubusw na psubq)
;
;v.1.0
;Ostateczne testowanie algorytmu na róænych danych, brak wykrycia kolejnych błędów. Uporządkowanie kodu,
;dodanie obszerniejszych komentarzy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.data
;brak danych

.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Funkcja wykonuje algorytm dylatacji, poprzez badanie otoczenia każdego piksela, w oparciu o 
;przekazany element strukturalny. Przypisuje wartość 0 (czarny piksel) do badanego piksela, jeżeli
;w obrębie przyłożonego do niego elementu strukturalnego w punkcie centralnym występuje przynajmniej
;jeden piksel o wartości 0 (czarny piksel)
;
; parametry wejściowe:
; rejestr rcx - src - wskaźnik na tablicę pikseli obrazu źródłowego
; rejestr rdx - dst - wskaźnik na tablicę pikseli obrazu docelowego
; rejestr r8 - imageWidth - szerokosc obrazu - zakres parametru: liczba całkowita nieujemna
; rejestr r9 - imageHeight - wysokosc obrazu - zakres parametru: liczba całkowita nieujemna
; rejestr stos - elemWidth - szerokosc elementu strukturalnego - zakres parametru: liczba całkowita nieujemna
; rejestr stos - elemHeight - wysokosc elementu strukturalnego - zakres parametru: liczba całkowita nieujemna
; rejestr stos - centrPntX - wspolrzedna x punktu centralnego - zakres parametru: liczba całkowita nieujemna mniejsza niż elemWidth
; rejestr stos - centrPntY - wspolrzedna y punktu centralnego - zakres parametru: liczba całkowita nieujemna mniejsza niż elemHeight
;
; procedura nie niszczy rejestrów
;
; parametry wyjściowe:
; void
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dilatationAsm PROC

	;kopiowanie argumentów do rejestrów, te rejestry są używane w całej procedurze, gdy potrzebne jest użycie danego argumentu
	movd xmm0, rcx					;skopiuj 1. argument - src - do rejestru xmm0
	movd xmm1, rdx					;skopiuj 2. argument - dst - do rejestru xmm1
	mov rax, r8						;skopiuj 3. argument - imageWidth - do rejestru rax
	movd xmm2, eax					;skopiuj 3. argument - imageWidth - do rejestru xmm2
	mov rax, r9						;skopiuj 4. argument - imageHeight - do rejestru rax
 	movd xmm3, eax					;skopiuj 4. argument - imageHeight - do rejestru xmm3
	mov eax, dword ptr[rsp+40]		;skopiuj 5. argument - elemWidth - ze stosu do rejestru rax
	movd xmm4, eax					;skopiuj 5. argument - elemWidth - do rejestru xmm4
	mov eax, dword ptr[rsp+48]		;skopiuj 6. argument - elemHeight - ze stosu do rejestru rax
	movd xmm5, eax					;skopiuj 6. argument - elemHeight - do rejestru xmm5
	mov eax, dword ptr[rsp+56]		;skopiuj 7. argument - centrPntX - ze stosu do rejestru rax
	movd xmm6, eax					;skopiuj 7. argument - centrPntX - do rejestru xmm6
	mov eax, dword ptr[rsp+64]		;skopiuj 8. argument - centrPntY - ze stosu do rejestru rax
	movd xmm7, eax					;skopiuj 8. argument - centrPntY - do rejestru xmm7
	
	;kopiowanie obrazu źródłowego do docelowego obszaru pamięci (pod wskaźnikiem dst)
	;petla 1 - po wierszach obrazu
	;for(int j = 0; j < imageHeight; j++)
	mov ecx, 0						;int j = 0
	jmp checkIfEndOfPetla1			;skok do sprawdzania warunków końca pętli
petla1:
	;petla 2 - po kolumnach obrazu
	;for(int i = 0; i < imageWidth; i++)
	mov ebx, 0						;int i = 0
	jmp checkIfEndOfPetla2			;skok do sprawdzania warunków końca pętli
petla2:
	movd xmm8, ecx					;kopiuj j do rejestru xmm8
    pmuludq xmm8, xmm2				;j*imageWidth		
    movd xmm9, ebx					;kopiuj i do xmm9
    paddq xmm9, xmm8				;i + j*imageWidth
	movd rsi, xmm9					;rsi = i + j*imageWidth
	movd rdi, xmm0					;adres src do rdi
	movd rax, xmm1					;adres dst do rax
    add rdi, rsi					;wyznacz adres kopiowanego piksela src i zapisz w rdi
	add rax, rsi					;wyznacz adres przypisywanego piksela dst i zapisz w rax
	mov sil, BYTE PTR [rdi]			;kopiuj wartość piksela src do rejestru esi
    mov BYTE PTR [rax], sil			;przypisz wartość piksela src do piksela dst
	add	ebx, 1						;i++
checkIfEndOfPetla2:					;sprawdzanie warunku końca pętli 2
    movd eax, xmm2					;kopiuj imageWidth do eax
    cmp  ebx, eax					;porównaj j z imageHeight
    jl  petla2						;skocz do początku pętli jeżeli i < imageWidth
    add ecx, 1						;j++
checkIfEndOfPetla1:					;sprawdzanie warunku końca pętli 1
	movd eax, xmm3					;kopiuj imageHeight do eax						
    cmp  ecx, eax					;porównaj j z imageHeight
    jl   petla1						;skocz do początku pętli, jeżeli j < imageHeight;

	;algorytm dylatacji
	;pierwsze dwie pętle - badanie każdego piksela
	;petla3 - po wierszach obrazu
	;for (int h = 0; h < imageHeight; h++)
	mov ebx, 0						;int h = 0
	jmp checkIfEndOfPetla3			;skok do sprawdzania warunków końca pętli
petla3:
	;petla4 - po kolumnach obrazu
	;for (int w = 0; w < imageWidth; w++)
	mov ecx, 0						;int w = 0
	jmp checkIfEndOfPetla4			;skok do sprawdzania warunków końca pętli
petla4:
	
	;przypadek szczególny nr 1 - gdy piksel jest blisko lewego górnego rogu obrazu
	;w tym przypadku element strukturalny wychodzi z lewej i górnej strony poza obszar obrazu
	;if (h < centrPntY && w < centrPntX)
	movd eax, xmm7					;kopiuj centrPntY do eax
	cmp ebx, eax					;porównaj h z centrPntY
	ja nIf2							;jeżeli h < centrPntY skocz do If2
	movd eax, xmm6					;kopiuj centrPntX do eax
	cmp ecx, eax					;porównaj w z centrPntX
	ja nIf2							;jeżeli w < centrPntX skocz do If2

	;dwie pętle badające otoczenie piksela w tym przypadku
	mov edx, 0						;int czy_jest = 0
	;petla5 - po wierszach elementu strukturalnego
	;for (int j = 0; j < elemHeight - h && h + j < imageHeight && !czy_jest; j++)
	mov esi, 0						;int j = 0
	jmp checkIfEndOfPetla5			;skok do sprawdzania warunków końca pętli
petla5:
	
	;petla6 - po kolumnach elementu strukturalnego
	;for (int i = 0; i < elemWidth - w && w + i - centrPntX < imageWidth && !czy_jest; i++)
	mov r8d, 0						;int i = 0
	jmp checkIfEndOfPetla6			;skok do sprawdzania warunków końca pętli
petla6:

	;sprawdzenie czy dany piksel jest czarny
	;if (image[i + j * imageWidth] < 10)
	movd xmm8, esi					;kopiuj j do rejestru xmm8
	pmuludq xmm8, xmm2				;j*imageWidth	
	movd xmm9, r8d					;kopiuj i do xmm9
    paddq xmm9, xmm8				;i + j*imageWidth
	movd rax, xmm9					;rax = i + i*imageWidth
	movd rdi, xmm0					;adres src do rdi
	add rdi, rax					;wyznacz adres piksela src i zapisz w rdi
	mov al, BYTE PTR [rdi]			;kopiuj wartość piksela src do rejestru al
	cmp al, 9						;porównaj wartość piksela src z 9
	ja koniecPetli6					; jeżeli piksel src >=10 skocz na koniec petli 6

	;jeżeli znaleziono czarny piksel - przypisanie wartości 0 do badanego piksela
	mov edx, 1						;czy_jest = 1
	;buffer[w + h * imageWidth] = 0;
	movd xmm8, ebx					;kopiuj h do rejestru xmm8
    pmuludq xmm8, xmm2				;h*imageWidth		
    movd xmm9, ecx					;kopiuj w do xmm9
    paddq xmm9, xmm8				;w + h*imageWidth
	movd rax, xmm9					;rax = w + h*imageWidth
	movd rdi, xmm1					;adres dst do rdi
	add rdi, rax					;wyznacz adres piksela dst i zapisz w rdi
	mov BYTE PTR [rdi], 0			;przypisz 0 do piksela dst

	;sprawdzenie warunków wyjścia z petli6
koniecPetli6:
	add r8d, 1						;i++
checkIfEndOfPetla6:
	movd eax, xmm4					;koiuj elemWidth do eax
	sub eax, ecx					;elemWidth - w
	cmp r8d, eax					;porównaj i z (elemWIdth - w)
	jge koniecPetli5				;jeżeli i > (elemWidth - w) skocz na koniec petli 5
	mov eax, r8d					;kopiuj i do eax
	add eax, ecx					;i + w
	movd edi, xmm6					;kopiuj centrPntX do edi
	sub eax, edi					;(i+w) - centrPntX
	movd edi, xmm2					;kopiuj imageWidth do edi
	cmp edi, eax					;porównaj imageWidth z (i+w-centrPntX)
	jle koniecPetli5				;jeżeli i+w-centrPntX>imageHeight skocz na koniec petli 5
	cmp edx, 0						;porównaj czy_jest z 0
	je petla6						;jeżeli czy_jest!=0 skocz na początek petli

	;sprawdzenie warunków wyjścia z petli5
koniecPetli5:
	add esi, 1						;j++
checkIfEndOfPetla5:
	movd eax, xmm5					;kopiuj elemHeight do eax
	sub eax, ebx					;elemHeight - h
	cmp esi, eax					;porównaj j z (elemHeight - h)
	jge endOfPetla4					;jeżeli j >= (elemHeight - h) skocz na koniec petli 4
	mov eax, esi					;kopiuj j do eax
	add eax, ebx					;j + h
	movd edi, xmm3					;kopiuj imageHeight do edi
	cmp edi, eax					;porównaj imageHeight z (j+h)
	jle endOfPetla4					;jeżeli h+j>imageHeight skocz na koniec petli 4
	cmp edx, 0						;porównaj czy_jest z 0
	je petla5						;jeżeli czy_jest!=0 skocz na początek petli
	jmp endOfPetla4					;jeżeli czy_jest = 0 skocz na koniec petli 4

	;przypadek szczególny nr 2 - gdy piksel jest blisko lewej strony obrazu
	;w tym przypadku element strukturalny wychodzi z lewej strony poza obszar obrazu
	;else
	;if (h < centrPntY)
nIf2:
	movd eax, xmm7					;kopiuj centrPntY do eax
	cmp ebx, eax					;porównaj h z centrPntY
	ja nIf3							;jeżeli h < centrPntY skocz do If3

	;dwie pętle badające otoczenie piksela w tym przypadku
	mov edx, 0						;int czy_jest = 0
	;petla7 - po wierszach elementu strukturalnego
	;for (int j = 0; j < elemHeight + h - centrPntX && h + j < imageHeight && !czy_jest; j++)
	mov esi, 0						;int j = 0
	jmp checkIfEndOfPetla7			;skok do sprawdzania warunków końca pętli
petla7:
	
	;petla8 - po kolumnach elementu strukturalnego
	;for (int i = 0; i < elemWidth && w + i - centrPntX < imageWidth && !czy_jest; i++)
	mov r8d, 0						;int i = 0
	jmp checkIfEndOfPetla8			;skok do sprawdzania warunków końca pętli
petla8:

	;sprawdzenie czy dany piksel jest czarny
	;if (image[w - centrPntX + i + j * imageWidth] < 10)
	mov eax, ecx					;kopiuj w do eax
	movd edi, xmm6					;kopiuj centrPntX do edi
	sub eax, edi					; w - centrPntX
	add eax, r8d					;w - centrPntX + i
	movd xmm8, esi					;kopiuj j do rejestru xmm8
	pmuludq xmm8, xmm2				;j*imageWidth	
	movd xmm9, eax					;kopiuj (w - centrPntX + i) do xmm9
    paddq xmm9, xmm8				;(w - centrPntX + i) + (j*imageWidth)
	movd rax, xmm9					;rax = (w - centrPntX + i) + (j*imageWidth)
	movd rdi, xmm0					;adres src do rdi
	add rdi, rax					;wyznacz adres piksela src i zapisz w rdi
	mov al, BYTE PTR [rdi]			;kopiuj wartość piksela src do rejestru al
	cmp al, 9						;porównaj wartość piksela src z 9
	ja koniecPetli8					; jeżeli piksel src >=10 skocz na koniec petli 6

	;jeżeli znaleziono czarny piksel - przypisanie wartości 0 do badanego piksela
	mov edx, 1						;czy_jest = 1
	;buffer[w + h * imageWidth] = 0;
	movd xmm8, ebx					;kopiuj h do rejestru xmm8
    pmuludq xmm8, xmm2				;h*imageWidth		
    movd xmm9, ecx					;kopiuj w do xmm9
    paddq xmm9, xmm8				;w + h*imageWidth
	movd rax, xmm9					;rax = w + h*imageWidth
	movd rdi, xmm1					;adres dst do rdi
	add rdi, rax					;wyznacz adres piksela dst i zapisz w rdi
	mov BYTE PTR [rdi], 0			;przypisz 0 do piksela dst


	;sprawdzenie warunków wyjścia z petli8
koniecPetli8:
	add r8d, 1						;i++
checkIfEndOfPetla8:
	movd eax, xmm4					;koiuj elemWidth do eax
	cmp r8d, eax					;porównaj i z elemWIdth
	jge koniecPetli7				;jeżeli i > elemWidth skocz na koniec petli 7
	mov eax, r8d					;kopiuj i do eax
	add eax, ecx					;i + w
	movd edi, xmm6					;kopiuj centrPntX do edi
	sub eax, edi					;(i+w) - centrPntX
	movd edi, xmm2					;kopiuj imageWidth do edi
	cmp edi, eax					;porównaj imageWidth z (i+w-centrPntX)
	jle koniecPetli7				;jeżeli i+w-centrPntX>imageHeight skocz na koniec petli 7
	cmp edx, 0						;porównaj czy_jest z 0
	je petla8						;jeżeli czy_jest!=0 skocz na początek petli

	;sprawdzenie warunków wyjścia z petli7
koniecPetli7:
	add esi, 1						;j++
checkIfEndOfPetla7:
	movd eax, xmm5					;kopiuj elemHeight do eax
	add eax, ebx					;elemHeight + h
	movd edi, xmm7					;kopiuj centrPntY do edi
	sub eax, edi					;(elemHeight + h) - centrPntY
	cmp esi, eax					;porównaj j z (elemHeight + h - centrPntY)
	jge endOfPetla4					;jeżeli j >= (elemHeight + h - centrPntY) skocz na koniec petli 4
	mov eax, esi					;kopiuj j do eax
	add eax, ebx					;j + h
	movd edi, xmm3					;kopiuj imageHeight do edi
	cmp edi, eax					;porównaj imageHeight z (j+h)
	jle endOfPetla4					;jeżeli h+j>imageHeight skocz na koniec petli 4
	cmp edx, 0						;porównaj czy_jest z 0
	je petla7						;jeżeli czy_jest!=0 skocz na początek petli
	jmp endOfPetla4					;jeżeli czy_jest = 0 skocz na koniec petli 4

	;przypadek szczególny nr 3 - gdy piksel jest blisko górnej strony obrazu
	;w tym przypadku element strukturalny wychodzi z górnej strony poza obszar obrazu
	;else if (w < centrPntX)
nIf3:
	movd eax, xmm6					;kopiuj centrPntX do eax
	cmp ecx, eax					;porównaj w z centrPntX
	ja nIf4							;jeżeli w > centrPntX skocz do If4	
	
	;dwie pętle badające otoczenie piksela w tym przypadku
	mov edx, 0						;int czy_jest = 0
	;petla9 - po wierszach elementu strukturalnego
	;for (int j = 0; j < elemHeight && h + j < imageHeight && !czy_jest; j++)
	mov esi, 0						;int j = 0
	jmp checkIfEndOfPetla9			;skok do sprawdzania warunków końca pętli
petla9:
	
	;petla10 - po kolumnach elementu strukturalnego
	;for (int i = 0; i < elemWidth + w - centrPntX && w + i - centrPntX < imageWidth && !czy_jest; i++)
	mov r8d, 0						;int i = 0
	jmp checkIfEndOfPetla10			;skok do sprawdzania warunków końca pętli
petla10:

	;sprawdzenie czy dany piksel jest czarny
	;if (image[h * imageWidth - imageWidth * centrPntY + i + j * imageWidth] < 10)
	movd xmm8, esi					;kopiuj j do rejestru xmm8
	pmuludq xmm8, xmm2				;j*imageWidth
	movd rax, xmm2					;kopiuj imageWidth do rax
	movd xmm9, rax					;kopiuj imageWidth do xmm9
	pmuludq xmm9, xmm7				;imageWidth * centrPntY 
	psubq xmm8, xmm9   				;j*imageWidth - imageWidth * centrPntY 
	movd xmm9, r8d					;kopiuj i do xmm9
    paddq xmm9, xmm8				;i + j*imageWidth - imageWidth * centrPntY 
	movd xmm8, ebx					;kopiuj h do xmm8
	pmuludq xmm8, xmm2				;h*imageWidth
	paddq xmm9, xmm8				;h*imageWidth + i + j*imageWidth - imageWidth * centrPntY 
	movd rax, xmm9					;rax = h*imageWidth + i + j*imageWidth - imageWidth * centrPntY
	movd rdi, xmm0					;adres src do rdi
	add rdi, rax					;wyznacz adres piksela src i zapisz w rdi
	mov al, BYTE PTR [rdi]			;kopiuj wartość piksela src do rejestru al
	cmp al, 9						;porównaj wartość piksela src z 9
	ja koniecPetli10				; jeżeli piksel src >=10 skocz na koniec petli 10

	;jeżeli znaleziono czarny piksel - przypisanie wartości 0 do badanego piksela
	mov edx, 1						;czy_jest = 1
	;buffer[w + h * imageWidth] = 0;
	movd xmm8, ebx					;kopiuj h do rejestru xmm8
    pmuludq xmm8, xmm2				;h*imageWidth		
    movd xmm9, ecx					;kopiuj w do xmm9
    paddq xmm9, xmm8				;w + h*imageWidth
	movd rax, xmm9					;rax = w + h*imageWidth
	movd rdi, xmm1					;adres dst do rdi
	add rdi, rax					;wyznacz adres piksela dst i zapisz w rdi
	mov BYTE PTR [rdi], 0			;przypisz 0 do piksela dst

	;sprawdzenie warunków wyjścia z petli10
koniecPetli10:
	add r8d, 1						;i++
checkIfEndOfPetla10:
	movd eax, xmm4					;koiuj elemWidth do eax
	add eax, ecx					;elemWidth + w
	movd edi, xmm6					;kopiuj centrPntX do edi
	sub eax, edi					;elemWidth + w - centrPntX
	cmp r8d, eax					;porównaj i z (elemWidth + w - centrPntX)
	jge koniecPetli9				;jeżeli i > (elemWidth - w) skocz na koniec petli 5
	mov eax, r8d					;kopiuj i do eax
	add eax, ecx					;i + w
	movd edi, xmm6					;kopiuj centrPntX do edi
	sub eax, edi					;(i+w) - centrPntX
	movd edi, xmm2					;kopiuj imageWidth do edi
	cmp edi, eax					;porównaj imageWidth z (i+w-centrPntX)
	jle koniecPetli9				;jeżeli i+w>imageHeight skocz na koniec petli 5
	cmp edx, 0						;porównaj czy_jest z 0
	je petla10						;jeżeli czy_jest!=0 skocz na początek petli

	;sprawdzenie warunków wyjścia z petli9
koniecPetli9:
	add esi, 1						;j++
checkIfEndOfPetla9:
	movd eax, xmm5					;kopiuj elemHeight do eax
	cmp esi, eax					;porównaj j z elemHeight
	jge endOfPetla4					;jeżeli j >= (elemHeight - h) skocz na koniec petli 4
	mov eax, esi					;kopiuj j do eax
	add eax, ebx					;j + h
	movd edi, xmm3					;kopiuj imageHeight do edi
	cmp edi, eax					;porównaj imageHeight z (j+h)
	jle endOfPetla4					;jeżeli h+j>imageHeight skocz na koniec petli 4
	cmp edx, 0						;porównaj czy_jest z 0
	je petla9						;jeżeli czy_jest!=0 skocz na początek petli
	jmp endOfPetla4					;jeżeli czy_jest = 0 skocz na koniec petli 4
	
	;pozostałe przypadki - gdy piksel nie jest blisko górnej ani lewej strony obrazu
	;w tym przypadku element strukturalny mieści się w obrębie obrazu
	;else
nIf4:
	
	;dwie pętle badające otoczenie piksela w tym przypadku
	mov edx, 0						;int czy_jest = 0
	;petla11 - po wierszach elementu strukturalnego
	;for (int j = 0; j < elemHeight && h + j < imageHeight && !czy_jest; j++)
	mov esi, 0						;int j = 0
	jmp checkIfEndOfPetla11			;skok do sprawdzania warunków końca pętli
petla11:
	
	;petla12 - po kolumnach elementu strukturalnego
	;for (int i = 0; i < elemWidth && w + i - centrPntX < imageWidth && !czy_jest; i++)
	mov r8d, 0						;int i = 0
	jmp checkIfEndOfPetla12			;skok do sprawdzania warunków końca pętli
petla12:

	;sprawdzenie czy dany piksel jest czarny
	;if (image[w + h * imageWidth - imageWidth * centrPntY - centrPntX + i + j * imageWidth] < 10)
	movd xmm8, esi					;kopiuj j do rejestru xmm8
	pmuludq xmm8, xmm2				;j*imageWidth
	movd rax, xmm2					;kopiuj imageWidth do rax
	movd xmm9, rax					;kopiuj imageWidth do xmm9
	pmuludq xmm9, xmm7				;imageWidth * centrPntY 
	psubq xmm8, xmm9   				;j*imageWidth - imageWidth * centrPntY 
	movd xmm9, r8d					;kopiuj i do xmm9
    paddq xmm9, xmm8				;i + j*imageWidth - imageWidth * centrPntY 
	movd xmm8, ebx					;kopiuj h do xmm8
	pmuludq xmm8, xmm2				;h*imageWidth
	paddq xmm9, xmm8				;h*imageWidth + i + j*imageWidth - imageWidth * centrPntY 
	psubq xmm9, xmm6				;h*imageWidth + i + j*imageWidth - imageWidth * centrPntY - centrPntX
	movd xmm8, ecx					;kopiuj w do xmm8
	paddq xmm9, xmm8				;h*imageWidth + i + j*imageWidth - imageWidth * centrPntY - centrPntX + w
	movd rax, xmm9					;rax = h*imageWidth + i + j*imageWidth - imageWidth * centrPntY - centrPntX + w
	movd rdi, xmm0					;adres src do rdi
	add rdi, rax					;wyznacz adres piksela src i zapisz w rdi
	mov al, BYTE PTR [rdi]			;kopiuj wartość piksela src do rejestru al
	cmp al, 9						;porównaj wartość piksela src z 9
	ja koniecPetli12				; jeżeli piksel src >=10 skocz na koniec petli 10

	;jeżeli znaleziono czarny piksel - przypisanie wartości 0 do badanego piksela
	mov edx, 1						;czy_jest = 1
	;buffer[w + h * imageWidth] = 0;
	movd xmm8, ebx					;kopiuj h do rejestru xmm8
    pmuludq xmm8, xmm2				;h*imageWidth		
    movd xmm9, ecx					;kopiuj w do xmm9
    paddq xmm9, xmm8				;w + h*imageWidth
	movd rax, xmm9					;rax = w + h*imageWidth
	movd rdi, xmm1					;adres dst do rdi
	add rdi, rax					;wyznacz adres piksela dst i zapisz w rdi
	mov BYTE PTR [rdi], 0			;przypisz 0 do piksela dst

	;sprawdzenie warunków wyjścia z petli12
koniecPetli12:
	add r8d, 1						;i++
checkIfEndOfPetla12:
	movd eax, xmm4					;kopiuj elemWidth do eax
	cmp r8d, eax					;porównaj i z elemWidth
	jge koniecPetli11				;jeżeli i > elemWidth skocz na koniec petli 5
	mov eax, r8d					;kopiuj i do eax
	add eax, ecx					;i + w
	movd edi, xmm6					;kopiuj centrPntX do edi
	sub eax, edi					;(i+w) - centrPntX
	movd edi, xmm2					;kopiuj imageWidth do edi
	cmp edi, eax					;porównaj imageWidth z (i+w-centrPntX)
	jle koniecPetli11				;jeżeli i+w>imageHeight skocz na koniec petli 5
	cmp edx, 0						;porównaj czy_jest z 0
	je petla12						;jeżeli czy_jest!=0 skocz na początek petli

	;sprawdzenie warunków wyjścia z petli11
koniecPetli11:
	add esi, 1						;j++
checkIfEndOfPetla11:
	movd eax, xmm5					;kopiuj elemHeight do eax
	cmp esi, eax					;porównaj j z elemHeight
	jge endOfPetla4					;jeżeli j >= elemHeight skocz na koniec petli 4
	mov eax, esi					;kopiuj j do eax
	add eax, ebx					;j + h
	movd edi, xmm3					;kopiuj imageHeight do edi
	cmp edi, eax					;porównaj imageHeight z (j+h)
	jle endOfPetla4					;jeżeli h+j>imageHeight skocz na koniec petli 4
	cmp edx, 0						;porównaj czy_jest z 0
	je petla11						;jeżeli czy_jest!=0 skocz na początek petli
	jmp endOfPetla4					;jeżeli czy_jest = 0 skocz na koniec petli 4

	;sprawdzenie warunków wyjścia z petli4
endOfPetla4:
	add ecx, 1						;w++
checkIfEndOfPetla4:					;sprawdzanie warunku końca pętli 4
	movd eax, xmm2					;kopiuj imageWidth do eax
	cmp ecx, eax					;porównaj w z imageWidth
	jl petla4						;skocz do początku pętli, jeżeli w < imageWidth;
	
	;sprawdzenie warunków wyjścia z petli3
	add ebx, 1						;h++
checkIfEndOfPetla3:					;sprawdzanie warunku końca pętli 3
	movd eax, xmm3					;kopiuj imageHeight do eax
	cmp ebx, eax					;porównaj h z imageHeight
	jl petla3						;skocz do początku pętli, jeżeli h < imageHeight;


	ret 
dilatationAsm ENDP

end