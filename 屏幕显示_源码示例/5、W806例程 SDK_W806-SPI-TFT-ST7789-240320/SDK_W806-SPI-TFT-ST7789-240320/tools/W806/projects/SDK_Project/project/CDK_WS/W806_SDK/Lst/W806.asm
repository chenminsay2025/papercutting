
.//Obj/W806.elf:     file format elf32-csky-little


Disassembly of section .text:

08010400 <__Vectors>:
 8010400:	00 05 01 08 d0 05 01 08 d0 05 01 08 d0 05 01 08     ................
 8010410:	d0 05 01 08 d0 05 01 08 d0 05 01 08 d0 05 01 08     ................
 8010420:	d0 05 01 08 d0 05 01 08 d0 05 01 08 d0 05 01 08     ................
 8010430:	d0 05 01 08 d0 05 01 08 d0 05 01 08 d0 05 01 08     ................
 8010440:	d0 05 01 08 d0 05 01 08 d0 05 01 08 d0 05 01 08     ................
 8010450:	d0 05 01 08 d0 05 01 08 d0 05 01 08 d0 05 01 08     ................
 8010460:	d0 05 01 08 d0 05 01 08 d0 05 01 08 d0 05 01 08     ................
 8010470:	d0 05 01 08 d0 05 01 08 d0 05 01 08 d0 05 01 08     ................
 8010480:	d0 05 01 08 d0 05 01 08 d0 05 01 08 d0 05 01 08     ................
 8010490:	d0 05 01 08 d0 05 01 08 d0 05 01 08 d0 05 01 08     ................
 80104a0:	d0 05 01 08 d0 05 01 08 d0 05 01 08 d0 05 01 08     ................
 80104b0:	d0 05 01 08 d0 05 01 08 d0 05 01 08 d0 05 01 08     ................
 80104c0:	d0 05 01 08 d0 05 01 08 d0 05 01 08 d0 05 01 08     ................
 80104d0:	d0 05 01 08 d0 05 01 08 d0 05 01 08 d0 05 01 08     ................
 80104e0:	d0 05 01 08 98 21 01 08 d0 05 01 08 d0 05 01 08     .....!..........
 80104f0:	d0 05 01 08 d0 05 01 08 d0 05 01 08 d0 05 01 08     ................

08010500 <Reset_Handler>:
    .align  2
    .globl  Reset_Handler
    .type   Reset_Handler, %function
Reset_Handler:
#ifdef CONFIG_KERNEL_NONE
    lrw     r0, 0xe0000200
 8010500:	1019      	lrw      	r0, 0xe0000200	// 8010564 <__exit+0x4>
#else
    lrw     r0, 0x80000200
    mtcr    r0, psr
#endif
    mtcr    r0, psr
 8010502:	c0006420 	mtcr      	r0, cr<0, 0>

    lrw     r0, g_top_irqstack
 8010506:	1019      	lrw      	r0, 0x20001160	// 8010568 <__exit+0x8>
    mov     sp, r0
 8010508:	6f83      	mov      	r14, r0

/*
 *	move __Vectors to irq_vectors
 */
    lrw     r1, __Vectors
 801050a:	1039      	lrw      	r1, 0x8010400	// 801056c <__exit+0xc>
    lrw     r2, __vdata_start__
 801050c:	1059      	lrw      	r2, 0x20000000	// 8010570 <__exit+0x10>
    lrw     r3, __vdata_end__
 801050e:	107a      	lrw      	r3, 0x20000100	// 8010574 <__exit+0x14>

    subu    r3, r2
 8010510:	60ca      	subu      	r3, r2
    cmpnei  r3, 0
 8010512:	3b40      	cmpnei      	r3, 0
    bf      .L_loopv0_done
 8010514:	0c08      	bf      	0x8010524	// 8010524 <Reset_Handler+0x24>

.L_loopv0:
    ldw     r0, (r1, 0)
 8010516:	9100      	ld.w      	r0, (r1, 0x0)
    stw     r0, (r2, 0)
 8010518:	b200      	st.w      	r0, (r2, 0x0)
    addi    r1, 4
 801051a:	2103      	addi      	r1, 4
    addi    r2, 4
 801051c:	2203      	addi      	r2, 4
    subi    r3, 4
 801051e:	2b03      	subi      	r3, 4
    cmpnei  r3, 0
 8010520:	3b40      	cmpnei      	r3, 0
    bt      .L_loopv0
 8010522:	0bfa      	bt      	0x8010516	// 8010516 <Reset_Handler+0x16>
 *    __data_start__: VMA of start of the section to copy to
 *    __data_end__: VMA of end of the section to copy to
 *
 *  All addresses must be aligned to 4 bytes boundary.
 */
    lrw     r1, __erodata
 8010524:	1035      	lrw      	r1, 0x8063864	// 8010578 <__exit+0x18>
    lrw     r2, __data_start__
 8010526:	1056      	lrw      	r2, 0x20000100	// 801057c <__exit+0x1c>
    lrw     r3, __data_end__
 8010528:	1076      	lrw      	r3, 0x20000160	// 8010580 <__exit+0x20>

    subu    r3, r2
 801052a:	60ca      	subu      	r3, r2
    cmpnei  r3, 0
 801052c:	3b40      	cmpnei      	r3, 0
    bf      .L_loop0_done
 801052e:	0c08      	bf      	0x801053e	// 801053e <Reset_Handler+0x3e>

.L_loop0:
    ldw     r0, (r1, 0)
 8010530:	9100      	ld.w      	r0, (r1, 0x0)
    stw     r0, (r2, 0)
 8010532:	b200      	st.w      	r0, (r2, 0x0)
    addi    r1, 4
 8010534:	2103      	addi      	r1, 4
    addi    r2, 4
 8010536:	2203      	addi      	r2, 4
    subi    r3, 4
 8010538:	2b03      	subi      	r3, 4
    cmpnei  r3, 0
 801053a:	3b40      	cmpnei      	r3, 0
    bt      .L_loop0
 801053c:	0bfa      	bt      	0x8010530	// 8010530 <Reset_Handler+0x30>
 *    __bss_end__: end of the BSS section.
 *
 *  Both addresses must be aligned to 4 bytes boundary.
 */
 #if 1
    lrw     r1, __bss_start__
 801053e:	1032      	lrw      	r1, 0x20000160	// 8010584 <__exit+0x24>
    lrw     r2, __bss_end__
 8010540:	1052      	lrw      	r2, 0x200013ac	// 8010588 <__exit+0x28>

    movi    r0, 0
 8010542:	3000      	movi      	r0, 0

    subu    r2, r1
 8010544:	6086      	subu      	r2, r1
    cmpnei  r2, 0
 8010546:	3a40      	cmpnei      	r2, 0
    bf      .L_loop1_done
 8010548:	0c06      	bf      	0x8010554	// 8010554 <Reset_Handler+0x54>

.L_loop1:
    stw     r0, (r1, 0)
 801054a:	b100      	st.w      	r0, (r1, 0x0)
    addi    r1, 4
 801054c:	2103      	addi      	r1, 4
    subi    r2, 4
 801054e:	2a03      	subi      	r2, 4
    cmpnei  r2, 0
 8010550:	3a40      	cmpnei      	r2, 0
    bt      .L_loop1
 8010552:	0bfc      	bt      	0x801054a	// 801054a <Reset_Handler+0x4a>
.L_loop1_done:
#endif

#ifndef __NO_SYSTEM_INIT
    jbsr    SystemInit
 8010554:	e00011d0 	bsr      	0x80128f4	// 80128f4 <SystemInit>
#endif

#ifndef __NO_BOARD_INIT
    jbsr    board_init
 8010558:	e0001224 	bsr      	0x80129a0	// 80129a0 <board_init>
#endif

    jbsr    main
 801055c:	e0000c4c 	bsr      	0x8011df4	// 8011df4 <main>

08010560 <__exit>:
    .size   Reset_Handler, . - Reset_Handler

__exit:
    br      __exit
 8010560:	0400      	br      	0x8010560	// 8010560 <__exit>
 8010562:	0000      	.short	0x0000
 8010564:	e0000200 	.long	0xe0000200
 8010568:	20001160 	.long	0x20001160
 801056c:	08010400 	.long	0x08010400
 8010570:	20000000 	.long	0x20000000
 8010574:	20000100 	.long	0x20000100
 8010578:	08063864 	.long	0x08063864
 801057c:	20000100 	.long	0x20000100
 8010580:	20000160 	.long	0x20000160
 8010584:	20000160 	.long	0x20000160
 8010588:	200013ac 	.long	0x200013ac

0801058c <trap>:
 * default exception handler
 ******************************************************************************/
    .global trap
    .type   trap, %function
trap:
    psrset  ee
 801058c:	c1007420 	psrset      	ee

    subi    sp, 4
 8010590:	1421      	subi      	r14, r14, 4
    stw     r13, (sp)
 8010592:	ddae2000 	st.w      	r13, (r14, 0x0)
    addi    sp, 4
 8010596:	1401      	addi      	r14, r14, 4

    lrw     r13, g_trap_sp
 8010598:	ea8d000f 	lrw      	r13, 0x20001360	// 80105d4 <ADC_IRQHandler+0x4>
    stw     sp, (r13)
 801059c:	ddcd2000 	st.w      	r14, (r13, 0x0)

    lrw     sp, g_top_trapstack
 80105a0:	ea8e000e 	lrw      	r14, 0x20001360	// 80105d8 <ADC_IRQHandler+0x8>

    subi    sp, 72
 80105a4:	1432      	subi      	r14, r14, 72
    stm     r0-r12, (sp)
 80105a6:	d40e1c2c 	stm      	r0-r12, (r14)

    lrw     r0, g_trap_sp
 80105aa:	100b      	lrw      	r0, 0x20001360	// 80105d4 <ADC_IRQHandler+0x4>
    ldw     r0, (r0)
 80105ac:	9000      	ld.w      	r0, (r0, 0x0)

    stw     r0, (sp, 56) /* save r14 */
 80105ae:	b80e      	st.w      	r0, (r14, 0x38)

    subi    r0, 4
 80105b0:	2803      	subi      	r0, 4
    ldw     r13, (r0)
 80105b2:	d9a02000 	ld.w      	r13, (r0, 0x0)
    stw     r13, (sp, 52)
 80105b6:	ddae200d 	st.w      	r13, (r14, 0x34)

    stw     r15, (sp, 60)
 80105ba:	ddee200f 	st.w      	r15, (r14, 0x3c)
    mfcr    r0, epsr
 80105be:	c0026020 	mfcr      	r0, cr<2, 0>
    stw     r0, (sp, 64)
 80105c2:	b810      	st.w      	r0, (r14, 0x40)
    mfcr    r0, epc
 80105c4:	c0046020 	mfcr      	r0, cr<4, 0>
    stw     r0, (sp, 68)
 80105c8:	b811      	st.w      	r0, (r14, 0x44)

    mov     r0, sp
 80105ca:	6c3b      	mov      	r0, r14

    jbsr    trap_c
 80105cc:	e00011ac 	bsr      	0x8012924	// 8012924 <trap_c>

080105d0 <ADC_IRQHandler>:

    .align  2
    .weak   Default_Handler
    .type   Default_Handler, %function
Default_Handler:
    br      trap
 80105d0:	07de      	br      	0x801058c	// 801058c <trap>
 80105d2:	0000      	.short	0x0000
 80105d4:	20001360 	.long	0x20001360
 80105d8:	20001360 	.long	0x20001360

080105dc <__fixunsdfsi>:
 80105dc:	14d2      	push      	r4-r5, r15
 80105de:	3200      	movi      	r2, 0
 80105e0:	ea2341e0 	movih      	r3, 16864
 80105e4:	6d03      	mov      	r4, r0
 80105e6:	6d47      	mov      	r5, r1
 80105e8:	e00006a2 	bsr      	0x801132c	// 801132c <__gedf2>
 80105ec:	e9a00007 	bhsz      	r0, 0x80105fa	// 80105fa <__fixunsdfsi+0x1e>
 80105f0:	6c13      	mov      	r0, r4
 80105f2:	6c57      	mov      	r1, r5
 80105f4:	e000070c 	bsr      	0x801140c	// 801140c <__fixdfsi>
 80105f8:	1492      	pop      	r4-r5, r15
 80105fa:	3200      	movi      	r2, 0
 80105fc:	ea2341e0 	movih      	r3, 16864
 8010600:	6c13      	mov      	r0, r4
 8010602:	6c57      	mov      	r1, r5
 8010604:	e00004ae 	bsr      	0x8010f60	// 8010f60 <__subdf3>
 8010608:	e0000702 	bsr      	0x801140c	// 801140c <__fixdfsi>
 801060c:	ea238000 	movih      	r3, 32768
 8010610:	600c      	addu      	r0, r3
 8010612:	1492      	pop      	r4-r5, r15

08010614 <__udivdi3>:
 8010614:	14c5      	push      	r4-r8
 8010616:	6f4b      	mov      	r13, r2
 8010618:	6d4f      	mov      	r5, r3
 801061a:	6d03      	mov      	r4, r0
 801061c:	6f07      	mov      	r12, r1
 801061e:	e9230054 	bnez      	r3, 0x80106c6	// 80106c6 <__udivdi3+0xb2>
 8010622:	6484      	cmphs      	r1, r2
 8010624:	0870      	bt      	0x8010704	// 8010704 <__udivdi3+0xf0>
 8010626:	eb02ffff 	cmphsi      	r2, 65536
 801062a:	0cc4      	bf      	0x80107b2	// 80107b2 <__udivdi3+0x19e>
 801062c:	c6e05023 	bmaski      	r3, 24
 8010630:	648c      	cmphs      	r3, r2
 8010632:	3518      	movi      	r5, 24
 8010634:	3310      	movi      	r3, 16
 8010636:	c4a30c40 	inct      	r5, r3, 0
 801063a:	01dc      	lrw      	r6, 0x8014214	// 8010944 <__udivdi3+0x330>
 801063c:	c4a24043 	lsr      	r3, r2, r5
 8010640:	d0660023 	ldr.b      	r3, (r6, r3 << 0)
 8010644:	614c      	addu      	r5, r3
 8010646:	3320      	movi      	r3, 32
 8010648:	60d6      	subu      	r3, r5
 801064a:	e903000c 	bez      	r3, 0x8010662	// 8010662 <__udivdi3+0x4e>
 801064e:	c462402d 	lsl      	r13, r2, r3
 8010652:	c4a04045 	lsr      	r5, r0, r5
 8010656:	c4614022 	lsl      	r2, r1, r3
 801065a:	c445242c 	or      	r12, r5, r2
 801065e:	c4604024 	lsl      	r4, r0, r3
 8010662:	c60d4841 	lsri      	r1, r13, 16
 8010666:	c42c8022 	divu      	r2, r12, r1
 801066a:	c4228423 	mult      	r3, r2, r1
 801066e:	630e      	subu      	r12, r3
 8010670:	c60c4823 	lsli      	r3, r12, 16
 8010674:	c40d55e5 	zext      	r5, r13, 15, 0
 8010678:	c604484c 	lsri      	r12, r4, 16
 801067c:	c4458420 	mult      	r0, r5, r2
 8010680:	6f0c      	or      	r12, r3
 8010682:	6430      	cmphs      	r12, r0
 8010684:	0808      	bt      	0x8010694	// 8010694 <__udivdi3+0x80>
 8010686:	6334      	addu      	r12, r13
 8010688:	6770      	cmphs      	r12, r13
 801068a:	5a63      	subi      	r3, r2, 1
 801068c:	0c03      	bf      	0x8010692	// 8010692 <__udivdi3+0x7e>
 801068e:	6430      	cmphs      	r12, r0
 8010690:	0d56      	bf      	0x801093c	// 801093c <__udivdi3+0x328>
 8010692:	6c8f      	mov      	r2, r3
 8010694:	6302      	subu      	r12, r0
 8010696:	c42c8020 	divu      	r0, r12, r1
 801069a:	7c40      	mult      	r1, r0
 801069c:	6306      	subu      	r12, r1
 801069e:	c60c482c 	lsli      	r12, r12, 16
 80106a2:	c40455e4 	zext      	r4, r4, 15, 0
 80106a6:	7d40      	mult      	r5, r0
 80106a8:	6d30      	or      	r4, r12
 80106aa:	6550      	cmphs      	r4, r5
 80106ac:	6c43      	mov      	r1, r0
 80106ae:	0808      	bt      	0x80106be	// 80106be <__udivdi3+0xaa>
 80106b0:	6134      	addu      	r4, r13
 80106b2:	6750      	cmphs      	r4, r13
 80106b4:	5863      	subi      	r3, r0, 1
 80106b6:	0d21      	bf      	0x80108f8	// 80108f8 <__udivdi3+0x2e4>
 80106b8:	6550      	cmphs      	r4, r5
 80106ba:	091f      	bt      	0x80108f8	// 80108f8 <__udivdi3+0x2e4>
 80106bc:	2901      	subi      	r1, 2
 80106be:	4210      	lsli      	r0, r2, 16
 80106c0:	6c04      	or      	r0, r1
 80106c2:	3100      	movi      	r1, 0
 80106c4:	1485      	pop      	r4-r8
 80106c6:	64c4      	cmphs      	r1, r3
 80106c8:	0c6b      	bf      	0x801079e	// 801079e <__udivdi3+0x18a>
 80106ca:	eb03ffff 	cmphsi      	r3, 65536
 80106ce:	0c6b      	bf      	0x80107a4	// 80107a4 <__udivdi3+0x190>
 80106d0:	c6e0502c 	bmaski      	r12, 24
 80106d4:	64f0      	cmphs      	r12, r3
 80106d6:	ea0d0018 	movi      	r13, 24
 80106da:	ea0c0010 	movi      	r12, 16
 80106de:	c58d0c20 	incf      	r12, r13, 0
 80106e2:	0386      	lrw      	r4, 0x8014214	// 8010944 <__udivdi3+0x330>
 80106e4:	c583404d 	lsr      	r13, r3, r12
 80106e8:	d1a4002d 	ldr.b      	r13, (r4, r13 << 0)
 80106ec:	6370      	addu      	r13, r12
 80106ee:	3520      	movi      	r5, 32
 80106f0:	6176      	subu      	r5, r13
 80106f2:	e925006c 	bnez      	r5, 0x80107ca	// 80107ca <__udivdi3+0x1b6>
 80106f6:	644c      	cmphs      	r3, r1
 80106f8:	0d0d      	bf      	0x8010912	// 8010912 <__udivdi3+0x2fe>
 80106fa:	6480      	cmphs      	r0, r2
 80106fc:	c4000500 	mvc      	r0
 8010700:	6c57      	mov      	r1, r5
 8010702:	1485      	pop      	r4-r8
 8010704:	e9220006 	bnez      	r2, 0x8010710	// 8010710 <__udivdi3+0xfc>
 8010708:	ea0d0001 	movi      	r13, 1
 801070c:	c44d802d 	divu      	r13, r13, r2
 8010710:	eb0dffff 	cmphsi      	r13, 65536
 8010714:	0c55      	bf      	0x80107be	// 80107be <__udivdi3+0x1aa>
 8010716:	c6e05023 	bmaski      	r3, 24
 801071a:	674c      	cmphs      	r3, r13
 801071c:	3518      	movi      	r5, 24
 801071e:	3310      	movi      	r3, 16
 8010720:	c4a30c40 	inct      	r5, r3, 0
 8010724:	0357      	lrw      	r2, 0x8014214	// 8010944 <__udivdi3+0x330>
 8010726:	c4ad4043 	lsr      	r3, r13, r5
 801072a:	d0620023 	ldr.b      	r3, (r2, r3 << 0)
 801072e:	614c      	addu      	r5, r3
 8010730:	3620      	movi      	r6, 32
 8010732:	6196      	subu      	r6, r5
 8010734:	e926009f 	bnez      	r6, 0x8010872	// 8010872 <__udivdi3+0x25e>
 8010738:	c5a10082 	subu      	r2, r1, r13
 801073c:	c60d4846 	lsri      	r6, r13, 16
 8010740:	c40d55e5 	zext      	r5, r13, 15, 0
 8010744:	3101      	movi      	r1, 1
 8010746:	c4c2802c 	divu      	r12, r2, r6
 801074a:	c4cc8423 	mult      	r3, r12, r6
 801074e:	608e      	subu      	r2, r3
 8010750:	4250      	lsli      	r2, r2, 16
 8010752:	4c70      	lsri      	r3, r4, 16
 8010754:	c4ac8420 	mult      	r0, r12, r5
 8010758:	6cc8      	or      	r3, r2
 801075a:	640c      	cmphs      	r3, r0
 801075c:	0809      	bt      	0x801076e	// 801076e <__udivdi3+0x15a>
 801075e:	60f4      	addu      	r3, r13
 8010760:	674c      	cmphs      	r3, r13
 8010762:	e44c1000 	subi      	r2, r12, 1
 8010766:	0c03      	bf      	0x801076c	// 801076c <__udivdi3+0x158>
 8010768:	640c      	cmphs      	r3, r0
 801076a:	0ce5      	bf      	0x8010934	// 8010934 <__udivdi3+0x320>
 801076c:	6f0b      	mov      	r12, r2
 801076e:	60c2      	subu      	r3, r0
 8010770:	c4c38020 	divu      	r0, r3, r6
 8010774:	7d80      	mult      	r6, r0
 8010776:	60da      	subu      	r3, r6
 8010778:	4370      	lsli      	r3, r3, 16
 801077a:	c40455e4 	zext      	r4, r4, 15, 0
 801077e:	7d40      	mult      	r5, r0
 8010780:	6cd0      	or      	r3, r4
 8010782:	654c      	cmphs      	r3, r5
 8010784:	6c83      	mov      	r2, r0
 8010786:	0808      	bt      	0x8010796	// 8010796 <__udivdi3+0x182>
 8010788:	60f4      	addu      	r3, r13
 801078a:	674c      	cmphs      	r3, r13
 801078c:	2800      	subi      	r0, 1
 801078e:	0cb3      	bf      	0x80108f4	// 80108f4 <__udivdi3+0x2e0>
 8010790:	654c      	cmphs      	r3, r5
 8010792:	08b1      	bt      	0x80108f4	// 80108f4 <__udivdi3+0x2e0>
 8010794:	2a01      	subi      	r2, 2
 8010796:	c60c4820 	lsli      	r0, r12, 16
 801079a:	6c08      	or      	r0, r2
 801079c:	1485      	pop      	r4-r8
 801079e:	3100      	movi      	r1, 0
 80107a0:	6c07      	mov      	r0, r1
 80107a2:	1485      	pop      	r4-r8
 80107a4:	eb0300ff 	cmphsi      	r3, 256
 80107a8:	c400050d 	mvc      	r13
 80107ac:	c46d482c 	lsli      	r12, r13, 3
 80107b0:	0799      	br      	0x80106e2	// 80106e2 <__udivdi3+0xce>
 80107b2:	eb0200ff 	cmphsi      	r2, 256
 80107b6:	3308      	movi      	r3, 8
 80107b8:	c4a30c40 	inct      	r5, r3, 0
 80107bc:	073f      	br      	0x801063a	// 801063a <__udivdi3+0x26>
 80107be:	eb0d00ff 	cmphsi      	r13, 256
 80107c2:	3308      	movi      	r3, 8
 80107c4:	c4a30c40 	inct      	r5, r3, 0
 80107c8:	07ae      	br      	0x8010724	// 8010724 <__udivdi3+0x110>
 80107ca:	c5a24046 	lsr      	r6, r2, r13
 80107ce:	70d4      	lsl      	r3, r5
 80107d0:	6d8c      	or      	r6, r3
 80107d2:	c5a14044 	lsr      	r4, r1, r13
 80107d6:	4ef0      	lsri      	r7, r6, 16
 80107d8:	c4e48023 	divu      	r3, r4, r7
 80107dc:	c4a1402c 	lsl      	r12, r1, r5
 80107e0:	c5a04041 	lsr      	r1, r0, r13
 80107e4:	c4e3842d 	mult      	r13, r3, r7
 80107e8:	6c70      	or      	r1, r12
 80107ea:	6136      	subu      	r4, r13
 80107ec:	c40655ec 	zext      	r12, r6, 15, 0
 80107f0:	4490      	lsli      	r4, r4, 16
 80107f2:	c601484d 	lsri      	r13, r1, 16
 80107f6:	c46c8428 	mult      	r8, r12, r3
 80107fa:	6f50      	or      	r13, r4
 80107fc:	6634      	cmphs      	r13, r8
 80107fe:	7094      	lsl      	r2, r5
 8010800:	0806      	bt      	0x801080c	// 801080c <__udivdi3+0x1f8>
 8010802:	6358      	addu      	r13, r6
 8010804:	65b4      	cmphs      	r13, r6
 8010806:	5b83      	subi      	r4, r3, 1
 8010808:	088d      	bt      	0x8010922	// 8010922 <__udivdi3+0x30e>
 801080a:	6cd3      	mov      	r3, r4
 801080c:	6362      	subu      	r13, r8
 801080e:	c4ed8024 	divu      	r4, r13, r7
 8010812:	7dd0      	mult      	r7, r4
 8010814:	635e      	subu      	r13, r7
 8010816:	c60d482d 	lsli      	r13, r13, 16
 801081a:	c48c8427 	mult      	r7, r12, r4
 801081e:	c40155ec 	zext      	r12, r1, 15, 0
 8010822:	6f34      	or      	r12, r13
 8010824:	65f0      	cmphs      	r12, r7
 8010826:	0806      	bt      	0x8010832	// 8010832 <__udivdi3+0x21e>
 8010828:	6318      	addu      	r12, r6
 801082a:	65b0      	cmphs      	r12, r6
 801082c:	5c23      	subi      	r1, r4, 1
 801082e:	0875      	bt      	0x8010918	// 8010918 <__udivdi3+0x304>
 8010830:	6d07      	mov      	r4, r1
 8010832:	4370      	lsli      	r3, r3, 16
 8010834:	6cd0      	or      	r3, r4
 8010836:	c40355e1 	zext      	r1, r3, 15, 0
 801083a:	c40255e4 	zext      	r4, r2, 15, 0
 801083e:	c603484d 	lsri      	r13, r3, 16
 8010842:	4a50      	lsri      	r2, r2, 16
 8010844:	c4818426 	mult      	r6, r1, r4
 8010848:	7d34      	mult      	r4, r13
 801084a:	7c48      	mult      	r1, r2
 801084c:	7f48      	mult      	r13, r2
 801084e:	6050      	addu      	r1, r4
 8010850:	4e50      	lsri      	r2, r6, 16
 8010852:	6084      	addu      	r2, r1
 8010854:	6508      	cmphs      	r2, r4
 8010856:	631e      	subu      	r12, r7
 8010858:	0804      	bt      	0x8010860	// 8010860 <__udivdi3+0x24c>
 801085a:	ea210001 	movih      	r1, 1
 801085e:	6344      	addu      	r13, r1
 8010860:	4a30      	lsri      	r1, r2, 16
 8010862:	6344      	addu      	r13, r1
 8010864:	6770      	cmphs      	r12, r13
 8010866:	0c53      	bf      	0x801090c	// 801090c <__udivdi3+0x2f8>
 8010868:	6772      	cmpne      	r12, r13
 801086a:	0c49      	bf      	0x80108fc	// 80108fc <__udivdi3+0x2e8>
 801086c:	6c0f      	mov      	r0, r3
 801086e:	3100      	movi      	r1, 0
 8010870:	1485      	pop      	r4-r8
 8010872:	7358      	lsl      	r13, r6
 8010874:	c4a1404c 	lsr      	r12, r1, r5
 8010878:	c4c14022 	lsl      	r2, r1, r6
 801087c:	c4c04024 	lsl      	r4, r0, r6
 8010880:	c60d4846 	lsri      	r6, r13, 16
 8010884:	c4a04045 	lsr      	r5, r0, r5
 8010888:	c4cc8020 	divu      	r0, r12, r6
 801088c:	c4c08421 	mult      	r1, r0, r6
 8010890:	c4452423 	or      	r3, r5, r2
 8010894:	6306      	subu      	r12, r1
 8010896:	c40d55e5 	zext      	r5, r13, 15, 0
 801089a:	c60c482c 	lsli      	r12, r12, 16
 801089e:	4b30      	lsri      	r1, r3, 16
 80108a0:	c4058422 	mult      	r2, r5, r0
 80108a4:	6c70      	or      	r1, r12
 80108a6:	6484      	cmphs      	r1, r2
 80108a8:	080a      	bt      	0x80108bc	// 80108bc <__udivdi3+0x2a8>
 80108aa:	6074      	addu      	r1, r13
 80108ac:	6744      	cmphs      	r1, r13
 80108ae:	e5801000 	subi      	r12, r0, 1
 80108b2:	0c3f      	bf      	0x8010930	// 8010930 <__udivdi3+0x31c>
 80108b4:	6484      	cmphs      	r1, r2
 80108b6:	083d      	bt      	0x8010930	// 8010930 <__udivdi3+0x31c>
 80108b8:	2801      	subi      	r0, 2
 80108ba:	6074      	addu      	r1, r13
 80108bc:	604a      	subu      	r1, r2
 80108be:	c4c1802c 	divu      	r12, r1, r6
 80108c2:	c4cc8422 	mult      	r2, r12, r6
 80108c6:	5949      	subu      	r2, r1, r2
 80108c8:	4250      	lsli      	r2, r2, 16
 80108ca:	c40355e3 	zext      	r3, r3, 15, 0
 80108ce:	c5858421 	mult      	r1, r5, r12
 80108d2:	6c8c      	or      	r2, r3
 80108d4:	6448      	cmphs      	r2, r1
 80108d6:	080b      	bt      	0x80108ec	// 80108ec <__udivdi3+0x2d8>
 80108d8:	60b4      	addu      	r2, r13
 80108da:	6748      	cmphs      	r2, r13
 80108dc:	e46c1000 	subi      	r3, r12, 1
 80108e0:	0c26      	bf      	0x801092c	// 801092c <__udivdi3+0x318>
 80108e2:	6448      	cmphs      	r2, r1
 80108e4:	0824      	bt      	0x801092c	// 801092c <__udivdi3+0x318>
 80108e6:	e58c1001 	subi      	r12, r12, 2
 80108ea:	60b4      	addu      	r2, r13
 80108ec:	6086      	subu      	r2, r1
 80108ee:	4030      	lsli      	r1, r0, 16
 80108f0:	6c70      	or      	r1, r12
 80108f2:	072a      	br      	0x8010746	// 8010746 <__udivdi3+0x132>
 80108f4:	6c83      	mov      	r2, r0
 80108f6:	0750      	br      	0x8010796	// 8010796 <__udivdi3+0x182>
 80108f8:	6c4f      	mov      	r1, r3
 80108fa:	06e2      	br      	0x80106be	// 80106be <__udivdi3+0xaa>
 80108fc:	4250      	lsli      	r2, r2, 16
 80108fe:	c40655e6 	zext      	r6, r6, 15, 0
 8010902:	c4a04021 	lsl      	r1, r0, r5
 8010906:	6098      	addu      	r2, r6
 8010908:	6484      	cmphs      	r1, r2
 801090a:	0bb1      	bt      	0x801086c	// 801086c <__udivdi3+0x258>
 801090c:	5b03      	subi      	r0, r3, 1
 801090e:	3100      	movi      	r1, 0
 8010910:	1485      	pop      	r4-r8
 8010912:	6c57      	mov      	r1, r5
 8010914:	3001      	movi      	r0, 1
 8010916:	1485      	pop      	r4-r8
 8010918:	65f0      	cmphs      	r12, r7
 801091a:	0b8b      	bt      	0x8010830	// 8010830 <__udivdi3+0x21c>
 801091c:	2c01      	subi      	r4, 2
 801091e:	6318      	addu      	r12, r6
 8010920:	0789      	br      	0x8010832	// 8010832 <__udivdi3+0x21e>
 8010922:	6634      	cmphs      	r13, r8
 8010924:	0b73      	bt      	0x801080a	// 801080a <__udivdi3+0x1f6>
 8010926:	2b01      	subi      	r3, 2
 8010928:	6358      	addu      	r13, r6
 801092a:	0771      	br      	0x801080c	// 801080c <__udivdi3+0x1f8>
 801092c:	6f0f      	mov      	r12, r3
 801092e:	07df      	br      	0x80108ec	// 80108ec <__udivdi3+0x2d8>
 8010930:	6c33      	mov      	r0, r12
 8010932:	07c5      	br      	0x80108bc	// 80108bc <__udivdi3+0x2a8>
 8010934:	e58c1001 	subi      	r12, r12, 2
 8010938:	60f4      	addu      	r3, r13
 801093a:	071a      	br      	0x801076e	// 801076e <__udivdi3+0x15a>
 801093c:	2a01      	subi      	r2, 2
 801093e:	6334      	addu      	r12, r13
 8010940:	06aa      	br      	0x8010694	// 8010694 <__udivdi3+0x80>
 8010942:	0000      	.short	0x0000
 8010944:	08014214 	.long	0x08014214

08010948 <__umoddi3>:
 8010948:	14c6      	push      	r4-r9
 801094a:	6d4b      	mov      	r5, r2
 801094c:	6f4f      	mov      	r13, r3
 801094e:	6d83      	mov      	r6, r0
 8010950:	6f07      	mov      	r12, r1
 8010952:	e923004a 	bnez      	r3, 0x80109e6	// 80109e6 <__umoddi3+0x9e>
 8010956:	6484      	cmphs      	r1, r2
 8010958:	086b      	bt      	0x8010a2e	// 8010a2e <__umoddi3+0xe6>
 801095a:	eb02ffff 	cmphsi      	r2, 65536
 801095e:	0cc0      	bf      	0x8010ade	// 8010ade <__umoddi3+0x196>
 8010960:	c6e05023 	bmaski      	r3, 24
 8010964:	648c      	cmphs      	r3, r2
 8010966:	ea0d0018 	movi      	r13, 24
 801096a:	3310      	movi      	r3, 16
 801096c:	c5a30c40 	inct      	r13, r3, 0
 8010970:	0281      	lrw      	r4, 0x8014214	// 8010c68 <__umoddi3+0x320>
 8010972:	c5a24043 	lsr      	r3, r2, r13
 8010976:	d0640023 	ldr.b      	r3, (r4, r3 << 0)
 801097a:	634c      	addu      	r13, r3
 801097c:	3420      	movi      	r4, 32
 801097e:	6136      	subu      	r4, r13
 8010980:	e904000b 	bez      	r4, 0x8010996	// 8010996 <__umoddi3+0x4e>
 8010984:	7050      	lsl      	r1, r4
 8010986:	c5a0404d 	lsr      	r13, r0, r13
 801098a:	c4824025 	lsl      	r5, r2, r4
 801098e:	c42d242c 	or      	r12, r13, r1
 8010992:	c4804026 	lsl      	r6, r0, r4
 8010996:	c605484d 	lsri      	r13, r5, 16
 801099a:	c5ac8021 	divu      	r1, r12, r13
 801099e:	c5a18422 	mult      	r2, r1, r13
 80109a2:	c40555e0 	zext      	r0, r5, 15, 0
 80109a6:	c44c0082 	subu      	r2, r12, r2
 80109aa:	c4208423 	mult      	r3, r0, r1
 80109ae:	4250      	lsli      	r2, r2, 16
 80109b0:	4e30      	lsri      	r1, r6, 16
 80109b2:	6c48      	or      	r1, r2
 80109b4:	64c4      	cmphs      	r1, r3
 80109b6:	0808      	bt      	0x80109c6	// 80109c6 <__umoddi3+0x7e>
 80109b8:	6054      	addu      	r1, r5
 80109ba:	6544      	cmphs      	r1, r5
 80109bc:	0c05      	bf      	0x80109c6	// 80109c6 <__umoddi3+0x7e>
 80109be:	5954      	addu      	r2, r1, r5
 80109c0:	64c4      	cmphs      	r1, r3
 80109c2:	c4220c20 	incf      	r1, r2, 0
 80109c6:	604e      	subu      	r1, r3
 80109c8:	c5a18023 	divu      	r3, r1, r13
 80109cc:	7f4c      	mult      	r13, r3
 80109ce:	6076      	subu      	r1, r13
 80109d0:	7c0c      	mult      	r0, r3
 80109d2:	4130      	lsli      	r1, r1, 16
 80109d4:	c40655e3 	zext      	r3, r6, 15, 0
 80109d8:	6cc4      	or      	r3, r1
 80109da:	640c      	cmphs      	r3, r0
 80109dc:	0c69      	bf      	0x8010aae	// 8010aae <__umoddi3+0x166>
 80109de:	5b01      	subu      	r0, r3, r0
 80109e0:	7011      	lsr      	r0, r4
 80109e2:	3100      	movi      	r1, 0
 80109e4:	1486      	pop      	r4-r9
 80109e6:	64c4      	cmphs      	r1, r3
 80109e8:	0ffe      	bf      	0x80109e4	// 80109e4 <__umoddi3+0x9c>
 80109ea:	eb03ffff 	cmphsi      	r3, 65536
 80109ee:	0c6b      	bf      	0x8010ac4	// 8010ac4 <__umoddi3+0x17c>
 80109f0:	c6e0502d 	bmaski      	r13, 24
 80109f4:	64f4      	cmphs      	r13, r3
 80109f6:	3518      	movi      	r5, 24
 80109f8:	ea0d0010 	movi      	r13, 16
 80109fc:	c5a50c20 	incf      	r13, r5, 0
 8010a00:	03a5      	lrw      	r5, 0x8014214	// 8010c68 <__umoddi3+0x320>
 8010a02:	c5a34044 	lsr      	r4, r3, r13
 8010a06:	d0850025 	ldr.b      	r5, (r5, r4 << 0)
 8010a0a:	6174      	addu      	r5, r13
 8010a0c:	3420      	movi      	r4, 32
 8010a0e:	6116      	subu      	r4, r5
 8010a10:	e924006d 	bnez      	r4, 0x8010aea	// 8010aea <__umoddi3+0x1a2>
 8010a14:	644c      	cmphs      	r3, r1
 8010a16:	0c03      	bf      	0x8010a1c	// 8010a1c <__umoddi3+0xd4>
 8010a18:	6480      	cmphs      	r0, r2
 8010a1a:	0d20      	bf      	0x8010c5a	// 8010c5a <__umoddi3+0x312>
 8010a1c:	5889      	subu      	r4, r0, r2
 8010a1e:	6500      	cmphs      	r0, r4
 8010a20:	c461008c 	subu      	r12, r1, r3
 8010a24:	6443      	mvcv      	r1
 8010a26:	6306      	subu      	r12, r1
 8010a28:	6c13      	mov      	r0, r4
 8010a2a:	6c73      	mov      	r1, r12
 8010a2c:	1486      	pop      	r4-r9
 8010a2e:	e9220005 	bnez      	r2, 0x8010a38	// 8010a38 <__umoddi3+0xf0>
 8010a32:	3501      	movi      	r5, 1
 8010a34:	c4458025 	divu      	r5, r5, r2
 8010a38:	eb05ffff 	cmphsi      	r5, 65536
 8010a3c:	0c4b      	bf      	0x8010ad2	// 8010ad2 <__umoddi3+0x18a>
 8010a3e:	c6e05023 	bmaski      	r3, 24
 8010a42:	654c      	cmphs      	r3, r5
 8010a44:	ea0d0018 	movi      	r13, 24
 8010a48:	3310      	movi      	r3, 16
 8010a4a:	c5a30c40 	inct      	r13, r3, 0
 8010a4e:	0358      	lrw      	r2, 0x8014214	// 8010c68 <__umoddi3+0x320>
 8010a50:	c5a54043 	lsr      	r3, r5, r13
 8010a54:	d0620023 	ldr.b      	r3, (r2, r3 << 0)
 8010a58:	634c      	addu      	r13, r3
 8010a5a:	3420      	movi      	r4, 32
 8010a5c:	6136      	subu      	r4, r13
 8010a5e:	e92400af 	bnez      	r4, 0x8010bbc	// 8010bbc <__umoddi3+0x274>
 8010a62:	c4a1008c 	subu      	r12, r1, r5
 8010a66:	4df0      	lsri      	r7, r5, 16
 8010a68:	c40555e2 	zext      	r2, r5, 15, 0
 8010a6c:	c4ec8021 	divu      	r1, r12, r7
 8010a70:	c4e18423 	mult      	r3, r1, r7
 8010a74:	630e      	subu      	r12, r3
 8010a76:	c60c482c 	lsli      	r12, r12, 16
 8010a7a:	c4418423 	mult      	r3, r1, r2
 8010a7e:	4e30      	lsri      	r1, r6, 16
 8010a80:	6c70      	or      	r1, r12
 8010a82:	64c4      	cmphs      	r1, r3
 8010a84:	0808      	bt      	0x8010a94	// 8010a94 <__umoddi3+0x14c>
 8010a86:	6054      	addu      	r1, r5
 8010a88:	6544      	cmphs      	r1, r5
 8010a8a:	0c05      	bf      	0x8010a94	// 8010a94 <__umoddi3+0x14c>
 8010a8c:	5914      	addu      	r0, r1, r5
 8010a8e:	64c4      	cmphs      	r1, r3
 8010a90:	c4200c20 	incf      	r1, r0, 0
 8010a94:	604e      	subu      	r1, r3
 8010a96:	c4e18020 	divu      	r0, r1, r7
 8010a9a:	7dc0      	mult      	r7, r0
 8010a9c:	605e      	subu      	r1, r7
 8010a9e:	4130      	lsli      	r1, r1, 16
 8010aa0:	c40655e6 	zext      	r6, r6, 15, 0
 8010aa4:	7c08      	mult      	r0, r2
 8010aa6:	c4c12423 	or      	r3, r1, r6
 8010aaa:	640c      	cmphs      	r3, r0
 8010aac:	0808      	bt      	0x8010abc	// 8010abc <__umoddi3+0x174>
 8010aae:	60d4      	addu      	r3, r5
 8010ab0:	654c      	cmphs      	r3, r5
 8010ab2:	0c05      	bf      	0x8010abc	// 8010abc <__umoddi3+0x174>
 8010ab4:	614c      	addu      	r5, r3
 8010ab6:	640c      	cmphs      	r3, r0
 8010ab8:	c4650c20 	incf      	r3, r5, 0
 8010abc:	5b01      	subu      	r0, r3, r0
 8010abe:	7011      	lsr      	r0, r4
 8010ac0:	3100      	movi      	r1, 0
 8010ac2:	1486      	pop      	r4-r9
 8010ac4:	eb0300ff 	cmphsi      	r3, 256
 8010ac8:	c4000505 	mvc      	r5
 8010acc:	c465482d 	lsli      	r13, r5, 3
 8010ad0:	0798      	br      	0x8010a00	// 8010a00 <__umoddi3+0xb8>
 8010ad2:	eb0500ff 	cmphsi      	r5, 256
 8010ad6:	3308      	movi      	r3, 8
 8010ad8:	c5a30c40 	inct      	r13, r3, 0
 8010adc:	07b9      	br      	0x8010a4e	// 8010a4e <__umoddi3+0x106>
 8010ade:	eb0200ff 	cmphsi      	r2, 256
 8010ae2:	3308      	movi      	r3, 8
 8010ae4:	c5a30c40 	inct      	r13, r3, 0
 8010ae8:	0744      	br      	0x8010970	// 8010970 <__umoddi3+0x28>
 8010aea:	70d0      	lsl      	r3, r4
 8010aec:	c4a24047 	lsr      	r7, r2, r5
 8010af0:	6dcc      	or      	r7, r3
 8010af2:	c4a14046 	lsr      	r6, r1, r5
 8010af6:	c481402c 	lsl      	r12, r1, r4
 8010afa:	c4a04041 	lsr      	r1, r0, r5
 8010afe:	6c70      	or      	r1, r12
 8010b00:	c607484c 	lsri      	r12, r7, 16
 8010b04:	c5868028 	divu      	r8, r6, r12
 8010b08:	c4824023 	lsl      	r3, r2, r4
 8010b0c:	c5888422 	mult      	r2, r8, r12
 8010b10:	618a      	subu      	r6, r2
 8010b12:	c40755ed 	zext      	r13, r7, 15, 0
 8010b16:	46d0      	lsli      	r6, r6, 16
 8010b18:	4950      	lsri      	r2, r1, 16
 8010b1a:	c50d8429 	mult      	r9, r13, r8
 8010b1e:	6c98      	or      	r2, r6
 8010b20:	6648      	cmphs      	r2, r9
 8010b22:	7010      	lsl      	r0, r4
 8010b24:	0807      	bt      	0x8010b32	// 8010b32 <__umoddi3+0x1ea>
 8010b26:	609c      	addu      	r2, r7
 8010b28:	65c8      	cmphs      	r2, r7
 8010b2a:	e4c81000 	subi      	r6, r8, 1
 8010b2e:	088a      	bt      	0x8010c42	// 8010c42 <__umoddi3+0x2fa>
 8010b30:	6e1b      	mov      	r8, r6
 8010b32:	60a6      	subu      	r2, r9
 8010b34:	c5828026 	divu      	r6, r2, r12
 8010b38:	7f18      	mult      	r12, r6
 8010b3a:	60b2      	subu      	r2, r12
 8010b3c:	4250      	lsli      	r2, r2, 16
 8010b3e:	c40155e1 	zext      	r1, r1, 15, 0
 8010b42:	7f58      	mult      	r13, r6
 8010b44:	6c48      	or      	r1, r2
 8010b46:	6744      	cmphs      	r1, r13
 8010b48:	0806      	bt      	0x8010b54	// 8010b54 <__umoddi3+0x20c>
 8010b4a:	605c      	addu      	r1, r7
 8010b4c:	65c4      	cmphs      	r1, r7
 8010b4e:	5e43      	subi      	r2, r6, 1
 8010b50:	0874      	bt      	0x8010c38	// 8010c38 <__umoddi3+0x2f0>
 8010b52:	6d8b      	mov      	r6, r2
 8010b54:	c6084822 	lsli      	r2, r8, 16
 8010b58:	6c98      	or      	r2, r6
 8010b5a:	c40255e8 	zext      	r8, r2, 15, 0
 8010b5e:	c603484c 	lsri      	r12, r3, 16
 8010b62:	4a50      	lsri      	r2, r2, 16
 8010b64:	c5a1008d 	subu      	r13, r1, r13
 8010b68:	c40355e1 	zext      	r1, r3, 15, 0
 8010b6c:	c4288426 	mult      	r6, r8, r1
 8010b70:	7c48      	mult      	r1, r2
 8010b72:	7e30      	mult      	r8, r12
 8010b74:	7cb0      	mult      	r2, r12
 8010b76:	6204      	addu      	r8, r1
 8010b78:	c606484c 	lsri      	r12, r6, 16
 8010b7c:	6320      	addu      	r12, r8
 8010b7e:	6470      	cmphs      	r12, r1
 8010b80:	0804      	bt      	0x8010b88	// 8010b88 <__umoddi3+0x240>
 8010b82:	ea210001 	movih      	r1, 1
 8010b86:	6084      	addu      	r2, r1
 8010b88:	c60c4841 	lsri      	r1, r12, 16
 8010b8c:	6048      	addu      	r1, r2
 8010b8e:	6474      	cmphs      	r13, r1
 8010b90:	c60c482c 	lsli      	r12, r12, 16
 8010b94:	c40655e6 	zext      	r6, r6, 15, 0
 8010b98:	6318      	addu      	r12, r6
 8010b9a:	0c46      	bf      	0x8010c26	// 8010c26 <__umoddi3+0x2de>
 8010b9c:	6476      	cmpne      	r13, r1
 8010b9e:	0c60      	bf      	0x8010c5e	// 8010c5e <__umoddi3+0x316>
 8010ba0:	c42d0081 	subu      	r1, r13, r1
 8010ba4:	6cf3      	mov      	r3, r12
 8010ba6:	586d      	subu      	r3, r0, r3
 8010ba8:	64c0      	cmphs      	r0, r3
 8010baa:	6743      	mvcv      	r13
 8010bac:	6076      	subu      	r1, r13
 8010bae:	c4a14025 	lsl      	r5, r1, r5
 8010bb2:	c4834040 	lsr      	r0, r3, r4
 8010bb6:	6c14      	or      	r0, r5
 8010bb8:	7051      	lsr      	r1, r4
 8010bba:	1486      	pop      	r4-r9
 8010bbc:	7150      	lsl      	r5, r4
 8010bbe:	c5a14048 	lsr      	r8, r1, r13
 8010bc2:	4df0      	lsri      	r7, r5, 16
 8010bc4:	c5a0404d 	lsr      	r13, r0, r13
 8010bc8:	7050      	lsl      	r1, r4
 8010bca:	6c74      	or      	r1, r13
 8010bcc:	c4e8802d 	divu      	r13, r8, r7
 8010bd0:	c4ed8423 	mult      	r3, r13, r7
 8010bd4:	c40555e2 	zext      	r2, r5, 15, 0
 8010bd8:	620e      	subu      	r8, r3
 8010bda:	c5a2842c 	mult      	r12, r2, r13
 8010bde:	c6084828 	lsli      	r8, r8, 16
 8010be2:	c601484d 	lsri      	r13, r1, 16
 8010be6:	6f60      	or      	r13, r8
 8010be8:	6734      	cmphs      	r13, r12
 8010bea:	c4804026 	lsl      	r6, r0, r4
 8010bee:	0804      	bt      	0x8010bf6	// 8010bf6 <__umoddi3+0x2ae>
 8010bf0:	6354      	addu      	r13, r5
 8010bf2:	6574      	cmphs      	r13, r5
 8010bf4:	082d      	bt      	0x8010c4e	// 8010c4e <__umoddi3+0x306>
 8010bf6:	6372      	subu      	r13, r12
 8010bf8:	c4ed8023 	divu      	r3, r13, r7
 8010bfc:	c4e3842c 	mult      	r12, r3, r7
 8010c00:	6372      	subu      	r13, r12
 8010c02:	c60d482c 	lsli      	r12, r13, 16
 8010c06:	c40155e1 	zext      	r1, r1, 15, 0
 8010c0a:	7cc8      	mult      	r3, r2
 8010c0c:	6f04      	or      	r12, r1
 8010c0e:	64f0      	cmphs      	r12, r3
 8010c10:	0809      	bt      	0x8010c22	// 8010c22 <__umoddi3+0x2da>
 8010c12:	6314      	addu      	r12, r5
 8010c14:	6570      	cmphs      	r12, r5
 8010c16:	0c06      	bf      	0x8010c22	// 8010c22 <__umoddi3+0x2da>
 8010c18:	c4ac0021 	addu      	r1, r12, r5
 8010c1c:	64f0      	cmphs      	r12, r3
 8010c1e:	c5810c20 	incf      	r12, r1, 0
 8010c22:	630e      	subu      	r12, r3
 8010c24:	0724      	br      	0x8010a6c	// 8010a6c <__umoddi3+0x124>
 8010c26:	c46c0083 	subu      	r3, r12, r3
 8010c2a:	64f0      	cmphs      	r12, r3
 8010c2c:	605e      	subu      	r1, r7
 8010c2e:	65c3      	mvcv      	r7
 8010c30:	605e      	subu      	r1, r7
 8010c32:	c42d0081 	subu      	r1, r13, r1
 8010c36:	07b8      	br      	0x8010ba6	// 8010ba6 <__umoddi3+0x25e>
 8010c38:	6744      	cmphs      	r1, r13
 8010c3a:	0b8c      	bt      	0x8010b52	// 8010b52 <__umoddi3+0x20a>
 8010c3c:	2e01      	subi      	r6, 2
 8010c3e:	605c      	addu      	r1, r7
 8010c40:	078a      	br      	0x8010b54	// 8010b54 <__umoddi3+0x20c>
 8010c42:	6648      	cmphs      	r2, r9
 8010c44:	0b76      	bt      	0x8010b30	// 8010b30 <__umoddi3+0x1e8>
 8010c46:	e5081001 	subi      	r8, r8, 2
 8010c4a:	609c      	addu      	r2, r7
 8010c4c:	0773      	br      	0x8010b32	// 8010b32 <__umoddi3+0x1ea>
 8010c4e:	c4ad0023 	addu      	r3, r13, r5
 8010c52:	6734      	cmphs      	r13, r12
 8010c54:	c5a30c20 	incf      	r13, r3, 0
 8010c58:	07cf      	br      	0x8010bf6	// 8010bf6 <__umoddi3+0x2ae>
 8010c5a:	6d03      	mov      	r4, r0
 8010c5c:	06e6      	br      	0x8010a28	// 8010a28 <__umoddi3+0xe0>
 8010c5e:	6700      	cmphs      	r0, r12
 8010c60:	0fe3      	bf      	0x8010c26	// 8010c26 <__umoddi3+0x2de>
 8010c62:	6cf3      	mov      	r3, r12
 8010c64:	3100      	movi      	r1, 0
 8010c66:	07a0      	br      	0x8010ba6	// 8010ba6 <__umoddi3+0x25e>
 8010c68:	08014214 	.long	0x08014214

08010c6c <_fpadd_parts>:
 8010c6c:	14c8      	push      	r4-r11
 8010c6e:	1423      	subi      	r14, r14, 12
 8010c70:	9060      	ld.w      	r3, (r0, 0x0)
 8010c72:	3501      	movi      	r5, 1
 8010c74:	64d4      	cmphs      	r5, r3
 8010c76:	0871      	bt      	0x8010d58	// 8010d58 <_fpadd_parts+0xec>
 8010c78:	d9812000 	ld.w      	r12, (r1, 0x0)
 8010c7c:	6714      	cmphs      	r5, r12
 8010c7e:	086f      	bt      	0x8010d5c	// 8010d5c <_fpadd_parts+0xf0>
 8010c80:	3b44      	cmpnei      	r3, 4
 8010c82:	0cef      	bf      	0x8010e60	// 8010e60 <_fpadd_parts+0x1f4>
 8010c84:	eb4c0004 	cmpnei      	r12, 4
 8010c88:	0c6a      	bf      	0x8010d5c	// 8010d5c <_fpadd_parts+0xf0>
 8010c8a:	eb4c0002 	cmpnei      	r12, 2
 8010c8e:	0cc7      	bf      	0x8010e1c	// 8010e1c <_fpadd_parts+0x1b0>
 8010c90:	3b42      	cmpnei      	r3, 2
 8010c92:	0c65      	bf      	0x8010d5c	// 8010d5c <_fpadd_parts+0xf0>
 8010c94:	9062      	ld.w      	r3, (r0, 0x8)
 8010c96:	d9812002 	ld.w      	r12, (r1, 0x8)
 8010c9a:	c583008d 	subu      	r13, r3, r12
 8010c9e:	c40d0208 	abs      	r8, r13
 8010ca2:	eb28003f 	cmplti      	r8, 64
 8010ca6:	90c3      	ld.w      	r6, (r0, 0xc)
 8010ca8:	90e4      	ld.w      	r7, (r0, 0x10)
 8010caa:	b8c0      	st.w      	r6, (r14, 0x0)
 8010cac:	b8e1      	st.w      	r7, (r14, 0x4)
 8010cae:	d9412003 	ld.w      	r10, (r1, 0xc)
 8010cb2:	d9612004 	ld.w      	r11, (r1, 0x10)
 8010cb6:	0856      	bt      	0x8010d62	// 8010d62 <_fpadd_parts+0xf6>
 8010cb8:	64f1      	cmplt      	r12, r3
 8010cba:	0cc9      	bf      	0x8010e4c	// 8010e4c <_fpadd_parts+0x1e0>
 8010cbc:	ea0a0000 	movi      	r10, 0
 8010cc0:	ea0b0000 	movi      	r11, 0
 8010cc4:	9001      	ld.w      	r0, (r0, 0x4)
 8010cc6:	9121      	ld.w      	r1, (r1, 0x4)
 8010cc8:	6442      	cmpne      	r0, r1
 8010cca:	0c82      	bf      	0x8010dce	// 8010dce <_fpadd_parts+0x162>
 8010ccc:	d98e2000 	ld.w      	r12, (r14, 0x0)
 8010cd0:	d9ae2001 	ld.w      	r13, (r14, 0x4)
 8010cd4:	e90000b8 	bez      	r0, 0x8010e44	// 8010e44 <_fpadd_parts+0x1d8>
 8010cd8:	6730      	cmphs      	r12, r12
 8010cda:	c58a010c 	subc      	r12, r10, r12
 8010cde:	c5ab010d 	subc      	r13, r11, r13
 8010ce2:	e98d00c9 	blz      	r13, 0x8010e74	// 8010e74 <_fpadd_parts+0x208>
 8010ce6:	3100      	movi      	r1, 0
 8010ce8:	b221      	st.w      	r1, (r2, 0x4)
 8010cea:	b262      	st.w      	r3, (r2, 0x8)
 8010cec:	dd822003 	st.w      	r12, (r2, 0xc)
 8010cf0:	dda22004 	st.w      	r13, (r2, 0x10)
 8010cf4:	6c33      	mov      	r0, r12
 8010cf6:	6c77      	mov      	r1, r13
 8010cf8:	3840      	cmpnei      	r0, 0
 8010cfa:	c4210c81 	decf      	r1, r1, 1
 8010cfe:	2800      	subi      	r0, 1
 8010d00:	c7605023 	bmaski      	r3, 28
 8010d04:	644c      	cmphs      	r3, r1
 8010d06:	0c71      	bf      	0x8010de8	// 8010de8 <_fpadd_parts+0x17c>
 8010d08:	64c6      	cmpne      	r1, r3
 8010d0a:	0d0d      	bf      	0x8010f24	// 8010f24 <_fpadd_parts+0x2b8>
 8010d0c:	9262      	ld.w      	r3, (r2, 0x8)
 8010d0e:	3600      	movi      	r6, 0
 8010d10:	3700      	movi      	r7, 0
 8010d12:	ea0a0000 	movi      	r10, 0
 8010d16:	2b00      	subi      	r3, 1
 8010d18:	2e00      	subi      	r6, 1
 8010d1a:	2f00      	subi      	r7, 1
 8010d1c:	c7605028 	bmaski      	r8, 28
 8010d20:	e54a1001 	subi      	r10, r10, 2
 8010d24:	0403      	br      	0x8010d2a	// 8010d2a <_fpadd_parts+0xbe>
 8010d26:	6606      	cmpne      	r1, r8
 8010d28:	0c8b      	bf      	0x8010e3e	// 8010e3e <_fpadd_parts+0x1d2>
 8010d2a:	6511      	cmplt      	r4, r4
 8010d2c:	c58c0044 	addc      	r4, r12, r12
 8010d30:	c5ad0045 	addc      	r5, r13, r13
 8010d34:	6401      	cmplt      	r0, r0
 8010d36:	c4c40040 	addc      	r0, r4, r6
 8010d3a:	c4e50041 	addc      	r1, r5, r7
 8010d3e:	6460      	cmphs      	r8, r1
 8010d40:	6e4f      	mov      	r9, r3
 8010d42:	6f13      	mov      	r12, r4
 8010d44:	6f57      	mov      	r13, r5
 8010d46:	2b00      	subi      	r3, 1
 8010d48:	0bef      	bt      	0x8010d26	// 8010d26 <_fpadd_parts+0xba>
 8010d4a:	3303      	movi      	r3, 3
 8010d4c:	b283      	st.w      	r4, (r2, 0xc)
 8010d4e:	b2a4      	st.w      	r5, (r2, 0x10)
 8010d50:	dd222002 	st.w      	r9, (r2, 0x8)
 8010d54:	b260      	st.w      	r3, (r2, 0x0)
 8010d56:	6c0b      	mov      	r0, r2
 8010d58:	1403      	addi      	r14, r14, 12
 8010d5a:	1488      	pop      	r4-r11
 8010d5c:	6c07      	mov      	r0, r1
 8010d5e:	1403      	addi      	r14, r14, 12
 8010d60:	1488      	pop      	r4-r11
 8010d62:	e96d009a 	blsz      	r13, 0x8010e96	// 8010e96 <_fpadd_parts+0x22a>
 8010d66:	ea0d001f 	movi      	r13, 31
 8010d6a:	c42b4826 	lsli      	r6, r11, 1
 8010d6e:	6362      	subu      	r13, r8
 8010d70:	e588101f 	subi      	r12, r8, 32
 8010d74:	c5a6402d 	lsl      	r13, r6, r13
 8010d78:	c50a4046 	lsr      	r6, r10, r8
 8010d7c:	c7ec2880 	btsti      	r12, 31
 8010d80:	c58b4049 	lsr      	r9, r11, r12
 8010d84:	3400      	movi      	r4, 0
 8010d86:	6db4      	or      	r6, r13
 8010d88:	c4c90c20 	incf      	r6, r9, 0
 8010d8c:	6f53      	mov      	r13, r4
 8010d8e:	c5854029 	lsl      	r9, r5, r12
 8010d92:	c505402c 	lsl      	r12, r5, r8
 8010d96:	c50b4047 	lsr      	r7, r11, r8
 8010d9a:	c5a90c20 	incf      	r13, r9, 0
 8010d9e:	c5840c20 	incf      	r12, r4, 0
 8010da2:	c4e40c20 	incf      	r7, r4, 0
 8010da6:	eb4c0000 	cmpnei      	r12, 0
 8010daa:	c5ad0c81 	decf      	r13, r13, 1
 8010dae:	e58c1000 	subi      	r12, r12, 1
 8010db2:	6b28      	and      	r12, r10
 8010db4:	6b6c      	and      	r13, r11
 8010db6:	6f34      	or      	r12, r13
 8010db8:	eb4c0000 	cmpnei      	r12, 0
 8010dbc:	9001      	ld.w      	r0, (r0, 0x4)
 8010dbe:	9121      	ld.w      	r1, (r1, 0x4)
 8010dc0:	c400050a 	mvc      	r10
 8010dc4:	6442      	cmpne      	r0, r1
 8010dc6:	6ed3      	mov      	r11, r4
 8010dc8:	6e98      	or      	r10, r6
 8010dca:	6edc      	or      	r11, r7
 8010dcc:	0b80      	bt      	0x8010ccc	// 8010ccc <_fpadd_parts+0x60>
 8010dce:	d98e2000 	ld.w      	r12, (r14, 0x0)
 8010dd2:	d9ae2001 	ld.w      	r13, (r14, 0x4)
 8010dd6:	6731      	cmplt      	r12, r12
 8010dd8:	6329      	addc      	r12, r10
 8010dda:	636d      	addc      	r13, r11
 8010ddc:	b201      	st.w      	r0, (r2, 0x4)
 8010dde:	b262      	st.w      	r3, (r2, 0x8)
 8010de0:	dd822003 	st.w      	r12, (r2, 0xc)
 8010de4:	dda22004 	st.w      	r13, (r2, 0x10)
 8010de8:	3303      	movi      	r3, 3
 8010dea:	b260      	st.w      	r3, (r2, 0x0)
 8010dec:	c7805023 	bmaski      	r3, 29
 8010df0:	674c      	cmphs      	r3, r13
 8010df2:	0812      	bt      	0x8010e16	// 8010e16 <_fpadd_parts+0x1aa>
 8010df4:	c7ed4823 	lsli      	r3, r13, 31
 8010df8:	c42c4840 	lsri      	r0, r12, 1
 8010dfc:	6c0c      	or      	r0, r3
 8010dfe:	c42d4841 	lsri      	r1, r13, 1
 8010e02:	9262      	ld.w      	r3, (r2, 0x8)
 8010e04:	e48c2001 	andi      	r4, r12, 1
 8010e08:	3500      	movi      	r5, 0
 8010e0a:	6c10      	or      	r0, r4
 8010e0c:	6c54      	or      	r1, r5
 8010e0e:	2300      	addi      	r3, 1
 8010e10:	b203      	st.w      	r0, (r2, 0xc)
 8010e12:	b224      	st.w      	r1, (r2, 0x10)
 8010e14:	b262      	st.w      	r3, (r2, 0x8)
 8010e16:	6c0b      	mov      	r0, r2
 8010e18:	1403      	addi      	r14, r14, 12
 8010e1a:	1488      	pop      	r4-r11
 8010e1c:	3b42      	cmpnei      	r3, 2
 8010e1e:	0b9d      	bt      	0x8010d58	// 8010d58 <_fpadd_parts+0xec>
 8010e20:	b260      	st.w      	r3, (r2, 0x0)
 8010e22:	9061      	ld.w      	r3, (r0, 0x4)
 8010e24:	b261      	st.w      	r3, (r2, 0x4)
 8010e26:	9062      	ld.w      	r3, (r0, 0x8)
 8010e28:	b262      	st.w      	r3, (r2, 0x8)
 8010e2a:	9063      	ld.w      	r3, (r0, 0xc)
 8010e2c:	b263      	st.w      	r3, (r2, 0xc)
 8010e2e:	9064      	ld.w      	r3, (r0, 0x10)
 8010e30:	9121      	ld.w      	r1, (r1, 0x4)
 8010e32:	b264      	st.w      	r3, (r2, 0x10)
 8010e34:	9061      	ld.w      	r3, (r0, 0x4)
 8010e36:	68c4      	and      	r3, r1
 8010e38:	b261      	st.w      	r3, (r2, 0x4)
 8010e3a:	6c0b      	mov      	r0, r2
 8010e3c:	078e      	br      	0x8010d58	// 8010d58 <_fpadd_parts+0xec>
 8010e3e:	6428      	cmphs      	r10, r0
 8010e40:	0b75      	bt      	0x8010d2a	// 8010d2a <_fpadd_parts+0xbe>
 8010e42:	0784      	br      	0x8010d4a	// 8010d4a <_fpadd_parts+0xde>
 8010e44:	6730      	cmphs      	r12, r12
 8010e46:	632b      	subc      	r12, r10
 8010e48:	636f      	subc      	r13, r11
 8010e4a:	074c      	br      	0x8010ce2	// 8010ce2 <_fpadd_parts+0x76>
 8010e4c:	6cf3      	mov      	r3, r12
 8010e4e:	ea0d0000 	movi      	r13, 0
 8010e52:	ea0c0000 	movi      	r12, 0
 8010e56:	dd8e2000 	st.w      	r12, (r14, 0x0)
 8010e5a:	ddae2001 	st.w      	r13, (r14, 0x4)
 8010e5e:	0733      	br      	0x8010cc4	// 8010cc4 <_fpadd_parts+0x58>
 8010e60:	eb4c0004 	cmpnei      	r12, 4
 8010e64:	0b7a      	bt      	0x8010d58	// 8010d58 <_fpadd_parts+0xec>
 8010e66:	9041      	ld.w      	r2, (r0, 0x4)
 8010e68:	9161      	ld.w      	r3, (r1, 0x4)
 8010e6a:	64ca      	cmpne      	r2, r3
 8010e6c:	124b      	lrw      	r2, 0x8014200	// 8010f98 <__subdf3+0x38>
 8010e6e:	c4020c40 	inct      	r0, r2, 0
 8010e72:	0773      	br      	0x8010d58	// 8010d58 <_fpadd_parts+0xec>
 8010e74:	ea0a0000 	movi      	r10, 0
 8010e78:	ea0b0000 	movi      	r11, 0
 8010e7c:	3101      	movi      	r1, 1
 8010e7e:	6730      	cmphs      	r12, r12
 8010e80:	c58a010c 	subc      	r12, r10, r12
 8010e84:	c5ab010d 	subc      	r13, r11, r13
 8010e88:	b221      	st.w      	r1, (r2, 0x4)
 8010e8a:	b262      	st.w      	r3, (r2, 0x8)
 8010e8c:	dd822003 	st.w      	r12, (r2, 0xc)
 8010e90:	dda22004 	st.w      	r13, (r2, 0x10)
 8010e94:	0730      	br      	0x8010cf4	// 8010cf4 <_fpadd_parts+0x88>
 8010e96:	e90dff17 	bez      	r13, 0x8010cc4	// 8010cc4 <_fpadd_parts+0x58>
 8010e9a:	98c0      	ld.w      	r6, (r14, 0x0)
 8010e9c:	98e1      	ld.w      	r7, (r14, 0x4)
 8010e9e:	ea0d001f 	movi      	r13, 31
 8010ea2:	47c1      	lsli      	r6, r7, 1
 8010ea4:	6362      	subu      	r13, r8
 8010ea6:	c5a6402d 	lsl      	r13, r6, r13
 8010eaa:	ddae2002 	st.w      	r13, (r14, 0x8)
 8010eae:	d9ae2000 	ld.w      	r13, (r14, 0x0)
 8010eb2:	e588101f 	subi      	r12, r8, 32
 8010eb6:	c50d4046 	lsr      	r6, r13, r8
 8010eba:	d9ae2002 	ld.w      	r13, (r14, 0x8)
 8010ebe:	c7ec2880 	btsti      	r12, 31
 8010ec2:	3400      	movi      	r4, 0
 8010ec4:	c5874049 	lsr      	r9, r7, r12
 8010ec8:	6db4      	or      	r6, r13
 8010eca:	d9ae2001 	ld.w      	r13, (r14, 0x4)
 8010ece:	c4c90c20 	incf      	r6, r9, 0
 8010ed2:	c50d4047 	lsr      	r7, r13, r8
 8010ed6:	c5854029 	lsl      	r9, r5, r12
 8010eda:	6f53      	mov      	r13, r4
 8010edc:	c505402c 	lsl      	r12, r5, r8
 8010ee0:	c5a90c20 	incf      	r13, r9, 0
 8010ee4:	c5840c20 	incf      	r12, r4, 0
 8010ee8:	c4e40c20 	incf      	r7, r4, 0
 8010eec:	60e0      	addu      	r3, r8
 8010eee:	eb4c0000 	cmpnei      	r12, 0
 8010ef2:	c5ad0c81 	decf      	r13, r13, 1
 8010ef6:	e58c1000 	subi      	r12, r12, 1
 8010efa:	d90e2000 	ld.w      	r8, (r14, 0x0)
 8010efe:	d92e2001 	ld.w      	r9, (r14, 0x4)
 8010f02:	6a30      	and      	r8, r12
 8010f04:	6a74      	and      	r9, r13
 8010f06:	6f23      	mov      	r12, r8
 8010f08:	6f67      	mov      	r13, r9
 8010f0a:	6f34      	or      	r12, r13
 8010f0c:	eb4c0000 	cmpnei      	r12, 0
 8010f10:	c400050c 	mvc      	r12
 8010f14:	6f53      	mov      	r13, r4
 8010f16:	c5862424 	or      	r4, r6, r12
 8010f1a:	c5a72425 	or      	r5, r7, r13
 8010f1e:	b880      	st.w      	r4, (r14, 0x0)
 8010f20:	b8a1      	st.w      	r5, (r14, 0x4)
 8010f22:	06d1      	br      	0x8010cc4	// 8010cc4 <_fpadd_parts+0x58>
 8010f24:	3300      	movi      	r3, 0
 8010f26:	2b01      	subi      	r3, 2
 8010f28:	640c      	cmphs      	r3, r0
 8010f2a:	0af1      	bt      	0x8010d0c	// 8010d0c <_fpadd_parts+0xa0>
 8010f2c:	075e      	br      	0x8010de8	// 8010de8 <_fpadd_parts+0x17c>
	...

08010f30 <__adddf3>:
 8010f30:	14d2      	push      	r4-r5, r15
 8010f32:	1433      	subi      	r14, r14, 76
 8010f34:	b800      	st.w      	r0, (r14, 0x0)
 8010f36:	b821      	st.w      	r1, (r14, 0x4)
 8010f38:	6c3b      	mov      	r0, r14
 8010f3a:	6d47      	mov      	r5, r1
 8010f3c:	1904      	addi      	r1, r14, 16
 8010f3e:	b863      	st.w      	r3, (r14, 0xc)
 8010f40:	b842      	st.w      	r2, (r14, 0x8)
 8010f42:	e00003b7 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 8010f46:	1909      	addi      	r1, r14, 36
 8010f48:	1802      	addi      	r0, r14, 8
 8010f4a:	e00003b3 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 8010f4e:	1a0e      	addi      	r2, r14, 56
 8010f50:	1909      	addi      	r1, r14, 36
 8010f52:	1804      	addi      	r0, r14, 16
 8010f54:	e3fffe8c 	bsr      	0x8010c6c	// 8010c6c <_fpadd_parts>
 8010f58:	e00002e4 	bsr      	0x8011520	// 8011520 <__pack_d>
 8010f5c:	1413      	addi      	r14, r14, 76
 8010f5e:	1492      	pop      	r4-r5, r15

08010f60 <__subdf3>:
 8010f60:	14d2      	push      	r4-r5, r15
 8010f62:	1433      	subi      	r14, r14, 76
 8010f64:	b800      	st.w      	r0, (r14, 0x0)
 8010f66:	b821      	st.w      	r1, (r14, 0x4)
 8010f68:	6c3b      	mov      	r0, r14
 8010f6a:	6d47      	mov      	r5, r1
 8010f6c:	1904      	addi      	r1, r14, 16
 8010f6e:	b842      	st.w      	r2, (r14, 0x8)
 8010f70:	b863      	st.w      	r3, (r14, 0xc)
 8010f72:	e000039f 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 8010f76:	1909      	addi      	r1, r14, 36
 8010f78:	1802      	addi      	r0, r14, 8
 8010f7a:	e000039b 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 8010f7e:	986a      	ld.w      	r3, (r14, 0x28)
 8010f80:	e4634001 	xori      	r3, r3, 1
 8010f84:	1a0e      	addi      	r2, r14, 56
 8010f86:	1909      	addi      	r1, r14, 36
 8010f88:	1804      	addi      	r0, r14, 16
 8010f8a:	b86a      	st.w      	r3, (r14, 0x28)
 8010f8c:	e3fffe70 	bsr      	0x8010c6c	// 8010c6c <_fpadd_parts>
 8010f90:	e00002c8 	bsr      	0x8011520	// 8011520 <__pack_d>
 8010f94:	1413      	addi      	r14, r14, 76
 8010f96:	1492      	pop      	r4-r5, r15
 8010f98:	08014200 	.long	0x08014200

08010f9c <__muldf3>:
 8010f9c:	14d8      	push      	r4-r11, r15
 8010f9e:	1436      	subi      	r14, r14, 88
 8010fa0:	b803      	st.w      	r0, (r14, 0xc)
 8010fa2:	b824      	st.w      	r1, (r14, 0x10)
 8010fa4:	1803      	addi      	r0, r14, 12
 8010fa6:	1907      	addi      	r1, r14, 28
 8010fa8:	b866      	st.w      	r3, (r14, 0x18)
 8010faa:	b845      	st.w      	r2, (r14, 0x14)
 8010fac:	e0000382 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 8010fb0:	190c      	addi      	r1, r14, 48
 8010fb2:	1805      	addi      	r0, r14, 20
 8010fb4:	e000037e 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 8010fb8:	9867      	ld.w      	r3, (r14, 0x1c)
 8010fba:	3b01      	cmphsi      	r3, 2
 8010fbc:	0ca4      	bf      	0x8011104	// 8011104 <__muldf3+0x168>
 8010fbe:	984c      	ld.w      	r2, (r14, 0x30)
 8010fc0:	3a01      	cmphsi      	r2, 2
 8010fc2:	0c94      	bf      	0x80110ea	// 80110ea <__muldf3+0x14e>
 8010fc4:	3b44      	cmpnei      	r3, 4
 8010fc6:	0c9d      	bf      	0x8011100	// 8011100 <__muldf3+0x164>
 8010fc8:	3a44      	cmpnei      	r2, 4
 8010fca:	0c8e      	bf      	0x80110e6	// 80110e6 <__muldf3+0x14a>
 8010fcc:	3b42      	cmpnei      	r3, 2
 8010fce:	0c9b      	bf      	0x8011104	// 8011104 <__muldf3+0x168>
 8010fd0:	3a42      	cmpnei      	r2, 2
 8010fd2:	0c8c      	bf      	0x80110ea	// 80110ea <__muldf3+0x14e>
 8010fd4:	d98e200f 	ld.w      	r12, (r14, 0x3c)
 8010fd8:	d90e200a 	ld.w      	r8, (r14, 0x28)
 8010fdc:	3300      	movi      	r3, 0
 8010fde:	6c33      	mov      	r0, r12
 8010fe0:	6ca3      	mov      	r2, r8
 8010fe2:	6c4f      	mov      	r1, r3
 8010fe4:	dd8e2002 	st.w      	r12, (r14, 0x8)
 8010fe8:	d96e2010 	ld.w      	r11, (r14, 0x40)
 8010fec:	e0000274 	bsr      	0x80114d4	// 80114d4 <__muldi3>
 8010ff0:	3300      	movi      	r3, 0
 8010ff2:	6ca3      	mov      	r2, r8
 8010ff4:	6d83      	mov      	r6, r0
 8010ff6:	6dc7      	mov      	r7, r1
 8010ff8:	6c4f      	mov      	r1, r3
 8010ffa:	6c2f      	mov      	r0, r11
 8010ffc:	e000026c 	bsr      	0x80114d4	// 80114d4 <__muldi3>
 8011000:	d94e200b 	ld.w      	r10, (r14, 0x2c)
 8011004:	3300      	movi      	r3, 0
 8011006:	6e03      	mov      	r8, r0
 8011008:	6e47      	mov      	r9, r1
 801100a:	6caf      	mov      	r2, r11
 801100c:	6c4f      	mov      	r1, r3
 801100e:	6c2b      	mov      	r0, r10
 8011010:	e0000262 	bsr      	0x80114d4	// 80114d4 <__muldi3>
 8011014:	d98e2002 	ld.w      	r12, (r14, 0x8)
 8011018:	3300      	movi      	r3, 0
 801101a:	b800      	st.w      	r0, (r14, 0x0)
 801101c:	b821      	st.w      	r1, (r14, 0x4)
 801101e:	6cb3      	mov      	r2, r12
 8011020:	6c2b      	mov      	r0, r10
 8011022:	6c4f      	mov      	r1, r3
 8011024:	e0000258 	bsr      	0x80114d4	// 80114d4 <__muldi3>
 8011028:	6401      	cmplt      	r0, r0
 801102a:	6021      	addc      	r0, r8
 801102c:	6065      	addc      	r1, r9
 801102e:	6644      	cmphs      	r1, r9
 8011030:	0c80      	bf      	0x8011130	// 8011130 <__muldf3+0x194>
 8011032:	6466      	cmpne      	r9, r1
 8011034:	0c7c      	bf      	0x801112c	// 801112c <__muldf3+0x190>
 8011036:	ea080000 	movi      	r8, 0
 801103a:	ea090000 	movi      	r9, 0
 801103e:	3200      	movi      	r2, 0
 8011040:	6cc3      	mov      	r3, r0
 8011042:	6489      	cmplt      	r2, r2
 8011044:	6099      	addc      	r2, r6
 8011046:	60dd      	addc      	r3, r7
 8011048:	65cc      	cmphs      	r3, r7
 801104a:	0c6a      	bf      	0x801111e	// 801111e <__muldf3+0x182>
 801104c:	64de      	cmpne      	r7, r3
 801104e:	0c66      	bf      	0x801111a	// 801111a <__muldf3+0x17e>
 8011050:	6f07      	mov      	r12, r1
 8011052:	ea0d0000 	movi      	r13, 0
 8011056:	9800      	ld.w      	r0, (r14, 0x0)
 8011058:	9821      	ld.w      	r1, (r14, 0x4)
 801105a:	6401      	cmplt      	r0, r0
 801105c:	6031      	addc      	r0, r12
 801105e:	6075      	addc      	r1, r13
 8011060:	6621      	cmplt      	r8, r8
 8011062:	6201      	addc      	r8, r0
 8011064:	6245      	addc      	r9, r1
 8011066:	980e      	ld.w      	r0, (r14, 0x38)
 8011068:	9829      	ld.w      	r1, (r14, 0x24)
 801106a:	6040      	addu      	r1, r0
 801106c:	590e      	addi      	r0, r1, 4
 801106e:	b813      	st.w      	r0, (r14, 0x4c)
 8011070:	d98e2008 	ld.w      	r12, (r14, 0x20)
 8011074:	980d      	ld.w      	r0, (r14, 0x34)
 8011076:	6432      	cmpne      	r12, r0
 8011078:	c780502a 	bmaski      	r10, 29
 801107c:	c4000500 	mvc      	r0
 8011080:	6668      	cmphs      	r10, r9
 8011082:	b812      	st.w      	r0, (r14, 0x48)
 8011084:	086f      	bt      	0x8011162	// 8011162 <__muldf3+0x1c6>
 8011086:	2104      	addi      	r1, 5
 8011088:	ea0c0000 	movi      	r12, 0
 801108c:	ea2d8000 	movih      	r13, 32768
 8011090:	e4082001 	andi      	r0, r8, 1
 8011094:	6ec7      	mov      	r11, r1
 8011096:	e900000a 	bez      	r0, 0x80110aa	// 80110aa <__muldf3+0x10e>
 801109a:	431f      	lsli      	r0, r3, 31
 801109c:	4a81      	lsri      	r4, r2, 1
 801109e:	6d00      	or      	r4, r0
 80110a0:	4ba1      	lsri      	r5, r3, 1
 80110a2:	c5842422 	or      	r2, r4, r12
 80110a6:	c5a52423 	or      	r3, r5, r13
 80110aa:	c4294840 	lsri      	r0, r9, 1
 80110ae:	6428      	cmphs      	r10, r0
 80110b0:	c7e94827 	lsli      	r7, r9, 31
 80110b4:	c4284846 	lsri      	r6, r8, 1
 80110b8:	c4c72428 	or      	r8, r7, r6
 80110bc:	6e43      	mov      	r9, r0
 80110be:	2100      	addi      	r1, 1
 80110c0:	0fe8      	bf      	0x8011090	// 8011090 <__muldf3+0xf4>
 80110c2:	dd6e2013 	st.w      	r11, (r14, 0x4c)
 80110c6:	e42820ff 	andi      	r1, r8, 255
 80110ca:	eb410080 	cmpnei      	r1, 128
 80110ce:	0c36      	bf      	0x801113a	// 801113a <__muldf3+0x19e>
 80110d0:	3303      	movi      	r3, 3
 80110d2:	dd0e2014 	st.w      	r8, (r14, 0x50)
 80110d6:	dd2e2015 	st.w      	r9, (r14, 0x54)
 80110da:	b871      	st.w      	r3, (r14, 0x44)
 80110dc:	1811      	addi      	r0, r14, 68
 80110de:	e0000221 	bsr      	0x8011520	// 8011520 <__pack_d>
 80110e2:	1416      	addi      	r14, r14, 88
 80110e4:	1498      	pop      	r4-r11, r15
 80110e6:	3b42      	cmpnei      	r3, 2
 80110e8:	0c3b      	bf      	0x801115e	// 801115e <__muldf3+0x1c2>
 80110ea:	986d      	ld.w      	r3, (r14, 0x34)
 80110ec:	9848      	ld.w      	r2, (r14, 0x20)
 80110ee:	64ca      	cmpne      	r2, r3
 80110f0:	c4000503 	mvc      	r3
 80110f4:	180c      	addi      	r0, r14, 48
 80110f6:	b86d      	st.w      	r3, (r14, 0x34)
 80110f8:	e0000214 	bsr      	0x8011520	// 8011520 <__pack_d>
 80110fc:	1416      	addi      	r14, r14, 88
 80110fe:	1498      	pop      	r4-r11, r15
 8011100:	3a42      	cmpnei      	r2, 2
 8011102:	0c2e      	bf      	0x801115e	// 801115e <__muldf3+0x1c2>
 8011104:	9848      	ld.w      	r2, (r14, 0x20)
 8011106:	986d      	ld.w      	r3, (r14, 0x34)
 8011108:	64ca      	cmpne      	r2, r3
 801110a:	c4000503 	mvc      	r3
 801110e:	1807      	addi      	r0, r14, 28
 8011110:	b868      	st.w      	r3, (r14, 0x20)
 8011112:	e0000207 	bsr      	0x8011520	// 8011520 <__pack_d>
 8011116:	1416      	addi      	r14, r14, 88
 8011118:	1498      	pop      	r4-r11, r15
 801111a:	6588      	cmphs      	r2, r6
 801111c:	0b9a      	bt      	0x8011050	// 8011050 <__muldf3+0xb4>
 801111e:	e5080000 	addi      	r8, r8, 1
 8011122:	eb480000 	cmpnei      	r8, 0
 8011126:	c5290c21 	incf      	r9, r9, 1
 801112a:	0793      	br      	0x8011050	// 8011050 <__muldf3+0xb4>
 801112c:	6600      	cmphs      	r0, r8
 801112e:	0b84      	bt      	0x8011036	// 8011036 <__muldf3+0x9a>
 8011130:	ea080000 	movi      	r8, 0
 8011134:	ea090001 	movi      	r9, 1
 8011138:	0783      	br      	0x801103e	// 801103e <__muldf3+0xa2>
 801113a:	e4282100 	andi      	r1, r8, 256
 801113e:	e921ffc9 	bnez      	r1, 0x80110d0	// 80110d0 <__muldf3+0x134>
 8011142:	6c8c      	or      	r2, r3
 8011144:	e902ffc6 	bez      	r2, 0x80110d0	// 80110d0 <__muldf3+0x134>
 8011148:	3280      	movi      	r2, 128
 801114a:	3300      	movi      	r3, 0
 801114c:	3100      	movi      	r1, 0
 801114e:	6489      	cmplt      	r2, r2
 8011150:	60a1      	addc      	r2, r8
 8011152:	60e5      	addc      	r3, r9
 8011154:	29ff      	subi      	r1, 256
 8011156:	c4222028 	and      	r8, r2, r1
 801115a:	6e4f      	mov      	r9, r3
 801115c:	07ba      	br      	0x80110d0	// 80110d0 <__muldf3+0x134>
 801115e:	100f      	lrw      	r0, 0x8014200	// 8011198 <__muldf3+0x1fc>
 8011160:	07bf      	br      	0x80110de	// 80110de <__muldf3+0x142>
 8011162:	c760502c 	bmaski      	r12, 28
 8011166:	6670      	cmphs      	r12, r9
 8011168:	0faf      	bf      	0x80110c6	// 80110c6 <__muldf3+0x12a>
 801116a:	2102      	addi      	r1, 3
 801116c:	3401      	movi      	r4, 1
 801116e:	3500      	movi      	r5, 0
 8011170:	6da3      	mov      	r6, r8
 8011172:	6de7      	mov      	r7, r9
 8011174:	6c07      	mov      	r0, r1
 8011176:	6621      	cmplt      	r8, r8
 8011178:	6219      	addc      	r8, r6
 801117a:	625d      	addc      	r9, r7
 801117c:	e9a30004 	bhsz      	r3, 0x8011184	// 8011184 <__muldf3+0x1e8>
 8011180:	6e10      	or      	r8, r4
 8011182:	6e54      	or      	r9, r5
 8011184:	6d8b      	mov      	r6, r2
 8011186:	6dcf      	mov      	r7, r3
 8011188:	6489      	cmplt      	r2, r2
 801118a:	6099      	addc      	r2, r6
 801118c:	60dd      	addc      	r3, r7
 801118e:	6670      	cmphs      	r12, r9
 8011190:	2900      	subi      	r1, 1
 8011192:	0bef      	bt      	0x8011170	// 8011170 <__muldf3+0x1d4>
 8011194:	b813      	st.w      	r0, (r14, 0x4c)
 8011196:	0798      	br      	0x80110c6	// 80110c6 <__muldf3+0x12a>
 8011198:	08014200 	.long	0x08014200

0801119c <__divdf3>:
 801119c:	14d6      	push      	r4-r9, r15
 801119e:	142e      	subi      	r14, r14, 56
 80111a0:	b800      	st.w      	r0, (r14, 0x0)
 80111a2:	b821      	st.w      	r1, (r14, 0x4)
 80111a4:	6c3b      	mov      	r0, r14
 80111a6:	1904      	addi      	r1, r14, 16
 80111a8:	b863      	st.w      	r3, (r14, 0xc)
 80111aa:	b842      	st.w      	r2, (r14, 0x8)
 80111ac:	e0000282 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 80111b0:	1909      	addi      	r1, r14, 36
 80111b2:	1802      	addi      	r0, r14, 8
 80111b4:	e000027e 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 80111b8:	9864      	ld.w      	r3, (r14, 0x10)
 80111ba:	3b01      	cmphsi      	r3, 2
 80111bc:	0c51      	bf      	0x801125e	// 801125e <__divdf3+0xc2>
 80111be:	9829      	ld.w      	r1, (r14, 0x24)
 80111c0:	3201      	movi      	r2, 1
 80111c2:	6448      	cmphs      	r2, r1
 80111c4:	0873      	bt      	0x80112aa	// 80112aa <__divdf3+0x10e>
 80111c6:	9845      	ld.w      	r2, (r14, 0x14)
 80111c8:	980a      	ld.w      	r0, (r14, 0x28)
 80111ca:	3b44      	cmpnei      	r3, 4
 80111cc:	6c81      	xor      	r2, r0
 80111ce:	b845      	st.w      	r2, (r14, 0x14)
 80111d0:	0c4c      	bf      	0x8011268	// 8011268 <__divdf3+0xcc>
 80111d2:	3b42      	cmpnei      	r3, 2
 80111d4:	0c4a      	bf      	0x8011268	// 8011268 <__divdf3+0xcc>
 80111d6:	3944      	cmpnei      	r1, 4
 80111d8:	0c4c      	bf      	0x8011270	// 8011270 <__divdf3+0xd4>
 80111da:	3942      	cmpnei      	r1, 2
 80111dc:	0c63      	bf      	0x80112a2	// 80112a2 <__divdf3+0x106>
 80111de:	9807      	ld.w      	r0, (r14, 0x1c)
 80111e0:	9828      	ld.w      	r1, (r14, 0x20)
 80111e2:	98cc      	ld.w      	r6, (r14, 0x30)
 80111e4:	98ed      	ld.w      	r7, (r14, 0x34)
 80111e6:	9866      	ld.w      	r3, (r14, 0x18)
 80111e8:	984b      	ld.w      	r2, (r14, 0x2c)
 80111ea:	65c4      	cmphs      	r1, r7
 80111ec:	60ca      	subu      	r3, r2
 80111ee:	b866      	st.w      	r3, (r14, 0x18)
 80111f0:	0c05      	bf      	0x80111fa	// 80111fa <__divdf3+0x5e>
 80111f2:	645e      	cmpne      	r7, r1
 80111f4:	080a      	bt      	0x8011208	// 8011208 <__divdf3+0x6c>
 80111f6:	6580      	cmphs      	r0, r6
 80111f8:	0808      	bt      	0x8011208	// 8011208 <__divdf3+0x6c>
 80111fa:	6f03      	mov      	r12, r0
 80111fc:	6f47      	mov      	r13, r1
 80111fe:	2b00      	subi      	r3, 1
 8011200:	6401      	cmplt      	r0, r0
 8011202:	6031      	addc      	r0, r12
 8011204:	6075      	addc      	r1, r13
 8011206:	b866      	st.w      	r3, (r14, 0x18)
 8011208:	ea0c003d 	movi      	r12, 61
 801120c:	3400      	movi      	r4, 0
 801120e:	3500      	movi      	r5, 0
 8011210:	3200      	movi      	r2, 0
 8011212:	ea231000 	movih      	r3, 4096
 8011216:	65c4      	cmphs      	r1, r7
 8011218:	0c0a      	bf      	0x801122c	// 801122c <__divdf3+0x90>
 801121a:	645e      	cmpne      	r7, r1
 801121c:	0803      	bt      	0x8011222	// 8011222 <__divdf3+0x86>
 801121e:	6580      	cmphs      	r0, r6
 8011220:	0c06      	bf      	0x801122c	// 801122c <__divdf3+0x90>
 8011222:	6d08      	or      	r4, r2
 8011224:	6d4c      	or      	r5, r3
 8011226:	6400      	cmphs      	r0, r0
 8011228:	601b      	subc      	r0, r6
 801122a:	605f      	subc      	r1, r7
 801122c:	c7e34829 	lsli      	r9, r3, 31
 8011230:	c4224848 	lsri      	r8, r2, 1
 8011234:	c423484d 	lsri      	r13, r3, 1
 8011238:	c5092422 	or      	r2, r9, r8
 801123c:	e58c1000 	subi      	r12, r12, 1
 8011240:	6e03      	mov      	r8, r0
 8011242:	6e47      	mov      	r9, r1
 8011244:	6cf7      	mov      	r3, r13
 8011246:	6401      	cmplt      	r0, r0
 8011248:	6021      	addc      	r0, r8
 801124a:	6065      	addc      	r1, r9
 801124c:	e92cffe5 	bnez      	r12, 0x8011216	// 8011216 <__divdf3+0x7a>
 8011250:	e46420ff 	andi      	r3, r4, 255
 8011254:	eb430080 	cmpnei      	r3, 128
 8011258:	0c13      	bf      	0x801127e	// 801127e <__divdf3+0xe2>
 801125a:	b887      	st.w      	r4, (r14, 0x1c)
 801125c:	b8a8      	st.w      	r5, (r14, 0x20)
 801125e:	1804      	addi      	r0, r14, 16
 8011260:	e0000160 	bsr      	0x8011520	// 8011520 <__pack_d>
 8011264:	140e      	addi      	r14, r14, 56
 8011266:	1496      	pop      	r4-r9, r15
 8011268:	644e      	cmpne      	r3, r1
 801126a:	0bfa      	bt      	0x801125e	// 801125e <__divdf3+0xc2>
 801126c:	1011      	lrw      	r0, 0x8014200	// 80112b0 <__divdf3+0x114>
 801126e:	07f9      	br      	0x8011260	// 8011260 <__divdf3+0xc4>
 8011270:	3300      	movi      	r3, 0
 8011272:	3400      	movi      	r4, 0
 8011274:	b867      	st.w      	r3, (r14, 0x1c)
 8011276:	b888      	st.w      	r4, (r14, 0x20)
 8011278:	b866      	st.w      	r3, (r14, 0x18)
 801127a:	1804      	addi      	r0, r14, 16
 801127c:	07f2      	br      	0x8011260	// 8011260 <__divdf3+0xc4>
 801127e:	e4642100 	andi      	r3, r4, 256
 8011282:	e923ffec 	bnez      	r3, 0x801125a	// 801125a <__divdf3+0xbe>
 8011286:	6c04      	or      	r0, r1
 8011288:	e900ffe9 	bez      	r0, 0x801125a	// 801125a <__divdf3+0xbe>
 801128c:	3280      	movi      	r2, 128
 801128e:	3300      	movi      	r3, 0
 8011290:	3100      	movi      	r1, 0
 8011292:	6489      	cmplt      	r2, r2
 8011294:	6091      	addc      	r2, r4
 8011296:	60d5      	addc      	r3, r5
 8011298:	29ff      	subi      	r1, 256
 801129a:	c4222024 	and      	r4, r2, r1
 801129e:	6d4f      	mov      	r5, r3
 80112a0:	07dd      	br      	0x801125a	// 801125a <__divdf3+0xbe>
 80112a2:	3304      	movi      	r3, 4
 80112a4:	b864      	st.w      	r3, (r14, 0x10)
 80112a6:	1804      	addi      	r0, r14, 16
 80112a8:	07dc      	br      	0x8011260	// 8011260 <__divdf3+0xc4>
 80112aa:	1809      	addi      	r0, r14, 36
 80112ac:	07da      	br      	0x8011260	// 8011260 <__divdf3+0xc4>
 80112ae:	0000      	.short	0x0000
 80112b0:	08014200 	.long	0x08014200

080112b4 <__nedf2>:
 80112b4:	14d2      	push      	r4-r5, r15
 80112b6:	142e      	subi      	r14, r14, 56
 80112b8:	b800      	st.w      	r0, (r14, 0x0)
 80112ba:	b821      	st.w      	r1, (r14, 0x4)
 80112bc:	6c3b      	mov      	r0, r14
 80112be:	6d47      	mov      	r5, r1
 80112c0:	1904      	addi      	r1, r14, 16
 80112c2:	b863      	st.w      	r3, (r14, 0xc)
 80112c4:	b842      	st.w      	r2, (r14, 0x8)
 80112c6:	e00001f5 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 80112ca:	1802      	addi      	r0, r14, 8
 80112cc:	1909      	addi      	r1, r14, 36
 80112ce:	e00001f1 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 80112d2:	9864      	ld.w      	r3, (r14, 0x10)
 80112d4:	3001      	movi      	r0, 1
 80112d6:	64c0      	cmphs      	r0, r3
 80112d8:	0808      	bt      	0x80112e8	// 80112e8 <__nedf2+0x34>
 80112da:	9869      	ld.w      	r3, (r14, 0x24)
 80112dc:	64c0      	cmphs      	r0, r3
 80112de:	0805      	bt      	0x80112e8	// 80112e8 <__nedf2+0x34>
 80112e0:	1909      	addi      	r1, r14, 36
 80112e2:	1804      	addi      	r0, r14, 16
 80112e4:	e0000258 	bsr      	0x8011794	// 8011794 <__fpcmp_parts_d>
 80112e8:	140e      	addi      	r14, r14, 56
 80112ea:	1492      	pop      	r4-r5, r15

080112ec <__gtdf2>:
 80112ec:	14d2      	push      	r4-r5, r15
 80112ee:	142e      	subi      	r14, r14, 56
 80112f0:	b800      	st.w      	r0, (r14, 0x0)
 80112f2:	b821      	st.w      	r1, (r14, 0x4)
 80112f4:	6c3b      	mov      	r0, r14
 80112f6:	6d47      	mov      	r5, r1
 80112f8:	1904      	addi      	r1, r14, 16
 80112fa:	b842      	st.w      	r2, (r14, 0x8)
 80112fc:	b863      	st.w      	r3, (r14, 0xc)
 80112fe:	e00001d9 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 8011302:	1909      	addi      	r1, r14, 36
 8011304:	1802      	addi      	r0, r14, 8
 8011306:	e00001d5 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 801130a:	9844      	ld.w      	r2, (r14, 0x10)
 801130c:	3301      	movi      	r3, 1
 801130e:	648c      	cmphs      	r3, r2
 8011310:	080a      	bt      	0x8011324	// 8011324 <__gtdf2+0x38>
 8011312:	9849      	ld.w      	r2, (r14, 0x24)
 8011314:	648c      	cmphs      	r3, r2
 8011316:	0807      	bt      	0x8011324	// 8011324 <__gtdf2+0x38>
 8011318:	1909      	addi      	r1, r14, 36
 801131a:	1804      	addi      	r0, r14, 16
 801131c:	e000023c 	bsr      	0x8011794	// 8011794 <__fpcmp_parts_d>
 8011320:	140e      	addi      	r14, r14, 56
 8011322:	1492      	pop      	r4-r5, r15
 8011324:	3000      	movi      	r0, 0
 8011326:	2800      	subi      	r0, 1
 8011328:	140e      	addi      	r14, r14, 56
 801132a:	1492      	pop      	r4-r5, r15

0801132c <__gedf2>:
 801132c:	14d2      	push      	r4-r5, r15
 801132e:	142e      	subi      	r14, r14, 56
 8011330:	b800      	st.w      	r0, (r14, 0x0)
 8011332:	b821      	st.w      	r1, (r14, 0x4)
 8011334:	6c3b      	mov      	r0, r14
 8011336:	6d47      	mov      	r5, r1
 8011338:	1904      	addi      	r1, r14, 16
 801133a:	b842      	st.w      	r2, (r14, 0x8)
 801133c:	b863      	st.w      	r3, (r14, 0xc)
 801133e:	e00001b9 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 8011342:	1909      	addi      	r1, r14, 36
 8011344:	1802      	addi      	r0, r14, 8
 8011346:	e00001b5 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 801134a:	9844      	ld.w      	r2, (r14, 0x10)
 801134c:	3301      	movi      	r3, 1
 801134e:	648c      	cmphs      	r3, r2
 8011350:	080a      	bt      	0x8011364	// 8011364 <__gedf2+0x38>
 8011352:	9849      	ld.w      	r2, (r14, 0x24)
 8011354:	648c      	cmphs      	r3, r2
 8011356:	0807      	bt      	0x8011364	// 8011364 <__gedf2+0x38>
 8011358:	1909      	addi      	r1, r14, 36
 801135a:	1804      	addi      	r0, r14, 16
 801135c:	e000021c 	bsr      	0x8011794	// 8011794 <__fpcmp_parts_d>
 8011360:	140e      	addi      	r14, r14, 56
 8011362:	1492      	pop      	r4-r5, r15
 8011364:	3000      	movi      	r0, 0
 8011366:	2800      	subi      	r0, 1
 8011368:	140e      	addi      	r14, r14, 56
 801136a:	1492      	pop      	r4-r5, r15

0801136c <__ltdf2>:
 801136c:	14d2      	push      	r4-r5, r15
 801136e:	142e      	subi      	r14, r14, 56
 8011370:	b800      	st.w      	r0, (r14, 0x0)
 8011372:	b821      	st.w      	r1, (r14, 0x4)
 8011374:	6c3b      	mov      	r0, r14
 8011376:	6d47      	mov      	r5, r1
 8011378:	1904      	addi      	r1, r14, 16
 801137a:	b863      	st.w      	r3, (r14, 0xc)
 801137c:	b842      	st.w      	r2, (r14, 0x8)
 801137e:	e0000199 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 8011382:	1802      	addi      	r0, r14, 8
 8011384:	1909      	addi      	r1, r14, 36
 8011386:	e0000195 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 801138a:	9864      	ld.w      	r3, (r14, 0x10)
 801138c:	3001      	movi      	r0, 1
 801138e:	64c0      	cmphs      	r0, r3
 8011390:	0808      	bt      	0x80113a0	// 80113a0 <__ltdf2+0x34>
 8011392:	9869      	ld.w      	r3, (r14, 0x24)
 8011394:	64c0      	cmphs      	r0, r3
 8011396:	0805      	bt      	0x80113a0	// 80113a0 <__ltdf2+0x34>
 8011398:	1909      	addi      	r1, r14, 36
 801139a:	1804      	addi      	r0, r14, 16
 801139c:	e00001fc 	bsr      	0x8011794	// 8011794 <__fpcmp_parts_d>
 80113a0:	140e      	addi      	r14, r14, 56
 80113a2:	1492      	pop      	r4-r5, r15

080113a4 <__floatsidf>:
 80113a4:	14d0      	push      	r15
 80113a6:	1425      	subi      	r14, r14, 20
 80113a8:	3303      	movi      	r3, 3
 80113aa:	b860      	st.w      	r3, (r14, 0x0)
 80113ac:	487f      	lsri      	r3, r0, 31
 80113ae:	b861      	st.w      	r3, (r14, 0x4)
 80113b0:	e9200009 	bnez      	r0, 0x80113c2	// 80113c2 <__floatsidf+0x1e>
 80113b4:	3302      	movi      	r3, 2
 80113b6:	b860      	st.w      	r3, (r14, 0x0)
 80113b8:	6c3b      	mov      	r0, r14
 80113ba:	e00000b3 	bsr      	0x8011520	// 8011520 <__pack_d>
 80113be:	1405      	addi      	r14, r14, 20
 80113c0:	1490      	pop      	r15
 80113c2:	e9a00008 	bhsz      	r0, 0x80113d2	// 80113d2 <__floatsidf+0x2e>
 80113c6:	ea238000 	movih      	r3, 32768
 80113ca:	64c2      	cmpne      	r0, r3
 80113cc:	0c1c      	bf      	0x8011404	// 8011404 <__floatsidf+0x60>
 80113ce:	3300      	movi      	r3, 0
 80113d0:	5b01      	subu      	r0, r3, r0
 80113d2:	c4007c42 	ff1      	r2, r0
 80113d6:	e422001c 	addi      	r1, r2, 29
 80113da:	ea0c001f 	movi      	r12, 31
 80113de:	2a02      	subi      	r2, 3
 80113e0:	4861      	lsri      	r3, r0, 1
 80113e2:	6306      	subu      	r12, r1
 80113e4:	c440402d 	lsl      	r13, r0, r2
 80113e8:	3adf      	btsti      	r2, 31
 80113ea:	70f1      	lsr      	r3, r12
 80113ec:	c46d0c20 	incf      	r3, r13, 0
 80113f0:	7004      	lsl      	r0, r1
 80113f2:	b864      	st.w      	r3, (r14, 0x10)
 80113f4:	3300      	movi      	r3, 0
 80113f6:	c4030c20 	incf      	r0, r3, 0
 80113fa:	333c      	movi      	r3, 60
 80113fc:	60c6      	subu      	r3, r1
 80113fe:	b803      	st.w      	r0, (r14, 0xc)
 8011400:	b862      	st.w      	r3, (r14, 0x8)
 8011402:	07db      	br      	0x80113b8	// 80113b8 <__floatsidf+0x14>
 8011404:	3000      	movi      	r0, 0
 8011406:	ea21c1e0 	movih      	r1, 49632
 801140a:	07da      	br      	0x80113be	// 80113be <__floatsidf+0x1a>

0801140c <__fixdfsi>:
 801140c:	14d0      	push      	r15
 801140e:	1427      	subi      	r14, r14, 28
 8011410:	b800      	st.w      	r0, (r14, 0x0)
 8011412:	b821      	st.w      	r1, (r14, 0x4)
 8011414:	6c3b      	mov      	r0, r14
 8011416:	1902      	addi      	r1, r14, 8
 8011418:	e000014c 	bsr      	0x80116b0	// 80116b0 <__unpack_d>
 801141c:	9862      	ld.w      	r3, (r14, 0x8)
 801141e:	3202      	movi      	r2, 2
 8011420:	64c8      	cmphs      	r2, r3
 8011422:	082a      	bt      	0x8011476	// 8011476 <__fixdfsi+0x6a>
 8011424:	3b44      	cmpnei      	r3, 4
 8011426:	0c06      	bf      	0x8011432	// 8011432 <__fixdfsi+0x26>
 8011428:	9804      	ld.w      	r0, (r14, 0x10)
 801142a:	e9800026 	blz      	r0, 0x8011476	// 8011476 <__fixdfsi+0x6a>
 801142e:	383e      	cmplti      	r0, 31
 8011430:	080a      	bt      	0x8011444	// 8011444 <__fixdfsi+0x38>
 8011432:	9863      	ld.w      	r3, (r14, 0xc)
 8011434:	3b40      	cmpnei      	r3, 0
 8011436:	c4000500 	mvc      	r0
 801143a:	c7c05023 	bmaski      	r3, 31
 801143e:	600c      	addu      	r0, r3
 8011440:	1407      	addi      	r14, r14, 28
 8011442:	1490      	pop      	r15
 8011444:	323c      	movi      	r2, 60
 8011446:	5a21      	subu      	r1, r2, r0
 8011448:	e581101f 	subi      	r12, r1, 32
 801144c:	9866      	ld.w      	r3, (r14, 0x18)
 801144e:	321f      	movi      	r2, 31
 8011450:	c5834040 	lsr      	r0, r3, r12
 8011454:	6086      	subu      	r2, r1
 8011456:	4361      	lsli      	r3, r3, 1
 8011458:	70c8      	lsl      	r3, r2
 801145a:	9845      	ld.w      	r2, (r14, 0x14)
 801145c:	7085      	lsr      	r2, r1
 801145e:	6c8c      	or      	r2, r3
 8011460:	9863      	ld.w      	r3, (r14, 0xc)
 8011462:	c7ec2880 	btsti      	r12, 31
 8011466:	c4020c40 	inct      	r0, r2, 0
 801146a:	e903ffeb 	bez      	r3, 0x8011440	// 8011440 <__fixdfsi+0x34>
 801146e:	3300      	movi      	r3, 0
 8011470:	5b01      	subu      	r0, r3, r0
 8011472:	1407      	addi      	r14, r14, 28
 8011474:	1490      	pop      	r15
 8011476:	3000      	movi      	r0, 0
 8011478:	1407      	addi      	r14, r14, 28
 801147a:	1490      	pop      	r15

0801147c <__floatunsidf>:
 801147c:	14d1      	push      	r4, r15
 801147e:	1425      	subi      	r14, r14, 20
 8011480:	3100      	movi      	r1, 0
 8011482:	b821      	st.w      	r1, (r14, 0x4)
 8011484:	e9000020 	bez      	r0, 0x80114c4	// 80114c4 <__floatunsidf+0x48>
 8011488:	c4007c42 	ff1      	r2, r0
 801148c:	e582001c 	addi      	r12, r2, 29
 8011490:	3303      	movi      	r3, 3
 8011492:	ea0d001f 	movi      	r13, 31
 8011496:	2a02      	subi      	r2, 3
 8011498:	b860      	st.w      	r3, (r14, 0x0)
 801149a:	6372      	subu      	r13, r12
 801149c:	4861      	lsri      	r3, r0, 1
 801149e:	c4404024 	lsl      	r4, r0, r2
 80114a2:	3adf      	btsti      	r2, 31
 80114a4:	70f5      	lsr      	r3, r13
 80114a6:	c4640c20 	incf      	r3, r4, 0
 80114aa:	7030      	lsl      	r0, r12
 80114ac:	c4010c20 	incf      	r0, r1, 0
 80114b0:	b864      	st.w      	r3, (r14, 0x10)
 80114b2:	333c      	movi      	r3, 60
 80114b4:	b803      	st.w      	r0, (r14, 0xc)
 80114b6:	60f2      	subu      	r3, r12
 80114b8:	6c3b      	mov      	r0, r14
 80114ba:	b862      	st.w      	r3, (r14, 0x8)
 80114bc:	e0000032 	bsr      	0x8011520	// 8011520 <__pack_d>
 80114c0:	1405      	addi      	r14, r14, 20
 80114c2:	1491      	pop      	r4, r15
 80114c4:	3302      	movi      	r3, 2
 80114c6:	6c3b      	mov      	r0, r14
 80114c8:	b860      	st.w      	r3, (r14, 0x0)
 80114ca:	e000002b 	bsr      	0x8011520	// 8011520 <__pack_d>
 80114ce:	1405      	addi      	r14, r14, 20
 80114d0:	1491      	pop      	r4, r15
	...

080114d4 <__muldi3>:
 80114d4:	14c3      	push      	r4-r6
 80114d6:	c602484d 	lsri      	r13, r2, 16
 80114da:	c40055ec 	zext      	r12, r0, 15, 0
 80114de:	4890      	lsri      	r4, r0, 16
 80114e0:	c40255e5 	zext      	r5, r2, 15, 0
 80114e4:	c4ac8426 	mult      	r6, r12, r5
 80114e8:	7d50      	mult      	r5, r4
 80114ea:	7f34      	mult      	r12, r13
 80114ec:	7d34      	mult      	r4, r13
 80114ee:	c4ac002d 	addu      	r13, r12, r5
 80114f2:	c606484c 	lsri      	r12, r6, 16
 80114f6:	6334      	addu      	r12, r13
 80114f8:	6570      	cmphs      	r12, r5
 80114fa:	0804      	bt      	0x8011502	// 8011502 <__muldi3+0x2e>
 80114fc:	ea2d0001 	movih      	r13, 1
 8011500:	6134      	addu      	r4, r13
 8011502:	c60c484d 	lsri      	r13, r12, 16
 8011506:	7cc0      	mult      	r3, r0
 8011508:	7c48      	mult      	r1, r2
 801150a:	6134      	addu      	r4, r13
 801150c:	c60c482c 	lsli      	r12, r12, 16
 8011510:	c40655e6 	zext      	r6, r6, 15, 0
 8011514:	604c      	addu      	r1, r3
 8011516:	c4cc0020 	addu      	r0, r12, r6
 801151a:	6050      	addu      	r1, r4
 801151c:	1483      	pop      	r4-r6
	...

08011520 <__pack_d>:
 8011520:	14c5      	push      	r4-r8
 8011522:	9020      	ld.w      	r1, (r0, 0x0)
 8011524:	3901      	cmphsi      	r1, 2
 8011526:	9043      	ld.w      	r2, (r0, 0xc)
 8011528:	9064      	ld.w      	r3, (r0, 0x10)
 801152a:	d9a02001 	ld.w      	r13, (r0, 0x4)
 801152e:	0c47      	bf      	0x80115bc	// 80115bc <__pack_d+0x9c>
 8011530:	3944      	cmpnei      	r1, 4
 8011532:	0c40      	bf      	0x80115b2	// 80115b2 <__pack_d+0x92>
 8011534:	3942      	cmpnei      	r1, 2
 8011536:	0c28      	bf      	0x8011586	// 8011586 <__pack_d+0x66>
 8011538:	c4622421 	or      	r1, r2, r3
 801153c:	e9010025 	bez      	r1, 0x8011586	// 8011586 <__pack_d+0x66>
 8011540:	9022      	ld.w      	r1, (r0, 0x8)
 8011542:	ea0003fd 	movi      	r0, 1021
 8011546:	6c02      	nor      	r0, r0
 8011548:	6405      	cmplt      	r1, r0
 801154a:	0855      	bt      	0x80115f4	// 80115f4 <__pack_d+0xd4>
 801154c:	eb2103ff 	cmplti      	r1, 1024
 8011550:	0c31      	bf      	0x80115b2	// 80115b2 <__pack_d+0x92>
 8011552:	e40220ff 	andi      	r0, r2, 255
 8011556:	eb400080 	cmpnei      	r0, 128
 801155a:	0c43      	bf      	0x80115e0	// 80115e0 <__pack_d+0xc0>
 801155c:	347f      	movi      	r4, 127
 801155e:	3500      	movi      	r5, 0
 8011560:	6489      	cmplt      	r2, r2
 8011562:	6091      	addc      	r2, r4
 8011564:	60d5      	addc      	r3, r5
 8011566:	c7805020 	bmaski      	r0, 29
 801156a:	64c0      	cmphs      	r0, r3
 801156c:	0c19      	bf      	0x801159e	// 801159e <__pack_d+0x7e>
 801156e:	e58103fe 	addi      	r12, r1, 1023
 8011572:	4b28      	lsri      	r1, r3, 8
 8011574:	4398      	lsli      	r4, r3, 24
 8011576:	4a08      	lsri      	r0, r2, 8
 8011578:	c4015663 	zext      	r3, r1, 19, 0
 801157c:	6c4f      	mov      	r1, r3
 801157e:	6c10      	or      	r0, r4
 8011580:	e46c27ff 	andi      	r3, r12, 2047
 8011584:	0404      	br      	0x801158c	// 801158c <__pack_d+0x6c>
 8011586:	3300      	movi      	r3, 0
 8011588:	3000      	movi      	r0, 0
 801158a:	3100      	movi      	r1, 0
 801158c:	3200      	movi      	r2, 0
 801158e:	c4415e60 	ins      	r2, r1, 19, 0
 8011592:	c4435d54 	ins      	r2, r3, 30, 20
 8011596:	c44d5c1f 	ins      	r2, r13, 31, 31
 801159a:	6c4b      	mov      	r1, r2
 801159c:	1485      	pop      	r4-r8
 801159e:	439f      	lsli      	r4, r3, 31
 80115a0:	c422484c 	lsri      	r12, r2, 1
 80115a4:	4b01      	lsri      	r0, r3, 1
 80115a6:	c5842422 	or      	r2, r4, r12
 80115aa:	6cc3      	mov      	r3, r0
 80115ac:	e58103ff 	addi      	r12, r1, 1024
 80115b0:	07e1      	br      	0x8011572	// 8011572 <__pack_d+0x52>
 80115b2:	ea0307ff 	movi      	r3, 2047
 80115b6:	3000      	movi      	r0, 0
 80115b8:	3100      	movi      	r1, 0
 80115ba:	07e9      	br      	0x801158c	// 801158c <__pack_d+0x6c>
 80115bc:	c703482c 	lsli      	r12, r3, 24
 80115c0:	4a48      	lsri      	r2, r2, 8
 80115c2:	c44c2420 	or      	r0, r12, r2
 80115c6:	c5035741 	zext      	r1, r3, 26, 8
 80115ca:	3200      	movi      	r2, 0
 80115cc:	ea230008 	movih      	r3, 8
 80115d0:	6c08      	or      	r0, r2
 80115d2:	6c4c      	or      	r1, r3
 80115d4:	c4015663 	zext      	r3, r1, 19, 0
 80115d8:	6c4f      	mov      	r1, r3
 80115da:	ea0307ff 	movi      	r3, 2047
 80115de:	07d7      	br      	0x801158c	// 801158c <__pack_d+0x6c>
 80115e0:	e4022100 	andi      	r0, r2, 256
 80115e4:	e900ffc1 	bez      	r0, 0x8011566	// 8011566 <__pack_d+0x46>
 80115e8:	3480      	movi      	r4, 128
 80115ea:	3500      	movi      	r5, 0
 80115ec:	6489      	cmplt      	r2, r2
 80115ee:	6091      	addc      	r2, r4
 80115f0:	60d5      	addc      	r3, r5
 80115f2:	07ba      	br      	0x8011566	// 8011566 <__pack_d+0x46>
 80115f4:	5825      	subu      	r1, r0, r1
 80115f6:	eb210038 	cmplti      	r1, 57
 80115fa:	0fc6      	bf      	0x8011586	// 8011586 <__pack_d+0x66>
 80115fc:	341f      	movi      	r4, 31
 80115fe:	c423482c 	lsli      	r12, r3, 1
 8011602:	6106      	subu      	r4, r1
 8011604:	e401101f 	subi      	r0, r1, 32
 8011608:	7310      	lsl      	r12, r4
 801160a:	c4224046 	lsr      	r6, r2, r1
 801160e:	38df      	btsti      	r0, 31
 8011610:	c4034045 	lsr      	r5, r3, r0
 8011614:	ea080000 	movi      	r8, 0
 8011618:	6db0      	or      	r6, r12
 801161a:	ea0c0001 	movi      	r12, 1
 801161e:	c4c50c20 	incf      	r6, r5, 0
 8011622:	c40c4020 	lsl      	r0, r12, r0
 8011626:	6d63      	mov      	r5, r8
 8011628:	c42c4024 	lsl      	r4, r12, r1
 801162c:	c4234047 	lsr      	r7, r3, r1
 8011630:	c4a00c20 	incf      	r5, r0, 0
 8011634:	c4880c20 	incf      	r4, r8, 0
 8011638:	c4e80c20 	incf      	r7, r8, 0
 801163c:	3c40      	cmpnei      	r4, 0
 801163e:	c4a50c81 	decf      	r5, r5, 1
 8011642:	2c00      	subi      	r4, 1
 8011644:	6890      	and      	r2, r4
 8011646:	68d4      	and      	r3, r5
 8011648:	6c8c      	or      	r2, r3
 801164a:	3a40      	cmpnei      	r2, 0
 801164c:	c4000502 	mvc      	r2
 8011650:	6ce3      	mov      	r3, r8
 8011652:	6d88      	or      	r6, r2
 8011654:	6dcc      	or      	r7, r3
 8011656:	e46620ff 	andi      	r3, r6, 255
 801165a:	eb430080 	cmpnei      	r3, 128
 801165e:	0814      	bt      	0x8011686	// 8011686 <__pack_d+0x166>
 8011660:	e4662100 	andi      	r3, r6, 256
 8011664:	e9230023 	bnez      	r3, 0x80116aa	// 80116aa <__pack_d+0x18a>
 8011668:	4758      	lsli      	r2, r7, 24
 801166a:	4f28      	lsri      	r1, r7, 8
 801166c:	4e08      	lsri      	r0, r6, 8
 801166e:	6c08      	or      	r0, r2
 8011670:	c4015662 	zext      	r2, r1, 19, 0
 8011674:	6c4b      	mov      	r1, r2
 8011676:	c7605022 	bmaski      	r2, 28
 801167a:	65c8      	cmphs      	r2, r7
 801167c:	0c02      	bf      	0x8011680	// 8011680 <__pack_d+0x160>
 801167e:	6f0f      	mov      	r12, r3
 8011680:	e46c2001 	andi      	r3, r12, 1
 8011684:	0784      	br      	0x801158c	// 801158c <__pack_d+0x6c>
 8011686:	327f      	movi      	r2, 127
 8011688:	3300      	movi      	r3, 0
 801168a:	6599      	cmplt      	r6, r6
 801168c:	6189      	addc      	r6, r2
 801168e:	61cd      	addc      	r7, r3
 8011690:	4778      	lsli      	r3, r7, 24
 8011692:	4f28      	lsri      	r1, r7, 8
 8011694:	4e08      	lsri      	r0, r6, 8
 8011696:	6c0c      	or      	r0, r3
 8011698:	c4015663 	zext      	r3, r1, 19, 0
 801169c:	6c4f      	mov      	r1, r3
 801169e:	c7605023 	bmaski      	r3, 28
 80116a2:	65cc      	cmphs      	r3, r7
 80116a4:	0fee      	bf      	0x8011680	// 8011680 <__pack_d+0x160>
 80116a6:	6f23      	mov      	r12, r8
 80116a8:	07ec      	br      	0x8011680	// 8011680 <__pack_d+0x160>
 80116aa:	3280      	movi      	r2, 128
 80116ac:	07ee      	br      	0x8011688	// 8011688 <__pack_d+0x168>
	...

080116b0 <__unpack_d>:
 80116b0:	1421      	subi      	r14, r14, 4
 80116b2:	dd6e2000 	st.w      	r11, (r14, 0x0)
 80116b6:	8863      	ld.h      	r3, (r0, 0x6)
 80116b8:	8047      	ld.b      	r2, (r0, 0x7)
 80116ba:	c48355c3 	zext      	r3, r3, 14, 4
 80116be:	d9802001 	ld.w      	r12, (r0, 0x4)
 80116c2:	4a47      	lsri      	r2, r2, 7
 80116c4:	d9a02000 	ld.w      	r13, (r0, 0x0)
 80116c8:	c40c566c 	zext      	r12, r12, 19, 0
 80116cc:	b141      	st.w      	r2, (r1, 0x4)
 80116ce:	e9230025 	bnez      	r3, 0x8011718	// 8011718 <__unpack_d+0x68>
 80116d2:	c58d2423 	or      	r3, r13, r12
 80116d6:	e903003c 	bez      	r3, 0x801174e	// 801174e <__unpack_d+0x9e>
 80116da:	c70d4840 	lsri      	r0, r13, 24
 80116de:	c50c4823 	lsli      	r3, r12, 8
 80116e2:	6cc0      	or      	r3, r0
 80116e4:	3003      	movi      	r0, 3
 80116e6:	c50d4822 	lsli      	r2, r13, 8
 80116ea:	b100      	st.w      	r0, (r1, 0x0)
 80116ec:	c760502d 	bmaski      	r13, 28
 80116f0:	ea0003fe 	movi      	r0, 1022
 80116f4:	6c02      	nor      	r0, r0
 80116f6:	6ecb      	mov      	r11, r2
 80116f8:	6f0f      	mov      	r12, r3
 80116fa:	6489      	cmplt      	r2, r2
 80116fc:	60ad      	addc      	r2, r11
 80116fe:	60f1      	addc      	r3, r12
 8011700:	64f4      	cmphs      	r13, r3
 8011702:	6f03      	mov      	r12, r0
 8011704:	2800      	subi      	r0, 1
 8011706:	0bf8      	bt      	0x80116f6	// 80116f6 <__unpack_d+0x46>
 8011708:	dd812002 	st.w      	r12, (r1, 0x8)
 801170c:	b143      	st.w      	r2, (r1, 0xc)
 801170e:	b164      	st.w      	r3, (r1, 0x10)
 8011710:	d96e2000 	ld.w      	r11, (r14, 0x0)
 8011714:	1401      	addi      	r14, r14, 4
 8011716:	783c      	jmp      	r15
 8011718:	eb4307ff 	cmpnei      	r3, 2047
 801171c:	0c1f      	bf      	0x801175a	// 801175a <__unpack_d+0xaa>
 801171e:	e46313fe 	subi      	r3, r3, 1023
 8011722:	b162      	st.w      	r3, (r1, 0x8)
 8011724:	3303      	movi      	r3, 3
 8011726:	c70d4840 	lsri      	r0, r13, 24
 801172a:	b160      	st.w      	r3, (r1, 0x0)
 801172c:	c50c4823 	lsli      	r3, r12, 8
 8011730:	c50d4822 	lsli      	r2, r13, 8
 8011734:	6cc0      	or      	r3, r0
 8011736:	ea0c0000 	movi      	r12, 0
 801173a:	ea2d1000 	movih      	r13, 4096
 801173e:	6cb0      	or      	r2, r12
 8011740:	6cf4      	or      	r3, r13
 8011742:	b143      	st.w      	r2, (r1, 0xc)
 8011744:	b164      	st.w      	r3, (r1, 0x10)
 8011746:	d96e2000 	ld.w      	r11, (r14, 0x0)
 801174a:	1401      	addi      	r14, r14, 4
 801174c:	783c      	jmp      	r15
 801174e:	3302      	movi      	r3, 2
 8011750:	b160      	st.w      	r3, (r1, 0x0)
 8011752:	d96e2000 	ld.w      	r11, (r14, 0x0)
 8011756:	1401      	addi      	r14, r14, 4
 8011758:	783c      	jmp      	r15
 801175a:	c58d2423 	or      	r3, r13, r12
 801175e:	e9030018 	bez      	r3, 0x801178e	// 801178e <__unpack_d+0xde>
 8011762:	ea230008 	movih      	r3, 8
 8011766:	68f0      	and      	r3, r12
 8011768:	3b40      	cmpnei      	r3, 0
 801176a:	3201      	movi      	r2, 1
 801176c:	c4620c40 	inct      	r3, r2, 0
 8011770:	b160      	st.w      	r3, (r1, 0x0)
 8011772:	c50c482c 	lsli      	r12, r12, 8
 8011776:	c70d4843 	lsri      	r3, r13, 24
 801177a:	6f0c      	or      	r12, r3
 801177c:	c50d482d 	lsli      	r13, r13, 8
 8011780:	c76c282c 	bclri      	r12, r12, 27
 8011784:	dda12003 	st.w      	r13, (r1, 0xc)
 8011788:	dd812004 	st.w      	r12, (r1, 0x10)
 801178c:	07dd      	br      	0x8011746	// 8011746 <__unpack_d+0x96>
 801178e:	3304      	movi      	r3, 4
 8011790:	b160      	st.w      	r3, (r1, 0x0)
 8011792:	07da      	br      	0x8011746	// 8011746 <__unpack_d+0x96>

08011794 <__fpcmp_parts_d>:
 8011794:	9040      	ld.w      	r2, (r0, 0x0)
 8011796:	3301      	movi      	r3, 1
 8011798:	648c      	cmphs      	r3, r2
 801179a:	0830      	bt      	0x80117fa	// 80117fa <__fpcmp_parts_d+0x66>
 801179c:	d9812000 	ld.w      	r12, (r1, 0x0)
 80117a0:	670c      	cmphs      	r3, r12
 80117a2:	082c      	bt      	0x80117fa	// 80117fa <__fpcmp_parts_d+0x66>
 80117a4:	3a44      	cmpnei      	r2, 4
 80117a6:	0c1f      	bf      	0x80117e4	// 80117e4 <__fpcmp_parts_d+0x50>
 80117a8:	eb4c0004 	cmpnei      	r12, 4
 80117ac:	0c14      	bf      	0x80117d4	// 80117d4 <__fpcmp_parts_d+0x40>
 80117ae:	3a42      	cmpnei      	r2, 2
 80117b0:	0c0f      	bf      	0x80117ce	// 80117ce <__fpcmp_parts_d+0x3a>
 80117b2:	eb4c0002 	cmpnei      	r12, 2
 80117b6:	0c1a      	bf      	0x80117ea	// 80117ea <__fpcmp_parts_d+0x56>
 80117b8:	9041      	ld.w      	r2, (r0, 0x4)
 80117ba:	d9812001 	ld.w      	r12, (r1, 0x4)
 80117be:	670a      	cmpne      	r2, r12
 80117c0:	0c1f      	bf      	0x80117fe	// 80117fe <__fpcmp_parts_d+0x6a>
 80117c2:	3000      	movi      	r0, 0
 80117c4:	2800      	subi      	r0, 1
 80117c6:	3a40      	cmpnei      	r2, 0
 80117c8:	c4030c20 	incf      	r0, r3, 0
 80117cc:	783c      	jmp      	r15
 80117ce:	eb4c0002 	cmpnei      	r12, 2
 80117d2:	0c2a      	bf      	0x8011826	// 8011826 <__fpcmp_parts_d+0x92>
 80117d4:	9141      	ld.w      	r2, (r1, 0x4)
 80117d6:	3300      	movi      	r3, 0
 80117d8:	2b00      	subi      	r3, 1
 80117da:	3a40      	cmpnei      	r2, 0
 80117dc:	3001      	movi      	r0, 1
 80117de:	c4030c20 	incf      	r0, r3, 0
 80117e2:	783c      	jmp      	r15
 80117e4:	eb4c0004 	cmpnei      	r12, 4
 80117e8:	0c21      	bf      	0x801182a	// 801182a <__fpcmp_parts_d+0x96>
 80117ea:	9061      	ld.w      	r3, (r0, 0x4)
 80117ec:	3000      	movi      	r0, 0
 80117ee:	3b40      	cmpnei      	r3, 0
 80117f0:	2800      	subi      	r0, 1
 80117f2:	3301      	movi      	r3, 1
 80117f4:	c4030c20 	incf      	r0, r3, 0
 80117f8:	783c      	jmp      	r15
 80117fa:	6c0f      	mov      	r0, r3
 80117fc:	783c      	jmp      	r15
 80117fe:	d9a02002 	ld.w      	r13, (r0, 0x8)
 8011802:	d9812002 	ld.w      	r12, (r1, 0x8)
 8011806:	6771      	cmplt      	r12, r13
 8011808:	0bdd      	bt      	0x80117c2	// 80117c2 <__fpcmp_parts_d+0x2e>
 801180a:	6735      	cmplt      	r13, r12
 801180c:	0c13      	bf      	0x8011832	// 8011832 <__fpcmp_parts_d+0x9e>
 801180e:	3000      	movi      	r0, 0
 8011810:	2800      	subi      	r0, 1
 8011812:	3a40      	cmpnei      	r2, 0
 8011814:	c4030c40 	inct      	r0, r3, 0
 8011818:	07da      	br      	0x80117cc	// 80117cc <__fpcmp_parts_d+0x38>
 801181a:	644c      	cmphs      	r3, r1
 801181c:	0fdd      	bf      	0x80117d6	// 80117d6 <__fpcmp_parts_d+0x42>
 801181e:	64c6      	cmpne      	r1, r3
 8011820:	0803      	bt      	0x8011826	// 8011826 <__fpcmp_parts_d+0x92>
 8011822:	6430      	cmphs      	r12, r0
 8011824:	0fd9      	bf      	0x80117d6	// 80117d6 <__fpcmp_parts_d+0x42>
 8011826:	3000      	movi      	r0, 0
 8011828:	07d2      	br      	0x80117cc	// 80117cc <__fpcmp_parts_d+0x38>
 801182a:	9161      	ld.w      	r3, (r1, 0x4)
 801182c:	9001      	ld.w      	r0, (r0, 0x4)
 801182e:	5b01      	subu      	r0, r3, r0
 8011830:	07ce      	br      	0x80117cc	// 80117cc <__fpcmp_parts_d+0x38>
 8011832:	9064      	ld.w      	r3, (r0, 0x10)
 8011834:	d9802003 	ld.w      	r12, (r0, 0xc)
 8011838:	9103      	ld.w      	r0, (r1, 0xc)
 801183a:	9124      	ld.w      	r1, (r1, 0x10)
 801183c:	64c4      	cmphs      	r1, r3
 801183e:	0c05      	bf      	0x8011848	// 8011848 <__fpcmp_parts_d+0xb4>
 8011840:	644e      	cmpne      	r3, r1
 8011842:	0bec      	bt      	0x801181a	// 801181a <__fpcmp_parts_d+0x86>
 8011844:	6700      	cmphs      	r0, r12
 8011846:	0bea      	bt      	0x801181a	// 801181a <__fpcmp_parts_d+0x86>
 8011848:	3000      	movi      	r0, 0
 801184a:	2800      	subi      	r0, 1
 801184c:	3a40      	cmpnei      	r2, 0
 801184e:	3301      	movi      	r3, 1
 8011850:	c4030c20 	incf      	r0, r3, 0
 8011854:	07bc      	br      	0x80117cc	// 80117cc <__fpcmp_parts_d+0x38>
	...

08011858 <__GI_putchar>:
 8011858:	14d0      	push      	r15
 801185a:	1063      	lrw      	r3, 0x20000120	// 8011864 <__GI_putchar+0xc>
 801185c:	9320      	ld.w      	r1, (r3, 0x0)
 801185e:	e000003f 	bsr      	0x80118dc	// 80118dc <__GI_putc>
 8011862:	1490      	pop      	r15
 8011864:	20000120 	.long	0x20000120

08011868 <__GI_puts>:
 8011868:	14d1      	push      	r4, r15
 801186a:	1085      	lrw      	r4, 0x20000120	// 801187c <__GI_puts+0x14>
 801186c:	9420      	ld.w      	r1, (r4, 0x0)
 801186e:	e0000009 	bsr      	0x8011880	// 8011880 <__GI_fputs>
 8011872:	9420      	ld.w      	r1, (r4, 0x0)
 8011874:	300a      	movi      	r0, 10
 8011876:	e000149d 	bsr      	0x80141b0	// 80141b0 <fputc>
 801187a:	1491      	pop      	r4, r15
 801187c:	20000120 	.long	0x20000120

08011880 <__GI_fputs>:
 8011880:	14d5      	push      	r4-r8, r15
 8011882:	6d03      	mov      	r4, r0
 8011884:	6d87      	mov      	r6, r1
 8011886:	e9010018 	bez      	r1, 0x80118b6	// 80118b6 <__GI_fputs+0x36>
 801188a:	e5010017 	addi      	r8, r1, 24
 801188e:	6c23      	mov      	r0, r8
 8011890:	e0000020 	bsr      	0x80118d0	// 80118d0 <__GI_os_critical_enter>
 8011894:	8400      	ld.b      	r0, (r4, 0x0)
 8011896:	e9000014 	bez      	r0, 0x80118be	// 80118be <__GI_fputs+0x3e>
 801189a:	3500      	movi      	r5, 0
 801189c:	6dd7      	mov      	r7, r5
 801189e:	2f00      	subi      	r7, 1
 80118a0:	0406      	br      	0x80118ac	// 80118ac <__GI_fputs+0x2c>
 80118a2:	2400      	addi      	r4, 1
 80118a4:	8400      	ld.b      	r0, (r4, 0x0)
 80118a6:	2500      	addi      	r5, 1
 80118a8:	e900000c 	bez      	r0, 0x80118c0	// 80118c0 <__GI_fputs+0x40>
 80118ac:	6c5b      	mov      	r1, r6
 80118ae:	e0001481 	bsr      	0x80141b0	// 80141b0 <fputc>
 80118b2:	65c2      	cmpne      	r0, r7
 80118b4:	0bf7      	bt      	0x80118a2	// 80118a2 <__GI_fputs+0x22>
 80118b6:	3500      	movi      	r5, 0
 80118b8:	2d00      	subi      	r5, 1
 80118ba:	6c17      	mov      	r0, r5
 80118bc:	1495      	pop      	r4-r8, r15
 80118be:	6d43      	mov      	r5, r0
 80118c0:	6c23      	mov      	r0, r8
 80118c2:	e0000009 	bsr      	0x80118d4	// 80118d4 <__GI_os_critical_exit>
 80118c6:	6c17      	mov      	r0, r5
 80118c8:	1495      	pop      	r4-r8, r15
	...

080118cc <__GI_os_critical_open>:
 80118cc:	3000      	movi      	r0, 0
 80118ce:	783c      	jmp      	r15

080118d0 <__GI_os_critical_enter>:
 80118d0:	3000      	movi      	r0, 0
 80118d2:	783c      	jmp      	r15

080118d4 <__GI_os_critical_exit>:
 80118d4:	3000      	movi      	r0, 0
 80118d6:	783c      	jmp      	r15

080118d8 <__GI_os_critical_close>:
 80118d8:	3000      	movi      	r0, 0
 80118da:	783c      	jmp      	r15

080118dc <__GI_putc>:
 80118dc:	14d0      	push      	r15
 80118de:	e0001469 	bsr      	0x80141b0	// 80141b0 <fputc>
 80118e2:	1490      	pop      	r15

080118e4 <HAL_GPIO_Init>:
	
	assert_param(IS_GPIO_ALL_INSTANCE(GPIOx));
	assert_param(IS_GPIO_PIN(GPIO_Init->Pin));
	assert_param(IS_GPIO_MODE(GPIO_Init->Mode));

	while (((GPIO_Init->Pin) >>  position) != 0x00)
 80118e4:	d9812000 	ld.w      	r12, (r1, 0x0)
 80118e8:	e90c0044 	bez      	r12, 0x8011970	// 8011970 <HAL_GPIO_Init+0x8c>
 80118ec:	3200      	movi      	r2, 0
	{
		ioposition = (0x01 << position);
 80118ee:	ea140001 	movi      	r20, 1
			{
					SET_BIT(GPIOx->PULLUP_EN, ioposition);
					SET_BIT(GPIOx->PULLDOWN_EN, ioposition);
			}
			
			switch (GPIO_Init->Mode)
 80118f2:	ea96001f 	lrw      	r22, 0x8014314	// 801196c <HAL_GPIO_Init+0x88>
 80118f6:	0406      	br      	0x8011902	// 8011902 <HAL_GPIO_Init+0x1e>
			{
				SET_BIT(GPIOx->IE, ioposition);
			}
		}
		
		position++;
 80118f8:	2200      	addi      	r2, 1
	while (((GPIO_Init->Pin) >>  position) != 0x00)
 80118fa:	c44c4043 	lsr      	r3, r12, r2
 80118fe:	e9030039 	bez      	r3, 0x8011970	// 8011970 <HAL_GPIO_Init+0x8c>
		ioposition = (0x01 << position);
 8011902:	c4544023 	lsl      	r3, r20, r2
		iocurrent = (uint32_t)(GPIO_Init->Pin) & ioposition;
 8011906:	c583202d 	and      	r13, r3, r12
		if (iocurrent == ioposition)
 801190a:	674e      	cmpne      	r3, r13
 801190c:	0bf6      	bt      	0x80118f8	// 80118f8 <HAL_GPIO_Init+0x14>
			switch (GPIO_Init->Mode)
 801190e:	da612001 	ld.w      	r19, (r1, 0x4)
			__AFIO_REMAP_SET_OPT5(GPIOx, ioposition);
 8011912:	da402004 	ld.w      	r18, (r0, 0x10)
 8011916:	c463248d 	nor      	r13, r3, r3
			switch (GPIO_Init->Mode)
 801191a:	eb530002 	cmpnei      	r19, 2
			__AFIO_REMAP_SET_OPT5(GPIOx, ioposition);
 801191e:	c5b22032 	and      	r18, r18, r13
 8011922:	de402004 	st.w      	r18, (r0, 0x10)
			switch (GPIO_Init->Mode)
 8011926:	0c44      	bf      	0x80119ae	// 80119ae <HAL_GPIO_Init+0xca>
 8011928:	eb130002 	cmphsi      	r19, 3
 801192c:	0823      	bt      	0x8011972	// 8011972 <HAL_GPIO_Init+0x8e>
 801192e:	eb530001 	cmpnei      	r19, 1
 8011932:	08a3      	bt      	0x8011a78	// 8011a78 <HAL_GPIO_Init+0x194>
 8011934:	ea120000 	movi      	r18, 0
 8011938:	e6521085 	subi      	r18, r18, 134
					CLEAR_BIT(GPIOx->DIR, ioposition);
 801193c:	daa02002 	ld.w      	r21, (r0, 0x8)
 8011940:	c6ad2035 	and      	r21, r13, r21
 8011944:	dea02002 	st.w      	r21, (r0, 0x8)
			if (GPIO_Init->Pull == GPIO_NOPULL)
 8011948:	daa12002 	ld.w      	r21, (r1, 0x8)
 801194c:	eb550012 	cmpnei      	r21, 18
 8011950:	0c1b      	bf      	0x8011986	// 8011986 <HAL_GPIO_Init+0xa2>
			else if (GPIO_Init->Pull == GPIO_PULLUP)
 8011952:	eb550013 	cmpnei      	r21, 19
 8011956:	0c37      	bf      	0x80119c4	// 80119c4 <HAL_GPIO_Init+0xe0>
			else if(GPIO_Init->Pull == GPIO_PULLDOWN)
 8011958:	eb550014 	cmpnei      	r21, 20
 801195c:	0c91      	bf      	0x8011a7e	// 8011a7e <HAL_GPIO_Init+0x19a>
			switch (GPIO_Init->Mode)
 801195e:	eb120004 	cmphsi      	r18, 5
 8011962:	0821      	bt      	0x80119a4	// 80119a4 <HAL_GPIO_Init+0xc0>
 8011964:	d2560892 	ldr.w      	r18, (r22, r18 << 2)
 8011968:	e8d20000 	jmp      	r18
 801196c:	08014314 	.long	0x08014314
	}
}
 8011970:	783c      	jmp      	r15
			switch (GPIO_Init->Mode)
 8011972:	e6531086 	subi      	r18, r19, 135
 8011976:	eb120004 	cmphsi      	r18, 5
 801197a:	0fe1      	bf      	0x801193c	// 801193c <HAL_GPIO_Init+0x58>
			if (GPIO_Init->Pull == GPIO_NOPULL)
 801197c:	daa12002 	ld.w      	r21, (r1, 0x8)
 8011980:	eb550012 	cmpnei      	r21, 18
 8011984:	0be7      	bt      	0x8011952	// 8011952 <HAL_GPIO_Init+0x6e>
					SET_BIT(GPIOx->PULLUP_EN, ioposition);
 8011986:	daa02003 	ld.w      	r21, (r0, 0xc)
 801198a:	c6a32435 	or      	r21, r3, r21
 801198e:	dea02003 	st.w      	r21, (r0, 0xc)
					CLEAR_BIT(GPIOx->PULLDOWN_EN, ioposition);
 8011992:	daa02007 	ld.w      	r21, (r0, 0x1c)
			switch (GPIO_Init->Mode)
 8011996:	eb120004 	cmphsi      	r18, 5
					CLEAR_BIT(GPIOx->PULLDOWN_EN, ioposition);
 801199a:	c6ad2035 	and      	r21, r13, r21
 801199e:	dea02007 	st.w      	r21, (r0, 0x1c)
			switch (GPIO_Init->Mode)
 80119a2:	0fe1      	bf      	0x8011964	// 8011964 <HAL_GPIO_Init+0x80>
			if ((GPIO_Init->Mode & EXTI_MODE) == EXTI_MODE)
 80119a4:	e6732080 	andi      	r19, r19, 128
 80119a8:	e913ffa8 	bez      	r19, 0x80118f8	// 80118f8 <HAL_GPIO_Init+0x14>
 80119ac:	0423      	br      	0x80119f2	// 80119f2 <HAL_GPIO_Init+0x10e>
					SET_BIT(GPIOx->DIR, ioposition);
 80119ae:	da402002 	ld.w      	r18, (r0, 0x8)
 80119b2:	c6432432 	or      	r18, r3, r18
 80119b6:	de402002 	st.w      	r18, (r0, 0x8)
 80119ba:	ea120000 	movi      	r18, 0
 80119be:	e6521084 	subi      	r18, r18, 133
					break;
 80119c2:	07c3      	br      	0x8011948	// 8011948 <HAL_GPIO_Init+0x64>
					CLEAR_BIT(GPIOx->PULLUP_EN, ioposition);
 80119c4:	daa02003 	ld.w      	r21, (r0, 0xc)
 80119c8:	c6ad2035 	and      	r21, r13, r21
 80119cc:	dea02003 	st.w      	r21, (r0, 0xc)
					CLEAR_BIT(GPIOx->PULLDOWN_EN, ioposition);
 80119d0:	daa02007 	ld.w      	r21, (r0, 0x1c)
 80119d4:	c6ad2035 	and      	r21, r13, r21
 80119d8:	dea02007 	st.w      	r21, (r0, 0x1c)
 80119dc:	07c1      	br      	0x801195e	// 801195e <HAL_GPIO_Init+0x7a>
					SET_BIT(GPIOx->IS, ioposition);
 80119de:	d9a02008 	ld.w      	r13, (r0, 0x20)
 80119e2:	6f4c      	or      	r13, r3
 80119e4:	dda02008 	st.w      	r13, (r0, 0x20)
					SET_BIT(GPIOx->IEV, ioposition);
 80119e8:	d9a0200a 	ld.w      	r13, (r0, 0x28)
 80119ec:	6f4c      	or      	r13, r3
 80119ee:	dda0200a 	st.w      	r13, (r0, 0x28)
				SET_BIT(GPIOx->IE, ioposition);
 80119f2:	d9a0200b 	ld.w      	r13, (r0, 0x2c)
 80119f6:	6cf4      	or      	r3, r13
 80119f8:	b06b      	st.w      	r3, (r0, 0x2c)
 80119fa:	077f      	br      	0x80118f8	// 80118f8 <HAL_GPIO_Init+0x14>
					CLEAR_BIT(GPIOx->IS, ioposition);
 80119fc:	da402008 	ld.w      	r18, (r0, 0x20)
 8011a00:	c64d202d 	and      	r13, r13, r18
 8011a04:	dda02008 	st.w      	r13, (r0, 0x20)
					SET_BIT(GPIOx->IBE, ioposition);
 8011a08:	d9a02009 	ld.w      	r13, (r0, 0x24)
 8011a0c:	6f4c      	or      	r13, r3
 8011a0e:	dda02009 	st.w      	r13, (r0, 0x24)
					break;
 8011a12:	07f0      	br      	0x80119f2	// 80119f2 <HAL_GPIO_Init+0x10e>
					CLEAR_BIT(GPIOx->IS, ioposition);
 8011a14:	da402008 	ld.w      	r18, (r0, 0x20)
 8011a18:	c64d2032 	and      	r18, r13, r18
 8011a1c:	de402008 	st.w      	r18, (r0, 0x20)
					CLEAR_BIT(GPIOx->IBE, ioposition);
 8011a20:	da402009 	ld.w      	r18, (r0, 0x24)
 8011a24:	c64d2032 	and      	r18, r13, r18
 8011a28:	de402009 	st.w      	r18, (r0, 0x24)
					CLEAR_BIT(GPIOx->IEV, ioposition);
 8011a2c:	da40200a 	ld.w      	r18, (r0, 0x28)
 8011a30:	c64d202d 	and      	r13, r13, r18
 8011a34:	dda0200a 	st.w      	r13, (r0, 0x28)
					break;
 8011a38:	07dd      	br      	0x80119f2	// 80119f2 <HAL_GPIO_Init+0x10e>
					CLEAR_BIT(GPIOx->IS, ioposition);
 8011a3a:	da402008 	ld.w      	r18, (r0, 0x20)
 8011a3e:	c64d2032 	and      	r18, r13, r18
 8011a42:	de402008 	st.w      	r18, (r0, 0x20)
					CLEAR_BIT(GPIOx->IBE, ioposition);
 8011a46:	da402009 	ld.w      	r18, (r0, 0x24)
 8011a4a:	c64d202d 	and      	r13, r13, r18
 8011a4e:	dda02009 	st.w      	r13, (r0, 0x24)
					SET_BIT(GPIOx->IEV, ioposition);
 8011a52:	d9a0200a 	ld.w      	r13, (r0, 0x28)
 8011a56:	6f4c      	or      	r13, r3
 8011a58:	dda0200a 	st.w      	r13, (r0, 0x28)
					break;
 8011a5c:	07cb      	br      	0x80119f2	// 80119f2 <HAL_GPIO_Init+0x10e>
					SET_BIT(GPIOx->IS, ioposition);
 8011a5e:	da402008 	ld.w      	r18, (r0, 0x20)
 8011a62:	c6432432 	or      	r18, r3, r18
 8011a66:	de402008 	st.w      	r18, (r0, 0x20)
					CLEAR_BIT(GPIOx->IEV, ioposition);
 8011a6a:	da40200a 	ld.w      	r18, (r0, 0x28)
 8011a6e:	c64d202d 	and      	r13, r13, r18
 8011a72:	dda0200a 	st.w      	r13, (r0, 0x28)
					break;
 8011a76:	07be      	br      	0x80119f2	// 80119f2 <HAL_GPIO_Init+0x10e>
 8011a78:	e6531086 	subi      	r18, r19, 135
 8011a7c:	0766      	br      	0x8011948	// 8011948 <HAL_GPIO_Init+0x64>
					SET_BIT(GPIOx->PULLUP_EN, ioposition);
 8011a7e:	daa02003 	ld.w      	r21, (r0, 0xc)
 8011a82:	c6a32435 	or      	r21, r3, r21
 8011a86:	dea02003 	st.w      	r21, (r0, 0xc)
					SET_BIT(GPIOx->PULLDOWN_EN, ioposition);
 8011a8a:	daa02007 	ld.w      	r21, (r0, 0x1c)
 8011a8e:	c6a32435 	or      	r21, r3, r21
 8011a92:	dea02007 	st.w      	r21, (r0, 0x1c)
 8011a96:	0764      	br      	0x801195e	// 801195e <HAL_GPIO_Init+0x7a>

08011a98 <HAL_GPIO_WritePin>:
	uint32_t data_en;
	
	assert_param(IS_GPIO_PIN(GPIO_Pin));
	assert_param(IS_GPIO_PIN_ACTION(PinState));

	data_en = READ_REG(GPIOx->DATA_B_EN);
 8011a98:	d9802001 	ld.w      	r12, (r0, 0x4)
	SET_BIT(GPIOx->DATA_B_EN, GPIO_Pin);
 8011a9c:	9061      	ld.w      	r3, (r0, 0x4)
 8011a9e:	6cc4      	or      	r3, r1
 8011aa0:	b061      	st.w      	r3, (r0, 0x4)
	if (PinState != GPIO_PIN_RESET)
	{
		SET_BIT(GPIOx->DATA, GPIO_Pin);
 8011aa2:	9060      	ld.w      	r3, (r0, 0x0)
	if (PinState != GPIO_PIN_RESET)
 8011aa4:	e9220008 	bnez      	r2, 0x8011ab4	// 8011ab4 <HAL_GPIO_WritePin+0x1c>
	}
	else
	{
		CLEAR_BIT(GPIOx->DATA, GPIO_Pin);
 8011aa8:	c4232041 	andn      	r1, r3, r1
 8011aac:	b020      	st.w      	r1, (r0, 0x0)
	}
	WRITE_REG(GPIOx->DATA_B_EN, data_en);
 8011aae:	dd802001 	st.w      	r12, (r0, 0x4)
}
 8011ab2:	783c      	jmp      	r15
		SET_BIT(GPIOx->DATA, GPIO_Pin);
 8011ab4:	6c4c      	or      	r1, r3
 8011ab6:	b020      	st.w      	r1, (r0, 0x0)
	WRITE_REG(GPIOx->DATA_B_EN, data_en);
 8011ab8:	dd802001 	st.w      	r12, (r0, 0x4)
}
 8011abc:	783c      	jmp      	r15
	...

08011ac0 <HAL_InitTick>:
 */
void SystemClock_Get(wm_sys_clk *sysclk)
{
	clk_div_reg clk_div;

	clk_div.w = READ_REG(RCC->CLK_DIV);
 8011ac0:	ea234000 	movih      	r3, 16384
 8011ac4:	e4630dff 	addi      	r3, r3, 3584
	sysclk->apbclk = sysclk->cpuclk / clk_div.b.BUS2;
}


__attribute__((weak)) HAL_StatusTypeDef HAL_InitTick(uint32_t TickPriority)
{
 8011ac8:	6f03      	mov      	r12, r0
	clk_div.w = READ_REG(RCC->CLK_DIV);
 8011aca:	9364      	ld.w      	r3, (r3, 0x10)
	sysclk->cpuclk = W805_PLL_CLK_MHZ/(clk_div.b.CPU);
 8011acc:	748c      	zextb      	r2, r3
 8011ace:	ea0301e0 	movi      	r3, 480
 8011ad2:	c4438043 	divs      	r3, r3, r2
	wm_sys_clk sysclk;
	
	SystemClock_Get(&sysclk);
	SysTick_Config(sysclk.cpuclk * UNIT_MHZ / uwTickFreq);
 8011ad6:	ea02f424 	movi      	r2, 62500
 8011ada:	c4824902 	rotli      	r2, r2, 4
 8011ade:	7cc8      	mult      	r3, r2
 8011ae0:	ea0203e8 	movi      	r2, 1000
 8011ae4:	c4438023 	divu      	r3, r3, r2
{
    if ((ticks - 1UL) > CORET_LOAD_RELOAD_Msk) {
        return (1UL);                                                   /* Reload value impossible */
    }

    CORET->LOAD = (uint32_t)(ticks - 1UL);                              /* set reload register */
 8011ae8:	104f      	lrw      	r2, 0xe000e010	// 8011b24 <HAL_InitTick+0x64>
    if ((ticks - 1UL) > CORET_LOAD_RELOAD_Msk) {
 8011aea:	2b00      	subi      	r3, 1
    CORET->LOAD = (uint32_t)(ticks - 1UL);                              /* set reload register */
 8011aec:	b261      	st.w      	r3, (r2, 0x4)
	clk_div.w = READ_REG(RCC->CLK_DIV);
 8011aee:	3000      	movi      	r0, 0
    CORET->VAL  = 0UL;                                                  /* Load the CORET Counter Value */
    CORET->CTRL = CORET_CTRL_CLKSOURCE_Msk |
 8011af0:	3307      	movi      	r3, 7
    CORET->VAL  = 0UL;                                                  /* Load the CORET Counter Value */
 8011af2:	b202      	st.w      	r0, (r2, 0x8)
    CORET->CTRL = CORET_CTRL_CLKSOURCE_Msk |
 8011af4:	b260      	st.w      	r3, (r2, 0x0)
    VIC->IPR[_IP_IDX(IRQn)] = ((uint32_t)(VIC->IPR[_IP_IDX(IRQn)]  & ~(0xFFUL << _BIT_SHIFT(IRQn))) |
 8011af6:	104d      	lrw      	r2, 0xe000e100	// 8011b28 <HAL_InitTick+0x68>
                                 (((priority << (8U - __VIC_PRIO_BITS)) & (uint32_t)0xFFUL) << _BIT_SHIFT(IRQn)));
 8011af8:	c5cc4823 	lsli      	r3, r12, 14
    VIC->IPR[_IP_IDX(IRQn)] = ((uint32_t)(VIC->IPR[_IP_IDX(IRQn)]  & ~(0xFFUL << _BIT_SHIFT(IRQn))) |
 8011afc:	d82220c6 	ld.w      	r1, (r2, 0x318)
 8011b00:	ea0dff00 	movi      	r13, 65280
 8011b04:	6f76      	nor      	r13, r13
 8011b06:	6874      	and      	r1, r13
                                 (((priority << (8U - __VIC_PRIO_BITS)) & (uint32_t)0xFFUL) << _BIT_SHIFT(IRQn)));
 8011b08:	c40355e3 	zext      	r3, r3, 15, 0
    VIC->IPR[_IP_IDX(IRQn)] = ((uint32_t)(VIC->IPR[_IP_IDX(IRQn)]  & ~(0xFFUL << _BIT_SHIFT(IRQn))) |
 8011b0c:	6cc4      	or      	r3, r1
 8011b0e:	dc6220c6 	st.w      	r3, (r2, 0x318)
    VIC->ISER[_IR_IDX(IRQn)] = (uint32_t)(1UL << ((uint32_t)(int32_t)IRQn % 32));
 8011b12:	ea230200 	movih      	r3, 512
 8011b16:	b260      	st.w      	r3, (r2, 0x0)
    VIC->ISSR[_IR_IDX(IRQn)] = (uint32_t)(1UL << ((uint32_t)(int32_t)IRQn % 32));
 8011b18:	dc622050 	st.w      	r3, (r2, 0x140)
	HAL_NVIC_SetPriority(SYS_TICK_IRQn, TickPriority);
	HAL_NVIC_EnableIRQ(SYS_TICK_IRQn);
	uwTickPrio = TickPriority;
 8011b1c:	1064      	lrw      	r3, 0x20001368	// 8011b2c <HAL_InitTick+0x6c>
 8011b1e:	dd832000 	st.w      	r12, (r3, 0x0)
	return HAL_OK;
}
 8011b22:	783c      	jmp      	r15
 8011b24:	e000e010 	.long	0xe000e010
 8011b28:	e000e100 	.long	0xe000e100
 8011b2c:	20001368 	.long	0x20001368

08011b30 <SystemClock_Config>:
{
 8011b30:	14d0      	push      	r15
	if ((clk < 2) || (clk > 240))
 8011b32:	5867      	subi      	r3, r0, 2
 8011b34:	eb0300ee 	cmphsi      	r3, 239
 8011b38:	0826      	bt      	0x8011b84	// 8011b84 <SystemClock_Config+0x54>
    RegValue = READ_REG(RCC->CLK_EN);
 8011b3a:	ea224000 	movih      	r2, 16384
 8011b3e:	e4420dff 	addi      	r2, r2, 3584
    RegValue &= ~0x3FFFFF;
 8011b42:	ea21ffc0 	movih      	r1, 65472
    RegValue = READ_REG(RCC->CLK_EN);
 8011b46:	9260      	ld.w      	r3, (r2, 0x0)
    RegValue &= ~0x3FFFFF;
 8011b48:	68c4      	and      	r3, r1
    RegValue |= 0x802;
 8011b4a:	ec630802 	ori      	r3, r3, 2050
    WRITE_REG(RCC->CLK_EN, RegValue);
 8011b4e:	b260      	st.w      	r3, (r2, 0x0)
	WRITE_REG(RCC->BBP_CLK, 0x0F);
 8011b50:	330f      	movi      	r3, 15
 8011b52:	b262      	st.w      	r3, (r2, 0x8)
	RegValue = READ_REG(RCC->CLK_DIV);
 8011b54:	9264      	ld.w      	r3, (r2, 0x10)
	RegValue &= 0xFF000000;
 8011b56:	ea22ff00 	movih      	r2, 65280
 8011b5a:	68c8      	and      	r3, r2
	if(cpuDiv > 12)
 8011b5c:	320c      	movi      	r2, 12
 8011b5e:	6408      	cmphs      	r2, r0
	RegValue |= 0x80000000;
 8011b60:	3bbf      	bseti      	r3, 31
	if(cpuDiv > 12)
 8011b62:	0c12      	bf      	0x8011b86	// 8011b86 <SystemClock_Config+0x56>
		bus2Fac = (wlanDiv*4/cpuDiv)&0xFF;
 8011b64:	c4028022 	divu      	r2, r2, r0
 8011b68:	4250      	lsli      	r2, r2, 16
 8011b6a:	ea010300 	movi      	r1, 768
 8011b6e:	6c0c      	or      	r0, r3
 8011b70:	6c08      	or      	r0, r2
	WRITE_REG(RCC->CLK_DIV, RegValue);
 8011b72:	ea234000 	movih      	r3, 16384
 8011b76:	e4630dff 	addi      	r3, r3, 3584
	RegValue |= (bus2Fac<<16) | (wlanDiv<<8) | cpuDiv;
 8011b7a:	6c04      	or      	r0, r1
	WRITE_REG(RCC->CLK_DIV, RegValue);
 8011b7c:	b304      	st.w      	r0, (r3, 0x10)
	HAL_InitTick(TICK_INT_PRIORITY);
 8011b7e:	3007      	movi      	r0, 7
 8011b80:	e3ffffa0 	bsr      	0x8011ac0	// 8011ac0 <HAL_InitTick>
}
 8011b84:	1490      	pop      	r15
		wlanDiv = cpuDiv/4;
 8011b86:	4822      	lsri      	r1, r0, 2
 8011b88:	4128      	lsli      	r1, r1, 8
 8011b8a:	ea220001 	movih      	r2, 1
 8011b8e:	07f0      	br      	0x8011b6e	// 8011b6e <SystemClock_Config+0x3e>

08011b90 <HAL_IncTick>:

__attribute__((weak)) void HAL_IncTick(void)
{
	uwTick += 1;
 8011b90:	1043      	lrw      	r2, 0x20001364	// 8011b9c <HAL_IncTick+0xc>
 8011b92:	9260      	ld.w      	r3, (r2, 0x0)
 8011b94:	2300      	addi      	r3, 1
 8011b96:	b260      	st.w      	r3, (r2, 0x0)
}
 8011b98:	783c      	jmp      	r15
 8011b9a:	0000      	.short	0x0000
 8011b9c:	20001364 	.long	0x20001364

08011ba0 <HAL_GetTick>:

__attribute__((weak)) uint32_t HAL_GetTick(void)
{
	return uwTick;
 8011ba0:	1062      	lrw      	r3, 0x20001364	// 8011ba8 <HAL_GetTick+0x8>
 8011ba2:	9300      	ld.w      	r0, (r3, 0x0)
}
 8011ba4:	783c      	jmp      	r15
 8011ba6:	0000      	.short	0x0000
 8011ba8:	20001364 	.long	0x20001364

08011bac <HAL_Delay>:

__attribute__((weak)) void HAL_Delay(uint32_t Delay)
{
 8011bac:	14d2      	push      	r4-r5, r15
 8011bae:	6d43      	mov      	r5, r0
	uint32_t tickstart = HAL_GetTick();
 8011bb0:	e3fffff8 	bsr      	0x8011ba0	// 8011ba0 <HAL_GetTick>
 8011bb4:	6d03      	mov      	r4, r0
	uint32_t wait = Delay;

	while ((HAL_GetTick() - tickstart) < wait)
 8011bb6:	e3fffff5 	bsr      	0x8011ba0	// 8011ba0 <HAL_GetTick>
 8011bba:	6012      	subu      	r0, r4
 8011bbc:	6540      	cmphs      	r0, r5
 8011bbe:	0ffc      	bf      	0x8011bb6	// 8011bb6 <HAL_Delay+0xa>
	{
	}
}
 8011bc0:	1492      	pop      	r4-r5, r15
	...

08011bc4 <HAL_SPI_Init>:
#include "wm_spi.h"

HAL_StatusTypeDef HAL_SPI_Init(SPI_HandleTypeDef *hspi)
{
 8011bc4:	14d1      	push      	r4, r15
 8011bc6:	6d03      	mov      	r4, r0
	if (hspi == NULL)
 8011bc8:	e9000028 	bez      	r0, 0x8011c18	// 8011c18 <HAL_SPI_Init+0x54>
	assert_param(IS_SPI_BAUDRATE_PRESCALER(hspi->Init.BaudRatePrescaler));
	assert_param(IS_SPI_CPOL(hspi->Init.CLKPolarity));
    assert_param(IS_SPI_CPHA(hspi->Init.CLKPhase));
	assert_param(IS_SPI_BIG_OR_LITTLE(hspi->Init.FirstByte));
	
	if (hspi->State == HAL_SPI_STATE_RESET)
 8011bcc:	906e      	ld.w      	r3, (r0, 0x38)
 8011bce:	e9030021 	bez      	r3, 0x8011c10	// 8011c10 <HAL_SPI_Init+0x4c>
	{
		hspi->Lock = HAL_UNLOCKED;
		HAL_SPI_MspInit(hspi);
	}
	hspi->State = HAL_SPI_STATE_BUSY;
 8011bd2:	3302      	movi      	r3, 2
 8011bd4:	b46e      	st.w      	r3, (r4, 0x38)
	
	__HAL_SPI_DISABLE(hspi);
 8011bd6:	9460      	ld.w      	r3, (r4, 0x0)
 8011bd8:	ea21ffe8 	movih      	r1, 65512
 8011bdc:	9340      	ld.w      	r2, (r3, 0x0)
 8011bde:	2901      	subi      	r1, 2
 8011be0:	6884      	and      	r2, r1
 8011be2:	b340      	st.w      	r2, (r3, 0x0)
	
	WRITE_REG(hspi->Instance->CH_CFG, (hspi->Init.NSS | SPI_CH_CFG_CLEARFIFOS));
 8011be4:	9444      	ld.w      	r2, (r4, 0x10)
 8011be6:	3ab6      	bseti      	r2, 22
 8011be8:	b340      	st.w      	r2, (r3, 0x0)
	WRITE_REG(hspi->Instance->SPI_CFG, (hspi->Init.Mode | hspi->Init.CLKPolarity | hspi->Init.CLKPhase | hspi->Init.FirstByte));
 8011bea:	9422      	ld.w      	r1, (r4, 0x8)
 8011bec:	9441      	ld.w      	r2, (r4, 0x4)
 8011bee:	6c84      	or      	r2, r1
 8011bf0:	9423      	ld.w      	r1, (r4, 0xc)
 8011bf2:	6c84      	or      	r2, r1
 8011bf4:	9426      	ld.w      	r1, (r4, 0x18)
 8011bf6:	6c84      	or      	r2, r1
 8011bf8:	b341      	st.w      	r2, (r3, 0x4)
	WRITE_REG(hspi->Instance->CLK_CFG, hspi->Init.BaudRatePrescaler);
 8011bfa:	9445      	ld.w      	r2, (r4, 0x14)
 8011bfc:	b342      	st.w      	r2, (r3, 0x8)
	
	__HAL_SPI_SET_CS_HIGH(hspi);
 8011bfe:	9340      	ld.w      	r2, (r3, 0x0)
 8011c00:	ec420004 	ori      	r2, r2, 4
 8011c04:	b340      	st.w      	r2, (r3, 0x0)
	
	hspi->ErrorCode = HAL_SPI_ERROR_NONE;
 8011c06:	3000      	movi      	r0, 0
	hspi->State     = HAL_SPI_STATE_READY;
 8011c08:	3301      	movi      	r3, 1
	hspi->ErrorCode = HAL_SPI_ERROR_NONE;
 8011c0a:	b40f      	st.w      	r0, (r4, 0x3c)
	hspi->State     = HAL_SPI_STATE_READY;
 8011c0c:	b46e      	st.w      	r3, (r4, 0x38)
	
	return HAL_OK;
}
 8011c0e:	1491      	pop      	r4, r15
		hspi->Lock = HAL_UNLOCKED;
 8011c10:	b06d      	st.w      	r3, (r0, 0x34)
		HAL_SPI_MspInit(hspi);
 8011c12:	e0000293 	bsr      	0x8012138	// 8012138 <HAL_SPI_MspInit>
 8011c16:	07de      	br      	0x8011bd2	// 8011bd2 <HAL_SPI_Init+0xe>
		return HAL_ERROR;
 8011c18:	3001      	movi      	r0, 1
}
 8011c1a:	1491      	pop      	r4, r15

08011c1c <HAL_SPI_Transmit>:
{
	UNUSED(hspi);
}

HAL_StatusTypeDef HAL_SPI_Transmit(SPI_HandleTypeDef *hspi, uint8_t *pData, uint32_t Size, uint32_t Timeout)
{
 8011c1c:	ebe00058 	push      	r4-r11, r15, r16-r17
 8011c20:	c4034831 	lsli      	r17, r3, 0
	uint32_t tickstart, data = 0, i = 0;
	HAL_StatusTypeDef errorcode = HAL_OK;
	uint32_t fifo_count = 0, block_cnt = 0, tx_block_cnt = 0, tx_size = 0;
	
	__HAL_LOCK(hspi);
 8011c24:	906d      	ld.w      	r3, (r0, 0x34)
 8011c26:	3b41      	cmpnei      	r3, 1
{
 8011c28:	6ec3      	mov      	r11, r0
	__HAL_LOCK(hspi);
 8011c2a:	0804      	bt      	0x8011c32	// 8011c32 <HAL_SPI_Transmit+0x16>
 8011c2c:	3002      	movi      	r0, 2
	CLEAR_BIT(hspi->Instance->CH_CFG, SPI_CH_CFG_TXON);
	hspi->State = HAL_SPI_STATE_READY;
	
	__HAL_UNLOCK(hspi);
	return errorcode;
}
 8011c2e:	ebc00058 	pop      	r4-r11, r15, r16-r17
	__HAL_LOCK(hspi);
 8011c32:	3301      	movi      	r3, 1
 8011c34:	b06d      	st.w      	r3, (r0, 0x34)
 8011c36:	6d4b      	mov      	r5, r2
 8011c38:	6d07      	mov      	r4, r1
	tickstart = HAL_GetTick();
 8011c3a:	e3ffffb3 	bsr      	0x8011ba0	// 8011ba0 <HAL_GetTick>
	if (hspi->State != HAL_SPI_STATE_READY)
 8011c3e:	d86b200e 	ld.w      	r3, (r11, 0x38)
 8011c42:	3b41      	cmpnei      	r3, 1
	tickstart = HAL_GetTick();
 8011c44:	6dc3      	mov      	r7, r0
 8011c46:	daab2000 	ld.w      	r21, (r11, 0x0)
	if (hspi->State != HAL_SPI_STATE_READY)
 8011c4a:	6c53      	mov      	r1, r4
 8011c4c:	6c97      	mov      	r2, r5
 8011c4e:	0c0f      	bf      	0x8011c6c	// 8011c6c <HAL_SPI_Transmit+0x50>
		errorcode = HAL_BUSY;
 8011c50:	3002      	movi      	r0, 2
	CLEAR_BIT(hspi->Instance->CH_CFG, SPI_CH_CFG_TXON);
 8011c52:	d8752000 	ld.w      	r3, (r21, 0x0)
 8011c56:	3b93      	bclri      	r3, 19
 8011c58:	dc752000 	st.w      	r3, (r21, 0x0)
	hspi->State = HAL_SPI_STATE_READY;
 8011c5c:	3301      	movi      	r3, 1
 8011c5e:	dc6b200e 	st.w      	r3, (r11, 0x38)
	__HAL_UNLOCK(hspi);
 8011c62:	3300      	movi      	r3, 0
 8011c64:	dc6b200d 	st.w      	r3, (r11, 0x34)
}
 8011c68:	ebc00058 	pop      	r4-r11, r15, r16-r17
	if ((pData == NULL) || (Size == 0U))
 8011c6c:	e9040094 	bez      	r4, 0x8011d94	// 8011d94 <HAL_SPI_Transmit+0x178>
 8011c70:	e9050092 	bez      	r5, 0x8011d94	// 8011d94 <HAL_SPI_Transmit+0x178>
	__HAL_SPI_CLEAR_FIFO(hspi);
 8011c74:	d8752000 	ld.w      	r3, (r21, 0x0)
 8011c78:	3bb6      	bseti      	r3, 22
 8011c7a:	dc752000 	st.w      	r3, (r21, 0x0)
 8011c7e:	ea230040 	movih      	r3, 64
 8011c82:	d8952000 	ld.w      	r4, (r21, 0x0)
 8011c86:	690c      	and      	r4, r3
 8011c88:	e924fffd 	bnez      	r4, 0x8011c82	// 8011c82 <HAL_SPI_Transmit+0x66>
	SET_BIT(hspi->Instance->CH_CFG, SPI_CH_CFG_TXON);
 8011c8c:	d8752000 	ld.w      	r3, (r21, 0x0)
 8011c90:	3bb3      	bseti      	r3, 19
 8011c92:	dc752000 	st.w      	r3, (r21, 0x0)
	hspi->State       = HAL_SPI_STATE_BUSY_TX;
 8011c96:	3303      	movi      	r3, 3
 8011c98:	dc6b200e 	st.w      	r3, (r11, 0x38)
	block_cnt = Size / BLOCK_SIZE;
 8011c9c:	ea031ffc 	movi      	r3, 8188
 8011ca0:	c462802a 	divu      	r10, r2, r3
			tx_size = Size % BLOCK_SIZE;
 8011ca4:	7ce8      	mult      	r3, r10
 8011ca6:	5acd      	subu      	r6, r2, r3
			if ((((HAL_GetTick() - tickstart) >=  Timeout) && (Timeout != HAL_MAX_DELAY)) || (Timeout == 0U))
 8011ca8:	ea090000 	movi      	r9, 0
	hspi->ErrorCode   = HAL_SPI_ERROR_NONE;
 8011cac:	dc8b200f 	st.w      	r4, (r11, 0x3c)
	hspi->pRxBuffPtr  = (uint8_t *)NULL;
 8011cb0:	dc8b200a 	st.w      	r4, (r11, 0x28)
	hspi->RxXferSize  = 0U;
 8011cb4:	dc8b200b 	st.w      	r4, (r11, 0x2c)
	hspi->RxXferCount = 0U;
 8011cb8:	dc8b200c 	st.w      	r4, (r11, 0x30)
 8011cbc:	c4c64830 	lsli      	r16, r6, 6
 8011cc0:	6d47      	mov      	r5, r1
			fifo_count = (32 - __HAL_SPI_GET_TXFIFO(hspi)) / 4;
 8011cc2:	ea080020 	movi      	r8, 32
			if ((((HAL_GetTick() - tickstart) >=  Timeout) && (Timeout != HAL_MAX_DELAY)) || (Timeout == 0U))
 8011cc6:	e5291000 	subi      	r9, r9, 1
		if (tx_block_cnt < block_cnt)
 8011cca:	6690      	cmphs      	r4, r10
 8011ccc:	ea220008 	movih      	r2, 8
 8011cd0:	2aff      	subi      	r2, 256
 8011cd2:	c4500c40 	inct      	r2, r16, 0
 8011cd6:	ea031ffc 	movi      	r3, 8188
 8011cda:	6690      	cmphs      	r4, r10
 8011cdc:	c4660c40 	inct      	r3, r6, 0
		hspi->TxXferCount = tx_size;
 8011ce0:	dc6b2009 	st.w      	r3, (r11, 0x24)
		hspi->TxXferSize  = tx_size;
 8011ce4:	dc6b2008 	st.w      	r3, (r11, 0x20)
		__HAL_SPI_SET_CLK_NUM(hspi, tx_size * 8);
 8011ce8:	ea01ffff 	movi      	r1, 65535
 8011cec:	c6614901 	rotli      	r1, r1, 19
 8011cf0:	d8752000 	ld.w      	r3, (r21, 0x0)
 8011cf4:	68c4      	and      	r3, r1
 8011cf6:	6cc8      	or      	r3, r2
		hspi->pTxBuffPtr  = (uint8_t *)(pData + (tx_block_cnt * BLOCK_SIZE));
 8011cf8:	dcab2007 	st.w      	r5, (r11, 0x1c)
		__HAL_SPI_SET_CLK_NUM(hspi, tx_size * 8);
 8011cfc:	dc752000 	st.w      	r3, (r21, 0x0)
		__HAL_SPI_SET_START(hspi);
 8011d00:	d8752000 	ld.w      	r3, (r21, 0x0)
 8011d04:	ec630001 	ori      	r3, r3, 1
 8011d08:	dc752000 	st.w      	r3, (r21, 0x0)
		while (hspi->TxXferCount > 0U)
 8011d0c:	d86b2009 	ld.w      	r3, (r11, 0x24)
 8011d10:	e9030044 	bez      	r3, 0x8011d98	// 8011d98 <HAL_SPI_Transmit+0x17c>
			fifo_count = (32 - __HAL_SPI_GET_TXFIFO(hspi)) / 4;
 8011d14:	da952006 	ld.w      	r20, (r21, 0x18)
 8011d18:	e694203f 	andi      	r20, r20, 63
 8011d1c:	c6880094 	subu      	r20, r8, r20
 8011d20:	c4544854 	lsri      	r20, r20, 2
			while((fifo_count > 0) && (hspi->TxXferCount > 0))
 8011d24:	e914004d 	bez      	r20, 0x8011dbe	// 8011dbe <HAL_SPI_Transmit+0x1a2>
 8011d28:	d86b2009 	ld.w      	r3, (r11, 0x24)
 8011d2c:	e9030049 	bez      	r3, 0x8011dbe	// 8011dbe <HAL_SPI_Transmit+0x1a2>
 8011d30:	da6b2007 	ld.w      	r19, (r11, 0x1c)
 8011d34:	0429      	br      	0x8011d86	// 8011d86 <HAL_SPI_Transmit+0x16a>
				for (i = 0; i < hspi->TxXferCount; i++)
 8011d36:	3100      	movi      	r1, 0
 8011d38:	c4134820 	lsli      	r0, r19, 0
 8011d3c:	6c87      	mov      	r2, r1
 8011d3e:	c4014832 	lsli      	r18, r1, 0
 8011d42:	ea0c0004 	movi      	r12, 4
					data |= (hspi->pTxBuffPtr[i] << (i * 8));
 8011d46:	8060      	ld.b      	r3, (r0, 0x0)
 8011d48:	70c4      	lsl      	r3, r1
 8011d4a:	c4722432 	or      	r18, r18, r3
				for (i = 0; i < hspi->TxXferCount; i++)
 8011d4e:	2200      	addi      	r2, 1
 8011d50:	d86b2009 	ld.w      	r3, (r11, 0x24)
 8011d54:	64c8      	cmphs      	r2, r3
 8011d56:	0805      	bt      	0x8011d60	// 8011d60 <HAL_SPI_Transmit+0x144>
 8011d58:	2000      	addi      	r0, 1
 8011d5a:	2107      	addi      	r1, 8
					if (i == 4)
 8011d5c:	e82cfff5 	bnezad      	r12, 0x8011d46	// 8011d46 <HAL_SPI_Transmit+0x12a>
				hspi->TxXferCount -= i;
 8011d60:	d86b2009 	ld.w      	r3, (r11, 0x24)
				hspi->pTxBuffPtr += sizeof(uint8_t) * i;
 8011d64:	c4530033 	addu      	r19, r19, r2
					fifo_count--;
 8011d68:	e6941000 	subi      	r20, r20, 1
				hspi->TxXferCount -= i;
 8011d6c:	5b49      	subu      	r2, r3, r2
				hspi->pTxBuffPtr += sizeof(uint8_t) * i;
 8011d6e:	de6b2007 	st.w      	r19, (r11, 0x1c)
				hspi->TxXferCount -= i;
 8011d72:	dc4b2009 	st.w      	r2, (r11, 0x24)
				WRITE_REG(hspi->Instance->TXDATA, data);
 8011d76:	de552008 	st.w      	r18, (r21, 0x20)
			while((fifo_count > 0) && (hspi->TxXferCount > 0))
 8011d7a:	e9140022 	bez      	r20, 0x8011dbe	// 8011dbe <HAL_SPI_Transmit+0x1a2>
 8011d7e:	d86b2009 	ld.w      	r3, (r11, 0x24)
 8011d82:	e903001e 	bez      	r3, 0x8011dbe	// 8011dbe <HAL_SPI_Transmit+0x1a2>
				for (i = 0; i < hspi->TxXferCount; i++)
 8011d86:	d84b2009 	ld.w      	r2, (r11, 0x24)
 8011d8a:	e922ffd6 	bnez      	r2, 0x8011d36	// 8011d36 <HAL_SPI_Transmit+0x11a>
 8011d8e:	c4024832 	lsli      	r18, r2, 0
 8011d92:	07e7      	br      	0x8011d60	// 8011d60 <HAL_SPI_Transmit+0x144>
		errorcode = HAL_ERROR;
 8011d94:	3001      	movi      	r0, 1
 8011d96:	075e      	br      	0x8011c52	// 8011c52 <HAL_SPI_Transmit+0x36>
		while (__HAL_SPI_GET_FLAG(hspi, SPI_INT_SRC_DONE) != SPI_INT_SRC_DONE)
 8011d98:	d8752005 	ld.w      	r3, (r21, 0x14)
 8011d9c:	e4632040 	andi      	r3, r3, 64
 8011da0:	e923001b 	bnez      	r3, 0x8011dd6	// 8011dd6 <HAL_SPI_Transmit+0x1ba>
			if ((((HAL_GetTick() - tickstart) >=  Timeout) && (Timeout != HAL_MAX_DELAY)) || (Timeout == 0U))
 8011da4:	e3fffefe 	bsr      	0x8011ba0	// 8011ba0 <HAL_GetTick>
 8011da8:	601e      	subu      	r0, r7
 8011daa:	c6200420 	cmphs      	r0, r17
 8011dae:	daab2000 	ld.w      	r21, (r11, 0x0)
 8011db2:	0ff3      	bf      	0x8011d98	// 8011d98 <HAL_SPI_Transmit+0x17c>
 8011db4:	c5310480 	cmpne      	r17, r9
 8011db8:	0ff0      	bf      	0x8011d98	// 8011d98 <HAL_SPI_Transmit+0x17c>
				errorcode = HAL_TIMEOUT;
 8011dba:	3003      	movi      	r0, 3
 8011dbc:	074b      	br      	0x8011c52	// 8011c52 <HAL_SPI_Transmit+0x36>
			if ((((HAL_GetTick() - tickstart) >=  Timeout) && (Timeout != HAL_MAX_DELAY)) || (Timeout == 0U))
 8011dbe:	e3fffef1 	bsr      	0x8011ba0	// 8011ba0 <HAL_GetTick>
 8011dc2:	601e      	subu      	r0, r7
 8011dc4:	c6200420 	cmphs      	r0, r17
 8011dc8:	daab2000 	ld.w      	r21, (r11, 0x0)
 8011dcc:	0fa0      	bf      	0x8011d0c	// 8011d0c <HAL_SPI_Transmit+0xf0>
 8011dce:	c5310480 	cmpne      	r17, r9
 8011dd2:	0f9d      	bf      	0x8011d0c	// 8011d0c <HAL_SPI_Transmit+0xf0>
 8011dd4:	07f3      	br      	0x8011dba	// 8011dba <HAL_SPI_Transmit+0x19e>
		__HAL_SPI_CELAR_FLAG(hspi, SPI_INT_SRC_DONE);
 8011dd6:	d8752005 	ld.w      	r3, (r21, 0x14)
		tx_block_cnt++;
 8011dda:	2400      	addi      	r4, 1
		__HAL_SPI_CELAR_FLAG(hspi, SPI_INT_SRC_DONE);
 8011ddc:	ec630040 	ori      	r3, r3, 64
	while (tx_block_cnt <= block_cnt)
 8011de0:	6528      	cmphs      	r10, r4
		__HAL_SPI_CELAR_FLAG(hspi, SPI_INT_SRC_DONE);
 8011de2:	dc752005 	st.w      	r3, (r21, 0x14)
 8011de6:	ea031ffc 	movi      	r3, 8188
 8011dea:	614c      	addu      	r5, r3
	while (tx_block_cnt <= block_cnt)
 8011dec:	0b6f      	bt      	0x8011cca	// 8011cca <HAL_SPI_Transmit+0xae>
	HAL_StatusTypeDef errorcode = HAL_OK;
 8011dee:	3000      	movi      	r0, 0
 8011df0:	0731      	br      	0x8011c52	// 8011c52 <HAL_SPI_Transmit+0x36>
	...

08011df4 <main>:
static void SPI_Init(void);     
#endif
void Error_Handler(void);

int main(void)
{
 8011df4:	ebe00038 	push      	r4-r11, r15, r16
 8011df8:	1427      	subi      	r14, r14, 28
	SystemClock_Config(CPU_CLK_240M); //设置主频为240MHZ 可设置160/80/40/2 见wm_cpu.h
 8011dfa:	3002      	movi      	r0, 2
 8011dfc:	e3fffe9a 	bsr      	0x8011b30	// 8011b30 <SystemClock_Config>
	printf("enter main\r\n");         //串口打印
 8011e00:	0316      	lrw      	r0, 0x80618a8	// 8012024 <main+0x230>
 8011e02:	e3fffd33 	bsr      	0x8011868	// 8011868 <__GI_puts>

static void GPIO_Init(void)
{
	GPIO_InitTypeDef GPIO_InitStruct;

	__HAL_RCC_GPIO_CLK_ENABLE();
 8011e06:	ea224000 	movih      	r2, 16384
 8011e0a:	e4420dff 	addi      	r2, r2, 3584
 8011e0e:	3400      	movi      	r4, 0
 8011e10:	9260      	ld.w      	r3, (r2, 0x0)
 8011e12:	ec630800 	ori      	r3, r3, 2048
 8011e16:	b260      	st.w      	r3, (r2, 0x0)
#if ST7789_SPI	
	GPIO_InitStruct.Pin = S_BLC_PIN;                //背光控制脚
 8011e18:	3604      	movi      	r6, 4
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
 8011e1a:	3312      	movi      	r3, 18
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT;
 8011e1c:	3502      	movi      	r5, 2
	HAL_GPIO_Init(S_BLC_PORT, &GPIO_InitStruct);
 8011e1e:	1904      	addi      	r1, r14, 16
 8011e20:	031d      	lrw      	r0, 0x40011400	// 8012028 <main+0x234>
	GPIO_InitStruct.Pull = GPIO_NOPULL;
 8011e22:	b866      	st.w      	r3, (r14, 0x18)
	GPIO_InitStruct.Pin = S_BLC_PIN;                //背光控制脚
 8011e24:	b8c4      	st.w      	r6, (r14, 0x10)
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT;
 8011e26:	b8a5      	st.w      	r5, (r14, 0x14)
	HAL_GPIO_Init(S_BLC_PORT, &GPIO_InitStruct);
 8011e28:	e3fffd5e 	bsr      	0x80118e4	// 80118e4 <HAL_GPIO_Init>
	HAL_GPIO_WritePin(S_BLC_PORT, S_BLC_PIN, GPIO_PIN_RESET);
 8011e2c:	6c93      	mov      	r2, r4
 8011e2e:	6c5b      	mov      	r1, r6
 8011e30:	131e      	lrw      	r0, 0x40011400	// 8012028 <main+0x234>
 8011e32:	e3fffe33 	bsr      	0x8011a98	// 8011a98 <HAL_GPIO_WritePin>
	
	
	GPIO_InitStruct.Pin = S_CD_PIN;                //数据指令选择脚
 8011e36:	3708      	movi      	r7, 8
	HAL_GPIO_Init(S_CD_PORT, &GPIO_InitStruct);
 8011e38:	1904      	addi      	r1, r14, 16
 8011e3a:	131c      	lrw      	r0, 0x40011400	// 8012028 <main+0x234>
	GPIO_InitStruct.Pin = S_CD_PIN;                //数据指令选择脚
 8011e3c:	b8e4      	st.w      	r7, (r14, 0x10)
	HAL_GPIO_Init(S_CD_PORT, &GPIO_InitStruct);
 8011e3e:	e3fffd53 	bsr      	0x80118e4	// 80118e4 <HAL_GPIO_Init>
	HAL_GPIO_WritePin(S_CD_PORT, S_CD_PIN, GPIO_PIN_SET);
 8011e42:	3201      	movi      	r2, 1
 8011e44:	6c5f      	mov      	r1, r7
 8011e46:	1319      	lrw      	r0, 0x40011400	// 8012028 <main+0x234>
 8011e48:	e3fffe28 	bsr      	0x8011a98	// 8011a98 <HAL_GPIO_WritePin>
	
	GPIO_InitStruct.Pin = S_RESET_PIN;             //复位脚
 8011e4c:	ea270800 	movih      	r7, 2048
	HAL_GPIO_Init(S_RESET_PORT, &GPIO_InitStruct);
 8011e50:	1904      	addi      	r1, r14, 16
 8011e52:	1316      	lrw      	r0, 0x40011400	// 8012028 <main+0x234>
	GPIO_InitStruct.Pin = S_RESET_PIN;             //复位脚
 8011e54:	b8e4      	st.w      	r7, (r14, 0x10)
	HAL_GPIO_Init(S_RESET_PORT, &GPIO_InitStruct);
 8011e56:	e3fffd47 	bsr      	0x80118e4	// 80118e4 <HAL_GPIO_Init>
	HAL_GPIO_WritePin(S_RESET_PORT, S_RESET_PIN, GPIO_PIN_RESET);
 8011e5a:	6c93      	mov      	r2, r4
 8011e5c:	6c5f      	mov      	r1, r7
 8011e5e:	1313      	lrw      	r0, 0x40011400	// 8012028 <main+0x234>
 8011e60:	e3fffe1c 	bsr      	0x8011a98	// 8011a98 <HAL_GPIO_WritePin>
	
	GPIO_InitStruct.Pin = S_FMARK_PIN;             //帧头信号
	GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
 8011e64:	3701      	movi      	r7, 1
	GPIO_InitStruct.Pin = S_FMARK_PIN;             //帧头信号
 8011e66:	ea230004 	movih      	r3, 4
	HAL_GPIO_Init(S_FMARK_PORT, &GPIO_InitStruct);
 8011e6a:	1904      	addi      	r1, r14, 16
 8011e6c:	130f      	lrw      	r0, 0x40011400	// 8012028 <main+0x234>
	GPIO_InitStruct.Pin = S_FMARK_PIN;             //帧头信号
 8011e6e:	b864      	st.w      	r3, (r14, 0x10)
	GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
 8011e70:	b8e5      	st.w      	r7, (r14, 0x14)
	HAL_GPIO_Init(S_FMARK_PORT, &GPIO_InitStruct);
 8011e72:	e3fffd39 	bsr      	0x80118e4	// 80118e4 <HAL_GPIO_Init>
}

#if ST7789_SPI
static void SPI_Init(void)
{
	hspi.Instance = SPI;
 8011e76:	130e      	lrw      	r0, 0x2000136c	// 801202c <main+0x238>
 8011e78:	ea234001 	movih      	r3, 16385
 8011e7c:	3baa      	bseti      	r3, 10
	hspi.Init.Mode = SPI_MODE_MASTER;            //设置为SPI主机模式
 8011e7e:	b0c1      	st.w      	r6, (r0, 0x4)
	hspi.Instance = SPI;
 8011e80:	b060      	st.w      	r3, (r0, 0x0)
	hspi.Init.CLKPolarity = SPI_POLARITY_HIGH;   //设置为CLK空闲时高电平  
 8011e82:	b0e2      	st.w      	r7, (r0, 0x8)
	hspi.Init.CLKPhase = SPI_PHASE_2EDGE;        //设置为第二个时钟沿捕获 
 8011e84:	b0a3      	st.w      	r5, (r0, 0xc)
	hspi.Init.NSS = SPI_NSS_SOFT;                //设置为软件CS
 8011e86:	b0a4      	st.w      	r5, (r0, 0x10)
	hspi.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_2;    //设置SPI分频速率，最快2分频 20M，详见wm_spi.h
 8011e88:	b085      	st.w      	r4, (r0, 0x14)
	hspi.Init.FirstByte = SPI_LITTLEENDIAN;
 8011e8a:	b086      	st.w      	r4, (r0, 0x18)
	
	if (HAL_SPI_Init(&hspi) != HAL_OK)
 8011e8c:	e3fffe9c 	bsr      	0x8011bc4	// 8011bc4 <HAL_SPI_Init>
 8011e90:	6d83      	mov      	r6, r0
 8011e92:	e9000003 	bez      	r0, 0x8011e98	// 8011e98 <main+0xa4>
 8011e96:	0400      	br      	0x8011e96	// 8011e96 <main+0xa2>
	LCD_Init();
 8011e98:	e00001ae 	bsr      	0x80121f4	// 80121f4 <LCD_Init>
 8011e9c:	ea900065 	lrw      	r16, 0x80618b4	// 8012030 <main+0x23c>
 8011ea0:	ea8b0065 	lrw      	r11, 0x803c0a8	// 8012034 <main+0x240>
 8011ea4:	ea8a0065 	lrw      	r10, 0x80168a8	// 8012038 <main+0x244>
 8011ea8:	1385      	lrw      	r4, 0x8014328	// 801203c <main+0x248>
		LCD_Fill(0, 0, Screen_W, Screen_H, WHITE_16B);   //显示纯色
 8011eaa:	ea05ffff 	movi      	r5, 65535
 8011eae:	3100      	movi      	r1, 0
 8011eb0:	6c07      	mov      	r0, r1
 8011eb2:	ea030140 	movi      	r3, 320
 8011eb6:	32f0      	movi      	r2, 240
 8011eb8:	b8a0      	st.w      	r5, (r14, 0x0)
 8011eba:	e0000297 	bsr      	0x80123e8	// 80123e8 <LCD_Fill>
		HAL_Delay(300);
 8011ebe:	ea00012c 	movi      	r0, 300
 8011ec2:	e3fffe75 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
		LCD_DrawRectangle(0, 0, Screen_W-1, Screen_H-1, RED_16B,BLACK_16B);  //显示矩形
 8011ec6:	ea07f800 	movi      	r7, 63488
 8011eca:	3100      	movi      	r1, 0
 8011ecc:	6c07      	mov      	r0, r1
 8011ece:	b8c1      	st.w      	r6, (r14, 0x4)
 8011ed0:	b8e0      	st.w      	r7, (r14, 0x0)
 8011ed2:	ea03013f 	movi      	r3, 319
 8011ed6:	32ef      	movi      	r2, 239
 8011ed8:	e0000312 	bsr      	0x80124fc	// 80124fc <LCD_DrawRectangle>
		tftlcd_show_font_string(10, 10, 239, 239,"0123456789ABCDEFGHIGKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*()_+/.,:" , 32, GREEN_16B, RED_16B);
 8011edc:	3320      	movi      	r3, 32
 8011ede:	ea0807e0 	movi      	r8, 2016
 8011ee2:	310a      	movi      	r1, 10
 8011ee4:	b861      	st.w      	r3, (r14, 0x4)
 8011ee6:	33ef      	movi      	r3, 239
 8011ee8:	6c8f      	mov      	r2, r3
 8011eea:	6c07      	mov      	r0, r1
 8011eec:	b8e3      	st.w      	r7, (r14, 0xc)
 8011eee:	dd0e2002 	st.w      	r8, (r14, 0x8)
 8011ef2:	de0e2000 	st.w      	r16, (r14, 0x0)
 8011ef6:	e00003fd 	bsr      	0x80126f0	// 80126f0 <tftlcd_show_font_string>
        HAL_Delay(500);
 8011efa:	ea0001f4 	movi      	r0, 500
 8011efe:	e3fffe57 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
		LCD_ShowPicture(0, 0, Screen_W, Screen_H, gImage_240320tly);    //显示ROM中图片
 8011f02:	3100      	movi      	r1, 0
 8011f04:	6c07      	mov      	r0, r1
 8011f06:	ea030140 	movi      	r3, 320
 8011f0a:	32f0      	movi      	r2, 240
 8011f0c:	dd6e2000 	st.w      	r11, (r14, 0x0)
 8011f10:	e000048a 	bsr      	0x8012824	// 8012824 <LCD_ShowPicture>
		HAL_Delay(1000);
 8011f14:	ea0003e8 	movi      	r0, 1000
 8011f18:	e3fffe4a 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
		LCD_ShowPicture(0, 0, Screen_W, Screen_H, (uint8_t*)gImage_240320logo);  //显示ROM中图片
 8011f1c:	3100      	movi      	r1, 0
 8011f1e:	6c07      	mov      	r0, r1
 8011f20:	ea030140 	movi      	r3, 320
 8011f24:	32f0      	movi      	r2, 240
 8011f26:	dd4e2000 	st.w      	r10, (r14, 0x0)
 8011f2a:	e000047d 	bsr      	0x8012824	// 8012824 <LCD_ShowPicture>
		HAL_Delay(3000);
 8011f2e:	ea000bb8 	movi      	r0, 3000
 8011f32:	e3fffe3d 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt,BLACK_16B, WHITE_16B);
 8011f36:	3100      	movi      	r1, 0
 8011f38:	ea030140 	movi      	r3, 320
 8011f3c:	32f0      	movi      	r2, 240
 8011f3e:	6c07      	mov      	r0, r1
 8011f40:	b8a2      	st.w      	r5, (r14, 0x8)
 8011f42:	b8c1      	st.w      	r6, (r14, 0x4)
 8011f44:	b880      	st.w      	r4, (r14, 0x0)
 8011f46:	e000043f 	bsr      	0x80127c4	// 80127c4 <tftlcd_bit_image>
	    HAL_Delay(500);
 8011f4a:	ea0001f4 	movi      	r0, 500
 8011f4e:	e3fffe2f 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt, RED_16B, WHITE_16B);
 8011f52:	3100      	movi      	r1, 0
 8011f54:	ea030140 	movi      	r3, 320
 8011f58:	32f0      	movi      	r2, 240
 8011f5a:	6c07      	mov      	r0, r1
 8011f5c:	b8a2      	st.w      	r5, (r14, 0x8)
 8011f5e:	b8e1      	st.w      	r7, (r14, 0x4)
 8011f60:	b880      	st.w      	r4, (r14, 0x0)
 8011f62:	e0000431 	bsr      	0x80127c4	// 80127c4 <tftlcd_bit_image>
		HAL_Delay(500);
 8011f66:	ea0001f4 	movi      	r0, 500
 8011f6a:	e3fffe21 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt, GREEN_16B, WHITE_16B);
 8011f6e:	3100      	movi      	r1, 0
 8011f70:	ea030140 	movi      	r3, 320
 8011f74:	32f0      	movi      	r2, 240
 8011f76:	6c07      	mov      	r0, r1
 8011f78:	b8a2      	st.w      	r5, (r14, 0x8)
 8011f7a:	dd0e2001 	st.w      	r8, (r14, 0x4)
 8011f7e:	b880      	st.w      	r4, (r14, 0x0)
 8011f80:	e0000422 	bsr      	0x80127c4	// 80127c4 <tftlcd_bit_image>
		HAL_Delay(500);
 8011f84:	ea0001f4 	movi      	r0, 500
 8011f88:	e3fffe12 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt, BLUE_16B, WHITE_16B);
 8011f8c:	ea09001f 	movi      	r9, 31
 8011f90:	3100      	movi      	r1, 0
 8011f92:	ea030140 	movi      	r3, 320
 8011f96:	32f0      	movi      	r2, 240
 8011f98:	6c07      	mov      	r0, r1
 8011f9a:	b8a2      	st.w      	r5, (r14, 0x8)
 8011f9c:	dd2e2001 	st.w      	r9, (r14, 0x4)
 8011fa0:	b880      	st.w      	r4, (r14, 0x0)
 8011fa2:	e0000411 	bsr      	0x80127c4	// 80127c4 <tftlcd_bit_image>
		HAL_Delay(500);
 8011fa6:	ea0001f4 	movi      	r0, 500
 8011faa:	e3fffe01 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt,WHITE_16B, BLACK_16B);
 8011fae:	3100      	movi      	r1, 0
 8011fb0:	ea030140 	movi      	r3, 320
 8011fb4:	32f0      	movi      	r2, 240
 8011fb6:	6c07      	mov      	r0, r1
 8011fb8:	b8c2      	st.w      	r6, (r14, 0x8)
 8011fba:	b8a1      	st.w      	r5, (r14, 0x4)
 8011fbc:	b880      	st.w      	r4, (r14, 0x0)
 8011fbe:	e0000403 	bsr      	0x80127c4	// 80127c4 <tftlcd_bit_image>
		HAL_Delay(500);
 8011fc2:	ea0001f4 	movi      	r0, 500
 8011fc6:	e3fffdf3 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt, RED_16B, BLACK_16B);
 8011fca:	3100      	movi      	r1, 0
 8011fcc:	ea030140 	movi      	r3, 320
 8011fd0:	32f0      	movi      	r2, 240
 8011fd2:	6c07      	mov      	r0, r1
 8011fd4:	b8c2      	st.w      	r6, (r14, 0x8)
 8011fd6:	b8e1      	st.w      	r7, (r14, 0x4)
 8011fd8:	b880      	st.w      	r4, (r14, 0x0)
 8011fda:	e00003f5 	bsr      	0x80127c4	// 80127c4 <tftlcd_bit_image>
		HAL_Delay(500);
 8011fde:	ea0001f4 	movi      	r0, 500
 8011fe2:	e3fffde5 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt, GREEN_16B, BLACK_16B);
 8011fe6:	3100      	movi      	r1, 0
 8011fe8:	ea030140 	movi      	r3, 320
 8011fec:	32f0      	movi      	r2, 240
 8011fee:	6c07      	mov      	r0, r1
 8011ff0:	b8c2      	st.w      	r6, (r14, 0x8)
 8011ff2:	dd0e2001 	st.w      	r8, (r14, 0x4)
 8011ff6:	b880      	st.w      	r4, (r14, 0x0)
 8011ff8:	e00003e6 	bsr      	0x80127c4	// 80127c4 <tftlcd_bit_image>
		HAL_Delay(500);
 8011ffc:	ea0001f4 	movi      	r0, 500
 8012000:	e3fffdd6 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt, BLUE_16B, BLACK_16B);
 8012004:	3100      	movi      	r1, 0
 8012006:	b8c2      	st.w      	r6, (r14, 0x8)
 8012008:	dd2e2001 	st.w      	r9, (r14, 0x4)
 801200c:	b880      	st.w      	r4, (r14, 0x0)
 801200e:	ea030140 	movi      	r3, 320
 8012012:	32f0      	movi      	r2, 240
 8012014:	6c07      	mov      	r0, r1
 8012016:	e00003d7 	bsr      	0x80127c4	// 80127c4 <tftlcd_bit_image>
		HAL_Delay(500);
 801201a:	ea0001f4 	movi      	r0, 500
 801201e:	e3fffdc7 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
 8012022:	0744      	br      	0x8011eaa	// 8011eaa <main+0xb6>
 8012024:	080618a8 	.long	0x080618a8
 8012028:	40011400 	.long	0x40011400
 801202c:	2000136c 	.long	0x2000136c
 8012030:	080618b4 	.long	0x080618b4
 8012034:	0803c0a8 	.long	0x0803c0a8
 8012038:	080168a8 	.long	0x080168a8
 801203c:	08014328 	.long	0x08014328

08012040 <S_Back_On>:
 ****@Remark       : 
**************************************************************************************************/
#include "st7789_serial.h"

void S_Back_On(void)
{
 8012040:	14d0      	push      	r15
	HAL_GPIO_WritePin(S_BLC_PORT, S_BLC_PIN, GPIO_PIN_SET);
 8012042:	3201      	movi      	r2, 1
 8012044:	3104      	movi      	r1, 4
 8012046:	1003      	lrw      	r0, 0x40011400	// 8012050 <S_Back_On+0x10>
 8012048:	e3fffd28 	bsr      	0x8011a98	// 8011a98 <HAL_GPIO_WritePin>
}
 801204c:	1490      	pop      	r15
 801204e:	0000      	.short	0x0000
 8012050:	40011400 	.long	0x40011400

08012054 <S_WriteReg>:
{
	while ((S_FMARK_PORT->DATA & S_FMARK_PIN) == 0);
}

void S_WriteReg(uint8_t reg)
{
 8012054:	14d1      	push      	r4, r15
 8012056:	1421      	subi      	r14, r14, 4
	S_CD_LOW;
	S_CS_LOW;
 8012058:	1090      	lrw      	r4, 0x2000136c	// 8012098 <S_WriteReg+0x44>
	S_CD_LOW;
 801205a:	3200      	movi      	r2, 0
{
 801205c:	dc0e0003 	st.b      	r0, (r14, 0x3)
	S_CD_LOW;
 8012060:	3108      	movi      	r1, 8
 8012062:	100f      	lrw      	r0, 0x40011400	// 801209c <S_WriteReg+0x48>
 8012064:	e3fffd1a 	bsr      	0x8011a98	// 8011a98 <HAL_GPIO_WritePin>
	S_CS_LOW;
 8012068:	9440      	ld.w      	r2, (r4, 0x0)
	HAL_SPI_Transmit(&hspi, &reg, 1, 100);
 801206a:	e42e0002 	addi      	r1, r14, 3
	S_CS_LOW;
 801206e:	9260      	ld.w      	r3, (r2, 0x0)
 8012070:	3b82      	bclri      	r3, 2
 8012072:	b260      	st.w      	r3, (r2, 0x0)
	HAL_SPI_Transmit(&hspi, &reg, 1, 100);
 8012074:	6c13      	mov      	r0, r4
 8012076:	3364      	movi      	r3, 100
 8012078:	3201      	movi      	r2, 1
 801207a:	e3fffdd1 	bsr      	0x8011c1c	// 8011c1c <HAL_SPI_Transmit>
	S_CS_HIGH;
 801207e:	9440      	ld.w      	r2, (r4, 0x0)
	S_CD_HIGH;
 8012080:	3108      	movi      	r1, 8
	S_CS_HIGH;
 8012082:	9260      	ld.w      	r3, (r2, 0x0)
 8012084:	ec630004 	ori      	r3, r3, 4
 8012088:	b260      	st.w      	r3, (r2, 0x0)
	S_CD_HIGH;
 801208a:	1005      	lrw      	r0, 0x40011400	// 801209c <S_WriteReg+0x48>
 801208c:	3201      	movi      	r2, 1
 801208e:	e3fffd05 	bsr      	0x8011a98	// 8011a98 <HAL_GPIO_WritePin>
}
 8012092:	1401      	addi      	r14, r14, 4
 8012094:	1491      	pop      	r4, r15
 8012096:	0000      	.short	0x0000
 8012098:	2000136c 	.long	0x2000136c
 801209c:	40011400 	.long	0x40011400

080120a0 <S_WriteData8>:

void S_WriteData8(uint8_t data)
{
 80120a0:	14d1      	push      	r4, r15
 80120a2:	1421      	subi      	r14, r14, 4
	S_CS_LOW;
 80120a4:	108b      	lrw      	r4, 0x2000136c	// 80120d0 <S_WriteData8+0x30>
	HAL_SPI_Transmit(&hspi, &data, 1, 100);
 80120a6:	e42e0002 	addi      	r1, r14, 3
	S_CS_LOW;
 80120aa:	9440      	ld.w      	r2, (r4, 0x0)
{
 80120ac:	dc0e0003 	st.b      	r0, (r14, 0x3)
	S_CS_LOW;
 80120b0:	9260      	ld.w      	r3, (r2, 0x0)
 80120b2:	3b82      	bclri      	r3, 2
 80120b4:	b260      	st.w      	r3, (r2, 0x0)
	HAL_SPI_Transmit(&hspi, &data, 1, 100);
 80120b6:	6c13      	mov      	r0, r4
 80120b8:	3364      	movi      	r3, 100
 80120ba:	3201      	movi      	r2, 1
 80120bc:	e3fffdb0 	bsr      	0x8011c1c	// 8011c1c <HAL_SPI_Transmit>
	S_CS_HIGH;
 80120c0:	9440      	ld.w      	r2, (r4, 0x0)
 80120c2:	9260      	ld.w      	r3, (r2, 0x0)
 80120c4:	ec630004 	ori      	r3, r3, 4
 80120c8:	b260      	st.w      	r3, (r2, 0x0)
}
 80120ca:	1401      	addi      	r14, r14, 4
 80120cc:	1491      	pop      	r4, r15
 80120ce:	0000      	.short	0x0000
 80120d0:	2000136c 	.long	0x2000136c

080120d4 <S_WriteData16>:

void S_WriteData16(uint16_t data)
{
 80120d4:	14d1      	push      	r4, r15
 80120d6:	1421      	subi      	r14, r14, 4
	uint8_t temp[2];
	
	temp[0] = data >> 8;
	temp[1] = data;
	S_CS_LOW;
 80120d8:	108c      	lrw      	r4, 0x2000136c	// 8012108 <S_WriteData16+0x34>
	temp[0] = data >> 8;
 80120da:	4868      	lsri      	r3, r0, 8
	S_CS_LOW;
 80120dc:	9440      	ld.w      	r2, (r4, 0x0)
	temp[1] = data;
 80120de:	dc0e0001 	st.b      	r0, (r14, 0x1)
	temp[0] = data >> 8;
 80120e2:	dc6e0000 	st.b      	r3, (r14, 0x0)
	S_CS_LOW;
 80120e6:	9260      	ld.w      	r3, (r2, 0x0)
 80120e8:	3b82      	bclri      	r3, 2
 80120ea:	b260      	st.w      	r3, (r2, 0x0)
	HAL_SPI_Transmit(&hspi, temp, 2, 100);
 80120ec:	6c7b      	mov      	r1, r14
 80120ee:	3364      	movi      	r3, 100
 80120f0:	3202      	movi      	r2, 2
 80120f2:	6c13      	mov      	r0, r4
 80120f4:	e3fffd94 	bsr      	0x8011c1c	// 8011c1c <HAL_SPI_Transmit>
	S_CS_HIGH;
 80120f8:	9440      	ld.w      	r2, (r4, 0x0)
 80120fa:	9260      	ld.w      	r3, (r2, 0x0)
 80120fc:	ec630004 	ori      	r3, r3, 4
 8012100:	b260      	st.w      	r3, (r2, 0x0)
}
 8012102:	1401      	addi      	r14, r14, 4
 8012104:	1491      	pop      	r4, r15
 8012106:	0000      	.short	0x0000
 8012108:	2000136c 	.long	0x2000136c

0801210c <S_WriteData>:
		tx_block_cnt++;
	}
}

void S_WriteData(uint8_t *data, uint32_t len)
{
 801210c:	14d1      	push      	r4, r15
	S_CS_LOW;
 801210e:	108a      	lrw      	r4, 0x2000136c	// 8012134 <S_WriteData+0x28>
 8012110:	9440      	ld.w      	r2, (r4, 0x0)
 8012112:	9260      	ld.w      	r3, (r2, 0x0)
 8012114:	3b82      	bclri      	r3, 2
 8012116:	b260      	st.w      	r3, (r2, 0x0)
	HAL_SPI_Transmit(&hspi, data, len, 1000);
 8012118:	6c87      	mov      	r2, r1
 801211a:	ea0303e8 	movi      	r3, 1000
 801211e:	6c43      	mov      	r1, r0
 8012120:	6c13      	mov      	r0, r4
 8012122:	e3fffd7d 	bsr      	0x8011c1c	// 8011c1c <HAL_SPI_Transmit>
//	HAL_SPI_Transmit_dma(&hspi, data, len);
	S_CS_HIGH;
 8012126:	9440      	ld.w      	r2, (r4, 0x0)
 8012128:	9260      	ld.w      	r3, (r2, 0x0)
 801212a:	ec630004 	ori      	r3, r3, 4
 801212e:	b260      	st.w      	r3, (r2, 0x0)
 8012130:	1491      	pop      	r4, r15
 8012132:	0000      	.short	0x0000
 8012134:	2000136c 	.long	0x2000136c

08012138 <HAL_SPI_MspInit>:
}

#if ST7789_SPI
void HAL_SPI_MspInit(SPI_HandleTypeDef* hspi)
{
	__HAL_RCC_SPI_CLK_ENABLE();
 8012138:	ea224000 	movih      	r2, 16384
 801213c:	e4420dff 	addi      	r2, r2, 3584
 8012140:	9260      	ld.w      	r3, (r2, 0x0)
 8012142:	ec630080 	ori      	r3, r3, 128
 8012146:	b260      	st.w      	r3, (r2, 0x0)
	__HAL_AFIO_REMAP_SPI_CS(S_CS_PORT, S_CS_PIN);
 8012148:	1072      	lrw      	r3, 0x40011400	// 8012190 <HAL_SPI_MspInit+0x58>
 801214a:	9344      	ld.w      	r2, (r3, 0x10)
 801214c:	ec420010 	ori      	r2, r2, 16
 8012150:	b344      	st.w      	r2, (r3, 0x10)
 8012152:	9345      	ld.w      	r2, (r3, 0x14)
 8012154:	3a84      	bclri      	r2, 4
 8012156:	b345      	st.w      	r2, (r3, 0x14)
 8012158:	9346      	ld.w      	r2, (r3, 0x18)
 801215a:	3a84      	bclri      	r2, 4
 801215c:	b346      	st.w      	r2, (r3, 0x18)
	__HAL_AFIO_REMAP_SPI_CLK(S_SCL_PORT, S_SCL_PIN);
 801215e:	9344      	ld.w      	r2, (r3, 0x10)
 8012160:	ec420002 	ori      	r2, r2, 2
 8012164:	b344      	st.w      	r2, (r3, 0x10)
 8012166:	9345      	ld.w      	r2, (r3, 0x14)
 8012168:	3a81      	bclri      	r2, 1
 801216a:	b345      	st.w      	r2, (r3, 0x14)
 801216c:	9346      	ld.w      	r2, (r3, 0x18)
 801216e:	ec420002 	ori      	r2, r2, 2
 8012172:	b346      	st.w      	r2, (r3, 0x18)
	__HAL_AFIO_REMAP_SPI_MOSI(S_SDA_PORT, S_SDA_PIN);
 8012174:	1068      	lrw      	r3, 0x40011200	// 8012194 <HAL_SPI_MspInit+0x5c>
 8012176:	9344      	ld.w      	r2, (r3, 0x10)
 8012178:	ec420080 	ori      	r2, r2, 128
 801217c:	b344      	st.w      	r2, (r3, 0x10)
 801217e:	9345      	ld.w      	r2, (r3, 0x14)
 8012180:	3a87      	bclri      	r2, 7
 8012182:	b345      	st.w      	r2, (r3, 0x14)
 8012184:	9346      	ld.w      	r2, (r3, 0x18)
 8012186:	ec420080 	ori      	r2, r2, 128
 801218a:	b346      	st.w      	r2, (r3, 0x18)
}
 801218c:	783c      	jmp      	r15
 801218e:	0000      	.short	0x0000
 8012190:	40011400 	.long	0x40011400
 8012194:	40011200 	.long	0x40011200

08012198 <CORET_IRQHandler>:

#include "wm_hal.h"

__attribute__((isr)) void CORET_IRQHandler(void)
{
 8012198:	1460      	nie
 801219a:	1462      	ipush
 801219c:	142e      	subi      	r14, r14, 56
 801219e:	d64e1c2d 	stm      	r18-r31, (r14)
 80121a2:	1428      	subi      	r14, r14, 32
 80121a4:	f4ee3400 	fstms      	fr0-fr7, (r14)
 80121a8:	14d0      	push      	r15
	uint32_t temp;
	
	temp = (*(volatile unsigned int *) (0xE000E010));
 80121aa:	1068      	lrw      	r3, 0xe000e000	// 80121c8 <CORET_IRQHandler+0x30>
 80121ac:	9364      	ld.w      	r3, (r3, 0x10)
	HAL_IncTick();
 80121ae:	e3fffcf1 	bsr      	0x8011b90	// 8011b90 <HAL_IncTick>
}
 80121b2:	d9ee2000 	ld.w      	r15, (r14, 0x0)
 80121b6:	1401      	addi      	r14, r14, 4
 80121b8:	f4ee3000 	fldms      	fr0-fr7, (r14)
 80121bc:	1408      	addi      	r14, r14, 32
 80121be:	d24e1c2d 	ldm      	r18-r31, (r14)
 80121c2:	140e      	addi      	r14, r14, 56
 80121c4:	1463      	ipop
 80121c6:	1461      	nir
 80121c8:	e000e000 	.long	0xe000e000

080121cc <LCD_WriteData>:
#if ST7789_8080
	P_WriteData16(data);
#endif
}
 void LCD_WriteData(uint8_t *data, uint32_t len)   //写数组 
{
 80121cc:	14d3      	push      	r4-r6, r15
 80121ce:	6d43      	mov      	r5, r0
 80121d0:	6d87      	mov      	r6, r1
	uint32_t t1 = 0, t2 = 0;
	
#if ST7789_SPI
	t1 = HAL_GetTick();
 80121d2:	e3fffce7 	bsr      	0x8011ba0	// 8011ba0 <HAL_GetTick>
 80121d6:	6d03      	mov      	r4, r0
	S_WriteData(data, len);
 80121d8:	6c5b      	mov      	r1, r6
 80121da:	6c17      	mov      	r0, r5
 80121dc:	e3ffff98 	bsr      	0x801210c	// 801210c <S_WriteData>
	t2 = HAL_GetTick();
 80121e0:	e3fffce0 	bsr      	0x8011ba0	// 8011ba0 <HAL_GetTick>
	printf("s_t = %d\r\n", t2 - t1);
 80121e4:	5831      	subu      	r1, r0, r4
 80121e6:	1003      	lrw      	r0, 0x8061904	// 80121f0 <LCD_WriteData+0x24>
 80121e8:	e0000ff2 	bsr      	0x80141cc	// 80141cc <wm_printf>
	t1 = HAL_GetTick();
	P_WriteData(data, len);
	t2 = HAL_GetTick();
	printf("p_t = %d\r\n", t2 - t1);
#endif
}
 80121ec:	1493      	pop      	r4-r6, r15
 80121ee:	0000      	.short	0x0000
 80121f0:	08061904 	.long	0x08061904

080121f4 <LCD_Init>:

void LCD_Init(void)       // LCD初始化
{
 80121f4:	14d0      	push      	r15
	S_RESET_LOW;
 80121f6:	3200      	movi      	r2, 0
 80121f8:	ea210800 	movih      	r1, 2048
 80121fc:	130c      	lrw      	r0, 0x40011400	// 80123ac <LCD_Init+0x1b8>
 80121fe:	e3fffc4d 	bsr      	0x8011a98	// 8011a98 <HAL_GPIO_WritePin>
	LCD_Reset_On();
	HAL_Delay(120);
 8012202:	3078      	movi      	r0, 120
 8012204:	e3fffcd4 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
	S_RESET_HIGH;
 8012208:	3201      	movi      	r2, 1
 801220a:	ea210800 	movih      	r1, 2048
 801220e:	1308      	lrw      	r0, 0x40011400	// 80123ac <LCD_Init+0x1b8>
 8012210:	e3fffc44 	bsr      	0x8011a98	// 8011a98 <HAL_GPIO_WritePin>
	LCD_Reset_Off();
	HAL_Delay(120);
 8012214:	3078      	movi      	r0, 120
 8012216:	e3fffccb 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
	S_Back_On();
 801221a:	e3ffff13 	bsr      	0x8012040	// 8012040 <S_Back_On>
	LCD_Back_On();
	HAL_Delay(100);
 801221e:	3064      	movi      	r0, 100
 8012220:	e3fffcc6 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
	S_WriteReg(reg);
 8012224:	3011      	movi      	r0, 17
 8012226:	e3ffff17 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	LCD_WriteReg(0x11);
	HAL_Delay(120);
 801222a:	3078      	movi      	r0, 120
 801222c:	e3fffcc0 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
	S_WriteReg(reg);
 8012230:	3011      	movi      	r0, 17
 8012232:	e3ffff11 	bsr      	0x8012054	// 8012054 <S_WriteReg>
#endif

#if ST7789_CTC20IPS

LCD_WriteReg(0x11);     
HAL_Delay(120);                //ms
 8012236:	3078      	movi      	r0, 120
 8012238:	e3fffcba 	bsr      	0x8011bac	// 8011bac <HAL_Delay>
	S_WriteReg(reg);
 801223c:	3036      	movi      	r0, 54
 801223e:	e3ffff0b 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData8(data);
 8012242:	3000      	movi      	r0, 0
 8012244:	e3ffff2e 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
	S_WriteReg(reg);
 8012248:	303a      	movi      	r0, 58
 801224a:	e3ffff05 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData8(data);
 801224e:	3005      	movi      	r0, 5
 8012250:	e3ffff28 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
	S_WriteReg(reg);
 8012254:	30b2      	movi      	r0, 178
 8012256:	e3fffeff 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData8(data);
 801225a:	300c      	movi      	r0, 12
 801225c:	e3ffff22 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012260:	300c      	movi      	r0, 12
 8012262:	e3ffff1f 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012266:	3000      	movi      	r0, 0
 8012268:	e3ffff1c 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 801226c:	3033      	movi      	r0, 51
 801226e:	e3ffff19 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012272:	3033      	movi      	r0, 51
 8012274:	e3ffff16 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
	S_WriteReg(reg);
 8012278:	30b7      	movi      	r0, 183
 801227a:	e3fffeed 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData8(data);
 801227e:	3075      	movi      	r0, 117
 8012280:	e3ffff10 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
	S_WriteReg(reg);
 8012284:	30bb      	movi      	r0, 187
 8012286:	e3fffee7 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData8(data);
 801228a:	3021      	movi      	r0, 33
 801228c:	e3ffff0a 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
	S_WriteReg(reg);
 8012290:	30c0      	movi      	r0, 192
 8012292:	e3fffee1 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData8(data);
 8012296:	302c      	movi      	r0, 44
 8012298:	e3ffff04 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
	S_WriteReg(reg);
 801229c:	30c2      	movi      	r0, 194
 801229e:	e3fffedb 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData8(data);
 80122a2:	3001      	movi      	r0, 1
 80122a4:	e3fffefe 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
	S_WriteReg(reg);
 80122a8:	30c3      	movi      	r0, 195
 80122aa:	e3fffed5 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData8(data);
 80122ae:	3013      	movi      	r0, 19
 80122b0:	e3fffef8 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
	S_WriteReg(reg);
 80122b4:	30c4      	movi      	r0, 196
 80122b6:	e3fffecf 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData8(data);
 80122ba:	3020      	movi      	r0, 32
 80122bc:	e3fffef2 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
	S_WriteReg(reg);
 80122c0:	30c6      	movi      	r0, 198
 80122c2:	e3fffec9 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData8(data);
 80122c6:	300f      	movi      	r0, 15
 80122c8:	e3fffeec 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
	S_WriteReg(reg);
 80122cc:	30d0      	movi      	r0, 208
 80122ce:	e3fffec3 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData8(data);
 80122d2:	30a4      	movi      	r0, 164
 80122d4:	e3fffee6 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 80122d8:	30a1      	movi      	r0, 161
 80122da:	e3fffee3 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
	S_WriteReg(reg);
 80122de:	30d6      	movi      	r0, 214
 80122e0:	e3fffeba 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData8(data);
 80122e4:	30a1      	movi      	r0, 161
 80122e6:	e3fffedd 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
	S_WriteReg(reg);
 80122ea:	30e0      	movi      	r0, 224
 80122ec:	e3fffeb4 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData8(data);
 80122f0:	3070      	movi      	r0, 112
 80122f2:	e3fffed7 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 80122f6:	3004      	movi      	r0, 4
 80122f8:	e3fffed4 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 80122fc:	300a      	movi      	r0, 10
 80122fe:	e3fffed1 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012302:	3008      	movi      	r0, 8
 8012304:	e3fffece 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012308:	3007      	movi      	r0, 7
 801230a:	e3fffecb 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 801230e:	3005      	movi      	r0, 5
 8012310:	e3fffec8 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012314:	3032      	movi      	r0, 50
 8012316:	e3fffec5 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 801231a:	3032      	movi      	r0, 50
 801231c:	e3fffec2 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012320:	3048      	movi      	r0, 72
 8012322:	e3fffebf 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012326:	3038      	movi      	r0, 56
 8012328:	e3fffebc 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 801232c:	3015      	movi      	r0, 21
 801232e:	e3fffeb9 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012332:	3015      	movi      	r0, 21
 8012334:	e3fffeb6 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012338:	302a      	movi      	r0, 42
 801233a:	e3fffeb3 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 801233e:	302e      	movi      	r0, 46
 8012340:	e3fffeb0 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
	S_WriteReg(reg);
 8012344:	30e1      	movi      	r0, 225
 8012346:	e3fffe87 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData8(data);
 801234a:	3070      	movi      	r0, 112
 801234c:	e3fffeaa 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012350:	3007      	movi      	r0, 7
 8012352:	e3fffea7 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012356:	300d      	movi      	r0, 13
 8012358:	e3fffea4 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 801235c:	3009      	movi      	r0, 9
 801235e:	e3fffea1 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012362:	3009      	movi      	r0, 9
 8012364:	e3fffe9e 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012368:	3016      	movi      	r0, 22
 801236a:	e3fffe9b 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 801236e:	3030      	movi      	r0, 48
 8012370:	e3fffe98 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012374:	3044      	movi      	r0, 68
 8012376:	e3fffe95 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 801237a:	3049      	movi      	r0, 73
 801237c:	e3fffe92 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012380:	3039      	movi      	r0, 57
 8012382:	e3fffe8f 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012386:	3016      	movi      	r0, 22
 8012388:	e3fffe8c 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 801238c:	3016      	movi      	r0, 22
 801238e:	e3fffe89 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012392:	302b      	movi      	r0, 43
 8012394:	e3fffe86 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
 8012398:	302f      	movi      	r0, 47
 801239a:	e3fffe83 	bsr      	0x80120a0	// 80120a0 <S_WriteData8>
	S_WriteReg(reg);
 801239e:	3021      	movi      	r0, 33
 80123a0:	e3fffe5a 	bsr      	0x8012054	// 8012054 <S_WriteReg>
 80123a4:	3029      	movi      	r0, 41
 80123a6:	e3fffe57 	bsr      	0x8012054	// 8012054 <S_WriteReg>

#endif



}
 80123aa:	1490      	pop      	r15
 80123ac:	40011400 	.long	0x40011400

080123b0 <Set_ST7789_GRAM_Address>:
 **** @param    {uint16_t} xe            结束X坐标
 **** @param    {uint16_t} ye            结束Y坐标
 **** @return   {*}
******************************************************************************************************/
void Set_ST7789_GRAM_Address(uint16_t xs, uint16_t ys, uint16_t xe, uint16_t ye)   
{
 80123b0:	14d4      	push      	r4-r7, r15
 80123b2:	6dc3      	mov      	r7, r0
	S_WriteReg(reg);
 80123b4:	302a      	movi      	r0, 42
{
 80123b6:	6d47      	mov      	r5, r1
 80123b8:	6d8b      	mov      	r6, r2
 80123ba:	6d0f      	mov      	r4, r3
	S_WriteReg(reg);
 80123bc:	e3fffe4c 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData16(data);
 80123c0:	6c1f      	mov      	r0, r7
 80123c2:	e3fffe89 	bsr      	0x80120d4	// 80120d4 <S_WriteData16>
 80123c6:	6c1b      	mov      	r0, r6
 80123c8:	e3fffe86 	bsr      	0x80120d4	// 80120d4 <S_WriteData16>
	S_WriteReg(reg);
 80123cc:	302b      	movi      	r0, 43
 80123ce:	e3fffe43 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	S_WriteData16(data);
 80123d2:	6c17      	mov      	r0, r5
 80123d4:	e3fffe80 	bsr      	0x80120d4	// 80120d4 <S_WriteData16>
 80123d8:	6c13      	mov      	r0, r4
 80123da:	e3fffe7d 	bsr      	0x80120d4	// 80120d4 <S_WriteData16>
	S_WriteReg(reg);
 80123de:	302c      	movi      	r0, 44
 80123e0:	e3fffe3a 	bsr      	0x8012054	// 8012054 <S_WriteReg>
	LCD_WriteData16(xe);
	LCD_WriteReg(0x2B);
	LCD_WriteData16(ys);
	LCD_WriteData16(ye);
	LCD_WriteReg(0x2C);
}
 80123e4:	1494      	pop      	r4-r7, r15
	...

080123e8 <LCD_Fill>:
 **** @param    {uint16_t} ye            结束Y坐标
 **** @param    {uint16_t} color         颜色值
 **** @return   {*}
******************************************************************************************************/
void LCD_Fill(uint16_t xs, uint16_t ys, uint16_t xe, uint16_t ye, uint16_t color)
{
 80123e8:	14d5      	push      	r4-r8, r15
 80123ea:	6e0f      	mov      	r8, r3
 80123ec:	6d4b      	mov      	r5, r2
    height = sy + height - 1;
 80123ee:	2b00      	subi      	r3, 1
    width  = sx + width - 1;
 80123f0:	2a00      	subi      	r2, 1
    height = sy + height - 1;
 80123f2:	60c4      	addu      	r3, r1
    width  = sx + width - 1;
 80123f4:	6080      	addu      	r2, r0
    Set_ST7789_GRAM_Address(sx, sy, width, height);
 80123f6:	74cd      	zexth      	r3, r3
 80123f8:	7489      	zexth      	r2, r2
{
 80123fa:	d8ce100c 	ld.h      	r6, (r14, 0x18)
    Set_ST7789_GRAM_Address(sx, sy, width, height);
 80123fe:	e3ffffd9 	bsr      	0x80123b0	// 80123b0 <Set_ST7789_GRAM_Address>
	uint16_t i, j;
	
	Set_Screen_Windows(xs, ys, xe, ye);
	for (i = 0; i < ye; i++)
 8012402:	e9080011 	bez      	r8, 0x8012424	// 8012424 <LCD_Fill+0x3c>
 8012406:	3700      	movi      	r7, 0
	{
		for (j = 0; j < xe; j++)
 8012408:	e905000a 	bez      	r5, 0x801241c	// 801241c <LCD_Fill+0x34>
 801240c:	3400      	movi      	r4, 0
 801240e:	2400      	addi      	r4, 1
	S_WriteData16(data);
 8012410:	6c1b      	mov      	r0, r6
		for (j = 0; j < xe; j++)
 8012412:	7511      	zexth      	r4, r4
	S_WriteData16(data);
 8012414:	e3fffe60 	bsr      	0x80120d4	// 80120d4 <S_WriteData16>
		for (j = 0; j < xe; j++)
 8012418:	6516      	cmpne      	r5, r4
 801241a:	0bfa      	bt      	0x801240e	// 801240e <LCD_Fill+0x26>
	for (i = 0; i < ye; i++)
 801241c:	2700      	addi      	r7, 1
 801241e:	75dd      	zexth      	r7, r7
 8012420:	65e2      	cmpne      	r8, r7
 8012422:	0bf3      	bt      	0x8012408	// 8012408 <LCD_Fill+0x20>
		{
			LCD_WriteData16(color);
		}
	}
}
 8012424:	1495      	pop      	r4-r8, r15
	...

08012428 <LCD_DrawLine>:
	LCD_Fill(xpos, ypos, 1, 1, color);
}

// 画线
void LCD_DrawLine(uint16_t xs, uint16_t ys, uint16_t xe, uint16_t ye, uint16_t color)
{
 8012428:	ebe00058 	push      	r4-r11, r15, r16-r17
 801242c:	1421      	subi      	r14, r14, 4
	uint16_t i;
	int x = 0, y = 0, dx, dy, offset;
	int stepx, stepy, nowx, nowy;
	
	dx = xe - xs;
 801242e:	c4020088 	subu      	r8, r2, r0
{
 8012432:	d94e1018 	ld.h      	r10, (r14, 0x30)
	dx = xe - xs;
 8012436:	c4004831 	lsli      	r17, r0, 0
	dy = ye - ys;
 801243a:	c4014830 	lsli      	r16, r1, 0
 801243e:	c4230089 	subu      	r9, r3, r1
	
	nowx = xs;
	nowy = ys;
	
	stepx = (dx > 0) ? 1 : ((dx == 0) ? 0 : -1);
 8012442:	e968002e 	blsz      	r8, 0x801249e	// 801249e <LCD_DrawLine+0x76>
	stepy = (dy > 0) ? 1 : ((dy == 0) ? 0 : -1);
 8012446:	e9690051 	blsz      	r9, 0x80124e8	// 80124e8 <LCD_DrawLine+0xc0>
	stepx = (dx > 0) ? 1 : ((dx == 0) ? 0 : -1);
 801244a:	ea0b0001 	movi      	r11, 1
	stepy = (dy > 0) ? 1 : ((dy == 0) ? 0 : -1);
 801244e:	dd6e2000 	st.w      	r11, (r14, 0x0)
	dx = (stepx >= 0) ? dx : -dx;
	dy = (stepy >= 0) ? dy : -dy;
	offset = (dx > dy) ? dx : dy;
 8012452:	f909cca6 	max.s32      	r6, r9, r8
	
	for (i = 0; i < (offset + 1); i++)
 8012456:	e9860021 	blz      	r6, 0x8012498	// 8012498 <LCD_DrawLine+0x70>
 801245a:	3500      	movi      	r5, 0
 801245c:	6dd7      	mov      	r7, r5
 801245e:	6d17      	mov      	r4, r5
	{
		//LCD_DrawPoint(nowx, nowy, color);
		Set_ST7789_GRAM_Address(nowx, nowy, nowx, nowy);
 8012460:	c41155e2 	zext      	r2, r17, 15, 0
 8012464:	c41055e3 	zext      	r3, r16, 15, 0
 8012468:	6c0b      	mov      	r0, r2
 801246a:	6c4f      	mov      	r1, r3
 801246c:	e3ffffa2 	bsr      	0x80123b0	// 80123b0 <Set_ST7789_GRAM_Address>
	    LCD_WriteData16(color);
		x += dx;
 8012470:	61e0      	addu      	r7, r8
	S_WriteData16(data);
 8012472:	6c2b      	mov      	r0, r10
 8012474:	e3fffe30 	bsr      	0x80120d4	// 80120d4 <S_WriteData16>
		y += dy;
		if (x > offset)
 8012478:	65d9      	cmplt      	r6, r7
		y += dy;
 801247a:	6164      	addu      	r5, r9
		if (x > offset)
 801247c:	0c04      	bf      	0x8012484	// 8012484 <LCD_DrawLine+0x5c>
		{
			x -= offset;
 801247e:	61da      	subu      	r7, r6
			nowx += stepx;
 8012480:	c5710031 	addu      	r17, r17, r11
		}
		if (y > offset)
 8012484:	6559      	cmplt      	r6, r5
 8012486:	0c05      	bf      	0x8012490	// 8012490 <LCD_DrawLine+0x68>
		{
			y -= offset;
			nowy += stepy;
 8012488:	9860      	ld.w      	r3, (r14, 0x0)
			y -= offset;
 801248a:	615a      	subu      	r5, r6
			nowy += stepy;
 801248c:	c4700030 	addu      	r16, r16, r3
	for (i = 0; i < (offset + 1); i++)
 8012490:	2400      	addi      	r4, 1
 8012492:	7511      	zexth      	r4, r4
 8012494:	6519      	cmplt      	r6, r4
 8012496:	0fe5      	bf      	0x8012460	// 8012460 <LCD_DrawLine+0x38>
		}
	}
}
 8012498:	1401      	addi      	r14, r14, 4
 801249a:	ebc00058 	pop      	r4-r11, r15, r16-r17
	stepx = (dx > 0) ? 1 : ((dx == 0) ? 0 : -1);
 801249e:	eb480000 	cmpnei      	r8, 0
 80124a2:	c400050b 	mvc      	r11
 80124a6:	3200      	movi      	r2, 0
 80124a8:	c562008b 	subu      	r11, r2, r11
	stepy = (dy > 0) ? 1 : ((dy == 0) ? 0 : -1);
 80124ac:	e9690014 	blsz      	r9, 0x80124d4	// 80124d4 <LCD_DrawLine+0xac>
 80124b0:	3301      	movi      	r3, 1
 80124b2:	b860      	st.w      	r3, (r14, 0x0)
	dx = (stepx >= 0) ? dx : -dx;
 80124b4:	e908ffcf 	bez      	r8, 0x8012452	// 8012452 <LCD_DrawLine+0x2a>
 80124b8:	3300      	movi      	r3, 0
 80124ba:	c5030088 	subu      	r8, r3, r8
 80124be:	e5631000 	subi      	r11, r3, 1
	dy = (stepy >= 0) ? dy : -dy;
 80124c2:	3300      	movi      	r3, 0
 80124c4:	2b00      	subi      	r3, 1
 80124c6:	9840      	ld.w      	r2, (r14, 0x0)
 80124c8:	64ca      	cmpne      	r2, r3
 80124ca:	0bc4      	bt      	0x8012452	// 8012452 <LCD_DrawLine+0x2a>
 80124cc:	3300      	movi      	r3, 0
 80124ce:	c5230089 	subu      	r9, r3, r9
 80124d2:	07c0      	br      	0x8012452	// 8012452 <LCD_DrawLine+0x2a>
	stepy = (dy > 0) ? 1 : ((dy == 0) ? 0 : -1);
 80124d4:	eb490000 	cmpnei      	r9, 0
 80124d8:	c4000503 	mvc      	r3
 80124dc:	5a6d      	subu      	r3, r2, r3
 80124de:	b860      	st.w      	r3, (r14, 0x0)
	dx = (stepx >= 0) ? dx : -dx;
 80124e0:	e928ffec 	bnez      	r8, 0x80124b8	// 80124b8 <LCD_DrawLine+0x90>
 80124e4:	6ee3      	mov      	r11, r8
 80124e6:	07ee      	br      	0x80124c2	// 80124c2 <LCD_DrawLine+0x9a>
	stepy = (dy > 0) ? 1 : ((dy == 0) ? 0 : -1);
 80124e8:	eb490000 	cmpnei      	r9, 0
 80124ec:	c4000503 	mvc      	r3
 80124f0:	3200      	movi      	r2, 0
 80124f2:	5a6d      	subu      	r3, r2, r3
 80124f4:	b860      	st.w      	r3, (r14, 0x0)
	stepx = (dx > 0) ? 1 : ((dx == 0) ? 0 : -1);
 80124f6:	ea0b0001 	movi      	r11, 1
 80124fa:	07e4      	br      	0x80124c2	// 80124c2 <LCD_DrawLine+0x9a>

080124fc <LCD_DrawRectangle>:

// 画矩形
void LCD_DrawRectangle(uint16_t xs, uint16_t ys, uint16_t xe, uint16_t ye, uint16_t border,uint16_t fill)
{ 
 80124fc:	14d6      	push      	r4-r9, r15
 80124fe:	1421      	subi      	r14, r14, 4
 8012500:	d90e1010 	ld.h      	r8, (r14, 0x20)
 8012504:	6d0f      	mov      	r4, r3
 8012506:	6dcb      	mov      	r7, r2
 8012508:	6d87      	mov      	r6, r1
  if(border !=Screen_Color_Alpha)
  {
	LCD_DrawLine(xs, ys, xe, ys, border);
 801250a:	6cc7      	mov      	r3, r1
 801250c:	dd0e2000 	st.w      	r8, (r14, 0x0)
{ 
 8012510:	6d43      	mov      	r5, r0
 8012512:	d92e1012 	ld.h      	r9, (r14, 0x24)
	LCD_DrawLine(xs, ys, xe, ys, border);
 8012516:	e3ffff89 	bsr      	0x8012428	// 8012428 <LCD_DrawLine>
	LCD_DrawLine(xe, ys, xe, ye, border);
 801251a:	6cd3      	mov      	r3, r4
 801251c:	6c9f      	mov      	r2, r7
 801251e:	6c5b      	mov      	r1, r6
 8012520:	6c1f      	mov      	r0, r7
 8012522:	dd0e2000 	st.w      	r8, (r14, 0x0)
 8012526:	e3ffff81 	bsr      	0x8012428	// 8012428 <LCD_DrawLine>
	LCD_DrawLine(xe, ye, xs, ye, border);
 801252a:	6cd3      	mov      	r3, r4
 801252c:	6c97      	mov      	r2, r5
 801252e:	6c53      	mov      	r1, r4
 8012530:	6c1f      	mov      	r0, r7
 8012532:	dd0e2000 	st.w      	r8, (r14, 0x0)
 8012536:	e3ffff79 	bsr      	0x8012428	// 8012428 <LCD_DrawLine>
	LCD_DrawLine(xs, ye, xs, ys, border);
 801253a:	6cdb      	mov      	r3, r6
 801253c:	6c97      	mov      	r2, r5
 801253e:	6c53      	mov      	r1, r4
 8012540:	6c17      	mov      	r0, r5
 8012542:	dd0e2000 	st.w      	r8, (r14, 0x0)
 8012546:	e3ffff71 	bsr      	0x8012428	// 8012428 <LCD_DrawLine>
	
  }
  if(fill !=Screen_Color_Alpha)
  {LCD_Fill(xs+1, ys+1, xe-1, ye-1, fill);}
 801254a:	5c63      	subi      	r3, r4, 1
 801254c:	5f43      	subi      	r2, r7, 1
 801254e:	5e22      	addi      	r1, r6, 1
 8012550:	5d02      	addi      	r0, r5, 1
 8012552:	dd2e2000 	st.w      	r9, (r14, 0x0)
 8012556:	74cd      	zexth      	r3, r3
 8012558:	7489      	zexth      	r2, r2
 801255a:	7445      	zexth      	r1, r1
 801255c:	7401      	zexth      	r0, r0
 801255e:	e3ffff45 	bsr      	0x80123e8	// 80123e8 <LCD_Fill>
}
 8012562:	1401      	addi      	r14, r14, 4
 8012564:	1496      	pop      	r4-r9, r15
	...

08012568 <tftlcd_show_char>:
 **** @param    {uint16_t} pcolor    笔颜色
 **** @param    {uint16_t} bcolor    背景颜色
 **** @return   {*}
******************************************************************************************************/
void tftlcd_show_char(uint16_t x, uint16_t y, uint8_t num, uint8_t size, uint16_t pcolor, uint16_t bcolor)
{
 8012568:	ebe00058 	push      	r4-r11, r15, r16-r17
    uint16_t csize = 0;

    //得到字体一个字符对应点阵集所占的字节数
    csize = ((uint16_t)(size / 8 + ((size / 2 % 8) ? 1 : 0))) * (size / 2);
    //得到偏移后的值
    if (size != Font_96)
 801256c:	eb430060 	cmpnei      	r3, 96
{
 8012570:	6d0b      	mov      	r4, r2
 8012572:	6e4f      	mov      	r9, r3
 8012574:	d8ae1016 	ld.h      	r5, (r14, 0x2c)
 8012578:	d8ce1018 	ld.h      	r6, (r14, 0x30)
    if (size != Font_96)
 801257c:	0c03      	bf      	0x8012582	// 8012582 <tftlcd_show_char+0x1a>
        num = num - ' ';
 801257e:	2c1f      	subi      	r4, 32
 8012580:	7510      	zextb      	r4, r4

    //超界限直接退出
    if (x > Screen_W || y > Screen_H)
 8012582:	33f0      	movi      	r3, 240
 8012584:	640c      	cmphs      	r3, r0
 8012586:	0c04      	bf      	0x801258e	// 801258e <tftlcd_show_char+0x26>
 8012588:	eb010140 	cmphsi      	r1, 321
 801258c:	0c03      	bf      	0x8012592	// 8012592 <tftlcd_show_char+0x2a>
            else
                LCD_WriteData16(bcolor);  //画背景颜色 一个点
            temp >>= 1;
        }
    }
}
 801258e:	ebc00058 	pop      	r4-r11, r15, r16-r17
    csize = ((uint16_t)(size / 8 + ((size / 2 % 8) ? 1 : 0))) * (size / 2);
 8012592:	c4294843 	lsri      	r3, r9, 1
 8012596:	748d      	zexth      	r2, r3
 8012598:	e4632007 	andi      	r3, r3, 7
 801259c:	3b40      	cmpnei      	r3, 0
 801259e:	c400050a 	mvc      	r10
 80125a2:	c4694843 	lsri      	r3, r9, 3
 80125a6:	628c      	addu      	r10, r3
 80125a8:	7e88      	mult      	r10, r2
    height = sy + height - 1;
 80125aa:	5963      	subi      	r3, r1, 1
    width  = sx + width - 1;
 80125ac:	e5801000 	subi      	r12, r0, 1
    csize = ((uint16_t)(size / 8 + ((size / 2 % 8) ? 1 : 0))) * (size / 2);
 80125b0:	76a9      	zexth      	r10, r10
    height = sy + height - 1;
 80125b2:	60e4      	addu      	r3, r9
    width  = sx + width - 1;
 80125b4:	60b0      	addu      	r2, r12
    Set_ST7789_GRAM_Address(sx, sy, width, height);
 80125b6:	74cd      	zexth      	r3, r3
 80125b8:	7489      	zexth      	r2, r2
 80125ba:	e3fffefb 	bsr      	0x80123b0	// 80123b0 <Set_ST7789_GRAM_Address>
    for (pos = 0; pos < csize; pos++)
 80125be:	e90affe8 	bez      	r10, 0x801258e	// 801258e <tftlcd_show_char+0x26>
        switch (size)
 80125c2:	eb490018 	cmpnei      	r9, 24
 80125c6:	4486      	lsli      	r4, r4, 6
 80125c8:	107f      	lrw      	r3, 0x8061910	// 8012644 <tftlcd_show_char+0xdc>
 80125ca:	c4640028 	addu      	r8, r4, r3
    for (pos = 0; pos < csize; pos++)
 80125ce:	3700      	movi      	r7, 0
                n = 8;
 80125d0:	ea110004 	movi      	r17, 4
        switch (size)
 80125d4:	0c2b      	bf      	0x801262a	// 801262a <tftlcd_show_char+0xc2>
 80125d6:	eb490020 	cmpnei      	r9, 32
 80125da:	0831      	bt      	0x801263c	// 801263c <tftlcd_show_char+0xd4>
            temp = ascii_3216[num][pos];
 80125dc:	da080000 	ld.b      	r16, (r8, 0x0)
            n    = 8;
 80125e0:	3408      	movi      	r4, 8
        for (t = 0; t < n; t++)
 80125e2:	ea0b0000 	movi      	r11, 0
 80125e6:	040b      	br      	0x80125fc	// 80125fc <tftlcd_show_char+0x94>
	S_WriteData16(data);
 80125e8:	6c17      	mov      	r0, r5
 80125ea:	e3fffd75 	bsr      	0x80120d4	// 80120d4 <S_WriteData16>
        for (t = 0; t < n; t++)
 80125ee:	e46b0000 	addi      	r3, r11, 1
 80125f2:	76cc      	zextb      	r11, r3
 80125f4:	66d2      	cmpne      	r4, r11
            temp >>= 1;
 80125f6:	c4304850 	lsri      	r16, r16, 1
        for (t = 0; t < n; t++)
 80125fa:	0c0f      	bf      	0x8012618	// 8012618 <tftlcd_show_char+0xb0>
            if (temp & 0x01)
 80125fc:	e4302001 	andi      	r1, r16, 1
 8012600:	e921fff4 	bnez      	r1, 0x80125e8	// 80125e8 <tftlcd_show_char+0x80>
	S_WriteData16(data);
 8012604:	6c1b      	mov      	r0, r6
 8012606:	e3fffd67 	bsr      	0x80120d4	// 80120d4 <S_WriteData16>
        for (t = 0; t < n; t++)
 801260a:	e46b0000 	addi      	r3, r11, 1
 801260e:	76cc      	zextb      	r11, r3
 8012610:	66d2      	cmpne      	r4, r11
            temp >>= 1;
 8012612:	c4304850 	lsri      	r16, r16, 1
        for (t = 0; t < n; t++)
 8012616:	0bf3      	bt      	0x80125fc	// 80125fc <tftlcd_show_char+0x94>
    for (pos = 0; pos < csize; pos++)
 8012618:	2700      	addi      	r7, 1
 801261a:	75dd      	zexth      	r7, r7
 801261c:	65ea      	cmpne      	r10, r7
 801261e:	e5080000 	addi      	r8, r8, 1
 8012622:	0fb6      	bf      	0x801258e	// 801258e <tftlcd_show_char+0x26>
        switch (size)
 8012624:	eb490018 	cmpnei      	r9, 24
 8012628:	0bd7      	bt      	0x80125d6	// 80125d6 <tftlcd_show_char+0x6e>
            if (pos % 2)
 801262a:	e4672001 	andi      	r3, r7, 1
                n = 8;
 801262e:	3b40      	cmpnei      	r3, 0
 8012630:	3408      	movi      	r4, 8
 8012632:	c4910c40 	inct      	r4, r17, 0
 8012636:	ea1000ff 	movi      	r16, 255
 801263a:	07d4      	br      	0x80125e2	// 80125e2 <tftlcd_show_char+0x7a>
            n = 8;
 801263c:	3408      	movi      	r4, 8
            temp = 0XFF;
 801263e:	ea1000ff 	movi      	r16, 255
 8012642:	07d0      	br      	0x80125e2	// 80125e2 <tftlcd_show_char+0x7a>
 8012644:	08061910 	.long	0x08061910

08012648 <tftlcd_show_font>:
 **** @param    {uint16_t} pcolor    笔颜色
 **** @param    {uint16_t} bcolor    背景颜色
 **** @return   {*}
******************************************************************************************************/
void tftlcd_show_font(uint16_t x, uint16_t y, uint8_t *font, uint8_t size, uint16_t pcolor, uint16_t bcolor)
{
 8012648:	14d6      	push      	r4-r9, r15
 801264a:	e5ce11ff 	subi      	r14, r14, 512
 801264e:	6d43      	mov      	r5, r0

    //得到字体一个字符对应点阵集所占的字节数
    csize = ((uint16_t)(size / 8 + ((size % 8) ? 1 : 0))) * size;

    //超界限直接退出
    if (x > Screen_W || y > Screen_H)
 8012650:	eb0500f0 	cmphsi      	r5, 241
{
 8012654:	6e07      	mov      	r8, r1
 8012656:	6c0b      	mov      	r0, r2
 8012658:	d8ce110e 	ld.h      	r6, (r14, 0x21c)
 801265c:	d8ee1110 	ld.h      	r7, (r14, 0x220)
    if (x > Screen_W || y > Screen_H)
 8012660:	0804      	bt      	0x8012668	// 8012668 <tftlcd_show_font+0x20>
 8012662:	eb010140 	cmphsi      	r1, 321
 8012666:	0c04      	bf      	0x801266e	// 801266e <tftlcd_show_font+0x26>
            else
                LCD_WriteData16(bcolor);  //画背景颜色 一个点
            temp >>= 1;
        }
    }
}
 8012668:	e5ce01ff 	addi      	r14, r14, 512
 801266c:	1496      	pop      	r4-r9, r15
    csize = ((uint16_t)(size / 8 + ((size % 8) ? 1 : 0))) * size;
 801266e:	e4432007 	andi      	r2, r3, 7
 8012672:	3a40      	cmpnei      	r2, 0
 8012674:	c4000504 	mvc      	r4
 8012678:	4b43      	lsri      	r2, r3, 3
 801267a:	764d      	zexth      	r9, r3
 801267c:	6108      	addu      	r4, r2
    font_get_chinese_characters_array(font, ascii_font, size);
 801267e:	6c7b      	mov      	r1, r14
 8012680:	6c8f      	mov      	r2, r3
 8012682:	e00000e5 	bsr      	0x801284c	// 801284c <font_get_chinese_characters_array>
    csize = ((uint16_t)(size / 8 + ((size % 8) ? 1 : 0))) * size;
 8012686:	7d24      	mult      	r4, r9
    height = sy + height - 1;
 8012688:	e4681000 	subi      	r3, r8, 1
    width  = sx + width - 1;
 801268c:	5d43      	subi      	r2, r5, 1
    csize = ((uint16_t)(size / 8 + ((size % 8) ? 1 : 0))) * size;
 801268e:	7511      	zexth      	r4, r4
    height = sy + height - 1;
 8012690:	60e4      	addu      	r3, r9
    width  = sx + width - 1;
 8012692:	60a4      	addu      	r2, r9
    Set_ST7789_GRAM_Address(sx, sy, width, height);
 8012694:	74cd      	zexth      	r3, r3
 8012696:	7489      	zexth      	r2, r2
 8012698:	6c63      	mov      	r1, r8
 801269a:	6c17      	mov      	r0, r5
 801269c:	e3fffe8a 	bsr      	0x80123b0	// 80123b0 <Set_ST7789_GRAM_Address>
    for (pos = 0; pos < csize; pos++)
 80126a0:	e904ffe4 	bez      	r4, 0x8012668	// 8012668 <tftlcd_show_font+0x20>
 80126a4:	e5241000 	subi      	r9, r4, 1
 80126a8:	7665      	zexth      	r9, r9
 80126aa:	e5290000 	addi      	r9, r9, 1
 80126ae:	6e3b      	mov      	r8, r14
 80126b0:	6278      	addu      	r9, r14
        temp = ascii_font[pos];
 80126b2:	d8a80000 	ld.b      	r5, (r8, 0x0)
 80126b6:	3408      	movi      	r4, 8
 80126b8:	0409      	br      	0x80126ca	// 80126ca <tftlcd_show_font+0x82>
 80126ba:	2c00      	subi      	r4, 1
 80126bc:	7510      	zextb      	r4, r4
	S_WriteData16(data);
 80126be:	6c1b      	mov      	r0, r6
 80126c0:	e3fffd0a 	bsr      	0x80120d4	// 80120d4 <S_WriteData16>
            temp >>= 1;
 80126c4:	4da1      	lsri      	r5, r5, 1
        for (t = 0; t < 8; t++)
 80126c6:	e904000e 	bez      	r4, 0x80126e2	// 80126e2 <tftlcd_show_font+0x9a>
            if (temp & 0x01)
 80126ca:	e4652001 	andi      	r3, r5, 1
 80126ce:	e923fff6 	bnez      	r3, 0x80126ba	// 80126ba <tftlcd_show_font+0x72>
 80126d2:	2c00      	subi      	r4, 1
 80126d4:	7510      	zextb      	r4, r4
	S_WriteData16(data);
 80126d6:	6c1f      	mov      	r0, r7
 80126d8:	e3fffcfe 	bsr      	0x80120d4	// 80120d4 <S_WriteData16>
            temp >>= 1;
 80126dc:	4da1      	lsri      	r5, r5, 1
        for (t = 0; t < 8; t++)
 80126de:	e924fff6 	bnez      	r4, 0x80126ca	// 80126ca <tftlcd_show_font+0x82>
 80126e2:	e5080000 	addi      	r8, r8, 1
    for (pos = 0; pos < csize; pos++)
 80126e6:	6662      	cmpne      	r8, r9
 80126e8:	0be5      	bt      	0x80126b2	// 80126b2 <tftlcd_show_font+0x6a>
}
 80126ea:	e5ce01ff 	addi      	r14, r14, 512
 80126ee:	1496      	pop      	r4-r9, r15

080126f0 <tftlcd_show_font_string>:
 **** @param    {uint16_t} pcolor    笔颜色
 **** @param    {uint16_t} bcolor    背景颜色
 **** @return   {*}
******************************************************************************************************/
void tftlcd_show_font_string(uint16_t x, uint16_t y, uint16_t width, uint16_t height, char *str, uint8_t size, uint16_t pcolor, uint16_t bcolor)
{
 80126f0:	ebe00058 	push      	r4-r11, r15, r16-r17
 80126f4:	1424      	subi      	r14, r14, 16
 80126f6:	d90e0040 	ld.b      	r8, (r14, 0x40)
 80126fa:	6dc3      	mov      	r7, r0
            x += size;  //下一个汉字偏移
        }
        else  //字符
        {
            //字符
            if (x > (x0 + width - size / 2))  //换行
 80126fc:	c428484b 	lsri      	r11, r8, 1
 8012700:	c5620080 	subu      	r0, r2, r11
            {
                y += size;
                x = x0;
            }
            if (y > (y0 + height - size))
 8012704:	60c4      	addu      	r3, r1
            if (x > (x0 + width - size))  //换行
 8012706:	609c      	addu      	r2, r7
            if (x > (x0 + width - size / 2))  //换行
 8012708:	601c      	addu      	r0, r7
            if (y > (y0 + height - size))
 801270a:	c5030085 	subu      	r5, r3, r8
            if (x > (x0 + width - size))  //换行
 801270e:	c5020083 	subu      	r3, r2, r8
{
 8012712:	da0e200f 	ld.w      	r16, (r14, 0x3c)
 8012716:	d94e1022 	ld.h      	r10, (r14, 0x44)
 801271a:	d92e1024 	ld.h      	r9, (r14, 0x48)
            if (x > (x0 + width - size / 2))  //换行
 801271e:	b802      	st.w      	r0, (r14, 0x8)
                str++;
            }
            else
                tftlcd_show_char(x, y, *str, size, pcolor, bcolor);  //有效部分写入
            str++;
            x += size / 2;  //字符,为全字的一半
 8012720:	76ed      	zexth      	r11, r11
    while (*str != 0)  //数据未结束
 8012722:	c4014831 	lsli      	r17, r1, 0
 8012726:	6d1f      	mov      	r4, r7
        if (*str > (char)0x80)
 8012728:	3680      	movi      	r6, 128
            if (x > (x0 + width - size))  //换行
 801272a:	b863      	st.w      	r3, (r14, 0xc)
    while (*str != 0)  //数据未结束
 801272c:	d8500000 	ld.b      	r2, (r16, 0x0)
 8012730:	e9020023 	bez      	r2, 0x8012776	// 8012776 <tftlcd_show_font_string+0x86>
        if (*str > (char)0x80)
 8012734:	6498      	cmphs      	r6, r2
 8012736:	0823      	bt      	0x801277c	// 801277c <tftlcd_show_font_string+0x8c>
            if (x > (x0 + width - size))  //换行
 8012738:	9863      	ld.w      	r3, (r14, 0xc)
 801273a:	650d      	cmplt      	r3, r4
 801273c:	0c06      	bf      	0x8012748	// 8012748 <tftlcd_show_font_string+0x58>
                y += size;
 801273e:	c5110031 	addu      	r17, r17, r8
 8012742:	c41155f1 	zext      	r17, r17, 15, 0
                x = x0;
 8012746:	6d1f      	mov      	r4, r7
            if (y > (y0 + height - size))
 8012748:	c6250440 	cmplt      	r5, r17
 801274c:	0815      	bt      	0x8012776	// 8012776 <tftlcd_show_font_string+0x86>
            tftlcd_show_font(x, y, (uint8_t *)str, size, pcolor, bcolor);  //显示这个汉字,空心显示
 801274e:	c4104822 	lsli      	r2, r16, 0
            str += 2;
 8012752:	e6100001 	addi      	r16, r16, 2
            tftlcd_show_font(x, y, (uint8_t *)str, size, pcolor, bcolor);  //显示这个汉字,空心显示
 8012756:	6c13      	mov      	r0, r4
 8012758:	dd2e2001 	st.w      	r9, (r14, 0x4)
 801275c:	dd4e2000 	st.w      	r10, (r14, 0x0)
 8012760:	6ce3      	mov      	r3, r8
 8012762:	c4114821 	lsli      	r1, r17, 0
 8012766:	e3ffff71 	bsr      	0x8012648	// 8012648 <tftlcd_show_font>
    while (*str != 0)  //数据未结束
 801276a:	d8500000 	ld.b      	r2, (r16, 0x0)
            x += size;  //下一个汉字偏移
 801276e:	6120      	addu      	r4, r8
 8012770:	7511      	zexth      	r4, r4
    while (*str != 0)  //数据未结束
 8012772:	e922ffe1 	bnez      	r2, 0x8012734	// 8012734 <tftlcd_show_font_string+0x44>
        }
    }
}
 8012776:	1404      	addi      	r14, r14, 16
 8012778:	ebc00058 	pop      	r4-r11, r15, r16-r17
            if (x > (x0 + width - size / 2))  //换行
 801277c:	9862      	ld.w      	r3, (r14, 0x8)
 801277e:	650d      	cmplt      	r3, r4
 8012780:	0c06      	bf      	0x801278c	// 801278c <tftlcd_show_font_string+0x9c>
                y += size;
 8012782:	c5110031 	addu      	r17, r17, r8
 8012786:	c41155f1 	zext      	r17, r17, 15, 0
                x = x0;
 801278a:	6d1f      	mov      	r4, r7
            if (y > (y0 + height - size))
 801278c:	c6250440 	cmplt      	r5, r17
 8012790:	0bf3      	bt      	0x8012776	// 8012776 <tftlcd_show_font_string+0x86>
            if (*str == 13)  //换行符号
 8012792:	3a4d      	cmpnei      	r2, 13
 8012794:	080d      	bt      	0x80127ae	// 80127ae <tftlcd_show_font_string+0xbe>
                y += size;
 8012796:	c5110031 	addu      	r17, r17, r8
 801279a:	c41155f1 	zext      	r17, r17, 15, 0
                str++;
 801279e:	e6100000 	addi      	r16, r16, 1
                x = x0;
 80127a2:	6d1f      	mov      	r4, r7
            x += size / 2;  //字符,为全字的一半
 80127a4:	612c      	addu      	r4, r11
            str++;
 80127a6:	e6100000 	addi      	r16, r16, 1
            x += size / 2;  //字符,为全字的一半
 80127aa:	7511      	zexth      	r4, r4
 80127ac:	07c0      	br      	0x801272c	// 801272c <tftlcd_show_font_string+0x3c>
                tftlcd_show_char(x, y, *str, size, pcolor, bcolor);  //有效部分写入
 80127ae:	dd2e2001 	st.w      	r9, (r14, 0x4)
 80127b2:	dd4e2000 	st.w      	r10, (r14, 0x0)
 80127b6:	6ce3      	mov      	r3, r8
 80127b8:	c4114821 	lsli      	r1, r17, 0
 80127bc:	6c13      	mov      	r0, r4
 80127be:	e3fffed5 	bsr      	0x8012568	// 8012568 <tftlcd_show_char>
 80127c2:	07f1      	br      	0x80127a4	// 80127a4 <tftlcd_show_font_string+0xb4>

080127c4 <tftlcd_bit_image>:
 **** @param    {uint16_t} pcolor    笔颜色
 **** @param    {uint16_t} bcolor    背景颜色
 **** @return   {*}
******************************************************************************************************/
void tftlcd_bit_image(uint16_t x, uint16_t y, uint16_t width, uint16_t height, uint8_t *pic, uint16_t pcolor, uint16_t bcolor)
{
 80127c4:	14d6      	push      	r4-r9, r15
    height = sy + height - 1;
 80127c6:	e5811000 	subi      	r12, r1, 1
    uint32_t pos, num, i;
    uint8_t temp;

    num = (uint32_t)width * height / 8;
 80127ca:	c4628429 	mult      	r9, r2, r3
    height = sy + height - 1;
 80127ce:	60f0      	addu      	r3, r12
    width  = sx + width - 1;
 80127d0:	e5801000 	subi      	r12, r0, 1
    num = (uint32_t)width * height / 8;
 80127d4:	c4694849 	lsri      	r9, r9, 3
    width  = sx + width - 1;
 80127d8:	60b0      	addu      	r2, r12
    Set_ST7789_GRAM_Address(sx, sy, width, height);
 80127da:	74cd      	zexth      	r3, r3
 80127dc:	7489      	zexth      	r2, r2
{
 80127de:	98c7      	ld.w      	r6, (r14, 0x1c)
 80127e0:	d8ee1010 	ld.h      	r7, (r14, 0x20)
 80127e4:	d90e1012 	ld.h      	r8, (r14, 0x24)
    Set_ST7789_GRAM_Address(sx, sy, width, height);
 80127e8:	e3fffde4 	bsr      	0x80123b0	// 80123b0 <Set_ST7789_GRAM_Address>

    //设置窗口
    Set_Screen_Windows(x, y, width, height);

    for (pos = 0; pos < num; pos++)
 80127ec:	e909001b 	bez      	r9, 0x8012822	// 8012822 <tftlcd_bit_image+0x5e>
 80127f0:	6258      	addu      	r9, r6
    {
        temp = *pic;
 80127f2:	86a0      	ld.b      	r5, (r6, 0x0)
 80127f4:	3408      	movi      	r4, 8
 80127f6:	0408      	br      	0x8012806	// 8012806 <tftlcd_bit_image+0x42>
	S_WriteData16(data);
 80127f8:	6c1f      	mov      	r0, r7
 80127fa:	2c00      	subi      	r4, 1
 80127fc:	e3fffc6c 	bsr      	0x80120d4	// 80120d4 <S_WriteData16>
            //从低位开始
            if (temp & 0x01)
                LCD_WriteData16(pcolor);  //画字体颜色 一个点
            else
                LCD_WriteData16(bcolor);  //画背景颜色 一个点
            temp >>= 1;
 8012800:	4da1      	lsri      	r5, r5, 1
        for (i = 0; i < 8; i++)
 8012802:	e904000d 	bez      	r4, 0x801281c	// 801281c <tftlcd_bit_image+0x58>
            if (temp & 0x01)
 8012806:	e4652001 	andi      	r3, r5, 1
 801280a:	e923fff7 	bnez      	r3, 0x80127f8	// 80127f8 <tftlcd_bit_image+0x34>
	S_WriteData16(data);
 801280e:	6c23      	mov      	r0, r8
 8012810:	2c00      	subi      	r4, 1
 8012812:	e3fffc61 	bsr      	0x80120d4	// 80120d4 <S_WriteData16>
            temp >>= 1;
 8012816:	4da1      	lsri      	r5, r5, 1
        for (i = 0; i < 8; i++)
 8012818:	e924fff7 	bnez      	r4, 0x8012806	// 8012806 <tftlcd_bit_image+0x42>
        }

        pic++;
 801281c:	2600      	addi      	r6, 1
    for (pos = 0; pos < num; pos++)
 801281e:	665a      	cmpne      	r6, r9
 8012820:	0be9      	bt      	0x80127f2	// 80127f2 <tftlcd_bit_image+0x2e>
    }
}
 8012822:	1496      	pop      	r4-r9, r15

08012824 <LCD_ShowPicture>:



// 显示图片
void LCD_ShowPicture(uint16_t x, uint16_t y, uint16_t length, uint16_t width,  uint8_t *data)
{
 8012824:	14d3      	push      	r4-r6, r15
 8012826:	6d4f      	mov      	r5, r3
 8012828:	9864      	ld.w      	r3, (r14, 0x10)
 801282a:	6d0b      	mov      	r4, r2
 801282c:	6d8f      	mov      	r6, r3
    width  = sx + width - 1;
 801282e:	2a00      	subi      	r2, 1
    height = sy + height - 1;
 8012830:	5d63      	subi      	r3, r5, 1
 8012832:	60c4      	addu      	r3, r1
    width  = sx + width - 1;
 8012834:	6080      	addu      	r2, r0
    Set_ST7789_GRAM_Address(sx, sy, width, height);
 8012836:	74cd      	zexth      	r3, r3
 8012838:	7489      	zexth      	r2, r2
 801283a:	e3fffdbb 	bsr      	0x80123b0	// 80123b0 <Set_ST7789_GRAM_Address>
	
	Set_Screen_Windows(x, y, length, width);
	LCD_WriteData(data, length * width * 2);
 801283e:	c4a48421 	mult      	r1, r4, r5
 8012842:	4121      	lsli      	r1, r1, 1
 8012844:	6c1b      	mov      	r0, r6
 8012846:	e3fffcc3 	bsr      	0x80121cc	// 80121cc <LCD_WriteData>
}
 801284a:	1493      	pop      	r4-r6, r15

0801284c <font_get_chinese_characters_array>:
void font_get_chinese_characters_array(uint8_t *font, uint8_t *buff, uint8_t size)
{
    uint16_t length = 0;
    uint16_t i, j;

    switch (size)
 801284c:	3a58      	cmpnei      	r2, 24
 801284e:	0c3f      	bf      	0x80128cc	// 80128cc <font_get_chinese_characters_array+0x80>
 8012850:	3a18      	cmphsi      	r2, 25
 8012852:	0c33      	bf      	0x80128b8	// 80128b8 <font_get_chinese_characters_array+0x6c>
 8012854:	eb420020 	cmpnei      	r2, 32
 8012858:	0c0d      	bf      	0x8012872	// 8012872 <font_get_chinese_characters_array+0x26>
 801285a:	eb420030 	cmpnei      	r2, 48
 801285e:	0809      	bt      	0x8012870	// 8012870 <font_get_chinese_characters_array+0x24>
                return;
            }
        }
#endif
        for (j = 0; j < 288; j++)
            *buff++ = 0XFF;
 8012860:	3200      	movi      	r2, 0
 8012862:	2a00      	subi      	r2, 1
 8012864:	ea030120 	movi      	r3, 288
 8012868:	d4018002 	stbi.b      	r2, (r1)
        for (j = 0; j < 288; j++)
 801286c:	e823fffe 	bnezad      	r3, 0x8012868	// 8012868 <font_get_chinese_characters_array+0x1c>
#endif

    default:
        break;
    }
}
 8012870:	783c      	jmp      	r15
 8012872:	d9a00000 	ld.b      	r13, (r0, 0x0)
 8012876:	107e      	lrw      	r3, 0x80630d1	// 80128ec <font_get_chinese_characters_array+0xa0>
    switch (size)
 8012878:	3200      	movi      	r2, 0
 801287a:	ea0c00e4 	movi      	r12, 228
 801287e:	0407      	br      	0x801288c	// 801288c <font_get_chinese_characters_array+0x40>
 8012880:	2200      	addi      	r2, 1
        for (i = 0; i < length; i++)
 8012882:	3a4a      	cmpnei      	r2, 10
 8012884:	0c2c      	bf      	0x80128dc	// 80128dc <font_get_chinese_characters_array+0x90>
 8012886:	d9830081 	ld.b      	r12, (r3, 0x81)
 801288a:	2381      	addi      	r3, 130
            if ((*font == font_32_array[i].font[0]) && (*(font + 1) == font_32_array[i].font[1]))
 801288c:	6772      	cmpne      	r12, r13
 801288e:	0bf9      	bt      	0x8012880	// 8012880 <font_get_chinese_characters_array+0x34>
 8012890:	da400001 	ld.b      	r18, (r0, 0x1)
 8012894:	d9830000 	ld.b      	r12, (r3, 0x0)
 8012898:	c5920480 	cmpne      	r18, r12
 801289c:	0bf2      	bt      	0x8012880	// 8012880 <font_get_chinese_characters_array+0x34>
 801289e:	6cc7      	mov      	r3, r1
 80128a0:	3182      	movi      	r1, 130
 80128a2:	7c84      	mult      	r2, r1
 80128a4:	1033      	lrw      	r1, 0x80630d2	// 80128f0 <font_get_chinese_characters_array+0xa4>
 80128a6:	6084      	addu      	r2, r1
 80128a8:	3180      	movi      	r1, 128
                    *buff++ = font_32_array[i].array[j];
 80128aa:	d0028000 	ldbi.b      	r0, (r2)
 80128ae:	d4038000 	stbi.b      	r0, (r3)
                for (j = 0; j < 128; j++)
 80128b2:	e821fffc 	bnezad      	r1, 0x80128aa	// 80128aa <font_get_chinese_characters_array+0x5e>
 80128b6:	07dd      	br      	0x8012870	// 8012870 <font_get_chinese_characters_array+0x24>
    switch (size)
 80128b8:	3a50      	cmpnei      	r2, 16
 80128ba:	0bdb      	bt      	0x8012870	// 8012870 <font_get_chinese_characters_array+0x24>
            *buff++ = 0XFF;
 80128bc:	3200      	movi      	r2, 0
 80128be:	2a00      	subi      	r2, 1
 80128c0:	3320      	movi      	r3, 32
 80128c2:	d4018002 	stbi.b      	r2, (r1)
        for (j = 0; j < 32; j++)
 80128c6:	e823fffe 	bnezad      	r3, 0x80128c2	// 80128c2 <font_get_chinese_characters_array+0x76>
}
 80128ca:	783c      	jmp      	r15
            *buff++ = 0XFF;
 80128cc:	3200      	movi      	r2, 0
 80128ce:	2a00      	subi      	r2, 1
 80128d0:	3348      	movi      	r3, 72
 80128d2:	d4018002 	stbi.b      	r2, (r1)
        for (j = 0; j < 72; j++)
 80128d6:	e823fffe 	bnezad      	r3, 0x80128d2	// 80128d2 <font_get_chinese_characters_array+0x86>
}
 80128da:	783c      	jmp      	r15
            *buff++ = 0XFF;
 80128dc:	3200      	movi      	r2, 0
 80128de:	2a00      	subi      	r2, 1
 80128e0:	3380      	movi      	r3, 128
 80128e2:	d4018002 	stbi.b      	r2, (r1)
        for (j = 0; j < 128; j++)
 80128e6:	e823fffe 	bnezad      	r3, 0x80128e2	// 80128e2 <font_get_chinese_characters_array+0x96>
}
 80128ea:	783c      	jmp      	r15
 80128ec:	080630d1 	.long	0x080630d1
 80128f0:	080630d2 	.long	0x080630d2

080128f4 <SystemInit>:
  \details Writes the given value to the VBR Register.
  \param [in]    vbr  VBR Register value to set
 */
__ALWAYS_STATIC_INLINE void __set_VBR(uint32_t vbr)
{
    __ASM volatile("mtcr %0, vbr" : : "r"(vbr));
 80128f4:	106a      	lrw      	r3, 0x20000000	// 801291c <SystemInit+0x28>
 80128f6:	c0036421 	mtcr      	r3, cr<1, 0>
 */
__ALWAYS_STATIC_INLINE uint32_t __get_CHR(void)
{
    uint32_t result;

    __ASM volatile("mfcr %0, cr<31, 0>\n" :"=r"(result));
 80128fa:	c01f6023 	mfcr      	r3, cr<31, 0>
    __set_Int_SP((uint32_t)&g_top_irqstack);
    __set_CHR(__get_CHR() | CHR_ISE_Msk);
    VIC->TSPR = 0xFF;
#endif

    __set_CHR(__get_CHR() | CHR_IAE_Msk);
 80128fe:	ec630010 	ori      	r3, r3, 16
  \details Assigns the given value to the CHR.
  \param [in]    chr  CHR value to set
 */
__ALWAYS_STATIC_INLINE void __set_CHR(uint32_t chr)
{
    __ASM volatile("mtcr %0, cr<31, 0>\n" : : "r"(chr));
 8012902:	c003643f 	mtcr      	r3, cr<31, 0>

    /* Clear active and pending IRQ */
    VIC->IABR[0] = 0x0;
 8012906:	1047      	lrw      	r2, 0xe000e100	// 8012920 <SystemInit+0x2c>
 8012908:	3300      	movi      	r3, 0
 801290a:	dc622080 	st.w      	r3, (r2, 0x200)
    VIC->ICPR[0] = 0xFFFFFFFF;
 801290e:	2b00      	subi      	r3, 1
 8012910:	dc622060 	st.w      	r3, (r2, 0x180)
  \details Enables interrupts and exceptions by setting the IE-bit and EE-bit in the PSR.
           Can only be executed in Privileged modes.
 */
__ALWAYS_STATIC_INLINE void __enable_excp_irq(void)
{
    __ASM volatile("psrset ee, ie");
 8012914:	c1807420 	psrset      	ee, ie

#ifdef CONFIG_KERNEL_NONE
    __enable_excp_irq();
#endif
}
 8012918:	783c      	jmp      	r15
 801291a:	0000      	.short	0x0000
 801291c:	20000000 	.long	0x20000000
 8012920:	e000e100 	.long	0xe000e100

08012924 <trap_c>:
#include <stdio.h>
#include <stdlib.h>
#include <csi_config.h>

void trap_c(uint32_t *regs)
{
 8012924:	14d4      	push      	r4-r7, r15
 8012926:	6d43      	mov      	r5, r0
    int i;
    uint32_t vec = 0;
    asm volatile(
 8012928:	c0006021 	mfcr      	r1, cr<0, 0>
 801292c:	4930      	lsri      	r1, r1, 16
 801292e:	7446      	sextb      	r1, r1
        "mfcr    %0, psr \n"
        "lsri    %0, 16 \n"
        "sextb   %0 \n"
        :"=r"(vec):);
    //while (1);
    printf("CPU Exception : %u", vec);
 8012930:	1018      	lrw      	r0, 0x80635e4	// 8012990 <trap_c+0x6c>
 8012932:	e0000c4d 	bsr      	0x80141cc	// 80141cc <wm_printf>
    printf("\n");
 8012936:	300a      	movi      	r0, 10
 8012938:	e3fff790 	bsr      	0x8011858	// 8011858 <__GI_putchar>

    for (i = 0; i < 16; i++) {
        printf("r%d: %08x\t", i, regs[i]);
 801293c:	9540      	ld.w      	r2, (r5, 0x0)
 801293e:	3100      	movi      	r1, 0
 8012940:	1015      	lrw      	r0, 0x80635f8	// 8012994 <trap_c+0x70>
 8012942:	e0000c45 	bsr      	0x80141cc	// 80141cc <wm_printf>
    for (i = 0; i < 16; i++) {
 8012946:	3400      	movi      	r4, 0
        printf("r%d: %08x\t", i, regs[i]);
 8012948:	10f3      	lrw      	r7, 0x80635f8	// 8012994 <trap_c+0x70>

        if ((i % 5) == 4) {
 801294a:	3605      	movi      	r6, 5
    for (i = 0; i < 16; i++) {
 801294c:	2400      	addi      	r4, 1
 801294e:	3c50      	cmpnei      	r4, 16
 8012950:	0c13      	bf      	0x8012976	// 8012976 <trap_c+0x52>
        printf("r%d: %08x\t", i, regs[i]);
 8012952:	d0850882 	ldr.w      	r2, (r5, r4 << 2)
 8012956:	6c53      	mov      	r1, r4
 8012958:	6c1f      	mov      	r0, r7
 801295a:	e0000c39 	bsr      	0x80141cc	// 80141cc <wm_printf>
        if ((i % 5) == 4) {
 801295e:	c4c48043 	divs      	r3, r4, r6
 8012962:	7cd8      	mult      	r3, r6
 8012964:	5c6d      	subu      	r3, r4, r3
 8012966:	3b44      	cmpnei      	r3, 4
 8012968:	0bf2      	bt      	0x801294c	// 801294c <trap_c+0x28>
            printf("\n");
 801296a:	300a      	movi      	r0, 10
    for (i = 0; i < 16; i++) {
 801296c:	2400      	addi      	r4, 1
            printf("\n");
 801296e:	e3fff775 	bsr      	0x8011858	// 8011858 <__GI_putchar>
    for (i = 0; i < 16; i++) {
 8012972:	3c50      	cmpnei      	r4, 16
 8012974:	0bef      	bt      	0x8012952	// 8012952 <trap_c+0x2e>
        }
    }

    printf("\n");
 8012976:	300a      	movi      	r0, 10
 8012978:	e3fff770 	bsr      	0x8011858	// 8011858 <__GI_putchar>
    printf("epsr: %8x\n", regs[16]);
 801297c:	9530      	ld.w      	r1, (r5, 0x40)
 801297e:	1007      	lrw      	r0, 0x8063604	// 8012998 <trap_c+0x74>
 8012980:	e0000c26 	bsr      	0x80141cc	// 80141cc <wm_printf>
    printf("epc : %8x\n", regs[17]);
 8012984:	9531      	ld.w      	r1, (r5, 0x44)
 8012986:	1006      	lrw      	r0, 0x8063610	// 801299c <trap_c+0x78>
 8012988:	e0000c22 	bsr      	0x80141cc	// 80141cc <wm_printf>
 801298c:	0400      	br      	0x801298c	// 801298c <trap_c+0x68>
 801298e:	0000      	.short	0x0000
 8012990:	080635e4 	.long	0x080635e4
 8012994:	080635f8 	.long	0x080635f8
 8012998:	08063604 	.long	0x08063604
 801299c:	08063610 	.long	0x08063610

080129a0 <board_init>:
    VIC->ICER[_IR_IDX(IRQn)] = (uint32_t)(1UL << ((uint32_t)(int32_t)IRQn % 32));
 80129a0:	106a      	lrw      	r3, 0xe000e100	// 80129c8 <board_init+0x28>
 80129a2:	ea210001 	movih      	r1, 1
 80129a6:	dc232020 	st.w      	r1, (r3, 0x80)
    VIC->ICPR[_IR_IDX(IRQn)] = (uint32_t)(1UL << ((uint32_t)(int32_t)IRQn % 32));
 80129aa:	dc232060 	st.w      	r1, (r3, 0x180)

	NVIC_DisableIRQ(UART0_IRQn);
	NVIC_ClearPendingIRQ(UART0_IRQn);

	bd = (APB_CLK/(16*bandrate) - 1)|(((APB_CLK%(bandrate*16))*16/(bandrate*16))<<16);
	WRITE_REG(UART0->BAUDR, bd);
 80129ae:	1068      	lrw      	r3, 0x40010600	// 80129cc <board_init+0x2c>
 80129b0:	ea21000b 	movih      	r1, 11
 80129b4:	2113      	addi      	r1, 20
 80129b6:	b324      	st.w      	r1, (r3, 0x10)
    VIC->ICER[_IR_IDX(IRQn)] = (uint32_t)(1UL << ((uint32_t)(int32_t)IRQn % 32));
 80129b8:	3200      	movi      	r2, 0

	WRITE_REG(UART0->LC, UART_BITSTOP_VAL | UART_TXEN_BIT | UART_RXEN_BIT);
 80129ba:	31c3      	movi      	r1, 195
 80129bc:	b320      	st.w      	r1, (r3, 0x0)
	WRITE_REG(UART0->FC, 0x00);   			/* Disable afc */
 80129be:	b341      	st.w      	r2, (r3, 0x4)
	WRITE_REG(UART0->DMAC, 0x00);             		/* Disable DMA */
 80129c0:	b342      	st.w      	r2, (r3, 0x8)
	WRITE_REG(UART0->FIFOC, 0x00);             		/* one byte TX/RX */
 80129c2:	b343      	st.w      	r2, (r3, 0xc)
#else
    uart1_io_init();
    /* use uart1 as log output io */
	uart1Init(115200);
#endif
}
 80129c4:	783c      	jmp      	r15
 80129c6:	0000      	.short	0x0000
 80129c8:	e000e100 	.long	0xe000e100
 80129cc:	40010600 	.long	0x40010600

080129d0 <_out_uart>:
#include "wm_regs.h"
#include "wm_hal.h"

int sendchar(int ch)
{
    while((READ_REG(UART0->FIFOS) & 0x3F) >= 32);
 80129d0:	1044      	lrw      	r2, 0x40010600	// 80129e0 <_out_uart+0x10>
 80129d2:	9267      	ld.w      	r3, (r2, 0x1c)
 80129d4:	e463203f 	andi      	r3, r3, 63
 80129d8:	3b1f      	cmphsi      	r3, 32
 80129da:	0bfc      	bt      	0x80129d2	// 80129d2 <_out_uart+0x2>
    WRITE_REG(UART0->TDW, (char)ch);
 80129dc:	b208      	st.w      	r0, (r2, 0x20)
}

static inline void _out_uart(char character, void* buffer, size_t idx, size_t maxlen)
{
  _write_r(NULL, 0, &character, 1);
}
 80129de:	783c      	jmp      	r15
 80129e0:	40010600 	.long	0x40010600

080129e4 <_out_null>:

// internal null output
static inline void _out_null(char character, void* buffer, size_t idx, size_t maxlen)
{
  (void)character; (void)buffer; (void)idx; (void)maxlen;
}
 80129e4:	783c      	jmp      	r15
	...

080129e8 <_out_rev>:
  return i;
}

// output the specified string in reverse, taking care of any zero-padding
static size_t _out_rev(out_fct_type out, char* buffer, size_t idx, size_t maxlen, const char* buf, size_t len, unsigned int width, unsigned int flags)
{
 80129e8:	ebe00058 	push      	r4-r11, r15, r16-r17
 80129ec:	6e4f      	mov      	r9, r3
 80129ee:	da0e200e 	ld.w      	r16, (r14, 0x38)
 80129f2:	986b      	ld.w      	r3, (r14, 0x2c)
 80129f4:	c4034831 	lsli      	r17, r3, 0
  const size_t start_idx = idx;

  // pad spaces up to given width
  if (!(flags & FLAGS_LEFT) && !(flags & FLAGS_ZEROPAD)) {
 80129f8:	e4702003 	andi      	r3, r16, 3
{
 80129fc:	6dc3      	mov      	r7, r0
 80129fe:	6e07      	mov      	r8, r1
 8012a00:	6e8b      	mov      	r10, r2
 8012a02:	98ac      	ld.w      	r5, (r14, 0x30)
 8012a04:	d96e200d 	ld.w      	r11, (r14, 0x34)
  if (!(flags & FLAGS_LEFT) && !(flags & FLAGS_ZEROPAD)) {
 8012a08:	e9230010 	bnez      	r3, 0x8012a28	// 8012a28 <_out_rev+0x40>
    for (size_t i = len; i < width; i++) {
 8012a0c:	66d4      	cmphs      	r5, r11
 8012a0e:	080d      	bt      	0x8012a28	// 8012a28 <_out_rev+0x40>
 8012a10:	c4ab0086 	subu      	r6, r11, r5
 8012a14:	6188      	addu      	r6, r2
      out(' ', buffer, idx++, maxlen);
 8012a16:	5a82      	addi      	r4, r2, 1
 8012a18:	6ce7      	mov      	r3, r9
 8012a1a:	6c63      	mov      	r1, r8
 8012a1c:	3020      	movi      	r0, 32
 8012a1e:	7bdd      	jsr      	r7
    for (size_t i = len; i < width; i++) {
 8012a20:	6592      	cmpne      	r4, r6
 8012a22:	6c93      	mov      	r2, r4
 8012a24:	0bf9      	bt      	0x8012a16	// 8012a16 <_out_rev+0x2e>
 8012a26:	0402      	br      	0x8012a2a	// 8012a2a <_out_rev+0x42>
 8012a28:	6d2b      	mov      	r4, r10
    }
  }

  // reverse string
  while (len) {
 8012a2a:	e905002a 	bez      	r5, 0x8012a7e	// 8012a7e <_out_rev+0x96>
 8012a2e:	5dc3      	subi      	r6, r5, 1
 8012a30:	c4114823 	lsli      	r3, r17, 0
 8012a34:	60d8      	addu      	r3, r6
 8012a36:	6d8f      	mov      	r6, r3
 8012a38:	6150      	addu      	r5, r4
    out(buf[--len], buffer, idx++, maxlen);
 8012a3a:	e6240000 	addi      	r17, r4, 1
 8012a3e:	6c93      	mov      	r2, r4
 8012a40:	8600      	ld.b      	r0, (r6, 0x0)
 8012a42:	6ce7      	mov      	r3, r9
 8012a44:	6c63      	mov      	r1, r8
 8012a46:	c4114824 	lsli      	r4, r17, 0
 8012a4a:	7bdd      	jsr      	r7
  while (len) {
 8012a4c:	6552      	cmpne      	r4, r5
 8012a4e:	2e00      	subi      	r6, 1
 8012a50:	0bf5      	bt      	0x8012a3a	// 8012a3a <_out_rev+0x52>
  }

  // append pad spaces up to given width
  if (flags & FLAGS_LEFT) {
 8012a52:	e6102002 	andi      	r16, r16, 2
 8012a56:	e9100011 	bez      	r16, 0x8012a78	// 8012a78 <_out_rev+0x90>
    while (idx - start_idx < width) {
 8012a5a:	c5450083 	subu      	r3, r5, r10
 8012a5e:	66cc      	cmphs      	r3, r11
 8012a60:	080c      	bt      	0x8012a78	// 8012a78 <_out_rev+0x90>
 8012a62:	6c97      	mov      	r2, r5
      out(' ', buffer, idx++, maxlen);
 8012a64:	2500      	addi      	r5, 1
 8012a66:	6ce7      	mov      	r3, r9
 8012a68:	6c63      	mov      	r1, r8
 8012a6a:	3020      	movi      	r0, 32
 8012a6c:	7bdd      	jsr      	r7
    while (idx - start_idx < width) {
 8012a6e:	c5450083 	subu      	r3, r5, r10
 8012a72:	66cc      	cmphs      	r3, r11
      out(' ', buffer, idx++, maxlen);
 8012a74:	6c97      	mov      	r2, r5
    while (idx - start_idx < width) {
 8012a76:	0ff7      	bf      	0x8012a64	// 8012a64 <_out_rev+0x7c>
    }
  }

  return idx;
}
 8012a78:	6c17      	mov      	r0, r5
 8012a7a:	ebc00058 	pop      	r4-r11, r15, r16-r17
  while (len) {
 8012a7e:	6d53      	mov      	r5, r4
 8012a80:	07e9      	br      	0x8012a52	// 8012a52 <_out_rev+0x6a>
	...

08012a84 <_ntoa_format>:

// internal itoa format
static size_t _ntoa_format(out_fct_type out, char* buffer, size_t idx, size_t maxlen, char* buf, size_t len, bool negative, unsigned int base, unsigned int prec, unsigned int width, unsigned int flags)
{
 8012a84:	14d1      	push      	r4, r15
 8012a86:	1424      	subi      	r14, r14, 16
 8012a88:	d9ae2009 	ld.w      	r13, (r14, 0x24)
 8012a8c:	da8e200c 	ld.w      	r20, (r14, 0x30)
 8012a90:	c40d4839 	lsli      	r25, r13, 0
  // pad leading zeros
  if (!(flags & FLAGS_LEFT)) {
 8012a94:	e5b42002 	andi      	r13, r20, 2
{
 8012a98:	dace2006 	ld.w      	r22, (r14, 0x18)
 8012a9c:	d98e2007 	ld.w      	r12, (r14, 0x1c)
 8012aa0:	da6e200a 	ld.w      	r19, (r14, 0x28)
 8012aa4:	da4e200b 	ld.w      	r18, (r14, 0x2c)
 8012aa8:	daee0020 	ld.b      	r23, (r14, 0x20)
  if (!(flags & FLAGS_LEFT)) {
 8012aac:	e92d0039 	bnez      	r13, 0x8012b1e	// 8012b1e <_ntoa_format+0x9a>
    if (width && (flags & FLAGS_ZEROPAD) && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
 8012ab0:	e9320071 	bnez      	r18, 0x8012b92	// 8012b92 <_ntoa_format+0x10e>
      width--;
    }
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012ab4:	c66c0420 	cmphs      	r12, r19
 8012ab8:	0833      	bt      	0x8012b1e	// 8012b1e <_ntoa_format+0x9a>
 8012aba:	eb0c001f 	cmphsi      	r12, 32
 8012abe:	e7142001 	andi      	r24, r20, 1
 8012ac2:	082e      	bt      	0x8012b1e	// 8012b1e <_ntoa_format+0x9a>
 8012ac4:	c596002d 	addu      	r13, r22, r12
      buf[len++] = '0';
 8012ac8:	ea150030 	movi      	r21, 48
 8012acc:	0406      	br      	0x8012ad8	// 8012ad8 <_ntoa_format+0x54>
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012ace:	eb4c0020 	cmpnei      	r12, 32
 8012ad2:	e5ad0000 	addi      	r13, r13, 1
 8012ad6:	0c08      	bf      	0x8012ae6	// 8012ae6 <_ntoa_format+0x62>
      buf[len++] = '0';
 8012ad8:	e58c0000 	addi      	r12, r12, 1
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012adc:	c66c0420 	cmphs      	r12, r19
      buf[len++] = '0';
 8012ae0:	dead0000 	st.b      	r21, (r13, 0x0)
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012ae4:	0ff5      	bf      	0x8012ace	// 8012ace <_ntoa_format+0x4a>
    }
    while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012ae6:	e918001c 	bez      	r24, 0x8012b1e	// 8012b1e <_ntoa_format+0x9a>
 8012aea:	c64c0420 	cmphs      	r12, r18
 8012aee:	0818      	bt      	0x8012b1e	// 8012b1e <_ntoa_format+0x9a>
 8012af0:	ea0d001f 	movi      	r13, 31
 8012af4:	6734      	cmphs      	r13, r12
 8012af6:	0c62      	bf      	0x8012bba	// 8012bba <_ntoa_format+0x136>
 8012af8:	c596002d 	addu      	r13, r22, r12
      buf[len++] = '0';
 8012afc:	ea150030 	movi      	r21, 48
 8012b00:	0406      	br      	0x8012b0c	// 8012b0c <_ntoa_format+0x88>
    while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012b02:	eb4c0020 	cmpnei      	r12, 32
 8012b06:	e5ad0000 	addi      	r13, r13, 1
 8012b0a:	0c58      	bf      	0x8012bba	// 8012bba <_ntoa_format+0x136>
      buf[len++] = '0';
 8012b0c:	e58c0000 	addi      	r12, r12, 1
    while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012b10:	c64c0480 	cmpne      	r12, r18
      buf[len++] = '0';
 8012b14:	dead0000 	st.b      	r21, (r13, 0x0)
    while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012b18:	0bf5      	bt      	0x8012b02	// 8012b02 <_ntoa_format+0x7e>
      buf[len++] = '0';
 8012b1a:	c40c4832 	lsli      	r18, r12, 0
    }
  }

  // handle hash
  if (flags & FLAGS_HASH) {
 8012b1e:	e5b42010 	andi      	r13, r20, 16
 8012b22:	e90d0019 	bez      	r13, 0x8012b54	// 8012b54 <_ntoa_format+0xd0>
    if (!(flags & FLAGS_PRECISION) && len && ((len == prec) || (len == width))) {
 8012b26:	e5b42400 	andi      	r13, r20, 1024
 8012b2a:	e92d0004 	bnez      	r13, 0x8012b32	// 8012b32 <_ntoa_format+0xae>
 8012b2e:	e92c004e 	bnez      	r12, 0x8012bca	// 8012bca <_ntoa_format+0x146>
      len--;
      if (len && (base == 16U)) {
        len--;
      }
    }
    if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012b32:	c4194824 	lsli      	r4, r25, 0
 8012b36:	3c50      	cmpnei      	r4, 16
 8012b38:	0c74      	bf      	0x8012c20	// 8012c20 <_ntoa_format+0x19c>
      buf[len++] = 'x';
    }
    else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = 'X';
    }
    else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012b3a:	c4194824 	lsli      	r4, r25, 0
 8012b3e:	3c42      	cmpnei      	r4, 2
 8012b40:	0c7e      	bf      	0x8012c3c	// 8012c3c <_ntoa_format+0x1b8>
      buf[len++] = 'b';
    }
    if (len < PRINTF_NTOA_BUFFER_SIZE) {
 8012b42:	eb0c001f 	cmphsi      	r12, 32
 8012b46:	081a      	bt      	0x8012b7a	// 8012b7a <_ntoa_format+0xf6>
      buf[len++] = '0';
 8012b48:	ea0d0030 	movi      	r13, 48
 8012b4c:	d596002d 	str.b      	r13, (r22, r12 << 0)
 8012b50:	e58c0000 	addi      	r12, r12, 1
    }
  }

  if (len < PRINTF_NTOA_BUFFER_SIZE) {
 8012b54:	eb0c001f 	cmphsi      	r12, 32
 8012b58:	0811      	bt      	0x8012b7a	// 8012b7a <_ntoa_format+0xf6>
    if (negative) {
 8012b5a:	e9370048 	bnez      	r23, 0x8012bea	// 8012bea <_ntoa_format+0x166>
      buf[len++] = '-';
    }
    else if (flags & FLAGS_PLUS) {
 8012b5e:	e5b42004 	andi      	r13, r20, 4
 8012b62:	e92d0056 	bnez      	r13, 0x8012c0e	// 8012c0e <_ntoa_format+0x18a>
      buf[len++] = '+';  // ignore the space if the '+' exists
    }
    else if (flags & FLAGS_SPACE) {
 8012b66:	e5b42008 	andi      	r13, r20, 8
 8012b6a:	e90d0008 	bez      	r13, 0x8012b7a	// 8012b7a <_ntoa_format+0xf6>
      buf[len++] = ' ';
 8012b6e:	ea0d0020 	movi      	r13, 32
 8012b72:	d596002d 	str.b      	r13, (r22, r12 << 0)
 8012b76:	e58c0000 	addi      	r12, r12, 1
    }
  }

  return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
 8012b7a:	de8e2003 	st.w      	r20, (r14, 0xc)
 8012b7e:	de4e2002 	st.w      	r18, (r14, 0x8)
 8012b82:	dd8e2001 	st.w      	r12, (r14, 0x4)
 8012b86:	dece2000 	st.w      	r22, (r14, 0x0)
 8012b8a:	e3ffff2f 	bsr      	0x80129e8	// 80129e8 <_out_rev>
}
 8012b8e:	1404      	addi      	r14, r14, 16
 8012b90:	1491      	pop      	r4, r15
    if (width && (flags & FLAGS_ZEROPAD) && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
 8012b92:	e7142001 	andi      	r24, r20, 1
 8012b96:	e9180031 	bez      	r24, 0x8012bf8	// 8012bf8 <_ntoa_format+0x174>
 8012b9a:	e9370037 	bnez      	r23, 0x8012c08	// 8012c08 <_ntoa_format+0x184>
 8012b9e:	e5b4200c 	andi      	r13, r20, 12
 8012ba2:	e92d0033 	bnez      	r13, 0x8012c08	// 8012c08 <_ntoa_format+0x184>
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012ba6:	c66c0420 	cmphs      	r12, r19
 8012baa:	0ba0      	bt      	0x8012aea	// 8012aea <_ntoa_format+0x66>
 8012bac:	ea0d001f 	movi      	r13, 31
 8012bb0:	6734      	cmphs      	r13, r12
 8012bb2:	0b89      	bt      	0x8012ac4	// 8012ac4 <_ntoa_format+0x40>
    while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012bb4:	c64c0420 	cmphs      	r12, r18
 8012bb8:	0bb3      	bt      	0x8012b1e	// 8012b1e <_ntoa_format+0x9a>
  if (flags & FLAGS_HASH) {
 8012bba:	e5b42010 	andi      	r13, r20, 16
 8012bbe:	e90dffde 	bez      	r13, 0x8012b7a	// 8012b7a <_ntoa_format+0xf6>
    if (!(flags & FLAGS_PRECISION) && len && ((len == prec) || (len == width))) {
 8012bc2:	e5b42400 	andi      	r13, r20, 1024
 8012bc6:	e92dffb6 	bnez      	r13, 0x8012b32	// 8012b32 <_ntoa_format+0xae>
 8012bca:	c5930480 	cmpne      	r19, r12
 8012bce:	0c04      	bf      	0x8012bd6	// 8012bd6 <_ntoa_format+0x152>
 8012bd0:	c64c0480 	cmpne      	r12, r18
 8012bd4:	0baf      	bt      	0x8012b32	// 8012b32 <_ntoa_format+0xae>
      len--;
 8012bd6:	e5ac1000 	subi      	r13, r12, 1
      if (len && (base == 16U)) {
 8012bda:	e90d0046 	bez      	r13, 0x8012c66	// 8012c66 <_ntoa_format+0x1e2>
 8012bde:	c4194824 	lsli      	r4, r25, 0
 8012be2:	3c50      	cmpnei      	r4, 16
 8012be4:	0c1c      	bf      	0x8012c1c	// 8012c1c <_ntoa_format+0x198>
 8012be6:	6f37      	mov      	r12, r13
 8012be8:	07a9      	br      	0x8012b3a	// 8012b3a <_ntoa_format+0xb6>
      buf[len++] = '-';
 8012bea:	ea0d002d 	movi      	r13, 45
 8012bee:	d596002d 	str.b      	r13, (r22, r12 << 0)
 8012bf2:	e58c0000 	addi      	r12, r12, 1
 8012bf6:	07c2      	br      	0x8012b7a	// 8012b7a <_ntoa_format+0xf6>
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012bf8:	c66c0420 	cmphs      	r12, r19
 8012bfc:	0b91      	bt      	0x8012b1e	// 8012b1e <_ntoa_format+0x9a>
 8012bfe:	ea0d001f 	movi      	r13, 31
 8012c02:	6734      	cmphs      	r13, r12
 8012c04:	0b60      	bt      	0x8012ac4	// 8012ac4 <_ntoa_format+0x40>
 8012c06:	078c      	br      	0x8012b1e	// 8012b1e <_ntoa_format+0x9a>
      width--;
 8012c08:	e6521000 	subi      	r18, r18, 1
 8012c0c:	07cd      	br      	0x8012ba6	// 8012ba6 <_ntoa_format+0x122>
      buf[len++] = '+';  // ignore the space if the '+' exists
 8012c0e:	ea0d002b 	movi      	r13, 43
 8012c12:	d596002d 	str.b      	r13, (r22, r12 << 0)
 8012c16:	e58c0000 	addi      	r12, r12, 1
 8012c1a:	07b0      	br      	0x8012b7a	// 8012b7a <_ntoa_format+0xf6>
        len--;
 8012c1c:	e58c1001 	subi      	r12, r12, 2
    if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012c20:	e5b42020 	andi      	r13, r20, 32
 8012c24:	e92d0016 	bnez      	r13, 0x8012c50	// 8012c50 <_ntoa_format+0x1cc>
 8012c28:	eb0c001f 	cmphsi      	r12, 32
 8012c2c:	0ba7      	bt      	0x8012b7a	// 8012b7a <_ntoa_format+0xf6>
      buf[len++] = 'x';
 8012c2e:	ea0d0078 	movi      	r13, 120
 8012c32:	d596002d 	str.b      	r13, (r22, r12 << 0)
 8012c36:	e58c0000 	addi      	r12, r12, 1
 8012c3a:	0784      	br      	0x8012b42	// 8012b42 <_ntoa_format+0xbe>
    else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012c3c:	eb0c001f 	cmphsi      	r12, 32
 8012c40:	0b9d      	bt      	0x8012b7a	// 8012b7a <_ntoa_format+0xf6>
      buf[len++] = 'b';
 8012c42:	ea0d0062 	movi      	r13, 98
 8012c46:	d596002d 	str.b      	r13, (r22, r12 << 0)
 8012c4a:	e58c0000 	addi      	r12, r12, 1
 8012c4e:	077a      	br      	0x8012b42	// 8012b42 <_ntoa_format+0xbe>
    else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
 8012c50:	ea0d001f 	movi      	r13, 31
 8012c54:	6734      	cmphs      	r13, r12
 8012c56:	0f92      	bf      	0x8012b7a	// 8012b7a <_ntoa_format+0xf6>
      buf[len++] = 'X';
 8012c58:	ea0d0058 	movi      	r13, 88
 8012c5c:	d596002d 	str.b      	r13, (r22, r12 << 0)
 8012c60:	e58c0000 	addi      	r12, r12, 1
 8012c64:	076f      	br      	0x8012b42	// 8012b42 <_ntoa_format+0xbe>
 8012c66:	6f37      	mov      	r12, r13
 8012c68:	0765      	br      	0x8012b32	// 8012b32 <_ntoa_format+0xae>
	...

08012c6c <_ntoa_long>:


// internal itoa for 'long' type
static size_t _ntoa_long(out_fct_type out, char* buffer, size_t idx, size_t maxlen, unsigned long value, bool negative, unsigned long base, unsigned int prec, unsigned int width, unsigned int flags)
{
 8012c6c:	14d3      	push      	r4-r6, r15
 8012c6e:	142f      	subi      	r14, r14, 60
 8012c70:	d9ae2016 	ld.w      	r13, (r14, 0x58)
 8012c74:	d98e2013 	ld.w      	r12, (r14, 0x4c)
 8012c78:	6d77      	mov      	r5, r13
 8012c7a:	d9ae2017 	ld.w      	r13, (r14, 0x5c)
 8012c7e:	da8e2015 	ld.w      	r20, (r14, 0x54)
 8012c82:	6db7      	mov      	r6, r13
 8012c84:	db0e2018 	ld.w      	r24, (r14, 0x60)
 8012c88:	d88e0050 	ld.b      	r4, (r14, 0x50)
  char buf[PRINTF_NTOA_BUFFER_SIZE];
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
 8012c8c:	e92c000a 	bnez      	r12, 0x8012ca0	// 8012ca0 <_ntoa_long+0x34>
    flags &= ~FLAGS_HASH;
 8012c90:	c498282d 	bclri      	r13, r24, 4
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
 8012c94:	e7182400 	andi      	r24, r24, 1024
 8012c98:	e9380043 	bnez      	r24, 0x8012d1e	// 8012d1e <_ntoa_long+0xb2>
    flags &= ~FLAGS_HASH;
 8012c9c:	c40d4838 	lsli      	r24, r13, 0
    do {
      const char digit = (char)(value % base);
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
 8012ca0:	e5b82020 	andi      	r13, r24, 32
 8012ca4:	eb4d0000 	cmpnei      	r13, 0
 8012ca8:	ea170041 	movi      	r23, 65
 8012cac:	ea0d0061 	movi      	r13, 97
 8012cb0:	c6ed0c20 	incf      	r23, r13, 0
 8012cb4:	e72e001b 	addi      	r25, r14, 28
 8012cb8:	c4194832 	lsli      	r18, r25, 0
 8012cbc:	ea150000 	movi      	r21, 0
 8012cc0:	e6f71009 	subi      	r23, r23, 10
 8012cc4:	ea130020 	movi      	r19, 32
      const char digit = (char)(value % base);
 8012cc8:	c68c802d 	divu      	r13, r12, r20
 8012ccc:	c68d8436 	mult      	r22, r13, r20
 8012cd0:	c6cc008c 	subu      	r12, r12, r22
 8012cd4:	7730      	zextb      	r12, r12
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
 8012cd6:	eb0c0009 	cmphsi      	r12, 10
 8012cda:	e6b50000 	addi      	r21, r21, 1
 8012cde:	081c      	bt      	0x8012d16	// 8012d16 <_ntoa_long+0xaa>
 8012ce0:	e58c002f 	addi      	r12, r12, 48
 8012ce4:	7730      	zextb      	r12, r12
 8012ce6:	dd920000 	st.b      	r12, (r18, 0x0)
      value /= base;
 8012cea:	6f37      	mov      	r12, r13
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
 8012cec:	e90d0006 	bez      	r13, 0x8012cf8	// 8012cf8 <_ntoa_long+0x8c>
 8012cf0:	e6520000 	addi      	r18, r18, 1
 8012cf4:	e833ffea 	bnezad      	r19, 0x8012cc8	// 8012cc8 <_ntoa_long+0x5c>
  }

  return _ntoa_format(out, buffer, idx, maxlen, buf, len, negative, (unsigned int)base, prec, width, flags);
 8012cf8:	df0e2006 	st.w      	r24, (r14, 0x18)
 8012cfc:	b8c5      	st.w      	r6, (r14, 0x14)
 8012cfe:	b8a4      	st.w      	r5, (r14, 0x10)
 8012d00:	de8e2003 	st.w      	r20, (r14, 0xc)
 8012d04:	b882      	st.w      	r4, (r14, 0x8)
 8012d06:	deae2001 	st.w      	r21, (r14, 0x4)
 8012d0a:	df2e2000 	st.w      	r25, (r14, 0x0)
 8012d0e:	e3fffebb 	bsr      	0x8012a84	// 8012a84 <_ntoa_format>
}
 8012d12:	140f      	addi      	r14, r14, 60
 8012d14:	1493      	pop      	r4-r6, r15
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
 8012d16:	c6ec002c 	addu      	r12, r12, r23
 8012d1a:	7730      	zextb      	r12, r12
 8012d1c:	07e5      	br      	0x8012ce6	// 8012ce6 <_ntoa_long+0x7a>
    flags &= ~FLAGS_HASH;
 8012d1e:	c40d4838 	lsli      	r24, r13, 0
  size_t len = 0U;
 8012d22:	c40c4835 	lsli      	r21, r12, 0
 8012d26:	e72e001b 	addi      	r25, r14, 28
 8012d2a:	07e7      	br      	0x8012cf8	// 8012cf8 <_ntoa_long+0x8c>

08012d2c <_ntoa_long_long>:


// internal itoa for 'long long' type
#if defined(PRINTF_SUPPORT_LONG_LONG)
static size_t _ntoa_long_long(out_fct_type out, char* buffer, size_t idx, size_t maxlen, unsigned long long value, bool negative, unsigned long long base, unsigned int prec, unsigned int width, unsigned int flags)
{
 8012d2c:	ebe00058 	push      	r4-r11, r15, r16-r17
 8012d30:	1435      	subi      	r14, r14, 84
 8012d32:	c4034831 	lsli      	r17, r3, 0
 8012d36:	d96e2020 	ld.w      	r11, (r14, 0x80)
 8012d3a:	9965      	ld.w      	r3, (r14, 0x94)
 8012d3c:	da0e2021 	ld.w      	r16, (r14, 0x84)
 8012d40:	b86b      	st.w      	r3, (r14, 0x2c)
  char buf[PRINTF_NTOA_BUFFER_SIZE];
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
 8012d42:	c60b2424 	or      	r4, r11, r16
{
 8012d46:	9966      	ld.w      	r3, (r14, 0x98)
 8012d48:	b86c      	st.w      	r3, (r14, 0x30)
 8012d4a:	d86e0088 	ld.b      	r3, (r14, 0x88)
 8012d4e:	b807      	st.w      	r0, (r14, 0x1c)
 8012d50:	b828      	st.w      	r1, (r14, 0x20)
 8012d52:	b849      	st.w      	r2, (r14, 0x24)
 8012d54:	99c3      	ld.w      	r6, (r14, 0x8c)
 8012d56:	99e4      	ld.w      	r7, (r14, 0x90)
 8012d58:	d94e2027 	ld.w      	r10, (r14, 0x9c)
 8012d5c:	b86a      	st.w      	r3, (r14, 0x28)
  if (!value) {
 8012d5e:	e9240009 	bnez      	r4, 0x8012d70	// 8012d70 <_ntoa_long_long+0x44>
    flags &= ~FLAGS_HASH;
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
 8012d62:	e44a2400 	andi      	r2, r10, 1024
    flags &= ~FLAGS_HASH;
 8012d66:	c48a2823 	bclri      	r3, r10, 4
 8012d6a:	6e8f      	mov      	r10, r3
  if (!(flags & FLAGS_PRECISION) || value) {
 8012d6c:	e9220033 	bnez      	r2, 0x8012dd2	// 8012dd2 <_ntoa_long_long+0xa6>
    do {
      const char digit = (char)(value % base);
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
 8012d70:	e46a2020 	andi      	r3, r10, 32
 8012d74:	3b40      	cmpnei      	r3, 0
 8012d76:	ea080041 	movi      	r8, 65
 8012d7a:	3361      	movi      	r3, 97
 8012d7c:	c5030c20 	incf      	r8, r3, 0
 8012d80:	e52e0033 	addi      	r9, r14, 52
 8012d84:	6d67      	mov      	r5, r9
 8012d86:	3400      	movi      	r4, 0
 8012d88:	e5081009 	subi      	r8, r8, 10
 8012d8c:	0415      	br      	0x8012db6	// 8012db6 <_ntoa_long_long+0x8a>
 8012d8e:	202f      	addi      	r0, 48
 8012d90:	7400      	zextb      	r0, r0
 8012d92:	a500      	st.b      	r0, (r5, 0x0)
      value /= base;
 8012d94:	c4104821 	lsli      	r1, r16, 0
 8012d98:	6c2f      	mov      	r0, r11
 8012d9a:	6c9b      	mov      	r2, r6
 8012d9c:	6cdf      	mov      	r3, r7
 8012d9e:	e3ffec3b 	bsr      	0x8010614	// 8010614 <__udivdi3>
 8012da2:	c4014830 	lsli      	r16, r1, 0
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
 8012da6:	6c40      	or      	r1, r0
      value /= base;
 8012da8:	6ec3      	mov      	r11, r0
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
 8012daa:	e9010016 	bez      	r1, 0x8012dd6	// 8012dd6 <_ntoa_long_long+0xaa>
 8012dae:	eb440020 	cmpnei      	r4, 32
 8012db2:	2500      	addi      	r5, 1
 8012db4:	0c11      	bf      	0x8012dd6	// 8012dd6 <_ntoa_long_long+0xaa>
      const char digit = (char)(value % base);
 8012db6:	6c9b      	mov      	r2, r6
 8012db8:	6cdf      	mov      	r3, r7
 8012dba:	6c2f      	mov      	r0, r11
 8012dbc:	c4104821 	lsli      	r1, r16, 0
 8012dc0:	e3ffedc4 	bsr      	0x8010948	// 8010948 <__umoddi3>
 8012dc4:	7400      	zextb      	r0, r0
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
 8012dc6:	3809      	cmphsi      	r0, 10
 8012dc8:	2400      	addi      	r4, 1
 8012dca:	0fe2      	bf      	0x8012d8e	// 8012d8e <_ntoa_long_long+0x62>
 8012dcc:	6020      	addu      	r0, r8
 8012dce:	7400      	zextb      	r0, r0
 8012dd0:	07e1      	br      	0x8012d92	// 8012d92 <_ntoa_long_long+0x66>
 8012dd2:	e52e0033 	addi      	r9, r14, 52
  }

  return _ntoa_format(out, buffer, idx, maxlen, buf, len, negative, (unsigned int)base, prec, width, flags);
 8012dd6:	986c      	ld.w      	r3, (r14, 0x30)
 8012dd8:	b865      	st.w      	r3, (r14, 0x14)
 8012dda:	986b      	ld.w      	r3, (r14, 0x2c)
 8012ddc:	b864      	st.w      	r3, (r14, 0x10)
 8012dde:	986a      	ld.w      	r3, (r14, 0x28)
 8012de0:	b862      	st.w      	r3, (r14, 0x8)
 8012de2:	dd4e2006 	st.w      	r10, (r14, 0x18)
 8012de6:	b8c3      	st.w      	r6, (r14, 0xc)
 8012de8:	b881      	st.w      	r4, (r14, 0x4)
 8012dea:	dd2e2000 	st.w      	r9, (r14, 0x0)
 8012dee:	c4114823 	lsli      	r3, r17, 0
 8012df2:	9849      	ld.w      	r2, (r14, 0x24)
 8012df4:	9828      	ld.w      	r1, (r14, 0x20)
 8012df6:	9807      	ld.w      	r0, (r14, 0x1c)
 8012df8:	e3fffe46 	bsr      	0x8012a84	// 8012a84 <_ntoa_format>
}
 8012dfc:	1415      	addi      	r14, r14, 84
 8012dfe:	ebc00058 	pop      	r4-r11, r15, r16-r17
	...

08012e04 <_ftoa>:
#endif


// internal ftoa for fixed decimal floating point
static size_t _ftoa(out_fct_type out, char* buffer, size_t idx, size_t maxlen, double value, unsigned int prec, unsigned int width, unsigned int flags)
{
 8012e04:	ebe00058 	push      	r4-r11, r15, r16-r17
 8012e08:	1435      	subi      	r14, r14, 84
 8012e0a:	6ecf      	mov      	r11, r3
 8012e0c:	9962      	ld.w      	r3, (r14, 0x88)
 8012e0e:	6e4f      	mov      	r9, r3
 8012e10:	9963      	ld.w      	r3, (r14, 0x8c)
 8012e12:	9980      	ld.w      	r4, (r14, 0x80)
 8012e14:	99a1      	ld.w      	r5, (r14, 0x84)
 8012e16:	b865      	st.w      	r3, (r14, 0x14)
 8012e18:	9964      	ld.w      	r3, (r14, 0x90)
 8012e1a:	6d83      	mov      	r6, r0
 8012e1c:	6dc7      	mov      	r7, r1
 8012e1e:	6e8b      	mov      	r10, r2
 8012e20:	b866      	st.w      	r3, (r14, 0x18)

  // powers of 10
  static const double pow10[] = { 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000 };

  // test for special values
  if (value != value)
 8012e22:	6c93      	mov      	r2, r4
 8012e24:	6cd7      	mov      	r3, r5
 8012e26:	6c13      	mov      	r0, r4
 8012e28:	6c57      	mov      	r1, r5
 8012e2a:	e3fff245 	bsr      	0x80112b4	// 80112b4 <__nedf2>
 8012e2e:	e920010c 	bnez      	r0, 0x8013046	// 8013046 <_ftoa+0x242>
    return _out_rev(out, buffer, idx, maxlen, "nan", 3, width, flags);
  if (value < -DBL_MAX)
 8012e32:	3200      	movi      	r2, 0
 8012e34:	ea23fff0 	movih      	r3, 65520
 8012e38:	2a00      	subi      	r2, 1
 8012e3a:	2b00      	subi      	r3, 1
 8012e3c:	6c13      	mov      	r0, r4
 8012e3e:	9921      	ld.w      	r1, (r14, 0x84)
 8012e40:	e3fff296 	bsr      	0x801136c	// 801136c <__ltdf2>
 8012e44:	e980011b 	blz      	r0, 0x801307a	// 801307a <_ftoa+0x276>
    return _out_rev(out, buffer, idx, maxlen, "fni-", 4, width, flags);
  if (value > DBL_MAX)
 8012e48:	3200      	movi      	r2, 0
 8012e4a:	ea237ff0 	movih      	r3, 32752
 8012e4e:	2a00      	subi      	r2, 1
 8012e50:	2b00      	subi      	r3, 1
 8012e52:	6c13      	mov      	r0, r4
 8012e54:	9921      	ld.w      	r1, (r14, 0x84)
 8012e56:	e3fff24b 	bsr      	0x80112ec	// 80112ec <__gtdf2>
 8012e5a:	e960001d 	blsz      	r0, 0x8012e94	// 8012e94 <_ftoa+0x90>
    return _out_rev(out, buffer, idx, maxlen, (flags & FLAGS_PLUS) ? "fni+" : "fni", (flags & FLAGS_PLUS) ? 4U : 3U, width, flags);
 8012e5e:	9806      	ld.w      	r0, (r14, 0x18)
 8012e60:	e4402004 	andi      	r2, r0, 4
 8012e64:	3a40      	cmpnei      	r2, 0
 8012e66:	0137      	lrw      	r1, 0x8063804	// 8013184 <_ftoa+0x380>
 8012e68:	0177      	lrw      	r3, 0x80637fc	// 8013188 <_ftoa+0x384>
 8012e6a:	c4610c20 	incf      	r3, r1, 0
 8012e6e:	3a40      	cmpnei      	r2, 0
 8012e70:	3103      	movi      	r1, 3
 8012e72:	3204      	movi      	r2, 4
 8012e74:	c4410c20 	incf      	r2, r1, 0
 8012e78:	9825      	ld.w      	r1, (r14, 0x14)
 8012e7a:	b803      	st.w      	r0, (r14, 0xc)
 8012e7c:	b822      	st.w      	r1, (r14, 0x8)
 8012e7e:	b841      	st.w      	r2, (r14, 0x4)
 8012e80:	b860      	st.w      	r3, (r14, 0x0)
    else if (flags & FLAGS_SPACE) {
      buf[len++] = ' ';
    }
  }

  return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
 8012e82:	6cef      	mov      	r3, r11
 8012e84:	6cab      	mov      	r2, r10
 8012e86:	6c5f      	mov      	r1, r7
 8012e88:	6c1b      	mov      	r0, r6
 8012e8a:	e3fffdaf 	bsr      	0x80129e8	// 80129e8 <_out_rev>
}
 8012e8e:	1415      	addi      	r14, r14, 84
 8012e90:	ebc00058 	pop      	r4-r11, r15, r16-r17
  if ((value > PRINTF_MAX_FLOAT) || (value < -PRINTF_MAX_FLOAT)) {
 8012e94:	3200      	movi      	r2, 0
 8012e96:	0261      	lrw      	r3, 0x41cdcd65	// 801318c <_ftoa+0x388>
 8012e98:	6c13      	mov      	r0, r4
 8012e9a:	9921      	ld.w      	r1, (r14, 0x84)
 8012e9c:	e3fff228 	bsr      	0x80112ec	// 80112ec <__gtdf2>
 8012ea0:	e94000dc 	bhz      	r0, 0x8013058	// 8013058 <_ftoa+0x254>
 8012ea4:	3200      	movi      	r2, 0
 8012ea6:	0264      	lrw      	r3, 0xc1cdcd65	// 8013190 <_ftoa+0x38c>
 8012ea8:	6c13      	mov      	r0, r4
 8012eaa:	9921      	ld.w      	r1, (r14, 0x84)
 8012eac:	e3fff260 	bsr      	0x801136c	// 801136c <__ltdf2>
 8012eb0:	e98000d4 	blz      	r0, 0x8013058	// 8013058 <_ftoa+0x254>
  if (value < 0) {
 8012eb4:	3200      	movi      	r2, 0
 8012eb6:	6ccb      	mov      	r3, r2
 8012eb8:	6c13      	mov      	r0, r4
 8012eba:	9921      	ld.w      	r1, (r14, 0x84)
 8012ebc:	e3fff258 	bsr      	0x801136c	// 801136c <__ltdf2>
 8012ec0:	e98001b0 	blz      	r0, 0x8013220	// 8013220 <_ftoa+0x41c>
  bool negative = false;
 8012ec4:	3300      	movi      	r3, 0
 8012ec6:	b86c      	st.w      	r3, (r14, 0x30)
  if (!(flags & FLAGS_PRECISION)) {
 8012ec8:	9866      	ld.w      	r3, (r14, 0x18)
 8012eca:	e5a32400 	andi      	r13, r3, 1024
 8012ece:	e92d0136 	bnez      	r13, 0x801313a	// 801313a <_ftoa+0x336>
 8012ed2:	026e      	lrw      	r3, 0x412e8480	// 8013194 <_ftoa+0x390>
 8012ed4:	ddae2007 	st.w      	r13, (r14, 0x1c)
 8012ed8:	b868      	st.w      	r3, (r14, 0x20)
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
 8012eda:	ea080006 	movi      	r8, 6
 8012ede:	e68e0033 	addi      	r20, r14, 52
  int whole = (int)value;
 8012ee2:	6c57      	mov      	r1, r5
 8012ee4:	6c13      	mov      	r0, r4
 8012ee6:	de8e200b 	st.w      	r20, (r14, 0x2c)
 8012eea:	ddae200a 	st.w      	r13, (r14, 0x28)
 8012eee:	e3fff28f 	bsr      	0x801140c	// 801140c <__fixdfsi>
 8012ef2:	6e43      	mov      	r9, r0
  double tmp = (value - whole) * pow10[prec];
 8012ef4:	e3fff258 	bsr      	0x80113a4	// 80113a4 <__floatsidf>
 8012ef8:	6c83      	mov      	r2, r0
 8012efa:	6cc7      	mov      	r3, r1
 8012efc:	6c13      	mov      	r0, r4
 8012efe:	6c57      	mov      	r1, r5
 8012f00:	e3fff030 	bsr      	0x8010f60	// 8010f60 <__subdf3>
 8012f04:	d98e2007 	ld.w      	r12, (r14, 0x1c)
 8012f08:	d9ae2008 	ld.w      	r13, (r14, 0x20)
 8012f0c:	6cb3      	mov      	r2, r12
 8012f0e:	9868      	ld.w      	r3, (r14, 0x20)
 8012f10:	e3fff046 	bsr      	0x8010f9c	// 8010f9c <__muldf3>
 8012f14:	c4014831 	lsli      	r17, r1, 0
 8012f18:	c4004830 	lsli      	r16, r0, 0
  unsigned long frac = (unsigned long)tmp;
 8012f1c:	e3ffeb60 	bsr      	0x80105dc	// 80105dc <__fixunsdfsi>
 8012f20:	b809      	st.w      	r0, (r14, 0x24)
  diff = tmp - frac;
 8012f22:	e3fff2ad 	bsr      	0x801147c	// 801147c <__floatunsidf>
 8012f26:	6c83      	mov      	r2, r0
 8012f28:	6cc7      	mov      	r3, r1
 8012f2a:	c4104820 	lsli      	r0, r16, 0
 8012f2e:	c4114821 	lsli      	r1, r17, 0
 8012f32:	e3fff017 	bsr      	0x8010f60	// 8010f60 <__subdf3>
  if (diff > 0.5) {
 8012f36:	3200      	movi      	r2, 0
 8012f38:	ea233fe0 	movih      	r3, 16352
  diff = tmp - frac;
 8012f3c:	c4004830 	lsli      	r16, r0, 0
 8012f40:	c4014831 	lsli      	r17, r1, 0
  if (diff > 0.5) {
 8012f44:	e3fff1d4 	bsr      	0x80112ec	// 80112ec <__gtdf2>
 8012f48:	da4e2009 	ld.w      	r18, (r14, 0x24)
 8012f4c:	d9ae200a 	ld.w      	r13, (r14, 0x28)
 8012f50:	da8e200b 	ld.w      	r20, (r14, 0x2c)
 8012f54:	e96000d3 	blsz      	r0, 0x80130fa	// 80130fa <_ftoa+0x2f6>
    ++frac;
 8012f58:	e6520000 	addi      	r18, r18, 1
    if (frac >= pow10[prec]) {
 8012f5c:	c4124820 	lsli      	r0, r18, 0
 8012f60:	de8e2009 	st.w      	r20, (r14, 0x24)
 8012f64:	c40d4831 	lsli      	r17, r13, 0
 8012f68:	c4124830 	lsli      	r16, r18, 0
 8012f6c:	e3fff288 	bsr      	0x801147c	// 801147c <__floatunsidf>
 8012f70:	d98e2007 	ld.w      	r12, (r14, 0x1c)
 8012f74:	d9ae2008 	ld.w      	r13, (r14, 0x20)
 8012f78:	6cf7      	mov      	r3, r13
 8012f7a:	6cb3      	mov      	r2, r12
 8012f7c:	e3fff1d8 	bsr      	0x801132c	// 801132c <__gedf2>
 8012f80:	c4104832 	lsli      	r18, r16, 0
 8012f84:	c411482d 	lsli      	r13, r17, 0
 8012f88:	da8e2009 	ld.w      	r20, (r14, 0x24)
 8012f8c:	e9a0011f 	bhsz      	r0, 0x80131ca	// 80131ca <_ftoa+0x3c6>
  if (prec == 0U) {
 8012f90:	e928007e 	bnez      	r8, 0x801308c	// 801308c <_ftoa+0x288>
    diff = value - (double)whole;
 8012f94:	6c27      	mov      	r0, r9
 8012f96:	c4144831 	lsli      	r17, r20, 0
 8012f9a:	c40d4830 	lsli      	r16, r13, 0
 8012f9e:	e3fff203 	bsr      	0x80113a4	// 80113a4 <__floatsidf>
 8012fa2:	6c83      	mov      	r2, r0
 8012fa4:	6cc7      	mov      	r3, r1
 8012fa6:	6c13      	mov      	r0, r4
 8012fa8:	6c57      	mov      	r1, r5
 8012faa:	e3ffefdb 	bsr      	0x8010f60	// 8010f60 <__subdf3>
    if ((!(diff < 0.5) || (diff > 0.5)) && (whole & 1)) {
 8012fae:	6ca3      	mov      	r2, r8
 8012fb0:	ea233fe0 	movih      	r3, 16352
    diff = value - (double)whole;
 8012fb4:	6d03      	mov      	r4, r0
 8012fb6:	6d47      	mov      	r5, r1
    if ((!(diff < 0.5) || (diff > 0.5)) && (whole & 1)) {
 8012fb8:	e3fff1da 	bsr      	0x801136c	// 801136c <__ltdf2>
 8012fbc:	c410482d 	lsli      	r13, r16, 0
 8012fc0:	c4114834 	lsli      	r20, r17, 0
 8012fc4:	e98000f5 	blz      	r0, 0x80131ae	// 80131ae <_ftoa+0x3aa>
 8012fc8:	e4692001 	andi      	r3, r9, 1
      ++whole;
 8012fcc:	3b40      	cmpnei      	r3, 0
 8012fce:	c4690c20 	incf      	r3, r9, 0
 8012fd2:	c4690c41 	inct      	r3, r9, 1
 8012fd6:	6e4f      	mov      	r9, r3
  while (len < PRINTF_FTOA_BUFFER_SIZE) {
 8012fd8:	eb4d0020 	cmpnei      	r13, 32
 8012fdc:	0c81      	bf      	0x80130de	// 80130de <_ftoa+0x2da>
    buf[len++] = (char)(48 + (whole % 10));
 8012fde:	300a      	movi      	r0, 10
 8012fe0:	c4098043 	divs      	r3, r9, r0
 8012fe4:	6d27      	mov      	r4, r9
 8012fe6:	c4038421 	mult      	r1, r3, r0
 8012fea:	5c25      	subu      	r1, r4, r1
 8012fec:	212f      	addi      	r1, 48
 8012fee:	e44d0000 	addi      	r2, r13, 1
 8012ff2:	d5b40021 	str.b      	r1, (r20, r13 << 0)
    if (!(whole /= 10)) {
 8012ff6:	e9030013 	bez      	r3, 0x801301c	// 801301c <_ftoa+0x218>
 8012ffa:	c454002c 	addu      	r12, r20, r2
  while (len < PRINTF_FTOA_BUFFER_SIZE) {
 8012ffe:	eb420020 	cmpnei      	r2, 32
 8013002:	0c6e      	bf      	0x80130de	// 80130de <_ftoa+0x2da>
    buf[len++] = (char)(48 + (whole % 10));
 8013004:	c4038041 	divs      	r1, r3, r0
 8013008:	c401842d 	mult      	r13, r1, r0
 801300c:	60f6      	subu      	r3, r13
 801300e:	232f      	addi      	r3, 48
 8013010:	d40c8003 	stbi.b      	r3, (r12)
 8013014:	2200      	addi      	r2, 1
    if (!(whole /= 10)) {
 8013016:	6cc7      	mov      	r3, r1
 8013018:	e921fff3 	bnez      	r1, 0x8012ffe	// 8012ffe <_ftoa+0x1fa>
  if (!(flags & FLAGS_LEFT) && (flags & FLAGS_ZEROPAD)) {
 801301c:	9866      	ld.w      	r3, (r14, 0x18)
 801301e:	e4632003 	andi      	r3, r3, 3
 8013022:	3b41      	cmpnei      	r3, 1
 8013024:	0cda      	bf      	0x80131d8	// 80131d8 <_ftoa+0x3d4>
  if (len < PRINTF_FTOA_BUFFER_SIZE) {
 8013026:	eb420020 	cmpnei      	r2, 32
 801302a:	0d27      	bf      	0x8013278	// 8013278 <_ftoa+0x474>
    if (negative) {
 801302c:	986c      	ld.w      	r3, (r14, 0x30)
 801302e:	e92300bb 	bnez      	r3, 0x80131a4	// 80131a4 <_ftoa+0x3a0>
    else if (flags & FLAGS_PLUS) {
 8013032:	9866      	ld.w      	r3, (r14, 0x18)
 8013034:	e4632004 	andi      	r3, r3, 4
 8013038:	e9030116 	bez      	r3, 0x8013264	// 8013264 <_ftoa+0x460>
      buf[len++] = '+';  // ignore the space if the '+' exists
 801303c:	312b      	movi      	r1, 43
 801303e:	5a62      	addi      	r3, r2, 1
 8013040:	d4540021 	str.b      	r1, (r20, r2 << 0)
 8013044:	0453      	br      	0x80130ea	// 80130ea <_ftoa+0x2e6>
    return _out_rev(out, buffer, idx, maxlen, "nan", 3, width, flags);
 8013046:	9866      	ld.w      	r3, (r14, 0x18)
 8013048:	b863      	st.w      	r3, (r14, 0xc)
 801304a:	9865      	ld.w      	r3, (r14, 0x14)
 801304c:	b862      	st.w      	r3, (r14, 0x8)
 801304e:	3303      	movi      	r3, 3
 8013050:	b861      	st.w      	r3, (r14, 0x4)
 8013052:	1272      	lrw      	r3, 0x8063808	// 8013198 <_ftoa+0x394>
 8013054:	b860      	st.w      	r3, (r14, 0x0)
 8013056:	0716      	br      	0x8012e82	// 8012e82 <_ftoa+0x7e>
    return _etoa(out, buffer, idx, maxlen, value, prec, width, flags);
 8013058:	9866      	ld.w      	r3, (r14, 0x18)
 801305a:	b864      	st.w      	r3, (r14, 0x10)
 801305c:	9865      	ld.w      	r3, (r14, 0x14)
 801305e:	b863      	st.w      	r3, (r14, 0xc)
 8013060:	dd2e2002 	st.w      	r9, (r14, 0x8)
 8013064:	b880      	st.w      	r4, (r14, 0x0)
 8013066:	b8a1      	st.w      	r5, (r14, 0x4)
 8013068:	6cef      	mov      	r3, r11
 801306a:	6cab      	mov      	r2, r10
 801306c:	6c5f      	mov      	r1, r7
 801306e:	6c1b      	mov      	r0, r6
 8013070:	e0000116 	bsr      	0x801329c	// 801329c <_etoa>
}
 8013074:	1415      	addi      	r14, r14, 84
 8013076:	ebc00058 	pop      	r4-r11, r15, r16-r17
    return _out_rev(out, buffer, idx, maxlen, "fni-", 4, width, flags);
 801307a:	9866      	ld.w      	r3, (r14, 0x18)
 801307c:	b863      	st.w      	r3, (r14, 0xc)
 801307e:	9865      	ld.w      	r3, (r14, 0x14)
 8013080:	b862      	st.w      	r3, (r14, 0x8)
 8013082:	3304      	movi      	r3, 4
 8013084:	b861      	st.w      	r3, (r14, 0x4)
 8013086:	1266      	lrw      	r3, 0x806380c	// 801319c <_ftoa+0x398>
 8013088:	b860      	st.w      	r3, (r14, 0x0)
 801308a:	06fc      	br      	0x8012e82	// 8012e82 <_ftoa+0x7e>
    while (len < PRINTF_FTOA_BUFFER_SIZE) {
 801308c:	eb4d0020 	cmpnei      	r13, 32
 8013090:	0c27      	bf      	0x80130de	// 80130de <_ftoa+0x2da>
      buf[len++] = (char)(48U + (frac % 10U));
 8013092:	300a      	movi      	r0, 10
 8013094:	c4128023 	divu      	r3, r18, r0
 8013098:	c4038421 	mult      	r1, r3, r0
 801309c:	c4320092 	subu      	r18, r18, r1
 80130a0:	e652002f 	addi      	r18, r18, 48
      --count;
 80130a4:	e5881000 	subi      	r12, r8, 1
      buf[len++] = (char)(48U + (frac % 10U));
 80130a8:	e44d0000 	addi      	r2, r13, 1
 80130ac:	d5b40032 	str.b      	r18, (r20, r13 << 0)
      if (!(frac /= 10U)) {
 80130b0:	e90300c3 	bez      	r3, 0x8013236	// 8013236 <_ftoa+0x432>
 80130b4:	c454002d 	addu      	r13, r20, r2
 80130b8:	0410      	br      	0x80130d8	// 80130d8 <_ftoa+0x2d4>
      buf[len++] = (char)(48U + (frac % 10U));
 80130ba:	c4038021 	divu      	r1, r3, r0
 80130be:	c4018432 	mult      	r18, r1, r0
 80130c2:	c6430083 	subu      	r3, r3, r18
 80130c6:	232f      	addi      	r3, 48
 80130c8:	d40d8003 	stbi.b      	r3, (r13)
      --count;
 80130cc:	e58c1000 	subi      	r12, r12, 1
      buf[len++] = (char)(48U + (frac % 10U));
 80130d0:	2200      	addi      	r2, 1
      if (!(frac /= 10U)) {
 80130d2:	6cc7      	mov      	r3, r1
 80130d4:	e90100b1 	bez      	r1, 0x8013236	// 8013236 <_ftoa+0x432>
    while (len < PRINTF_FTOA_BUFFER_SIZE) {
 80130d8:	eb420020 	cmpnei      	r2, 32
 80130dc:	0bef      	bt      	0x80130ba	// 80130ba <_ftoa+0x2b6>
  if (!(flags & FLAGS_LEFT) && (flags & FLAGS_ZEROPAD)) {
 80130de:	9866      	ld.w      	r3, (r14, 0x18)
 80130e0:	e4632003 	andi      	r3, r3, 3
 80130e4:	3b41      	cmpnei      	r3, 1
 80130e6:	0c78      	bf      	0x80131d6	// 80131d6 <_ftoa+0x3d2>
 80130e8:	3320      	movi      	r3, 32
  return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
 80130ea:	9846      	ld.w      	r2, (r14, 0x18)
 80130ec:	b843      	st.w      	r2, (r14, 0xc)
 80130ee:	9845      	ld.w      	r2, (r14, 0x14)
 80130f0:	b842      	st.w      	r2, (r14, 0x8)
 80130f2:	b861      	st.w      	r3, (r14, 0x4)
 80130f4:	de8e2000 	st.w      	r20, (r14, 0x0)
 80130f8:	06c5      	br      	0x8012e82	// 8012e82 <_ftoa+0x7e>
  else if (diff < 0.5) {
 80130fa:	3200      	movi      	r2, 0
 80130fc:	ea233fe0 	movih      	r3, 16352
 8013100:	c4104820 	lsli      	r0, r16, 0
 8013104:	c4114821 	lsli      	r1, r17, 0
 8013108:	de8e200a 	st.w      	r20, (r14, 0x28)
 801310c:	de4e2009 	st.w      	r18, (r14, 0x24)
 8013110:	ddae2007 	st.w      	r13, (r14, 0x1c)
 8013114:	e3fff12c 	bsr      	0x801136c	// 801136c <__ltdf2>
 8013118:	d9ae2007 	ld.w      	r13, (r14, 0x1c)
 801311c:	da4e2009 	ld.w      	r18, (r14, 0x24)
 8013120:	da8e200a 	ld.w      	r20, (r14, 0x28)
 8013124:	e980ff36 	blz      	r0, 0x8012f90	// 8012f90 <_ftoa+0x18c>
  else if ((frac == 0U) || (frac & 1U)) {
 8013128:	e9120006 	bez      	r18, 0x8013134	// 8013134 <_ftoa+0x330>
 801312c:	e4722001 	andi      	r3, r18, 1
 8013130:	e903ff30 	bez      	r3, 0x8012f90	// 8012f90 <_ftoa+0x18c>
    ++frac;
 8013134:	e6520000 	addi      	r18, r18, 1
 8013138:	072c      	br      	0x8012f90	// 8012f90 <_ftoa+0x18c>
  while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
 801313a:	6ce7      	mov      	r3, r9
 801313c:	3b09      	cmphsi      	r3, 10
 801313e:	0c9f      	bf      	0x801327c	// 801327c <_ftoa+0x478>
    buf[len++] = '0';
 8013140:	e68e0033 	addi      	r20, r14, 52
 8013144:	3030      	movi      	r0, 48
 8013146:	dc140000 	st.b      	r0, (r20, 0x0)
    prec--;
 801314a:	e5091000 	subi      	r8, r9, 1
 801314e:	e44e0034 	addi      	r2, r14, 53
 8013152:	e4291008 	subi      	r1, r9, 9
 8013156:	ea0d0001 	movi      	r13, 1
    buf[len++] = '0';
 801315a:	331f      	movi      	r3, 31
  while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
 801315c:	6476      	cmpne      	r13, r1
 801315e:	0c09      	bf      	0x8013170	// 8013170 <_ftoa+0x36c>
    buf[len++] = '0';
 8013160:	e5ad0000 	addi      	r13, r13, 1
 8013164:	d4028000 	stbi.b      	r0, (r2)
    prec--;
 8013168:	e5081000 	subi      	r8, r8, 1
  while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
 801316c:	e823fff8 	bnezad      	r3, 0x801315c	// 801315c <_ftoa+0x358>
 8013170:	104c      	lrw      	r2, 0x8063814	// 80131a0 <_ftoa+0x39c>
 8013172:	c4684823 	lsli      	r3, r8, 3
 8013176:	60c8      	addu      	r3, r2
 8013178:	9340      	ld.w      	r2, (r3, 0x0)
 801317a:	9361      	ld.w      	r3, (r3, 0x4)
 801317c:	b847      	st.w      	r2, (r14, 0x1c)
 801317e:	b868      	st.w      	r3, (r14, 0x20)
 8013180:	06b1      	br      	0x8012ee2	// 8012ee2 <_ftoa+0xde>
 8013182:	0000      	.short	0x0000
 8013184:	08063804 	.long	0x08063804
 8013188:	080637fc 	.long	0x080637fc
 801318c:	41cdcd65 	.long	0x41cdcd65
 8013190:	c1cdcd65 	.long	0xc1cdcd65
 8013194:	412e8480 	.long	0x412e8480
 8013198:	08063808 	.long	0x08063808
 801319c:	0806380c 	.long	0x0806380c
 80131a0:	08063814 	.long	0x08063814
      buf[len++] = '-';
 80131a4:	312d      	movi      	r1, 45
 80131a6:	5a62      	addi      	r3, r2, 1
 80131a8:	d4540021 	str.b      	r1, (r20, r2 << 0)
 80131ac:	079f      	br      	0x80130ea	// 80130ea <_ftoa+0x2e6>
    if ((!(diff < 0.5) || (diff > 0.5)) && (whole & 1)) {
 80131ae:	6ca3      	mov      	r2, r8
 80131b0:	ea233fe0 	movih      	r3, 16352
 80131b4:	6c13      	mov      	r0, r4
 80131b6:	6c57      	mov      	r1, r5
 80131b8:	e3fff09a 	bsr      	0x80112ec	// 80112ec <__gtdf2>
 80131bc:	c410482d 	lsli      	r13, r16, 0
 80131c0:	c4114834 	lsli      	r20, r17, 0
 80131c4:	e960ff0a 	blsz      	r0, 0x8012fd8	// 8012fd8 <_ftoa+0x1d4>
 80131c8:	0700      	br      	0x8012fc8	// 8012fc8 <_ftoa+0x1c4>
      ++whole;
 80131ca:	6ce7      	mov      	r3, r9
 80131cc:	2300      	addi      	r3, 1
 80131ce:	6e4f      	mov      	r9, r3
      frac = 0;
 80131d0:	ea120000 	movi      	r18, 0
 80131d4:	06de      	br      	0x8012f90	// 8012f90 <_ftoa+0x18c>
  if (!(flags & FLAGS_LEFT) && (flags & FLAGS_ZEROPAD)) {
 80131d6:	3220      	movi      	r2, 32
    if (width && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
 80131d8:	9865      	ld.w      	r3, (r14, 0x14)
 80131da:	e903ff26 	bez      	r3, 0x8013026	// 8013026 <_ftoa+0x222>
 80131de:	986c      	ld.w      	r3, (r14, 0x30)
 80131e0:	e9230007 	bnez      	r3, 0x80131ee	// 80131ee <_ftoa+0x3ea>
 80131e4:	9866      	ld.w      	r3, (r14, 0x18)
 80131e6:	e463200c 	andi      	r3, r3, 12
 80131ea:	e9030005 	bez      	r3, 0x80131f4	// 80131f4 <_ftoa+0x3f0>
      width--;
 80131ee:	9865      	ld.w      	r3, (r14, 0x14)
 80131f0:	2b00      	subi      	r3, 1
 80131f2:	b865      	st.w      	r3, (r14, 0x14)
    while ((len < width) && (len < PRINTF_FTOA_BUFFER_SIZE)) {
 80131f4:	9865      	ld.w      	r3, (r14, 0x14)
 80131f6:	64c8      	cmphs      	r2, r3
 80131f8:	0b17      	bt      	0x8013026	// 8013026 <_ftoa+0x222>
 80131fa:	eb420020 	cmpnei      	r2, 32
 80131fe:	0c3d      	bf      	0x8013278	// 8013278 <_ftoa+0x474>
 8013200:	c4540021 	addu      	r1, r20, r2
 8013204:	6ccb      	mov      	r3, r2
      buf[len++] = '0';
 8013206:	3230      	movi      	r2, 48
 8013208:	0405      	br      	0x8013212	// 8013212 <_ftoa+0x40e>
    while ((len < width) && (len < PRINTF_FTOA_BUFFER_SIZE)) {
 801320a:	eb430020 	cmpnei      	r3, 32
 801320e:	2100      	addi      	r1, 1
 8013210:	0f6d      	bf      	0x80130ea	// 80130ea <_ftoa+0x2e6>
      buf[len++] = '0';
 8013212:	2300      	addi      	r3, 1
    while ((len < width) && (len < PRINTF_FTOA_BUFFER_SIZE)) {
 8013214:	9805      	ld.w      	r0, (r14, 0x14)
 8013216:	640e      	cmpne      	r3, r0
      buf[len++] = '0';
 8013218:	a140      	st.b      	r2, (r1, 0x0)
    while ((len < width) && (len < PRINTF_FTOA_BUFFER_SIZE)) {
 801321a:	0bf8      	bt      	0x801320a	// 801320a <_ftoa+0x406>
      buf[len++] = '0';
 801321c:	9845      	ld.w      	r2, (r14, 0x14)
 801321e:	0704      	br      	0x8013026	// 8013026 <_ftoa+0x222>
    value = 0 - value;
 8013220:	6c93      	mov      	r2, r4
 8013222:	9961      	ld.w      	r3, (r14, 0x84)
 8013224:	3000      	movi      	r0, 0
 8013226:	3100      	movi      	r1, 0
 8013228:	e3ffee9c 	bsr      	0x8010f60	// 8010f60 <__subdf3>
    negative = true;
 801322c:	3301      	movi      	r3, 1
    value = 0 - value;
 801322e:	6d03      	mov      	r4, r0
 8013230:	6d47      	mov      	r5, r1
    negative = true;
 8013232:	b86c      	st.w      	r3, (r14, 0x30)
 8013234:	064a      	br      	0x8012ec8	// 8012ec8 <_ftoa+0xc4>
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
 8013236:	eb420020 	cmpnei      	r2, 32
 801323a:	0f52      	bf      	0x80130de	// 80130de <_ftoa+0x2da>
 801323c:	e90c000e 	bez      	r12, 0x8013258	// 8013258 <_ftoa+0x454>
 8013240:	c4540023 	addu      	r3, r20, r2
 8013244:	6308      	addu      	r12, r2
      buf[len++] = '0';
 8013246:	3130      	movi      	r1, 48
 8013248:	2200      	addi      	r2, 1
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
 801324a:	eb420020 	cmpnei      	r2, 32
      buf[len++] = '0';
 801324e:	a320      	st.b      	r1, (r3, 0x0)
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
 8013250:	0f47      	bf      	0x80130de	// 80130de <_ftoa+0x2da>
 8013252:	670a      	cmpne      	r2, r12
 8013254:	2300      	addi      	r3, 1
 8013256:	0bf9      	bt      	0x8013248	// 8013248 <_ftoa+0x444>
      buf[len++] = '.';
 8013258:	332e      	movi      	r3, 46
 801325a:	e5a20000 	addi      	r13, r2, 1
 801325e:	d4540023 	str.b      	r3, (r20, r2 << 0)
 8013262:	06bb      	br      	0x8012fd8	// 8012fd8 <_ftoa+0x1d4>
    else if (flags & FLAGS_SPACE) {
 8013264:	9866      	ld.w      	r3, (r14, 0x18)
 8013266:	e4632008 	andi      	r3, r3, 8
 801326a:	e9030007 	bez      	r3, 0x8013278	// 8013278 <_ftoa+0x474>
      buf[len++] = ' ';
 801326e:	3120      	movi      	r1, 32
 8013270:	5a62      	addi      	r3, r2, 1
 8013272:	d4540021 	str.b      	r1, (r20, r2 << 0)
 8013276:	073a      	br      	0x80130ea	// 80130ea <_ftoa+0x2e6>
    else if (flags & FLAGS_SPACE) {
 8013278:	6ccb      	mov      	r3, r2
 801327a:	0738      	br      	0x80130ea	// 80130ea <_ftoa+0x2e6>
 801327c:	1047      	lrw      	r2, 0x8063814	// 8013298 <_ftoa+0x494>
 801327e:	4363      	lsli      	r3, r3, 3
 8013280:	60c8      	addu      	r3, r2
  while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
 8013282:	6e27      	mov      	r8, r9
 8013284:	9340      	ld.w      	r2, (r3, 0x0)
 8013286:	9361      	ld.w      	r3, (r3, 0x4)
 8013288:	b847      	st.w      	r2, (r14, 0x1c)
 801328a:	b868      	st.w      	r3, (r14, 0x20)
 801328c:	ea0d0000 	movi      	r13, 0
 8013290:	e68e0033 	addi      	r20, r14, 52
 8013294:	0627      	br      	0x8012ee2	// 8012ee2 <_ftoa+0xde>
 8013296:	0000      	.short	0x0000
 8013298:	08063814 	.long	0x08063814

0801329c <_etoa>:


#if defined(PRINTF_SUPPORT_EXPONENTIAL)
// internal ftoa variant for exponential floating-point type, contributed by Martijn Jasperse <m.jasperse@gmail.com>
static size_t _etoa(out_fct_type out, char* buffer, size_t idx, size_t maxlen, double value, unsigned int prec, unsigned int width, unsigned int flags)
{
 801329c:	ebe00058 	push      	r4-r11, r15, r16-r17
 80132a0:	1434      	subi      	r14, r14, 80
 80132a2:	6e0f      	mov      	r8, r3
 80132a4:	9961      	ld.w      	r3, (r14, 0x84)
 80132a6:	b867      	st.w      	r3, (r14, 0x1c)
 80132a8:	9962      	ld.w      	r3, (r14, 0x88)
 80132aa:	98bf      	ld.w      	r5, (r14, 0x7c)
 80132ac:	9980      	ld.w      	r4, (r14, 0x80)
 80132ae:	b868      	st.w      	r3, (r14, 0x20)
 80132b0:	9963      	ld.w      	r3, (r14, 0x8c)
 80132b2:	b866      	st.w      	r3, (r14, 0x18)
 80132b4:	6d83      	mov      	r6, r0
 80132b6:	6dc7      	mov      	r7, r1
 80132b8:	6ecb      	mov      	r11, r2
  // check for NaN and special values
  if ((value != value) || (value > DBL_MAX) || (value < -DBL_MAX)) {
 80132ba:	6cd3      	mov      	r3, r4
 80132bc:	6c97      	mov      	r2, r5
 80132be:	6c17      	mov      	r0, r5
 80132c0:	6c53      	mov      	r1, r4
 80132c2:	e3ffeff9 	bsr      	0x80112b4	// 80112b4 <__nedf2>
 80132c6:	6e43      	mov      	r9, r0
 80132c8:	e92001d7 	bnez      	r0, 0x8013676	// 8013676 <_etoa+0x3da>
 80132cc:	3200      	movi      	r2, 0
 80132ce:	ea237ff0 	movih      	r3, 32752
 80132d2:	2a00      	subi      	r2, 1
 80132d4:	2b00      	subi      	r3, 1
 80132d6:	6c17      	mov      	r0, r5
 80132d8:	6c53      	mov      	r1, r4
 80132da:	e3fff009 	bsr      	0x80112ec	// 80112ec <__gtdf2>
 80132de:	e94001cc 	bhz      	r0, 0x8013676	// 8013676 <_etoa+0x3da>
 80132e2:	3200      	movi      	r2, 0
 80132e4:	ea23fff0 	movih      	r3, 65520
 80132e8:	2a00      	subi      	r2, 1
 80132ea:	2b00      	subi      	r3, 1
 80132ec:	6c17      	mov      	r0, r5
 80132ee:	6c53      	mov      	r1, r4
 80132f0:	e3fff03e 	bsr      	0x801136c	// 801136c <__ltdf2>
 80132f4:	e98001c1 	blz      	r0, 0x8013676	// 8013676 <_etoa+0x3da>
    return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
  }

  // determine the sign
  const bool negative = value < 0;
  if (negative) {
 80132f8:	6ca7      	mov      	r2, r9
 80132fa:	6ce7      	mov      	r3, r9
 80132fc:	6c17      	mov      	r0, r5
 80132fe:	6c53      	mov      	r1, r4
 8013300:	e3fff036 	bsr      	0x801136c	// 801136c <__ltdf2>
    value = -value;
 8013304:	6e97      	mov      	r10, r5
  if (negative) {
 8013306:	e9800208 	blz      	r0, 0x8013716	// 8013716 <_etoa+0x47a>
 801330a:	6e53      	mov      	r9, r4
  }

  // default precision
  if (!(flags & FLAGS_PRECISION)) {
 801330c:	9866      	ld.w      	r3, (r14, 0x18)
 801330e:	e4632400 	andi      	r3, r3, 1024
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
 8013312:	3b40      	cmpnei      	r3, 0
 8013314:	9847      	ld.w      	r2, (r14, 0x1c)
  if (!(flags & FLAGS_PRECISION)) {
 8013316:	b873      	st.w      	r3, (r14, 0x4c)
    uint64_t U;
    double   F;
  } conv;

  conv.F = value;
  int exp2 = (int)((conv.U >> 52U) & 0x07FFU) - 1023;           // effectively log2
 8013318:	c68957c0 	zext      	r0, r9, 30, 20
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
 801331c:	3306      	movi      	r3, 6
 801331e:	c4430c20 	incf      	r2, r3, 0
  conv.U = (conv.U & ((1ULL << 52U) - 1U)) | (1023ULL << 52U);  // drop the exponent so conv.F is now in [1,2)
  // now approximate log10 from the log2 integer part and an expansion of ln around 1.5
  int expval = (int)(0.1760912590558 + exp2 * 0.301029995663981 + (conv.F - 1.5) * 0.289529654602168);
 8013322:	e40013fe 	subi      	r0, r0, 1023
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
 8013326:	b847      	st.w      	r2, (r14, 0x1c)
  int exp2 = (int)((conv.U >> 52U) & 0x07FFU) - 1023;           // effectively log2
 8013328:	dd4e200a 	st.w      	r10, (r14, 0x28)
 801332c:	dd2e2009 	st.w      	r9, (r14, 0x24)
  int expval = (int)(0.1760912590558 + exp2 * 0.301029995663981 + (conv.F - 1.5) * 0.289529654602168);
 8013330:	e3fff03a 	bsr      	0x80113a4	// 80113a4 <__floatsidf>
 8013334:	0145      	lrw      	r2, 0x509f79fb	// 801369c <_etoa+0x400>
 8013336:	0164      	lrw      	r3, 0x3fd34413	// 80136a0 <_etoa+0x404>
 8013338:	e3ffee32 	bsr      	0x8010f9c	// 8010f9c <__muldf3>
 801333c:	0145      	lrw      	r2, 0x8b60c8b3	// 80136a4 <_etoa+0x408>
 801333e:	0164      	lrw      	r3, 0x3fc68a28	// 80136a8 <_etoa+0x40c>
 8013340:	e3ffedf8 	bsr      	0x8010f30	// 8010f30 <__adddf3>
  conv.U = (conv.U & ((1ULL << 52U) - 1U)) | (1023ULL << 52U);  // drop the exponent so conv.F is now in [1,2)
 8013344:	d98e200a 	ld.w      	r12, (r14, 0x28)
 8013348:	da6e2009 	ld.w      	r19, (r14, 0x24)
 801334c:	c40c4836 	lsli      	r22, r12, 0
 8013350:	c4135677 	zext      	r23, r19, 19, 0
 8013354:	ea140000 	movi      	r20, 0
 8013358:	ea353ff0 	movih      	r21, 16368
  int expval = (int)(0.1760912590558 + exp2 * 0.301029995663981 + (conv.F - 1.5) * 0.289529654602168);
 801335c:	c4004831 	lsli      	r17, r0, 0
 8013360:	c4014830 	lsli      	r16, r1, 0
 8013364:	3200      	movi      	r2, 0
 8013366:	c6962420 	or      	r0, r22, r20
 801336a:	c6b72421 	or      	r1, r23, r21
 801336e:	ea233ff8 	movih      	r3, 16376
  conv.U = (conv.U & ((1ULL << 52U) - 1U)) | (1023ULL << 52U);  // drop the exponent so conv.F is now in [1,2)
 8013372:	dd8e2012 	st.w      	r12, (r14, 0x48)
 8013376:	de6e2011 	st.w      	r19, (r14, 0x44)
  int expval = (int)(0.1760912590558 + exp2 * 0.301029995663981 + (conv.F - 1.5) * 0.289529654602168);
 801337a:	de8e200f 	st.w      	r20, (r14, 0x3c)
 801337e:	deae2010 	st.w      	r21, (r14, 0x40)
 8013382:	e3ffedef 	bsr      	0x8010f60	// 8010f60 <__subdf3>
 8013386:	0155      	lrw      	r2, 0x636f4361	// 80136ac <_etoa+0x410>
 8013388:	0175      	lrw      	r3, 0x3fd287a7	// 80136b0 <_etoa+0x414>
 801338a:	e3ffee09 	bsr      	0x8010f9c	// 8010f9c <__muldf3>
 801338e:	6c83      	mov      	r2, r0
 8013390:	6cc7      	mov      	r3, r1
 8013392:	c4114820 	lsli      	r0, r17, 0
 8013396:	c4104821 	lsli      	r1, r16, 0
 801339a:	e3ffedcb 	bsr      	0x8010f30	// 8010f30 <__adddf3>
 801339e:	e3fff037 	bsr      	0x801140c	// 801140c <__fixdfsi>
 80133a2:	b809      	st.w      	r0, (r14, 0x24)
  // now we want to compute 10^expval but we want to be sure it won't overflow
  exp2 = (int)(expval * 3.321928094887362 + 0.5);
 80133a4:	e3fff000 	bsr      	0x80113a4	// 80113a4 <__floatsidf>
 80133a8:	015c      	lrw      	r2, 0x979a371	// 80136b4 <_etoa+0x418>
 80133aa:	017b      	lrw      	r3, 0x400a934f	// 80136b8 <_etoa+0x41c>
 80133ac:	c4004831 	lsli      	r17, r0, 0
 80133b0:	c4014830 	lsli      	r16, r1, 0
 80133b4:	e3ffedf4 	bsr      	0x8010f9c	// 8010f9c <__muldf3>
 80133b8:	3200      	movi      	r2, 0
 80133ba:	ea233fe0 	movih      	r3, 16352
 80133be:	e3ffedb9 	bsr      	0x8010f30	// 8010f30 <__adddf3>
 80133c2:	e3fff025 	bsr      	0x801140c	// 801140c <__fixdfsi>
 80133c6:	b80a      	st.w      	r0, (r14, 0x28)
  const double z  = expval * 2.302585092994046 - exp2 * 0.6931471805599453;
 80133c8:	0242      	lrw      	r2, 0xbbb55516	// 80136bc <_etoa+0x420>
 80133ca:	0261      	lrw      	r3, 0x40026bb1	// 80136c0 <_etoa+0x424>
 80133cc:	c4114820 	lsli      	r0, r17, 0
 80133d0:	c4104821 	lsli      	r1, r16, 0
 80133d4:	e3ffede4 	bsr      	0x8010f9c	// 8010f9c <__muldf3>
 80133d8:	c4004831 	lsli      	r17, r0, 0
 80133dc:	980a      	ld.w      	r0, (r14, 0x28)
 80133de:	c4014830 	lsli      	r16, r1, 0
 80133e2:	e3ffefe1 	bsr      	0x80113a4	// 80113a4 <__floatsidf>
 80133e6:	0247      	lrw      	r2, 0xfefa39ef	// 80136c4 <_etoa+0x428>
 80133e8:	0267      	lrw      	r3, 0x3fe62e42	// 80136c8 <_etoa+0x42c>
 80133ea:	e3ffedd9 	bsr      	0x8010f9c	// 8010f9c <__muldf3>
 80133ee:	6c83      	mov      	r2, r0
 80133f0:	6cc7      	mov      	r3, r1
 80133f2:	c4114820 	lsli      	r0, r17, 0
 80133f6:	c4104821 	lsli      	r1, r16, 0
 80133fa:	e3ffedb3 	bsr      	0x8010f60	// 8010f60 <__subdf3>
  const double z2 = z * z;
 80133fe:	6c83      	mov      	r2, r0
 8013400:	6cc7      	mov      	r3, r1
 8013402:	b80c      	st.w      	r0, (r14, 0x30)
 8013404:	b82b      	st.w      	r1, (r14, 0x2c)
 8013406:	e3ffedcb 	bsr      	0x8010f9c	// 8010f9c <__muldf3>
  conv.U = (uint64_t)(exp2 + 1023) << 52U;
  // compute exp(z) using continued fractions, see https://en.wikipedia.org/wiki/Exponential_function#Continued_fractions_for_ex
  conv.F *= 1 + 2 * z / (2 - z + (z2 / (6 + (z2 / (10 + z2 / 14)))));
 801340a:	da4e200c 	ld.w      	r18, (r14, 0x30)
 801340e:	d9ae200b 	ld.w      	r13, (r14, 0x2c)
 8013412:	c4124822 	lsli      	r2, r18, 0
 8013416:	6cf7      	mov      	r3, r13
  const double z2 = z * z;
 8013418:	c4004831 	lsli      	r17, r0, 0
 801341c:	c4014830 	lsli      	r16, r1, 0
  conv.F *= 1 + 2 * z / (2 - z + (z2 / (6 + (z2 / (10 + z2 / 14)))));
 8013420:	c4124820 	lsli      	r0, r18, 0
 8013424:	6c77      	mov      	r1, r13
 8013426:	de4e200e 	st.w      	r18, (r14, 0x38)
 801342a:	ddae200d 	st.w      	r13, (r14, 0x34)
 801342e:	e3ffed81 	bsr      	0x8010f30	// 8010f30 <__adddf3>
 8013432:	b80c      	st.w      	r0, (r14, 0x30)
 8013434:	b82b      	st.w      	r1, (r14, 0x2c)
 8013436:	3200      	movi      	r2, 0
 8013438:	ea23402c 	movih      	r3, 16428
 801343c:	c4114820 	lsli      	r0, r17, 0
 8013440:	c4104821 	lsli      	r1, r16, 0
 8013444:	e3ffeeac 	bsr      	0x801119c	// 801119c <__divdf3>
 8013448:	3200      	movi      	r2, 0
 801344a:	ea234024 	movih      	r3, 16420
 801344e:	e3ffed71 	bsr      	0x8010f30	// 8010f30 <__adddf3>
 8013452:	6c83      	mov      	r2, r0
 8013454:	6cc7      	mov      	r3, r1
 8013456:	c4114820 	lsli      	r0, r17, 0
 801345a:	c4104821 	lsli      	r1, r16, 0
 801345e:	e3ffee9f 	bsr      	0x801119c	// 801119c <__divdf3>
 8013462:	3200      	movi      	r2, 0
 8013464:	ea234018 	movih      	r3, 16408
 8013468:	e3ffed64 	bsr      	0x8010f30	// 8010f30 <__adddf3>
 801346c:	6c83      	mov      	r2, r0
 801346e:	6cc7      	mov      	r3, r1
 8013470:	c4114820 	lsli      	r0, r17, 0
 8013474:	c4104821 	lsli      	r1, r16, 0
 8013478:	e3ffee92 	bsr      	0x801119c	// 801119c <__divdf3>
 801347c:	da4e200e 	ld.w      	r18, (r14, 0x38)
 8013480:	d9ae200d 	ld.w      	r13, (r14, 0x34)
 8013484:	c4124822 	lsli      	r2, r18, 0
 8013488:	6cf7      	mov      	r3, r13
 801348a:	c4004831 	lsli      	r17, r0, 0
 801348e:	c4014830 	lsli      	r16, r1, 0
 8013492:	3000      	movi      	r0, 0
 8013494:	ea214000 	movih      	r1, 16384
 8013498:	e3ffed64 	bsr      	0x8010f60	// 8010f60 <__subdf3>
 801349c:	6c83      	mov      	r2, r0
 801349e:	6cc7      	mov      	r3, r1
 80134a0:	c4114820 	lsli      	r0, r17, 0
 80134a4:	c4104821 	lsli      	r1, r16, 0
 80134a8:	e3ffed44 	bsr      	0x8010f30	// 8010f30 <__adddf3>
 80134ac:	daee200c 	ld.w      	r23, (r14, 0x30)
 80134b0:	dace200b 	ld.w      	r22, (r14, 0x2c)
 80134b4:	6c83      	mov      	r2, r0
 80134b6:	6cc7      	mov      	r3, r1
 80134b8:	c4174820 	lsli      	r0, r23, 0
 80134bc:	c4164821 	lsli      	r1, r22, 0
 80134c0:	e3ffee6e 	bsr      	0x801119c	// 801119c <__divdf3>
 80134c4:	da8e200f 	ld.w      	r20, (r14, 0x3c)
 80134c8:	daae2010 	ld.w      	r21, (r14, 0x40)
 80134cc:	c4144822 	lsli      	r2, r20, 0
 80134d0:	c4154823 	lsli      	r3, r21, 0
 80134d4:	e3ffed2e 	bsr      	0x8010f30	// 8010f30 <__adddf3>
  conv.U = (uint64_t)(exp2 + 1023) << 52U;
 80134d8:	984a      	ld.w      	r2, (r14, 0x28)
 80134da:	e46203fe 	addi      	r3, r2, 1023
  conv.F *= 1 + 2 * z / (2 - z + (z2 / (6 + (z2 / (10 + z2 / 14)))));
 80134de:	4374      	lsli      	r3, r3, 20
 80134e0:	3200      	movi      	r2, 0
 80134e2:	e3ffed5d 	bsr      	0x8010f9c	// 8010f9c <__muldf3>
  // correct for rounding errors
  if (value < conv.F) {
 80134e6:	d98e2012 	ld.w      	r12, (r14, 0x48)
 80134ea:	da6e2011 	ld.w      	r19, (r14, 0x44)
 80134ee:	6c83      	mov      	r2, r0
 80134f0:	c4004830 	lsli      	r16, r0, 0
 80134f4:	6cc7      	mov      	r3, r1
  conv.F *= 1 + 2 * z / (2 - z + (z2 / (6 + (z2 / (10 + z2 / 14)))));
 80134f6:	c4014831 	lsli      	r17, r1, 0
  if (value < conv.F) {
 80134fa:	6c33      	mov      	r0, r12
 80134fc:	c4134821 	lsli      	r1, r19, 0
 8013500:	e3ffef36 	bsr      	0x801136c	// 801136c <__ltdf2>
 8013504:	c4104832 	lsli      	r18, r16, 0
 8013508:	e9a00012 	bhsz      	r0, 0x801352c	// 801352c <_etoa+0x290>
    expval--;
 801350c:	9869      	ld.w      	r3, (r14, 0x24)
 801350e:	2b00      	subi      	r3, 1
 8013510:	b869      	st.w      	r3, (r14, 0x24)
    conv.F /= 10;
 8013512:	c4114821 	lsli      	r1, r17, 0
 8013516:	3200      	movi      	r2, 0
 8013518:	ea234024 	movih      	r3, 16420
 801351c:	c4104820 	lsli      	r0, r16, 0
 8013520:	e3ffee3e 	bsr      	0x801119c	// 801119c <__divdf3>
 8013524:	c4004832 	lsli      	r18, r0, 0
 8013528:	c4014831 	lsli      	r17, r1, 0
  }

  // the exponent format is "%+03d" and largest value is "307", so set aside 4-5 characters
  unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
 801352c:	9849      	ld.w      	r2, (r14, 0x24)
 801352e:	e4620062 	addi      	r3, r2, 99
 8013532:	eb0300c6 	cmphsi      	r3, 199

  // in "%g" mode, "prec" is the number of *significant figures* not decimals
  if (flags & FLAGS_ADAPT_EXP) {
 8013536:	9866      	ld.w      	r3, (r14, 0x18)
 8013538:	e4632800 	andi      	r3, r3, 2048
  unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
 801353c:	c4000510 	mvc      	r16
 8013540:	e6100003 	addi      	r16, r16, 4
  if (flags & FLAGS_ADAPT_EXP) {
 8013544:	e9030027 	bez      	r3, 0x8013592	// 8013592 <_etoa+0x2f6>
    // do we want to fall-back to "%f" mode?
    if ((value >= 1e-4) && (value < 1e6)) {
 8013548:	1341      	lrw      	r2, 0xeb1c432d	// 80136cc <_etoa+0x430>
 801354a:	1362      	lrw      	r3, 0x3f1a36e2	// 80136d0 <_etoa+0x434>
 801354c:	6c2b      	mov      	r0, r10
 801354e:	6c67      	mov      	r1, r9
 8013550:	de4e200a 	st.w      	r18, (r14, 0x28)
 8013554:	e3ffeeec 	bsr      	0x801132c	// 801132c <__gedf2>
 8013558:	da4e200a 	ld.w      	r18, (r14, 0x28)
 801355c:	e98000cd 	blz      	r0, 0x80136f6	// 80136f6 <_etoa+0x45a>
 8013560:	3200      	movi      	r2, 0
 8013562:	127d      	lrw      	r3, 0x412e8480	// 80136d4 <_etoa+0x438>
 8013564:	6c2b      	mov      	r0, r10
 8013566:	6c67      	mov      	r1, r9
 8013568:	e3ffef02 	bsr      	0x801136c	// 801136c <__ltdf2>
 801356c:	da4e200a 	ld.w      	r18, (r14, 0x28)
 8013570:	e9a000c3 	bhsz      	r0, 0x80136f6	// 80136f6 <_etoa+0x45a>
      if ((int)prec > expval) {
 8013574:	9849      	ld.w      	r2, (r14, 0x24)
 8013576:	9867      	ld.w      	r3, (r14, 0x1c)
 8013578:	64c9      	cmplt      	r2, r3
 801357a:	0cd4      	bf      	0x8013722	// 8013722 <_etoa+0x486>
        prec = (unsigned)((int)prec - expval - 1);
 801357c:	60ca      	subu      	r3, r2
 801357e:	2b00      	subi      	r3, 1
 8013580:	b867      	st.w      	r3, (r14, 0x1c)
      }
      else {
        prec = 0;
      }
      flags |= FLAGS_PRECISION;   // make sure _ftoa respects precision
 8013582:	9866      	ld.w      	r3, (r14, 0x18)
 8013584:	ec630400 	ori      	r3, r3, 1024
      // no characters in exponent
      minwidth = 0U;
 8013588:	ea100000 	movi      	r16, 0
      flags |= FLAGS_PRECISION;   // make sure _ftoa respects precision
 801358c:	b866      	st.w      	r3, (r14, 0x18)
      expval   = 0;
 801358e:	de0e2009 	st.w      	r16, (r14, 0x24)

  // will everything fit?
  unsigned int fwidth = width;
  if (width > minwidth) {
    // we didn't fall-back so subtract the characters required for the exponent
    fwidth -= minwidth;
 8013592:	9848      	ld.w      	r2, (r14, 0x20)
 8013594:	c602008c 	subu      	r12, r2, r16
 8013598:	c4500420 	cmphs      	r16, r2
  } else {
    // not enough characters, so go back to default sizing
    fwidth = 0U;
  }
  if ((flags & FLAGS_LEFT) && minwidth) {
 801359c:	9846      	ld.w      	r2, (r14, 0x18)
 801359e:	e4422002 	andi      	r2, r2, 2
    fwidth -= minwidth;
 80135a2:	3300      	movi      	r3, 0
 80135a4:	c5830c40 	inct      	r12, r3, 0
  if ((flags & FLAGS_LEFT) && minwidth) {
 80135a8:	b84a      	st.w      	r2, (r14, 0x28)
 80135aa:	e9020006 	bez      	r2, 0x80135b6	// 80135b6 <_etoa+0x31a>
    // if we're padding on the right, DON'T pad the floating part
    fwidth = 0U;
 80135ae:	eb500000 	cmpnei      	r16, 0
 80135b2:	c5830c40 	inct      	r12, r3, 0
  }

  // rescale the float value
  if (expval) {
 80135b6:	9869      	ld.w      	r3, (r14, 0x24)
 80135b8:	e9230090 	bnez      	r3, 0x80136d8	// 80136d8 <_etoa+0x43c>
    value /= conv.F;
  }

  // output the floating part
  const size_t start_idx = idx;
  idx = _ftoa(out, buffer, idx, maxlen, negative ? -value : value, prec, fwidth, flags & ~FLAGS_ADAPT_EXP);
 80135bc:	3200      	movi      	r2, 0
 80135be:	6ccb      	mov      	r3, r2
 80135c0:	6c17      	mov      	r0, r5
 80135c2:	6c53      	mov      	r1, r4
 80135c4:	c40c4831 	lsli      	r17, r12, 0
 80135c8:	e3ffeed2 	bsr      	0x801136c	// 801136c <__ltdf2>
 80135cc:	c411482c 	lsli      	r12, r17, 0
 80135d0:	e980009e 	blz      	r0, 0x801370c	// 801370c <_etoa+0x470>
 80135d4:	da2e2006 	ld.w      	r17, (r14, 0x18)
 80135d8:	98a7      	ld.w      	r5, (r14, 0x1c)
 80135da:	c5712823 	bclri      	r3, r17, 11
 80135de:	b864      	st.w      	r3, (r14, 0x10)
 80135e0:	dd2e2001 	st.w      	r9, (r14, 0x4)
 80135e4:	dd8e2003 	st.w      	r12, (r14, 0xc)
 80135e8:	b8a2      	st.w      	r5, (r14, 0x8)
 80135ea:	dd4e2000 	st.w      	r10, (r14, 0x0)
 80135ee:	6ce3      	mov      	r3, r8
 80135f0:	6caf      	mov      	r2, r11
 80135f2:	6c5f      	mov      	r1, r7
 80135f4:	6c1b      	mov      	r0, r6
 80135f6:	e3fffc07 	bsr      	0x8012e04	// 8012e04 <_ftoa>
 80135fa:	6d03      	mov      	r4, r0

  // output the exponent part
  if (!prec && minwidth) {
 80135fc:	6e57      	mov      	r9, r5
 80135fe:	e925004b 	bnez      	r5, 0x8013694	// 8013694 <_etoa+0x3f8>
 8013602:	e9100049 	bez      	r16, 0x8013694	// 8013694 <_etoa+0x3f8>
    // output the exponential symbol
    out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
 8013606:	e4712020 	andi      	r3, r17, 32
 801360a:	3b40      	cmpnei      	r3, 0
 801360c:	6c83      	mov      	r2, r0
 801360e:	ea0c0065 	movi      	r12, 101
 8013612:	58a2      	addi      	r5, r0, 1
 8013614:	3045      	movi      	r0, 69
 8013616:	c40c0c20 	incf      	r0, r12, 0
 801361a:	6ce3      	mov      	r3, r8
 801361c:	6c5f      	mov      	r1, r7
 801361e:	7bd9      	jsr      	r6
    // output the exponent value
    idx = _ntoa_long(out, buffer, idx, maxlen, (expval < 0) ? -expval : expval, expval < 0, 10, 0, minwidth-1, FLAGS_ZEROPAD | FLAGS_PLUS);
 8013620:	3305      	movi      	r3, 5
 8013622:	9849      	ld.w      	r2, (r14, 0x24)
 8013624:	b865      	st.w      	r3, (r14, 0x14)
 8013626:	330a      	movi      	r3, 10
 8013628:	b862      	st.w      	r3, (r14, 0x8)
 801362a:	4a7f      	lsri      	r3, r2, 31
 801362c:	b861      	st.w      	r3, (r14, 0x4)
 801362e:	e6101000 	subi      	r16, r16, 1
 8013632:	c4020203 	abs      	r3, r2
 8013636:	b860      	st.w      	r3, (r14, 0x0)
 8013638:	de0e2004 	st.w      	r16, (r14, 0x10)
 801363c:	6ce3      	mov      	r3, r8
 801363e:	dd2e2003 	st.w      	r9, (r14, 0xc)
 8013642:	6c97      	mov      	r2, r5
 8013644:	6c5f      	mov      	r1, r7
 8013646:	6c1b      	mov      	r0, r6
 8013648:	e3fffb12 	bsr      	0x8012c6c	// 8012c6c <_ntoa_long>
    // might need to right-pad spaces
    if (flags & FLAGS_LEFT) {
 801364c:	986a      	ld.w      	r3, (r14, 0x28)
    idx = _ntoa_long(out, buffer, idx, maxlen, (expval < 0) ? -expval : expval, expval < 0, 10, 0, minwidth-1, FLAGS_ZEROPAD | FLAGS_PLUS);
 801364e:	6d03      	mov      	r4, r0
    if (flags & FLAGS_LEFT) {
 8013650:	e9030022 	bez      	r3, 0x8013694	// 8013694 <_etoa+0x3f8>
      while (idx - start_idx < width) out(' ', buffer, idx++, maxlen);
 8013654:	c5600083 	subu      	r3, r0, r11
 8013658:	98a8      	ld.w      	r5, (r14, 0x20)
 801365a:	654c      	cmphs      	r3, r5
 801365c:	081c      	bt      	0x8013694	// 8013694 <_etoa+0x3f8>
 801365e:	6c83      	mov      	r2, r0
 8013660:	2400      	addi      	r4, 1
 8013662:	6ce3      	mov      	r3, r8
 8013664:	6c5f      	mov      	r1, r7
 8013666:	3020      	movi      	r0, 32
 8013668:	7bd9      	jsr      	r6
 801366a:	c5640083 	subu      	r3, r4, r11
 801366e:	654c      	cmphs      	r3, r5
 8013670:	6c93      	mov      	r2, r4
 8013672:	0ff7      	bf      	0x8013660	// 8013660 <_etoa+0x3c4>
 8013674:	0410      	br      	0x8013694	// 8013694 <_etoa+0x3f8>
    return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
 8013676:	9866      	ld.w      	r3, (r14, 0x18)
 8013678:	b864      	st.w      	r3, (r14, 0x10)
 801367a:	9868      	ld.w      	r3, (r14, 0x20)
 801367c:	b863      	st.w      	r3, (r14, 0xc)
 801367e:	9867      	ld.w      	r3, (r14, 0x1c)
 8013680:	b862      	st.w      	r3, (r14, 0x8)
 8013682:	b881      	st.w      	r4, (r14, 0x4)
 8013684:	b8a0      	st.w      	r5, (r14, 0x0)
 8013686:	6ce3      	mov      	r3, r8
 8013688:	6caf      	mov      	r2, r11
 801368a:	6c5f      	mov      	r1, r7
 801368c:	6c1b      	mov      	r0, r6
 801368e:	e3fffbbb 	bsr      	0x8012e04	// 8012e04 <_ftoa>
 8013692:	6d03      	mov      	r4, r0
    }
  }
  return idx;
}
 8013694:	6c13      	mov      	r0, r4
 8013696:	1414      	addi      	r14, r14, 80
 8013698:	ebc00058 	pop      	r4-r11, r15, r16-r17
 801369c:	509f79fb 	.long	0x509f79fb
 80136a0:	3fd34413 	.long	0x3fd34413
 80136a4:	8b60c8b3 	.long	0x8b60c8b3
 80136a8:	3fc68a28 	.long	0x3fc68a28
 80136ac:	636f4361 	.long	0x636f4361
 80136b0:	3fd287a7 	.long	0x3fd287a7
 80136b4:	0979a371 	.long	0x0979a371
 80136b8:	400a934f 	.long	0x400a934f
 80136bc:	bbb55516 	.long	0xbbb55516
 80136c0:	40026bb1 	.long	0x40026bb1
 80136c4:	fefa39ef 	.long	0xfefa39ef
 80136c8:	3fe62e42 	.long	0x3fe62e42
 80136cc:	eb1c432d 	.long	0xeb1c432d
 80136d0:	3f1a36e2 	.long	0x3f1a36e2
 80136d4:	412e8480 	.long	0x412e8480
    value /= conv.F;
 80136d8:	6c2b      	mov      	r0, r10
 80136da:	6c67      	mov      	r1, r9
 80136dc:	c4124822 	lsli      	r2, r18, 0
 80136e0:	c4114823 	lsli      	r3, r17, 0
 80136e4:	dd8e200b 	st.w      	r12, (r14, 0x2c)
 80136e8:	e3ffed5a 	bsr      	0x801119c	// 801119c <__divdf3>
 80136ec:	6e83      	mov      	r10, r0
 80136ee:	6e47      	mov      	r9, r1
 80136f0:	d98e200b 	ld.w      	r12, (r14, 0x2c)
 80136f4:	0764      	br      	0x80135bc	// 80135bc <_etoa+0x320>
      if ((prec > 0) && (flags & FLAGS_PRECISION)) {
 80136f6:	9847      	ld.w      	r2, (r14, 0x1c)
 80136f8:	e902ff4d 	bez      	r2, 0x8013592	// 8013592 <_etoa+0x2f6>
        --prec;
 80136fc:	9873      	ld.w      	r3, (r14, 0x4c)
 80136fe:	3b40      	cmpnei      	r3, 0
 8013700:	c4620c20 	incf      	r3, r2, 0
 8013704:	c4620d01 	dect      	r3, r2, 1
 8013708:	b867      	st.w      	r3, (r14, 0x1c)
 801370a:	0744      	br      	0x8013592	// 8013592 <_etoa+0x2f6>
  idx = _ftoa(out, buffer, idx, maxlen, negative ? -value : value, prec, fwidth, flags & ~FLAGS_ADAPT_EXP);
 801370c:	ea238000 	movih      	r3, 32768
 8013710:	60e4      	addu      	r3, r9
 8013712:	6e4f      	mov      	r9, r3
 8013714:	0760      	br      	0x80135d4	// 80135d4 <_etoa+0x338>
    value = -value;
 8013716:	ea238000 	movih      	r3, 32768
 801371a:	c4640029 	addu      	r9, r4, r3
 801371e:	e800fdf7 	br      	0x801330c	// 801330c <_etoa+0x70>
      if ((int)prec > expval) {
 8013722:	3300      	movi      	r3, 0
 8013724:	072e      	br      	0x8013580	// 8013580 <_etoa+0x2e4>
	...

08013728 <_vsnprintf>:
#endif  // PRINTF_SUPPORT_FLOAT


// internal vsnprintf
static int _vsnprintf(out_fct_type out, char* buffer, const size_t maxlen, const char* format, va_list va)
{
 8013728:	ebe00058 	push      	r4-r11, r15, r16-r17
 801372c:	1436      	subi      	r14, r14, 88
  unsigned int flags, width, precision, n;
  size_t idx = 0U;

  if (!buffer) {
    // use null output function
    out = _out_null;
 801372e:	3940      	cmpnei      	r1, 0
 8013730:	10cf      	lrw      	r6, 0x80129e4	// 801376c <_vsnprintf+0x44>
{
 8013732:	6e07      	mov      	r8, r1
 8013734:	6dcb      	mov      	r7, r2
 8013736:	6d4f      	mov      	r5, r3
 8013738:	9981      	ld.w      	r4, (r14, 0x84)
    out = _out_null;
 801373a:	c4c00c40 	inct      	r6, r0, 0
        format++;
        break;
      }

      case '%' :
        out('%', buffer, idx++, maxlen);
 801373e:	ea0b0000 	movi      	r11, 0
      switch (*format) {
 8013742:	ea89000c 	lrw      	r9, 0x806361c	// 8013770 <_vsnprintf+0x48>
  while (*format)
 8013746:	8500      	ld.b      	r0, (r5, 0x0)
 8013748:	e900006f 	bez      	r0, 0x8013826	// 8013826 <_vsnprintf+0xfe>
    if (*format != '%') {
 801374c:	eb400025 	cmpnei      	r0, 37
 8013750:	0860      	bt      	0x8013810	// 8013810 <_vsnprintf+0xe8>
      format++;
 8013752:	5d42      	addi      	r2, r5, 1
    flags = 0U;
 8013754:	3100      	movi      	r1, 0
      switch (*format) {
 8013756:	8200      	ld.b      	r0, (r2, 0x0)
 8013758:	e460101f 	subi      	r3, r0, 32
 801375c:	74cc      	zextb      	r3, r3
 801375e:	3b10      	cmphsi      	r3, 17
 8013760:	6d4b      	mov      	r5, r2
 8013762:	081d      	bt      	0x801379c	// 801379c <_vsnprintf+0x74>
 8013764:	d0690883 	ldr.w      	r3, (r9, r3 << 2)
 8013768:	780c      	jmp      	r3
 801376a:	0000      	.short	0x0000
 801376c:	080129e4 	.long	0x080129e4
 8013770:	0806361c 	.long	0x0806361c
        case '0': flags |= FLAGS_ZEROPAD; format++; n = 1U; break;
 8013774:	ec210001 	ori      	r1, r1, 1
 8013778:	2200      	addi      	r2, 1
 801377a:	07ee      	br      	0x8013756	// 8013756 <_vsnprintf+0x2e>
        case ' ': flags |= FLAGS_SPACE;   format++; n = 1U; break;
 801377c:	ec210008 	ori      	r1, r1, 8
 8013780:	2200      	addi      	r2, 1
 8013782:	07ea      	br      	0x8013756	// 8013756 <_vsnprintf+0x2e>
        case '#': flags |= FLAGS_HASH;    format++; n = 1U; break;
 8013784:	ec210010 	ori      	r1, r1, 16
 8013788:	2200      	addi      	r2, 1
 801378a:	07e6      	br      	0x8013756	// 8013756 <_vsnprintf+0x2e>
        case '+': flags |= FLAGS_PLUS;    format++; n = 1U; break;
 801378c:	ec210004 	ori      	r1, r1, 4
 8013790:	2200      	addi      	r2, 1
 8013792:	07e2      	br      	0x8013756	// 8013756 <_vsnprintf+0x2e>
        case '-': flags |= FLAGS_LEFT;    format++; n = 1U; break;
 8013794:	ec210002 	ori      	r1, r1, 2
 8013798:	2200      	addi      	r2, 1
 801379a:	07de      	br      	0x8013756	// 8013756 <_vsnprintf+0x2e>
  return (ch >= '0') && (ch <= '9');
 801379c:	e460102f 	subi      	r3, r0, 48
    if (_is_digit(*format)) {
 80137a0:	74cc      	zextb      	r3, r3
 80137a2:	3b09      	cmphsi      	r3, 10
 80137a4:	0c5b      	bf      	0x801385a	// 801385a <_vsnprintf+0x132>
    else if (*format == '*') {
 80137a6:	eb40002a 	cmpnei      	r0, 42
 80137aa:	e84003c3 	bf      	0x8013f30	// 8013f30 <_vsnprintf+0x808>
    width = 0U;
 80137ae:	ea110000 	movi      	r17, 0
    if (*format == '.') {
 80137b2:	eb40002e 	cmpnei      	r0, 46
 80137b6:	0c65      	bf      	0x8013880	// 8013880 <_vsnprintf+0x158>
    precision = 0U;
 80137b8:	ea0a0000 	movi      	r10, 0
    switch (*format) {
 80137bc:	e4601067 	subi      	r3, r0, 104
 80137c0:	74cc      	zextb      	r3, r3
 80137c2:	3b12      	cmphsi      	r3, 19
 80137c4:	080c      	bt      	0x80137dc	// 80137dc <_vsnprintf+0xb4>
 80137c6:	1043      	lrw      	r2, 0x8063660	// 80137d0 <_vsnprintf+0xa8>
 80137c8:	d0620883 	ldr.w      	r3, (r2, r3 << 2)
 80137cc:	780c      	jmp      	r3
 80137ce:	0000      	.short	0x0000
 80137d0:	08063660 	.long	0x08063660
 80137d4:	8501      	ld.b      	r0, (r5, 0x1)
        flags |= (sizeof(size_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
 80137d6:	ec210100 	ori      	r1, r1, 256
        format++;
 80137da:	2500      	addi      	r5, 1
    switch (*format) {
 80137dc:	e4601024 	subi      	r3, r0, 37
 80137e0:	74cc      	zextb      	r3, r3
 80137e2:	eb030053 	cmphsi      	r3, 84
 80137e6:	0815      	bt      	0x8013810	// 8013810 <_vsnprintf+0xe8>
 80137e8:	1042      	lrw      	r2, 0x80636ac	// 80137f0 <_vsnprintf+0xc8>
 80137ea:	d0620883 	ldr.w      	r3, (r2, r3 << 2)
 80137ee:	780c      	jmp      	r3
 80137f0:	080636ac 	.long	0x080636ac
        if (*format == 'l') {
 80137f4:	8501      	ld.b      	r0, (r5, 0x1)
 80137f6:	eb40006c 	cmpnei      	r0, 108
 80137fa:	e84003ac 	bf      	0x8013f52	// 8013f52 <_vsnprintf+0x82a>
    switch (*format) {
 80137fe:	e4601024 	subi      	r3, r0, 37
 8013802:	74cc      	zextb      	r3, r3
 8013804:	eb030053 	cmphsi      	r3, 84
        flags |= FLAGS_LONG;
 8013808:	ec210100 	ori      	r1, r1, 256
        format++;
 801380c:	2500      	addi      	r5, 1
    switch (*format) {
 801380e:	0fed      	bf      	0x80137e8	// 80137e8 <_vsnprintf+0xc0>
        format++;
        break;

      default :
        out(*format, buffer, idx++, maxlen);
        format++;
 8013810:	2500      	addi      	r5, 1
        out(*format, buffer, idx++, maxlen);
 8013812:	6caf      	mov      	r2, r11
 8013814:	6cdf      	mov      	r3, r7
 8013816:	6c63      	mov      	r1, r8
 8013818:	7bd9      	jsr      	r6
  while (*format)
 801381a:	8500      	ld.b      	r0, (r5, 0x0)
        out(*format, buffer, idx++, maxlen);
 801381c:	e54b0000 	addi      	r10, r11, 1
 8013820:	6eeb      	mov      	r11, r10
  while (*format)
 8013822:	e920ff95 	bnez      	r0, 0x801374c	// 801374c <_vsnprintf+0x24>
        break;
    }
  }

  // termination
  out((char)0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);
 8013826:	65ec      	cmphs      	r11, r7
 8013828:	e8400381 	bf      	0x8013f2a	// 8013f2a <_vsnprintf+0x802>
 801382c:	5f43      	subi      	r2, r7, 1
 801382e:	6cdf      	mov      	r3, r7
 8013830:	6c63      	mov      	r1, r8
 8013832:	3000      	movi      	r0, 0
 8013834:	7bd9      	jsr      	r6

  // return written chars without terminating \0
  return (int)idx;
}
 8013836:	6c2f      	mov      	r0, r11
 8013838:	1416      	addi      	r14, r14, 88
 801383a:	ebc00058 	pop      	r4-r11, r15, r16-r17
        if (*format == 'h') {
 801383e:	8501      	ld.b      	r0, (r5, 0x1)
 8013840:	eb400068 	cmpnei      	r0, 104
 8013844:	e8400381 	bf      	0x8013f46	// 8013f46 <_vsnprintf+0x81e>
        flags |= FLAGS_SHORT;
 8013848:	ec210080 	ori      	r1, r1, 128
        format++;
 801384c:	2500      	addi      	r5, 1
 801384e:	07c7      	br      	0x80137dc	// 80137dc <_vsnprintf+0xb4>
 8013850:	8501      	ld.b      	r0, (r5, 0x1)
        flags |= (sizeof(intmax_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
 8013852:	ec210200 	ori      	r1, r1, 512
        format++;
 8013856:	2500      	addi      	r5, 1
        break;
 8013858:	07c2      	br      	0x80137dc	// 80137dc <_vsnprintf+0xb4>
 801385a:	ea110000 	movi      	r17, 0
    i = i * 10U + (unsigned int)(*((*str)++) - '0');
 801385e:	ea0d000a 	movi      	r13, 10
  while (_is_digit(**str)) {
 8013862:	3209      	movi      	r2, 9
    i = i * 10U + (unsigned int)(*((*str)++) - '0');
 8013864:	2500      	addi      	r5, 1
 8013866:	f9b18440 	mula.32.l      	r0, r17, r13
 801386a:	e620102f 	subi      	r17, r0, 48
  while (_is_digit(**str)) {
 801386e:	8500      	ld.b      	r0, (r5, 0x0)
  return (ch >= '0') && (ch <= '9');
 8013870:	e460102f 	subi      	r3, r0, 48
  while (_is_digit(**str)) {
 8013874:	74cc      	zextb      	r3, r3
 8013876:	64c8      	cmphs      	r2, r3
 8013878:	0bf6      	bt      	0x8013864	// 8013864 <_vsnprintf+0x13c>
    if (*format == '.') {
 801387a:	eb40002e 	cmpnei      	r0, 46
 801387e:	0b9d      	bt      	0x80137b8	// 80137b8 <_vsnprintf+0x90>
      if (_is_digit(*format)) {
 8013880:	8501      	ld.b      	r0, (r5, 0x1)
  return (ch >= '0') && (ch <= '9');
 8013882:	e460102f 	subi      	r3, r0, 48
      if (_is_digit(*format)) {
 8013886:	74cc      	zextb      	r3, r3
 8013888:	3b09      	cmphsi      	r3, 10
      flags |= FLAGS_PRECISION;
 801388a:	ec210400 	ori      	r1, r1, 1024
      format++;
 801388e:	5d42      	addi      	r2, r5, 1
      if (_is_digit(*format)) {
 8013890:	0813      	bt      	0x80138b6	// 80138b6 <_vsnprintf+0x18e>
 8013892:	6d4b      	mov      	r5, r2
 8013894:	ea0a0000 	movi      	r10, 0
    i = i * 10U + (unsigned int)(*((*str)++) - '0');
 8013898:	ea12000a 	movi      	r18, 10
  while (_is_digit(**str)) {
 801389c:	3209      	movi      	r2, 9
    i = i * 10U + (unsigned int)(*((*str)++) - '0');
 801389e:	2500      	addi      	r5, 1
 80138a0:	fa4a8440 	mula.32.l      	r0, r10, r18
 80138a4:	e540102f 	subi      	r10, r0, 48
  while (_is_digit(**str)) {
 80138a8:	8500      	ld.b      	r0, (r5, 0x0)
  return (ch >= '0') && (ch <= '9');
 80138aa:	e460102f 	subi      	r3, r0, 48
  while (_is_digit(**str)) {
 80138ae:	74cc      	zextb      	r3, r3
 80138b0:	64c8      	cmphs      	r2, r3
 80138b2:	0bf6      	bt      	0x801389e	// 801389e <_vsnprintf+0x176>
 80138b4:	0784      	br      	0x80137bc	// 80137bc <_vsnprintf+0x94>
      else if (*format == '*') {
 80138b6:	eb40002a 	cmpnei      	r0, 42
 80138ba:	e84003e2 	bf      	0x801407e	// 801407e <_vsnprintf+0x956>
      format++;
 80138be:	6d4b      	mov      	r5, r2
 80138c0:	077c      	br      	0x80137b8	// 80137b8 <_vsnprintf+0x90>
        uint32_t ipv4 = va_arg(va, uint32_t);
 80138c2:	5c6e      	addi      	r3, r4, 4
 80138c4:	3000      	movi      	r0, 0
 80138c6:	dac42000 	ld.w      	r22, (r4, 0x0)
 80138ca:	b869      	st.w      	r3, (r14, 0x24)
 80138cc:	6d03      	mov      	r4, r0
            h = bit / 100;
 80138ce:	ea140064 	movi      	r20, 100
            m = (bit % 100) / 10;
 80138d2:	ea13000a 	movi      	r19, 10
                    outtxt[j++] = '0';
 80138d6:	ea170030 	movi      	r23, 48
            outtxt[j++] = '.';
 80138da:	ea15002e 	movi      	r21, 46
 80138de:	ea120004 	movi      	r18, 4
            bit = (*inuint >> (8 * i)) & 0xff;
 80138e2:	c4164043 	lsr      	r3, r22, r0
 80138e6:	74cc      	zextb      	r3, r3
            h = bit / 100;
 80138e8:	c6838022 	divu      	r2, r3, r20
 80138ec:	7748      	zextb      	r13, r2
            if (h)
 80138ee:	e90d0306 	bez      	r13, 0x8013efa	// 8013efa <_vsnprintf+0x7d2>
            m = (bit % 100) / 10;
 80138f2:	c6828422 	mult      	r2, r2, r20
 80138f6:	60ca      	subu      	r3, r2
 80138f8:	74cc      	zextb      	r3, r3
                outtxt[j++] = '0' + h;
 80138fa:	e70e002f 	addi      	r24, r14, 48
            m = (bit % 100) / 10;
 80138fe:	c6638022 	divu      	r2, r3, r19
                outtxt[j++] = '0' + h;
 8013902:	e5840000 	addi      	r12, r4, 1
 8013906:	e5ad002f 	addi      	r13, r13, 48
 801390a:	7730      	zextb      	r12, r12
 801390c:	d498002d 	str.b      	r13, (r24, r4 << 0)
            if (m)
 8013910:	e92202fe 	bnez      	r2, 0x8013f0c	// 8013f0c <_vsnprintf+0x7e4>
                    outtxt[j++] = '0';
 8013914:	1a0c      	addi      	r2, r14, 48
 8013916:	2401      	addi      	r4, 2
 8013918:	7510      	zextb      	r4, r4
 801391a:	d5820037 	str.b      	r23, (r2, r12 << 0)
            l = (bit % 100) % 10;
 801391e:	c6638022 	divu      	r2, r3, r19
 8013922:	c6628422 	mult      	r2, r2, r19
 8013926:	60ca      	subu      	r3, r2
            outtxt[j++] = '0' + l;
 8013928:	1a0c      	addi      	r2, r14, 48
 801392a:	e5840000 	addi      	r12, r4, 1
 801392e:	232f      	addi      	r3, 48
 8013930:	d4820023 	str.b      	r3, (r2, r4 << 0)
 8013934:	7730      	zextb      	r12, r12
            outtxt[j++] = '.';
 8013936:	2401      	addi      	r4, 2
 8013938:	7510      	zextb      	r4, r4
 801393a:	d5820035 	str.b      	r21, (r2, r12 << 0)
 801393e:	2007      	addi      	r0, 8
        for(i = 0; i < 4; i++)
 8013940:	e832ffd1 	bnezad      	r18, 0x80138e2	// 80138e2 <_vsnprintf+0x1ba>
    outtxt[j - 1] = 0;
 8013944:	e46e002e 	addi      	r3, r14, 47
 8013948:	3200      	movi      	r2, 0
 801394a:	d4830022 	str.b      	r2, (r3, r4 << 0)
    return j - 1;
 801394e:	5c63      	subi      	r3, r4, 1
        if (flags & FLAGS_PRECISION) {
 8013950:	e4412400 	andi      	r2, r1, 1024
    return j - 1;
 8013954:	6c0f      	mov      	r0, r3
          l = (l < precision ? l : precision);
 8013956:	3a40      	cmpnei      	r2, 0
 8013958:	f943cd23 	min.u32      	r3, r3, r10
        if (flags & FLAGS_PRECISION) {
 801395c:	b84a      	st.w      	r2, (r14, 0x28)
          l = (l < precision ? l : precision);
 801395e:	6c83      	mov      	r2, r0
 8013960:	c4430c40 	inct      	r2, r3, 0
        if (!(flags & FLAGS_LEFT)) {
 8013964:	e4612002 	andi      	r3, r1, 2
          l = (l < precision ? l : precision);
 8013968:	b848      	st.w      	r2, (r14, 0x20)
        if (!(flags & FLAGS_LEFT)) {
 801396a:	b86b      	st.w      	r3, (r14, 0x2c)
 801396c:	e9230333 	bnez      	r3, 0x8013fd2	// 8013fd2 <_vsnprintf+0x8aa>
          while (l++ < width) {
 8013970:	c6220420 	cmphs      	r2, r17
 8013974:	6ccb      	mov      	r3, r2
 8013976:	2300      	addi      	r3, 1
 8013978:	e86003ff 	bt      	0x8014176	// 8014176 <_vsnprintf+0xa4e>
 801397c:	c5710023 	addu      	r3, r17, r11
 8013980:	5b89      	subu      	r4, r3, r2
 8013982:	6caf      	mov      	r2, r11
            out(' ', buffer, idx++, maxlen);
 8013984:	e56b0000 	addi      	r11, r11, 1
 8013988:	6cdf      	mov      	r3, r7
 801398a:	6c63      	mov      	r1, r8
 801398c:	3020      	movi      	r0, 32
 801398e:	7bd9      	jsr      	r6
          while (l++ < width) {
 8013990:	66d2      	cmpne      	r4, r11
 8013992:	6caf      	mov      	r2, r11
 8013994:	0bf8      	bt      	0x8013984	// 8013984 <_vsnprintf+0x25c>
 8013996:	e4710000 	addi      	r3, r17, 1
 801399a:	b868      	st.w      	r3, (r14, 0x20)
        while ((*pstr != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 801399c:	d80e0030 	ld.b      	r0, (r14, 0x30)
 80139a0:	e9000030 	bez      	r0, 0x8013a00	// 8013a00 <_vsnprintf+0x2d8>
 80139a4:	6caf      	mov      	r2, r11
 80139a6:	e60e002f 	addi      	r16, r14, 48
 80139aa:	d96e200a 	ld.w      	r11, (r14, 0x28)
 80139ae:	0402      	br      	0x80139b2	// 80139b2 <_vsnprintf+0x28a>
          out(*(pstr++), buffer, idx++, maxlen);
 80139b0:	6c93      	mov      	r2, r4
        while ((*pstr != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 80139b2:	e90b0007 	bez      	r11, 0x80139c0	// 80139c0 <_vsnprintf+0x298>
 80139b6:	e46a1000 	subi      	r3, r10, 1
 80139ba:	e90a034a 	bez      	r10, 0x801404e	// 801404e <_vsnprintf+0x926>
 80139be:	6e8f      	mov      	r10, r3
          out(*(pstr++), buffer, idx++, maxlen);
 80139c0:	e6100000 	addi      	r16, r16, 1
 80139c4:	6cdf      	mov      	r3, r7
 80139c6:	6c63      	mov      	r1, r8
 80139c8:	5a82      	addi      	r4, r2, 1
 80139ca:	7bd9      	jsr      	r6
        while ((*pstr != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 80139cc:	d8100000 	ld.b      	r0, (r16, 0x0)
 80139d0:	e920fff0 	bnez      	r0, 0x80139b0	// 80139b0 <_vsnprintf+0x288>
        if (flags & FLAGS_LEFT) {
 80139d4:	986b      	ld.w      	r3, (r14, 0x2c)
 80139d6:	e90302a5 	bez      	r3, 0x8013f20	// 8013f20 <_vsnprintf+0x7f8>
          while (l++ < width) {
 80139da:	9868      	ld.w      	r3, (r14, 0x20)
 80139dc:	c6230420 	cmphs      	r3, r17
 80139e0:	e86002a0 	bt      	0x8013f20	// 8013f20 <_vsnprintf+0x7f8>
 80139e4:	c4910020 	addu      	r0, r17, r4
 80139e8:	c460008a 	subu      	r10, r0, r3
 80139ec:	6c93      	mov      	r2, r4
            out(' ', buffer, idx++, maxlen);
 80139ee:	e5620000 	addi      	r11, r2, 1
 80139f2:	6cdf      	mov      	r3, r7
 80139f4:	6c63      	mov      	r1, r8
 80139f6:	3020      	movi      	r0, 32
 80139f8:	7bd9      	jsr      	r6
          while (l++ < width) {
 80139fa:	66ea      	cmpne      	r10, r11
 80139fc:	6caf      	mov      	r2, r11
 80139fe:	0bf8      	bt      	0x80139ee	// 80139ee <_vsnprintf+0x2c6>
        format++;
 8013a00:	2500      	addi      	r5, 1
        char *ipv6 = va_arg(va, char*);
 8013a02:	9889      	ld.w      	r4, (r14, 0x24)
 8013a04:	06a1      	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
        const char* p = va_arg(va, char*);
 8013a06:	da042000 	ld.w      	r16, (r4, 0x0)
 8013a0a:	5c6e      	addi      	r3, r4, 4
 8013a0c:	b868      	st.w      	r3, (r14, 0x20)
  for (s = str; *s && maxsize--; ++s);
 8013a0e:	d8100000 	ld.b      	r0, (r16, 0x0)
        unsigned int l = _strnlen_s(p, precision ? precision : (size_t)-1);
 8013a12:	3300      	movi      	r3, 0
 8013a14:	2b00      	subi      	r3, 1
 8013a16:	eb4a0000 	cmpnei      	r10, 0
 8013a1a:	c46a0c40 	inct      	r3, r10, 0
  for (s = str; *s && maxsize--; ++s);
 8013a1e:	c4104824 	lsli      	r4, r16, 0
 8013a22:	e9200006 	bnez      	r0, 0x8013a2e	// 8013a2e <_vsnprintf+0x306>
 8013a26:	0408      	br      	0x8013a36	// 8013a36 <_vsnprintf+0x30e>
 8013a28:	2b00      	subi      	r3, 1
 8013a2a:	e9030006 	bez      	r3, 0x8013a36	// 8013a36 <_vsnprintf+0x30e>
 8013a2e:	2400      	addi      	r4, 1
 8013a30:	8440      	ld.b      	r2, (r4, 0x0)
 8013a32:	e922fffb 	bnez      	r2, 0x8013a28	// 8013a28 <_vsnprintf+0x300>
  return (unsigned int)(s - str);
 8013a36:	c6040084 	subu      	r4, r4, r16
        if (flags & FLAGS_PRECISION) {
 8013a3a:	e4412400 	andi      	r2, r1, 1024
          l = (l < precision ? l : precision);
 8013a3e:	f944cd23 	min.u32      	r3, r4, r10
 8013a42:	3a40      	cmpnei      	r2, 0
 8013a44:	c4830c40 	inct      	r4, r3, 0
        if (!(flags & FLAGS_LEFT)) {
 8013a48:	e4612002 	andi      	r3, r1, 2
        if (flags & FLAGS_PRECISION) {
 8013a4c:	b849      	st.w      	r2, (r14, 0x24)
        if (!(flags & FLAGS_LEFT)) {
 8013a4e:	b86a      	st.w      	r3, (r14, 0x28)
 8013a50:	e9230287 	bnez      	r3, 0x8013f5e	// 8013f5e <_vsnprintf+0x836>
          while (l++ < width) {
 8013a54:	c6240420 	cmphs      	r4, r17
 8013a58:	5c62      	addi      	r3, r4, 1
 8013a5a:	e860039c 	bt      	0x8014192	// 8014192 <_vsnprintf+0xa6a>
 8013a5e:	c5710023 	addu      	r3, r17, r11
 8013a62:	5b91      	subu      	r4, r3, r4
 8013a64:	6caf      	mov      	r2, r11
            out(' ', buffer, idx++, maxlen);
 8013a66:	e5620000 	addi      	r11, r2, 1
 8013a6a:	6cdf      	mov      	r3, r7
 8013a6c:	6c63      	mov      	r1, r8
 8013a6e:	3020      	movi      	r0, 32
 8013a70:	7bd9      	jsr      	r6
          while (l++ < width) {
 8013a72:	66d2      	cmpne      	r4, r11
 8013a74:	6caf      	mov      	r2, r11
 8013a76:	0bf8      	bt      	0x8013a66	// 8013a66 <_vsnprintf+0x33e>
 8013a78:	c40b4832 	lsli      	r18, r11, 0
 8013a7c:	e4910000 	addi      	r4, r17, 1
 8013a80:	d8100000 	ld.b      	r0, (r16, 0x0)
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 8013a84:	e9000391 	bez      	r0, 0x80141a6	// 80141a6 <_vsnprintf+0xa7e>
 8013a88:	b88b      	st.w      	r4, (r14, 0x2c)
 8013a8a:	c4124822 	lsli      	r2, r18, 0
 8013a8e:	d96e2009 	ld.w      	r11, (r14, 0x24)
 8013a92:	0402      	br      	0x8013a96	// 8013a96 <_vsnprintf+0x36e>
          out(*(p++), buffer, idx++, maxlen);
 8013a94:	6c93      	mov      	r2, r4
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 8013a96:	e90b0007 	bez      	r11, 0x8013aa4	// 8013aa4 <_vsnprintf+0x37c>
 8013a9a:	e46a1000 	subi      	r3, r10, 1
 8013a9e:	e90a02d2 	bez      	r10, 0x8014042	// 8014042 <_vsnprintf+0x91a>
 8013aa2:	6e8f      	mov      	r10, r3
          out(*(p++), buffer, idx++, maxlen);
 8013aa4:	e6100000 	addi      	r16, r16, 1
 8013aa8:	6cdf      	mov      	r3, r7
 8013aaa:	6c63      	mov      	r1, r8
 8013aac:	5a82      	addi      	r4, r2, 1
 8013aae:	7bd9      	jsr      	r6
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 8013ab0:	d8100000 	ld.b      	r0, (r16, 0x0)
 8013ab4:	e920fff0 	bnez      	r0, 0x8013a94	// 8013a94 <_vsnprintf+0x36c>
 8013ab8:	6ed3      	mov      	r11, r4
 8013aba:	988b      	ld.w      	r4, (r14, 0x2c)
        if (flags & FLAGS_LEFT) {
 8013abc:	986a      	ld.w      	r3, (r14, 0x28)
 8013abe:	e9030012 	bez      	r3, 0x8013ae2	// 8013ae2 <_vsnprintf+0x3ba>
          while (l++ < width) {
 8013ac2:	c6240420 	cmphs      	r4, r17
 8013ac6:	080e      	bt      	0x8013ae2	// 8013ae2 <_vsnprintf+0x3ba>
 8013ac8:	c5710020 	addu      	r0, r17, r11
 8013acc:	5891      	subu      	r4, r0, r4
 8013ace:	6caf      	mov      	r2, r11
            out(' ', buffer, idx++, maxlen);
 8013ad0:	e56b0000 	addi      	r11, r11, 1
 8013ad4:	6cdf      	mov      	r3, r7
 8013ad6:	6c63      	mov      	r1, r8
 8013ad8:	3020      	movi      	r0, 32
 8013ada:	7bd9      	jsr      	r6
          while (l++ < width) {
 8013adc:	66d2      	cmpne      	r4, r11
 8013ade:	6caf      	mov      	r2, r11
 8013ae0:	0bf8      	bt      	0x8013ad0	// 8013ad0 <_vsnprintf+0x3a8>
        format++;
 8013ae2:	2500      	addi      	r5, 1
        const char* p = va_arg(va, char*);
 8013ae4:	9888      	ld.w      	r4, (r14, 0x20)
        break;
 8013ae6:	0630      	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
          idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)((uintptr_t)va_arg(va, void*)), false, 16U, precision, width, flags);
 8013ae8:	3308      	movi      	r3, 8
 8013aea:	b864      	st.w      	r3, (r14, 0x10)
 8013aec:	3310      	movi      	r3, 16
 8013aee:	b862      	st.w      	r3, (r14, 0x8)
        flags |= FLAGS_ZEROPAD | FLAGS_UPPERCASE;
 8013af0:	ec210021 	ori      	r1, r1, 33
          idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)((uintptr_t)va_arg(va, void*)), false, 16U, precision, width, flags);
 8013af4:	3300      	movi      	r3, 0
 8013af6:	b825      	st.w      	r1, (r14, 0x14)
 8013af8:	dd4e2003 	st.w      	r10, (r14, 0xc)
 8013afc:	b861      	st.w      	r3, (r14, 0x4)
 8013afe:	9460      	ld.w      	r3, (r4, 0x0)
 8013b00:	b860      	st.w      	r3, (r14, 0x0)
 8013b02:	6caf      	mov      	r2, r11
 8013b04:	6cdf      	mov      	r3, r7
 8013b06:	6c63      	mov      	r1, r8
 8013b08:	6c1b      	mov      	r0, r6
 8013b0a:	e6040003 	addi      	r16, r4, 4
 8013b0e:	e3fff8af 	bsr      	0x8012c6c	// 8012c6c <_ntoa_long>
 8013b12:	6ec3      	mov      	r11, r0
        format++;
 8013b14:	2500      	addi      	r5, 1
          idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)((uintptr_t)va_arg(va, void*)), false, 16U, precision, width, flags);
 8013b16:	c4104824 	lsli      	r4, r16, 0
        break;
 8013b1a:	0616      	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
        if (!(flags & FLAGS_LEFT)) {
 8013b1c:	e4212002 	andi      	r1, r1, 2
 8013b20:	e9210227 	bnez      	r1, 0x8013f6e	// 8013f6e <_vsnprintf+0x846>
          while (l++ < width) {
 8013b24:	3301      	movi      	r3, 1
 8013b26:	c6230420 	cmphs      	r3, r17
 8013b2a:	e860032f 	bt      	0x8014188	// 8014188 <_vsnprintf+0xa60>
 8013b2e:	e60b1000 	subi      	r16, r11, 1
 8013b32:	c6300030 	addu      	r16, r16, r17
 8013b36:	6caf      	mov      	r2, r11
            out(' ', buffer, idx++, maxlen);
 8013b38:	e5420000 	addi      	r10, r2, 1
 8013b3c:	6cdf      	mov      	r3, r7
 8013b3e:	6c63      	mov      	r1, r8
 8013b40:	3020      	movi      	r0, 32
 8013b42:	7bd9      	jsr      	r6
          while (l++ < width) {
 8013b44:	c5500480 	cmpne      	r16, r10
 8013b48:	6cab      	mov      	r2, r10
 8013b4a:	0bf7      	bt      	0x8013b38	// 8013b38 <_vsnprintf+0x410>
        out((char)va_arg(va, int), buffer, idx++, maxlen);
 8013b4c:	8400      	ld.b      	r0, (r4, 0x0)
 8013b4e:	e6040003 	addi      	r16, r4, 4
 8013b52:	6cdf      	mov      	r3, r7
 8013b54:	6cab      	mov      	r2, r10
 8013b56:	6c63      	mov      	r1, r8
 8013b58:	e56a0000 	addi      	r11, r10, 1
 8013b5c:	7bd9      	jsr      	r6
 8013b5e:	c4104824 	lsli      	r4, r16, 0
        format++;
 8013b62:	2500      	addi      	r5, 1
        break;
 8013b64:	e800fdf1 	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
        if (*format == 'x' || *format == 'X') {
 8013b68:	eb400078 	cmpnei      	r0, 120
 8013b6c:	e8400277 	bf      	0x801405a	// 801405a <_vsnprintf+0x932>
 8013b70:	eb400058 	cmpnei      	r0, 88
 8013b74:	e8400275 	bf      	0x801405e	// 801405e <_vsnprintf+0x936>
        else if (*format == 'o') {
 8013b78:	eb40006f 	cmpnei      	r0, 111
 8013b7c:	e8400232 	bf      	0x8013fe0	// 8013fe0 <_vsnprintf+0x8b8>
        else if (*format == 'b') {
 8013b80:	eb400062 	cmpnei      	r0, 98
 8013b84:	e84002d5 	bf      	0x801412e	// 801412e <_vsnprintf+0xa06>
        if ((*format != 'i') && (*format != 'd')) {
 8013b88:	eb400069 	cmpnei      	r0, 105
          flags &= ~FLAGS_HASH;   // no hash for dec format
 8013b8c:	c4812823 	bclri      	r3, r1, 4
        if ((*format != 'i') && (*format != 'd')) {
 8013b90:	e8600232 	bt      	0x8013ff4	// 8013ff4 <_vsnprintf+0x8cc>
        if (flags & FLAGS_PRECISION) {
 8013b94:	e4212400 	andi      	r1, r1, 1024
          base = 10U;
 8013b98:	320a      	movi      	r2, 10
        if (flags & FLAGS_PRECISION) {
 8013b9a:	e9010236 	bez      	r1, 0x8014006	// 8014006 <_vsnprintf+0x8de>
          flags &= ~FLAGS_ZEROPAD;
 8013b9e:	3b80      	bclri      	r3, 0
        if ((*format == 'i') || (*format == 'd')) {
 8013ba0:	eb400069 	cmpnei      	r0, 105
 8013ba4:	e8400231 	bf      	0x8014006	// 8014006 <_vsnprintf+0x8de>
 8013ba8:	eb400064 	cmpnei      	r0, 100
 8013bac:	e840022d 	bf      	0x8014006	// 8014006 <_vsnprintf+0x8de>
          if (flags & FLAGS_LONG_LONG) {
 8013bb0:	e4232200 	andi      	r1, r3, 512
 8013bb4:	e9210276 	bnez      	r1, 0x80140a0	// 80140a0 <_vsnprintf+0x978>
          else if (flags & FLAGS_LONG) {
 8013bb8:	e4032100 	andi      	r0, r3, 256
 8013bbc:	e92002a2 	bnez      	r0, 0x8014100	// 8014100 <_vsnprintf+0x9d8>
            const unsigned int value = (flags & FLAGS_CHAR) ? (unsigned char)va_arg(va, unsigned int) : (flags & FLAGS_SHORT) ? (unsigned short int)va_arg(va, unsigned int) : va_arg(va, unsigned int);
 8013bc0:	e4232040 	andi      	r1, r3, 64
 8013bc4:	e92102cf 	bnez      	r1, 0x8014162	// 8014162 <_vsnprintf+0xa3a>
 8013bc8:	e4232080 	andi      	r1, r3, 128
 8013bcc:	e92102b3 	bnez      	r1, 0x8014132	// 8014132 <_vsnprintf+0xa0a>
 8013bd0:	9420      	ld.w      	r1, (r4, 0x0)
 8013bd2:	2403      	addi      	r4, 4
            idx = _ntoa_long(out, buffer, idx, maxlen, value, false, base, precision, width, flags);
 8013bd4:	b865      	st.w      	r3, (r14, 0x14)
 8013bd6:	3300      	movi      	r3, 0
 8013bd8:	de2e2004 	st.w      	r17, (r14, 0x10)
 8013bdc:	dd4e2003 	st.w      	r10, (r14, 0xc)
 8013be0:	b842      	st.w      	r2, (r14, 0x8)
 8013be2:	b861      	st.w      	r3, (r14, 0x4)
 8013be4:	b820      	st.w      	r1, (r14, 0x0)
 8013be6:	6caf      	mov      	r2, r11
 8013be8:	6cdf      	mov      	r3, r7
 8013bea:	6c63      	mov      	r1, r8
 8013bec:	6c1b      	mov      	r0, r6
 8013bee:	e3fff83f 	bsr      	0x8012c6c	// 8012c6c <_ntoa_long>
 8013bf2:	6ec3      	mov      	r11, r0
        format++;
 8013bf4:	2500      	addi      	r5, 1
 8013bf6:	e800fda8 	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
        if (*format == 'F') flags |= FLAGS_UPPERCASE;
 8013bfa:	eb400046 	cmpnei      	r0, 70
 8013bfe:	e840023c 	bf      	0x8014076	// 8014076 <_vsnprintf+0x94e>
        idx = _ftoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
 8013c02:	b824      	st.w      	r1, (r14, 0x10)
 8013c04:	de2e2003 	st.w      	r17, (r14, 0xc)
 8013c08:	dd4e2002 	st.w      	r10, (r14, 0x8)
 8013c0c:	e6040007 	addi      	r16, r4, 8
 8013c10:	9460      	ld.w      	r3, (r4, 0x0)
 8013c12:	9481      	ld.w      	r4, (r4, 0x4)
 8013c14:	b860      	st.w      	r3, (r14, 0x0)
 8013c16:	b881      	st.w      	r4, (r14, 0x4)
 8013c18:	6caf      	mov      	r2, r11
 8013c1a:	6cdf      	mov      	r3, r7
 8013c1c:	6c63      	mov      	r1, r8
 8013c1e:	6c1b      	mov      	r0, r6
 8013c20:	e3fff8f2 	bsr      	0x8012e04	// 8012e04 <_ftoa>
 8013c24:	6ec3      	mov      	r11, r0
        format++;
 8013c26:	2500      	addi      	r5, 1
        idx = _ftoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
 8013c28:	c4104824 	lsli      	r4, r16, 0
        break;
 8013c2c:	e800fd8d 	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
        out('%', buffer, idx++, maxlen);
 8013c30:	6caf      	mov      	r2, r11
 8013c32:	e54b0000 	addi      	r10, r11, 1
 8013c36:	6cdf      	mov      	r3, r7
 8013c38:	6c63      	mov      	r1, r8
 8013c3a:	3025      	movi      	r0, 37
 8013c3c:	7bd9      	jsr      	r6
        format++;
 8013c3e:	2500      	addi      	r5, 1
        out('%', buffer, idx++, maxlen);
 8013c40:	6eeb      	mov      	r11, r10
        break;
 8013c42:	e800fd82 	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
        char *ipv6 = va_arg(va, char*);
 8013c46:	5c6e      	addi      	r3, r4, 4
 8013c48:	dac42000 	ld.w      	r22, (r4, 0x0)
 8013c4c:	b869      	st.w      	r3, (r14, 0x24)
 8013c4e:	e716000f 	addi      	r24, r22, 16
 8013c52:	3400      	movi      	r4, 0
                if (h > 9)
 8013c54:	ea140009 	movi      	r20, 9
                    outtxt[j++] = ':';
 8013c58:	ea17003a 	movi      	r23, 58
          while (l++ < width) {
 8013c5c:	ea0c0000 	movi      	r12, 0
 8013c60:	da562000 	ld.w      	r18, (r22, 0x0)
 8013c64:	6c33      	mov      	r0, r12
 8013c66:	ea0d0004 	movi      	r13, 4
                m = (*inuint >> (8 * i)) & 0xff;
 8013c6a:	c5924043 	lsr      	r3, r18, r12
 8013c6e:	74cc      	zextb      	r3, r3
                h = m >> 4;
 8013c70:	4b44      	lsri      	r2, r3, 4
                if (h > 9)
 8013c72:	c4540420 	cmphs      	r20, r2
                    outtxt[j++] = 'A' + h - 10;
 8013c76:	e6640000 	addi      	r19, r4, 1
                l = m & 0xf;
 8013c7a:	e463200f 	andi      	r3, r3, 15
                    outtxt[j++] = 'A' + h - 10;
 8013c7e:	c41354f3 	zext      	r19, r19, 7, 0
                if (h > 9)
 8013c82:	092e      	bt      	0x8013ede	// 8013ede <_vsnprintf+0x7b6>
                    outtxt[j++] = 'A' + h - 10;
 8013c84:	e6ae002f 	addi      	r21, r14, 48
 8013c88:	2236      	addi      	r2, 55
 8013c8a:	d4950022 	str.b      	r2, (r21, r4 << 0)
                if (l > 9)
 8013c8e:	c4740420 	cmphs      	r20, r3
                    outtxt[j++] = 'A' + l - 10;
 8013c92:	e4930000 	addi      	r4, r19, 1
 8013c96:	7510      	zextb      	r4, r4
                if (l > 9)
 8013c98:	091e      	bt      	0x8013ed4	// 8013ed4 <_vsnprintf+0x7ac>
                    outtxt[j++] = 'A' + l - 10;
 8013c9a:	1a0c      	addi      	r2, r14, 48
 8013c9c:	2336      	addi      	r3, 55
 8013c9e:	d6620023 	str.b      	r3, (r2, r19 << 0)
                if (0 != (i % 2))
 8013ca2:	e4602001 	andi      	r3, r0, 1
 8013ca6:	e9030007 	bez      	r3, 0x8013cb4	// 8013cb4 <_vsnprintf+0x58c>
                    outtxt[j++] = ':';
 8013caa:	1a0c      	addi      	r2, r14, 48
 8013cac:	5c62      	addi      	r3, r4, 1
 8013cae:	d4820037 	str.b      	r23, (r2, r4 << 0)
 8013cb2:	750c      	zextb      	r4, r3
            for(i = 0; i < 4; i++)
 8013cb4:	2000      	addi      	r0, 1
 8013cb6:	7400      	zextb      	r0, r0
 8013cb8:	e58c0007 	addi      	r12, r12, 8
 8013cbc:	e82dffd7 	bnezad      	r13, 0x8013c6a	// 8013c6a <_vsnprintf+0x542>
            inuint++;
 8013cc0:	e6d60003 	addi      	r22, r22, 4
        for (k = 0; k < 4; k++)
 8013cc4:	c6d80480 	cmpne      	r24, r22
 8013cc8:	0bca      	bt      	0x8013c5c	// 8013c5c <_vsnprintf+0x534>
    outtxt[j - 1] = 0;
 8013cca:	e46e002e 	addi      	r3, r14, 47
 8013cce:	3200      	movi      	r2, 0
 8013cd0:	d4830022 	str.b      	r2, (r3, r4 << 0)
    return j - 1;
 8013cd4:	5c63      	subi      	r3, r4, 1
        if (flags & FLAGS_PRECISION) {
 8013cd6:	e4412400 	andi      	r2, r1, 1024
    return j - 1;
 8013cda:	6c0f      	mov      	r0, r3
          l = (l < precision ? l : precision);
 8013cdc:	3a40      	cmpnei      	r2, 0
 8013cde:	f943cd23 	min.u32      	r3, r3, r10
        if (flags & FLAGS_PRECISION) {
 8013ce2:	b84a      	st.w      	r2, (r14, 0x28)
          l = (l < precision ? l : precision);
 8013ce4:	6c83      	mov      	r2, r0
 8013ce6:	c4430c40 	inct      	r2, r3, 0
        if (!(flags & FLAGS_LEFT)) {
 8013cea:	e4612002 	andi      	r3, r1, 2
          l = (l < precision ? l : precision);
 8013cee:	b848      	st.w      	r2, (r14, 0x20)
        if (!(flags & FLAGS_LEFT)) {
 8013cf0:	b86b      	st.w      	r3, (r14, 0x2c)
 8013cf2:	e923015a 	bnez      	r3, 0x8013fa6	// 8013fa6 <_vsnprintf+0x87e>
          while (l++ < width) {
 8013cf6:	c6220420 	cmphs      	r2, r17
 8013cfa:	6ccb      	mov      	r3, r2
 8013cfc:	2300      	addi      	r3, 1
 8013cfe:	e8600239 	bt      	0x8014170	// 8014170 <_vsnprintf+0xa48>
 8013d02:	c5710023 	addu      	r3, r17, r11
 8013d06:	5b89      	subu      	r4, r3, r2
 8013d08:	6caf      	mov      	r2, r11
            out(' ', buffer, idx++, maxlen);
 8013d0a:	e56b0000 	addi      	r11, r11, 1
 8013d0e:	6cdf      	mov      	r3, r7
 8013d10:	6c63      	mov      	r1, r8
 8013d12:	3020      	movi      	r0, 32
 8013d14:	7bd9      	jsr      	r6
          while (l++ < width) {
 8013d16:	66d2      	cmpne      	r4, r11
 8013d18:	6caf      	mov      	r2, r11
 8013d1a:	0bf8      	bt      	0x8013d0a	// 8013d0a <_vsnprintf+0x5e2>
 8013d1c:	e4710000 	addi      	r3, r17, 1
 8013d20:	b868      	st.w      	r3, (r14, 0x20)
        while ((*pstr != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 8013d22:	d80e0030 	ld.b      	r0, (r14, 0x30)
 8013d26:	e900fe6d 	bez      	r0, 0x8013a00	// 8013a00 <_vsnprintf+0x2d8>
 8013d2a:	6caf      	mov      	r2, r11
 8013d2c:	e60e002f 	addi      	r16, r14, 48
 8013d30:	d96e200a 	ld.w      	r11, (r14, 0x28)
 8013d34:	0402      	br      	0x8013d38	// 8013d38 <_vsnprintf+0x610>
          out(*(pstr++), buffer, idx++, maxlen);
 8013d36:	6c93      	mov      	r2, r4
        while ((*pstr != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 8013d38:	e90b0007 	bez      	r11, 0x8013d46	// 8013d46 <_vsnprintf+0x61e>
 8013d3c:	e46a1000 	subi      	r3, r10, 1
 8013d40:	e90a0185 	bez      	r10, 0x801404a	// 801404a <_vsnprintf+0x922>
 8013d44:	6e8f      	mov      	r10, r3
          out(*(pstr++), buffer, idx++, maxlen);
 8013d46:	e6100000 	addi      	r16, r16, 1
 8013d4a:	6cdf      	mov      	r3, r7
 8013d4c:	6c63      	mov      	r1, r8
 8013d4e:	5a82      	addi      	r4, r2, 1
 8013d50:	7bd9      	jsr      	r6
        while ((*pstr != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 8013d52:	d8100000 	ld.b      	r0, (r16, 0x0)
 8013d56:	e920fff0 	bnez      	r0, 0x8013d36	// 8013d36 <_vsnprintf+0x60e>
        if (flags & FLAGS_LEFT) {
 8013d5a:	986b      	ld.w      	r3, (r14, 0x2c)
 8013d5c:	e90300e2 	bez      	r3, 0x8013f20	// 8013f20 <_vsnprintf+0x7f8>
          while (l++ < width) {
 8013d60:	9868      	ld.w      	r3, (r14, 0x20)
 8013d62:	c6230420 	cmphs      	r3, r17
 8013d66:	08dd      	bt      	0x8013f20	// 8013f20 <_vsnprintf+0x7f8>
 8013d68:	c4910020 	addu      	r0, r17, r4
 8013d6c:	c460008a 	subu      	r10, r0, r3
 8013d70:	6c93      	mov      	r2, r4
            out(' ', buffer, idx++, maxlen);
 8013d72:	e5620000 	addi      	r11, r2, 1
 8013d76:	6cdf      	mov      	r3, r7
 8013d78:	6c63      	mov      	r1, r8
 8013d7a:	3020      	movi      	r0, 32
 8013d7c:	7bd9      	jsr      	r6
          while (l++ < width) {
 8013d7e:	66ea      	cmpne      	r10, r11
 8013d80:	6caf      	mov      	r2, r11
 8013d82:	0bf8      	bt      	0x8013d72	// 8013d72 <_vsnprintf+0x64a>
        format++;
 8013d84:	2500      	addi      	r5, 1
        char *ipv6 = va_arg(va, char*);
 8013d86:	9889      	ld.w      	r4, (r14, 0x24)
 8013d88:	e800fcdf 	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
        const char* p = va_arg(va, char*);
 8013d8c:	5c6e      	addi      	r3, r4, 4
 8013d8e:	b869      	st.w      	r3, (r14, 0x24)
 8013d90:	da642000 	ld.w      	r19, (r4, 0x0)
 8013d94:	1a0c      	addi      	r2, r14, 48
        if (hbit > 9)
 8013d96:	ea140009 	movi      	r20, 9
        outtxt[3 * i + 2] = '-';
 8013d9a:	ea15002d 	movi      	r21, 45
 8013d9e:	ea120006 	movi      	r18, 6
        hbit = (*(inchar + i) & 0xf0) >> 4;
 8013da2:	d8730000 	ld.b      	r3, (r19, 0x0)
 8013da6:	4b04      	lsri      	r0, r3, 4
        if (hbit > 9)
 8013da8:	c4140420 	cmphs      	r20, r0
        lbit = *(inchar + i ) & 0x0f;
 8013dac:	e463200f 	andi      	r3, r3, 15
        if (hbit > 9)
 8013db0:	089d      	bt      	0x8013eea	// 8013eea <_vsnprintf+0x7c2>
        if (lbit > 9)
 8013db2:	c4740420 	cmphs      	r20, r3
            outtxt[3 * i] = 'A' + hbit - 10;
 8013db6:	2036      	addi      	r0, 55
 8013db8:	a200      	st.b      	r0, (r2, 0x0)
        if (lbit > 9)
 8013dba:	089d      	bt      	0x8013ef4	// 8013ef4 <_vsnprintf+0x7cc>
            outtxt[3 * i + 1] = 'A' + lbit - 10;
 8013dbc:	2336      	addi      	r3, 55
 8013dbe:	a261      	st.b      	r3, (r2, 0x1)
        outtxt[3 * i + 2] = '-';
 8013dc0:	dea20002 	st.b      	r21, (r2, 0x2)
 8013dc4:	e6730000 	addi      	r19, r19, 1
 8013dc8:	2202      	addi      	r2, 3
    for(i = 0; i < 6; i++)/* mac length */
 8013dca:	e832ffec 	bnezad      	r18, 0x8013da2	// 8013da2 <_vsnprintf+0x67a>
    outtxt[3 * (i - 1) + 2] = 0;
 8013dce:	3300      	movi      	r3, 0
 8013dd0:	dc6e0041 	st.b      	r3, (r14, 0x41)
        if (flags & FLAGS_PRECISION) {
 8013dd4:	e4612400 	andi      	r3, r1, 1024
 8013dd8:	b86a      	st.w      	r3, (r14, 0x28)
 8013dda:	e90300f3 	bez      	r3, 0x8013fc0	// 8013fc0 <_vsnprintf+0x898>
          l = (l < precision ? l : precision);
 8013dde:	ea100011 	movi      	r16, 17
 8013de2:	fa0acd23 	min.u32      	r3, r10, r16
 8013de6:	b868      	st.w      	r3, (r14, 0x20)
        if (!(flags & FLAGS_LEFT)) {
 8013de8:	e4612002 	andi      	r3, r1, 2
 8013dec:	b86b      	st.w      	r3, (r14, 0x2c)
 8013dee:	e92300e2 	bnez      	r3, 0x8013fb2	// 8013fb2 <_vsnprintf+0x88a>
          while (l++ < width) {
 8013df2:	9848      	ld.w      	r2, (r14, 0x20)
 8013df4:	c6220420 	cmphs      	r2, r17
 8013df8:	6ccb      	mov      	r3, r2
 8013dfa:	2300      	addi      	r3, 1
 8013dfc:	09c9      	bt      	0x801418e	// 801418e <_vsnprintf+0xa66>
 8013dfe:	c5710023 	addu      	r3, r17, r11
 8013e02:	c4430090 	subu      	r16, r3, r2
 8013e06:	6caf      	mov      	r2, r11
            out(' ', buffer, idx++, maxlen);
 8013e08:	e56b0000 	addi      	r11, r11, 1
 8013e0c:	6cdf      	mov      	r3, r7
 8013e0e:	6c63      	mov      	r1, r8
 8013e10:	3020      	movi      	r0, 32
 8013e12:	7bd9      	jsr      	r6
          while (l++ < width) {
 8013e14:	c60b0480 	cmpne      	r11, r16
 8013e18:	6caf      	mov      	r2, r11
 8013e1a:	0bf7      	bt      	0x8013e08	// 8013e08 <_vsnprintf+0x6e0>
 8013e1c:	e4710000 	addi      	r3, r17, 1
 8013e20:	b868      	st.w      	r3, (r14, 0x20)
        while ((*pstr != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 8013e22:	d80e0030 	ld.b      	r0, (r14, 0x30)
 8013e26:	e900fded 	bez      	r0, 0x8013a00	// 8013a00 <_vsnprintf+0x2d8>
 8013e2a:	6caf      	mov      	r2, r11
 8013e2c:	1c0c      	addi      	r4, r14, 48
 8013e2e:	d96e200a 	ld.w      	r11, (r14, 0x28)
 8013e32:	0403      	br      	0x8013e38	// 8013e38 <_vsnprintf+0x710>
          out(*(pstr++), buffer, idx++, maxlen);
 8013e34:	c4104822 	lsli      	r2, r16, 0
        while ((*pstr != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 8013e38:	e90b0007 	bez      	r11, 0x8013e46	// 8013e46 <_vsnprintf+0x71e>
 8013e3c:	e46a1000 	subi      	r3, r10, 1
 8013e40:	e90a010a 	bez      	r10, 0x8014054	// 8014054 <_vsnprintf+0x92c>
 8013e44:	6e8f      	mov      	r10, r3
          out(*(pstr++), buffer, idx++, maxlen);
 8013e46:	2400      	addi      	r4, 1
 8013e48:	6cdf      	mov      	r3, r7
 8013e4a:	6c63      	mov      	r1, r8
 8013e4c:	e6020000 	addi      	r16, r2, 1
 8013e50:	7bd9      	jsr      	r6
        while ((*pstr != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 8013e52:	8400      	ld.b      	r0, (r4, 0x0)
 8013e54:	e920fff0 	bnez      	r0, 0x8013e34	// 8013e34 <_vsnprintf+0x70c>
        if (flags & FLAGS_LEFT) {
 8013e58:	986b      	ld.w      	r3, (r14, 0x2c)
 8013e5a:	e90300b6 	bez      	r3, 0x8013fc6	// 8013fc6 <_vsnprintf+0x89e>
          while (l++ < width) {
 8013e5e:	9868      	ld.w      	r3, (r14, 0x20)
 8013e60:	c6230420 	cmphs      	r3, r17
 8013e64:	08b1      	bt      	0x8013fc6	// 8013fc6 <_vsnprintf+0x89e>
 8013e66:	c6110020 	addu      	r0, r17, r16
 8013e6a:	588d      	subu      	r4, r0, r3
 8013e6c:	c4104822 	lsli      	r2, r16, 0
            out(' ', buffer, idx++, maxlen);
 8013e70:	e5620000 	addi      	r11, r2, 1
 8013e74:	6cdf      	mov      	r3, r7
 8013e76:	6c63      	mov      	r1, r8
 8013e78:	3020      	movi      	r0, 32
 8013e7a:	7bd9      	jsr      	r6
          while (l++ < width) {
 8013e7c:	652e      	cmpne      	r11, r4
 8013e7e:	6caf      	mov      	r2, r11
 8013e80:	0bf8      	bt      	0x8013e70	// 8013e70 <_vsnprintf+0x748>
        format++;
 8013e82:	2500      	addi      	r5, 1
        char *ipv6 = va_arg(va, char*);
 8013e84:	9889      	ld.w      	r4, (r14, 0x24)
 8013e86:	e800fc60 	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
        if ((*format == 'g')||(*format == 'G')) flags |= FLAGS_ADAPT_EXP;
 8013e8a:	e46020df 	andi      	r3, r0, 223
 8013e8e:	eb430047 	cmpnei      	r3, 71
 8013e92:	0805      	bt      	0x8013e9c	// 8013e9c <_vsnprintf+0x774>
 8013e94:	ec210800 	ori      	r1, r1, 2048
        if ((*format == 'E')||(*format == 'G')) flags |= FLAGS_UPPERCASE;
 8013e98:	e40020fd 	andi      	r0, r0, 253
 8013e9c:	eb400045 	cmpnei      	r0, 69
 8013ea0:	0803      	bt      	0x8013ea6	// 8013ea6 <_vsnprintf+0x77e>
 8013ea2:	ec210020 	ori      	r1, r1, 32
        idx = _etoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
 8013ea6:	b824      	st.w      	r1, (r14, 0x10)
 8013ea8:	de2e2003 	st.w      	r17, (r14, 0xc)
 8013eac:	dd4e2002 	st.w      	r10, (r14, 0x8)
 8013eb0:	e6040007 	addi      	r16, r4, 8
 8013eb4:	9460      	ld.w      	r3, (r4, 0x0)
 8013eb6:	9481      	ld.w      	r4, (r4, 0x4)
 8013eb8:	b860      	st.w      	r3, (r14, 0x0)
 8013eba:	b881      	st.w      	r4, (r14, 0x4)
 8013ebc:	6caf      	mov      	r2, r11
 8013ebe:	6cdf      	mov      	r3, r7
 8013ec0:	6c63      	mov      	r1, r8
 8013ec2:	6c1b      	mov      	r0, r6
 8013ec4:	e3fff9ec 	bsr      	0x801329c	// 801329c <_etoa>
 8013ec8:	6ec3      	mov      	r11, r0
        format++;
 8013eca:	2500      	addi      	r5, 1
        idx = _etoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
 8013ecc:	c4104824 	lsli      	r4, r16, 0
        break;
 8013ed0:	e800fc3b 	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
                    outtxt[j++] = '0' + l;
 8013ed4:	1a0c      	addi      	r2, r14, 48
 8013ed6:	232f      	addi      	r3, 48
 8013ed8:	d6620023 	str.b      	r3, (r2, r19 << 0)
 8013edc:	06e3      	br      	0x8013ca2	// 8013ca2 <_vsnprintf+0x57a>
                    outtxt[j++]= '0' + h;
 8013ede:	e6ae002f 	addi      	r21, r14, 48
 8013ee2:	222f      	addi      	r2, 48
 8013ee4:	d4950022 	str.b      	r2, (r21, r4 << 0)
 8013ee8:	06d3      	br      	0x8013c8e	// 8013c8e <_vsnprintf+0x566>
        if (lbit > 9)
 8013eea:	c4740420 	cmphs      	r20, r3
            outtxt[3 * i]= '0' + hbit;
 8013eee:	202f      	addi      	r0, 48
 8013ef0:	a200      	st.b      	r0, (r2, 0x0)
        if (lbit > 9)
 8013ef2:	0f65      	bf      	0x8013dbc	// 8013dbc <_vsnprintf+0x694>
            outtxt[3 * i + 1] = '0' + lbit;
 8013ef4:	232f      	addi      	r3, 48
 8013ef6:	a261      	st.b      	r3, (r2, 0x1)
 8013ef8:	0764      	br      	0x8013dc0	// 8013dc0 <_vsnprintf+0x698>
            m = (bit % 100) / 10;
 8013efa:	c6828422 	mult      	r2, r2, r20
 8013efe:	60ca      	subu      	r3, r2
 8013f00:	74cc      	zextb      	r3, r3
 8013f02:	c6638022 	divu      	r2, r3, r19
            if (m)
 8013f06:	e902fd0c 	bez      	r2, 0x801391e	// 801391e <_vsnprintf+0x1f6>
 8013f0a:	6f13      	mov      	r12, r4
                outtxt[j++] = '0' + m;
 8013f0c:	e5ae002f 	addi      	r13, r14, 48
 8013f10:	e48c0000 	addi      	r4, r12, 1
 8013f14:	222f      	addi      	r2, 48
 8013f16:	7510      	zextb      	r4, r4
 8013f18:	d58d0022 	str.b      	r2, (r13, r12 << 0)
 8013f1c:	e800fd01 	br      	0x801391e	// 801391e <_vsnprintf+0x1f6>
          while (l++ < width) {
 8013f20:	6ed3      	mov      	r11, r4
        format++;
 8013f22:	2500      	addi      	r5, 1
        char *ipv6 = va_arg(va, char*);
 8013f24:	9889      	ld.w      	r4, (r14, 0x24)
 8013f26:	e800fc10 	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
 8013f2a:	6caf      	mov      	r2, r11
 8013f2c:	e800fc81 	br      	0x801382e	// 801382e <_vsnprintf+0x106>
      const int w = va_arg(va, int);
 8013f30:	9400      	ld.w      	r0, (r4, 0x0)
 8013f32:	5c6e      	addi      	r3, r4, 4
      if (w < 0) {
 8013f34:	e98000af 	blz      	r0, 0x8014092	// 8014092 <_vsnprintf+0x96a>
        width = (unsigned int)w;
 8013f38:	c4004831 	lsli      	r17, r0, 0
 8013f3c:	8201      	ld.b      	r0, (r2, 0x1)
      const int w = va_arg(va, int);
 8013f3e:	6d0f      	mov      	r4, r3
      format++;
 8013f40:	5aa2      	addi      	r5, r2, 1
 8013f42:	e800fc38 	br      	0x80137b2	// 80137b2 <_vsnprintf+0x8a>
 8013f46:	8502      	ld.b      	r0, (r5, 0x2)
          flags |= FLAGS_CHAR;
 8013f48:	ec2100c0 	ori      	r1, r1, 192
          format++;
 8013f4c:	2501      	addi      	r5, 2
 8013f4e:	e800fc47 	br      	0x80137dc	// 80137dc <_vsnprintf+0xb4>
 8013f52:	8502      	ld.b      	r0, (r5, 0x2)
          flags |= FLAGS_LONG_LONG;
 8013f54:	ec210300 	ori      	r1, r1, 768
          format++;
 8013f58:	2501      	addi      	r5, 2
 8013f5a:	e800fc41 	br      	0x80137dc	// 80137dc <_vsnprintf+0xb4>
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 8013f5e:	e900fdb2 	bez      	r0, 0x8013ac2	// 8013ac2 <_vsnprintf+0x39a>
 8013f62:	6caf      	mov      	r2, r11
 8013f64:	b88b      	st.w      	r4, (r14, 0x2c)
 8013f66:	d96e2009 	ld.w      	r11, (r14, 0x24)
 8013f6a:	e800fd96 	br      	0x8013a96	// 8013a96 <_vsnprintf+0x36e>
        out((char)va_arg(va, int), buffer, idx++, maxlen);
 8013f6e:	6cdf      	mov      	r3, r7
 8013f70:	6caf      	mov      	r2, r11
 8013f72:	6c63      	mov      	r1, r8
 8013f74:	8400      	ld.b      	r0, (r4, 0x0)
 8013f76:	7bd9      	jsr      	r6
          while (l++ < width) {
 8013f78:	eb110001 	cmphsi      	r17, 2
        out((char)va_arg(va, int), buffer, idx++, maxlen);
 8013f7c:	e6040003 	addi      	r16, r4, 4
 8013f80:	e54b0000 	addi      	r10, r11, 1
          while (l++ < width) {
 8013f84:	0cfc      	bf      	0x801417c	// 801417c <_vsnprintf+0xa54>
 8013f86:	c571002b 	addu      	r11, r17, r11
 8013f8a:	6cab      	mov      	r2, r10
            out(' ', buffer, idx++, maxlen);
 8013f8c:	5a82      	addi      	r4, r2, 1
 8013f8e:	6cdf      	mov      	r3, r7
 8013f90:	6c63      	mov      	r1, r8
 8013f92:	3020      	movi      	r0, 32
 8013f94:	7bd9      	jsr      	r6
          while (l++ < width) {
 8013f96:	652e      	cmpne      	r11, r4
 8013f98:	6c93      	mov      	r2, r4
 8013f9a:	0bf9      	bt      	0x8013f8c	// 8013f8c <_vsnprintf+0x864>
        out((char)va_arg(va, int), buffer, idx++, maxlen);
 8013f9c:	c4104824 	lsli      	r4, r16, 0
        format++;
 8013fa0:	2500      	addi      	r5, 1
 8013fa2:	e800fbd2 	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
        while ((*pstr != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 8013fa6:	d80e0030 	ld.b      	r0, (r14, 0x30)
 8013faa:	e920fec0 	bnez      	r0, 0x8013d2a	// 8013d2a <_vsnprintf+0x602>
 8013fae:	6d2f      	mov      	r4, r11
 8013fb0:	06d8      	br      	0x8013d60	// 8013d60 <_vsnprintf+0x638>
        while ((*pstr != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 8013fb2:	d80e0030 	ld.b      	r0, (r14, 0x30)
 8013fb6:	e920ff3a 	bnez      	r0, 0x8013e2a	// 8013e2a <_vsnprintf+0x702>
 8013fba:	c40b4830 	lsli      	r16, r11, 0
 8013fbe:	0750      	br      	0x8013e5e	// 8013e5e <_vsnprintf+0x736>
        unsigned int l = __mac2str((unsigned char *)p, store);
 8013fc0:	3311      	movi      	r3, 17
 8013fc2:	b868      	st.w      	r3, (r14, 0x20)
 8013fc4:	0712      	br      	0x8013de8	// 8013de8 <_vsnprintf+0x6c0>
          while (l++ < width) {
 8013fc6:	c410482b 	lsli      	r11, r16, 0
        format++;
 8013fca:	2500      	addi      	r5, 1
        char *ipv6 = va_arg(va, char*);
 8013fcc:	9889      	ld.w      	r4, (r14, 0x24)
 8013fce:	e800fbbc 	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
        while ((*pstr != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 8013fd2:	d80e0030 	ld.b      	r0, (r14, 0x30)
 8013fd6:	e920fce7 	bnez      	r0, 0x80139a4	// 80139a4 <_vsnprintf+0x27c>
 8013fda:	6d2f      	mov      	r4, r11
 8013fdc:	e800fcff 	br      	0x80139da	// 80139da <_vsnprintf+0x2b2>
          base =  8U;
 8013fe0:	3208      	movi      	r2, 8
          flags &= ~(FLAGS_PLUS | FLAGS_SPACE);
 8013fe2:	c4412823 	bclri      	r3, r1, 2
 8013fe6:	3b83      	bclri      	r3, 3
        if (flags & FLAGS_PRECISION) {
 8013fe8:	e4212400 	andi      	r1, r1, 1024
 8013fec:	e901fdda 	bez      	r1, 0x8013ba0	// 8013ba0 <_vsnprintf+0x478>
 8013ff0:	e800fdd7 	br      	0x8013b9e	// 8013b9e <_vsnprintf+0x476>
        if ((*format != 'i') && (*format != 'd')) {
 8013ff4:	eb400064 	cmpnei      	r0, 100
          flags &= ~FLAGS_HASH;   // no hash for dec format
 8013ff8:	6c4f      	mov      	r1, r3
          base = 10U;
 8013ffa:	320a      	movi      	r2, 10
        if ((*format != 'i') && (*format != 'd')) {
 8013ffc:	0bf3      	bt      	0x8013fe2	// 8013fe2 <_vsnprintf+0x8ba>
        if (flags & FLAGS_PRECISION) {
 8013ffe:	e4232400 	andi      	r1, r3, 1024
 8014002:	e921fdce 	bnez      	r1, 0x8013b9e	// 8013b9e <_vsnprintf+0x476>
          if (flags & FLAGS_LONG_LONG) {
 8014006:	e4232200 	andi      	r1, r3, 512
 801400a:	e9210066 	bnez      	r1, 0x80140d6	// 80140d6 <_vsnprintf+0x9ae>
          else if (flags & FLAGS_LONG) {
 801400e:	e4032100 	andi      	r0, r3, 256
 8014012:	e9200099 	bnez      	r0, 0x8014144	// 8014144 <_vsnprintf+0xa1c>
            const int value = (flags & FLAGS_CHAR) ? (char)va_arg(va, int) : (flags & FLAGS_SHORT) ? (short int)va_arg(va, int) : va_arg(va, int);
 8014016:	e4232040 	andi      	r1, r3, 64
 801401a:	e92100a8 	bnez      	r1, 0x801416a	// 801416a <_vsnprintf+0xa42>
 801401e:	e4232080 	andi      	r1, r3, 128
 8014022:	e921008c 	bnez      	r1, 0x801413a	// 801413a <_vsnprintf+0xa12>
 8014026:	9420      	ld.w      	r1, (r4, 0x0)
 8014028:	491f      	lsri      	r0, r1, 31
 801402a:	2403      	addi      	r4, 4
            idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned int)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
 801402c:	b865      	st.w      	r3, (r14, 0x14)
 801402e:	de2e2004 	st.w      	r17, (r14, 0x10)
 8014032:	dd4e2003 	st.w      	r10, (r14, 0xc)
 8014036:	b842      	st.w      	r2, (r14, 0x8)
 8014038:	b801      	st.w      	r0, (r14, 0x4)
 801403a:	c4010201 	abs      	r1, r1
 801403e:	e800fdd3 	br      	0x8013be4	// 8013be4 <_vsnprintf+0x4bc>
 8014042:	988b      	ld.w      	r4, (r14, 0x2c)
 8014044:	6ecb      	mov      	r11, r2
 8014046:	e800fd3b 	br      	0x8013abc	// 8013abc <_vsnprintf+0x394>
 801404a:	6d0b      	mov      	r4, r2
 801404c:	0687      	br      	0x8013d5a	// 8013d5a <_vsnprintf+0x632>
 801404e:	6d0b      	mov      	r4, r2
 8014050:	e800fcc2 	br      	0x80139d4	// 80139d4 <_vsnprintf+0x2ac>
 8014054:	c4024830 	lsli      	r16, r2, 0
 8014058:	0700      	br      	0x8013e58	// 8013e58 <_vsnprintf+0x730>
          base = 16U;
 801405a:	3210      	movi      	r2, 16
 801405c:	07c3      	br      	0x8013fe2	// 8013fe2 <_vsnprintf+0x8ba>
 801405e:	c4412823 	bclri      	r3, r1, 2
 8014062:	3b83      	bclri      	r3, 3
        if (flags & FLAGS_PRECISION) {
 8014064:	e4212400 	andi      	r1, r1, 1024
          flags &= ~(FLAGS_PLUS | FLAGS_SPACE);
 8014068:	ec630020 	ori      	r3, r3, 32
          base = 16U;
 801406c:	3210      	movi      	r2, 16
        if (flags & FLAGS_PRECISION) {
 801406e:	e921fd98 	bnez      	r1, 0x8013b9e	// 8013b9e <_vsnprintf+0x476>
 8014072:	e800fd9f 	br      	0x8013bb0	// 8013bb0 <_vsnprintf+0x488>
        if (*format == 'F') flags |= FLAGS_UPPERCASE;
 8014076:	ec210020 	ori      	r1, r1, 32
 801407a:	e800fdc4 	br      	0x8013c02	// 8013c02 <_vsnprintf+0x4da>
        precision = prec > 0 ? (unsigned int)prec : 0U;
 801407e:	d9a42000 	ld.w      	r13, (r4, 0x0)
 8014082:	3300      	movi      	r3, 0
 8014084:	8502      	ld.b      	r0, (r5, 0x2)
 8014086:	f86dccaa 	max.s32      	r10, r13, r3
        const int prec = (int)va_arg(va, int);
 801408a:	2403      	addi      	r4, 4
        format++;
 801408c:	2501      	addi      	r5, 2
 801408e:	e800fb97 	br      	0x80137bc	// 80137bc <_vsnprintf+0x94>
        width = (unsigned int)-w;
 8014092:	ea0c0000 	movi      	r12, 0
        flags |= FLAGS_LEFT;    // reverse padding
 8014096:	ec210002 	ori      	r1, r1, 2
        width = (unsigned int)-w;
 801409a:	c40c0091 	subu      	r17, r12, r0
 801409e:	074f      	br      	0x8013f3c	// 8013f3c <_vsnprintf+0x814>
            idx = _ntoa_long_long(out, buffer, idx, maxlen, va_arg(va, unsigned long long), false, base, precision, width, flags);
 80140a0:	b867      	st.w      	r3, (r14, 0x1c)
 80140a2:	3300      	movi      	r3, 0
 80140a4:	de2e2006 	st.w      	r17, (r14, 0x18)
 80140a8:	dd4e2005 	st.w      	r10, (r14, 0x14)
 80140ac:	b843      	st.w      	r2, (r14, 0xc)
 80140ae:	b864      	st.w      	r3, (r14, 0x10)
 80140b0:	b862      	st.w      	r3, (r14, 0x8)
 80140b2:	e6040007 	addi      	r16, r4, 8
 80140b6:	9460      	ld.w      	r3, (r4, 0x0)
 80140b8:	9481      	ld.w      	r4, (r4, 0x4)
 80140ba:	b860      	st.w      	r3, (r14, 0x0)
 80140bc:	b881      	st.w      	r4, (r14, 0x4)
 80140be:	6caf      	mov      	r2, r11
 80140c0:	6cdf      	mov      	r3, r7
 80140c2:	6c63      	mov      	r1, r8
 80140c4:	6c1b      	mov      	r0, r6
 80140c6:	e3fff633 	bsr      	0x8012d2c	// 8012d2c <_ntoa_long_long>
 80140ca:	6ec3      	mov      	r11, r0
 80140cc:	c4104824 	lsli      	r4, r16, 0
        format++;
 80140d0:	2500      	addi      	r5, 1
 80140d2:	e800fb3a 	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
            const long long value = va_arg(va, long long);
 80140d6:	9421      	ld.w      	r1, (r4, 0x4)
 80140d8:	9400      	ld.w      	r0, (r4, 0x0)
            idx = _ntoa_long_long(out, buffer, idx, maxlen, (unsigned long long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
 80140da:	b867      	st.w      	r3, (r14, 0x1c)
 80140dc:	3300      	movi      	r3, 0
 80140de:	b864      	st.w      	r3, (r14, 0x10)
 80140e0:	497f      	lsri      	r3, r1, 31
 80140e2:	b843      	st.w      	r2, (r14, 0xc)
 80140e4:	b862      	st.w      	r3, (r14, 0x8)
            const long long value = va_arg(va, long long);
 80140e6:	e6040007 	addi      	r16, r4, 8
            idx = _ntoa_long_long(out, buffer, idx, maxlen, (unsigned long long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
 80140ea:	de2e2006 	st.w      	r17, (r14, 0x18)
 80140ee:	dd4e2005 	st.w      	r10, (r14, 0x14)
 80140f2:	6c83      	mov      	r2, r0
 80140f4:	6cc7      	mov      	r3, r1
 80140f6:	e9810053 	blz      	r1, 0x801419c	// 801419c <_vsnprintf+0xa74>
 80140fa:	b840      	st.w      	r2, (r14, 0x0)
 80140fc:	b861      	st.w      	r3, (r14, 0x4)
 80140fe:	07e0      	br      	0x80140be	// 80140be <_vsnprintf+0x996>
            idx = _ntoa_long(out, buffer, idx, maxlen, va_arg(va, unsigned long), false, base, precision, width, flags);
 8014100:	b865      	st.w      	r3, (r14, 0x14)
 8014102:	de2e2004 	st.w      	r17, (r14, 0x10)
 8014106:	dd4e2003 	st.w      	r10, (r14, 0xc)
 801410a:	b842      	st.w      	r2, (r14, 0x8)
 801410c:	b821      	st.w      	r1, (r14, 0x4)
 801410e:	9460      	ld.w      	r3, (r4, 0x0)
 8014110:	e6040003 	addi      	r16, r4, 4
 8014114:	b860      	st.w      	r3, (r14, 0x0)
 8014116:	6caf      	mov      	r2, r11
 8014118:	6cdf      	mov      	r3, r7
 801411a:	6c63      	mov      	r1, r8
 801411c:	6c1b      	mov      	r0, r6
 801411e:	e3fff5a7 	bsr      	0x8012c6c	// 8012c6c <_ntoa_long>
 8014122:	6ec3      	mov      	r11, r0
 8014124:	c4104824 	lsli      	r4, r16, 0
        format++;
 8014128:	2500      	addi      	r5, 1
 801412a:	e800fb0e 	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
          base =  2U;
 801412e:	3202      	movi      	r2, 2
 8014130:	0759      	br      	0x8013fe2	// 8013fe2 <_vsnprintf+0x8ba>
 8014132:	8c20      	ld.h      	r1, (r4, 0x0)
            const unsigned int value = (flags & FLAGS_CHAR) ? (unsigned char)va_arg(va, unsigned int) : (flags & FLAGS_SHORT) ? (unsigned short int)va_arg(va, unsigned int) : va_arg(va, unsigned int);
 8014134:	2403      	addi      	r4, 4
 8014136:	e800fd4f 	br      	0x8013bd4	// 8013bd4 <_vsnprintf+0x4ac>
            const int value = (flags & FLAGS_CHAR) ? (char)va_arg(va, int) : (flags & FLAGS_SHORT) ? (short int)va_arg(va, int) : va_arg(va, int);
 801413a:	d8245000 	ld.hs      	r1, (r4, 0x0)
 801413e:	491f      	lsri      	r0, r1, 31
 8014140:	2403      	addi      	r4, 4
 8014142:	0775      	br      	0x801402c	// 801402c <_vsnprintf+0x904>
            const long value = va_arg(va, long);
 8014144:	9420      	ld.w      	r1, (r4, 0x0)
            idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
 8014146:	b865      	st.w      	r3, (r14, 0x14)
 8014148:	497f      	lsri      	r3, r1, 31
 801414a:	c4010201 	abs      	r1, r1
            const long value = va_arg(va, long);
 801414e:	e6040003 	addi      	r16, r4, 4
            idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
 8014152:	de2e2004 	st.w      	r17, (r14, 0x10)
 8014156:	dd4e2003 	st.w      	r10, (r14, 0xc)
 801415a:	b842      	st.w      	r2, (r14, 0x8)
 801415c:	b861      	st.w      	r3, (r14, 0x4)
 801415e:	b820      	st.w      	r1, (r14, 0x0)
 8014160:	07db      	br      	0x8014116	// 8014116 <_vsnprintf+0x9ee>
 8014162:	8420      	ld.b      	r1, (r4, 0x0)
            const unsigned int value = (flags & FLAGS_CHAR) ? (unsigned char)va_arg(va, unsigned int) : (flags & FLAGS_SHORT) ? (unsigned short int)va_arg(va, unsigned int) : va_arg(va, unsigned int);
 8014164:	2403      	addi      	r4, 4
 8014166:	e800fd37 	br      	0x8013bd4	// 8013bd4 <_vsnprintf+0x4ac>
 801416a:	8420      	ld.b      	r1, (r4, 0x0)
            const int value = (flags & FLAGS_CHAR) ? (char)va_arg(va, int) : (flags & FLAGS_SHORT) ? (short int)va_arg(va, int) : va_arg(va, int);
 801416c:	2403      	addi      	r4, 4
 801416e:	075f      	br      	0x801402c	// 801402c <_vsnprintf+0x904>
          while (l++ < width) {
 8014170:	b868      	st.w      	r3, (r14, 0x20)
 8014172:	e800fdd8 	br      	0x8013d22	// 8013d22 <_vsnprintf+0x5fa>
          while (l++ < width) {
 8014176:	b868      	st.w      	r3, (r14, 0x20)
 8014178:	e800fc12 	br      	0x801399c	// 801399c <_vsnprintf+0x274>
        out((char)va_arg(va, int), buffer, idx++, maxlen);
 801417c:	c4104824 	lsli      	r4, r16, 0
 8014180:	6eeb      	mov      	r11, r10
        format++;
 8014182:	2500      	addi      	r5, 1
 8014184:	e800fae1 	br      	0x8013746	// 8013746 <_vsnprintf+0x1e>
          while (l++ < width) {
 8014188:	6eaf      	mov      	r10, r11
 801418a:	e800fce1 	br      	0x8013b4c	// 8013b4c <_vsnprintf+0x424>
          while (l++ < width) {
 801418e:	b868      	st.w      	r3, (r14, 0x20)
 8014190:	0649      	br      	0x8013e22	// 8013e22 <_vsnprintf+0x6fa>
          while (l++ < width) {
 8014192:	6d0f      	mov      	r4, r3
 8014194:	c40b4832 	lsli      	r18, r11, 0
 8014198:	e800fc76 	br      	0x8013a84	// 8013a84 <_vsnprintf+0x35c>
            idx = _ntoa_long_long(out, buffer, idx, maxlen, (unsigned long long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
 801419c:	3000      	movi      	r0, 0
 801419e:	3100      	movi      	r1, 0
 80141a0:	f840c462 	sub.64      	r2, r0, r2
 80141a4:	07ab      	br      	0x80140fa	// 80140fa <_vsnprintf+0x9d2>
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
 80141a6:	c412482b 	lsli      	r11, r18, 0
 80141aa:	e800fc9c 	br      	0x8013ae2	// 8013ae2 <_vsnprintf+0x3ba>
	...

080141b0 <fputc>:
    while((READ_REG(UART0->FIFOS) & 0x3F) >= 32);
 80141b0:	1046      	lrw      	r2, 0x40010600	// 80141c8 <fputc+0x18>
 80141b2:	9267      	ld.w      	r3, (r2, 0x1c)
 80141b4:	e463203f 	andi      	r3, r3, 63
 80141b8:	3b1f      	cmphsi      	r3, 32
 80141ba:	0bfc      	bt      	0x80141b2	// 80141b2 <fputc+0x2>
    WRITE_REG(UART0->TDW, (char)ch);
 80141bc:	e40020ff 	andi      	r0, r0, 255
 80141c0:	b208      	st.w      	r0, (r2, 0x20)
}
 80141c2:	3000      	movi      	r0, 0
 80141c4:	783c      	jmp      	r15
 80141c6:	0000      	.short	0x0000
 80141c8:	40010600 	.long	0x40010600

080141cc <wm_printf>:
  return _vsnprintf(_out_buffer, buffer, count, format, va);
}


int wm_printf(const char *fmt,...)
{
 80141cc:	1424      	subi      	r14, r14, 16
 80141ce:	b863      	st.w      	r3, (r14, 0xc)
 80141d0:	b842      	st.w      	r2, (r14, 0x8)
 80141d2:	b821      	st.w      	r1, (r14, 0x4)
 80141d4:	b800      	st.w      	r0, (r14, 0x0)
 80141d6:	14d0      	push      	r15
 80141d8:	1421      	subi      	r14, r14, 4
 80141da:	9862      	ld.w      	r3, (r14, 0x8)
 80141dc:	6c8f      	mov      	r2, r3
    va_list args;
    size_t length;

	va_start(args, fmt);
	length = _vsnprintf(_out_uart, (char*)fmt, (size_t) - 1, fmt, args);
 80141de:	1b03      	addi      	r3, r14, 12
 80141e0:	b860      	st.w      	r3, (r14, 0x0)
 80141e2:	6ccb      	mov      	r3, r2
 80141e4:	3200      	movi      	r2, 0
 80141e6:	2a00      	subi      	r2, 1
 80141e8:	6c4f      	mov      	r1, r3
 80141ea:	1005      	lrw      	r0, 0x80129d0	// 80141fc <wm_printf+0x30>
 80141ec:	e3fffa9e 	bsr      	0x8013728	// 8013728 <_vsnprintf>
	va_end(args);

	return length;
}
 80141f0:	1401      	addi      	r14, r14, 4
 80141f2:	d9ee2000 	ld.w      	r15, (r14, 0x0)
 80141f6:	1405      	addi      	r14, r14, 20
 80141f8:	783c      	jmp      	r15
 80141fa:	0000      	.short	0x0000
 80141fc:	080129d0 	.long	0x080129d0
