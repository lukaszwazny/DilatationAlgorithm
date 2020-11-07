

.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Funkcja wykonuje algorytm dylatacji
;
; @param rcx - src - wskaŸnik na tablicê pikseli obrazu Ÿród³owego
; @param rdx - dst - wskaŸnik na tablicê pikseli obrazu docelowego
; @param r8 - imageWidth - szerokosc obrazu
; @param r9 - imageHeight - wysokosc obrazu
; @param stos - elemWidth - szerokosc elementu strukturalnego
; @param stos - elemHeight - wysokosc elementu strukturalnego
; @param stos - centrPntX - wspolrzedna x punktu centralnego
; @param stos - centrPntY - wspolrzedna y punktu centralnego
;
; @return wskaŸnik na tablicê pikseli obrazu docelowego
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dilatationAsm PROC

	;kopiowanie argumentów do rejestrów, te rejestry s¹ u¿ywane w ca³ej procedurze, gdy potrzebne jest u¿ycie danego argumentu
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
	
	;kopiowanie src do dst
	;petla 1
	;for(int j = 0; j < imageHeight; j++)
	mov ecx, 0						;int j = 0
	jmp checkIfEndOfPetla1			;skok do sprawdzania warunków koñca pêtli
petla1:
	;petla 2
	;for(int i = 0; i < imageWidth; i++)
	mov ebx, 0						;int i = 0
	jmp checkIfEndOfPetla2			;skok do sprawdzania warunków koñca pêtli
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
	mov sil, BYTE PTR [rdi]			;kopiuj wartoœæ piksela src do rejestru esi
    mov BYTE PTR [rax], sil			;przypisz wartoœæ piksela src do piksela dst
	add	ebx, 1						;i++
checkIfEndOfPetla2:					;sprawdzanie warunku koñca pêtli 2
    movd eax, xmm2					;kopiuj imageWidth do eax
    cmp  ebx, eax					;porównaj j z imageHeight
    jl  petla2						;skocz do pocz¹tku pêtli je¿eli i < imageWidth
    add ecx, 1						;j++
checkIfEndOfPetla1:					;sprawdzanie warunku koñca pêtli 1
	movd eax, xmm3					;kopiuj imageHeight do eax
    ;sub  eax, 1						
    cmp  ecx, eax					;porównaj j z imageHeight
    jl   petla1						;skocz do pocz¹tku pêtli, je¿eli j < imageHeight;

	;algorytm dylatacji
	;petla3
	;for (int h = 0; h < imageHeight; h++)
	mov ebx, 0						;int h = 0
	jmp checkIfEndOfPetla3			;skok do sprawdzania warunków koñca pêtli
petla3:
	;petla4
	;for (int w = 0; w < imageWidth; w++)
	mov ecx, 0						;int w = 0
	jmp checkIfEndOfPetla4			;skok do sprawdzania warunków koñca pêtli
petla4:

	;if (h < centrPntY && w < centrPntX)
	movd eax, xmm7					;kopiuj centrPntY do eax
	cmp ebx, eax					;porównaj h z centrPntY
	ja nIf2							;je¿eli h < centrPntY skocz do If2
	movd eax, xmm6					;kopiuj centrPntX do eax
	cmp ecx, eax					;porównaj w z centrPntX
	ja nIf2							;je¿eli w < centrPntX skocz do If2

	mov edx, 0						;int czy_jest = 0
	;for (int j = 0; j < elemHeight - h && h + j < imageHeight && !czy_jest; j++)
	mov esi, 0						;int j = 0
	jmp checkIfEndOfPetla5			;skok do sprawdzania warunków koñca pêtli
petla5:
	
	;for (int i = 0; i < elemWidth - w && w + i - centrPntX < imageWidth && !czy_jest; i++)
	mov r8d, 0						;int i = 0
	jmp checkIfEndOfPetla6			;skok do sprawdzania warunków koñca pêtli
