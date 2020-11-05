;INCLUDE    include\windows.inc
INCLUDE    kernel32.inc
;INCLUDE	   msvcrt.inc
;INCLUDELIB kernel32.lib
includelib msvcrt.lib

.data

.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Funkcja wykonuje algorytm dylatacji
;
; @param rcx - src - wskaŸnik na tablicê pikseli obrazu Ÿród³owego
; @param rdx - imageWidth - szerokosc obrazu
; @param r8 - imageHeight - wysokosc obrazu
; @param r9 - elemWidth - szerokosc elementu strukturalnego
; @param stos - elemHeight - wysokosc elementu strukturalnego
; @param stos - centrPntX - wspolrzedna x punktu centralnego
; @param stos - centrPntY - wspolrzedna y punktu centralnego
;
; @return wskaŸnik na tablicê pikseli obrazu docelowego
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dilatationAsm PROC

	;kopiowanie argumentów do rejestrów
	movd xmm0, rcx					;skopiuj 1. argument - src - do rejestru xmm0
	mov rax, rdx					;skopiuj 2. argument - imageWidth - do rejestru rax
	movd xmm1, eax					;skopiuj 2. argument - imageWidth - do rejestru xmm1
	mov rax, r8						;skopiuj 3. argument - imageHeight - do rejestru rax
 	movd xmm2, eax					;skopiuj 3. argument - imageHeight - do rejestru xmm2
	movd xmm3, r9					;skopiuj 4. argument - elemWidth - do rejestru xmm3
	movd xmm4, dword ptr[rsp+40]	;skopiuj 5. argument - elemHeight - ze stosu do rejestru xmm4
	movd xmm5, dword ptr[rsp+48]	;skopiuj 6. argument - centrPntX - ze stosu do rejestru xmm5
	movd xmm6, dword ptr[rsp+56]	;skopiuj 7. argument - centrPntY - ze stosu do rejestru xmm6
	
	;alokacja pamiêci na bufor obrazu docelowego
	movsd xmm7, xmm1				;skopiuj imageWidth do xmm7
	pmuludq xmm7, xmm2				;pomnó¿ imageWidth * imageHeight
	movd eax, xmm7					;wynik mno¿enia do eax
	cdqe							;podwojenie
	mov rdi, rax					;iloœæ pamiêci do zaalokowania wrzucamy do rejestru rdi
	extern malloc : PROC
	call malloc						;alokacja pamiêci
	movd xmm7, rax					;kopiuj wskaŸnik do zaalokowanej pamiêci do xmm7

	movd rax, xmm7
	ret 
dilatationAsm ENDP

end