petla6:

	;if (image[i + j * imageWidth] < 10)
	movd xmm8, esi					;kopiuj j do rejestru xmm8
	pmuludq xmm8, xmm2				;j*imageWidth	
	movd xmm9, r8d					;kopiuj i do xmm9
    paddq xmm9, xmm8				;i + j*imageWidth
	movd rax, xmm9					;rax = i + i*imageWidth
	movd rdi, xmm0					;adres src do rdi
	add rdi, rax					;wyznacz adres piksela src i zapisz w rdi
	mov al, BYTE PTR [rdi]			;kopiuj wartoœæ piksela src do rejestru al
	cmp al, 9						;porównaj wartoœæ piksela src z 9
	ja koniecPetli6					; je¿eli piksel src >=10 skocz na koniec petli 6

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

koniecPetli6:
	add r8d, 1						;i++
checkIfEndOfPetla6:
	movd eax, xmm4					;koiuj elemWidth do eax
	sub eax, ecx					;elemWidth - w
	cmp r8d, eax					;porównaj i z (elemWIdth - w)
	jge koniecPetli5				;je¿eli i > (elemWidth - w) skocz na koniec petli 5
	mov eax, r8d					;kopiuj i do eax
	add eax, ecx					;i + w
	movd edi, xmm6					;kopiuj centrPntX do edi
	sub eax, edi					;(i+w) - centrPntX
	movd edi, xmm2					;kopiuj imageWidth do edi
	cmp edi, eax					;porównaj imageWidth z (i+w-centrPntX)
	jle koniecPetli5				;je¿eli i+w-centrPntX>imageHeight skocz na koniec petli 5
	cmp edx, 0						;porównaj czy_jest z 0
	je petla6						;je¿eli czy_jest!=0 skocz na pocz¹tek petli

koniecPetli5:
	add esi, 1						;j++
checkIfEndOfPetla5:
	movd eax, xmm5					;kopiuj elemHeight do eax
	sub eax, ebx					;elemHeight - h
	cmp esi, eax					;porównaj j z (elemHeight - h)
	jge endOfPetla4					;je¿eli j >= (elemHeight - h) skocz na koniec petli 4
	mov eax, esi					;kopiuj j do eax
	add eax, ebx					;j + h
	movd edi, xmm3					;kopiuj imageHeight do edi
	cmp edi, eax					;porównaj imageHeight z (j+h)
	jle endOfPetla4					;je¿eli h+j>imageHeight skocz na koniec petli 4
	cmp edx, 0						;porównaj czy_jest z 0
	je petla5						;je¿eli czy_jest!=0 skocz na pocz¹tek petli
	jmp endOfPetla4					;je¿eli czy_jest = 0 skocz na koniec petli 4

	;else
	;if (h < centrPntY)
nIf2:
	movd eax, xmm7					;kopiuj centrPntY do eax
	cmp ebx, eax					;porównaj h z centrPntY
	ja nIf3							;je¿eli h < centrPntY skocz do If3

	mov edx, 0						;int czy_jest = 0
	;for (int j = 0; j < elemHeight + h - centrPntX && h + j < imageHeight && !czy_jest; j++)
	mov esi, 0						;int j = 0
	jmp checkIfEndOfPetla7			;skok do sprawdzania warunków koñca pêtli
petla7:
	
	;for (int i = 0; i < elemWidth && w + i - centrPntX < imageWidth && !czy_jest; i++)
	mov r8d, 0						;int i = 0
	jmp checkIfEndOfPetla8			;skok do sprawdzania warunków koñca pêtli
petla8:

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
	mov al, BYTE PTR [rdi]			;kopiuj wartoœæ piksela src do rejestru al
	cmp al, 9						;porównaj wartoœæ piksela src z 9
	ja koniecPetli8					; je¿eli piksel src >=10 skocz na koniec petli 6

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


koniecPetli8:
	add r8d, 1						;i++
checkIfEndOfPetla8:
	movd eax, xmm4					;koiuj elemWidth do eax
	cmp r8d, eax					;porównaj i z elemWIdth
	jge koniecPetli7				;je¿eli i > elemWidth skocz na koniec petli 7
	mov eax, r8d					;kopiuj i do eax
	add eax, ecx					;i + w
	movd edi, xmm6					;kopiuj centrPntX do edi
	sub eax, edi					;(i+w) - centrPntX
	movd edi, xmm2					;kopiuj imageWidth do edi
	cmp edi, eax					;porównaj imageWidth z (i+w-centrPntX)
	jle koniecPetli7				;je¿eli i+w-centrPntX>imageHeight skocz na koniec petli 7
	cmp edx, 0						;porównaj czy_jest z 0
	je petla8						;je¿eli czy_jest!=0 skocz na pocz¹tek petli

koniecPetli7:
	add esi, 1						;j++
checkIfEndOfPetla7:
	movd eax, xmm5					;kopiuj elemHeight do eax
	add eax, ebx					;elemHeight + h
	movd edi, xmm7					;kopiuj centrPntY do edi
	sub eax, edi					;(elemHeight + h) - centrPntY
	cmp esi, eax					;porównaj j z (elemHeight + h - centrPntY)
	jge endOfPetla4					;je¿eli j >= (elemHeight + h - centrPntY) skocz na koniec petli 4
	mov eax, esi					;kopiuj j do eax
	add eax, ebx					;j + h
	movd edi, xmm3					;kopiuj imageHeight do edi
	cmp edi, eax					;porównaj imageHeight z (j+h)
	jle endOfPetla4					;je¿eli h+j>imageHeight skocz na koniec petli 4
	cmp edx, 0						;porównaj czy_jest z 0
	je petla7						;je¿eli czy_jest!=0 skocz na pocz¹tek petli
	jmp endOfPetla4					;je¿eli czy_jest = 0 skocz na koniec petli 4

	;else if (w < centrPntX)
nIf3:
	movd eax, xmm6					;kopiuj centrPntX do eax
	cmp ecx, eax					;porównaj w z centrPntX
	ja nIf4							;je¿eli w > centrPntX skocz do If4	
	
	mov edx, 0						;int czy_jest = 0
	;for (int j = 0; j < elemHeight && h + j < imageHeight && !czy_jest; j++)
	mov esi, 0						;int j = 0
	jmp checkIfEndOfPetla9			;skok do sprawdzania warunków koñca pêtli
petla9:
	
	;for (int i = 0; i < elemWidth + w - centrPntX && w + i - centrPntX < imageWidth && !czy_jest; i++)
	mov r8d, 0						;int i = 0
	jmp checkIfEndOfPetla10			;skok do sprawdzania warunków koñca pêtli
petla10:

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
	mov al, BYTE PTR [rdi]			;kopiuj wartoœæ piksela src do rejestru al
	cmp al, 9						;porównaj wartoœæ piksela src z 9
	ja koniecPetli10				; je¿eli piksel src >=10 skocz na koniec petli 10

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

koniecPetli10:
	add r8d, 1						;i++
checkIfEndOfPetla10:
	movd eax, xmm4					;koiuj elemWidth do eax
	add eax, ecx					;elemWidth + w
	movd edi, xmm6					;kopiuj centrPntX do edi
	sub eax, edi					;elemWidth + w - centrPntX
	cmp r8d, eax					;porównaj i z (elemWidth + w - centrPntX)
	jge koniecPetli9				;je¿eli i > (elemWidth - w) skocz na koniec petli 5
	mov eax, r8d					;kopiuj i do eax
	add eax, ecx					;i + w
	movd edi, xmm6					;kopiuj centrPntX do edi
	sub eax, edi					;(i+w) - centrPntX
	movd edi, xmm2					;kopiuj imageWidth do edi
	cmp edi, eax					;porównaj imageWidth z (i+w-centrPntX)
	jle koniecPetli9				;je¿eli i+w>imageHeight skocz na koniec petli 5
	cmp edx, 0						;porównaj czy_jest z 0
	je petla10						;je¿eli czy_jest!=0 skocz na pocz¹tek petli

koniecPetli9:
	add esi, 1						;j++
checkIfEndOfPetla9:
	movd eax, xmm5					;kopiuj elemHeight do eax
	cmp esi, eax					;porównaj j z elemHeight
	jge endOfPetla4					;je¿eli j >= (elemHeight - h) skocz na koniec petli 4
	mov eax, esi					;kopiuj j do eax
	add eax, ebx					;j + h
	movd edi, xmm3					;kopiuj imageHeight do edi
	cmp edi, eax					;porównaj imageHeight z (j+h)
	jle endOfPetla4					;je¿eli h+j>imageHeight skocz na koniec petli 4
	cmp edx, 0						;porównaj czy_jest z 0
	je petla9						;je¿eli czy_jest!=0 skocz na pocz¹tek petli
	jmp endOfPetla4					;je¿eli czy_jest = 0 skocz na koniec petli 4
	
	;else
nIf4:
	
	mov edx, 0						;int czy_jest = 0
	;for (int j = 0; j < elemHeight && h + j < imageHeight && !czy_jest; j++)
	mov esi, 0						;int j = 0
	jmp checkIfEndOfPetla11			;skok do sprawdzania warunków koñca pêtli
petla11:
	
	;for (int i = 0; i < elemWidth && w + i - centrPntX < imageWidth && !czy_jest; i++)
	mov r8d, 0						;int i = 0
	jmp checkIfEndOfPetla12			;skok do sprawdzania warunków koñca pêtli
petla12:

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
	mov al, BYTE PTR [rdi]			;kopiuj wartoœæ piksela src do rejestru al
	cmp al, 9						;porównaj wartoœæ piksela src z 9
	ja koniecPetli12				; je¿eli piksel src >=10 skocz na koniec petli 10

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

koniecPetli12:
	add r8d, 1						;i++
checkIfEndOfPetla12:
	movd eax, xmm4					;kopiuj elemWidth do eax
	cmp r8d, eax					;porównaj i z elemWidth
	jge koniecPetli11				;je¿eli i > elemWidth skocz na koniec petli 5
	mov eax, r8d					;kopiuj i do eax
	add eax, ecx					;i + w
	movd edi, xmm6					;kopiuj centrPntX do edi
	sub eax, edi					;(i+w) - centrPntX
	movd edi, xmm2					;kopiuj imageWidth do edi
	cmp edi, eax					;porównaj imageWidth z (i+w-centrPntX)
	jle koniecPetli11				;je¿eli i+w>imageHeight skocz na koniec petli 5
	cmp edx, 0						;porównaj czy_jest z 0
	je petla12						;je¿eli czy_jest!=0 skocz na pocz¹tek petli

koniecPetli11:
	add esi, 1						;j++
checkIfEndOfPetla11:
	movd eax, xmm5					;kopiuj elemHeight do eax
	cmp esi, eax					;porównaj j z elemHeight
	jge endOfPetla4					;je¿eli j >= elemHeight skocz na koniec petli 4
	mov eax, esi					;kopiuj j do eax
	add eax, ebx					;j + h
	movd edi, xmm3					;kopiuj imageHeight do edi
	cmp edi, eax					;porównaj imageHeight z (j+h)
	jle endOfPetla4					;je¿eli h+j>imageHeight skocz na koniec petli 4
	cmp edx, 0						;porównaj czy_jest z 0
	je petla11						;je¿eli czy_jest!=0 skocz na pocz¹tek petli
	jmp endOfPetla4					;je¿eli czy_jest = 0 skocz na koniec petli 4

endOfPetla4:
	add ecx, 1						;w++
checkIfEndOfPetla4:					;sprawdzanie warunku koñca pêtli 4
	movd eax, xmm2					;kopiuj imageWidth do eax
	cmp ecx, eax					;porównaj w z imageWidth
	jl petla4						;skocz do pocz¹tku pêtli, je¿eli w < imageWidth;
	
	add ebx, 1						;h++
checkIfEndOfPetla3:					;sprawdzanie warunku koñca pêtli 3
	movd eax, xmm3					;kopiuj imageHeight do eax
	cmp ebx, eax					;porównaj h z imageHeight
	jl petla3						;skocz do pocz¹tku pêtli, je¿eli h < imageHeight;


	ret 
dilatationAsm ENDP

end