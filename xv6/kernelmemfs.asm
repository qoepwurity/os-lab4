
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr  
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr  

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc 80 8a 19 80       	mov    $0x80198a80,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 66 33 10 80       	mov    $0x80103366,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 80 a7 10 80       	push   $0x8010a780
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 86 4a 00 00       	call   80104b04 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 17 19 80 fc 	movl   $0x801916fc,0x8019174c
80100088:	16 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 17 19 80 fc 	movl   $0x801916fc,0x80191750
80100092:	16 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 d0 18 80 	movl   $0x8018d034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 17 19 80    	mov    0x80191750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 87 a7 10 80       	push   $0x8010a787
801000c2:	50                   	push   %eax
801000c3:	e8 df 48 00 00       	call   801049a7 <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 17 19 80       	mov    0x80191750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 17 19 80       	mov    %eax,0x80191750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 16 19 80       	mov    $0x801916fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave  
801000f2:	c3                   	ret    

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 d0 18 80       	push   $0x8018d000
80100101:	e8 20 4a 00 00       	call   80104b26 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 17 19 80       	mov    0x80191750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 d0 18 80       	push   $0x8018d000
80100140:	e8 4f 4a 00 00       	call   80104b94 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 8c 48 00 00       	call   801049e3 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 17 19 80       	mov    0x8019174c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 d0 18 80       	push   $0x8018d000
801001c1:	e8 ce 49 00 00       	call   80104b94 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 0b 48 00 00       	call   801049e3 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 8e a7 10 80       	push   $0x8010a78e
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave  
80100200:	c3                   	ret    

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 54 a4 00 00       	call   8010a686 <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave  
80100239:	c3                   	ret    

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 46 48 00 00       	call   80104a95 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 9f a7 10 80       	push   $0x8010a79f
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 09 a4 00 00       	call   8010a686 <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave  
80100282:	c3                   	ret    

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 fd 47 00 00       	call   80104a95 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 a6 a7 10 80       	push   $0x8010a7a6
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 8c 47 00 00       	call   80104a47 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 5b 48 00 00       	call   80104b26 <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 17 19 80    	mov    0x80191750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 17 19 80       	mov    0x80191750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 17 19 80       	mov    %eax,0x80191750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 d0 18 80       	push   $0x8018d000
80100336:	e8 59 48 00 00       	call   80104b94 <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave  
80100340:	c3                   	ret    

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli    
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret    

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8c 03 00 00       	call   8010076f <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave  
801003f3:	c3                   	ret    

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 1a 19 80       	mov    0x80191a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 1a 19 80       	push   $0x80191a00
80100410:	e8 11 47 00 00       	call   80104b26 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 ad a7 10 80       	push   $0x8010a7ad
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 20 03 00 00       	call   8010076f <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec b6 a7 10 80 	movl   $0x8010a7b6,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 44 02 00 00       	call   8010076f <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 27 02 00 00       	call   8010076f <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 18 02 00 00       	call   8010076f <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 0a 02 00 00       	call   8010076f <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 1a 19 80       	push   $0x80191a00
8010059e:	e8 f1 45 00 00       	call   80104b94 <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave  
801005a8:	c3                   	ret    

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 38 25 00 00       	call   80102afb <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 bd a7 10 80       	push   $0x8010a7bd
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 d1 a7 10 80       	push   $0x8010a7d1
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 e3 45 00 00       	call   80104be6 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 d3 a7 10 80       	push   $0x8010a7d3
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
80100638:	00 00 00 
  for(;;)
8010063b:	eb fe                	jmp    8010063b <panic+0x92>

8010063d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063d:	55                   	push   %ebp
8010063e:	89 e5                	mov    %esp,%ebp
80100640:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100643:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100647:	75 64                	jne    801006ad <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100649:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010064f:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100654:	89 c8                	mov    %ecx,%eax
80100656:	f7 ea                	imul   %edx
80100658:	89 d0                	mov    %edx,%eax
8010065a:	c1 f8 04             	sar    $0x4,%eax
8010065d:	89 ca                	mov    %ecx,%edx
8010065f:	c1 fa 1f             	sar    $0x1f,%edx
80100662:	29 d0                	sub    %edx,%eax
80100664:	6b d0 35             	imul   $0x35,%eax,%edx
80100667:	89 c8                	mov    %ecx,%eax
80100669:	29 d0                	sub    %edx,%eax
8010066b:	ba 35 00 00 00       	mov    $0x35,%edx
80100670:	29 c2                	sub    %eax,%edx
80100672:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100677:	01 d0                	add    %edx,%eax
80100679:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100683:	3d 23 04 00 00       	cmp    $0x423,%eax
80100688:	0f 8e de 00 00 00    	jle    8010076c <graphic_putc+0x12f>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100693:	83 e8 35             	sub    $0x35,%eax
80100696:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069b:	83 ec 0c             	sub    $0xc,%esp
8010069e:	6a 1e                	push   $0x1e
801006a0:	e8 38 7f 00 00       	call   801085dd <graphic_scroll_up>
801006a5:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a8:	e9 bf 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
  }else if(c == BACKSPACE){
801006ad:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b4:	75 1f                	jne    801006d5 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bb:	85 c0                	test   %eax,%eax
801006bd:	0f 8e a9 00 00 00    	jle    8010076c <graphic_putc+0x12f>
801006c3:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c8:	83 e8 01             	sub    $0x1,%eax
801006cb:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d0:	e9 97 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d5:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006da:	3d 23 04 00 00       	cmp    $0x423,%eax
801006df:	7e 1a                	jle    801006fb <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e1:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e6:	83 e8 35             	sub    $0x35,%eax
801006e9:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ee:	83 ec 0c             	sub    $0xc,%esp
801006f1:	6a 1e                	push   $0x1e
801006f3:	e8 e5 7e 00 00       	call   801085dd <graphic_scroll_up>
801006f8:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fb:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100701:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100706:	89 c8                	mov    %ecx,%eax
80100708:	f7 ea                	imul   %edx
8010070a:	89 d0                	mov    %edx,%eax
8010070c:	c1 f8 04             	sar    $0x4,%eax
8010070f:	89 ca                	mov    %ecx,%edx
80100711:	c1 fa 1f             	sar    $0x1f,%edx
80100714:	29 d0                	sub    %edx,%eax
80100716:	6b d0 35             	imul   $0x35,%eax,%edx
80100719:	89 c8                	mov    %ecx,%eax
8010071b:	29 d0                	sub    %edx,%eax
8010071d:	89 c2                	mov    %eax,%edx
8010071f:	c1 e2 04             	shl    $0x4,%edx
80100722:	29 c2                	sub    %eax,%edx
80100724:	8d 42 02             	lea    0x2(%edx),%eax
80100727:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100730:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100735:	89 c8                	mov    %ecx,%eax
80100737:	f7 ea                	imul   %edx
80100739:	89 d0                	mov    %edx,%eax
8010073b:	c1 f8 04             	sar    $0x4,%eax
8010073e:	c1 f9 1f             	sar    $0x1f,%ecx
80100741:	89 ca                	mov    %ecx,%edx
80100743:	29 d0                	sub    %edx,%eax
80100745:	6b c0 1e             	imul   $0x1e,%eax,%eax
80100748:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074b:	83 ec 04             	sub    $0x4,%esp
8010074e:	ff 75 08             	push   0x8(%ebp)
80100751:	ff 75 f0             	push   -0x10(%ebp)
80100754:	ff 75 f4             	push   -0xc(%ebp)
80100757:	e8 ec 7e 00 00       	call   80108648 <font_render>
8010075c:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100764:	83 c0 01             	add    $0x1,%eax
80100767:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076c:	90                   	nop
8010076d:	c9                   	leave  
8010076e:	c3                   	ret    

8010076f <consputc>:


void
consputc(int c)
{
8010076f:	55                   	push   %ebp
80100770:	89 e5                	mov    %esp,%ebp
80100772:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100775:	a1 ec 19 19 80       	mov    0x801919ec,%eax
8010077a:	85 c0                	test   %eax,%eax
8010077c:	74 07                	je     80100785 <consputc+0x16>
    cli();
8010077e:	e8 be fb ff ff       	call   80100341 <cli>
    for(;;)
80100783:	eb fe                	jmp    80100783 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 bc 62 00 00       	call   80106a54 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 af 62 00 00       	call   80106a54 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 a2 62 00 00       	call   80106a54 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 92 62 00 00       	call   80106a54 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6d fe ff ff       	call   8010063d <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave  
801007d5:	c3                   	ret    

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 1a 19 80       	push   $0x80191a00
801007eb:	e8 36 43 00 00       	call   80104b26 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 50 01 00 00       	jmp    80100948 <consoleintr+0x172>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 10 01 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
8010085b:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100889:	a1 e4 19 19 80       	mov    0x801919e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 bf fe ff ff       	call   8010076f <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 90 00 00 00       	jmp    80100948 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 85 00 00 00    	je     80100947 <consoleintr+0x171>
801008c2:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008c7:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801008cd:	29 d0                	sub    %edx,%eax
801008cf:	83 f8 7f             	cmp    $0x7f,%eax
801008d2:	77 73                	ja     80100947 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 63 fe ff ff       	call   8010076f <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100920:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100932:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 19 19 80       	push   $0x801919e0
8010093f:	e8 72 3e 00 00       	call   801047b6 <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	90                   	nop
  while((c = getc()) >= 0){
80100948:	8b 45 08             	mov    0x8(%ebp),%eax
8010094b:	ff d0                	call   *%eax
8010094d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100954:	0f 89 9e fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
8010095a:	83 ec 0c             	sub    $0xc,%esp
8010095d:	68 00 1a 19 80       	push   $0x80191a00
80100962:	e8 2d 42 00 00       	call   80104b94 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 ff 3e 00 00       	call   80104874 <procdump>
  }
}
80100975:	90                   	nop
80100976:	c9                   	leave  
80100977:	c3                   	ret    

80100978 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100978:	55                   	push   %ebp
80100979:	89 e5                	mov    %esp,%ebp
8010097b:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010097e:	83 ec 0c             	sub    $0xc,%esp
80100981:	ff 75 08             	push   0x8(%ebp)
80100984:	e8 75 11 00 00       	call   80101afe <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 87 41 00 00       	call   80104b26 <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 85 30 00 00       	call   80103a31 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 d4 41 00 00       	call   80104b94 <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 1d 10 00 00       	call   801019eb <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 df 3c 00 00       	call   801046cc <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801009f6:	a1 e4 19 19 80       	mov    0x801919e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
80100a17:	0f be c0             	movsbl %al,%eax
80100a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a1d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a21:	75 17                	jne    80100a3a <consoleread+0xc2>
      if(n < target){
80100a23:	8b 45 10             	mov    0x10(%ebp),%eax
80100a26:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a29:	76 2f                	jbe    80100a5a <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a2b:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 19 19 80       	mov    %eax,0x801919e0
      }
      break;
80100a38:	eb 20                	jmp    80100a5a <consoleread+0xe2>
    }
    *dst++ = c;
80100a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a3d:	8d 50 01             	lea    0x1(%eax),%edx
80100a40:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a43:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a46:	88 10                	mov    %dl,(%eax)
    --n;
80100a48:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a4c:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a50:	74 0b                	je     80100a5d <consoleread+0xe5>
  while(n > 0){
80100a52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a56:	7f 98                	jg     801009f0 <consoleread+0x78>
80100a58:	eb 04                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5a:	90                   	nop
80100a5b:	eb 01                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5d:	90                   	nop
  }
  release(&cons.lock);
80100a5e:	83 ec 0c             	sub    $0xc,%esp
80100a61:	68 00 1a 19 80       	push   $0x80191a00
80100a66:	e8 29 41 00 00       	call   80104b94 <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 72 0f 00 00       	call   801019eb <ilock>
80100a79:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a7c:	8b 55 10             	mov    0x10(%ebp),%edx
80100a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a82:	29 d0                	sub    %edx,%eax
}
80100a84:	c9                   	leave  
80100a85:	c3                   	ret    

80100a86 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a86:	55                   	push   %ebp
80100a87:	89 e5                	mov    %esp,%ebp
80100a89:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a8c:	83 ec 0c             	sub    $0xc,%esp
80100a8f:	ff 75 08             	push   0x8(%ebp)
80100a92:	e8 67 10 00 00       	call   80101afe <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 7f 40 00 00       	call   80104b26 <acquire>
80100aa7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ab1:	eb 21                	jmp    80100ad4 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab9:	01 d0                	add    %edx,%eax
80100abb:	0f b6 00             	movzbl (%eax),%eax
80100abe:	0f be c0             	movsbl %al,%eax
80100ac1:	0f b6 c0             	movzbl %al,%eax
80100ac4:	83 ec 0c             	sub    $0xc,%esp
80100ac7:	50                   	push   %eax
80100ac8:	e8 a2 fc ff ff       	call   8010076f <consputc>
80100acd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ad0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ad7:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ada:	7c d7                	jl     80100ab3 <consolewrite+0x2d>
  release(&cons.lock);
80100adc:	83 ec 0c             	sub    $0xc,%esp
80100adf:	68 00 1a 19 80       	push   $0x80191a00
80100ae4:	e8 ab 40 00 00       	call   80104b94 <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 f4 0e 00 00       	call   801019eb <ilock>
80100af7:	83 c4 10             	add    $0x10,%esp

  return n;
80100afa:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consoleinit>:

void
consoleinit(void)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b05:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 d7 a7 10 80       	push   $0x8010a7d7
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 e3 3f 00 00       	call   80104b04 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 df a7 10 80 	movl   $0x8010a7df,-0xc(%ebp)
80100b3f:	eb 19                	jmp    80100b5a <consoleinit+0x5b>
    graphic_putc(*p);
80100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b44:	0f b6 00             	movzbl (%eax),%eax
80100b47:	0f be c0             	movsbl %al,%eax
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	50                   	push   %eax
80100b4e:	e8 ea fa ff ff       	call   8010063d <graphic_putc>
80100b53:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b5d:	0f b6 00             	movzbl (%eax),%eax
80100b60:	84 c0                	test   %al,%al
80100b62:	75 dd                	jne    80100b41 <consoleinit+0x42>
  
  cons.locking = 1;
80100b64:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 b5 1a 00 00       	call   8010262f <ioapicenable>
80100b7a:	83 c4 10             	add    $0x10,%esp
}
80100b7d:	90                   	nop
80100b7e:	c9                   	leave  
80100b7f:	c3                   	ret    

80100b80 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b80:	55                   	push   %ebp
80100b81:	89 e5                	mov    %esp,%ebp
80100b83:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b89:	e8 a3 2e 00 00       	call   80103a31 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 a7 24 00 00       	call   8010303d <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7d 19 00 00       	call   8010251e <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 17 25 00 00       	call   801030c9 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 f5 a7 10 80       	push   $0x8010a7f5
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 f2 03 00 00       	jmp    80100fbe <exec+0x43e>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 14 0e 00 00       	call   801019eb <ilock>
80100bd7:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100be1:	6a 34                	push   $0x34
80100be3:	6a 00                	push   $0x0
80100be5:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100beb:	50                   	push   %eax
80100bec:	ff 75 d8             	push   -0x28(%ebp)
80100bef:	e8 e3 12 00 00       	call   80101ed7 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 67 03 00 00    	jne    80100f67 <exec+0x3e7>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 59 03 00 00    	jne    80100f6a <exec+0x3ea>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 3a 6e 00 00       	call   80107a50 <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 4a 03 00 00    	je     80100f6d <exec+0x3ed>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c23:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c31:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3a:	e9 de 00 00 00       	jmp    80100d1d <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c42:	6a 20                	push   $0x20
80100c44:	50                   	push   %eax
80100c45:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c4b:	50                   	push   %eax
80100c4c:	ff 75 d8             	push   -0x28(%ebp)
80100c4f:	e8 83 12 00 00       	call   80101ed7 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 10 03 00 00    	jne    80100f70 <exec+0x3f0>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c60:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c66:	83 f8 01             	cmp    $0x1,%eax
80100c69:	0f 85 a0 00 00 00    	jne    80100d0f <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c6f:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c75:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c7b:	39 c2                	cmp    %eax,%edx
80100c7d:	0f 82 f0 02 00 00    	jb     80100f73 <exec+0x3f3>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 d7 02 00 00    	jb     80100f76 <exec+0x3f6>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 8d 71 00 00       	call   80107e49 <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 ad 02 00 00    	je     80100f79 <exec+0x3f9>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 9d 02 00 00    	jne    80100f7c <exec+0x3fc>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100ce5:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ceb:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cf1:	83 ec 0c             	sub    $0xc,%esp
80100cf4:	52                   	push   %edx
80100cf5:	50                   	push   %eax
80100cf6:	ff 75 d8             	push   -0x28(%ebp)
80100cf9:	51                   	push   %ecx
80100cfa:	ff 75 d4             	push   -0x2c(%ebp)
80100cfd:	e8 7a 70 00 00       	call   80107d7c <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 72 02 00 00    	js     80100f7f <exec+0x3ff>
80100d0d:	eb 01                	jmp    80100d10 <exec+0x190>
      continue;
80100d0f:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d10:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d17:	83 c0 20             	add    $0x20,%eax
80100d1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1d:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d24:	0f b7 c0             	movzwl %ax,%eax
80100d27:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d2a:	0f 8c 0f ff ff ff    	jl     80100c3f <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d30:	83 ec 0c             	sub    $0xc,%esp
80100d33:	ff 75 d8             	push   -0x28(%ebp)
80100d36:	e8 e1 0e 00 00       	call   80101c1c <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 86 23 00 00       	call   801030c9 <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4d:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d57:	89 45 e0             	mov    %eax,-0x20(%ebp)
  sp = KERNBASE;
80100d5a:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d61:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d64:	05 00 20 00 00       	add    $0x2000,%eax
80100d69:	83 ec 04             	sub    $0x4,%esp
80100d6c:	50                   	push   %eax
80100d6d:	ff 75 e0             	push   -0x20(%ebp)
80100d70:	ff 75 d4             	push   -0x2c(%ebp)
80100d73:	e8 d1 70 00 00       	call   80107e49 <allocuvm>
80100d78:	83 c4 10             	add    $0x10,%esp
80100d7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d7e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d82:	0f 84 fa 01 00 00    	je     80100f82 <exec+0x402>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d88:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8b:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d90:	83 ec 08             	sub    $0x8,%esp
80100d93:	50                   	push   %eax
80100d94:	ff 75 d4             	push   -0x2c(%ebp)
80100d97:	e8 0f 73 00 00       	call   801080ab <clearpteu>
80100d9c:	83 c4 10             	add    $0x10,%esp
  //sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d9f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100da6:	e9 96 00 00 00       	jmp    80100e41 <exec+0x2c1>
    if(argc >= MAXARG)
80100dab:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100daf:	0f 87 d0 01 00 00    	ja     80100f85 <exec+0x405>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100db5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc2:	01 d0                	add    %edx,%eax
80100dc4:	8b 00                	mov    (%eax),%eax
80100dc6:	83 ec 0c             	sub    $0xc,%esp
80100dc9:	50                   	push   %eax
80100dca:	e8 1b 42 00 00       	call   80104fea <strlen>
80100dcf:	83 c4 10             	add    $0x10,%esp
80100dd2:	89 c2                	mov    %eax,%edx
80100dd4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dd7:	29 d0                	sub    %edx,%eax
80100dd9:	83 e8 01             	sub    $0x1,%eax
80100ddc:	83 e0 fc             	and    $0xfffffffc,%eax
80100ddf:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100de2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dec:	8b 45 0c             	mov    0xc(%ebp),%eax
80100def:	01 d0                	add    %edx,%eax
80100df1:	8b 00                	mov    (%eax),%eax
80100df3:	83 ec 0c             	sub    $0xc,%esp
80100df6:	50                   	push   %eax
80100df7:	e8 ee 41 00 00       	call   80104fea <strlen>
80100dfc:	83 c4 10             	add    $0x10,%esp
80100dff:	83 c0 01             	add    $0x1,%eax
80100e02:	89 c2                	mov    %eax,%edx
80100e04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e07:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e11:	01 c8                	add    %ecx,%eax
80100e13:	8b 00                	mov    (%eax),%eax
80100e15:	52                   	push   %edx
80100e16:	50                   	push   %eax
80100e17:	ff 75 dc             	push   -0x24(%ebp)
80100e1a:	ff 75 d4             	push   -0x2c(%ebp)
80100e1d:	e8 28 74 00 00       	call   8010824a <copyout>
80100e22:	83 c4 10             	add    $0x10,%esp
80100e25:	85 c0                	test   %eax,%eax
80100e27:	0f 88 5b 01 00 00    	js     80100f88 <exec+0x408>
      goto bad;
    ustack[3+argc] = sp;
80100e2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e30:	8d 50 03             	lea    0x3(%eax),%edx
80100e33:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e36:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e3d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e44:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4e:	01 d0                	add    %edx,%eax
80100e50:	8b 00                	mov    (%eax),%eax
80100e52:	85 c0                	test   %eax,%eax
80100e54:	0f 85 51 ff ff ff    	jne    80100dab <exec+0x22b>
  }
  ustack[3+argc] = 0;
80100e5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5d:	83 c0 03             	add    $0x3,%eax
80100e60:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e67:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e6b:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e72:	ff ff ff 
  ustack[1] = argc;
80100e75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e78:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e81:	83 c0 01             	add    $0x1,%eax
80100e84:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8e:	29 d0                	sub    %edx,%eax
80100e90:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e99:	83 c0 04             	add    $0x4,%eax
80100e9c:	c1 e0 02             	shl    $0x2,%eax
80100e9f:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ea2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea5:	83 c0 04             	add    $0x4,%eax
80100ea8:	c1 e0 02             	shl    $0x2,%eax
80100eab:	50                   	push   %eax
80100eac:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100eb2:	50                   	push   %eax
80100eb3:	ff 75 dc             	push   -0x24(%ebp)
80100eb6:	ff 75 d4             	push   -0x2c(%ebp)
80100eb9:	e8 8c 73 00 00       	call   8010824a <copyout>
80100ebe:	83 c4 10             	add    $0x10,%esp
80100ec1:	85 c0                	test   %eax,%eax
80100ec3:	0f 88 c2 00 00 00    	js     80100f8b <exec+0x40b>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80100ecc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ed5:	eb 17                	jmp    80100eee <exec+0x36e>
    if(*s == '/')
80100ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eda:	0f b6 00             	movzbl (%eax),%eax
80100edd:	3c 2f                	cmp    $0x2f,%al
80100edf:	75 09                	jne    80100eea <exec+0x36a>
      last = s+1;
80100ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee4:	83 c0 01             	add    $0x1,%eax
80100ee7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100eea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef1:	0f b6 00             	movzbl (%eax),%eax
80100ef4:	84 c0                	test   %al,%al
80100ef6:	75 df                	jne    80100ed7 <exec+0x357>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ef8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100efb:	83 c0 6c             	add    $0x6c,%eax
80100efe:	83 ec 04             	sub    $0x4,%esp
80100f01:	6a 10                	push   $0x10
80100f03:	ff 75 f0             	push   -0x10(%ebp)
80100f06:	50                   	push   %eax
80100f07:	e8 93 40 00 00       	call   80104f9f <safestrcpy>
80100f0c:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f0f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f12:	8b 40 04             	mov    0x4(%eax),%eax
80100f15:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f18:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f1e:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f21:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f24:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f27:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f29:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2c:	8b 40 18             	mov    0x18(%eax),%eax
80100f2f:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f35:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f38:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3b:	8b 40 18             	mov    0x18(%eax),%eax
80100f3e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f41:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f44:	83 ec 0c             	sub    $0xc,%esp
80100f47:	ff 75 d0             	push   -0x30(%ebp)
80100f4a:	e8 1e 6c 00 00       	call   80107b6d <switchuvm>
80100f4f:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f52:	83 ec 0c             	sub    $0xc,%esp
80100f55:	ff 75 cc             	push   -0x34(%ebp)
80100f58:	e8 b5 70 00 00       	call   80108012 <freevm>
80100f5d:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f60:	b8 00 00 00 00       	mov    $0x0,%eax
80100f65:	eb 57                	jmp    80100fbe <exec+0x43e>
    goto bad;
80100f67:	90                   	nop
80100f68:	eb 22                	jmp    80100f8c <exec+0x40c>
    goto bad;
80100f6a:	90                   	nop
80100f6b:	eb 1f                	jmp    80100f8c <exec+0x40c>
    goto bad;
80100f6d:	90                   	nop
80100f6e:	eb 1c                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f70:	90                   	nop
80100f71:	eb 19                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f73:	90                   	nop
80100f74:	eb 16                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f76:	90                   	nop
80100f77:	eb 13                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f79:	90                   	nop
80100f7a:	eb 10                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f7c:	90                   	nop
80100f7d:	eb 0d                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f7f:	90                   	nop
80100f80:	eb 0a                	jmp    80100f8c <exec+0x40c>
    goto bad;
80100f82:	90                   	nop
80100f83:	eb 07                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f85:	90                   	nop
80100f86:	eb 04                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f88:	90                   	nop
80100f89:	eb 01                	jmp    80100f8c <exec+0x40c>
    goto bad;
80100f8b:	90                   	nop

 bad:
  if(pgdir)
80100f8c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f90:	74 0e                	je     80100fa0 <exec+0x420>
    freevm(pgdir);
80100f92:	83 ec 0c             	sub    $0xc,%esp
80100f95:	ff 75 d4             	push   -0x2c(%ebp)
80100f98:	e8 75 70 00 00       	call   80108012 <freevm>
80100f9d:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fa0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa4:	74 13                	je     80100fb9 <exec+0x439>
    iunlockput(ip);
80100fa6:	83 ec 0c             	sub    $0xc,%esp
80100fa9:	ff 75 d8             	push   -0x28(%ebp)
80100fac:	e8 6b 0c 00 00       	call   80101c1c <iunlockput>
80100fb1:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fb4:	e8 10 21 00 00       	call   801030c9 <end_op>
  }
  return -1;
80100fb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fbe:	c9                   	leave  
80100fbf:	c3                   	ret    

80100fc0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fc0:	55                   	push   %ebp
80100fc1:	89 e5                	mov    %esp,%ebp
80100fc3:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fc6:	83 ec 08             	sub    $0x8,%esp
80100fc9:	68 01 a8 10 80       	push   $0x8010a801
80100fce:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd3:	e8 2c 3b 00 00       	call   80104b04 <initlock>
80100fd8:	83 c4 10             	add    $0x10,%esp
}
80100fdb:	90                   	nop
80100fdc:	c9                   	leave  
80100fdd:	c3                   	ret    

80100fde <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fde:	55                   	push   %ebp
80100fdf:	89 e5                	mov    %esp,%ebp
80100fe1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe4:	83 ec 0c             	sub    $0xc,%esp
80100fe7:	68 a0 1a 19 80       	push   $0x80191aa0
80100fec:	e8 35 3b 00 00       	call   80104b26 <acquire>
80100ff1:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff4:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80100ffb:	eb 2d                	jmp    8010102a <filealloc+0x4c>
    if(f->ref == 0){
80100ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101000:	8b 40 04             	mov    0x4(%eax),%eax
80101003:	85 c0                	test   %eax,%eax
80101005:	75 1f                	jne    80101026 <filealloc+0x48>
      f->ref = 1;
80101007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010100a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101011:	83 ec 0c             	sub    $0xc,%esp
80101014:	68 a0 1a 19 80       	push   $0x80191aa0
80101019:	e8 76 3b 00 00       	call   80104b94 <release>
8010101e:	83 c4 10             	add    $0x10,%esp
      return f;
80101021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101024:	eb 23                	jmp    80101049 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101026:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010102a:	b8 34 24 19 80       	mov    $0x80192434,%eax
8010102f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101032:	72 c9                	jb     80100ffd <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101034:	83 ec 0c             	sub    $0xc,%esp
80101037:	68 a0 1a 19 80       	push   $0x80191aa0
8010103c:	e8 53 3b 00 00       	call   80104b94 <release>
80101041:	83 c4 10             	add    $0x10,%esp
  return 0;
80101044:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101049:	c9                   	leave  
8010104a:	c3                   	ret    

8010104b <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010104b:	55                   	push   %ebp
8010104c:	89 e5                	mov    %esp,%ebp
8010104e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101051:	83 ec 0c             	sub    $0xc,%esp
80101054:	68 a0 1a 19 80       	push   $0x80191aa0
80101059:	e8 c8 3a 00 00       	call   80104b26 <acquire>
8010105e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101061:	8b 45 08             	mov    0x8(%ebp),%eax
80101064:	8b 40 04             	mov    0x4(%eax),%eax
80101067:	85 c0                	test   %eax,%eax
80101069:	7f 0d                	jg     80101078 <filedup+0x2d>
    panic("filedup");
8010106b:	83 ec 0c             	sub    $0xc,%esp
8010106e:	68 08 a8 10 80       	push   $0x8010a808
80101073:	e8 31 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101078:	8b 45 08             	mov    0x8(%ebp),%eax
8010107b:	8b 40 04             	mov    0x4(%eax),%eax
8010107e:	8d 50 01             	lea    0x1(%eax),%edx
80101081:	8b 45 08             	mov    0x8(%ebp),%eax
80101084:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101087:	83 ec 0c             	sub    $0xc,%esp
8010108a:	68 a0 1a 19 80       	push   $0x80191aa0
8010108f:	e8 00 3b 00 00       	call   80104b94 <release>
80101094:	83 c4 10             	add    $0x10,%esp
  return f;
80101097:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010109a:	c9                   	leave  
8010109b:	c3                   	ret    

8010109c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010109c:	55                   	push   %ebp
8010109d:	89 e5                	mov    %esp,%ebp
8010109f:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010a2:	83 ec 0c             	sub    $0xc,%esp
801010a5:	68 a0 1a 19 80       	push   $0x80191aa0
801010aa:	e8 77 3a 00 00       	call   80104b26 <acquire>
801010af:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b2:	8b 45 08             	mov    0x8(%ebp),%eax
801010b5:	8b 40 04             	mov    0x4(%eax),%eax
801010b8:	85 c0                	test   %eax,%eax
801010ba:	7f 0d                	jg     801010c9 <fileclose+0x2d>
    panic("fileclose");
801010bc:	83 ec 0c             	sub    $0xc,%esp
801010bf:	68 10 a8 10 80       	push   $0x8010a810
801010c4:	e8 e0 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010c9:	8b 45 08             	mov    0x8(%ebp),%eax
801010cc:	8b 40 04             	mov    0x4(%eax),%eax
801010cf:	8d 50 ff             	lea    -0x1(%eax),%edx
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	89 50 04             	mov    %edx,0x4(%eax)
801010d8:	8b 45 08             	mov    0x8(%ebp),%eax
801010db:	8b 40 04             	mov    0x4(%eax),%eax
801010de:	85 c0                	test   %eax,%eax
801010e0:	7e 15                	jle    801010f7 <fileclose+0x5b>
    release(&ftable.lock);
801010e2:	83 ec 0c             	sub    $0xc,%esp
801010e5:	68 a0 1a 19 80       	push   $0x80191aa0
801010ea:	e8 a5 3a 00 00       	call   80104b94 <release>
801010ef:	83 c4 10             	add    $0x10,%esp
801010f2:	e9 8b 00 00 00       	jmp    80101182 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010f7:	8b 45 08             	mov    0x8(%ebp),%eax
801010fa:	8b 10                	mov    (%eax),%edx
801010fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010ff:	8b 50 04             	mov    0x4(%eax),%edx
80101102:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101105:	8b 50 08             	mov    0x8(%eax),%edx
80101108:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010110b:	8b 50 0c             	mov    0xc(%eax),%edx
8010110e:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101111:	8b 50 10             	mov    0x10(%eax),%edx
80101114:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101117:	8b 40 14             	mov    0x14(%eax),%eax
8010111a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010111d:	8b 45 08             	mov    0x8(%ebp),%eax
80101120:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101127:	8b 45 08             	mov    0x8(%ebp),%eax
8010112a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101130:	83 ec 0c             	sub    $0xc,%esp
80101133:	68 a0 1a 19 80       	push   $0x80191aa0
80101138:	e8 57 3a 00 00       	call   80104b94 <release>
8010113d:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101140:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101143:	83 f8 01             	cmp    $0x1,%eax
80101146:	75 19                	jne    80101161 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101148:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010114c:	0f be d0             	movsbl %al,%edx
8010114f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101152:	83 ec 08             	sub    $0x8,%esp
80101155:	52                   	push   %edx
80101156:	50                   	push   %eax
80101157:	e8 64 25 00 00       	call   801036c0 <pipeclose>
8010115c:	83 c4 10             	add    $0x10,%esp
8010115f:	eb 21                	jmp    80101182 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101161:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101164:	83 f8 02             	cmp    $0x2,%eax
80101167:	75 19                	jne    80101182 <fileclose+0xe6>
    begin_op();
80101169:	e8 cf 1e 00 00       	call   8010303d <begin_op>
    iput(ff.ip);
8010116e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101171:	83 ec 0c             	sub    $0xc,%esp
80101174:	50                   	push   %eax
80101175:	e8 d2 09 00 00       	call   80101b4c <iput>
8010117a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117d:	e8 47 1f 00 00       	call   801030c9 <end_op>
  }
}
80101182:	c9                   	leave  
80101183:	c3                   	ret    

80101184 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101184:	55                   	push   %ebp
80101185:	89 e5                	mov    %esp,%ebp
80101187:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 00                	mov    (%eax),%eax
8010118f:	83 f8 02             	cmp    $0x2,%eax
80101192:	75 40                	jne    801011d4 <filestat+0x50>
    ilock(f->ip);
80101194:	8b 45 08             	mov    0x8(%ebp),%eax
80101197:	8b 40 10             	mov    0x10(%eax),%eax
8010119a:	83 ec 0c             	sub    $0xc,%esp
8010119d:	50                   	push   %eax
8010119e:	e8 48 08 00 00       	call   801019eb <ilock>
801011a3:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011a6:	8b 45 08             	mov    0x8(%ebp),%eax
801011a9:	8b 40 10             	mov    0x10(%eax),%eax
801011ac:	83 ec 08             	sub    $0x8,%esp
801011af:	ff 75 0c             	push   0xc(%ebp)
801011b2:	50                   	push   %eax
801011b3:	e8 d9 0c 00 00       	call   80101e91 <stati>
801011b8:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011bb:	8b 45 08             	mov    0x8(%ebp),%eax
801011be:	8b 40 10             	mov    0x10(%eax),%eax
801011c1:	83 ec 0c             	sub    $0xc,%esp
801011c4:	50                   	push   %eax
801011c5:	e8 34 09 00 00       	call   80101afe <iunlock>
801011ca:	83 c4 10             	add    $0x10,%esp
    return 0;
801011cd:	b8 00 00 00 00       	mov    $0x0,%eax
801011d2:	eb 05                	jmp    801011d9 <filestat+0x55>
  }
  return -1;
801011d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d9:	c9                   	leave  
801011da:	c3                   	ret    

801011db <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011db:	55                   	push   %ebp
801011dc:	89 e5                	mov    %esp,%ebp
801011de:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011e1:	8b 45 08             	mov    0x8(%ebp),%eax
801011e4:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011e8:	84 c0                	test   %al,%al
801011ea:	75 0a                	jne    801011f6 <fileread+0x1b>
    return -1;
801011ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011f1:	e9 9b 00 00 00       	jmp    80101291 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011f6:	8b 45 08             	mov    0x8(%ebp),%eax
801011f9:	8b 00                	mov    (%eax),%eax
801011fb:	83 f8 01             	cmp    $0x1,%eax
801011fe:	75 1a                	jne    8010121a <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101200:	8b 45 08             	mov    0x8(%ebp),%eax
80101203:	8b 40 0c             	mov    0xc(%eax),%eax
80101206:	83 ec 04             	sub    $0x4,%esp
80101209:	ff 75 10             	push   0x10(%ebp)
8010120c:	ff 75 0c             	push   0xc(%ebp)
8010120f:	50                   	push   %eax
80101210:	e8 58 26 00 00       	call   8010386d <piperead>
80101215:	83 c4 10             	add    $0x10,%esp
80101218:	eb 77                	jmp    80101291 <fileread+0xb6>
  if(f->type == FD_INODE){
8010121a:	8b 45 08             	mov    0x8(%ebp),%eax
8010121d:	8b 00                	mov    (%eax),%eax
8010121f:	83 f8 02             	cmp    $0x2,%eax
80101222:	75 60                	jne    80101284 <fileread+0xa9>
    ilock(f->ip);
80101224:	8b 45 08             	mov    0x8(%ebp),%eax
80101227:	8b 40 10             	mov    0x10(%eax),%eax
8010122a:	83 ec 0c             	sub    $0xc,%esp
8010122d:	50                   	push   %eax
8010122e:	e8 b8 07 00 00       	call   801019eb <ilock>
80101233:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101236:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101239:	8b 45 08             	mov    0x8(%ebp),%eax
8010123c:	8b 50 14             	mov    0x14(%eax),%edx
8010123f:	8b 45 08             	mov    0x8(%ebp),%eax
80101242:	8b 40 10             	mov    0x10(%eax),%eax
80101245:	51                   	push   %ecx
80101246:	52                   	push   %edx
80101247:	ff 75 0c             	push   0xc(%ebp)
8010124a:	50                   	push   %eax
8010124b:	e8 87 0c 00 00       	call   80101ed7 <readi>
80101250:	83 c4 10             	add    $0x10,%esp
80101253:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101256:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010125a:	7e 11                	jle    8010126d <fileread+0x92>
      f->off += r;
8010125c:	8b 45 08             	mov    0x8(%ebp),%eax
8010125f:	8b 50 14             	mov    0x14(%eax),%edx
80101262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101265:	01 c2                	add    %eax,%edx
80101267:	8b 45 08             	mov    0x8(%ebp),%eax
8010126a:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010126d:	8b 45 08             	mov    0x8(%ebp),%eax
80101270:	8b 40 10             	mov    0x10(%eax),%eax
80101273:	83 ec 0c             	sub    $0xc,%esp
80101276:	50                   	push   %eax
80101277:	e8 82 08 00 00       	call   80101afe <iunlock>
8010127c:	83 c4 10             	add    $0x10,%esp
    return r;
8010127f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101282:	eb 0d                	jmp    80101291 <fileread+0xb6>
  }
  panic("fileread");
80101284:	83 ec 0c             	sub    $0xc,%esp
80101287:	68 1a a8 10 80       	push   $0x8010a81a
8010128c:	e8 18 f3 ff ff       	call   801005a9 <panic>
}
80101291:	c9                   	leave  
80101292:	c3                   	ret    

80101293 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101293:	55                   	push   %ebp
80101294:	89 e5                	mov    %esp,%ebp
80101296:	53                   	push   %ebx
80101297:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010129a:	8b 45 08             	mov    0x8(%ebp),%eax
8010129d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012a1:	84 c0                	test   %al,%al
801012a3:	75 0a                	jne    801012af <filewrite+0x1c>
    return -1;
801012a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012aa:	e9 1b 01 00 00       	jmp    801013ca <filewrite+0x137>
  if(f->type == FD_PIPE)
801012af:	8b 45 08             	mov    0x8(%ebp),%eax
801012b2:	8b 00                	mov    (%eax),%eax
801012b4:	83 f8 01             	cmp    $0x1,%eax
801012b7:	75 1d                	jne    801012d6 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012b9:	8b 45 08             	mov    0x8(%ebp),%eax
801012bc:	8b 40 0c             	mov    0xc(%eax),%eax
801012bf:	83 ec 04             	sub    $0x4,%esp
801012c2:	ff 75 10             	push   0x10(%ebp)
801012c5:	ff 75 0c             	push   0xc(%ebp)
801012c8:	50                   	push   %eax
801012c9:	e8 9d 24 00 00       	call   8010376b <pipewrite>
801012ce:	83 c4 10             	add    $0x10,%esp
801012d1:	e9 f4 00 00 00       	jmp    801013ca <filewrite+0x137>
  if(f->type == FD_INODE){
801012d6:	8b 45 08             	mov    0x8(%ebp),%eax
801012d9:	8b 00                	mov    (%eax),%eax
801012db:	83 f8 02             	cmp    $0x2,%eax
801012de:	0f 85 d9 00 00 00    	jne    801013bd <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012e4:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012f2:	e9 a3 00 00 00       	jmp    8010139a <filewrite+0x107>
      int n1 = n - i;
801012f7:	8b 45 10             	mov    0x10(%ebp),%eax
801012fa:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101300:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101303:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101306:	7e 06                	jle    8010130e <filewrite+0x7b>
        n1 = max;
80101308:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010130b:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010130e:	e8 2a 1d 00 00       	call   8010303d <begin_op>
      ilock(f->ip);
80101313:	8b 45 08             	mov    0x8(%ebp),%eax
80101316:	8b 40 10             	mov    0x10(%eax),%eax
80101319:	83 ec 0c             	sub    $0xc,%esp
8010131c:	50                   	push   %eax
8010131d:	e8 c9 06 00 00       	call   801019eb <ilock>
80101322:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101325:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101328:	8b 45 08             	mov    0x8(%ebp),%eax
8010132b:	8b 50 14             	mov    0x14(%eax),%edx
8010132e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101331:	8b 45 0c             	mov    0xc(%ebp),%eax
80101334:	01 c3                	add    %eax,%ebx
80101336:	8b 45 08             	mov    0x8(%ebp),%eax
80101339:	8b 40 10             	mov    0x10(%eax),%eax
8010133c:	51                   	push   %ecx
8010133d:	52                   	push   %edx
8010133e:	53                   	push   %ebx
8010133f:	50                   	push   %eax
80101340:	e8 e7 0c 00 00       	call   8010202c <writei>
80101345:	83 c4 10             	add    $0x10,%esp
80101348:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010134b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010134f:	7e 11                	jle    80101362 <filewrite+0xcf>
        f->off += r;
80101351:	8b 45 08             	mov    0x8(%ebp),%eax
80101354:	8b 50 14             	mov    0x14(%eax),%edx
80101357:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010135a:	01 c2                	add    %eax,%edx
8010135c:	8b 45 08             	mov    0x8(%ebp),%eax
8010135f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101362:	8b 45 08             	mov    0x8(%ebp),%eax
80101365:	8b 40 10             	mov    0x10(%eax),%eax
80101368:	83 ec 0c             	sub    $0xc,%esp
8010136b:	50                   	push   %eax
8010136c:	e8 8d 07 00 00       	call   80101afe <iunlock>
80101371:	83 c4 10             	add    $0x10,%esp
      end_op();
80101374:	e8 50 1d 00 00       	call   801030c9 <end_op>

      if(r < 0)
80101379:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010137d:	78 29                	js     801013a8 <filewrite+0x115>
        break;
      if(r != n1)
8010137f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101382:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101385:	74 0d                	je     80101394 <filewrite+0x101>
        panic("short filewrite");
80101387:	83 ec 0c             	sub    $0xc,%esp
8010138a:	68 23 a8 10 80       	push   $0x8010a823
8010138f:	e8 15 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101394:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101397:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
8010139a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139d:	3b 45 10             	cmp    0x10(%ebp),%eax
801013a0:	0f 8c 51 ff ff ff    	jl     801012f7 <filewrite+0x64>
801013a6:	eb 01                	jmp    801013a9 <filewrite+0x116>
        break;
801013a8:	90                   	nop
    }
    return i == n ? n : -1;
801013a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ac:	3b 45 10             	cmp    0x10(%ebp),%eax
801013af:	75 05                	jne    801013b6 <filewrite+0x123>
801013b1:	8b 45 10             	mov    0x10(%ebp),%eax
801013b4:	eb 14                	jmp    801013ca <filewrite+0x137>
801013b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013bb:	eb 0d                	jmp    801013ca <filewrite+0x137>
  }
  panic("filewrite");
801013bd:	83 ec 0c             	sub    $0xc,%esp
801013c0:	68 33 a8 10 80       	push   $0x8010a833
801013c5:	e8 df f1 ff ff       	call   801005a9 <panic>
}
801013ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013cd:	c9                   	leave  
801013ce:	c3                   	ret    

801013cf <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013cf:	55                   	push   %ebp
801013d0:	89 e5                	mov    %esp,%ebp
801013d2:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013d5:	8b 45 08             	mov    0x8(%ebp),%eax
801013d8:	83 ec 08             	sub    $0x8,%esp
801013db:	6a 01                	push   $0x1
801013dd:	50                   	push   %eax
801013de:	e8 1e ee ff ff       	call   80100201 <bread>
801013e3:	83 c4 10             	add    $0x10,%esp
801013e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ec:	83 c0 5c             	add    $0x5c,%eax
801013ef:	83 ec 04             	sub    $0x4,%esp
801013f2:	6a 1c                	push   $0x1c
801013f4:	50                   	push   %eax
801013f5:	ff 75 0c             	push   0xc(%ebp)
801013f8:	e8 5e 3a 00 00       	call   80104e5b <memmove>
801013fd:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101400:	83 ec 0c             	sub    $0xc,%esp
80101403:	ff 75 f4             	push   -0xc(%ebp)
80101406:	e8 78 ee ff ff       	call   80100283 <brelse>
8010140b:	83 c4 10             	add    $0x10,%esp
}
8010140e:	90                   	nop
8010140f:	c9                   	leave  
80101410:	c3                   	ret    

80101411 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101411:	55                   	push   %ebp
80101412:	89 e5                	mov    %esp,%ebp
80101414:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101417:	8b 55 0c             	mov    0xc(%ebp),%edx
8010141a:	8b 45 08             	mov    0x8(%ebp),%eax
8010141d:	83 ec 08             	sub    $0x8,%esp
80101420:	52                   	push   %edx
80101421:	50                   	push   %eax
80101422:	e8 da ed ff ff       	call   80100201 <bread>
80101427:	83 c4 10             	add    $0x10,%esp
8010142a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010142d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101430:	83 c0 5c             	add    $0x5c,%eax
80101433:	83 ec 04             	sub    $0x4,%esp
80101436:	68 00 02 00 00       	push   $0x200
8010143b:	6a 00                	push   $0x0
8010143d:	50                   	push   %eax
8010143e:	e8 59 39 00 00       	call   80104d9c <memset>
80101443:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101446:	83 ec 0c             	sub    $0xc,%esp
80101449:	ff 75 f4             	push   -0xc(%ebp)
8010144c:	e8 25 1e 00 00       	call   80103276 <log_write>
80101451:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101454:	83 ec 0c             	sub    $0xc,%esp
80101457:	ff 75 f4             	push   -0xc(%ebp)
8010145a:	e8 24 ee ff ff       	call   80100283 <brelse>
8010145f:	83 c4 10             	add    $0x10,%esp
}
80101462:	90                   	nop
80101463:	c9                   	leave  
80101464:	c3                   	ret    

80101465 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101465:	55                   	push   %ebp
80101466:	89 e5                	mov    %esp,%ebp
80101468:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010146b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101472:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101479:	e9 0b 01 00 00       	jmp    80101589 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010147e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101481:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101487:	85 c0                	test   %eax,%eax
80101489:	0f 48 c2             	cmovs  %edx,%eax
8010148c:	c1 f8 0c             	sar    $0xc,%eax
8010148f:	89 c2                	mov    %eax,%edx
80101491:	a1 58 24 19 80       	mov    0x80192458,%eax
80101496:	01 d0                	add    %edx,%eax
80101498:	83 ec 08             	sub    $0x8,%esp
8010149b:	50                   	push   %eax
8010149c:	ff 75 08             	push   0x8(%ebp)
8010149f:	e8 5d ed ff ff       	call   80100201 <bread>
801014a4:	83 c4 10             	add    $0x10,%esp
801014a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014b1:	e9 9e 00 00 00       	jmp    80101554 <balloc+0xef>
      m = 1 << (bi % 8);
801014b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b9:	83 e0 07             	and    $0x7,%eax
801014bc:	ba 01 00 00 00       	mov    $0x1,%edx
801014c1:	89 c1                	mov    %eax,%ecx
801014c3:	d3 e2                	shl    %cl,%edx
801014c5:	89 d0                	mov    %edx,%eax
801014c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cd:	8d 50 07             	lea    0x7(%eax),%edx
801014d0:	85 c0                	test   %eax,%eax
801014d2:	0f 48 c2             	cmovs  %edx,%eax
801014d5:	c1 f8 03             	sar    $0x3,%eax
801014d8:	89 c2                	mov    %eax,%edx
801014da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014dd:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014e2:	0f b6 c0             	movzbl %al,%eax
801014e5:	23 45 e8             	and    -0x18(%ebp),%eax
801014e8:	85 c0                	test   %eax,%eax
801014ea:	75 64                	jne    80101550 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ef:	8d 50 07             	lea    0x7(%eax),%edx
801014f2:	85 c0                	test   %eax,%eax
801014f4:	0f 48 c2             	cmovs  %edx,%eax
801014f7:	c1 f8 03             	sar    $0x3,%eax
801014fa:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014fd:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101502:	89 d1                	mov    %edx,%ecx
80101504:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101507:	09 ca                	or     %ecx,%edx
80101509:	89 d1                	mov    %edx,%ecx
8010150b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010150e:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101512:	83 ec 0c             	sub    $0xc,%esp
80101515:	ff 75 ec             	push   -0x14(%ebp)
80101518:	e8 59 1d 00 00       	call   80103276 <log_write>
8010151d:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101520:	83 ec 0c             	sub    $0xc,%esp
80101523:	ff 75 ec             	push   -0x14(%ebp)
80101526:	e8 58 ed ff ff       	call   80100283 <brelse>
8010152b:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010152e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101531:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101534:	01 c2                	add    %eax,%edx
80101536:	8b 45 08             	mov    0x8(%ebp),%eax
80101539:	83 ec 08             	sub    $0x8,%esp
8010153c:	52                   	push   %edx
8010153d:	50                   	push   %eax
8010153e:	e8 ce fe ff ff       	call   80101411 <bzero>
80101543:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101546:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101549:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154c:	01 d0                	add    %edx,%eax
8010154e:	eb 57                	jmp    801015a7 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101550:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101554:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010155b:	7f 17                	jg     80101574 <balloc+0x10f>
8010155d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101560:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101563:	01 d0                	add    %edx,%eax
80101565:	89 c2                	mov    %eax,%edx
80101567:	a1 40 24 19 80       	mov    0x80192440,%eax
8010156c:	39 c2                	cmp    %eax,%edx
8010156e:	0f 82 42 ff ff ff    	jb     801014b6 <balloc+0x51>
      }
    }
    brelse(bp);
80101574:	83 ec 0c             	sub    $0xc,%esp
80101577:	ff 75 ec             	push   -0x14(%ebp)
8010157a:	e8 04 ed ff ff       	call   80100283 <brelse>
8010157f:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101582:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101589:	8b 15 40 24 19 80    	mov    0x80192440,%edx
8010158f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101592:	39 c2                	cmp    %eax,%edx
80101594:	0f 87 e4 fe ff ff    	ja     8010147e <balloc+0x19>
  }
  panic("balloc: out of blocks");
8010159a:	83 ec 0c             	sub    $0xc,%esp
8010159d:	68 40 a8 10 80       	push   $0x8010a840
801015a2:	e8 02 f0 ff ff       	call   801005a9 <panic>
}
801015a7:	c9                   	leave  
801015a8:	c3                   	ret    

801015a9 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015a9:	55                   	push   %ebp
801015aa:	89 e5                	mov    %esp,%ebp
801015ac:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015af:	83 ec 08             	sub    $0x8,%esp
801015b2:	68 40 24 19 80       	push   $0x80192440
801015b7:	ff 75 08             	push   0x8(%ebp)
801015ba:	e8 10 fe ff ff       	call   801013cf <readsb>
801015bf:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c5:	c1 e8 0c             	shr    $0xc,%eax
801015c8:	89 c2                	mov    %eax,%edx
801015ca:	a1 58 24 19 80       	mov    0x80192458,%eax
801015cf:	01 c2                	add    %eax,%edx
801015d1:	8b 45 08             	mov    0x8(%ebp),%eax
801015d4:	83 ec 08             	sub    $0x8,%esp
801015d7:	52                   	push   %edx
801015d8:	50                   	push   %eax
801015d9:	e8 23 ec ff ff       	call   80100201 <bread>
801015de:	83 c4 10             	add    $0x10,%esp
801015e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e7:	25 ff 0f 00 00       	and    $0xfff,%eax
801015ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f2:	83 e0 07             	and    $0x7,%eax
801015f5:	ba 01 00 00 00       	mov    $0x1,%edx
801015fa:	89 c1                	mov    %eax,%ecx
801015fc:	d3 e2                	shl    %cl,%edx
801015fe:	89 d0                	mov    %edx,%eax
80101600:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101603:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101606:	8d 50 07             	lea    0x7(%eax),%edx
80101609:	85 c0                	test   %eax,%eax
8010160b:	0f 48 c2             	cmovs  %edx,%eax
8010160e:	c1 f8 03             	sar    $0x3,%eax
80101611:	89 c2                	mov    %eax,%edx
80101613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101616:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010161b:	0f b6 c0             	movzbl %al,%eax
8010161e:	23 45 ec             	and    -0x14(%ebp),%eax
80101621:	85 c0                	test   %eax,%eax
80101623:	75 0d                	jne    80101632 <bfree+0x89>
    panic("freeing free block");
80101625:	83 ec 0c             	sub    $0xc,%esp
80101628:	68 56 a8 10 80       	push   $0x8010a856
8010162d:	e8 77 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101632:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101635:	8d 50 07             	lea    0x7(%eax),%edx
80101638:	85 c0                	test   %eax,%eax
8010163a:	0f 48 c2             	cmovs  %edx,%eax
8010163d:	c1 f8 03             	sar    $0x3,%eax
80101640:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101643:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101648:	89 d1                	mov    %edx,%ecx
8010164a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164d:	f7 d2                	not    %edx
8010164f:	21 ca                	and    %ecx,%edx
80101651:	89 d1                	mov    %edx,%ecx
80101653:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101656:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010165a:	83 ec 0c             	sub    $0xc,%esp
8010165d:	ff 75 f4             	push   -0xc(%ebp)
80101660:	e8 11 1c 00 00       	call   80103276 <log_write>
80101665:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	ff 75 f4             	push   -0xc(%ebp)
8010166e:	e8 10 ec ff ff       	call   80100283 <brelse>
80101673:	83 c4 10             	add    $0x10,%esp
}
80101676:	90                   	nop
80101677:	c9                   	leave  
80101678:	c3                   	ret    

80101679 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101679:	55                   	push   %ebp
8010167a:	89 e5                	mov    %esp,%ebp
8010167c:	57                   	push   %edi
8010167d:	56                   	push   %esi
8010167e:	53                   	push   %ebx
8010167f:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101682:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101689:	83 ec 08             	sub    $0x8,%esp
8010168c:	68 69 a8 10 80       	push   $0x8010a869
80101691:	68 60 24 19 80       	push   $0x80192460
80101696:	e8 69 34 00 00       	call   80104b04 <initlock>
8010169b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010169e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016a5:	eb 2d                	jmp    801016d4 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016aa:	89 d0                	mov    %edx,%eax
801016ac:	c1 e0 03             	shl    $0x3,%eax
801016af:	01 d0                	add    %edx,%eax
801016b1:	c1 e0 04             	shl    $0x4,%eax
801016b4:	83 c0 30             	add    $0x30,%eax
801016b7:	05 60 24 19 80       	add    $0x80192460,%eax
801016bc:	83 c0 10             	add    $0x10,%eax
801016bf:	83 ec 08             	sub    $0x8,%esp
801016c2:	68 70 a8 10 80       	push   $0x8010a870
801016c7:	50                   	push   %eax
801016c8:	e8 da 32 00 00       	call   801049a7 <initsleeplock>
801016cd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016d0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d4:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d8:	7e cd                	jle    801016a7 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016da:	83 ec 08             	sub    $0x8,%esp
801016dd:	68 40 24 19 80       	push   $0x80192440
801016e2:	ff 75 08             	push   0x8(%ebp)
801016e5:	e8 e5 fc ff ff       	call   801013cf <readsb>
801016ea:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ed:	a1 58 24 19 80       	mov    0x80192458,%eax
801016f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f5:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016fb:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101701:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
80101707:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
8010170d:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101713:	a1 40 24 19 80       	mov    0x80192440,%eax
80101718:	ff 75 d4             	push   -0x2c(%ebp)
8010171b:	57                   	push   %edi
8010171c:	56                   	push   %esi
8010171d:	53                   	push   %ebx
8010171e:	51                   	push   %ecx
8010171f:	52                   	push   %edx
80101720:	50                   	push   %eax
80101721:	68 78 a8 10 80       	push   $0x8010a878
80101726:	e8 c9 ec ff ff       	call   801003f4 <cprintf>
8010172b:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010172e:	90                   	nop
8010172f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101732:	5b                   	pop    %ebx
80101733:	5e                   	pop    %esi
80101734:	5f                   	pop    %edi
80101735:	5d                   	pop    %ebp
80101736:	c3                   	ret    

80101737 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101737:	55                   	push   %ebp
80101738:	89 e5                	mov    %esp,%ebp
8010173a:	83 ec 28             	sub    $0x28,%esp
8010173d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101740:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101744:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010174b:	e9 9e 00 00 00       	jmp    801017ee <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101753:	c1 e8 03             	shr    $0x3,%eax
80101756:	89 c2                	mov    %eax,%edx
80101758:	a1 54 24 19 80       	mov    0x80192454,%eax
8010175d:	01 d0                	add    %edx,%eax
8010175f:	83 ec 08             	sub    $0x8,%esp
80101762:	50                   	push   %eax
80101763:	ff 75 08             	push   0x8(%ebp)
80101766:	e8 96 ea ff ff       	call   80100201 <bread>
8010176b:	83 c4 10             	add    $0x10,%esp
8010176e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101771:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101774:	8d 50 5c             	lea    0x5c(%eax),%edx
80101777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177a:	83 e0 07             	and    $0x7,%eax
8010177d:	c1 e0 06             	shl    $0x6,%eax
80101780:	01 d0                	add    %edx,%eax
80101782:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101785:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101788:	0f b7 00             	movzwl (%eax),%eax
8010178b:	66 85 c0             	test   %ax,%ax
8010178e:	75 4c                	jne    801017dc <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101790:	83 ec 04             	sub    $0x4,%esp
80101793:	6a 40                	push   $0x40
80101795:	6a 00                	push   $0x0
80101797:	ff 75 ec             	push   -0x14(%ebp)
8010179a:	e8 fd 35 00 00       	call   80104d9c <memset>
8010179f:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a5:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a9:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ac:	83 ec 0c             	sub    $0xc,%esp
801017af:	ff 75 f0             	push   -0x10(%ebp)
801017b2:	e8 bf 1a 00 00       	call   80103276 <log_write>
801017b7:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017ba:	83 ec 0c             	sub    $0xc,%esp
801017bd:	ff 75 f0             	push   -0x10(%ebp)
801017c0:	e8 be ea ff ff       	call   80100283 <brelse>
801017c5:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017cb:	83 ec 08             	sub    $0x8,%esp
801017ce:	50                   	push   %eax
801017cf:	ff 75 08             	push   0x8(%ebp)
801017d2:	e8 f8 00 00 00       	call   801018cf <iget>
801017d7:	83 c4 10             	add    $0x10,%esp
801017da:	eb 30                	jmp    8010180c <ialloc+0xd5>
    }
    brelse(bp);
801017dc:	83 ec 0c             	sub    $0xc,%esp
801017df:	ff 75 f0             	push   -0x10(%ebp)
801017e2:	e8 9c ea ff ff       	call   80100283 <brelse>
801017e7:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017ee:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f7:	39 c2                	cmp    %eax,%edx
801017f9:	0f 87 51 ff ff ff    	ja     80101750 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017ff:	83 ec 0c             	sub    $0xc,%esp
80101802:	68 cb a8 10 80       	push   $0x8010a8cb
80101807:	e8 9d ed ff ff       	call   801005a9 <panic>
}
8010180c:	c9                   	leave  
8010180d:	c3                   	ret    

8010180e <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010180e:	55                   	push   %ebp
8010180f:	89 e5                	mov    %esp,%ebp
80101811:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101814:	8b 45 08             	mov    0x8(%ebp),%eax
80101817:	8b 40 04             	mov    0x4(%eax),%eax
8010181a:	c1 e8 03             	shr    $0x3,%eax
8010181d:	89 c2                	mov    %eax,%edx
8010181f:	a1 54 24 19 80       	mov    0x80192454,%eax
80101824:	01 c2                	add    %eax,%edx
80101826:	8b 45 08             	mov    0x8(%ebp),%eax
80101829:	8b 00                	mov    (%eax),%eax
8010182b:	83 ec 08             	sub    $0x8,%esp
8010182e:	52                   	push   %edx
8010182f:	50                   	push   %eax
80101830:	e8 cc e9 ff ff       	call   80100201 <bread>
80101835:	83 c4 10             	add    $0x10,%esp
80101838:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010183b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183e:	8d 50 5c             	lea    0x5c(%eax),%edx
80101841:	8b 45 08             	mov    0x8(%ebp),%eax
80101844:	8b 40 04             	mov    0x4(%eax),%eax
80101847:	83 e0 07             	and    $0x7,%eax
8010184a:	c1 e0 06             	shl    $0x6,%eax
8010184d:	01 d0                	add    %edx,%eax
8010184f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101852:	8b 45 08             	mov    0x8(%ebp),%eax
80101855:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101859:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185c:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010185f:	8b 45 08             	mov    0x8(%ebp),%eax
80101862:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101869:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010186d:	8b 45 08             	mov    0x8(%ebp),%eax
80101870:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101874:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101877:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010187b:	8b 45 08             	mov    0x8(%ebp),%eax
8010187e:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101882:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101885:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101889:	8b 45 08             	mov    0x8(%ebp),%eax
8010188c:	8b 50 58             	mov    0x58(%eax),%edx
8010188f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101892:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101895:	8b 45 08             	mov    0x8(%ebp),%eax
80101898:	8d 50 5c             	lea    0x5c(%eax),%edx
8010189b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189e:	83 c0 0c             	add    $0xc,%eax
801018a1:	83 ec 04             	sub    $0x4,%esp
801018a4:	6a 34                	push   $0x34
801018a6:	52                   	push   %edx
801018a7:	50                   	push   %eax
801018a8:	e8 ae 35 00 00       	call   80104e5b <memmove>
801018ad:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018b0:	83 ec 0c             	sub    $0xc,%esp
801018b3:	ff 75 f4             	push   -0xc(%ebp)
801018b6:	e8 bb 19 00 00       	call   80103276 <log_write>
801018bb:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018be:	83 ec 0c             	sub    $0xc,%esp
801018c1:	ff 75 f4             	push   -0xc(%ebp)
801018c4:	e8 ba e9 ff ff       	call   80100283 <brelse>
801018c9:	83 c4 10             	add    $0x10,%esp
}
801018cc:	90                   	nop
801018cd:	c9                   	leave  
801018ce:	c3                   	ret    

801018cf <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018cf:	55                   	push   %ebp
801018d0:	89 e5                	mov    %esp,%ebp
801018d2:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018d5:	83 ec 0c             	sub    $0xc,%esp
801018d8:	68 60 24 19 80       	push   $0x80192460
801018dd:	e8 44 32 00 00       	call   80104b26 <acquire>
801018e2:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018ec:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018f3:	eb 60                	jmp    80101955 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f8:	8b 40 08             	mov    0x8(%eax),%eax
801018fb:	85 c0                	test   %eax,%eax
801018fd:	7e 39                	jle    80101938 <iget+0x69>
801018ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101902:	8b 00                	mov    (%eax),%eax
80101904:	39 45 08             	cmp    %eax,0x8(%ebp)
80101907:	75 2f                	jne    80101938 <iget+0x69>
80101909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190c:	8b 40 04             	mov    0x4(%eax),%eax
8010190f:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101912:	75 24                	jne    80101938 <iget+0x69>
      ip->ref++;
80101914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101917:	8b 40 08             	mov    0x8(%eax),%eax
8010191a:	8d 50 01             	lea    0x1(%eax),%edx
8010191d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101920:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101923:	83 ec 0c             	sub    $0xc,%esp
80101926:	68 60 24 19 80       	push   $0x80192460
8010192b:	e8 64 32 00 00       	call   80104b94 <release>
80101930:	83 c4 10             	add    $0x10,%esp
      return ip;
80101933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101936:	eb 77                	jmp    801019af <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101938:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010193c:	75 10                	jne    8010194e <iget+0x7f>
8010193e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101941:	8b 40 08             	mov    0x8(%eax),%eax
80101944:	85 c0                	test   %eax,%eax
80101946:	75 06                	jne    8010194e <iget+0x7f>
      empty = ip;
80101948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010194e:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101955:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
8010195c:	72 97                	jb     801018f5 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101962:	75 0d                	jne    80101971 <iget+0xa2>
    panic("iget: no inodes");
80101964:	83 ec 0c             	sub    $0xc,%esp
80101967:	68 dd a8 10 80       	push   $0x8010a8dd
8010196c:	e8 38 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101971:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101974:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197a:	8b 55 08             	mov    0x8(%ebp),%edx
8010197d:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010197f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101982:	8b 55 0c             	mov    0xc(%ebp),%edx
80101985:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101995:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010199c:	83 ec 0c             	sub    $0xc,%esp
8010199f:	68 60 24 19 80       	push   $0x80192460
801019a4:	e8 eb 31 00 00       	call   80104b94 <release>
801019a9:	83 c4 10             	add    $0x10,%esp

  return ip;
801019ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019af:	c9                   	leave  
801019b0:	c3                   	ret    

801019b1 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b1:	55                   	push   %ebp
801019b2:	89 e5                	mov    %esp,%ebp
801019b4:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019b7:	83 ec 0c             	sub    $0xc,%esp
801019ba:	68 60 24 19 80       	push   $0x80192460
801019bf:	e8 62 31 00 00       	call   80104b26 <acquire>
801019c4:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ca:	8b 40 08             	mov    0x8(%eax),%eax
801019cd:	8d 50 01             	lea    0x1(%eax),%edx
801019d0:	8b 45 08             	mov    0x8(%ebp),%eax
801019d3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d6:	83 ec 0c             	sub    $0xc,%esp
801019d9:	68 60 24 19 80       	push   $0x80192460
801019de:	e8 b1 31 00 00       	call   80104b94 <release>
801019e3:	83 c4 10             	add    $0x10,%esp
  return ip;
801019e6:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019e9:	c9                   	leave  
801019ea:	c3                   	ret    

801019eb <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019eb:	55                   	push   %ebp
801019ec:	89 e5                	mov    %esp,%ebp
801019ee:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019f5:	74 0a                	je     80101a01 <ilock+0x16>
801019f7:	8b 45 08             	mov    0x8(%ebp),%eax
801019fa:	8b 40 08             	mov    0x8(%eax),%eax
801019fd:	85 c0                	test   %eax,%eax
801019ff:	7f 0d                	jg     80101a0e <ilock+0x23>
    panic("ilock");
80101a01:	83 ec 0c             	sub    $0xc,%esp
80101a04:	68 ed a8 10 80       	push   $0x8010a8ed
80101a09:	e8 9b eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a11:	83 c0 0c             	add    $0xc,%eax
80101a14:	83 ec 0c             	sub    $0xc,%esp
80101a17:	50                   	push   %eax
80101a18:	e8 c6 2f 00 00       	call   801049e3 <acquiresleep>
80101a1d:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a20:	8b 45 08             	mov    0x8(%ebp),%eax
80101a23:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a26:	85 c0                	test   %eax,%eax
80101a28:	0f 85 cd 00 00 00    	jne    80101afb <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a31:	8b 40 04             	mov    0x4(%eax),%eax
80101a34:	c1 e8 03             	shr    $0x3,%eax
80101a37:	89 c2                	mov    %eax,%edx
80101a39:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a3e:	01 c2                	add    %eax,%edx
80101a40:	8b 45 08             	mov    0x8(%ebp),%eax
80101a43:	8b 00                	mov    (%eax),%eax
80101a45:	83 ec 08             	sub    $0x8,%esp
80101a48:	52                   	push   %edx
80101a49:	50                   	push   %eax
80101a4a:	e8 b2 e7 ff ff       	call   80100201 <bread>
80101a4f:	83 c4 10             	add    $0x10,%esp
80101a52:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a58:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5e:	8b 40 04             	mov    0x4(%eax),%eax
80101a61:	83 e0 07             	and    $0x7,%eax
80101a64:	c1 e0 06             	shl    $0x6,%eax
80101a67:	01 d0                	add    %edx,%eax
80101a69:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6f:	0f b7 10             	movzwl (%eax),%edx
80101a72:	8b 45 08             	mov    0x8(%ebp),%eax
80101a75:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7c:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a80:	8b 45 08             	mov    0x8(%ebp),%eax
80101a83:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a8a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a91:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a98:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9f:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa6:	8b 50 08             	mov    0x8(%eax),%edx
80101aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80101aac:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab2:	8d 50 0c             	lea    0xc(%eax),%edx
80101ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab8:	83 c0 5c             	add    $0x5c,%eax
80101abb:	83 ec 04             	sub    $0x4,%esp
80101abe:	6a 34                	push   $0x34
80101ac0:	52                   	push   %edx
80101ac1:	50                   	push   %eax
80101ac2:	e8 94 33 00 00       	call   80104e5b <memmove>
80101ac7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101aca:	83 ec 0c             	sub    $0xc,%esp
80101acd:	ff 75 f4             	push   -0xc(%ebp)
80101ad0:	e8 ae e7 ff ff       	call   80100283 <brelse>
80101ad5:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80101adb:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ae9:	66 85 c0             	test   %ax,%ax
80101aec:	75 0d                	jne    80101afb <ilock+0x110>
      panic("ilock: no type");
80101aee:	83 ec 0c             	sub    $0xc,%esp
80101af1:	68 f3 a8 10 80       	push   $0x8010a8f3
80101af6:	e8 ae ea ff ff       	call   801005a9 <panic>
  }
}
80101afb:	90                   	nop
80101afc:	c9                   	leave  
80101afd:	c3                   	ret    

80101afe <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101afe:	55                   	push   %ebp
80101aff:	89 e5                	mov    %esp,%ebp
80101b01:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b04:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b08:	74 20                	je     80101b2a <iunlock+0x2c>
80101b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0d:	83 c0 0c             	add    $0xc,%eax
80101b10:	83 ec 0c             	sub    $0xc,%esp
80101b13:	50                   	push   %eax
80101b14:	e8 7c 2f 00 00       	call   80104a95 <holdingsleep>
80101b19:	83 c4 10             	add    $0x10,%esp
80101b1c:	85 c0                	test   %eax,%eax
80101b1e:	74 0a                	je     80101b2a <iunlock+0x2c>
80101b20:	8b 45 08             	mov    0x8(%ebp),%eax
80101b23:	8b 40 08             	mov    0x8(%eax),%eax
80101b26:	85 c0                	test   %eax,%eax
80101b28:	7f 0d                	jg     80101b37 <iunlock+0x39>
    panic("iunlock");
80101b2a:	83 ec 0c             	sub    $0xc,%esp
80101b2d:	68 02 a9 10 80       	push   $0x8010a902
80101b32:	e8 72 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b37:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3a:	83 c0 0c             	add    $0xc,%eax
80101b3d:	83 ec 0c             	sub    $0xc,%esp
80101b40:	50                   	push   %eax
80101b41:	e8 01 2f 00 00       	call   80104a47 <releasesleep>
80101b46:	83 c4 10             	add    $0x10,%esp
}
80101b49:	90                   	nop
80101b4a:	c9                   	leave  
80101b4b:	c3                   	ret    

80101b4c <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b4c:	55                   	push   %ebp
80101b4d:	89 e5                	mov    %esp,%ebp
80101b4f:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b52:	8b 45 08             	mov    0x8(%ebp),%eax
80101b55:	83 c0 0c             	add    $0xc,%eax
80101b58:	83 ec 0c             	sub    $0xc,%esp
80101b5b:	50                   	push   %eax
80101b5c:	e8 82 2e 00 00       	call   801049e3 <acquiresleep>
80101b61:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b64:	8b 45 08             	mov    0x8(%ebp),%eax
80101b67:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b6a:	85 c0                	test   %eax,%eax
80101b6c:	74 6a                	je     80101bd8 <iput+0x8c>
80101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b71:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b75:	66 85 c0             	test   %ax,%ax
80101b78:	75 5e                	jne    80101bd8 <iput+0x8c>
    acquire(&icache.lock);
80101b7a:	83 ec 0c             	sub    $0xc,%esp
80101b7d:	68 60 24 19 80       	push   $0x80192460
80101b82:	e8 9f 2f 00 00       	call   80104b26 <acquire>
80101b87:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8d:	8b 40 08             	mov    0x8(%eax),%eax
80101b90:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b93:	83 ec 0c             	sub    $0xc,%esp
80101b96:	68 60 24 19 80       	push   $0x80192460
80101b9b:	e8 f4 2f 00 00       	call   80104b94 <release>
80101ba0:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ba3:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ba7:	75 2f                	jne    80101bd8 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ba9:	83 ec 0c             	sub    $0xc,%esp
80101bac:	ff 75 08             	push   0x8(%ebp)
80101baf:	e8 ad 01 00 00       	call   80101d61 <itrunc>
80101bb4:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bba:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bc0:	83 ec 0c             	sub    $0xc,%esp
80101bc3:	ff 75 08             	push   0x8(%ebp)
80101bc6:	e8 43 fc ff ff       	call   8010180e <iupdate>
80101bcb:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bce:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd1:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdb:	83 c0 0c             	add    $0xc,%eax
80101bde:	83 ec 0c             	sub    $0xc,%esp
80101be1:	50                   	push   %eax
80101be2:	e8 60 2e 00 00       	call   80104a47 <releasesleep>
80101be7:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bea:	83 ec 0c             	sub    $0xc,%esp
80101bed:	68 60 24 19 80       	push   $0x80192460
80101bf2:	e8 2f 2f 00 00       	call   80104b26 <acquire>
80101bf7:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfd:	8b 40 08             	mov    0x8(%eax),%eax
80101c00:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c03:	8b 45 08             	mov    0x8(%ebp),%eax
80101c06:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c09:	83 ec 0c             	sub    $0xc,%esp
80101c0c:	68 60 24 19 80       	push   $0x80192460
80101c11:	e8 7e 2f 00 00       	call   80104b94 <release>
80101c16:	83 c4 10             	add    $0x10,%esp
}
80101c19:	90                   	nop
80101c1a:	c9                   	leave  
80101c1b:	c3                   	ret    

80101c1c <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c1c:	55                   	push   %ebp
80101c1d:	89 e5                	mov    %esp,%ebp
80101c1f:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c22:	83 ec 0c             	sub    $0xc,%esp
80101c25:	ff 75 08             	push   0x8(%ebp)
80101c28:	e8 d1 fe ff ff       	call   80101afe <iunlock>
80101c2d:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	ff 75 08             	push   0x8(%ebp)
80101c36:	e8 11 ff ff ff       	call   80101b4c <iput>
80101c3b:	83 c4 10             	add    $0x10,%esp
}
80101c3e:	90                   	nop
80101c3f:	c9                   	leave  
80101c40:	c3                   	ret    

80101c41 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c41:	55                   	push   %ebp
80101c42:	89 e5                	mov    %esp,%ebp
80101c44:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c47:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c4b:	77 42                	ja     80101c8f <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c50:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c53:	83 c2 14             	add    $0x14,%edx
80101c56:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c61:	75 24                	jne    80101c87 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c63:	8b 45 08             	mov    0x8(%ebp),%eax
80101c66:	8b 00                	mov    (%eax),%eax
80101c68:	83 ec 0c             	sub    $0xc,%esp
80101c6b:	50                   	push   %eax
80101c6c:	e8 f4 f7 ff ff       	call   80101465 <balloc>
80101c71:	83 c4 10             	add    $0x10,%esp
80101c74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c77:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c7d:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c83:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c8a:	e9 d0 00 00 00       	jmp    80101d5f <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c8f:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c93:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c97:	0f 87 b5 00 00 00    	ja     80101d52 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca0:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ca6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cad:	75 20                	jne    80101ccf <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101caf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb2:	8b 00                	mov    (%eax),%eax
80101cb4:	83 ec 0c             	sub    $0xc,%esp
80101cb7:	50                   	push   %eax
80101cb8:	e8 a8 f7 ff ff       	call   80101465 <balloc>
80101cbd:	83 c4 10             	add    $0x10,%esp
80101cc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc9:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd2:	8b 00                	mov    (%eax),%eax
80101cd4:	83 ec 08             	sub    $0x8,%esp
80101cd7:	ff 75 f4             	push   -0xc(%ebp)
80101cda:	50                   	push   %eax
80101cdb:	e8 21 e5 ff ff       	call   80100201 <bread>
80101ce0:	83 c4 10             	add    $0x10,%esp
80101ce3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce9:	83 c0 5c             	add    $0x5c,%eax
80101cec:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cef:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cfc:	01 d0                	add    %edx,%eax
80101cfe:	8b 00                	mov    (%eax),%eax
80101d00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d07:	75 36                	jne    80101d3f <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d09:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0c:	8b 00                	mov    (%eax),%eax
80101d0e:	83 ec 0c             	sub    $0xc,%esp
80101d11:	50                   	push   %eax
80101d12:	e8 4e f7 ff ff       	call   80101465 <balloc>
80101d17:	83 c4 10             	add    $0x10,%esp
80101d1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d20:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d2a:	01 c2                	add    %eax,%edx
80101d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2f:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d31:	83 ec 0c             	sub    $0xc,%esp
80101d34:	ff 75 f0             	push   -0x10(%ebp)
80101d37:	e8 3a 15 00 00       	call   80103276 <log_write>
80101d3c:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d3f:	83 ec 0c             	sub    $0xc,%esp
80101d42:	ff 75 f0             	push   -0x10(%ebp)
80101d45:	e8 39 e5 ff ff       	call   80100283 <brelse>
80101d4a:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d50:	eb 0d                	jmp    80101d5f <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d52:	83 ec 0c             	sub    $0xc,%esp
80101d55:	68 0a a9 10 80       	push   $0x8010a90a
80101d5a:	e8 4a e8 ff ff       	call   801005a9 <panic>
}
80101d5f:	c9                   	leave  
80101d60:	c3                   	ret    

80101d61 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d61:	55                   	push   %ebp
80101d62:	89 e5                	mov    %esp,%ebp
80101d64:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d67:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d6e:	eb 45                	jmp    80101db5 <itrunc+0x54>
    if(ip->addrs[i]){
80101d70:	8b 45 08             	mov    0x8(%ebp),%eax
80101d73:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d76:	83 c2 14             	add    $0x14,%edx
80101d79:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d7d:	85 c0                	test   %eax,%eax
80101d7f:	74 30                	je     80101db1 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d81:	8b 45 08             	mov    0x8(%ebp),%eax
80101d84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d87:	83 c2 14             	add    $0x14,%edx
80101d8a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8e:	8b 55 08             	mov    0x8(%ebp),%edx
80101d91:	8b 12                	mov    (%edx),%edx
80101d93:	83 ec 08             	sub    $0x8,%esp
80101d96:	50                   	push   %eax
80101d97:	52                   	push   %edx
80101d98:	e8 0c f8 ff ff       	call   801015a9 <bfree>
80101d9d:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101da0:	8b 45 08             	mov    0x8(%ebp),%eax
80101da3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da6:	83 c2 14             	add    $0x14,%edx
80101da9:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101db0:	00 
  for(i = 0; i < NDIRECT; i++){
80101db1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101db5:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101db9:	7e b5                	jle    80101d70 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbe:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dc4:	85 c0                	test   %eax,%eax
80101dc6:	0f 84 aa 00 00 00    	je     80101e76 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dcc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcf:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd8:	8b 00                	mov    (%eax),%eax
80101dda:	83 ec 08             	sub    $0x8,%esp
80101ddd:	52                   	push   %edx
80101dde:	50                   	push   %eax
80101ddf:	e8 1d e4 ff ff       	call   80100201 <bread>
80101de4:	83 c4 10             	add    $0x10,%esp
80101de7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101dea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ded:	83 c0 5c             	add    $0x5c,%eax
80101df0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101df3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101dfa:	eb 3c                	jmp    80101e38 <itrunc+0xd7>
      if(a[j])
80101dfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e06:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e09:	01 d0                	add    %edx,%eax
80101e0b:	8b 00                	mov    (%eax),%eax
80101e0d:	85 c0                	test   %eax,%eax
80101e0f:	74 23                	je     80101e34 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e14:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e1e:	01 d0                	add    %edx,%eax
80101e20:	8b 00                	mov    (%eax),%eax
80101e22:	8b 55 08             	mov    0x8(%ebp),%edx
80101e25:	8b 12                	mov    (%edx),%edx
80101e27:	83 ec 08             	sub    $0x8,%esp
80101e2a:	50                   	push   %eax
80101e2b:	52                   	push   %edx
80101e2c:	e8 78 f7 ff ff       	call   801015a9 <bfree>
80101e31:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e34:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e3b:	83 f8 7f             	cmp    $0x7f,%eax
80101e3e:	76 bc                	jbe    80101dfc <itrunc+0x9b>
    }
    brelse(bp);
80101e40:	83 ec 0c             	sub    $0xc,%esp
80101e43:	ff 75 ec             	push   -0x14(%ebp)
80101e46:	e8 38 e4 ff ff       	call   80100283 <brelse>
80101e4b:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e51:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e57:	8b 55 08             	mov    0x8(%ebp),%edx
80101e5a:	8b 12                	mov    (%edx),%edx
80101e5c:	83 ec 08             	sub    $0x8,%esp
80101e5f:	50                   	push   %eax
80101e60:	52                   	push   %edx
80101e61:	e8 43 f7 ff ff       	call   801015a9 <bfree>
80101e66:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e69:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6c:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e73:	00 00 00 
  }

  ip->size = 0;
80101e76:	8b 45 08             	mov    0x8(%ebp),%eax
80101e79:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e80:	83 ec 0c             	sub    $0xc,%esp
80101e83:	ff 75 08             	push   0x8(%ebp)
80101e86:	e8 83 f9 ff ff       	call   8010180e <iupdate>
80101e8b:	83 c4 10             	add    $0x10,%esp
}
80101e8e:	90                   	nop
80101e8f:	c9                   	leave  
80101e90:	c3                   	ret    

80101e91 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e91:	55                   	push   %ebp
80101e92:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e94:	8b 45 08             	mov    0x8(%ebp),%eax
80101e97:	8b 00                	mov    (%eax),%eax
80101e99:	89 c2                	mov    %eax,%edx
80101e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9e:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea4:	8b 50 04             	mov    0x4(%eax),%edx
80101ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eaa:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ead:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb0:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb7:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eba:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebd:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec4:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecb:	8b 50 58             	mov    0x58(%eax),%edx
80101ece:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed1:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed4:	90                   	nop
80101ed5:	5d                   	pop    %ebp
80101ed6:	c3                   	ret    

80101ed7 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed7:	55                   	push   %ebp
80101ed8:	89 e5                	mov    %esp,%ebp
80101eda:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ee4:	66 83 f8 03          	cmp    $0x3,%ax
80101ee8:	75 5c                	jne    80101f46 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101eea:	8b 45 08             	mov    0x8(%ebp),%eax
80101eed:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef1:	66 85 c0             	test   %ax,%ax
80101ef4:	78 20                	js     80101f16 <readi+0x3f>
80101ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efd:	66 83 f8 09          	cmp    $0x9,%ax
80101f01:	7f 13                	jg     80101f16 <readi+0x3f>
80101f03:	8b 45 08             	mov    0x8(%ebp),%eax
80101f06:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f0a:	98                   	cwtl   
80101f0b:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f12:	85 c0                	test   %eax,%eax
80101f14:	75 0a                	jne    80101f20 <readi+0x49>
      return -1;
80101f16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1b:	e9 0a 01 00 00       	jmp    8010202a <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f20:	8b 45 08             	mov    0x8(%ebp),%eax
80101f23:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f27:	98                   	cwtl   
80101f28:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f2f:	8b 55 14             	mov    0x14(%ebp),%edx
80101f32:	83 ec 04             	sub    $0x4,%esp
80101f35:	52                   	push   %edx
80101f36:	ff 75 0c             	push   0xc(%ebp)
80101f39:	ff 75 08             	push   0x8(%ebp)
80101f3c:	ff d0                	call   *%eax
80101f3e:	83 c4 10             	add    $0x10,%esp
80101f41:	e9 e4 00 00 00       	jmp    8010202a <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f46:	8b 45 08             	mov    0x8(%ebp),%eax
80101f49:	8b 40 58             	mov    0x58(%eax),%eax
80101f4c:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f4f:	77 0d                	ja     80101f5e <readi+0x87>
80101f51:	8b 55 10             	mov    0x10(%ebp),%edx
80101f54:	8b 45 14             	mov    0x14(%ebp),%eax
80101f57:	01 d0                	add    %edx,%eax
80101f59:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f5c:	76 0a                	jbe    80101f68 <readi+0x91>
    return -1;
80101f5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f63:	e9 c2 00 00 00       	jmp    8010202a <readi+0x153>
  if(off + n > ip->size)
80101f68:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6e:	01 c2                	add    %eax,%edx
80101f70:	8b 45 08             	mov    0x8(%ebp),%eax
80101f73:	8b 40 58             	mov    0x58(%eax),%eax
80101f76:	39 c2                	cmp    %eax,%edx
80101f78:	76 0c                	jbe    80101f86 <readi+0xaf>
    n = ip->size - off;
80101f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7d:	8b 40 58             	mov    0x58(%eax),%eax
80101f80:	2b 45 10             	sub    0x10(%ebp),%eax
80101f83:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8d:	e9 89 00 00 00       	jmp    8010201b <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f92:	8b 45 10             	mov    0x10(%ebp),%eax
80101f95:	c1 e8 09             	shr    $0x9,%eax
80101f98:	83 ec 08             	sub    $0x8,%esp
80101f9b:	50                   	push   %eax
80101f9c:	ff 75 08             	push   0x8(%ebp)
80101f9f:	e8 9d fc ff ff       	call   80101c41 <bmap>
80101fa4:	83 c4 10             	add    $0x10,%esp
80101fa7:	8b 55 08             	mov    0x8(%ebp),%edx
80101faa:	8b 12                	mov    (%edx),%edx
80101fac:	83 ec 08             	sub    $0x8,%esp
80101faf:	50                   	push   %eax
80101fb0:	52                   	push   %edx
80101fb1:	e8 4b e2 ff ff       	call   80100201 <bread>
80101fb6:	83 c4 10             	add    $0x10,%esp
80101fb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbc:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbf:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc4:	ba 00 02 00 00       	mov    $0x200,%edx
80101fc9:	29 c2                	sub    %eax,%edx
80101fcb:	8b 45 14             	mov    0x14(%ebp),%eax
80101fce:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd1:	39 c2                	cmp    %eax,%edx
80101fd3:	0f 46 c2             	cmovbe %edx,%eax
80101fd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdc:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fdf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe7:	01 d0                	add    %edx,%eax
80101fe9:	83 ec 04             	sub    $0x4,%esp
80101fec:	ff 75 ec             	push   -0x14(%ebp)
80101fef:	50                   	push   %eax
80101ff0:	ff 75 0c             	push   0xc(%ebp)
80101ff3:	e8 63 2e 00 00       	call   80104e5b <memmove>
80101ff8:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffb:	83 ec 0c             	sub    $0xc,%esp
80101ffe:	ff 75 f0             	push   -0x10(%ebp)
80102001:	e8 7d e2 ff ff       	call   80100283 <brelse>
80102006:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102009:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200c:	01 45 f4             	add    %eax,-0xc(%ebp)
8010200f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102012:	01 45 10             	add    %eax,0x10(%ebp)
80102015:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102018:	01 45 0c             	add    %eax,0xc(%ebp)
8010201b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201e:	3b 45 14             	cmp    0x14(%ebp),%eax
80102021:	0f 82 6b ff ff ff    	jb     80101f92 <readi+0xbb>
  }
  return n;
80102027:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010202a:	c9                   	leave  
8010202b:	c3                   	ret    

8010202c <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202c:	55                   	push   %ebp
8010202d:	89 e5                	mov    %esp,%ebp
8010202f:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102032:	8b 45 08             	mov    0x8(%ebp),%eax
80102035:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102039:	66 83 f8 03          	cmp    $0x3,%ax
8010203d:	75 5c                	jne    8010209b <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010203f:	8b 45 08             	mov    0x8(%ebp),%eax
80102042:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102046:	66 85 c0             	test   %ax,%ax
80102049:	78 20                	js     8010206b <writei+0x3f>
8010204b:	8b 45 08             	mov    0x8(%ebp),%eax
8010204e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102052:	66 83 f8 09          	cmp    $0x9,%ax
80102056:	7f 13                	jg     8010206b <writei+0x3f>
80102058:	8b 45 08             	mov    0x8(%ebp),%eax
8010205b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205f:	98                   	cwtl   
80102060:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102067:	85 c0                	test   %eax,%eax
80102069:	75 0a                	jne    80102075 <writei+0x49>
      return -1;
8010206b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102070:	e9 3b 01 00 00       	jmp    801021b0 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102075:	8b 45 08             	mov    0x8(%ebp),%eax
80102078:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207c:	98                   	cwtl   
8010207d:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102084:	8b 55 14             	mov    0x14(%ebp),%edx
80102087:	83 ec 04             	sub    $0x4,%esp
8010208a:	52                   	push   %edx
8010208b:	ff 75 0c             	push   0xc(%ebp)
8010208e:	ff 75 08             	push   0x8(%ebp)
80102091:	ff d0                	call   *%eax
80102093:	83 c4 10             	add    $0x10,%esp
80102096:	e9 15 01 00 00       	jmp    801021b0 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
8010209b:	8b 45 08             	mov    0x8(%ebp),%eax
8010209e:	8b 40 58             	mov    0x58(%eax),%eax
801020a1:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a4:	77 0d                	ja     801020b3 <writei+0x87>
801020a6:	8b 55 10             	mov    0x10(%ebp),%edx
801020a9:	8b 45 14             	mov    0x14(%ebp),%eax
801020ac:	01 d0                	add    %edx,%eax
801020ae:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b1:	76 0a                	jbe    801020bd <writei+0x91>
    return -1;
801020b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b8:	e9 f3 00 00 00       	jmp    801021b0 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020bd:	8b 55 10             	mov    0x10(%ebp),%edx
801020c0:	8b 45 14             	mov    0x14(%ebp),%eax
801020c3:	01 d0                	add    %edx,%eax
801020c5:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020ca:	76 0a                	jbe    801020d6 <writei+0xaa>
    return -1;
801020cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d1:	e9 da 00 00 00       	jmp    801021b0 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dd:	e9 97 00 00 00       	jmp    80102179 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e2:	8b 45 10             	mov    0x10(%ebp),%eax
801020e5:	c1 e8 09             	shr    $0x9,%eax
801020e8:	83 ec 08             	sub    $0x8,%esp
801020eb:	50                   	push   %eax
801020ec:	ff 75 08             	push   0x8(%ebp)
801020ef:	e8 4d fb ff ff       	call   80101c41 <bmap>
801020f4:	83 c4 10             	add    $0x10,%esp
801020f7:	8b 55 08             	mov    0x8(%ebp),%edx
801020fa:	8b 12                	mov    (%edx),%edx
801020fc:	83 ec 08             	sub    $0x8,%esp
801020ff:	50                   	push   %eax
80102100:	52                   	push   %edx
80102101:	e8 fb e0 ff ff       	call   80100201 <bread>
80102106:	83 c4 10             	add    $0x10,%esp
80102109:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210c:	8b 45 10             	mov    0x10(%ebp),%eax
8010210f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102114:	ba 00 02 00 00       	mov    $0x200,%edx
80102119:	29 c2                	sub    %eax,%edx
8010211b:	8b 45 14             	mov    0x14(%ebp),%eax
8010211e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102121:	39 c2                	cmp    %eax,%edx
80102123:	0f 46 c2             	cmovbe %edx,%eax
80102126:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102129:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010212c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010212f:	8b 45 10             	mov    0x10(%ebp),%eax
80102132:	25 ff 01 00 00       	and    $0x1ff,%eax
80102137:	01 d0                	add    %edx,%eax
80102139:	83 ec 04             	sub    $0x4,%esp
8010213c:	ff 75 ec             	push   -0x14(%ebp)
8010213f:	ff 75 0c             	push   0xc(%ebp)
80102142:	50                   	push   %eax
80102143:	e8 13 2d 00 00       	call   80104e5b <memmove>
80102148:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214b:	83 ec 0c             	sub    $0xc,%esp
8010214e:	ff 75 f0             	push   -0x10(%ebp)
80102151:	e8 20 11 00 00       	call   80103276 <log_write>
80102156:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102159:	83 ec 0c             	sub    $0xc,%esp
8010215c:	ff 75 f0             	push   -0x10(%ebp)
8010215f:	e8 1f e1 ff ff       	call   80100283 <brelse>
80102164:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102167:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010216d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102170:	01 45 10             	add    %eax,0x10(%ebp)
80102173:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102176:	01 45 0c             	add    %eax,0xc(%ebp)
80102179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010217f:	0f 82 5d ff ff ff    	jb     801020e2 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102185:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102189:	74 22                	je     801021ad <writei+0x181>
8010218b:	8b 45 08             	mov    0x8(%ebp),%eax
8010218e:	8b 40 58             	mov    0x58(%eax),%eax
80102191:	39 45 10             	cmp    %eax,0x10(%ebp)
80102194:	76 17                	jbe    801021ad <writei+0x181>
    ip->size = off;
80102196:	8b 45 08             	mov    0x8(%ebp),%eax
80102199:	8b 55 10             	mov    0x10(%ebp),%edx
8010219c:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010219f:	83 ec 0c             	sub    $0xc,%esp
801021a2:	ff 75 08             	push   0x8(%ebp)
801021a5:	e8 64 f6 ff ff       	call   8010180e <iupdate>
801021aa:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021ad:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b0:	c9                   	leave  
801021b1:	c3                   	ret    

801021b2 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b2:	55                   	push   %ebp
801021b3:	89 e5                	mov    %esp,%ebp
801021b5:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021b8:	83 ec 04             	sub    $0x4,%esp
801021bb:	6a 0e                	push   $0xe
801021bd:	ff 75 0c             	push   0xc(%ebp)
801021c0:	ff 75 08             	push   0x8(%ebp)
801021c3:	e8 29 2d 00 00       	call   80104ef1 <strncmp>
801021c8:	83 c4 10             	add    $0x10,%esp
}
801021cb:	c9                   	leave  
801021cc:	c3                   	ret    

801021cd <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021cd:	55                   	push   %ebp
801021ce:	89 e5                	mov    %esp,%ebp
801021d0:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d3:	8b 45 08             	mov    0x8(%ebp),%eax
801021d6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021da:	66 83 f8 01          	cmp    $0x1,%ax
801021de:	74 0d                	je     801021ed <dirlookup+0x20>
    panic("dirlookup not DIR");
801021e0:	83 ec 0c             	sub    $0xc,%esp
801021e3:	68 1d a9 10 80       	push   $0x8010a91d
801021e8:	e8 bc e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f4:	eb 7b                	jmp    80102271 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f6:	6a 10                	push   $0x10
801021f8:	ff 75 f4             	push   -0xc(%ebp)
801021fb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021fe:	50                   	push   %eax
801021ff:	ff 75 08             	push   0x8(%ebp)
80102202:	e8 d0 fc ff ff       	call   80101ed7 <readi>
80102207:	83 c4 10             	add    $0x10,%esp
8010220a:	83 f8 10             	cmp    $0x10,%eax
8010220d:	74 0d                	je     8010221c <dirlookup+0x4f>
      panic("dirlookup read");
8010220f:	83 ec 0c             	sub    $0xc,%esp
80102212:	68 2f a9 10 80       	push   $0x8010a92f
80102217:	e8 8d e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
8010221c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102220:	66 85 c0             	test   %ax,%ax
80102223:	74 47                	je     8010226c <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102225:	83 ec 08             	sub    $0x8,%esp
80102228:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222b:	83 c0 02             	add    $0x2,%eax
8010222e:	50                   	push   %eax
8010222f:	ff 75 0c             	push   0xc(%ebp)
80102232:	e8 7b ff ff ff       	call   801021b2 <namecmp>
80102237:	83 c4 10             	add    $0x10,%esp
8010223a:	85 c0                	test   %eax,%eax
8010223c:	75 2f                	jne    8010226d <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010223e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102242:	74 08                	je     8010224c <dirlookup+0x7f>
        *poff = off;
80102244:	8b 45 10             	mov    0x10(%ebp),%eax
80102247:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010224a:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010224c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102250:	0f b7 c0             	movzwl %ax,%eax
80102253:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102256:	8b 45 08             	mov    0x8(%ebp),%eax
80102259:	8b 00                	mov    (%eax),%eax
8010225b:	83 ec 08             	sub    $0x8,%esp
8010225e:	ff 75 f0             	push   -0x10(%ebp)
80102261:	50                   	push   %eax
80102262:	e8 68 f6 ff ff       	call   801018cf <iget>
80102267:	83 c4 10             	add    $0x10,%esp
8010226a:	eb 19                	jmp    80102285 <dirlookup+0xb8>
      continue;
8010226c:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102271:	8b 45 08             	mov    0x8(%ebp),%eax
80102274:	8b 40 58             	mov    0x58(%eax),%eax
80102277:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010227a:	0f 82 76 ff ff ff    	jb     801021f6 <dirlookup+0x29>
    }
  }

  return 0;
80102280:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102285:	c9                   	leave  
80102286:	c3                   	ret    

80102287 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102287:	55                   	push   %ebp
80102288:	89 e5                	mov    %esp,%ebp
8010228a:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010228d:	83 ec 04             	sub    $0x4,%esp
80102290:	6a 00                	push   $0x0
80102292:	ff 75 0c             	push   0xc(%ebp)
80102295:	ff 75 08             	push   0x8(%ebp)
80102298:	e8 30 ff ff ff       	call   801021cd <dirlookup>
8010229d:	83 c4 10             	add    $0x10,%esp
801022a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022a7:	74 18                	je     801022c1 <dirlink+0x3a>
    iput(ip);
801022a9:	83 ec 0c             	sub    $0xc,%esp
801022ac:	ff 75 f0             	push   -0x10(%ebp)
801022af:	e8 98 f8 ff ff       	call   80101b4c <iput>
801022b4:	83 c4 10             	add    $0x10,%esp
    return -1;
801022b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022bc:	e9 9c 00 00 00       	jmp    8010235d <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c8:	eb 39                	jmp    80102303 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cd:	6a 10                	push   $0x10
801022cf:	50                   	push   %eax
801022d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d3:	50                   	push   %eax
801022d4:	ff 75 08             	push   0x8(%ebp)
801022d7:	e8 fb fb ff ff       	call   80101ed7 <readi>
801022dc:	83 c4 10             	add    $0x10,%esp
801022df:	83 f8 10             	cmp    $0x10,%eax
801022e2:	74 0d                	je     801022f1 <dirlink+0x6a>
      panic("dirlink read");
801022e4:	83 ec 0c             	sub    $0xc,%esp
801022e7:	68 3e a9 10 80       	push   $0x8010a93e
801022ec:	e8 b8 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f1:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f5:	66 85 c0             	test   %ax,%ax
801022f8:	74 18                	je     80102312 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fd:	83 c0 10             	add    $0x10,%eax
80102300:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102303:	8b 45 08             	mov    0x8(%ebp),%eax
80102306:	8b 50 58             	mov    0x58(%eax),%edx
80102309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230c:	39 c2                	cmp    %eax,%edx
8010230e:	77 ba                	ja     801022ca <dirlink+0x43>
80102310:	eb 01                	jmp    80102313 <dirlink+0x8c>
      break;
80102312:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102313:	83 ec 04             	sub    $0x4,%esp
80102316:	6a 0e                	push   $0xe
80102318:	ff 75 0c             	push   0xc(%ebp)
8010231b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010231e:	83 c0 02             	add    $0x2,%eax
80102321:	50                   	push   %eax
80102322:	e8 20 2c 00 00       	call   80104f47 <strncpy>
80102327:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010232a:	8b 45 10             	mov    0x10(%ebp),%eax
8010232d:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102334:	6a 10                	push   $0x10
80102336:	50                   	push   %eax
80102337:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010233a:	50                   	push   %eax
8010233b:	ff 75 08             	push   0x8(%ebp)
8010233e:	e8 e9 fc ff ff       	call   8010202c <writei>
80102343:	83 c4 10             	add    $0x10,%esp
80102346:	83 f8 10             	cmp    $0x10,%eax
80102349:	74 0d                	je     80102358 <dirlink+0xd1>
    panic("dirlink");
8010234b:	83 ec 0c             	sub    $0xc,%esp
8010234e:	68 4b a9 10 80       	push   $0x8010a94b
80102353:	e8 51 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102358:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010235d:	c9                   	leave  
8010235e:	c3                   	ret    

8010235f <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010235f:	55                   	push   %ebp
80102360:	89 e5                	mov    %esp,%ebp
80102362:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102365:	eb 04                	jmp    8010236b <skipelem+0xc>
    path++;
80102367:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010236b:	8b 45 08             	mov    0x8(%ebp),%eax
8010236e:	0f b6 00             	movzbl (%eax),%eax
80102371:	3c 2f                	cmp    $0x2f,%al
80102373:	74 f2                	je     80102367 <skipelem+0x8>
  if(*path == 0)
80102375:	8b 45 08             	mov    0x8(%ebp),%eax
80102378:	0f b6 00             	movzbl (%eax),%eax
8010237b:	84 c0                	test   %al,%al
8010237d:	75 07                	jne    80102386 <skipelem+0x27>
    return 0;
8010237f:	b8 00 00 00 00       	mov    $0x0,%eax
80102384:	eb 77                	jmp    801023fd <skipelem+0x9e>
  s = path;
80102386:	8b 45 08             	mov    0x8(%ebp),%eax
80102389:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010238c:	eb 04                	jmp    80102392 <skipelem+0x33>
    path++;
8010238e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102392:	8b 45 08             	mov    0x8(%ebp),%eax
80102395:	0f b6 00             	movzbl (%eax),%eax
80102398:	3c 2f                	cmp    $0x2f,%al
8010239a:	74 0a                	je     801023a6 <skipelem+0x47>
8010239c:	8b 45 08             	mov    0x8(%ebp),%eax
8010239f:	0f b6 00             	movzbl (%eax),%eax
801023a2:	84 c0                	test   %al,%al
801023a4:	75 e8                	jne    8010238e <skipelem+0x2f>
  len = path - s;
801023a6:	8b 45 08             	mov    0x8(%ebp),%eax
801023a9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023af:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023b3:	7e 15                	jle    801023ca <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023b5:	83 ec 04             	sub    $0x4,%esp
801023b8:	6a 0e                	push   $0xe
801023ba:	ff 75 f4             	push   -0xc(%ebp)
801023bd:	ff 75 0c             	push   0xc(%ebp)
801023c0:	e8 96 2a 00 00       	call   80104e5b <memmove>
801023c5:	83 c4 10             	add    $0x10,%esp
801023c8:	eb 26                	jmp    801023f0 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cd:	83 ec 04             	sub    $0x4,%esp
801023d0:	50                   	push   %eax
801023d1:	ff 75 f4             	push   -0xc(%ebp)
801023d4:	ff 75 0c             	push   0xc(%ebp)
801023d7:	e8 7f 2a 00 00       	call   80104e5b <memmove>
801023dc:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023df:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e5:	01 d0                	add    %edx,%eax
801023e7:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023ea:	eb 04                	jmp    801023f0 <skipelem+0x91>
    path++;
801023ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023f0:	8b 45 08             	mov    0x8(%ebp),%eax
801023f3:	0f b6 00             	movzbl (%eax),%eax
801023f6:	3c 2f                	cmp    $0x2f,%al
801023f8:	74 f2                	je     801023ec <skipelem+0x8d>
  return path;
801023fa:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023fd:	c9                   	leave  
801023fe:	c3                   	ret    

801023ff <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023ff:	55                   	push   %ebp
80102400:	89 e5                	mov    %esp,%ebp
80102402:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102405:	8b 45 08             	mov    0x8(%ebp),%eax
80102408:	0f b6 00             	movzbl (%eax),%eax
8010240b:	3c 2f                	cmp    $0x2f,%al
8010240d:	75 17                	jne    80102426 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010240f:	83 ec 08             	sub    $0x8,%esp
80102412:	6a 01                	push   $0x1
80102414:	6a 01                	push   $0x1
80102416:	e8 b4 f4 ff ff       	call   801018cf <iget>
8010241b:	83 c4 10             	add    $0x10,%esp
8010241e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102421:	e9 ba 00 00 00       	jmp    801024e0 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102426:	e8 06 16 00 00       	call   80103a31 <myproc>
8010242b:	8b 40 68             	mov    0x68(%eax),%eax
8010242e:	83 ec 0c             	sub    $0xc,%esp
80102431:	50                   	push   %eax
80102432:	e8 7a f5 ff ff       	call   801019b1 <idup>
80102437:	83 c4 10             	add    $0x10,%esp
8010243a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010243d:	e9 9e 00 00 00       	jmp    801024e0 <namex+0xe1>
    ilock(ip);
80102442:	83 ec 0c             	sub    $0xc,%esp
80102445:	ff 75 f4             	push   -0xc(%ebp)
80102448:	e8 9e f5 ff ff       	call   801019eb <ilock>
8010244d:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102453:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102457:	66 83 f8 01          	cmp    $0x1,%ax
8010245b:	74 18                	je     80102475 <namex+0x76>
      iunlockput(ip);
8010245d:	83 ec 0c             	sub    $0xc,%esp
80102460:	ff 75 f4             	push   -0xc(%ebp)
80102463:	e8 b4 f7 ff ff       	call   80101c1c <iunlockput>
80102468:	83 c4 10             	add    $0x10,%esp
      return 0;
8010246b:	b8 00 00 00 00       	mov    $0x0,%eax
80102470:	e9 a7 00 00 00       	jmp    8010251c <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102475:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102479:	74 20                	je     8010249b <namex+0x9c>
8010247b:	8b 45 08             	mov    0x8(%ebp),%eax
8010247e:	0f b6 00             	movzbl (%eax),%eax
80102481:	84 c0                	test   %al,%al
80102483:	75 16                	jne    8010249b <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102485:	83 ec 0c             	sub    $0xc,%esp
80102488:	ff 75 f4             	push   -0xc(%ebp)
8010248b:	e8 6e f6 ff ff       	call   80101afe <iunlock>
80102490:	83 c4 10             	add    $0x10,%esp
      return ip;
80102493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102496:	e9 81 00 00 00       	jmp    8010251c <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010249b:	83 ec 04             	sub    $0x4,%esp
8010249e:	6a 00                	push   $0x0
801024a0:	ff 75 10             	push   0x10(%ebp)
801024a3:	ff 75 f4             	push   -0xc(%ebp)
801024a6:	e8 22 fd ff ff       	call   801021cd <dirlookup>
801024ab:	83 c4 10             	add    $0x10,%esp
801024ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024b5:	75 15                	jne    801024cc <namex+0xcd>
      iunlockput(ip);
801024b7:	83 ec 0c             	sub    $0xc,%esp
801024ba:	ff 75 f4             	push   -0xc(%ebp)
801024bd:	e8 5a f7 ff ff       	call   80101c1c <iunlockput>
801024c2:	83 c4 10             	add    $0x10,%esp
      return 0;
801024c5:	b8 00 00 00 00       	mov    $0x0,%eax
801024ca:	eb 50                	jmp    8010251c <namex+0x11d>
    }
    iunlockput(ip);
801024cc:	83 ec 0c             	sub    $0xc,%esp
801024cf:	ff 75 f4             	push   -0xc(%ebp)
801024d2:	e8 45 f7 ff ff       	call   80101c1c <iunlockput>
801024d7:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024e0:	83 ec 08             	sub    $0x8,%esp
801024e3:	ff 75 10             	push   0x10(%ebp)
801024e6:	ff 75 08             	push   0x8(%ebp)
801024e9:	e8 71 fe ff ff       	call   8010235f <skipelem>
801024ee:	83 c4 10             	add    $0x10,%esp
801024f1:	89 45 08             	mov    %eax,0x8(%ebp)
801024f4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f8:	0f 85 44 ff ff ff    	jne    80102442 <namex+0x43>
  }
  if(nameiparent){
801024fe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102502:	74 15                	je     80102519 <namex+0x11a>
    iput(ip);
80102504:	83 ec 0c             	sub    $0xc,%esp
80102507:	ff 75 f4             	push   -0xc(%ebp)
8010250a:	e8 3d f6 ff ff       	call   80101b4c <iput>
8010250f:	83 c4 10             	add    $0x10,%esp
    return 0;
80102512:	b8 00 00 00 00       	mov    $0x0,%eax
80102517:	eb 03                	jmp    8010251c <namex+0x11d>
  }
  return ip;
80102519:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010251c:	c9                   	leave  
8010251d:	c3                   	ret    

8010251e <namei>:

struct inode*
namei(char *path)
{
8010251e:	55                   	push   %ebp
8010251f:	89 e5                	mov    %esp,%ebp
80102521:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102524:	83 ec 04             	sub    $0x4,%esp
80102527:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010252a:	50                   	push   %eax
8010252b:	6a 00                	push   $0x0
8010252d:	ff 75 08             	push   0x8(%ebp)
80102530:	e8 ca fe ff ff       	call   801023ff <namex>
80102535:	83 c4 10             	add    $0x10,%esp
}
80102538:	c9                   	leave  
80102539:	c3                   	ret    

8010253a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010253a:	55                   	push   %ebp
8010253b:	89 e5                	mov    %esp,%ebp
8010253d:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102540:	83 ec 04             	sub    $0x4,%esp
80102543:	ff 75 0c             	push   0xc(%ebp)
80102546:	6a 01                	push   $0x1
80102548:	ff 75 08             	push   0x8(%ebp)
8010254b:	e8 af fe ff ff       	call   801023ff <namex>
80102550:	83 c4 10             	add    $0x10,%esp
}
80102553:	c9                   	leave  
80102554:	c3                   	ret    

80102555 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102555:	55                   	push   %ebp
80102556:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102558:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010255d:	8b 55 08             	mov    0x8(%ebp),%edx
80102560:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102562:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102567:	8b 40 10             	mov    0x10(%eax),%eax
}
8010256a:	5d                   	pop    %ebp
8010256b:	c3                   	ret    

8010256c <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010256c:	55                   	push   %ebp
8010256d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010256f:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102574:	8b 55 08             	mov    0x8(%ebp),%edx
80102577:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102579:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102581:	89 50 10             	mov    %edx,0x10(%eax)
}
80102584:	90                   	nop
80102585:	5d                   	pop    %ebp
80102586:	c3                   	ret    

80102587 <ioapicinit>:

void
ioapicinit(void)
{
80102587:	55                   	push   %ebp
80102588:	89 e5                	mov    %esp,%ebp
8010258a:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010258d:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
80102594:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102597:	6a 01                	push   $0x1
80102599:	e8 b7 ff ff ff       	call   80102555 <ioapicread>
8010259e:	83 c4 04             	add    $0x4,%esp
801025a1:	c1 e8 10             	shr    $0x10,%eax
801025a4:	25 ff 00 00 00       	and    $0xff,%eax
801025a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025ac:	6a 00                	push   $0x0
801025ae:	e8 a2 ff ff ff       	call   80102555 <ioapicread>
801025b3:	83 c4 04             	add    $0x4,%esp
801025b6:	c1 e8 18             	shr    $0x18,%eax
801025b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025bc:	0f b6 05 54 77 19 80 	movzbl 0x80197754,%eax
801025c3:	0f b6 c0             	movzbl %al,%eax
801025c6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025c9:	74 10                	je     801025db <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025cb:	83 ec 0c             	sub    $0xc,%esp
801025ce:	68 54 a9 10 80       	push   $0x8010a954
801025d3:	e8 1c de ff ff       	call   801003f4 <cprintf>
801025d8:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e2:	eb 3f                	jmp    80102623 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e7:	83 c0 20             	add    $0x20,%eax
801025ea:	0d 00 00 01 00       	or     $0x10000,%eax
801025ef:	89 c2                	mov    %eax,%edx
801025f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f4:	83 c0 08             	add    $0x8,%eax
801025f7:	01 c0                	add    %eax,%eax
801025f9:	83 ec 08             	sub    $0x8,%esp
801025fc:	52                   	push   %edx
801025fd:	50                   	push   %eax
801025fe:	e8 69 ff ff ff       	call   8010256c <ioapicwrite>
80102603:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102609:	83 c0 08             	add    $0x8,%eax
8010260c:	01 c0                	add    %eax,%eax
8010260e:	83 c0 01             	add    $0x1,%eax
80102611:	83 ec 08             	sub    $0x8,%esp
80102614:	6a 00                	push   $0x0
80102616:	50                   	push   %eax
80102617:	e8 50 ff ff ff       	call   8010256c <ioapicwrite>
8010261c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010261f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102626:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102629:	7e b9                	jle    801025e4 <ioapicinit+0x5d>
  }
}
8010262b:	90                   	nop
8010262c:	90                   	nop
8010262d:	c9                   	leave  
8010262e:	c3                   	ret    

8010262f <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010262f:	55                   	push   %ebp
80102630:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102632:	8b 45 08             	mov    0x8(%ebp),%eax
80102635:	83 c0 20             	add    $0x20,%eax
80102638:	89 c2                	mov    %eax,%edx
8010263a:	8b 45 08             	mov    0x8(%ebp),%eax
8010263d:	83 c0 08             	add    $0x8,%eax
80102640:	01 c0                	add    %eax,%eax
80102642:	52                   	push   %edx
80102643:	50                   	push   %eax
80102644:	e8 23 ff ff ff       	call   8010256c <ioapicwrite>
80102649:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010264c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010264f:	c1 e0 18             	shl    $0x18,%eax
80102652:	89 c2                	mov    %eax,%edx
80102654:	8b 45 08             	mov    0x8(%ebp),%eax
80102657:	83 c0 08             	add    $0x8,%eax
8010265a:	01 c0                	add    %eax,%eax
8010265c:	83 c0 01             	add    $0x1,%eax
8010265f:	52                   	push   %edx
80102660:	50                   	push   %eax
80102661:	e8 06 ff ff ff       	call   8010256c <ioapicwrite>
80102666:	83 c4 08             	add    $0x8,%esp
}
80102669:	90                   	nop
8010266a:	c9                   	leave  
8010266b:	c3                   	ret    

8010266c <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010266c:	55                   	push   %ebp
8010266d:	89 e5                	mov    %esp,%ebp
8010266f:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102672:	83 ec 08             	sub    $0x8,%esp
80102675:	68 86 a9 10 80       	push   $0x8010a986
8010267a:	68 c0 40 19 80       	push   $0x801940c0
8010267f:	e8 80 24 00 00       	call   80104b04 <initlock>
80102684:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102687:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
8010268e:	00 00 00 
  freerange(vstart, vend);
80102691:	83 ec 08             	sub    $0x8,%esp
80102694:	ff 75 0c             	push   0xc(%ebp)
80102697:	ff 75 08             	push   0x8(%ebp)
8010269a:	e8 2a 00 00 00       	call   801026c9 <freerange>
8010269f:	83 c4 10             	add    $0x10,%esp
}
801026a2:	90                   	nop
801026a3:	c9                   	leave  
801026a4:	c3                   	ret    

801026a5 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026a5:	55                   	push   %ebp
801026a6:	89 e5                	mov    %esp,%ebp
801026a8:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026ab:	83 ec 08             	sub    $0x8,%esp
801026ae:	ff 75 0c             	push   0xc(%ebp)
801026b1:	ff 75 08             	push   0x8(%ebp)
801026b4:	e8 10 00 00 00       	call   801026c9 <freerange>
801026b9:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026bc:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026c3:	00 00 00 
}
801026c6:	90                   	nop
801026c7:	c9                   	leave  
801026c8:	c3                   	ret    

801026c9 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026c9:	55                   	push   %ebp
801026ca:	89 e5                	mov    %esp,%ebp
801026cc:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026cf:	8b 45 08             	mov    0x8(%ebp),%eax
801026d2:	05 ff 0f 00 00       	add    $0xfff,%eax
801026d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026df:	eb 15                	jmp    801026f6 <freerange+0x2d>
    kfree(p);
801026e1:	83 ec 0c             	sub    $0xc,%esp
801026e4:	ff 75 f4             	push   -0xc(%ebp)
801026e7:	e8 1b 00 00 00       	call   80102707 <kfree>
801026ec:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026ef:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f9:	05 00 10 00 00       	add    $0x1000,%eax
801026fe:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102701:	73 de                	jae    801026e1 <freerange+0x18>
}
80102703:	90                   	nop
80102704:	90                   	nop
80102705:	c9                   	leave  
80102706:	c3                   	ret    

80102707 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102707:	55                   	push   %ebp
80102708:	89 e5                	mov    %esp,%ebp
8010270a:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010270d:	8b 45 08             	mov    0x8(%ebp),%eax
80102710:	25 ff 0f 00 00       	and    $0xfff,%eax
80102715:	85 c0                	test   %eax,%eax
80102717:	75 18                	jne    80102731 <kfree+0x2a>
80102719:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
80102720:	72 0f                	jb     80102731 <kfree+0x2a>
80102722:	8b 45 08             	mov    0x8(%ebp),%eax
80102725:	05 00 00 00 80       	add    $0x80000000,%eax
8010272a:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010272f:	76 0d                	jbe    8010273e <kfree+0x37>
    panic("kfree");
80102731:	83 ec 0c             	sub    $0xc,%esp
80102734:	68 8b a9 10 80       	push   $0x8010a98b
80102739:	e8 6b de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273e:	83 ec 04             	sub    $0x4,%esp
80102741:	68 00 10 00 00       	push   $0x1000
80102746:	6a 01                	push   $0x1
80102748:	ff 75 08             	push   0x8(%ebp)
8010274b:	e8 4c 26 00 00       	call   80104d9c <memset>
80102750:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102753:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102758:	85 c0                	test   %eax,%eax
8010275a:	74 10                	je     8010276c <kfree+0x65>
    acquire(&kmem.lock);
8010275c:	83 ec 0c             	sub    $0xc,%esp
8010275f:	68 c0 40 19 80       	push   $0x801940c0
80102764:	e8 bd 23 00 00       	call   80104b26 <acquire>
80102769:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010276c:	8b 45 08             	mov    0x8(%ebp),%eax
8010276f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102772:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
80102778:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277b:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010277d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102780:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
80102785:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010278a:	85 c0                	test   %eax,%eax
8010278c:	74 10                	je     8010279e <kfree+0x97>
    release(&kmem.lock);
8010278e:	83 ec 0c             	sub    $0xc,%esp
80102791:	68 c0 40 19 80       	push   $0x801940c0
80102796:	e8 f9 23 00 00       	call   80104b94 <release>
8010279b:	83 c4 10             	add    $0x10,%esp
}
8010279e:	90                   	nop
8010279f:	c9                   	leave  
801027a0:	c3                   	ret    

801027a1 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027a1:	55                   	push   %ebp
801027a2:	89 e5                	mov    %esp,%ebp
801027a4:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027a7:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027ac:	85 c0                	test   %eax,%eax
801027ae:	74 10                	je     801027c0 <kalloc+0x1f>
    acquire(&kmem.lock);
801027b0:	83 ec 0c             	sub    $0xc,%esp
801027b3:	68 c0 40 19 80       	push   $0x801940c0
801027b8:	e8 69 23 00 00       	call   80104b26 <acquire>
801027bd:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027c0:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027cc:	74 0a                	je     801027d8 <kalloc+0x37>
    kmem.freelist = r->next;
801027ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d1:	8b 00                	mov    (%eax),%eax
801027d3:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027d8:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027dd:	85 c0                	test   %eax,%eax
801027df:	74 10                	je     801027f1 <kalloc+0x50>
    release(&kmem.lock);
801027e1:	83 ec 0c             	sub    $0xc,%esp
801027e4:	68 c0 40 19 80       	push   $0x801940c0
801027e9:	e8 a6 23 00 00       	call   80104b94 <release>
801027ee:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027f4:	c9                   	leave  
801027f5:	c3                   	ret    

801027f6 <inb>:
{
801027f6:	55                   	push   %ebp
801027f7:	89 e5                	mov    %esp,%ebp
801027f9:	83 ec 14             	sub    $0x14,%esp
801027fc:	8b 45 08             	mov    0x8(%ebp),%eax
801027ff:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102803:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102807:	89 c2                	mov    %eax,%edx
80102809:	ec                   	in     (%dx),%al
8010280a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010280d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102811:	c9                   	leave  
80102812:	c3                   	ret    

80102813 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102813:	55                   	push   %ebp
80102814:	89 e5                	mov    %esp,%ebp
80102816:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102819:	6a 64                	push   $0x64
8010281b:	e8 d6 ff ff ff       	call   801027f6 <inb>
80102820:	83 c4 04             	add    $0x4,%esp
80102823:	0f b6 c0             	movzbl %al,%eax
80102826:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282c:	83 e0 01             	and    $0x1,%eax
8010282f:	85 c0                	test   %eax,%eax
80102831:	75 0a                	jne    8010283d <kbdgetc+0x2a>
    return -1;
80102833:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102838:	e9 23 01 00 00       	jmp    80102960 <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010283d:	6a 60                	push   $0x60
8010283f:	e8 b2 ff ff ff       	call   801027f6 <inb>
80102844:	83 c4 04             	add    $0x4,%esp
80102847:	0f b6 c0             	movzbl %al,%eax
8010284a:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010284d:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102854:	75 17                	jne    8010286d <kbdgetc+0x5a>
    shift |= E0ESC;
80102856:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010285b:	83 c8 40             	or     $0x40,%eax
8010285e:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102863:	b8 00 00 00 00       	mov    $0x0,%eax
80102868:	e9 f3 00 00 00       	jmp    80102960 <kbdgetc+0x14d>
  } else if(data & 0x80){
8010286d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102870:	25 80 00 00 00       	and    $0x80,%eax
80102875:	85 c0                	test   %eax,%eax
80102877:	74 45                	je     801028be <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102879:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010287e:	83 e0 40             	and    $0x40,%eax
80102881:	85 c0                	test   %eax,%eax
80102883:	75 08                	jne    8010288d <kbdgetc+0x7a>
80102885:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102888:	83 e0 7f             	and    $0x7f,%eax
8010288b:	eb 03                	jmp    80102890 <kbdgetc+0x7d>
8010288d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102890:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102893:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102896:	05 20 d0 10 80       	add    $0x8010d020,%eax
8010289b:	0f b6 00             	movzbl (%eax),%eax
8010289e:	83 c8 40             	or     $0x40,%eax
801028a1:	0f b6 c0             	movzbl %al,%eax
801028a4:	f7 d0                	not    %eax
801028a6:	89 c2                	mov    %eax,%edx
801028a8:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ad:	21 d0                	and    %edx,%eax
801028af:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028b4:	b8 00 00 00 00       	mov    $0x0,%eax
801028b9:	e9 a2 00 00 00       	jmp    80102960 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028be:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028c3:	83 e0 40             	and    $0x40,%eax
801028c6:	85 c0                	test   %eax,%eax
801028c8:	74 14                	je     801028de <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028ca:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d1:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028d6:	83 e0 bf             	and    $0xffffffbf,%eax
801028d9:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e1:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028e6:	0f b6 00             	movzbl (%eax),%eax
801028e9:	0f b6 d0             	movzbl %al,%edx
801028ec:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f1:	09 d0                	or     %edx,%eax
801028f3:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028fb:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102900:	0f b6 00             	movzbl (%eax),%eax
80102903:	0f b6 d0             	movzbl %al,%edx
80102906:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010290b:	31 d0                	xor    %edx,%eax
8010290d:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102912:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102917:	83 e0 03             	and    $0x3,%eax
8010291a:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102921:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102924:	01 d0                	add    %edx,%eax
80102926:	0f b6 00             	movzbl (%eax),%eax
80102929:	0f b6 c0             	movzbl %al,%eax
8010292c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010292f:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102934:	83 e0 08             	and    $0x8,%eax
80102937:	85 c0                	test   %eax,%eax
80102939:	74 22                	je     8010295d <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010293b:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010293f:	76 0c                	jbe    8010294d <kbdgetc+0x13a>
80102941:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102945:	77 06                	ja     8010294d <kbdgetc+0x13a>
      c += 'A' - 'a';
80102947:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010294b:	eb 10                	jmp    8010295d <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010294d:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102951:	76 0a                	jbe    8010295d <kbdgetc+0x14a>
80102953:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102957:	77 04                	ja     8010295d <kbdgetc+0x14a>
      c += 'a' - 'A';
80102959:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010295d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102960:	c9                   	leave  
80102961:	c3                   	ret    

80102962 <kbdintr>:

void
kbdintr(void)
{
80102962:	55                   	push   %ebp
80102963:	89 e5                	mov    %esp,%ebp
80102965:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102968:	83 ec 0c             	sub    $0xc,%esp
8010296b:	68 13 28 10 80       	push   $0x80102813
80102970:	e8 61 de ff ff       	call   801007d6 <consoleintr>
80102975:	83 c4 10             	add    $0x10,%esp
}
80102978:	90                   	nop
80102979:	c9                   	leave  
8010297a:	c3                   	ret    

8010297b <inb>:
{
8010297b:	55                   	push   %ebp
8010297c:	89 e5                	mov    %esp,%ebp
8010297e:	83 ec 14             	sub    $0x14,%esp
80102981:	8b 45 08             	mov    0x8(%ebp),%eax
80102984:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102988:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010298c:	89 c2                	mov    %eax,%edx
8010298e:	ec                   	in     (%dx),%al
8010298f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102992:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102996:	c9                   	leave  
80102997:	c3                   	ret    

80102998 <outb>:
{
80102998:	55                   	push   %ebp
80102999:	89 e5                	mov    %esp,%ebp
8010299b:	83 ec 08             	sub    $0x8,%esp
8010299e:	8b 45 08             	mov    0x8(%ebp),%eax
801029a1:	8b 55 0c             	mov    0xc(%ebp),%edx
801029a4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801029a8:	89 d0                	mov    %edx,%eax
801029aa:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029ad:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029b5:	ee                   	out    %al,(%dx)
}
801029b6:	90                   	nop
801029b7:	c9                   	leave  
801029b8:	c3                   	ret    

801029b9 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029b9:	55                   	push   %ebp
801029ba:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029bc:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029c2:	8b 45 08             	mov    0x8(%ebp),%eax
801029c5:	c1 e0 02             	shl    $0x2,%eax
801029c8:	01 c2                	add    %eax,%edx
801029ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801029cd:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029cf:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d4:	83 c0 20             	add    $0x20,%eax
801029d7:	8b 00                	mov    (%eax),%eax
}
801029d9:	90                   	nop
801029da:	5d                   	pop    %ebp
801029db:	c3                   	ret    

801029dc <lapicinit>:

void
lapicinit(void)
{
801029dc:	55                   	push   %ebp
801029dd:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029df:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e4:	85 c0                	test   %eax,%eax
801029e6:	0f 84 0c 01 00 00    	je     80102af8 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029ec:	68 3f 01 00 00       	push   $0x13f
801029f1:	6a 3c                	push   $0x3c
801029f3:	e8 c1 ff ff ff       	call   801029b9 <lapicw>
801029f8:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029fb:	6a 0b                	push   $0xb
801029fd:	68 f8 00 00 00       	push   $0xf8
80102a02:	e8 b2 ff ff ff       	call   801029b9 <lapicw>
80102a07:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a0a:	68 20 00 02 00       	push   $0x20020
80102a0f:	68 c8 00 00 00       	push   $0xc8
80102a14:	e8 a0 ff ff ff       	call   801029b9 <lapicw>
80102a19:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a1c:	68 80 96 98 00       	push   $0x989680
80102a21:	68 e0 00 00 00       	push   $0xe0
80102a26:	e8 8e ff ff ff       	call   801029b9 <lapicw>
80102a2b:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a2e:	68 00 00 01 00       	push   $0x10000
80102a33:	68 d4 00 00 00       	push   $0xd4
80102a38:	e8 7c ff ff ff       	call   801029b9 <lapicw>
80102a3d:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a40:	68 00 00 01 00       	push   $0x10000
80102a45:	68 d8 00 00 00       	push   $0xd8
80102a4a:	e8 6a ff ff ff       	call   801029b9 <lapicw>
80102a4f:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a52:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a57:	83 c0 30             	add    $0x30,%eax
80102a5a:	8b 00                	mov    (%eax),%eax
80102a5c:	c1 e8 10             	shr    $0x10,%eax
80102a5f:	25 fc 00 00 00       	and    $0xfc,%eax
80102a64:	85 c0                	test   %eax,%eax
80102a66:	74 12                	je     80102a7a <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a68:	68 00 00 01 00       	push   $0x10000
80102a6d:	68 d0 00 00 00       	push   $0xd0
80102a72:	e8 42 ff ff ff       	call   801029b9 <lapicw>
80102a77:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a7a:	6a 33                	push   $0x33
80102a7c:	68 dc 00 00 00       	push   $0xdc
80102a81:	e8 33 ff ff ff       	call   801029b9 <lapicw>
80102a86:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a89:	6a 00                	push   $0x0
80102a8b:	68 a0 00 00 00       	push   $0xa0
80102a90:	e8 24 ff ff ff       	call   801029b9 <lapicw>
80102a95:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a98:	6a 00                	push   $0x0
80102a9a:	68 a0 00 00 00       	push   $0xa0
80102a9f:	e8 15 ff ff ff       	call   801029b9 <lapicw>
80102aa4:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa7:	6a 00                	push   $0x0
80102aa9:	6a 2c                	push   $0x2c
80102aab:	e8 09 ff ff ff       	call   801029b9 <lapicw>
80102ab0:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab3:	6a 00                	push   $0x0
80102ab5:	68 c4 00 00 00       	push   $0xc4
80102aba:	e8 fa fe ff ff       	call   801029b9 <lapicw>
80102abf:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac2:	68 00 85 08 00       	push   $0x88500
80102ac7:	68 c0 00 00 00       	push   $0xc0
80102acc:	e8 e8 fe ff ff       	call   801029b9 <lapicw>
80102ad1:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad4:	90                   	nop
80102ad5:	a1 00 41 19 80       	mov    0x80194100,%eax
80102ada:	05 00 03 00 00       	add    $0x300,%eax
80102adf:	8b 00                	mov    (%eax),%eax
80102ae1:	25 00 10 00 00       	and    $0x1000,%eax
80102ae6:	85 c0                	test   %eax,%eax
80102ae8:	75 eb                	jne    80102ad5 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102aea:	6a 00                	push   $0x0
80102aec:	6a 20                	push   $0x20
80102aee:	e8 c6 fe ff ff       	call   801029b9 <lapicw>
80102af3:	83 c4 08             	add    $0x8,%esp
80102af6:	eb 01                	jmp    80102af9 <lapicinit+0x11d>
    return;
80102af8:	90                   	nop
}
80102af9:	c9                   	leave  
80102afa:	c3                   	ret    

80102afb <lapicid>:

int
lapicid(void)
{
80102afb:	55                   	push   %ebp
80102afc:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102afe:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b03:	85 c0                	test   %eax,%eax
80102b05:	75 07                	jne    80102b0e <lapicid+0x13>
    return 0;
80102b07:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0c:	eb 0d                	jmp    80102b1b <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0e:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b13:	83 c0 20             	add    $0x20,%eax
80102b16:	8b 00                	mov    (%eax),%eax
80102b18:	c1 e8 18             	shr    $0x18,%eax
}
80102b1b:	5d                   	pop    %ebp
80102b1c:	c3                   	ret    

80102b1d <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1d:	55                   	push   %ebp
80102b1e:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b20:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b25:	85 c0                	test   %eax,%eax
80102b27:	74 0c                	je     80102b35 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b29:	6a 00                	push   $0x0
80102b2b:	6a 2c                	push   $0x2c
80102b2d:	e8 87 fe ff ff       	call   801029b9 <lapicw>
80102b32:	83 c4 08             	add    $0x8,%esp
}
80102b35:	90                   	nop
80102b36:	c9                   	leave  
80102b37:	c3                   	ret    

80102b38 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b38:	55                   	push   %ebp
80102b39:	89 e5                	mov    %esp,%ebp
}
80102b3b:	90                   	nop
80102b3c:	5d                   	pop    %ebp
80102b3d:	c3                   	ret    

80102b3e <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3e:	55                   	push   %ebp
80102b3f:	89 e5                	mov    %esp,%ebp
80102b41:	83 ec 14             	sub    $0x14,%esp
80102b44:	8b 45 08             	mov    0x8(%ebp),%eax
80102b47:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b4a:	6a 0f                	push   $0xf
80102b4c:	6a 70                	push   $0x70
80102b4e:	e8 45 fe ff ff       	call   80102998 <outb>
80102b53:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b56:	6a 0a                	push   $0xa
80102b58:	6a 71                	push   $0x71
80102b5a:	e8 39 fe ff ff       	call   80102998 <outb>
80102b5f:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b62:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b69:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6c:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b71:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b74:	c1 e8 04             	shr    $0x4,%eax
80102b77:	89 c2                	mov    %eax,%edx
80102b79:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7c:	83 c0 02             	add    $0x2,%eax
80102b7f:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b82:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b86:	c1 e0 18             	shl    $0x18,%eax
80102b89:	50                   	push   %eax
80102b8a:	68 c4 00 00 00       	push   $0xc4
80102b8f:	e8 25 fe ff ff       	call   801029b9 <lapicw>
80102b94:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b97:	68 00 c5 00 00       	push   $0xc500
80102b9c:	68 c0 00 00 00       	push   $0xc0
80102ba1:	e8 13 fe ff ff       	call   801029b9 <lapicw>
80102ba6:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102ba9:	68 c8 00 00 00       	push   $0xc8
80102bae:	e8 85 ff ff ff       	call   80102b38 <microdelay>
80102bb3:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb6:	68 00 85 00 00       	push   $0x8500
80102bbb:	68 c0 00 00 00       	push   $0xc0
80102bc0:	e8 f4 fd ff ff       	call   801029b9 <lapicw>
80102bc5:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc8:	6a 64                	push   $0x64
80102bca:	e8 69 ff ff ff       	call   80102b38 <microdelay>
80102bcf:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bd9:	eb 3d                	jmp    80102c18 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bdb:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bdf:	c1 e0 18             	shl    $0x18,%eax
80102be2:	50                   	push   %eax
80102be3:	68 c4 00 00 00       	push   $0xc4
80102be8:	e8 cc fd ff ff       	call   801029b9 <lapicw>
80102bed:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bf0:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf3:	c1 e8 0c             	shr    $0xc,%eax
80102bf6:	80 cc 06             	or     $0x6,%ah
80102bf9:	50                   	push   %eax
80102bfa:	68 c0 00 00 00       	push   $0xc0
80102bff:	e8 b5 fd ff ff       	call   801029b9 <lapicw>
80102c04:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c07:	68 c8 00 00 00       	push   $0xc8
80102c0c:	e8 27 ff ff ff       	call   80102b38 <microdelay>
80102c11:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c14:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c18:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1c:	7e bd                	jle    80102bdb <lapicstartap+0x9d>
  }
}
80102c1e:	90                   	nop
80102c1f:	90                   	nop
80102c20:	c9                   	leave  
80102c21:	c3                   	ret    

80102c22 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c22:	55                   	push   %ebp
80102c23:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c25:	8b 45 08             	mov    0x8(%ebp),%eax
80102c28:	0f b6 c0             	movzbl %al,%eax
80102c2b:	50                   	push   %eax
80102c2c:	6a 70                	push   $0x70
80102c2e:	e8 65 fd ff ff       	call   80102998 <outb>
80102c33:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c36:	68 c8 00 00 00       	push   $0xc8
80102c3b:	e8 f8 fe ff ff       	call   80102b38 <microdelay>
80102c40:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c43:	6a 71                	push   $0x71
80102c45:	e8 31 fd ff ff       	call   8010297b <inb>
80102c4a:	83 c4 04             	add    $0x4,%esp
80102c4d:	0f b6 c0             	movzbl %al,%eax
}
80102c50:	c9                   	leave  
80102c51:	c3                   	ret    

80102c52 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c52:	55                   	push   %ebp
80102c53:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c55:	6a 00                	push   $0x0
80102c57:	e8 c6 ff ff ff       	call   80102c22 <cmos_read>
80102c5c:	83 c4 04             	add    $0x4,%esp
80102c5f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c62:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c64:	6a 02                	push   $0x2
80102c66:	e8 b7 ff ff ff       	call   80102c22 <cmos_read>
80102c6b:	83 c4 04             	add    $0x4,%esp
80102c6e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c71:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c74:	6a 04                	push   $0x4
80102c76:	e8 a7 ff ff ff       	call   80102c22 <cmos_read>
80102c7b:	83 c4 04             	add    $0x4,%esp
80102c7e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c81:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c84:	6a 07                	push   $0x7
80102c86:	e8 97 ff ff ff       	call   80102c22 <cmos_read>
80102c8b:	83 c4 04             	add    $0x4,%esp
80102c8e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c91:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c94:	6a 08                	push   $0x8
80102c96:	e8 87 ff ff ff       	call   80102c22 <cmos_read>
80102c9b:	83 c4 04             	add    $0x4,%esp
80102c9e:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca1:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca4:	6a 09                	push   $0x9
80102ca6:	e8 77 ff ff ff       	call   80102c22 <cmos_read>
80102cab:	83 c4 04             	add    $0x4,%esp
80102cae:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb1:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb4:	90                   	nop
80102cb5:	c9                   	leave  
80102cb6:	c3                   	ret    

80102cb7 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb7:	55                   	push   %ebp
80102cb8:	89 e5                	mov    %esp,%ebp
80102cba:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbd:	6a 0b                	push   $0xb
80102cbf:	e8 5e ff ff ff       	call   80102c22 <cmos_read>
80102cc4:	83 c4 04             	add    $0x4,%esp
80102cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccd:	83 e0 04             	and    $0x4,%eax
80102cd0:	85 c0                	test   %eax,%eax
80102cd2:	0f 94 c0             	sete   %al
80102cd5:	0f b6 c0             	movzbl %al,%eax
80102cd8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cdb:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cde:	50                   	push   %eax
80102cdf:	e8 6e ff ff ff       	call   80102c52 <fill_rtcdate>
80102ce4:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce7:	6a 0a                	push   $0xa
80102ce9:	e8 34 ff ff ff       	call   80102c22 <cmos_read>
80102cee:	83 c4 04             	add    $0x4,%esp
80102cf1:	25 80 00 00 00       	and    $0x80,%eax
80102cf6:	85 c0                	test   %eax,%eax
80102cf8:	75 27                	jne    80102d21 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cfa:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfd:	50                   	push   %eax
80102cfe:	e8 4f ff ff ff       	call   80102c52 <fill_rtcdate>
80102d03:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d06:	83 ec 04             	sub    $0x4,%esp
80102d09:	6a 18                	push   $0x18
80102d0b:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0e:	50                   	push   %eax
80102d0f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d12:	50                   	push   %eax
80102d13:	e8 eb 20 00 00       	call   80104e03 <memcmp>
80102d18:	83 c4 10             	add    $0x10,%esp
80102d1b:	85 c0                	test   %eax,%eax
80102d1d:	74 05                	je     80102d24 <cmostime+0x6d>
80102d1f:	eb ba                	jmp    80102cdb <cmostime+0x24>
        continue;
80102d21:	90                   	nop
    fill_rtcdate(&t1);
80102d22:	eb b7                	jmp    80102cdb <cmostime+0x24>
      break;
80102d24:	90                   	nop
  }

  // convert
  if(bcd) {
80102d25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d29:	0f 84 b4 00 00 00    	je     80102de3 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d2f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d32:	c1 e8 04             	shr    $0x4,%eax
80102d35:	89 c2                	mov    %eax,%edx
80102d37:	89 d0                	mov    %edx,%eax
80102d39:	c1 e0 02             	shl    $0x2,%eax
80102d3c:	01 d0                	add    %edx,%eax
80102d3e:	01 c0                	add    %eax,%eax
80102d40:	89 c2                	mov    %eax,%edx
80102d42:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d45:	83 e0 0f             	and    $0xf,%eax
80102d48:	01 d0                	add    %edx,%eax
80102d4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d50:	c1 e8 04             	shr    $0x4,%eax
80102d53:	89 c2                	mov    %eax,%edx
80102d55:	89 d0                	mov    %edx,%eax
80102d57:	c1 e0 02             	shl    $0x2,%eax
80102d5a:	01 d0                	add    %edx,%eax
80102d5c:	01 c0                	add    %eax,%eax
80102d5e:	89 c2                	mov    %eax,%edx
80102d60:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d63:	83 e0 0f             	and    $0xf,%eax
80102d66:	01 d0                	add    %edx,%eax
80102d68:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6e:	c1 e8 04             	shr    $0x4,%eax
80102d71:	89 c2                	mov    %eax,%edx
80102d73:	89 d0                	mov    %edx,%eax
80102d75:	c1 e0 02             	shl    $0x2,%eax
80102d78:	01 d0                	add    %edx,%eax
80102d7a:	01 c0                	add    %eax,%eax
80102d7c:	89 c2                	mov    %eax,%edx
80102d7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d81:	83 e0 0f             	and    $0xf,%eax
80102d84:	01 d0                	add    %edx,%eax
80102d86:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8c:	c1 e8 04             	shr    $0x4,%eax
80102d8f:	89 c2                	mov    %eax,%edx
80102d91:	89 d0                	mov    %edx,%eax
80102d93:	c1 e0 02             	shl    $0x2,%eax
80102d96:	01 d0                	add    %edx,%eax
80102d98:	01 c0                	add    %eax,%eax
80102d9a:	89 c2                	mov    %eax,%edx
80102d9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d9f:	83 e0 0f             	and    $0xf,%eax
80102da2:	01 d0                	add    %edx,%eax
80102da4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102daa:	c1 e8 04             	shr    $0x4,%eax
80102dad:	89 c2                	mov    %eax,%edx
80102daf:	89 d0                	mov    %edx,%eax
80102db1:	c1 e0 02             	shl    $0x2,%eax
80102db4:	01 d0                	add    %edx,%eax
80102db6:	01 c0                	add    %eax,%eax
80102db8:	89 c2                	mov    %eax,%edx
80102dba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbd:	83 e0 0f             	and    $0xf,%eax
80102dc0:	01 d0                	add    %edx,%eax
80102dc2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc8:	c1 e8 04             	shr    $0x4,%eax
80102dcb:	89 c2                	mov    %eax,%edx
80102dcd:	89 d0                	mov    %edx,%eax
80102dcf:	c1 e0 02             	shl    $0x2,%eax
80102dd2:	01 d0                	add    %edx,%eax
80102dd4:	01 c0                	add    %eax,%eax
80102dd6:	89 c2                	mov    %eax,%edx
80102dd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ddb:	83 e0 0f             	and    $0xf,%eax
80102dde:	01 d0                	add    %edx,%eax
80102de0:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de3:	8b 45 08             	mov    0x8(%ebp),%eax
80102de6:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102de9:	89 10                	mov    %edx,(%eax)
80102deb:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102dee:	89 50 04             	mov    %edx,0x4(%eax)
80102df1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df4:	89 50 08             	mov    %edx,0x8(%eax)
80102df7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102dfa:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfd:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102e00:	89 50 10             	mov    %edx,0x10(%eax)
80102e03:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e06:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e09:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0c:	8b 40 14             	mov    0x14(%eax),%eax
80102e0f:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e15:	8b 45 08             	mov    0x8(%ebp),%eax
80102e18:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1b:	90                   	nop
80102e1c:	c9                   	leave  
80102e1d:	c3                   	ret    

80102e1e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e1e:	55                   	push   %ebp
80102e1f:	89 e5                	mov    %esp,%ebp
80102e21:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e24:	83 ec 08             	sub    $0x8,%esp
80102e27:	68 91 a9 10 80       	push   $0x8010a991
80102e2c:	68 20 41 19 80       	push   $0x80194120
80102e31:	e8 ce 1c 00 00       	call   80104b04 <initlock>
80102e36:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e39:	83 ec 08             	sub    $0x8,%esp
80102e3c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e3f:	50                   	push   %eax
80102e40:	ff 75 08             	push   0x8(%ebp)
80102e43:	e8 87 e5 ff ff       	call   801013cf <readsb>
80102e48:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4e:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e53:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e56:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5e:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e63:	e8 b3 01 00 00       	call   8010301b <recover_from_log>
}
80102e68:	90                   	nop
80102e69:	c9                   	leave  
80102e6a:	c3                   	ret    

80102e6b <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e6b:	55                   	push   %ebp
80102e6c:	89 e5                	mov    %esp,%ebp
80102e6e:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e78:	e9 95 00 00 00       	jmp    80102f12 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e7d:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e86:	01 d0                	add    %edx,%eax
80102e88:	83 c0 01             	add    $0x1,%eax
80102e8b:	89 c2                	mov    %eax,%edx
80102e8d:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e92:	83 ec 08             	sub    $0x8,%esp
80102e95:	52                   	push   %edx
80102e96:	50                   	push   %eax
80102e97:	e8 65 d3 ff ff       	call   80100201 <bread>
80102e9c:	83 c4 10             	add    $0x10,%esp
80102e9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea5:	83 c0 10             	add    $0x10,%eax
80102ea8:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eaf:	89 c2                	mov    %eax,%edx
80102eb1:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb6:	83 ec 08             	sub    $0x8,%esp
80102eb9:	52                   	push   %edx
80102eba:	50                   	push   %eax
80102ebb:	e8 41 d3 ff ff       	call   80100201 <bread>
80102ec0:	83 c4 10             	add    $0x10,%esp
80102ec3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ec9:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ecf:	83 c0 5c             	add    $0x5c,%eax
80102ed2:	83 ec 04             	sub    $0x4,%esp
80102ed5:	68 00 02 00 00       	push   $0x200
80102eda:	52                   	push   %edx
80102edb:	50                   	push   %eax
80102edc:	e8 7a 1f 00 00       	call   80104e5b <memmove>
80102ee1:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ee4:	83 ec 0c             	sub    $0xc,%esp
80102ee7:	ff 75 ec             	push   -0x14(%ebp)
80102eea:	e8 4b d3 ff ff       	call   8010023a <bwrite>
80102eef:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ef2:	83 ec 0c             	sub    $0xc,%esp
80102ef5:	ff 75 f0             	push   -0x10(%ebp)
80102ef8:	e8 86 d3 ff ff       	call   80100283 <brelse>
80102efd:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102f00:	83 ec 0c             	sub    $0xc,%esp
80102f03:	ff 75 ec             	push   -0x14(%ebp)
80102f06:	e8 78 d3 ff ff       	call   80100283 <brelse>
80102f0b:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f12:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f17:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f1a:	0f 8c 5d ff ff ff    	jl     80102e7d <install_trans+0x12>
  }
}
80102f20:	90                   	nop
80102f21:	90                   	nop
80102f22:	c9                   	leave  
80102f23:	c3                   	ret    

80102f24 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f24:	55                   	push   %ebp
80102f25:	89 e5                	mov    %esp,%ebp
80102f27:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f2a:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f2f:	89 c2                	mov    %eax,%edx
80102f31:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f36:	83 ec 08             	sub    $0x8,%esp
80102f39:	52                   	push   %edx
80102f3a:	50                   	push   %eax
80102f3b:	e8 c1 d2 ff ff       	call   80100201 <bread>
80102f40:	83 c4 10             	add    $0x10,%esp
80102f43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f49:	83 c0 5c             	add    $0x5c,%eax
80102f4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f52:	8b 00                	mov    (%eax),%eax
80102f54:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f60:	eb 1b                	jmp    80102f7d <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f62:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f68:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f6f:	83 c2 10             	add    $0x10,%edx
80102f72:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f79:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7d:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f82:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f85:	7c db                	jl     80102f62 <read_head+0x3e>
  }
  brelse(buf);
80102f87:	83 ec 0c             	sub    $0xc,%esp
80102f8a:	ff 75 f0             	push   -0x10(%ebp)
80102f8d:	e8 f1 d2 ff ff       	call   80100283 <brelse>
80102f92:	83 c4 10             	add    $0x10,%esp
}
80102f95:	90                   	nop
80102f96:	c9                   	leave  
80102f97:	c3                   	ret    

80102f98 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f98:	55                   	push   %ebp
80102f99:	89 e5                	mov    %esp,%ebp
80102f9b:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f9e:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa3:	89 c2                	mov    %eax,%edx
80102fa5:	a1 64 41 19 80       	mov    0x80194164,%eax
80102faa:	83 ec 08             	sub    $0x8,%esp
80102fad:	52                   	push   %edx
80102fae:	50                   	push   %eax
80102faf:	e8 4d d2 ff ff       	call   80100201 <bread>
80102fb4:	83 c4 10             	add    $0x10,%esp
80102fb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbd:	83 c0 5c             	add    $0x5c,%eax
80102fc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fc3:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd5:	eb 1b                	jmp    80102ff2 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fda:	83 c0 10             	add    $0x10,%eax
80102fdd:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fea:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff2:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ffa:	7c db                	jl     80102fd7 <write_head+0x3f>
  }
  bwrite(buf);
80102ffc:	83 ec 0c             	sub    $0xc,%esp
80102fff:	ff 75 f0             	push   -0x10(%ebp)
80103002:	e8 33 d2 ff ff       	call   8010023a <bwrite>
80103007:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010300a:	83 ec 0c             	sub    $0xc,%esp
8010300d:	ff 75 f0             	push   -0x10(%ebp)
80103010:	e8 6e d2 ff ff       	call   80100283 <brelse>
80103015:	83 c4 10             	add    $0x10,%esp
}
80103018:	90                   	nop
80103019:	c9                   	leave  
8010301a:	c3                   	ret    

8010301b <recover_from_log>:

static void
recover_from_log(void)
{
8010301b:	55                   	push   %ebp
8010301c:	89 e5                	mov    %esp,%ebp
8010301e:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103021:	e8 fe fe ff ff       	call   80102f24 <read_head>
  install_trans(); // if committed, copy from log to disk
80103026:	e8 40 fe ff ff       	call   80102e6b <install_trans>
  log.lh.n = 0;
8010302b:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103032:	00 00 00 
  write_head(); // clear the log
80103035:	e8 5e ff ff ff       	call   80102f98 <write_head>
}
8010303a:	90                   	nop
8010303b:	c9                   	leave  
8010303c:	c3                   	ret    

8010303d <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010303d:	55                   	push   %ebp
8010303e:	89 e5                	mov    %esp,%ebp
80103040:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103043:	83 ec 0c             	sub    $0xc,%esp
80103046:	68 20 41 19 80       	push   $0x80194120
8010304b:	e8 d6 1a 00 00       	call   80104b26 <acquire>
80103050:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103053:	a1 60 41 19 80       	mov    0x80194160,%eax
80103058:	85 c0                	test   %eax,%eax
8010305a:	74 17                	je     80103073 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305c:	83 ec 08             	sub    $0x8,%esp
8010305f:	68 20 41 19 80       	push   $0x80194120
80103064:	68 20 41 19 80       	push   $0x80194120
80103069:	e8 5e 16 00 00       	call   801046cc <sleep>
8010306e:	83 c4 10             	add    $0x10,%esp
80103071:	eb e0                	jmp    80103053 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103073:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
80103079:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307e:	8d 50 01             	lea    0x1(%eax),%edx
80103081:	89 d0                	mov    %edx,%eax
80103083:	c1 e0 02             	shl    $0x2,%eax
80103086:	01 d0                	add    %edx,%eax
80103088:	01 c0                	add    %eax,%eax
8010308a:	01 c8                	add    %ecx,%eax
8010308c:	83 f8 1e             	cmp    $0x1e,%eax
8010308f:	7e 17                	jle    801030a8 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103091:	83 ec 08             	sub    $0x8,%esp
80103094:	68 20 41 19 80       	push   $0x80194120
80103099:	68 20 41 19 80       	push   $0x80194120
8010309e:	e8 29 16 00 00       	call   801046cc <sleep>
801030a3:	83 c4 10             	add    $0x10,%esp
801030a6:	eb ab                	jmp    80103053 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a8:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ad:	83 c0 01             	add    $0x1,%eax
801030b0:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030b5:	83 ec 0c             	sub    $0xc,%esp
801030b8:	68 20 41 19 80       	push   $0x80194120
801030bd:	e8 d2 1a 00 00       	call   80104b94 <release>
801030c2:	83 c4 10             	add    $0x10,%esp
      break;
801030c5:	90                   	nop
    }
  }
}
801030c6:	90                   	nop
801030c7:	c9                   	leave  
801030c8:	c3                   	ret    

801030c9 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030c9:	55                   	push   %ebp
801030ca:	89 e5                	mov    %esp,%ebp
801030cc:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d6:	83 ec 0c             	sub    $0xc,%esp
801030d9:	68 20 41 19 80       	push   $0x80194120
801030de:	e8 43 1a 00 00       	call   80104b26 <acquire>
801030e3:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e6:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030eb:	83 e8 01             	sub    $0x1,%eax
801030ee:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030f3:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f8:	85 c0                	test   %eax,%eax
801030fa:	74 0d                	je     80103109 <end_op+0x40>
    panic("log.committing");
801030fc:	83 ec 0c             	sub    $0xc,%esp
801030ff:	68 95 a9 10 80       	push   $0x8010a995
80103104:	e8 a0 d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
80103109:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310e:	85 c0                	test   %eax,%eax
80103110:	75 13                	jne    80103125 <end_op+0x5c>
    do_commit = 1;
80103112:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103119:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
80103120:	00 00 00 
80103123:	eb 10                	jmp    80103135 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103125:	83 ec 0c             	sub    $0xc,%esp
80103128:	68 20 41 19 80       	push   $0x80194120
8010312d:	e8 84 16 00 00       	call   801047b6 <wakeup>
80103132:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103135:	83 ec 0c             	sub    $0xc,%esp
80103138:	68 20 41 19 80       	push   $0x80194120
8010313d:	e8 52 1a 00 00       	call   80104b94 <release>
80103142:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103145:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103149:	74 3f                	je     8010318a <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010314b:	e8 f6 00 00 00       	call   80103246 <commit>
    acquire(&log.lock);
80103150:	83 ec 0c             	sub    $0xc,%esp
80103153:	68 20 41 19 80       	push   $0x80194120
80103158:	e8 c9 19 00 00       	call   80104b26 <acquire>
8010315d:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103160:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103167:	00 00 00 
    wakeup(&log);
8010316a:	83 ec 0c             	sub    $0xc,%esp
8010316d:	68 20 41 19 80       	push   $0x80194120
80103172:	e8 3f 16 00 00       	call   801047b6 <wakeup>
80103177:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010317a:	83 ec 0c             	sub    $0xc,%esp
8010317d:	68 20 41 19 80       	push   $0x80194120
80103182:	e8 0d 1a 00 00       	call   80104b94 <release>
80103187:	83 c4 10             	add    $0x10,%esp
  }
}
8010318a:	90                   	nop
8010318b:	c9                   	leave  
8010318c:	c3                   	ret    

8010318d <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010318d:	55                   	push   %ebp
8010318e:	89 e5                	mov    %esp,%ebp
80103190:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103193:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010319a:	e9 95 00 00 00       	jmp    80103234 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010319f:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a8:	01 d0                	add    %edx,%eax
801031aa:	83 c0 01             	add    $0x1,%eax
801031ad:	89 c2                	mov    %eax,%edx
801031af:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b4:	83 ec 08             	sub    $0x8,%esp
801031b7:	52                   	push   %edx
801031b8:	50                   	push   %eax
801031b9:	e8 43 d0 ff ff       	call   80100201 <bread>
801031be:	83 c4 10             	add    $0x10,%esp
801031c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c7:	83 c0 10             	add    $0x10,%eax
801031ca:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d1:	89 c2                	mov    %eax,%edx
801031d3:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d8:	83 ec 08             	sub    $0x8,%esp
801031db:	52                   	push   %edx
801031dc:	50                   	push   %eax
801031dd:	e8 1f d0 ff ff       	call   80100201 <bread>
801031e2:	83 c4 10             	add    $0x10,%esp
801031e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031eb:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f1:	83 c0 5c             	add    $0x5c,%eax
801031f4:	83 ec 04             	sub    $0x4,%esp
801031f7:	68 00 02 00 00       	push   $0x200
801031fc:	52                   	push   %edx
801031fd:	50                   	push   %eax
801031fe:	e8 58 1c 00 00       	call   80104e5b <memmove>
80103203:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103206:	83 ec 0c             	sub    $0xc,%esp
80103209:	ff 75 f0             	push   -0x10(%ebp)
8010320c:	e8 29 d0 ff ff       	call   8010023a <bwrite>
80103211:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103214:	83 ec 0c             	sub    $0xc,%esp
80103217:	ff 75 ec             	push   -0x14(%ebp)
8010321a:	e8 64 d0 ff ff       	call   80100283 <brelse>
8010321f:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103222:	83 ec 0c             	sub    $0xc,%esp
80103225:	ff 75 f0             	push   -0x10(%ebp)
80103228:	e8 56 d0 ff ff       	call   80100283 <brelse>
8010322d:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103230:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103234:	a1 68 41 19 80       	mov    0x80194168,%eax
80103239:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323c:	0f 8c 5d ff ff ff    	jl     8010319f <write_log+0x12>
  }
}
80103242:	90                   	nop
80103243:	90                   	nop
80103244:	c9                   	leave  
80103245:	c3                   	ret    

80103246 <commit>:

static void
commit()
{
80103246:	55                   	push   %ebp
80103247:	89 e5                	mov    %esp,%ebp
80103249:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010324c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103251:	85 c0                	test   %eax,%eax
80103253:	7e 1e                	jle    80103273 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103255:	e8 33 ff ff ff       	call   8010318d <write_log>
    write_head();    // Write header to disk -- the real commit
8010325a:	e8 39 fd ff ff       	call   80102f98 <write_head>
    install_trans(); // Now install writes to home locations
8010325f:	e8 07 fc ff ff       	call   80102e6b <install_trans>
    log.lh.n = 0;
80103264:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326b:	00 00 00 
    write_head();    // Erase the transaction from the log
8010326e:	e8 25 fd ff ff       	call   80102f98 <write_head>
  }
}
80103273:	90                   	nop
80103274:	c9                   	leave  
80103275:	c3                   	ret    

80103276 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103276:	55                   	push   %ebp
80103277:	89 e5                	mov    %esp,%ebp
80103279:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010327c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103281:	83 f8 1d             	cmp    $0x1d,%eax
80103284:	7f 12                	jg     80103298 <log_write+0x22>
80103286:	a1 68 41 19 80       	mov    0x80194168,%eax
8010328b:	8b 15 58 41 19 80    	mov    0x80194158,%edx
80103291:	83 ea 01             	sub    $0x1,%edx
80103294:	39 d0                	cmp    %edx,%eax
80103296:	7c 0d                	jl     801032a5 <log_write+0x2f>
    panic("too big a transaction");
80103298:	83 ec 0c             	sub    $0xc,%esp
8010329b:	68 a4 a9 10 80       	push   $0x8010a9a4
801032a0:	e8 04 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a5:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032aa:	85 c0                	test   %eax,%eax
801032ac:	7f 0d                	jg     801032bb <log_write+0x45>
    panic("log_write outside of trans");
801032ae:	83 ec 0c             	sub    $0xc,%esp
801032b1:	68 ba a9 10 80       	push   $0x8010a9ba
801032b6:	e8 ee d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032bb:	83 ec 0c             	sub    $0xc,%esp
801032be:	68 20 41 19 80       	push   $0x80194120
801032c3:	e8 5e 18 00 00       	call   80104b26 <acquire>
801032c8:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d2:	eb 1d                	jmp    801032f1 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d7:	83 c0 10             	add    $0x10,%eax
801032da:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e1:	89 c2                	mov    %eax,%edx
801032e3:	8b 45 08             	mov    0x8(%ebp),%eax
801032e6:	8b 40 08             	mov    0x8(%eax),%eax
801032e9:	39 c2                	cmp    %eax,%edx
801032eb:	74 10                	je     801032fd <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f1:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032f9:	7c d9                	jl     801032d4 <log_write+0x5e>
801032fb:	eb 01                	jmp    801032fe <log_write+0x88>
      break;
801032fd:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103301:	8b 40 08             	mov    0x8(%eax),%eax
80103304:	89 c2                	mov    %eax,%edx
80103306:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103309:	83 c0 10             	add    $0x10,%eax
8010330c:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103313:	a1 68 41 19 80       	mov    0x80194168,%eax
80103318:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331b:	75 0d                	jne    8010332a <log_write+0xb4>
    log.lh.n++;
8010331d:	a1 68 41 19 80       	mov    0x80194168,%eax
80103322:	83 c0 01             	add    $0x1,%eax
80103325:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
8010332a:	8b 45 08             	mov    0x8(%ebp),%eax
8010332d:	8b 00                	mov    (%eax),%eax
8010332f:	83 c8 04             	or     $0x4,%eax
80103332:	89 c2                	mov    %eax,%edx
80103334:	8b 45 08             	mov    0x8(%ebp),%eax
80103337:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103339:	83 ec 0c             	sub    $0xc,%esp
8010333c:	68 20 41 19 80       	push   $0x80194120
80103341:	e8 4e 18 00 00       	call   80104b94 <release>
80103346:	83 c4 10             	add    $0x10,%esp
}
80103349:	90                   	nop
8010334a:	c9                   	leave  
8010334b:	c3                   	ret    

8010334c <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334c:	55                   	push   %ebp
8010334d:	89 e5                	mov    %esp,%ebp
8010334f:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103352:	8b 55 08             	mov    0x8(%ebp),%edx
80103355:	8b 45 0c             	mov    0xc(%ebp),%eax
80103358:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335b:	f0 87 02             	lock xchg %eax,(%edx)
8010335e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103361:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103364:	c9                   	leave  
80103365:	c3                   	ret    

80103366 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103366:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010336a:	83 e4 f0             	and    $0xfffffff0,%esp
8010336d:	ff 71 fc             	push   -0x4(%ecx)
80103370:	55                   	push   %ebp
80103371:	89 e5                	mov    %esp,%ebp
80103373:	51                   	push   %ecx
80103374:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103377:	e8 a6 51 00 00       	call   80108522 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337c:	83 ec 08             	sub    $0x8,%esp
8010337f:	68 00 00 40 80       	push   $0x80400000
80103384:	68 00 90 19 80       	push   $0x80199000
80103389:	e8 de f2 ff ff       	call   8010266c <kinit1>
8010338e:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103391:	e8 a6 47 00 00       	call   80107b3c <kvmalloc>
  mpinit_uefi();
80103396:	e8 4d 4f 00 00       	call   801082e8 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339b:	e8 3c f6 ff ff       	call   801029dc <lapicinit>
  seginit();       // segment descriptors
801033a0:	e8 2f 42 00 00       	call   801075d4 <seginit>
  picinit();    // disable pic
801033a5:	e8 9d 01 00 00       	call   80103547 <picinit>
  ioapicinit();    // another interrupt controller
801033aa:	e8 d8 f1 ff ff       	call   80102587 <ioapicinit>
  consoleinit();   // console hardware
801033af:	e8 4b d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b4:	e8 b4 35 00 00       	call   8010696d <uartinit>
  pinit();         // process table
801033b9:	e8 c2 05 00 00       	call   80103980 <pinit>
  tvinit();        // trap vectors
801033be:	e8 28 31 00 00       	call   801064eb <tvinit>
  binit();         // buffer cache
801033c3:	e8 9e cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c8:	e8 f3 db ff ff       	call   80100fc0 <fileinit>
  ideinit();       // disk 
801033cd:	e8 91 72 00 00       	call   8010a663 <ideinit>
  startothers();   // start other processors
801033d2:	e8 8a 00 00 00       	call   80103461 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d7:	83 ec 08             	sub    $0x8,%esp
801033da:	68 00 00 00 a0       	push   $0xa0000000
801033df:	68 00 00 40 80       	push   $0x80400000
801033e4:	e8 bc f2 ff ff       	call   801026a5 <kinit2>
801033e9:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033ec:	e8 8a 53 00 00       	call   8010877b <pci_init>
  arp_scan();
801033f1:	e8 c1 60 00 00       	call   801094b7 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f6:	e8 be 07 00 00       	call   80103bb9 <userinit>

  mpmain();        // finish this processor's setup
801033fb:	e8 1a 00 00 00       	call   8010341a <mpmain>

80103400 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103400:	55                   	push   %ebp
80103401:	89 e5                	mov    %esp,%ebp
80103403:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103406:	e8 49 47 00 00       	call   80107b54 <switchkvm>
  seginit();
8010340b:	e8 c4 41 00 00       	call   801075d4 <seginit>
  lapicinit();
80103410:	e8 c7 f5 ff ff       	call   801029dc <lapicinit>
  mpmain();
80103415:	e8 00 00 00 00       	call   8010341a <mpmain>

8010341a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010341a:	55                   	push   %ebp
8010341b:	89 e5                	mov    %esp,%ebp
8010341d:	53                   	push   %ebx
8010341e:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103421:	e8 78 05 00 00       	call   8010399e <cpuid>
80103426:	89 c3                	mov    %eax,%ebx
80103428:	e8 71 05 00 00       	call   8010399e <cpuid>
8010342d:	83 ec 04             	sub    $0x4,%esp
80103430:	53                   	push   %ebx
80103431:	50                   	push   %eax
80103432:	68 d5 a9 10 80       	push   $0x8010a9d5
80103437:	e8 b8 cf ff ff       	call   801003f4 <cprintf>
8010343c:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343f:	e8 1d 32 00 00       	call   80106661 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103444:	e8 70 05 00 00       	call   801039b9 <mycpu>
80103449:	05 a0 00 00 00       	add    $0xa0,%eax
8010344e:	83 ec 08             	sub    $0x8,%esp
80103451:	6a 01                	push   $0x1
80103453:	50                   	push   %eax
80103454:	e8 f3 fe ff ff       	call   8010334c <xchg>
80103459:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345c:	e8 2a 0d 00 00       	call   8010418b <scheduler>

80103461 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103461:	55                   	push   %ebp
80103462:	89 e5                	mov    %esp,%ebp
80103464:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103467:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103473:	83 ec 04             	sub    $0x4,%esp
80103476:	50                   	push   %eax
80103477:	68 38 f5 10 80       	push   $0x8010f538
8010347c:	ff 75 f0             	push   -0x10(%ebp)
8010347f:	e8 d7 19 00 00       	call   80104e5b <memmove>
80103484:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103487:	c7 45 f4 80 74 19 80 	movl   $0x80197480,-0xc(%ebp)
8010348e:	eb 79                	jmp    80103509 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103490:	e8 24 05 00 00       	call   801039b9 <mycpu>
80103495:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103498:	74 67                	je     80103501 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010349a:	e8 02 f3 ff ff       	call   801027a1 <kalloc>
8010349f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a5:	83 e8 04             	sub    $0x4,%eax
801034a8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034ab:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b1:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b6:	83 e8 08             	sub    $0x8,%eax
801034b9:	c7 00 00 34 10 80    	movl   $0x80103400,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034bf:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cd:	83 e8 0c             	sub    $0xc,%eax
801034d0:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034de:	0f b6 00             	movzbl (%eax),%eax
801034e1:	0f b6 c0             	movzbl %al,%eax
801034e4:	83 ec 08             	sub    $0x8,%esp
801034e7:	52                   	push   %edx
801034e8:	50                   	push   %eax
801034e9:	e8 50 f6 ff ff       	call   80102b3e <lapicstartap>
801034ee:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f1:	90                   	nop
801034f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f5:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fb:	85 c0                	test   %eax,%eax
801034fd:	74 f3                	je     801034f2 <startothers+0x91>
801034ff:	eb 01                	jmp    80103502 <startothers+0xa1>
      continue;
80103501:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103502:	81 45 f4 b4 00 00 00 	addl   $0xb4,-0xc(%ebp)
80103509:	a1 50 77 19 80       	mov    0x80197750,%eax
8010350e:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103514:	05 80 74 19 80       	add    $0x80197480,%eax
80103519:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351c:	0f 82 6e ff ff ff    	jb     80103490 <startothers+0x2f>
      ;
  }
}
80103522:	90                   	nop
80103523:	90                   	nop
80103524:	c9                   	leave  
80103525:	c3                   	ret    

80103526 <outb>:
{
80103526:	55                   	push   %ebp
80103527:	89 e5                	mov    %esp,%ebp
80103529:	83 ec 08             	sub    $0x8,%esp
8010352c:	8b 45 08             	mov    0x8(%ebp),%eax
8010352f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103532:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103536:	89 d0                	mov    %edx,%eax
80103538:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010353b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103543:	ee                   	out    %al,(%dx)
}
80103544:	90                   	nop
80103545:	c9                   	leave  
80103546:	c3                   	ret    

80103547 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103547:	55                   	push   %ebp
80103548:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010354a:	68 ff 00 00 00       	push   $0xff
8010354f:	6a 21                	push   $0x21
80103551:	e8 d0 ff ff ff       	call   80103526 <outb>
80103556:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103559:	68 ff 00 00 00       	push   $0xff
8010355e:	68 a1 00 00 00       	push   $0xa1
80103563:	e8 be ff ff ff       	call   80103526 <outb>
80103568:	83 c4 08             	add    $0x8,%esp
}
8010356b:	90                   	nop
8010356c:	c9                   	leave  
8010356d:	c3                   	ret    

8010356e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010356e:	55                   	push   %ebp
8010356f:	89 e5                	mov    %esp,%ebp
80103571:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103574:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010357b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103584:	8b 45 0c             	mov    0xc(%ebp),%eax
80103587:	8b 10                	mov    (%eax),%edx
80103589:	8b 45 08             	mov    0x8(%ebp),%eax
8010358c:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010358e:	e8 4b da ff ff       	call   80100fde <filealloc>
80103593:	8b 55 08             	mov    0x8(%ebp),%edx
80103596:	89 02                	mov    %eax,(%edx)
80103598:	8b 45 08             	mov    0x8(%ebp),%eax
8010359b:	8b 00                	mov    (%eax),%eax
8010359d:	85 c0                	test   %eax,%eax
8010359f:	0f 84 c8 00 00 00    	je     8010366d <pipealloc+0xff>
801035a5:	e8 34 da ff ff       	call   80100fde <filealloc>
801035aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ad:	89 02                	mov    %eax,(%edx)
801035af:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b2:	8b 00                	mov    (%eax),%eax
801035b4:	85 c0                	test   %eax,%eax
801035b6:	0f 84 b1 00 00 00    	je     8010366d <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035bc:	e8 e0 f1 ff ff       	call   801027a1 <kalloc>
801035c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c8:	0f 84 a2 00 00 00    	je     80103670 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d1:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d8:	00 00 00 
  p->writeopen = 1;
801035db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035de:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e5:	00 00 00 
  p->nwrite = 0;
801035e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035eb:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f2:	00 00 00 
  p->nread = 0;
801035f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f8:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035ff:	00 00 00 
  initlock(&p->lock, "pipe");
80103602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103605:	83 ec 08             	sub    $0x8,%esp
80103608:	68 e9 a9 10 80       	push   $0x8010a9e9
8010360d:	50                   	push   %eax
8010360e:	e8 f1 14 00 00       	call   80104b04 <initlock>
80103613:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103616:	8b 45 08             	mov    0x8(%ebp),%eax
80103619:	8b 00                	mov    (%eax),%eax
8010361b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103621:	8b 45 08             	mov    0x8(%ebp),%eax
80103624:	8b 00                	mov    (%eax),%eax
80103626:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010362a:	8b 45 08             	mov    0x8(%ebp),%eax
8010362d:	8b 00                	mov    (%eax),%eax
8010362f:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103633:	8b 45 08             	mov    0x8(%ebp),%eax
80103636:	8b 00                	mov    (%eax),%eax
80103638:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363b:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010363e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103641:	8b 00                	mov    (%eax),%eax
80103643:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103649:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364c:	8b 00                	mov    (%eax),%eax
8010364e:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103652:	8b 45 0c             	mov    0xc(%ebp),%eax
80103655:	8b 00                	mov    (%eax),%eax
80103657:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010365b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365e:	8b 00                	mov    (%eax),%eax
80103660:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103663:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103666:	b8 00 00 00 00       	mov    $0x0,%eax
8010366b:	eb 51                	jmp    801036be <pipealloc+0x150>
    goto bad;
8010366d:	90                   	nop
8010366e:	eb 01                	jmp    80103671 <pipealloc+0x103>
    goto bad;
80103670:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103671:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103675:	74 0e                	je     80103685 <pipealloc+0x117>
    kfree((char*)p);
80103677:	83 ec 0c             	sub    $0xc,%esp
8010367a:	ff 75 f4             	push   -0xc(%ebp)
8010367d:	e8 85 f0 ff ff       	call   80102707 <kfree>
80103682:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103685:	8b 45 08             	mov    0x8(%ebp),%eax
80103688:	8b 00                	mov    (%eax),%eax
8010368a:	85 c0                	test   %eax,%eax
8010368c:	74 11                	je     8010369f <pipealloc+0x131>
    fileclose(*f0);
8010368e:	8b 45 08             	mov    0x8(%ebp),%eax
80103691:	8b 00                	mov    (%eax),%eax
80103693:	83 ec 0c             	sub    $0xc,%esp
80103696:	50                   	push   %eax
80103697:	e8 00 da ff ff       	call   8010109c <fileclose>
8010369c:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369f:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a2:	8b 00                	mov    (%eax),%eax
801036a4:	85 c0                	test   %eax,%eax
801036a6:	74 11                	je     801036b9 <pipealloc+0x14b>
    fileclose(*f1);
801036a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801036ab:	8b 00                	mov    (%eax),%eax
801036ad:	83 ec 0c             	sub    $0xc,%esp
801036b0:	50                   	push   %eax
801036b1:	e8 e6 d9 ff ff       	call   8010109c <fileclose>
801036b6:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036be:	c9                   	leave  
801036bf:	c3                   	ret    

801036c0 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036c0:	55                   	push   %ebp
801036c1:	89 e5                	mov    %esp,%ebp
801036c3:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c6:	8b 45 08             	mov    0x8(%ebp),%eax
801036c9:	83 ec 0c             	sub    $0xc,%esp
801036cc:	50                   	push   %eax
801036cd:	e8 54 14 00 00       	call   80104b26 <acquire>
801036d2:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d9:	74 23                	je     801036fe <pipeclose+0x3e>
    p->writeopen = 0;
801036db:	8b 45 08             	mov    0x8(%ebp),%eax
801036de:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e5:	00 00 00 
    wakeup(&p->nread);
801036e8:	8b 45 08             	mov    0x8(%ebp),%eax
801036eb:	05 34 02 00 00       	add    $0x234,%eax
801036f0:	83 ec 0c             	sub    $0xc,%esp
801036f3:	50                   	push   %eax
801036f4:	e8 bd 10 00 00       	call   801047b6 <wakeup>
801036f9:	83 c4 10             	add    $0x10,%esp
801036fc:	eb 21                	jmp    8010371f <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103701:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103708:	00 00 00 
    wakeup(&p->nwrite);
8010370b:	8b 45 08             	mov    0x8(%ebp),%eax
8010370e:	05 38 02 00 00       	add    $0x238,%eax
80103713:	83 ec 0c             	sub    $0xc,%esp
80103716:	50                   	push   %eax
80103717:	e8 9a 10 00 00       	call   801047b6 <wakeup>
8010371c:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010371f:	8b 45 08             	mov    0x8(%ebp),%eax
80103722:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103728:	85 c0                	test   %eax,%eax
8010372a:	75 2c                	jne    80103758 <pipeclose+0x98>
8010372c:	8b 45 08             	mov    0x8(%ebp),%eax
8010372f:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103735:	85 c0                	test   %eax,%eax
80103737:	75 1f                	jne    80103758 <pipeclose+0x98>
    release(&p->lock);
80103739:	8b 45 08             	mov    0x8(%ebp),%eax
8010373c:	83 ec 0c             	sub    $0xc,%esp
8010373f:	50                   	push   %eax
80103740:	e8 4f 14 00 00       	call   80104b94 <release>
80103745:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103748:	83 ec 0c             	sub    $0xc,%esp
8010374b:	ff 75 08             	push   0x8(%ebp)
8010374e:	e8 b4 ef ff ff       	call   80102707 <kfree>
80103753:	83 c4 10             	add    $0x10,%esp
80103756:	eb 10                	jmp    80103768 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103758:	8b 45 08             	mov    0x8(%ebp),%eax
8010375b:	83 ec 0c             	sub    $0xc,%esp
8010375e:	50                   	push   %eax
8010375f:	e8 30 14 00 00       	call   80104b94 <release>
80103764:	83 c4 10             	add    $0x10,%esp
}
80103767:	90                   	nop
80103768:	90                   	nop
80103769:	c9                   	leave  
8010376a:	c3                   	ret    

8010376b <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010376b:	55                   	push   %ebp
8010376c:	89 e5                	mov    %esp,%ebp
8010376e:	53                   	push   %ebx
8010376f:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103772:	8b 45 08             	mov    0x8(%ebp),%eax
80103775:	83 ec 0c             	sub    $0xc,%esp
80103778:	50                   	push   %eax
80103779:	e8 a8 13 00 00       	call   80104b26 <acquire>
8010377e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103781:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103788:	e9 ad 00 00 00       	jmp    8010383a <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010378d:	8b 45 08             	mov    0x8(%ebp),%eax
80103790:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103796:	85 c0                	test   %eax,%eax
80103798:	74 0c                	je     801037a6 <pipewrite+0x3b>
8010379a:	e8 92 02 00 00       	call   80103a31 <myproc>
8010379f:	8b 40 24             	mov    0x24(%eax),%eax
801037a2:	85 c0                	test   %eax,%eax
801037a4:	74 19                	je     801037bf <pipewrite+0x54>
        release(&p->lock);
801037a6:	8b 45 08             	mov    0x8(%ebp),%eax
801037a9:	83 ec 0c             	sub    $0xc,%esp
801037ac:	50                   	push   %eax
801037ad:	e8 e2 13 00 00       	call   80104b94 <release>
801037b2:	83 c4 10             	add    $0x10,%esp
        return -1;
801037b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037ba:	e9 a9 00 00 00       	jmp    80103868 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037bf:	8b 45 08             	mov    0x8(%ebp),%eax
801037c2:	05 34 02 00 00       	add    $0x234,%eax
801037c7:	83 ec 0c             	sub    $0xc,%esp
801037ca:	50                   	push   %eax
801037cb:	e8 e6 0f 00 00       	call   801047b6 <wakeup>
801037d0:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d3:	8b 45 08             	mov    0x8(%ebp),%eax
801037d6:	8b 55 08             	mov    0x8(%ebp),%edx
801037d9:	81 c2 38 02 00 00    	add    $0x238,%edx
801037df:	83 ec 08             	sub    $0x8,%esp
801037e2:	50                   	push   %eax
801037e3:	52                   	push   %edx
801037e4:	e8 e3 0e 00 00       	call   801046cc <sleep>
801037e9:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037ec:	8b 45 08             	mov    0x8(%ebp),%eax
801037ef:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f5:	8b 45 08             	mov    0x8(%ebp),%eax
801037f8:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fe:	05 00 02 00 00       	add    $0x200,%eax
80103803:	39 c2                	cmp    %eax,%edx
80103805:	74 86                	je     8010378d <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103807:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010380a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103810:	8b 45 08             	mov    0x8(%ebp),%eax
80103813:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103819:	8d 48 01             	lea    0x1(%eax),%ecx
8010381c:	8b 55 08             	mov    0x8(%ebp),%edx
8010381f:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103825:	25 ff 01 00 00       	and    $0x1ff,%eax
8010382a:	89 c1                	mov    %eax,%ecx
8010382c:	0f b6 13             	movzbl (%ebx),%edx
8010382f:	8b 45 08             	mov    0x8(%ebp),%eax
80103832:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103836:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010383a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383d:	3b 45 10             	cmp    0x10(%ebp),%eax
80103840:	7c aa                	jl     801037ec <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103842:	8b 45 08             	mov    0x8(%ebp),%eax
80103845:	05 34 02 00 00       	add    $0x234,%eax
8010384a:	83 ec 0c             	sub    $0xc,%esp
8010384d:	50                   	push   %eax
8010384e:	e8 63 0f 00 00       	call   801047b6 <wakeup>
80103853:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103856:	8b 45 08             	mov    0x8(%ebp),%eax
80103859:	83 ec 0c             	sub    $0xc,%esp
8010385c:	50                   	push   %eax
8010385d:	e8 32 13 00 00       	call   80104b94 <release>
80103862:	83 c4 10             	add    $0x10,%esp
  return n;
80103865:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103868:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386b:	c9                   	leave  
8010386c:	c3                   	ret    

8010386d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010386d:	55                   	push   %ebp
8010386e:	89 e5                	mov    %esp,%ebp
80103870:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103873:	8b 45 08             	mov    0x8(%ebp),%eax
80103876:	83 ec 0c             	sub    $0xc,%esp
80103879:	50                   	push   %eax
8010387a:	e8 a7 12 00 00       	call   80104b26 <acquire>
8010387f:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103882:	eb 3e                	jmp    801038c2 <piperead+0x55>
    if(myproc()->killed){
80103884:	e8 a8 01 00 00       	call   80103a31 <myproc>
80103889:	8b 40 24             	mov    0x24(%eax),%eax
8010388c:	85 c0                	test   %eax,%eax
8010388e:	74 19                	je     801038a9 <piperead+0x3c>
      release(&p->lock);
80103890:	8b 45 08             	mov    0x8(%ebp),%eax
80103893:	83 ec 0c             	sub    $0xc,%esp
80103896:	50                   	push   %eax
80103897:	e8 f8 12 00 00       	call   80104b94 <release>
8010389c:	83 c4 10             	add    $0x10,%esp
      return -1;
8010389f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a4:	e9 be 00 00 00       	jmp    80103967 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a9:	8b 45 08             	mov    0x8(%ebp),%eax
801038ac:	8b 55 08             	mov    0x8(%ebp),%edx
801038af:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b5:	83 ec 08             	sub    $0x8,%esp
801038b8:	50                   	push   %eax
801038b9:	52                   	push   %edx
801038ba:	e8 0d 0e 00 00       	call   801046cc <sleep>
801038bf:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c2:	8b 45 08             	mov    0x8(%ebp),%eax
801038c5:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038cb:	8b 45 08             	mov    0x8(%ebp),%eax
801038ce:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d4:	39 c2                	cmp    %eax,%edx
801038d6:	75 0d                	jne    801038e5 <piperead+0x78>
801038d8:	8b 45 08             	mov    0x8(%ebp),%eax
801038db:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e1:	85 c0                	test   %eax,%eax
801038e3:	75 9f                	jne    80103884 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038ec:	eb 48                	jmp    80103936 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038ee:	8b 45 08             	mov    0x8(%ebp),%eax
801038f1:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f7:	8b 45 08             	mov    0x8(%ebp),%eax
801038fa:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103900:	39 c2                	cmp    %eax,%edx
80103902:	74 3c                	je     80103940 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103904:	8b 45 08             	mov    0x8(%ebp),%eax
80103907:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390d:	8d 48 01             	lea    0x1(%eax),%ecx
80103910:	8b 55 08             	mov    0x8(%ebp),%edx
80103913:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103919:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391e:	89 c1                	mov    %eax,%ecx
80103920:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103923:	8b 45 0c             	mov    0xc(%ebp),%eax
80103926:	01 c2                	add    %eax,%edx
80103928:	8b 45 08             	mov    0x8(%ebp),%eax
8010392b:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103930:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103932:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103939:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393c:	7c b0                	jl     801038ee <piperead+0x81>
8010393e:	eb 01                	jmp    80103941 <piperead+0xd4>
      break;
80103940:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103941:	8b 45 08             	mov    0x8(%ebp),%eax
80103944:	05 38 02 00 00       	add    $0x238,%eax
80103949:	83 ec 0c             	sub    $0xc,%esp
8010394c:	50                   	push   %eax
8010394d:	e8 64 0e 00 00       	call   801047b6 <wakeup>
80103952:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103955:	8b 45 08             	mov    0x8(%ebp),%eax
80103958:	83 ec 0c             	sub    $0xc,%esp
8010395b:	50                   	push   %eax
8010395c:	e8 33 12 00 00       	call   80104b94 <release>
80103961:	83 c4 10             	add    $0x10,%esp
  return i;
80103964:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103967:	c9                   	leave  
80103968:	c3                   	ret    

80103969 <readeflags>:
{
80103969:	55                   	push   %ebp
8010396a:	89 e5                	mov    %esp,%ebp
8010396c:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396f:	9c                   	pushf  
80103970:	58                   	pop    %eax
80103971:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103974:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103977:	c9                   	leave  
80103978:	c3                   	ret    

80103979 <sti>:
{
80103979:	55                   	push   %ebp
8010397a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010397c:	fb                   	sti    
}
8010397d:	90                   	nop
8010397e:	5d                   	pop    %ebp
8010397f:	c3                   	ret    

80103980 <pinit>:
extern void trapret(void);

static void wakeup1(void *chan);

void pinit(void)
{
80103980:	55                   	push   %ebp
80103981:	89 e5                	mov    %esp,%ebp
80103983:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103986:	83 ec 08             	sub    $0x8,%esp
80103989:	68 f0 a9 10 80       	push   $0x8010a9f0
8010398e:	68 00 4b 19 80       	push   $0x80194b00
80103993:	e8 6c 11 00 00       	call   80104b04 <initlock>
80103998:	83 c4 10             	add    $0x10,%esp
}
8010399b:	90                   	nop
8010399c:	c9                   	leave  
8010399d:	c3                   	ret    

8010399e <cpuid>:

// Must be called with interrupts disabled
int cpuid()
{
8010399e:	55                   	push   %ebp
8010399f:	89 e5                	mov    %esp,%ebp
801039a1:	83 ec 08             	sub    $0x8,%esp
  return mycpu() - cpus;
801039a4:	e8 10 00 00 00       	call   801039b9 <mycpu>
801039a9:	2d 80 74 19 80       	sub    $0x80197480,%eax
801039ae:	c1 f8 02             	sar    $0x2,%eax
801039b1:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
}
801039b7:	c9                   	leave  
801039b8:	c3                   	ret    

801039b9 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu *
mycpu(void)
{
801039b9:	55                   	push   %ebp
801039ba:	89 e5                	mov    %esp,%ebp
801039bc:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;

  if (readeflags() & FL_IF)
801039bf:	e8 a5 ff ff ff       	call   80103969 <readeflags>
801039c4:	25 00 02 00 00       	and    $0x200,%eax
801039c9:	85 c0                	test   %eax,%eax
801039cb:	74 0d                	je     801039da <mycpu+0x21>
  {
    panic("mycpu called with interrupts enabled\n");
801039cd:	83 ec 0c             	sub    $0xc,%esp
801039d0:	68 f8 a9 10 80       	push   $0x8010a9f8
801039d5:	e8 cf cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039da:	e8 1c f1 ff ff       	call   80102afb <lapicid>
801039df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i)
801039e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e9:	eb 2d                	jmp    80103a18 <mycpu+0x5f>
  {
    if (cpus[i].apicid == apicid)
801039eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ee:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801039f4:	05 80 74 19 80       	add    $0x80197480,%eax
801039f9:	0f b6 00             	movzbl (%eax),%eax
801039fc:	0f b6 c0             	movzbl %al,%eax
801039ff:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a02:	75 10                	jne    80103a14 <mycpu+0x5b>
    {
      return &cpus[i];
80103a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a07:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103a0d:	05 80 74 19 80       	add    $0x80197480,%eax
80103a12:	eb 1b                	jmp    80103a2f <mycpu+0x76>
  for (i = 0; i < ncpu; ++i)
80103a14:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a18:	a1 50 77 19 80       	mov    0x80197750,%eax
80103a1d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a20:	7c c9                	jl     801039eb <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a22:	83 ec 0c             	sub    $0xc,%esp
80103a25:	68 1e aa 10 80       	push   $0x8010aa1e
80103a2a:	e8 7a cb ff ff       	call   801005a9 <panic>
}
80103a2f:	c9                   	leave  
80103a30:	c3                   	ret    

80103a31 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc *
myproc(void)
{
80103a31:	55                   	push   %ebp
80103a32:	89 e5                	mov    %esp,%ebp
80103a34:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a37:	e8 55 12 00 00       	call   80104c91 <pushcli>
  c = mycpu();
80103a3c:	e8 78 ff ff ff       	call   801039b9 <mycpu>
80103a41:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a47:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a50:	e8 89 12 00 00       	call   80104cde <popcli>
  return p;
80103a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a58:	c9                   	leave  
80103a59:	c3                   	ret    

80103a5a <allocproc>:
//  If found, change state to EMBRYO and initialize
//  state required to run in the kernel.
//  Otherwise return 0.
static struct proc *
allocproc(void)
{
80103a5a:	55                   	push   %ebp
80103a5b:	89 e5                	mov    %esp,%ebp
80103a5d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a60:	83 ec 0c             	sub    $0xc,%esp
80103a63:	68 00 4b 19 80       	push   $0x80194b00
80103a68:	e8 b9 10 00 00       	call   80104b26 <acquire>
80103a6d:	83 c4 10             	add    $0x10,%esp

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a70:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
80103a77:	eb 11                	jmp    80103a8a <allocproc+0x30>
    if (p->state == UNUSED)
80103a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7c:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7f:	85 c0                	test   %eax,%eax
80103a81:	74 2a                	je     80103aad <allocproc+0x53>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a83:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80103a8a:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
80103a91:	72 e6                	jb     80103a79 <allocproc+0x1f>
    {
      goto found;
    }

  release(&ptable.lock);
80103a93:	83 ec 0c             	sub    $0xc,%esp
80103a96:	68 00 4b 19 80       	push   $0x80194b00
80103a9b:	e8 f4 10 00 00       	call   80104b94 <release>
80103aa0:	83 c4 10             	add    $0x10,%esp
  return 0;
80103aa3:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa8:	e9 0a 01 00 00       	jmp    80103bb7 <allocproc+0x15d>
      goto found;
80103aad:	90                   	nop

found:
  p->state = EMBRYO;
80103aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab1:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab8:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103abd:	8d 50 01             	lea    0x1(%eax),%edx
80103ac0:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac9:	89 42 10             	mov    %eax,0x10(%edx)

  int idx = p - ptable.proc; // 해당 프로세스의 인덱스 계산
80103acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103acf:	2d 34 4b 19 80       	sub    $0x80194b34,%eax
80103ad4:	c1 f8 02             	sar    $0x2,%eax
80103ad7:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
80103add:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // MLFQ 전역 배열 초기화
  proc_priority[idx] = 3; // Q3가 가장 높은 우선순위
80103ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ae3:	c7 04 85 00 42 19 80 	movl   $0x3,-0x7fe6be00(,%eax,4)
80103aea:	03 00 00 00 
  memset(proc_ticks[idx], 0, sizeof(proc_ticks[idx]));
80103aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103af1:	c1 e0 04             	shl    $0x4,%eax
80103af4:	05 00 43 19 80       	add    $0x80194300,%eax
80103af9:	83 ec 04             	sub    $0x4,%esp
80103afc:	6a 10                	push   $0x10
80103afe:	6a 00                	push   $0x0
80103b00:	50                   	push   %eax
80103b01:	e8 96 12 00 00       	call   80104d9c <memset>
80103b06:	83 c4 10             	add    $0x10,%esp
  memset(proc_wait_ticks[idx], 0, sizeof(proc_wait_ticks[idx]));
80103b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b0c:	c1 e0 04             	shl    $0x4,%eax
80103b0f:	05 00 47 19 80       	add    $0x80194700,%eax
80103b14:	83 ec 04             	sub    $0x4,%esp
80103b17:	6a 10                	push   $0x10
80103b19:	6a 00                	push   $0x0
80103b1b:	50                   	push   %eax
80103b1c:	e8 7b 12 00 00       	call   80104d9c <memset>
80103b21:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103b24:	83 ec 0c             	sub    $0xc,%esp
80103b27:	68 00 4b 19 80       	push   $0x80194b00
80103b2c:	e8 63 10 00 00       	call   80104b94 <release>
80103b31:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if ((p->kstack = kalloc()) == 0)
80103b34:	e8 68 ec ff ff       	call   801027a1 <kalloc>
80103b39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b3c:	89 42 08             	mov    %eax,0x8(%edx)
80103b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b42:	8b 40 08             	mov    0x8(%eax),%eax
80103b45:	85 c0                	test   %eax,%eax
80103b47:	75 11                	jne    80103b5a <allocproc+0x100>
  {
    p->state = UNUSED;
80103b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103b53:	b8 00 00 00 00       	mov    $0x0,%eax
80103b58:	eb 5d                	jmp    80103bb7 <allocproc+0x15d>
  }
  sp = p->kstack + KSTACKSIZE;
80103b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b5d:	8b 40 08             	mov    0x8(%eax),%eax
80103b60:	05 00 10 00 00       	add    $0x1000,%eax
80103b65:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b68:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe *)sp;
80103b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b72:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b75:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint *)sp = (uint)trapret;
80103b79:	ba a5 64 10 80       	mov    $0x801064a5,%edx
80103b7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b81:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b83:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context *)sp;
80103b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b8d:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b93:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b96:	83 ec 04             	sub    $0x4,%esp
80103b99:	6a 14                	push   $0x14
80103b9b:	6a 00                	push   $0x0
80103b9d:	50                   	push   %eax
80103b9e:	e8 f9 11 00 00       	call   80104d9c <memset>
80103ba3:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba9:	8b 40 1c             	mov    0x1c(%eax),%eax
80103bac:	ba 86 46 10 80       	mov    $0x80104686,%edx
80103bb1:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103bb7:	c9                   	leave  
80103bb8:	c3                   	ret    

80103bb9 <userinit>:

// PAGEBREAK: 32
//  Set up first user process.
void userinit(void)
{
80103bb9:	55                   	push   %ebp
80103bba:	89 e5                	mov    %esp,%ebp
80103bbc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103bbf:	e8 96 fe ff ff       	call   80103a5a <allocproc>
80103bc4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  initproc = p;
80103bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bca:	a3 34 6c 19 80       	mov    %eax,0x80196c34
  if ((p->pgdir = setupkvm()) == 0)
80103bcf:	e8 7c 3e 00 00       	call   80107a50 <setupkvm>
80103bd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bd7:	89 42 04             	mov    %eax,0x4(%edx)
80103bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bdd:	8b 40 04             	mov    0x4(%eax),%eax
80103be0:	85 c0                	test   %eax,%eax
80103be2:	75 0d                	jne    80103bf1 <userinit+0x38>
  {
    panic("userinit: out of memory?");
80103be4:	83 ec 0c             	sub    $0xc,%esp
80103be7:	68 2e aa 10 80       	push   $0x8010aa2e
80103bec:	e8 b8 c9 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103bf1:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf9:	8b 40 04             	mov    0x4(%eax),%eax
80103bfc:	83 ec 04             	sub    $0x4,%esp
80103bff:	52                   	push   %edx
80103c00:	68 0c f5 10 80       	push   $0x8010f50c
80103c05:	50                   	push   %eax
80103c06:	e8 01 41 00 00       	call   80107d0c <inituvm>
80103c0b:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c11:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1a:	8b 40 18             	mov    0x18(%eax),%eax
80103c1d:	83 ec 04             	sub    $0x4,%esp
80103c20:	6a 4c                	push   $0x4c
80103c22:	6a 00                	push   $0x0
80103c24:	50                   	push   %eax
80103c25:	e8 72 11 00 00       	call   80104d9c <memset>
80103c2a:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c30:	8b 40 18             	mov    0x18(%eax),%eax
80103c33:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3c:	8b 40 18             	mov    0x18(%eax),%eax
80103c3f:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c48:	8b 50 18             	mov    0x18(%eax),%edx
80103c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c4e:	8b 40 18             	mov    0x18(%eax),%eax
80103c51:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c55:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5c:	8b 50 18             	mov    0x18(%eax),%edx
80103c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c62:	8b 40 18             	mov    0x18(%eax),%eax
80103c65:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c69:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c70:	8b 40 18             	mov    0x18(%eax),%eax
80103c73:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7d:	8b 40 18             	mov    0x18(%eax),%eax
80103c80:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0; // beginning of initcode.S
80103c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8a:	8b 40 18             	mov    0x18(%eax),%eax
80103c8d:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c97:	83 c0 6c             	add    $0x6c,%eax
80103c9a:	83 ec 04             	sub    $0x4,%esp
80103c9d:	6a 10                	push   $0x10
80103c9f:	68 47 aa 10 80       	push   $0x8010aa47
80103ca4:	50                   	push   %eax
80103ca5:	e8 f5 12 00 00       	call   80104f9f <safestrcpy>
80103caa:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103cad:	83 ec 0c             	sub    $0xc,%esp
80103cb0:	68 50 aa 10 80       	push   $0x8010aa50
80103cb5:	e8 64 e8 ff ff       	call   8010251e <namei>
80103cba:	83 c4 10             	add    $0x10,%esp
80103cbd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cc0:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103cc3:	83 ec 0c             	sub    $0xc,%esp
80103cc6:	68 00 4b 19 80       	push   $0x80194b00
80103ccb:	e8 56 0e 00 00       	call   80104b26 <acquire>
80103cd0:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103cdd:	83 ec 0c             	sub    $0xc,%esp
80103ce0:	68 00 4b 19 80       	push   $0x80194b00
80103ce5:	e8 aa 0e 00 00       	call   80104b94 <release>
80103cea:	83 c4 10             	add    $0x10,%esp
}
80103ced:	90                   	nop
80103cee:	c9                   	leave  
80103cef:	c3                   	ret    

80103cf0 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int growproc(int n)
{
80103cf0:	55                   	push   %ebp
80103cf1:	89 e5                	mov    %esp,%ebp
80103cf3:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103cf6:	e8 36 fd ff ff       	call   80103a31 <myproc>
80103cfb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d01:	8b 00                	mov    (%eax),%eax
80103d03:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (n > 0)
80103d06:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d0a:	7e 2e                	jle    80103d3a <growproc+0x4a>
  {
    if ((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d0c:	8b 55 08             	mov    0x8(%ebp),%edx
80103d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d12:	01 c2                	add    %eax,%edx
80103d14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d17:	8b 40 04             	mov    0x4(%eax),%eax
80103d1a:	83 ec 04             	sub    $0x4,%esp
80103d1d:	52                   	push   %edx
80103d1e:	ff 75 f4             	push   -0xc(%ebp)
80103d21:	50                   	push   %eax
80103d22:	e8 22 41 00 00       	call   80107e49 <allocuvm>
80103d27:	83 c4 10             	add    $0x10,%esp
80103d2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d2d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d31:	75 3b                	jne    80103d6e <growproc+0x7e>
      return -1;
80103d33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d38:	eb 4f                	jmp    80103d89 <growproc+0x99>
  }
  else if (n < 0)
80103d3a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d3e:	79 2e                	jns    80103d6e <growproc+0x7e>
  {
    if ((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d40:	8b 55 08             	mov    0x8(%ebp),%edx
80103d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d46:	01 c2                	add    %eax,%edx
80103d48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d4b:	8b 40 04             	mov    0x4(%eax),%eax
80103d4e:	83 ec 04             	sub    $0x4,%esp
80103d51:	52                   	push   %edx
80103d52:	ff 75 f4             	push   -0xc(%ebp)
80103d55:	50                   	push   %eax
80103d56:	e8 f3 41 00 00       	call   80107f4e <deallocuvm>
80103d5b:	83 c4 10             	add    $0x10,%esp
80103d5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d65:	75 07                	jne    80103d6e <growproc+0x7e>
      return -1;
80103d67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d6c:	eb 1b                	jmp    80103d89 <growproc+0x99>
  }
  curproc->sz = sz;
80103d6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d71:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d74:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d76:	83 ec 0c             	sub    $0xc,%esp
80103d79:	ff 75 f0             	push   -0x10(%ebp)
80103d7c:	e8 ec 3d 00 00       	call   80107b6d <switchuvm>
80103d81:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d84:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d89:	c9                   	leave  
80103d8a:	c3                   	ret    

80103d8b <fork>:

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int fork(void)
{
80103d8b:	55                   	push   %ebp
80103d8c:	89 e5                	mov    %esp,%ebp
80103d8e:	57                   	push   %edi
80103d8f:	56                   	push   %esi
80103d90:	53                   	push   %ebx
80103d91:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d94:	e8 98 fc ff ff       	call   80103a31 <myproc>
80103d99:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if ((np = allocproc()) == 0)
80103d9c:	e8 b9 fc ff ff       	call   80103a5a <allocproc>
80103da1:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103da4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103da8:	75 0a                	jne    80103db4 <fork+0x29>
  {
    return -1;
80103daa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103daf:	e9 48 01 00 00       	jmp    80103efc <fork+0x171>
  }

  // Copy process state from proc.
  if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0)
80103db4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db7:	8b 10                	mov    (%eax),%edx
80103db9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dbc:	8b 40 04             	mov    0x4(%eax),%eax
80103dbf:	83 ec 08             	sub    $0x8,%esp
80103dc2:	52                   	push   %edx
80103dc3:	50                   	push   %eax
80103dc4:	e8 23 43 00 00       	call   801080ec <copyuvm>
80103dc9:	83 c4 10             	add    $0x10,%esp
80103dcc:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103dcf:	89 42 04             	mov    %eax,0x4(%edx)
80103dd2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dd5:	8b 40 04             	mov    0x4(%eax),%eax
80103dd8:	85 c0                	test   %eax,%eax
80103dda:	75 30                	jne    80103e0c <fork+0x81>
  {
    kfree(np->kstack);
80103ddc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ddf:	8b 40 08             	mov    0x8(%eax),%eax
80103de2:	83 ec 0c             	sub    $0xc,%esp
80103de5:	50                   	push   %eax
80103de6:	e8 1c e9 ff ff       	call   80102707 <kfree>
80103deb:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103dee:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103df1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103df8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dfb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103e02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e07:	e9 f0 00 00 00       	jmp    80103efc <fork+0x171>
  }
  np->sz = curproc->sz;
80103e0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e0f:	8b 10                	mov    (%eax),%edx
80103e11:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e14:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103e16:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e19:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103e1c:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103e1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e22:	8b 48 18             	mov    0x18(%eax),%ecx
80103e25:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e28:	8b 40 18             	mov    0x18(%eax),%eax
80103e2b:	89 c2                	mov    %eax,%edx
80103e2d:	89 cb                	mov    %ecx,%ebx
80103e2f:	b8 13 00 00 00       	mov    $0x13,%eax
80103e34:	89 d7                	mov    %edx,%edi
80103e36:	89 de                	mov    %ebx,%esi
80103e38:	89 c1                	mov    %eax,%ecx
80103e3a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103e3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e3f:	8b 40 18             	mov    0x18(%eax),%eax
80103e42:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for (i = 0; i < NOFILE; i++)
80103e49:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103e50:	eb 3b                	jmp    80103e8d <fork+0x102>
    if (curproc->ofile[i])
80103e52:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e55:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e58:	83 c2 08             	add    $0x8,%edx
80103e5b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e5f:	85 c0                	test   %eax,%eax
80103e61:	74 26                	je     80103e89 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e63:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e66:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e69:	83 c2 08             	add    $0x8,%edx
80103e6c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e70:	83 ec 0c             	sub    $0xc,%esp
80103e73:	50                   	push   %eax
80103e74:	e8 d2 d1 ff ff       	call   8010104b <filedup>
80103e79:	83 c4 10             	add    $0x10,%esp
80103e7c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e7f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e82:	83 c1 08             	add    $0x8,%ecx
80103e85:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for (i = 0; i < NOFILE; i++)
80103e89:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e8d:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e91:	7e bf                	jle    80103e52 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e93:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e96:	8b 40 68             	mov    0x68(%eax),%eax
80103e99:	83 ec 0c             	sub    $0xc,%esp
80103e9c:	50                   	push   %eax
80103e9d:	e8 0f db ff ff       	call   801019b1 <idup>
80103ea2:	83 c4 10             	add    $0x10,%esp
80103ea5:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103ea8:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103eab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103eae:	8d 50 6c             	lea    0x6c(%eax),%edx
80103eb1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103eb4:	83 c0 6c             	add    $0x6c,%eax
80103eb7:	83 ec 04             	sub    $0x4,%esp
80103eba:	6a 10                	push   $0x10
80103ebc:	52                   	push   %edx
80103ebd:	50                   	push   %eax
80103ebe:	e8 dc 10 00 00       	call   80104f9f <safestrcpy>
80103ec3:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103ec6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ec9:	8b 40 10             	mov    0x10(%eax),%eax
80103ecc:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103ecf:	83 ec 0c             	sub    $0xc,%esp
80103ed2:	68 00 4b 19 80       	push   $0x80194b00
80103ed7:	e8 4a 0c 00 00       	call   80104b26 <acquire>
80103edc:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103edf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ee2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103ee9:	83 ec 0c             	sub    $0xc,%esp
80103eec:	68 00 4b 19 80       	push   $0x80194b00
80103ef1:	e8 9e 0c 00 00       	call   80104b94 <release>
80103ef6:	83 c4 10             	add    $0x10,%esp

  return pid;
80103ef9:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103efc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103eff:	5b                   	pop    %ebx
80103f00:	5e                   	pop    %esi
80103f01:	5f                   	pop    %edi
80103f02:	5d                   	pop    %ebp
80103f03:	c3                   	ret    

80103f04 <exit>:
//이거이거 살짝
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void exit(void)
{
80103f04:	55                   	push   %ebp
80103f05:	89 e5                	mov    %esp,%ebp
80103f07:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103f0a:	e8 22 fb ff ff       	call   80103a31 <myproc>
80103f0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if (curproc == initproc)
80103f12:	a1 34 6c 19 80       	mov    0x80196c34,%eax
80103f17:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f1a:	75 0d                	jne    80103f29 <exit+0x25>
    panic("init exiting");
80103f1c:	83 ec 0c             	sub    $0xc,%esp
80103f1f:	68 52 aa 10 80       	push   $0x8010aa52
80103f24:	e8 80 c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for (fd = 0; fd < NOFILE; fd++)
80103f29:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103f30:	eb 3f                	jmp    80103f71 <exit+0x6d>
  {
    if (curproc->ofile[fd])
80103f32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f35:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f38:	83 c2 08             	add    $0x8,%edx
80103f3b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f3f:	85 c0                	test   %eax,%eax
80103f41:	74 2a                	je     80103f6d <exit+0x69>
    {
      fileclose(curproc->ofile[fd]);
80103f43:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f46:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f49:	83 c2 08             	add    $0x8,%edx
80103f4c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f50:	83 ec 0c             	sub    $0xc,%esp
80103f53:	50                   	push   %eax
80103f54:	e8 43 d1 ff ff       	call   8010109c <fileclose>
80103f59:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f5f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f62:	83 c2 08             	add    $0x8,%edx
80103f65:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f6c:	00 
  for (fd = 0; fd < NOFILE; fd++)
80103f6d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f71:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f75:	7e bb                	jle    80103f32 <exit+0x2e>
    }
  }

  begin_op();
80103f77:	e8 c1 f0 ff ff       	call   8010303d <begin_op>
  iput(curproc->cwd);
80103f7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f7f:	8b 40 68             	mov    0x68(%eax),%eax
80103f82:	83 ec 0c             	sub    $0xc,%esp
80103f85:	50                   	push   %eax
80103f86:	e8 c1 db ff ff       	call   80101b4c <iput>
80103f8b:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f8e:	e8 36 f1 ff ff       	call   801030c9 <end_op>
  curproc->cwd = 0;
80103f93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f96:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f9d:	83 ec 0c             	sub    $0xc,%esp
80103fa0:	68 00 4b 19 80       	push   $0x80194b00
80103fa5:	e8 7c 0b 00 00       	call   80104b26 <acquire>
80103faa:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103fad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fb0:	8b 40 14             	mov    0x14(%eax),%eax
80103fb3:	83 ec 0c             	sub    $0xc,%esp
80103fb6:	50                   	push   %eax
80103fb7:	e8 b7 07 00 00       	call   80104773 <wakeup1>
80103fbc:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103fbf:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
80103fc6:	eb 3a                	jmp    80104002 <exit+0xfe>
  {
    if (p->parent == curproc)
80103fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fcb:	8b 40 14             	mov    0x14(%eax),%eax
80103fce:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103fd1:	75 28                	jne    80103ffb <exit+0xf7>
    {
      p->parent = initproc;
80103fd3:	8b 15 34 6c 19 80    	mov    0x80196c34,%edx
80103fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fdc:	89 50 14             	mov    %edx,0x14(%eax)
      if (p->state == ZOMBIE)
80103fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe2:	8b 40 0c             	mov    0xc(%eax),%eax
80103fe5:	83 f8 05             	cmp    $0x5,%eax
80103fe8:	75 11                	jne    80103ffb <exit+0xf7>
        wakeup1(initproc);
80103fea:	a1 34 6c 19 80       	mov    0x80196c34,%eax
80103fef:	83 ec 0c             	sub    $0xc,%esp
80103ff2:	50                   	push   %eax
80103ff3:	e8 7b 07 00 00       	call   80104773 <wakeup1>
80103ff8:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103ffb:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104002:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
80104009:	72 bd                	jb     80103fc8 <exit+0xc4>
    }
  }

  int idx = myproc() - ptable.proc;
8010400b:	e8 21 fa ff ff       	call   80103a31 <myproc>
80104010:	2d 34 4b 19 80       	sub    $0x80194b34,%eax
80104015:	c1 f8 02             	sar    $0x2,%eax
80104018:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
8010401e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  proc_ticks[idx][proc_priority[idx]]++;
80104021:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104024:	8b 0c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ecx
8010402b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010402e:	c1 e0 02             	shl    $0x2,%eax
80104031:	01 c8                	add    %ecx,%eax
80104033:	8b 04 85 00 43 19 80 	mov    -0x7fe6bd00(,%eax,4),%eax
8010403a:	8d 50 01             	lea    0x1(%eax),%edx
8010403d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104040:	c1 e0 02             	shl    $0x2,%eax
80104043:	01 c8                	add    %ecx,%eax
80104045:	89 14 85 00 43 19 80 	mov    %edx,-0x7fe6bd00(,%eax,4)

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010404c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010404f:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104056:	e8 f7 04 00 00       	call   80104552 <sched>
  panic("zombie exit");
8010405b:	83 ec 0c             	sub    $0xc,%esp
8010405e:	68 5f aa 10 80       	push   $0x8010aa5f
80104063:	e8 41 c5 ff ff       	call   801005a9 <panic>

80104068 <wait>:
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int wait(void)
{
80104068:	55                   	push   %ebp
80104069:	89 e5                	mov    %esp,%ebp
8010406b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010406e:	e8 be f9 ff ff       	call   80103a31 <myproc>
80104073:	89 45 ec             	mov    %eax,-0x14(%ebp)

  acquire(&ptable.lock);
80104076:	83 ec 0c             	sub    $0xc,%esp
80104079:	68 00 4b 19 80       	push   $0x80194b00
8010407e:	e8 a3 0a 00 00       	call   80104b26 <acquire>
80104083:	83 c4 10             	add    $0x10,%esp
  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
80104086:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010408d:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
80104094:	e9 a4 00 00 00       	jmp    8010413d <wait+0xd5>
    {
      if (p->parent != curproc)
80104099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409c:	8b 40 14             	mov    0x14(%eax),%eax
8010409f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801040a2:	0f 85 8d 00 00 00    	jne    80104135 <wait+0xcd>
        continue;
      havekids = 1;
801040a8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if (p->state == ZOMBIE)
801040af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b2:	8b 40 0c             	mov    0xc(%eax),%eax
801040b5:	83 f8 05             	cmp    $0x5,%eax
801040b8:	75 7c                	jne    80104136 <wait+0xce>
      {
        // Found one.
        pid = p->pid;
801040ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040bd:	8b 40 10             	mov    0x10(%eax),%eax
801040c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801040c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c6:	8b 40 08             	mov    0x8(%eax),%eax
801040c9:	83 ec 0c             	sub    $0xc,%esp
801040cc:	50                   	push   %eax
801040cd:	e8 35 e6 ff ff       	call   80102707 <kfree>
801040d2:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801040d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801040df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e2:	8b 40 04             	mov    0x4(%eax),%eax
801040e5:	83 ec 0c             	sub    $0xc,%esp
801040e8:	50                   	push   %eax
801040e9:	e8 24 3f 00 00       	call   80108012 <freevm>
801040ee:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801040f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f4:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801040fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040fe:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104108:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010410c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010410f:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104119:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104120:	83 ec 0c             	sub    $0xc,%esp
80104123:	68 00 4b 19 80       	push   $0x80194b00
80104128:	e8 67 0a 00 00       	call   80104b94 <release>
8010412d:	83 c4 10             	add    $0x10,%esp
        return pid;
80104130:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104133:	eb 54                	jmp    80104189 <wait+0x121>
        continue;
80104135:	90                   	nop
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104136:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010413d:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
80104144:	0f 82 4f ff ff ff    	jb     80104099 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if (!havekids || curproc->killed)
8010414a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010414e:	74 0a                	je     8010415a <wait+0xf2>
80104150:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104153:	8b 40 24             	mov    0x24(%eax),%eax
80104156:	85 c0                	test   %eax,%eax
80104158:	74 17                	je     80104171 <wait+0x109>
    {
      release(&ptable.lock);
8010415a:	83 ec 0c             	sub    $0xc,%esp
8010415d:	68 00 4b 19 80       	push   $0x80194b00
80104162:	e8 2d 0a 00 00       	call   80104b94 <release>
80104167:	83 c4 10             	add    $0x10,%esp
      return -1;
8010416a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010416f:	eb 18                	jmp    80104189 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock); // DOC: wait-sleep
80104171:	83 ec 08             	sub    $0x8,%esp
80104174:	68 00 4b 19 80       	push   $0x80194b00
80104179:	ff 75 ec             	push   -0x14(%ebp)
8010417c:	e8 4b 05 00 00       	call   801046cc <sleep>
80104181:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104184:	e9 fd fe ff ff       	jmp    80104086 <wait+0x1e>
  }
}
80104189:	c9                   	leave  
8010418a:	c3                   	ret    

8010418b <scheduler>:
//   - choose a process to run
//   - swtch to start running that process
//   - eventually that process transfers control
//       via swtch back to the scheduler.
void scheduler(void)
{
8010418b:	55                   	push   %ebp
8010418c:	89 e5                	mov    %esp,%ebp
8010418e:	83 ec 58             	sub    $0x58,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104191:	e8 23 f8 ff ff       	call   801039b9 <mycpu>
80104196:	89 45 e8             	mov    %eax,-0x18(%ebp)
  c->proc = 0;
80104199:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010419c:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801041a3:	00 00 00 

  for (;;) {
    sti(); // Enable interrupts
801041a6:	e8 ce f7 ff ff       	call   80103979 <sti>
    
    acquire(&ptable.lock);
801041ab:	83 ec 0c             	sub    $0xc,%esp
801041ae:	68 00 4b 19 80       	push   $0x80194b00
801041b3:	e8 6e 09 00 00       	call   80104b26 <acquire>
801041b8:	83 c4 10             	add    $0x10,%esp

    int policy = c->sched_policy;
801041bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041be:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801041c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    struct proc *chosen = 0;
801041c7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

    if (policy == 0) {
801041ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801041d2:	75 7b                	jne    8010424f <scheduler+0xc4>
      // Round-robin scheduling
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801041d4:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
801041db:	eb 64                	jmp    80104241 <scheduler+0xb6>
        if (p->state != RUNNABLE)
801041dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e0:	8b 40 0c             	mov    0xc(%eax),%eax
801041e3:	83 f8 03             	cmp    $0x3,%eax
801041e6:	75 51                	jne    80104239 <scheduler+0xae>
          continue;

        c->proc = p;
801041e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041ee:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
801041f4:	83 ec 0c             	sub    $0xc,%esp
801041f7:	ff 75 f4             	push   -0xc(%ebp)
801041fa:	e8 6e 39 00 00       	call   80107b6d <switchuvm>
801041ff:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
80104202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104205:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
8010420c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010420f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104212:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104215:	83 c2 04             	add    $0x4,%edx
80104218:	83 ec 08             	sub    $0x8,%esp
8010421b:	50                   	push   %eax
8010421c:	52                   	push   %edx
8010421d:	e8 ef 0d 00 00       	call   80105011 <swtch>
80104222:	83 c4 10             	add    $0x10,%esp
        switchkvm();
80104225:	e8 2a 39 00 00       	call   80107b54 <switchkvm>

        c->proc = 0;
8010422a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010422d:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104234:	00 00 00 
80104237:	eb 01                	jmp    8010423a <scheduler+0xaf>
          continue;
80104239:	90                   	nop
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010423a:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104241:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
80104248:	72 93                	jb     801041dd <scheduler+0x52>
8010424a:	e9 ee 02 00 00       	jmp    8010453d <scheduler+0x3b2>
      }
    } else {
      // MLFQ scheduling
      int level;
      for (level = 3; level >= 0; level--) {
8010424f:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)
80104256:	eb 53                	jmp    801042ab <scheduler+0x120>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104258:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
8010425f:	eb 3d                	jmp    8010429e <scheduler+0x113>
          int idx = p - ptable.proc;
80104261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104264:	2d 34 4b 19 80       	sub    $0x80194b34,%eax
80104269:	c1 f8 02             	sar    $0x2,%eax
8010426c:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
80104272:	89 45 e0             	mov    %eax,-0x20(%ebp)
          if (p->state == RUNNABLE && proc_priority[idx] == level) {
80104275:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104278:	8b 40 0c             	mov    0xc(%eax),%eax
8010427b:	83 f8 03             	cmp    $0x3,%eax
8010427e:	75 17                	jne    80104297 <scheduler+0x10c>
80104280:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104283:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
8010428a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010428d:	75 08                	jne    80104297 <scheduler+0x10c>
            chosen = p;
8010428f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104292:	89 45 f0             	mov    %eax,-0x10(%ebp)
            goto found;
80104295:	eb 1b                	jmp    801042b2 <scheduler+0x127>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104297:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010429e:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
801042a5:	72 ba                	jb     80104261 <scheduler+0xd6>
      for (level = 3; level >= 0; level--) {
801042a7:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
801042ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801042af:	79 a7                	jns    80104258 <scheduler+0xcd>
          }
        }
      }

    found:
801042b1:	90                   	nop
      if (chosen) {
801042b2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801042b6:	0f 84 15 01 00 00    	je     801043d1 <scheduler+0x246>
        int cidx = chosen - ptable.proc;
801042bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042bf:	2d 34 4b 19 80       	sub    $0x80194b34,%eax
801042c4:	c1 f8 02             	sar    $0x2,%eax
801042c7:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
801042cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
        c->proc = chosen;
801042d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801042d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801042d6:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(chosen);
801042dc:	83 ec 0c             	sub    $0xc,%esp
801042df:	ff 75 f0             	push   -0x10(%ebp)
801042e2:	e8 86 38 00 00       	call   80107b6d <switchuvm>
801042e7:	83 c4 10             	add    $0x10,%esp
        chosen->state = RUNNING;
801042ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042ed:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&c->scheduler, chosen->context);
801042f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042f7:	8b 40 1c             	mov    0x1c(%eax),%eax
801042fa:	8b 55 e8             	mov    -0x18(%ebp),%edx
801042fd:	83 c2 04             	add    $0x4,%edx
80104300:	83 ec 08             	sub    $0x8,%esp
80104303:	50                   	push   %eax
80104304:	52                   	push   %edx
80104305:	e8 07 0d 00 00       	call   80105011 <swtch>
8010430a:	83 c4 10             	add    $0x10,%esp
        switchkvm();
8010430d:	e8 42 38 00 00       	call   80107b54 <switchkvm>

        proc_ticks[cidx][proc_priority[cidx]]++;
80104312:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104315:	8b 0c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ecx
8010431c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010431f:	c1 e0 02             	shl    $0x2,%eax
80104322:	01 c8                	add    %ecx,%eax
80104324:	8b 04 85 00 43 19 80 	mov    -0x7fe6bd00(,%eax,4),%eax
8010432b:	8d 50 01             	lea    0x1(%eax),%edx
8010432e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104331:	c1 e0 02             	shl    $0x2,%eax
80104334:	01 c8                	add    %ecx,%eax
80104336:	89 14 85 00 43 19 80 	mov    %edx,-0x7fe6bd00(,%eax,4)

        if (proc_ticks[cidx][proc_priority[cidx]] >= (int[]){0,32,16,8}[proc_priority[cidx]]
8010433d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104340:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
80104347:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010434a:	c1 e0 02             	shl    $0x2,%eax
8010434d:	01 d0                	add    %edx,%eax
8010434f:	8b 14 85 00 43 19 80 	mov    -0x7fe6bd00(,%eax,4),%edx
80104356:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%ebp)
8010435d:	c7 45 c0 20 00 00 00 	movl   $0x20,-0x40(%ebp)
80104364:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
8010436b:	c7 45 c8 08 00 00 00 	movl   $0x8,-0x38(%ebp)
80104372:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104375:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
8010437c:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
80104380:	39 c2                	cmp    %eax,%edx
80104382:	7c 40                	jl     801043c4 <scheduler+0x239>
            && proc_priority[cidx] > 0) {
80104384:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104387:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
8010438e:	85 c0                	test   %eax,%eax
80104390:	7e 32                	jle    801043c4 <scheduler+0x239>
          proc_priority[cidx]--;
80104392:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104395:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
8010439c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010439f:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043a2:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
          memset(proc_wait_ticks[cidx], 0, sizeof(proc_wait_ticks[cidx]));
801043a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043ac:	c1 e0 04             	shl    $0x4,%eax
801043af:	05 00 47 19 80       	add    $0x80194700,%eax
801043b4:	83 ec 04             	sub    $0x4,%esp
801043b7:	6a 10                	push   $0x10
801043b9:	6a 00                	push   $0x0
801043bb:	50                   	push   %eax
801043bc:	e8 db 09 00 00       	call   80104d9c <memset>
801043c1:	83 c4 10             	add    $0x10,%esp
        }

        c->proc = 0;
801043c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801043c7:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801043ce:	00 00 00 
      }

      // wait_ticks 증가
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801043d1:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
801043d8:	eb 59                	jmp    80104433 <scheduler+0x2a8>
        int idx = p - ptable.proc;
801043da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043dd:	2d 34 4b 19 80       	sub    $0x80194b34,%eax
801043e2:	c1 f8 02             	sar    $0x2,%eax
801043e5:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
801043eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
        if (p->state == RUNNABLE && p != chosen) {
801043ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f1:	8b 40 0c             	mov    0xc(%eax),%eax
801043f4:	83 f8 03             	cmp    $0x3,%eax
801043f7:	75 33                	jne    8010442c <scheduler+0x2a1>
801043f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801043ff:	74 2b                	je     8010442c <scheduler+0x2a1>
          proc_wait_ticks[idx][proc_priority[idx]]++;
80104401:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104404:	8b 0c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ecx
8010440b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010440e:	c1 e0 02             	shl    $0x2,%eax
80104411:	01 c8                	add    %ecx,%eax
80104413:	8b 04 85 00 47 19 80 	mov    -0x7fe6b900(,%eax,4),%eax
8010441a:	8d 50 01             	lea    0x1(%eax),%edx
8010441d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104420:	c1 e0 02             	shl    $0x2,%eax
80104423:	01 c8                	add    %ecx,%eax
80104425:	89 14 85 00 47 19 80 	mov    %edx,-0x7fe6b900(,%eax,4)
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010442c:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104433:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
8010443a:	72 9e                	jb     801043da <scheduler+0x24f>
        }
      }

      // Boosting (policy 1, 2만)
      if (policy != 3) {
8010443c:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
80104440:	0f 84 f7 00 00 00    	je     8010453d <scheduler+0x3b2>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104446:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
8010444d:	e9 de 00 00 00       	jmp    80104530 <scheduler+0x3a5>
          int idx = p - ptable.proc;
80104452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104455:	2d 34 4b 19 80       	sub    $0x80194b34,%eax
8010445a:	c1 f8 02             	sar    $0x2,%eax
8010445d:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
80104463:	89 45 d8             	mov    %eax,-0x28(%ebp)
          if (p->state == RUNNABLE && proc_priority[idx] < 3) {
80104466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104469:	8b 40 0c             	mov    0xc(%eax),%eax
8010446c:	83 f8 03             	cmp    $0x3,%eax
8010446f:	0f 85 b4 00 00 00    	jne    80104529 <scheduler+0x39e>
80104475:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104478:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
8010447f:	83 f8 02             	cmp    $0x2,%eax
80104482:	0f 8f a1 00 00 00    	jg     80104529 <scheduler+0x39e>
            int waited = proc_wait_ticks[idx][proc_priority[idx]];
80104488:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010448b:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
80104492:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104495:	c1 e0 02             	shl    $0x2,%eax
80104498:	01 d0                	add    %edx,%eax
8010449a:	8b 04 85 00 47 19 80 	mov    -0x7fe6b900(,%eax,4),%eax
801044a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
            int required = (proc_priority[idx] == 0) ? 500 : 10 * (int[]){0,32,16,8}[proc_priority[idx]];
801044a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801044a7:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
801044ae:	85 c0                	test   %eax,%eax
801044b0:	74 35                	je     801044e7 <scheduler+0x35c>
801044b2:	c7 45 ac 00 00 00 00 	movl   $0x0,-0x54(%ebp)
801044b9:	c7 45 b0 20 00 00 00 	movl   $0x20,-0x50(%ebp)
801044c0:	c7 45 b4 10 00 00 00 	movl   $0x10,-0x4c(%ebp)
801044c7:	c7 45 b8 08 00 00 00 	movl   $0x8,-0x48(%ebp)
801044ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
801044d1:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
801044d8:	8b 54 85 ac          	mov    -0x54(%ebp,%eax,4),%edx
801044dc:	89 d0                	mov    %edx,%eax
801044de:	c1 e0 02             	shl    $0x2,%eax
801044e1:	01 d0                	add    %edx,%eax
801044e3:	01 c0                	add    %eax,%eax
801044e5:	eb 05                	jmp    801044ec <scheduler+0x361>
801044e7:	b8 f4 01 00 00       	mov    $0x1f4,%eax
801044ec:	89 45 d0             	mov    %eax,-0x30(%ebp)

            if (waited >= required) {
801044ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801044f2:	3b 45 d0             	cmp    -0x30(%ebp),%eax
801044f5:	7c 32                	jl     80104529 <scheduler+0x39e>
              proc_priority[idx]++;
801044f7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801044fa:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104501:	8d 50 01             	lea    0x1(%eax),%edx
80104504:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104507:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
              memset(proc_wait_ticks[idx], 0, sizeof(proc_wait_ticks[idx]));
8010450e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104511:	c1 e0 04             	shl    $0x4,%eax
80104514:	05 00 47 19 80       	add    $0x80194700,%eax
80104519:	83 ec 04             	sub    $0x4,%esp
8010451c:	6a 10                	push   $0x10
8010451e:	6a 00                	push   $0x0
80104520:	50                   	push   %eax
80104521:	e8 76 08 00 00       	call   80104d9c <memset>
80104526:	83 c4 10             	add    $0x10,%esp
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104529:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104530:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
80104537:	0f 82 15 ff ff ff    	jb     80104452 <scheduler+0x2c7>
          }
        }
      }
    }

    release(&ptable.lock);
8010453d:	83 ec 0c             	sub    $0xc,%esp
80104540:	68 00 4b 19 80       	push   $0x80194b00
80104545:	e8 4a 06 00 00       	call   80104b94 <release>
8010454a:	83 c4 10             	add    $0x10,%esp
  for (;;) {
8010454d:	e9 54 fc ff ff       	jmp    801041a6 <scheduler+0x1b>

80104552 <sched>:
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void sched(void)
{
80104552:	55                   	push   %ebp
80104553:	89 e5                	mov    %esp,%ebp
80104555:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104558:	e8 d4 f4 ff ff       	call   80103a31 <myproc>
8010455d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if (!holding(&ptable.lock))
80104560:	83 ec 0c             	sub    $0xc,%esp
80104563:	68 00 4b 19 80       	push   $0x80194b00
80104568:	e8 f4 06 00 00       	call   80104c61 <holding>
8010456d:	83 c4 10             	add    $0x10,%esp
80104570:	85 c0                	test   %eax,%eax
80104572:	75 0d                	jne    80104581 <sched+0x2f>
    panic("sched ptable.lock");
80104574:	83 ec 0c             	sub    $0xc,%esp
80104577:	68 6b aa 10 80       	push   $0x8010aa6b
8010457c:	e8 28 c0 ff ff       	call   801005a9 <panic>
  if (mycpu()->ncli != 1)
80104581:	e8 33 f4 ff ff       	call   801039b9 <mycpu>
80104586:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010458c:	83 f8 01             	cmp    $0x1,%eax
8010458f:	74 0d                	je     8010459e <sched+0x4c>
    panic("sched locks");
80104591:	83 ec 0c             	sub    $0xc,%esp
80104594:	68 7d aa 10 80       	push   $0x8010aa7d
80104599:	e8 0b c0 ff ff       	call   801005a9 <panic>
  if (p->state == RUNNING)
8010459e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a1:	8b 40 0c             	mov    0xc(%eax),%eax
801045a4:	83 f8 04             	cmp    $0x4,%eax
801045a7:	75 0d                	jne    801045b6 <sched+0x64>
    panic("sched running");
801045a9:	83 ec 0c             	sub    $0xc,%esp
801045ac:	68 89 aa 10 80       	push   $0x8010aa89
801045b1:	e8 f3 bf ff ff       	call   801005a9 <panic>
  if (readeflags() & FL_IF)
801045b6:	e8 ae f3 ff ff       	call   80103969 <readeflags>
801045bb:	25 00 02 00 00       	and    $0x200,%eax
801045c0:	85 c0                	test   %eax,%eax
801045c2:	74 0d                	je     801045d1 <sched+0x7f>
    panic("sched interruptible");
801045c4:	83 ec 0c             	sub    $0xc,%esp
801045c7:	68 97 aa 10 80       	push   $0x8010aa97
801045cc:	e8 d8 bf ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
801045d1:	e8 e3 f3 ff ff       	call   801039b9 <mycpu>
801045d6:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801045dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801045df:	e8 d5 f3 ff ff       	call   801039b9 <mycpu>
801045e4:	8b 40 04             	mov    0x4(%eax),%eax
801045e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ea:	83 c2 1c             	add    $0x1c,%edx
801045ed:	83 ec 08             	sub    $0x8,%esp
801045f0:	50                   	push   %eax
801045f1:	52                   	push   %edx
801045f2:	e8 1a 0a 00 00       	call   80105011 <swtch>
801045f7:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801045fa:	e8 ba f3 ff ff       	call   801039b9 <mycpu>
801045ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104602:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104608:	90                   	nop
80104609:	c9                   	leave  
8010460a:	c3                   	ret    

8010460b <yield>:

// 이거이거거
// Give up the CPU for one scheduling round.
void yield(void)
{
8010460b:	55                   	push   %ebp
8010460c:	89 e5                	mov    %esp,%ebp
8010460e:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock); // DOC: yieldlock
80104611:	83 ec 0c             	sub    $0xc,%esp
80104614:	68 00 4b 19 80       	push   $0x80194b00
80104619:	e8 08 05 00 00       	call   80104b26 <acquire>
8010461e:	83 c4 10             	add    $0x10,%esp

  int idx = myproc() - ptable.proc;
80104621:	e8 0b f4 ff ff       	call   80103a31 <myproc>
80104626:	2d 34 4b 19 80       	sub    $0x80194b34,%eax
8010462b:	c1 f8 02             	sar    $0x2,%eax
8010462e:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
80104634:	89 45 f4             	mov    %eax,-0xc(%ebp)
  proc_ticks[idx][proc_priority[idx]]++;
80104637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463a:	8b 0c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ecx
80104641:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104644:	c1 e0 02             	shl    $0x2,%eax
80104647:	01 c8                	add    %ecx,%eax
80104649:	8b 04 85 00 43 19 80 	mov    -0x7fe6bd00(,%eax,4),%eax
80104650:	8d 50 01             	lea    0x1(%eax),%edx
80104653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104656:	c1 e0 02             	shl    $0x2,%eax
80104659:	01 c8                	add    %ecx,%eax
8010465b:	89 14 85 00 43 19 80 	mov    %edx,-0x7fe6bd00(,%eax,4)

  myproc()->state = RUNNABLE;
80104662:	e8 ca f3 ff ff       	call   80103a31 <myproc>
80104667:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010466e:	e8 df fe ff ff       	call   80104552 <sched>
  release(&ptable.lock);
80104673:	83 ec 0c             	sub    $0xc,%esp
80104676:	68 00 4b 19 80       	push   $0x80194b00
8010467b:	e8 14 05 00 00       	call   80104b94 <release>
80104680:	83 c4 10             	add    $0x10,%esp
}
80104683:	90                   	nop
80104684:	c9                   	leave  
80104685:	c3                   	ret    

80104686 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void forkret(void)
{
80104686:	55                   	push   %ebp
80104687:	89 e5                	mov    %esp,%ebp
80104689:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010468c:	83 ec 0c             	sub    $0xc,%esp
8010468f:	68 00 4b 19 80       	push   $0x80194b00
80104694:	e8 fb 04 00 00       	call   80104b94 <release>
80104699:	83 c4 10             	add    $0x10,%esp

  if (first)
8010469c:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801046a1:	85 c0                	test   %eax,%eax
801046a3:	74 24                	je     801046c9 <forkret+0x43>
  {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801046a5:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801046ac:	00 00 00 
    iinit(ROOTDEV);
801046af:	83 ec 0c             	sub    $0xc,%esp
801046b2:	6a 01                	push   $0x1
801046b4:	e8 c0 cf ff ff       	call   80101679 <iinit>
801046b9:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801046bc:	83 ec 0c             	sub    $0xc,%esp
801046bf:	6a 01                	push   $0x1
801046c1:	e8 58 e7 ff ff       	call   80102e1e <initlog>
801046c6:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801046c9:	90                   	nop
801046ca:	c9                   	leave  
801046cb:	c3                   	ret    

801046cc <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
801046cc:	55                   	push   %ebp
801046cd:	89 e5                	mov    %esp,%ebp
801046cf:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801046d2:	e8 5a f3 ff ff       	call   80103a31 <myproc>
801046d7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if (p == 0)
801046da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046de:	75 0d                	jne    801046ed <sleep+0x21>
    panic("sleep");
801046e0:	83 ec 0c             	sub    $0xc,%esp
801046e3:	68 ab aa 10 80       	push   $0x8010aaab
801046e8:	e8 bc be ff ff       	call   801005a9 <panic>

  if (lk == 0)
801046ed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801046f1:	75 0d                	jne    80104700 <sleep+0x34>
    panic("sleep without lk");
801046f3:	83 ec 0c             	sub    $0xc,%esp
801046f6:	68 b1 aa 10 80       	push   $0x8010aab1
801046fb:	e8 a9 be ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if (lk != &ptable.lock)
80104700:	81 7d 0c 00 4b 19 80 	cmpl   $0x80194b00,0xc(%ebp)
80104707:	74 1e                	je     80104727 <sleep+0x5b>
  {                        // DOC: sleeplock0
    acquire(&ptable.lock); // DOC: sleeplock1
80104709:	83 ec 0c             	sub    $0xc,%esp
8010470c:	68 00 4b 19 80       	push   $0x80194b00
80104711:	e8 10 04 00 00       	call   80104b26 <acquire>
80104716:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104719:	83 ec 0c             	sub    $0xc,%esp
8010471c:	ff 75 0c             	push   0xc(%ebp)
8010471f:	e8 70 04 00 00       	call   80104b94 <release>
80104724:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472a:	8b 55 08             	mov    0x8(%ebp),%edx
8010472d:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104733:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
8010473a:	e8 13 fe ff ff       	call   80104552 <sched>

  // Tidy up.
  p->chan = 0;
8010473f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104742:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if (lk != &ptable.lock)
80104749:	81 7d 0c 00 4b 19 80 	cmpl   $0x80194b00,0xc(%ebp)
80104750:	74 1e                	je     80104770 <sleep+0xa4>
  { // DOC: sleeplock2
    release(&ptable.lock);
80104752:	83 ec 0c             	sub    $0xc,%esp
80104755:	68 00 4b 19 80       	push   $0x80194b00
8010475a:	e8 35 04 00 00       	call   80104b94 <release>
8010475f:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104762:	83 ec 0c             	sub    $0xc,%esp
80104765:	ff 75 0c             	push   0xc(%ebp)
80104768:	e8 b9 03 00 00       	call   80104b26 <acquire>
8010476d:	83 c4 10             	add    $0x10,%esp
  }
}
80104770:	90                   	nop
80104771:	c9                   	leave  
80104772:	c3                   	ret    

80104773 <wakeup1>:
// PAGEBREAK!
//  Wake up all processes sleeping on chan.
//  The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104773:	55                   	push   %ebp
80104774:	89 e5                	mov    %esp,%ebp
80104776:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104779:	c7 45 fc 34 4b 19 80 	movl   $0x80194b34,-0x4(%ebp)
80104780:	eb 27                	jmp    801047a9 <wakeup1+0x36>
    if (p->state == SLEEPING && p->chan == chan)
80104782:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104785:	8b 40 0c             	mov    0xc(%eax),%eax
80104788:	83 f8 02             	cmp    $0x2,%eax
8010478b:	75 15                	jne    801047a2 <wakeup1+0x2f>
8010478d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104790:	8b 40 20             	mov    0x20(%eax),%eax
80104793:	39 45 08             	cmp    %eax,0x8(%ebp)
80104796:	75 0a                	jne    801047a2 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104798:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010479b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801047a2:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
801047a9:	81 7d fc 34 6c 19 80 	cmpl   $0x80196c34,-0x4(%ebp)
801047b0:	72 d0                	jb     80104782 <wakeup1+0xf>
}
801047b2:	90                   	nop
801047b3:	90                   	nop
801047b4:	c9                   	leave  
801047b5:	c3                   	ret    

801047b6 <wakeup>:

// Wake up all processes sleeping on chan.
void wakeup(void *chan)
{
801047b6:	55                   	push   %ebp
801047b7:	89 e5                	mov    %esp,%ebp
801047b9:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801047bc:	83 ec 0c             	sub    $0xc,%esp
801047bf:	68 00 4b 19 80       	push   $0x80194b00
801047c4:	e8 5d 03 00 00       	call   80104b26 <acquire>
801047c9:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801047cc:	83 ec 0c             	sub    $0xc,%esp
801047cf:	ff 75 08             	push   0x8(%ebp)
801047d2:	e8 9c ff ff ff       	call   80104773 <wakeup1>
801047d7:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801047da:	83 ec 0c             	sub    $0xc,%esp
801047dd:	68 00 4b 19 80       	push   $0x80194b00
801047e2:	e8 ad 03 00 00       	call   80104b94 <release>
801047e7:	83 c4 10             	add    $0x10,%esp
}
801047ea:	90                   	nop
801047eb:	c9                   	leave  
801047ec:	c3                   	ret    

801047ed <kill>:

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int kill(int pid)
{
801047ed:	55                   	push   %ebp
801047ee:	89 e5                	mov    %esp,%ebp
801047f0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801047f3:	83 ec 0c             	sub    $0xc,%esp
801047f6:	68 00 4b 19 80       	push   $0x80194b00
801047fb:	e8 26 03 00 00       	call   80104b26 <acquire>
80104800:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104803:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
8010480a:	eb 48                	jmp    80104854 <kill+0x67>
  {
    if (p->pid == pid)
8010480c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480f:	8b 40 10             	mov    0x10(%eax),%eax
80104812:	39 45 08             	cmp    %eax,0x8(%ebp)
80104815:	75 36                	jne    8010484d <kill+0x60>
    {
      p->killed = 1;
80104817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010481a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if (p->state == SLEEPING)
80104821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104824:	8b 40 0c             	mov    0xc(%eax),%eax
80104827:	83 f8 02             	cmp    $0x2,%eax
8010482a:	75 0a                	jne    80104836 <kill+0x49>
        p->state = RUNNABLE;
8010482c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104836:	83 ec 0c             	sub    $0xc,%esp
80104839:	68 00 4b 19 80       	push   $0x80194b00
8010483e:	e8 51 03 00 00       	call   80104b94 <release>
80104843:	83 c4 10             	add    $0x10,%esp
      return 0;
80104846:	b8 00 00 00 00       	mov    $0x0,%eax
8010484b:	eb 25                	jmp    80104872 <kill+0x85>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010484d:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104854:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
8010485b:	72 af                	jb     8010480c <kill+0x1f>
    }
  }
  release(&ptable.lock);
8010485d:	83 ec 0c             	sub    $0xc,%esp
80104860:	68 00 4b 19 80       	push   $0x80194b00
80104865:	e8 2a 03 00 00       	call   80104b94 <release>
8010486a:	83 c4 10             	add    $0x10,%esp
  return -1;
8010486d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104872:	c9                   	leave  
80104873:	c3                   	ret    

80104874 <procdump>:
// PAGEBREAK: 36
//  Print a process listing to console.  For debugging.
//  Runs when user types ^P on console.
//  No lock to avoid wedging a stuck machine further.
void procdump(void)
{
80104874:	55                   	push   %ebp
80104875:	89 e5                	mov    %esp,%ebp
80104877:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010487a:	c7 45 f0 34 4b 19 80 	movl   $0x80194b34,-0x10(%ebp)
80104881:	e9 da 00 00 00       	jmp    80104960 <procdump+0xec>
  {
    if (p->state == UNUSED)
80104886:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104889:	8b 40 0c             	mov    0xc(%eax),%eax
8010488c:	85 c0                	test   %eax,%eax
8010488e:	0f 84 c4 00 00 00    	je     80104958 <procdump+0xe4>
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104894:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104897:	8b 40 0c             	mov    0xc(%eax),%eax
8010489a:	83 f8 05             	cmp    $0x5,%eax
8010489d:	77 23                	ja     801048c2 <procdump+0x4e>
8010489f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048a2:	8b 40 0c             	mov    0xc(%eax),%eax
801048a5:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801048ac:	85 c0                	test   %eax,%eax
801048ae:	74 12                	je     801048c2 <procdump+0x4e>
      state = states[p->state];
801048b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048b3:	8b 40 0c             	mov    0xc(%eax),%eax
801048b6:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801048bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
801048c0:	eb 07                	jmp    801048c9 <procdump+0x55>
    else
      state = "???";
801048c2:	c7 45 ec c2 aa 10 80 	movl   $0x8010aac2,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801048c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048cc:	8d 50 6c             	lea    0x6c(%eax),%edx
801048cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048d2:	8b 40 10             	mov    0x10(%eax),%eax
801048d5:	52                   	push   %edx
801048d6:	ff 75 ec             	push   -0x14(%ebp)
801048d9:	50                   	push   %eax
801048da:	68 c6 aa 10 80       	push   $0x8010aac6
801048df:	e8 10 bb ff ff       	call   801003f4 <cprintf>
801048e4:	83 c4 10             	add    $0x10,%esp
    if (p->state == SLEEPING)
801048e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048ea:	8b 40 0c             	mov    0xc(%eax),%eax
801048ed:	83 f8 02             	cmp    $0x2,%eax
801048f0:	75 54                	jne    80104946 <procdump+0xd2>
    {
      getcallerpcs((uint *)p->context->ebp + 2, pc);
801048f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048f5:	8b 40 1c             	mov    0x1c(%eax),%eax
801048f8:	8b 40 0c             	mov    0xc(%eax),%eax
801048fb:	83 c0 08             	add    $0x8,%eax
801048fe:	89 c2                	mov    %eax,%edx
80104900:	83 ec 08             	sub    $0x8,%esp
80104903:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104906:	50                   	push   %eax
80104907:	52                   	push   %edx
80104908:	e8 d9 02 00 00       	call   80104be6 <getcallerpcs>
8010490d:	83 c4 10             	add    $0x10,%esp
      for (i = 0; i < 10 && pc[i] != 0; i++)
80104910:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104917:	eb 1c                	jmp    80104935 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491c:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104920:	83 ec 08             	sub    $0x8,%esp
80104923:	50                   	push   %eax
80104924:	68 cf aa 10 80       	push   $0x8010aacf
80104929:	e8 c6 ba ff ff       	call   801003f4 <cprintf>
8010492e:	83 c4 10             	add    $0x10,%esp
      for (i = 0; i < 10 && pc[i] != 0; i++)
80104931:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104935:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104939:	7f 0b                	jg     80104946 <procdump+0xd2>
8010493b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104942:	85 c0                	test   %eax,%eax
80104944:	75 d3                	jne    80104919 <procdump+0xa5>
    }
    cprintf("\n");
80104946:	83 ec 0c             	sub    $0xc,%esp
80104949:	68 d3 aa 10 80       	push   $0x8010aad3
8010494e:	e8 a1 ba ff ff       	call   801003f4 <cprintf>
80104953:	83 c4 10             	add    $0x10,%esp
80104956:	eb 01                	jmp    80104959 <procdump+0xe5>
      continue;
80104958:	90                   	nop
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104959:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104960:	81 7d f0 34 6c 19 80 	cmpl   $0x80196c34,-0x10(%ebp)
80104967:	0f 82 19 ff ff ff    	jb     80104886 <procdump+0x12>
  }
}
8010496d:	90                   	nop
8010496e:	90                   	nop
8010496f:	c9                   	leave  
80104970:	c3                   	ret    

80104971 <find_proc_by_pid>:

struct proc* find_proc_by_pid(int pid) {
80104971:	55                   	push   %ebp
80104972:	89 e5                	mov    %esp,%ebp
80104974:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104977:	c7 45 fc 34 4b 19 80 	movl   $0x80194b34,-0x4(%ebp)
8010497e:	eb 17                	jmp    80104997 <find_proc_by_pid+0x26>
    if(p->pid == pid)
80104980:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104983:	8b 40 10             	mov    0x10(%eax),%eax
80104986:	39 45 08             	cmp    %eax,0x8(%ebp)
80104989:	75 05                	jne    80104990 <find_proc_by_pid+0x1f>
      return p;
8010498b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010498e:	eb 15                	jmp    801049a5 <find_proc_by_pid+0x34>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104990:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104997:	81 7d fc 34 6c 19 80 	cmpl   $0x80196c34,-0x4(%ebp)
8010499e:	72 e0                	jb     80104980 <find_proc_by_pid+0xf>
  }
  return 0;
801049a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049a5:	c9                   	leave  
801049a6:	c3                   	ret    

801049a7 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801049a7:	55                   	push   %ebp
801049a8:	89 e5                	mov    %esp,%ebp
801049aa:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801049ad:	8b 45 08             	mov    0x8(%ebp),%eax
801049b0:	83 c0 04             	add    $0x4,%eax
801049b3:	83 ec 08             	sub    $0x8,%esp
801049b6:	68 ff aa 10 80       	push   $0x8010aaff
801049bb:	50                   	push   %eax
801049bc:	e8 43 01 00 00       	call   80104b04 <initlock>
801049c1:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801049c4:	8b 45 08             	mov    0x8(%ebp),%eax
801049c7:	8b 55 0c             	mov    0xc(%ebp),%edx
801049ca:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801049cd:	8b 45 08             	mov    0x8(%ebp),%eax
801049d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801049d6:	8b 45 08             	mov    0x8(%ebp),%eax
801049d9:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801049e0:	90                   	nop
801049e1:	c9                   	leave  
801049e2:	c3                   	ret    

801049e3 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801049e3:	55                   	push   %ebp
801049e4:	89 e5                	mov    %esp,%ebp
801049e6:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801049e9:	8b 45 08             	mov    0x8(%ebp),%eax
801049ec:	83 c0 04             	add    $0x4,%eax
801049ef:	83 ec 0c             	sub    $0xc,%esp
801049f2:	50                   	push   %eax
801049f3:	e8 2e 01 00 00       	call   80104b26 <acquire>
801049f8:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801049fb:	eb 15                	jmp    80104a12 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801049fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104a00:	83 c0 04             	add    $0x4,%eax
80104a03:	83 ec 08             	sub    $0x8,%esp
80104a06:	50                   	push   %eax
80104a07:	ff 75 08             	push   0x8(%ebp)
80104a0a:	e8 bd fc ff ff       	call   801046cc <sleep>
80104a0f:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104a12:	8b 45 08             	mov    0x8(%ebp),%eax
80104a15:	8b 00                	mov    (%eax),%eax
80104a17:	85 c0                	test   %eax,%eax
80104a19:	75 e2                	jne    801049fd <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104a1b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a1e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104a24:	e8 08 f0 ff ff       	call   80103a31 <myproc>
80104a29:	8b 50 10             	mov    0x10(%eax),%edx
80104a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a2f:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104a32:	8b 45 08             	mov    0x8(%ebp),%eax
80104a35:	83 c0 04             	add    $0x4,%eax
80104a38:	83 ec 0c             	sub    $0xc,%esp
80104a3b:	50                   	push   %eax
80104a3c:	e8 53 01 00 00       	call   80104b94 <release>
80104a41:	83 c4 10             	add    $0x10,%esp
}
80104a44:	90                   	nop
80104a45:	c9                   	leave  
80104a46:	c3                   	ret    

80104a47 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104a47:	55                   	push   %ebp
80104a48:	89 e5                	mov    %esp,%ebp
80104a4a:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a50:	83 c0 04             	add    $0x4,%eax
80104a53:	83 ec 0c             	sub    $0xc,%esp
80104a56:	50                   	push   %eax
80104a57:	e8 ca 00 00 00       	call   80104b26 <acquire>
80104a5c:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a62:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104a68:	8b 45 08             	mov    0x8(%ebp),%eax
80104a6b:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104a72:	83 ec 0c             	sub    $0xc,%esp
80104a75:	ff 75 08             	push   0x8(%ebp)
80104a78:	e8 39 fd ff ff       	call   801047b6 <wakeup>
80104a7d:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104a80:	8b 45 08             	mov    0x8(%ebp),%eax
80104a83:	83 c0 04             	add    $0x4,%eax
80104a86:	83 ec 0c             	sub    $0xc,%esp
80104a89:	50                   	push   %eax
80104a8a:	e8 05 01 00 00       	call   80104b94 <release>
80104a8f:	83 c4 10             	add    $0x10,%esp
}
80104a92:	90                   	nop
80104a93:	c9                   	leave  
80104a94:	c3                   	ret    

80104a95 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104a95:	55                   	push   %ebp
80104a96:	89 e5                	mov    %esp,%ebp
80104a98:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a9e:	83 c0 04             	add    $0x4,%eax
80104aa1:	83 ec 0c             	sub    $0xc,%esp
80104aa4:	50                   	push   %eax
80104aa5:	e8 7c 00 00 00       	call   80104b26 <acquire>
80104aaa:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104aad:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab0:	8b 00                	mov    (%eax),%eax
80104ab2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab8:	83 c0 04             	add    $0x4,%eax
80104abb:	83 ec 0c             	sub    $0xc,%esp
80104abe:	50                   	push   %eax
80104abf:	e8 d0 00 00 00       	call   80104b94 <release>
80104ac4:	83 c4 10             	add    $0x10,%esp
  return r;
80104ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104aca:	c9                   	leave  
80104acb:	c3                   	ret    

80104acc <readeflags>:
{
80104acc:	55                   	push   %ebp
80104acd:	89 e5                	mov    %esp,%ebp
80104acf:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104ad2:	9c                   	pushf  
80104ad3:	58                   	pop    %eax
80104ad4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104ad7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ada:	c9                   	leave  
80104adb:	c3                   	ret    

80104adc <cli>:
{
80104adc:	55                   	push   %ebp
80104add:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104adf:	fa                   	cli    
}
80104ae0:	90                   	nop
80104ae1:	5d                   	pop    %ebp
80104ae2:	c3                   	ret    

80104ae3 <sti>:
{
80104ae3:	55                   	push   %ebp
80104ae4:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104ae6:	fb                   	sti    
}
80104ae7:	90                   	nop
80104ae8:	5d                   	pop    %ebp
80104ae9:	c3                   	ret    

80104aea <xchg>:
{
80104aea:	55                   	push   %ebp
80104aeb:	89 e5                	mov    %esp,%ebp
80104aed:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104af0:	8b 55 08             	mov    0x8(%ebp),%edx
80104af3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104af6:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104af9:	f0 87 02             	lock xchg %eax,(%edx)
80104afc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104aff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b02:	c9                   	leave  
80104b03:	c3                   	ret    

80104b04 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104b04:	55                   	push   %ebp
80104b05:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104b07:	8b 45 08             	mov    0x8(%ebp),%eax
80104b0a:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b0d:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104b10:	8b 45 08             	mov    0x8(%ebp),%eax
80104b13:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104b19:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104b23:	90                   	nop
80104b24:	5d                   	pop    %ebp
80104b25:	c3                   	ret    

80104b26 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104b26:	55                   	push   %ebp
80104b27:	89 e5                	mov    %esp,%ebp
80104b29:	53                   	push   %ebx
80104b2a:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104b2d:	e8 5f 01 00 00       	call   80104c91 <pushcli>
  if(holding(lk)){
80104b32:	8b 45 08             	mov    0x8(%ebp),%eax
80104b35:	83 ec 0c             	sub    $0xc,%esp
80104b38:	50                   	push   %eax
80104b39:	e8 23 01 00 00       	call   80104c61 <holding>
80104b3e:	83 c4 10             	add    $0x10,%esp
80104b41:	85 c0                	test   %eax,%eax
80104b43:	74 0d                	je     80104b52 <acquire+0x2c>
    panic("acquire");
80104b45:	83 ec 0c             	sub    $0xc,%esp
80104b48:	68 0a ab 10 80       	push   $0x8010ab0a
80104b4d:	e8 57 ba ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104b52:	90                   	nop
80104b53:	8b 45 08             	mov    0x8(%ebp),%eax
80104b56:	83 ec 08             	sub    $0x8,%esp
80104b59:	6a 01                	push   $0x1
80104b5b:	50                   	push   %eax
80104b5c:	e8 89 ff ff ff       	call   80104aea <xchg>
80104b61:	83 c4 10             	add    $0x10,%esp
80104b64:	85 c0                	test   %eax,%eax
80104b66:	75 eb                	jne    80104b53 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104b68:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104b6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104b70:	e8 44 ee ff ff       	call   801039b9 <mycpu>
80104b75:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104b78:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7b:	83 c0 0c             	add    $0xc,%eax
80104b7e:	83 ec 08             	sub    $0x8,%esp
80104b81:	50                   	push   %eax
80104b82:	8d 45 08             	lea    0x8(%ebp),%eax
80104b85:	50                   	push   %eax
80104b86:	e8 5b 00 00 00       	call   80104be6 <getcallerpcs>
80104b8b:	83 c4 10             	add    $0x10,%esp
}
80104b8e:	90                   	nop
80104b8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b92:	c9                   	leave  
80104b93:	c3                   	ret    

80104b94 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104b94:	55                   	push   %ebp
80104b95:	89 e5                	mov    %esp,%ebp
80104b97:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104b9a:	83 ec 0c             	sub    $0xc,%esp
80104b9d:	ff 75 08             	push   0x8(%ebp)
80104ba0:	e8 bc 00 00 00       	call   80104c61 <holding>
80104ba5:	83 c4 10             	add    $0x10,%esp
80104ba8:	85 c0                	test   %eax,%eax
80104baa:	75 0d                	jne    80104bb9 <release+0x25>
    panic("release");
80104bac:	83 ec 0c             	sub    $0xc,%esp
80104baf:	68 12 ab 10 80       	push   $0x8010ab12
80104bb4:	e8 f0 b9 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bbc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104bcd:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104bd2:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd5:	8b 55 08             	mov    0x8(%ebp),%edx
80104bd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104bde:	e8 fb 00 00 00       	call   80104cde <popcli>
}
80104be3:	90                   	nop
80104be4:	c9                   	leave  
80104be5:	c3                   	ret    

80104be6 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104be6:	55                   	push   %ebp
80104be7:	89 e5                	mov    %esp,%ebp
80104be9:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104bec:	8b 45 08             	mov    0x8(%ebp),%eax
80104bef:	83 e8 08             	sub    $0x8,%eax
80104bf2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104bf5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104bfc:	eb 38                	jmp    80104c36 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104bfe:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104c02:	74 53                	je     80104c57 <getcallerpcs+0x71>
80104c04:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104c0b:	76 4a                	jbe    80104c57 <getcallerpcs+0x71>
80104c0d:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104c11:	74 44                	je     80104c57 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104c13:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c20:	01 c2                	add    %eax,%edx
80104c22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c25:	8b 40 04             	mov    0x4(%eax),%eax
80104c28:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104c2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c2d:	8b 00                	mov    (%eax),%eax
80104c2f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104c32:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c36:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c3a:	7e c2                	jle    80104bfe <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104c3c:	eb 19                	jmp    80104c57 <getcallerpcs+0x71>
    pcs[i] = 0;
80104c3e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c41:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c48:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c4b:	01 d0                	add    %edx,%eax
80104c4d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104c53:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c57:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c5b:	7e e1                	jle    80104c3e <getcallerpcs+0x58>
}
80104c5d:	90                   	nop
80104c5e:	90                   	nop
80104c5f:	c9                   	leave  
80104c60:	c3                   	ret    

80104c61 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104c61:	55                   	push   %ebp
80104c62:	89 e5                	mov    %esp,%ebp
80104c64:	53                   	push   %ebx
80104c65:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104c68:	8b 45 08             	mov    0x8(%ebp),%eax
80104c6b:	8b 00                	mov    (%eax),%eax
80104c6d:	85 c0                	test   %eax,%eax
80104c6f:	74 16                	je     80104c87 <holding+0x26>
80104c71:	8b 45 08             	mov    0x8(%ebp),%eax
80104c74:	8b 58 08             	mov    0x8(%eax),%ebx
80104c77:	e8 3d ed ff ff       	call   801039b9 <mycpu>
80104c7c:	39 c3                	cmp    %eax,%ebx
80104c7e:	75 07                	jne    80104c87 <holding+0x26>
80104c80:	b8 01 00 00 00       	mov    $0x1,%eax
80104c85:	eb 05                	jmp    80104c8c <holding+0x2b>
80104c87:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c8f:	c9                   	leave  
80104c90:	c3                   	ret    

80104c91 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104c91:	55                   	push   %ebp
80104c92:	89 e5                	mov    %esp,%ebp
80104c94:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104c97:	e8 30 fe ff ff       	call   80104acc <readeflags>
80104c9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104c9f:	e8 38 fe ff ff       	call   80104adc <cli>
  if(mycpu()->ncli == 0)
80104ca4:	e8 10 ed ff ff       	call   801039b9 <mycpu>
80104ca9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104caf:	85 c0                	test   %eax,%eax
80104cb1:	75 14                	jne    80104cc7 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104cb3:	e8 01 ed ff ff       	call   801039b9 <mycpu>
80104cb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cbb:	81 e2 00 02 00 00    	and    $0x200,%edx
80104cc1:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104cc7:	e8 ed ec ff ff       	call   801039b9 <mycpu>
80104ccc:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104cd2:	83 c2 01             	add    $0x1,%edx
80104cd5:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104cdb:	90                   	nop
80104cdc:	c9                   	leave  
80104cdd:	c3                   	ret    

80104cde <popcli>:

void
popcli(void)
{
80104cde:	55                   	push   %ebp
80104cdf:	89 e5                	mov    %esp,%ebp
80104ce1:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104ce4:	e8 e3 fd ff ff       	call   80104acc <readeflags>
80104ce9:	25 00 02 00 00       	and    $0x200,%eax
80104cee:	85 c0                	test   %eax,%eax
80104cf0:	74 0d                	je     80104cff <popcli+0x21>
    panic("popcli - interruptible");
80104cf2:	83 ec 0c             	sub    $0xc,%esp
80104cf5:	68 1a ab 10 80       	push   $0x8010ab1a
80104cfa:	e8 aa b8 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104cff:	e8 b5 ec ff ff       	call   801039b9 <mycpu>
80104d04:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d0a:	83 ea 01             	sub    $0x1,%edx
80104d0d:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104d13:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d19:	85 c0                	test   %eax,%eax
80104d1b:	79 0d                	jns    80104d2a <popcli+0x4c>
    panic("popcli");
80104d1d:	83 ec 0c             	sub    $0xc,%esp
80104d20:	68 31 ab 10 80       	push   $0x8010ab31
80104d25:	e8 7f b8 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104d2a:	e8 8a ec ff ff       	call   801039b9 <mycpu>
80104d2f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d35:	85 c0                	test   %eax,%eax
80104d37:	75 14                	jne    80104d4d <popcli+0x6f>
80104d39:	e8 7b ec ff ff       	call   801039b9 <mycpu>
80104d3e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104d44:	85 c0                	test   %eax,%eax
80104d46:	74 05                	je     80104d4d <popcli+0x6f>
    sti();
80104d48:	e8 96 fd ff ff       	call   80104ae3 <sti>
}
80104d4d:	90                   	nop
80104d4e:	c9                   	leave  
80104d4f:	c3                   	ret    

80104d50 <stosb>:
{
80104d50:	55                   	push   %ebp
80104d51:	89 e5                	mov    %esp,%ebp
80104d53:	57                   	push   %edi
80104d54:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104d55:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d58:	8b 55 10             	mov    0x10(%ebp),%edx
80104d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d5e:	89 cb                	mov    %ecx,%ebx
80104d60:	89 df                	mov    %ebx,%edi
80104d62:	89 d1                	mov    %edx,%ecx
80104d64:	fc                   	cld    
80104d65:	f3 aa                	rep stos %al,%es:(%edi)
80104d67:	89 ca                	mov    %ecx,%edx
80104d69:	89 fb                	mov    %edi,%ebx
80104d6b:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d6e:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d71:	90                   	nop
80104d72:	5b                   	pop    %ebx
80104d73:	5f                   	pop    %edi
80104d74:	5d                   	pop    %ebp
80104d75:	c3                   	ret    

80104d76 <stosl>:
{
80104d76:	55                   	push   %ebp
80104d77:	89 e5                	mov    %esp,%ebp
80104d79:	57                   	push   %edi
80104d7a:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104d7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d7e:	8b 55 10             	mov    0x10(%ebp),%edx
80104d81:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d84:	89 cb                	mov    %ecx,%ebx
80104d86:	89 df                	mov    %ebx,%edi
80104d88:	89 d1                	mov    %edx,%ecx
80104d8a:	fc                   	cld    
80104d8b:	f3 ab                	rep stos %eax,%es:(%edi)
80104d8d:	89 ca                	mov    %ecx,%edx
80104d8f:	89 fb                	mov    %edi,%ebx
80104d91:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d94:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d97:	90                   	nop
80104d98:	5b                   	pop    %ebx
80104d99:	5f                   	pop    %edi
80104d9a:	5d                   	pop    %ebp
80104d9b:	c3                   	ret    

80104d9c <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104d9c:	55                   	push   %ebp
80104d9d:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80104da2:	83 e0 03             	and    $0x3,%eax
80104da5:	85 c0                	test   %eax,%eax
80104da7:	75 43                	jne    80104dec <memset+0x50>
80104da9:	8b 45 10             	mov    0x10(%ebp),%eax
80104dac:	83 e0 03             	and    $0x3,%eax
80104daf:	85 c0                	test   %eax,%eax
80104db1:	75 39                	jne    80104dec <memset+0x50>
    c &= 0xFF;
80104db3:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104dba:	8b 45 10             	mov    0x10(%ebp),%eax
80104dbd:	c1 e8 02             	shr    $0x2,%eax
80104dc0:	89 c2                	mov    %eax,%edx
80104dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dc5:	c1 e0 18             	shl    $0x18,%eax
80104dc8:	89 c1                	mov    %eax,%ecx
80104dca:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dcd:	c1 e0 10             	shl    $0x10,%eax
80104dd0:	09 c1                	or     %eax,%ecx
80104dd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dd5:	c1 e0 08             	shl    $0x8,%eax
80104dd8:	09 c8                	or     %ecx,%eax
80104dda:	0b 45 0c             	or     0xc(%ebp),%eax
80104ddd:	52                   	push   %edx
80104dde:	50                   	push   %eax
80104ddf:	ff 75 08             	push   0x8(%ebp)
80104de2:	e8 8f ff ff ff       	call   80104d76 <stosl>
80104de7:	83 c4 0c             	add    $0xc,%esp
80104dea:	eb 12                	jmp    80104dfe <memset+0x62>
  } else
    stosb(dst, c, n);
80104dec:	8b 45 10             	mov    0x10(%ebp),%eax
80104def:	50                   	push   %eax
80104df0:	ff 75 0c             	push   0xc(%ebp)
80104df3:	ff 75 08             	push   0x8(%ebp)
80104df6:	e8 55 ff ff ff       	call   80104d50 <stosb>
80104dfb:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104dfe:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e01:	c9                   	leave  
80104e02:	c3                   	ret    

80104e03 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104e03:	55                   	push   %ebp
80104e04:	89 e5                	mov    %esp,%ebp
80104e06:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104e09:	8b 45 08             	mov    0x8(%ebp),%eax
80104e0c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e12:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104e15:	eb 30                	jmp    80104e47 <memcmp+0x44>
    if(*s1 != *s2)
80104e17:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e1a:	0f b6 10             	movzbl (%eax),%edx
80104e1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e20:	0f b6 00             	movzbl (%eax),%eax
80104e23:	38 c2                	cmp    %al,%dl
80104e25:	74 18                	je     80104e3f <memcmp+0x3c>
      return *s1 - *s2;
80104e27:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e2a:	0f b6 00             	movzbl (%eax),%eax
80104e2d:	0f b6 d0             	movzbl %al,%edx
80104e30:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e33:	0f b6 00             	movzbl (%eax),%eax
80104e36:	0f b6 c8             	movzbl %al,%ecx
80104e39:	89 d0                	mov    %edx,%eax
80104e3b:	29 c8                	sub    %ecx,%eax
80104e3d:	eb 1a                	jmp    80104e59 <memcmp+0x56>
    s1++, s2++;
80104e3f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104e43:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104e47:	8b 45 10             	mov    0x10(%ebp),%eax
80104e4a:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e4d:	89 55 10             	mov    %edx,0x10(%ebp)
80104e50:	85 c0                	test   %eax,%eax
80104e52:	75 c3                	jne    80104e17 <memcmp+0x14>
  }

  return 0;
80104e54:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e59:	c9                   	leave  
80104e5a:	c3                   	ret    

80104e5b <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104e5b:	55                   	push   %ebp
80104e5c:	89 e5                	mov    %esp,%ebp
80104e5e:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104e61:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e64:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104e67:	8b 45 08             	mov    0x8(%ebp),%eax
80104e6a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104e6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e70:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e73:	73 54                	jae    80104ec9 <memmove+0x6e>
80104e75:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e78:	8b 45 10             	mov    0x10(%ebp),%eax
80104e7b:	01 d0                	add    %edx,%eax
80104e7d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104e80:	73 47                	jae    80104ec9 <memmove+0x6e>
    s += n;
80104e82:	8b 45 10             	mov    0x10(%ebp),%eax
80104e85:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104e88:	8b 45 10             	mov    0x10(%ebp),%eax
80104e8b:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104e8e:	eb 13                	jmp    80104ea3 <memmove+0x48>
      *--d = *--s;
80104e90:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104e94:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104e98:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e9b:	0f b6 10             	movzbl (%eax),%edx
80104e9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ea1:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104ea3:	8b 45 10             	mov    0x10(%ebp),%eax
80104ea6:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ea9:	89 55 10             	mov    %edx,0x10(%ebp)
80104eac:	85 c0                	test   %eax,%eax
80104eae:	75 e0                	jne    80104e90 <memmove+0x35>
  if(s < d && s + n > d){
80104eb0:	eb 24                	jmp    80104ed6 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104eb2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104eb5:	8d 42 01             	lea    0x1(%edx),%eax
80104eb8:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104ebb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ebe:	8d 48 01             	lea    0x1(%eax),%ecx
80104ec1:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104ec4:	0f b6 12             	movzbl (%edx),%edx
80104ec7:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104ec9:	8b 45 10             	mov    0x10(%ebp),%eax
80104ecc:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ecf:	89 55 10             	mov    %edx,0x10(%ebp)
80104ed2:	85 c0                	test   %eax,%eax
80104ed4:	75 dc                	jne    80104eb2 <memmove+0x57>

  return dst;
80104ed6:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ed9:	c9                   	leave  
80104eda:	c3                   	ret    

80104edb <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104edb:	55                   	push   %ebp
80104edc:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104ede:	ff 75 10             	push   0x10(%ebp)
80104ee1:	ff 75 0c             	push   0xc(%ebp)
80104ee4:	ff 75 08             	push   0x8(%ebp)
80104ee7:	e8 6f ff ff ff       	call   80104e5b <memmove>
80104eec:	83 c4 0c             	add    $0xc,%esp
}
80104eef:	c9                   	leave  
80104ef0:	c3                   	ret    

80104ef1 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104ef1:	55                   	push   %ebp
80104ef2:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ef4:	eb 0c                	jmp    80104f02 <strncmp+0x11>
    n--, p++, q++;
80104ef6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104efa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104efe:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104f02:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f06:	74 1a                	je     80104f22 <strncmp+0x31>
80104f08:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0b:	0f b6 00             	movzbl (%eax),%eax
80104f0e:	84 c0                	test   %al,%al
80104f10:	74 10                	je     80104f22 <strncmp+0x31>
80104f12:	8b 45 08             	mov    0x8(%ebp),%eax
80104f15:	0f b6 10             	movzbl (%eax),%edx
80104f18:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f1b:	0f b6 00             	movzbl (%eax),%eax
80104f1e:	38 c2                	cmp    %al,%dl
80104f20:	74 d4                	je     80104ef6 <strncmp+0x5>
  if(n == 0)
80104f22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f26:	75 07                	jne    80104f2f <strncmp+0x3e>
    return 0;
80104f28:	b8 00 00 00 00       	mov    $0x0,%eax
80104f2d:	eb 16                	jmp    80104f45 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f32:	0f b6 00             	movzbl (%eax),%eax
80104f35:	0f b6 d0             	movzbl %al,%edx
80104f38:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f3b:	0f b6 00             	movzbl (%eax),%eax
80104f3e:	0f b6 c8             	movzbl %al,%ecx
80104f41:	89 d0                	mov    %edx,%eax
80104f43:	29 c8                	sub    %ecx,%eax
}
80104f45:	5d                   	pop    %ebp
80104f46:	c3                   	ret    

80104f47 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104f47:	55                   	push   %ebp
80104f48:	89 e5                	mov    %esp,%ebp
80104f4a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104f50:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104f53:	90                   	nop
80104f54:	8b 45 10             	mov    0x10(%ebp),%eax
80104f57:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f5a:	89 55 10             	mov    %edx,0x10(%ebp)
80104f5d:	85 c0                	test   %eax,%eax
80104f5f:	7e 2c                	jle    80104f8d <strncpy+0x46>
80104f61:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f64:	8d 42 01             	lea    0x1(%edx),%eax
80104f67:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f6d:	8d 48 01             	lea    0x1(%eax),%ecx
80104f70:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104f73:	0f b6 12             	movzbl (%edx),%edx
80104f76:	88 10                	mov    %dl,(%eax)
80104f78:	0f b6 00             	movzbl (%eax),%eax
80104f7b:	84 c0                	test   %al,%al
80104f7d:	75 d5                	jne    80104f54 <strncpy+0xd>
    ;
  while(n-- > 0)
80104f7f:	eb 0c                	jmp    80104f8d <strncpy+0x46>
    *s++ = 0;
80104f81:	8b 45 08             	mov    0x8(%ebp),%eax
80104f84:	8d 50 01             	lea    0x1(%eax),%edx
80104f87:	89 55 08             	mov    %edx,0x8(%ebp)
80104f8a:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104f8d:	8b 45 10             	mov    0x10(%ebp),%eax
80104f90:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f93:	89 55 10             	mov    %edx,0x10(%ebp)
80104f96:	85 c0                	test   %eax,%eax
80104f98:	7f e7                	jg     80104f81 <strncpy+0x3a>
  return os;
80104f9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f9d:	c9                   	leave  
80104f9e:	c3                   	ret    

80104f9f <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104f9f:	55                   	push   %ebp
80104fa0:	89 e5                	mov    %esp,%ebp
80104fa2:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104fab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104faf:	7f 05                	jg     80104fb6 <safestrcpy+0x17>
    return os;
80104fb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fb4:	eb 32                	jmp    80104fe8 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104fb6:	90                   	nop
80104fb7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104fbb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fbf:	7e 1e                	jle    80104fdf <safestrcpy+0x40>
80104fc1:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fc4:	8d 42 01             	lea    0x1(%edx),%eax
80104fc7:	89 45 0c             	mov    %eax,0xc(%ebp)
80104fca:	8b 45 08             	mov    0x8(%ebp),%eax
80104fcd:	8d 48 01             	lea    0x1(%eax),%ecx
80104fd0:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104fd3:	0f b6 12             	movzbl (%edx),%edx
80104fd6:	88 10                	mov    %dl,(%eax)
80104fd8:	0f b6 00             	movzbl (%eax),%eax
80104fdb:	84 c0                	test   %al,%al
80104fdd:	75 d8                	jne    80104fb7 <safestrcpy+0x18>
    ;
  *s = 0;
80104fdf:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe2:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104fe5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fe8:	c9                   	leave  
80104fe9:	c3                   	ret    

80104fea <strlen>:

int
strlen(const char *s)
{
80104fea:	55                   	push   %ebp
80104feb:	89 e5                	mov    %esp,%ebp
80104fed:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104ff0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104ff7:	eb 04                	jmp    80104ffd <strlen+0x13>
80104ff9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104ffd:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105000:	8b 45 08             	mov    0x8(%ebp),%eax
80105003:	01 d0                	add    %edx,%eax
80105005:	0f b6 00             	movzbl (%eax),%eax
80105008:	84 c0                	test   %al,%al
8010500a:	75 ed                	jne    80104ff9 <strlen+0xf>
    ;
  return n;
8010500c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010500f:	c9                   	leave  
80105010:	c3                   	ret    

80105011 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105011:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105015:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105019:	55                   	push   %ebp
  pushl %ebx
8010501a:	53                   	push   %ebx
  pushl %esi
8010501b:	56                   	push   %esi
  pushl %edi
8010501c:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010501d:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010501f:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105021:	5f                   	pop    %edi
  popl %esi
80105022:	5e                   	pop    %esi
  popl %ebx
80105023:	5b                   	pop    %ebx
  popl %ebp
80105024:	5d                   	pop    %ebp
  ret
80105025:	c3                   	ret    

80105026 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105026:	55                   	push   %ebp
80105027:	89 e5                	mov    %esp,%ebp
80105029:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010502c:	e8 00 ea ff ff       	call   80103a31 <myproc>
80105031:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105034:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105037:	8b 00                	mov    (%eax),%eax
80105039:	39 45 08             	cmp    %eax,0x8(%ebp)
8010503c:	73 0f                	jae    8010504d <fetchint+0x27>
8010503e:	8b 45 08             	mov    0x8(%ebp),%eax
80105041:	8d 50 04             	lea    0x4(%eax),%edx
80105044:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105047:	8b 00                	mov    (%eax),%eax
80105049:	39 c2                	cmp    %eax,%edx
8010504b:	76 07                	jbe    80105054 <fetchint+0x2e>
    return -1;
8010504d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105052:	eb 0f                	jmp    80105063 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105054:	8b 45 08             	mov    0x8(%ebp),%eax
80105057:	8b 10                	mov    (%eax),%edx
80105059:	8b 45 0c             	mov    0xc(%ebp),%eax
8010505c:	89 10                	mov    %edx,(%eax)
  return 0;
8010505e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105063:	c9                   	leave  
80105064:	c3                   	ret    

80105065 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105065:	55                   	push   %ebp
80105066:	89 e5                	mov    %esp,%ebp
80105068:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010506b:	e8 c1 e9 ff ff       	call   80103a31 <myproc>
80105070:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105073:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105076:	8b 00                	mov    (%eax),%eax
80105078:	39 45 08             	cmp    %eax,0x8(%ebp)
8010507b:	72 07                	jb     80105084 <fetchstr+0x1f>
    return -1;
8010507d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105082:	eb 41                	jmp    801050c5 <fetchstr+0x60>
  *pp = (char*)addr;
80105084:	8b 55 08             	mov    0x8(%ebp),%edx
80105087:	8b 45 0c             	mov    0xc(%ebp),%eax
8010508a:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010508c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010508f:	8b 00                	mov    (%eax),%eax
80105091:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105094:	8b 45 0c             	mov    0xc(%ebp),%eax
80105097:	8b 00                	mov    (%eax),%eax
80105099:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010509c:	eb 1a                	jmp    801050b8 <fetchstr+0x53>
    if(*s == 0)
8010509e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a1:	0f b6 00             	movzbl (%eax),%eax
801050a4:	84 c0                	test   %al,%al
801050a6:	75 0c                	jne    801050b4 <fetchstr+0x4f>
      return s - *pp;
801050a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ab:	8b 10                	mov    (%eax),%edx
801050ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b0:	29 d0                	sub    %edx,%eax
801050b2:	eb 11                	jmp    801050c5 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
801050b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050bb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801050be:	72 de                	jb     8010509e <fetchstr+0x39>
  }
  return -1;
801050c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050c5:	c9                   	leave  
801050c6:	c3                   	ret    

801050c7 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801050c7:	55                   	push   %ebp
801050c8:	89 e5                	mov    %esp,%ebp
801050ca:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801050cd:	e8 5f e9 ff ff       	call   80103a31 <myproc>
801050d2:	8b 40 18             	mov    0x18(%eax),%eax
801050d5:	8b 50 44             	mov    0x44(%eax),%edx
801050d8:	8b 45 08             	mov    0x8(%ebp),%eax
801050db:	c1 e0 02             	shl    $0x2,%eax
801050de:	01 d0                	add    %edx,%eax
801050e0:	83 c0 04             	add    $0x4,%eax
801050e3:	83 ec 08             	sub    $0x8,%esp
801050e6:	ff 75 0c             	push   0xc(%ebp)
801050e9:	50                   	push   %eax
801050ea:	e8 37 ff ff ff       	call   80105026 <fetchint>
801050ef:	83 c4 10             	add    $0x10,%esp
}
801050f2:	c9                   	leave  
801050f3:	c3                   	ret    

801050f4 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801050f4:	55                   	push   %ebp
801050f5:	89 e5                	mov    %esp,%ebp
801050f7:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801050fa:	e8 32 e9 ff ff       	call   80103a31 <myproc>
801050ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105102:	83 ec 08             	sub    $0x8,%esp
80105105:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105108:	50                   	push   %eax
80105109:	ff 75 08             	push   0x8(%ebp)
8010510c:	e8 b6 ff ff ff       	call   801050c7 <argint>
80105111:	83 c4 10             	add    $0x10,%esp
80105114:	85 c0                	test   %eax,%eax
80105116:	79 07                	jns    8010511f <argptr+0x2b>
    return -1;
80105118:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010511d:	eb 3b                	jmp    8010515a <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010511f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105123:	78 1f                	js     80105144 <argptr+0x50>
80105125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105128:	8b 00                	mov    (%eax),%eax
8010512a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010512d:	39 d0                	cmp    %edx,%eax
8010512f:	76 13                	jbe    80105144 <argptr+0x50>
80105131:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105134:	89 c2                	mov    %eax,%edx
80105136:	8b 45 10             	mov    0x10(%ebp),%eax
80105139:	01 c2                	add    %eax,%edx
8010513b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513e:	8b 00                	mov    (%eax),%eax
80105140:	39 c2                	cmp    %eax,%edx
80105142:	76 07                	jbe    8010514b <argptr+0x57>
    return -1;
80105144:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105149:	eb 0f                	jmp    8010515a <argptr+0x66>
  *pp = (char*)i;
8010514b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010514e:	89 c2                	mov    %eax,%edx
80105150:	8b 45 0c             	mov    0xc(%ebp),%eax
80105153:	89 10                	mov    %edx,(%eax)
  return 0;
80105155:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010515a:	c9                   	leave  
8010515b:	c3                   	ret    

8010515c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010515c:	55                   	push   %ebp
8010515d:	89 e5                	mov    %esp,%ebp
8010515f:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105162:	83 ec 08             	sub    $0x8,%esp
80105165:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105168:	50                   	push   %eax
80105169:	ff 75 08             	push   0x8(%ebp)
8010516c:	e8 56 ff ff ff       	call   801050c7 <argint>
80105171:	83 c4 10             	add    $0x10,%esp
80105174:	85 c0                	test   %eax,%eax
80105176:	79 07                	jns    8010517f <argstr+0x23>
    return -1;
80105178:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010517d:	eb 12                	jmp    80105191 <argstr+0x35>
  return fetchstr(addr, pp);
8010517f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105182:	83 ec 08             	sub    $0x8,%esp
80105185:	ff 75 0c             	push   0xc(%ebp)
80105188:	50                   	push   %eax
80105189:	e8 d7 fe ff ff       	call   80105065 <fetchstr>
8010518e:	83 c4 10             	add    $0x10,%esp
}
80105191:	c9                   	leave  
80105192:	c3                   	ret    

80105193 <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80105193:	55                   	push   %ebp
80105194:	89 e5                	mov    %esp,%ebp
80105196:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105199:	e8 93 e8 ff ff       	call   80103a31 <myproc>
8010519e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801051a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a4:	8b 40 18             	mov    0x18(%eax),%eax
801051a7:	8b 40 1c             	mov    0x1c(%eax),%eax
801051aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801051ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801051b1:	7e 2f                	jle    801051e2 <syscall+0x4f>
801051b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051b6:	83 f8 1b             	cmp    $0x1b,%eax
801051b9:	77 27                	ja     801051e2 <syscall+0x4f>
801051bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051be:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801051c5:	85 c0                	test   %eax,%eax
801051c7:	74 19                	je     801051e2 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
801051c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051cc:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801051d3:	ff d0                	call   *%eax
801051d5:	89 c2                	mov    %eax,%edx
801051d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051da:	8b 40 18             	mov    0x18(%eax),%eax
801051dd:	89 50 1c             	mov    %edx,0x1c(%eax)
801051e0:	eb 2c                	jmp    8010520e <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801051e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e5:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801051e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051eb:	8b 40 10             	mov    0x10(%eax),%eax
801051ee:	ff 75 f0             	push   -0x10(%ebp)
801051f1:	52                   	push   %edx
801051f2:	50                   	push   %eax
801051f3:	68 38 ab 10 80       	push   $0x8010ab38
801051f8:	e8 f7 b1 ff ff       	call   801003f4 <cprintf>
801051fd:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105203:	8b 40 18             	mov    0x18(%eax),%eax
80105206:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010520d:	90                   	nop
8010520e:	90                   	nop
8010520f:	c9                   	leave  
80105210:	c3                   	ret    

80105211 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105211:	55                   	push   %ebp
80105212:	89 e5                	mov    %esp,%ebp
80105214:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105217:	83 ec 08             	sub    $0x8,%esp
8010521a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010521d:	50                   	push   %eax
8010521e:	ff 75 08             	push   0x8(%ebp)
80105221:	e8 a1 fe ff ff       	call   801050c7 <argint>
80105226:	83 c4 10             	add    $0x10,%esp
80105229:	85 c0                	test   %eax,%eax
8010522b:	79 07                	jns    80105234 <argfd+0x23>
    return -1;
8010522d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105232:	eb 4f                	jmp    80105283 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105234:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105237:	85 c0                	test   %eax,%eax
80105239:	78 20                	js     8010525b <argfd+0x4a>
8010523b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010523e:	83 f8 0f             	cmp    $0xf,%eax
80105241:	7f 18                	jg     8010525b <argfd+0x4a>
80105243:	e8 e9 e7 ff ff       	call   80103a31 <myproc>
80105248:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010524b:	83 c2 08             	add    $0x8,%edx
8010524e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105252:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105255:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105259:	75 07                	jne    80105262 <argfd+0x51>
    return -1;
8010525b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105260:	eb 21                	jmp    80105283 <argfd+0x72>
  if(pfd)
80105262:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105266:	74 08                	je     80105270 <argfd+0x5f>
    *pfd = fd;
80105268:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010526b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010526e:	89 10                	mov    %edx,(%eax)
  if(pf)
80105270:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105274:	74 08                	je     8010527e <argfd+0x6d>
    *pf = f;
80105276:	8b 45 10             	mov    0x10(%ebp),%eax
80105279:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010527c:	89 10                	mov    %edx,(%eax)
  return 0;
8010527e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105283:	c9                   	leave  
80105284:	c3                   	ret    

80105285 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105285:	55                   	push   %ebp
80105286:	89 e5                	mov    %esp,%ebp
80105288:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010528b:	e8 a1 e7 ff ff       	call   80103a31 <myproc>
80105290:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105293:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010529a:	eb 2a                	jmp    801052c6 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
8010529c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010529f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052a2:	83 c2 08             	add    $0x8,%edx
801052a5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801052a9:	85 c0                	test   %eax,%eax
801052ab:	75 15                	jne    801052c2 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801052ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052b3:	8d 4a 08             	lea    0x8(%edx),%ecx
801052b6:	8b 55 08             	mov    0x8(%ebp),%edx
801052b9:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801052bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c0:	eb 0f                	jmp    801052d1 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
801052c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801052c6:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801052ca:	7e d0                	jle    8010529c <fdalloc+0x17>
    }
  }
  return -1;
801052cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052d1:	c9                   	leave  
801052d2:	c3                   	ret    

801052d3 <sys_dup>:

int
sys_dup(void)
{
801052d3:	55                   	push   %ebp
801052d4:	89 e5                	mov    %esp,%ebp
801052d6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801052d9:	83 ec 04             	sub    $0x4,%esp
801052dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052df:	50                   	push   %eax
801052e0:	6a 00                	push   $0x0
801052e2:	6a 00                	push   $0x0
801052e4:	e8 28 ff ff ff       	call   80105211 <argfd>
801052e9:	83 c4 10             	add    $0x10,%esp
801052ec:	85 c0                	test   %eax,%eax
801052ee:	79 07                	jns    801052f7 <sys_dup+0x24>
    return -1;
801052f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052f5:	eb 31                	jmp    80105328 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801052f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052fa:	83 ec 0c             	sub    $0xc,%esp
801052fd:	50                   	push   %eax
801052fe:	e8 82 ff ff ff       	call   80105285 <fdalloc>
80105303:	83 c4 10             	add    $0x10,%esp
80105306:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105309:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010530d:	79 07                	jns    80105316 <sys_dup+0x43>
    return -1;
8010530f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105314:	eb 12                	jmp    80105328 <sys_dup+0x55>
  filedup(f);
80105316:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105319:	83 ec 0c             	sub    $0xc,%esp
8010531c:	50                   	push   %eax
8010531d:	e8 29 bd ff ff       	call   8010104b <filedup>
80105322:	83 c4 10             	add    $0x10,%esp
  return fd;
80105325:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105328:	c9                   	leave  
80105329:	c3                   	ret    

8010532a <sys_read>:

int
sys_read(void)
{
8010532a:	55                   	push   %ebp
8010532b:	89 e5                	mov    %esp,%ebp
8010532d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105330:	83 ec 04             	sub    $0x4,%esp
80105333:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105336:	50                   	push   %eax
80105337:	6a 00                	push   $0x0
80105339:	6a 00                	push   $0x0
8010533b:	e8 d1 fe ff ff       	call   80105211 <argfd>
80105340:	83 c4 10             	add    $0x10,%esp
80105343:	85 c0                	test   %eax,%eax
80105345:	78 2e                	js     80105375 <sys_read+0x4b>
80105347:	83 ec 08             	sub    $0x8,%esp
8010534a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010534d:	50                   	push   %eax
8010534e:	6a 02                	push   $0x2
80105350:	e8 72 fd ff ff       	call   801050c7 <argint>
80105355:	83 c4 10             	add    $0x10,%esp
80105358:	85 c0                	test   %eax,%eax
8010535a:	78 19                	js     80105375 <sys_read+0x4b>
8010535c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010535f:	83 ec 04             	sub    $0x4,%esp
80105362:	50                   	push   %eax
80105363:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105366:	50                   	push   %eax
80105367:	6a 01                	push   $0x1
80105369:	e8 86 fd ff ff       	call   801050f4 <argptr>
8010536e:	83 c4 10             	add    $0x10,%esp
80105371:	85 c0                	test   %eax,%eax
80105373:	79 07                	jns    8010537c <sys_read+0x52>
    return -1;
80105375:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010537a:	eb 17                	jmp    80105393 <sys_read+0x69>
  return fileread(f, p, n);
8010537c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010537f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105385:	83 ec 04             	sub    $0x4,%esp
80105388:	51                   	push   %ecx
80105389:	52                   	push   %edx
8010538a:	50                   	push   %eax
8010538b:	e8 4b be ff ff       	call   801011db <fileread>
80105390:	83 c4 10             	add    $0x10,%esp
}
80105393:	c9                   	leave  
80105394:	c3                   	ret    

80105395 <sys_write>:

int
sys_write(void)
{
80105395:	55                   	push   %ebp
80105396:	89 e5                	mov    %esp,%ebp
80105398:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010539b:	83 ec 04             	sub    $0x4,%esp
8010539e:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053a1:	50                   	push   %eax
801053a2:	6a 00                	push   $0x0
801053a4:	6a 00                	push   $0x0
801053a6:	e8 66 fe ff ff       	call   80105211 <argfd>
801053ab:	83 c4 10             	add    $0x10,%esp
801053ae:	85 c0                	test   %eax,%eax
801053b0:	78 2e                	js     801053e0 <sys_write+0x4b>
801053b2:	83 ec 08             	sub    $0x8,%esp
801053b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053b8:	50                   	push   %eax
801053b9:	6a 02                	push   $0x2
801053bb:	e8 07 fd ff ff       	call   801050c7 <argint>
801053c0:	83 c4 10             	add    $0x10,%esp
801053c3:	85 c0                	test   %eax,%eax
801053c5:	78 19                	js     801053e0 <sys_write+0x4b>
801053c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ca:	83 ec 04             	sub    $0x4,%esp
801053cd:	50                   	push   %eax
801053ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
801053d1:	50                   	push   %eax
801053d2:	6a 01                	push   $0x1
801053d4:	e8 1b fd ff ff       	call   801050f4 <argptr>
801053d9:	83 c4 10             	add    $0x10,%esp
801053dc:	85 c0                	test   %eax,%eax
801053de:	79 07                	jns    801053e7 <sys_write+0x52>
    return -1;
801053e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053e5:	eb 17                	jmp    801053fe <sys_write+0x69>
  return filewrite(f, p, n);
801053e7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053ea:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f0:	83 ec 04             	sub    $0x4,%esp
801053f3:	51                   	push   %ecx
801053f4:	52                   	push   %edx
801053f5:	50                   	push   %eax
801053f6:	e8 98 be ff ff       	call   80101293 <filewrite>
801053fb:	83 c4 10             	add    $0x10,%esp
}
801053fe:	c9                   	leave  
801053ff:	c3                   	ret    

80105400 <sys_close>:

int
sys_close(void)
{
80105400:	55                   	push   %ebp
80105401:	89 e5                	mov    %esp,%ebp
80105403:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105406:	83 ec 04             	sub    $0x4,%esp
80105409:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010540c:	50                   	push   %eax
8010540d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105410:	50                   	push   %eax
80105411:	6a 00                	push   $0x0
80105413:	e8 f9 fd ff ff       	call   80105211 <argfd>
80105418:	83 c4 10             	add    $0x10,%esp
8010541b:	85 c0                	test   %eax,%eax
8010541d:	79 07                	jns    80105426 <sys_close+0x26>
    return -1;
8010541f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105424:	eb 27                	jmp    8010544d <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105426:	e8 06 e6 ff ff       	call   80103a31 <myproc>
8010542b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010542e:	83 c2 08             	add    $0x8,%edx
80105431:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105438:	00 
  fileclose(f);
80105439:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010543c:	83 ec 0c             	sub    $0xc,%esp
8010543f:	50                   	push   %eax
80105440:	e8 57 bc ff ff       	call   8010109c <fileclose>
80105445:	83 c4 10             	add    $0x10,%esp
  return 0;
80105448:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010544d:	c9                   	leave  
8010544e:	c3                   	ret    

8010544f <sys_fstat>:

int
sys_fstat(void)
{
8010544f:	55                   	push   %ebp
80105450:	89 e5                	mov    %esp,%ebp
80105452:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105455:	83 ec 04             	sub    $0x4,%esp
80105458:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010545b:	50                   	push   %eax
8010545c:	6a 00                	push   $0x0
8010545e:	6a 00                	push   $0x0
80105460:	e8 ac fd ff ff       	call   80105211 <argfd>
80105465:	83 c4 10             	add    $0x10,%esp
80105468:	85 c0                	test   %eax,%eax
8010546a:	78 17                	js     80105483 <sys_fstat+0x34>
8010546c:	83 ec 04             	sub    $0x4,%esp
8010546f:	6a 14                	push   $0x14
80105471:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105474:	50                   	push   %eax
80105475:	6a 01                	push   $0x1
80105477:	e8 78 fc ff ff       	call   801050f4 <argptr>
8010547c:	83 c4 10             	add    $0x10,%esp
8010547f:	85 c0                	test   %eax,%eax
80105481:	79 07                	jns    8010548a <sys_fstat+0x3b>
    return -1;
80105483:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105488:	eb 13                	jmp    8010549d <sys_fstat+0x4e>
  return filestat(f, st);
8010548a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010548d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105490:	83 ec 08             	sub    $0x8,%esp
80105493:	52                   	push   %edx
80105494:	50                   	push   %eax
80105495:	e8 ea bc ff ff       	call   80101184 <filestat>
8010549a:	83 c4 10             	add    $0x10,%esp
}
8010549d:	c9                   	leave  
8010549e:	c3                   	ret    

8010549f <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010549f:	55                   	push   %ebp
801054a0:	89 e5                	mov    %esp,%ebp
801054a2:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801054a5:	83 ec 08             	sub    $0x8,%esp
801054a8:	8d 45 d8             	lea    -0x28(%ebp),%eax
801054ab:	50                   	push   %eax
801054ac:	6a 00                	push   $0x0
801054ae:	e8 a9 fc ff ff       	call   8010515c <argstr>
801054b3:	83 c4 10             	add    $0x10,%esp
801054b6:	85 c0                	test   %eax,%eax
801054b8:	78 15                	js     801054cf <sys_link+0x30>
801054ba:	83 ec 08             	sub    $0x8,%esp
801054bd:	8d 45 dc             	lea    -0x24(%ebp),%eax
801054c0:	50                   	push   %eax
801054c1:	6a 01                	push   $0x1
801054c3:	e8 94 fc ff ff       	call   8010515c <argstr>
801054c8:	83 c4 10             	add    $0x10,%esp
801054cb:	85 c0                	test   %eax,%eax
801054cd:	79 0a                	jns    801054d9 <sys_link+0x3a>
    return -1;
801054cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054d4:	e9 68 01 00 00       	jmp    80105641 <sys_link+0x1a2>

  begin_op();
801054d9:	e8 5f db ff ff       	call   8010303d <begin_op>
  if((ip = namei(old)) == 0){
801054de:	8b 45 d8             	mov    -0x28(%ebp),%eax
801054e1:	83 ec 0c             	sub    $0xc,%esp
801054e4:	50                   	push   %eax
801054e5:	e8 34 d0 ff ff       	call   8010251e <namei>
801054ea:	83 c4 10             	add    $0x10,%esp
801054ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054f4:	75 0f                	jne    80105505 <sys_link+0x66>
    end_op();
801054f6:	e8 ce db ff ff       	call   801030c9 <end_op>
    return -1;
801054fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105500:	e9 3c 01 00 00       	jmp    80105641 <sys_link+0x1a2>
  }

  ilock(ip);
80105505:	83 ec 0c             	sub    $0xc,%esp
80105508:	ff 75 f4             	push   -0xc(%ebp)
8010550b:	e8 db c4 ff ff       	call   801019eb <ilock>
80105510:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105516:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010551a:	66 83 f8 01          	cmp    $0x1,%ax
8010551e:	75 1d                	jne    8010553d <sys_link+0x9e>
    iunlockput(ip);
80105520:	83 ec 0c             	sub    $0xc,%esp
80105523:	ff 75 f4             	push   -0xc(%ebp)
80105526:	e8 f1 c6 ff ff       	call   80101c1c <iunlockput>
8010552b:	83 c4 10             	add    $0x10,%esp
    end_op();
8010552e:	e8 96 db ff ff       	call   801030c9 <end_op>
    return -1;
80105533:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105538:	e9 04 01 00 00       	jmp    80105641 <sys_link+0x1a2>
  }

  ip->nlink++;
8010553d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105540:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105544:	83 c0 01             	add    $0x1,%eax
80105547:	89 c2                	mov    %eax,%edx
80105549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010554c:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105550:	83 ec 0c             	sub    $0xc,%esp
80105553:	ff 75 f4             	push   -0xc(%ebp)
80105556:	e8 b3 c2 ff ff       	call   8010180e <iupdate>
8010555b:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010555e:	83 ec 0c             	sub    $0xc,%esp
80105561:	ff 75 f4             	push   -0xc(%ebp)
80105564:	e8 95 c5 ff ff       	call   80101afe <iunlock>
80105569:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010556c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010556f:	83 ec 08             	sub    $0x8,%esp
80105572:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105575:	52                   	push   %edx
80105576:	50                   	push   %eax
80105577:	e8 be cf ff ff       	call   8010253a <nameiparent>
8010557c:	83 c4 10             	add    $0x10,%esp
8010557f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105582:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105586:	74 71                	je     801055f9 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105588:	83 ec 0c             	sub    $0xc,%esp
8010558b:	ff 75 f0             	push   -0x10(%ebp)
8010558e:	e8 58 c4 ff ff       	call   801019eb <ilock>
80105593:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105596:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105599:	8b 10                	mov    (%eax),%edx
8010559b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010559e:	8b 00                	mov    (%eax),%eax
801055a0:	39 c2                	cmp    %eax,%edx
801055a2:	75 1d                	jne    801055c1 <sys_link+0x122>
801055a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a7:	8b 40 04             	mov    0x4(%eax),%eax
801055aa:	83 ec 04             	sub    $0x4,%esp
801055ad:	50                   	push   %eax
801055ae:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801055b1:	50                   	push   %eax
801055b2:	ff 75 f0             	push   -0x10(%ebp)
801055b5:	e8 cd cc ff ff       	call   80102287 <dirlink>
801055ba:	83 c4 10             	add    $0x10,%esp
801055bd:	85 c0                	test   %eax,%eax
801055bf:	79 10                	jns    801055d1 <sys_link+0x132>
    iunlockput(dp);
801055c1:	83 ec 0c             	sub    $0xc,%esp
801055c4:	ff 75 f0             	push   -0x10(%ebp)
801055c7:	e8 50 c6 ff ff       	call   80101c1c <iunlockput>
801055cc:	83 c4 10             	add    $0x10,%esp
    goto bad;
801055cf:	eb 29                	jmp    801055fa <sys_link+0x15b>
  }
  iunlockput(dp);
801055d1:	83 ec 0c             	sub    $0xc,%esp
801055d4:	ff 75 f0             	push   -0x10(%ebp)
801055d7:	e8 40 c6 ff ff       	call   80101c1c <iunlockput>
801055dc:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801055df:	83 ec 0c             	sub    $0xc,%esp
801055e2:	ff 75 f4             	push   -0xc(%ebp)
801055e5:	e8 62 c5 ff ff       	call   80101b4c <iput>
801055ea:	83 c4 10             	add    $0x10,%esp

  end_op();
801055ed:	e8 d7 da ff ff       	call   801030c9 <end_op>

  return 0;
801055f2:	b8 00 00 00 00       	mov    $0x0,%eax
801055f7:	eb 48                	jmp    80105641 <sys_link+0x1a2>
    goto bad;
801055f9:	90                   	nop

bad:
  ilock(ip);
801055fa:	83 ec 0c             	sub    $0xc,%esp
801055fd:	ff 75 f4             	push   -0xc(%ebp)
80105600:	e8 e6 c3 ff ff       	call   801019eb <ilock>
80105605:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105608:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010560f:	83 e8 01             	sub    $0x1,%eax
80105612:	89 c2                	mov    %eax,%edx
80105614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105617:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010561b:	83 ec 0c             	sub    $0xc,%esp
8010561e:	ff 75 f4             	push   -0xc(%ebp)
80105621:	e8 e8 c1 ff ff       	call   8010180e <iupdate>
80105626:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105629:	83 ec 0c             	sub    $0xc,%esp
8010562c:	ff 75 f4             	push   -0xc(%ebp)
8010562f:	e8 e8 c5 ff ff       	call   80101c1c <iunlockput>
80105634:	83 c4 10             	add    $0x10,%esp
  end_op();
80105637:	e8 8d da ff ff       	call   801030c9 <end_op>
  return -1;
8010563c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105641:	c9                   	leave  
80105642:	c3                   	ret    

80105643 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105643:	55                   	push   %ebp
80105644:	89 e5                	mov    %esp,%ebp
80105646:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105649:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105650:	eb 40                	jmp    80105692 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105655:	6a 10                	push   $0x10
80105657:	50                   	push   %eax
80105658:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010565b:	50                   	push   %eax
8010565c:	ff 75 08             	push   0x8(%ebp)
8010565f:	e8 73 c8 ff ff       	call   80101ed7 <readi>
80105664:	83 c4 10             	add    $0x10,%esp
80105667:	83 f8 10             	cmp    $0x10,%eax
8010566a:	74 0d                	je     80105679 <isdirempty+0x36>
      panic("isdirempty: readi");
8010566c:	83 ec 0c             	sub    $0xc,%esp
8010566f:	68 54 ab 10 80       	push   $0x8010ab54
80105674:	e8 30 af ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105679:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010567d:	66 85 c0             	test   %ax,%ax
80105680:	74 07                	je     80105689 <isdirempty+0x46>
      return 0;
80105682:	b8 00 00 00 00       	mov    $0x0,%eax
80105687:	eb 1b                	jmp    801056a4 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105689:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568c:	83 c0 10             	add    $0x10,%eax
8010568f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105692:	8b 45 08             	mov    0x8(%ebp),%eax
80105695:	8b 50 58             	mov    0x58(%eax),%edx
80105698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010569b:	39 c2                	cmp    %eax,%edx
8010569d:	77 b3                	ja     80105652 <isdirempty+0xf>
  }
  return 1;
8010569f:	b8 01 00 00 00       	mov    $0x1,%eax
}
801056a4:	c9                   	leave  
801056a5:	c3                   	ret    

801056a6 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801056a6:	55                   	push   %ebp
801056a7:	89 e5                	mov    %esp,%ebp
801056a9:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801056ac:	83 ec 08             	sub    $0x8,%esp
801056af:	8d 45 cc             	lea    -0x34(%ebp),%eax
801056b2:	50                   	push   %eax
801056b3:	6a 00                	push   $0x0
801056b5:	e8 a2 fa ff ff       	call   8010515c <argstr>
801056ba:	83 c4 10             	add    $0x10,%esp
801056bd:	85 c0                	test   %eax,%eax
801056bf:	79 0a                	jns    801056cb <sys_unlink+0x25>
    return -1;
801056c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c6:	e9 bf 01 00 00       	jmp    8010588a <sys_unlink+0x1e4>

  begin_op();
801056cb:	e8 6d d9 ff ff       	call   8010303d <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801056d0:	8b 45 cc             	mov    -0x34(%ebp),%eax
801056d3:	83 ec 08             	sub    $0x8,%esp
801056d6:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801056d9:	52                   	push   %edx
801056da:	50                   	push   %eax
801056db:	e8 5a ce ff ff       	call   8010253a <nameiparent>
801056e0:	83 c4 10             	add    $0x10,%esp
801056e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056ea:	75 0f                	jne    801056fb <sys_unlink+0x55>
    end_op();
801056ec:	e8 d8 d9 ff ff       	call   801030c9 <end_op>
    return -1;
801056f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f6:	e9 8f 01 00 00       	jmp    8010588a <sys_unlink+0x1e4>
  }

  ilock(dp);
801056fb:	83 ec 0c             	sub    $0xc,%esp
801056fe:	ff 75 f4             	push   -0xc(%ebp)
80105701:	e8 e5 c2 ff ff       	call   801019eb <ilock>
80105706:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105709:	83 ec 08             	sub    $0x8,%esp
8010570c:	68 66 ab 10 80       	push   $0x8010ab66
80105711:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105714:	50                   	push   %eax
80105715:	e8 98 ca ff ff       	call   801021b2 <namecmp>
8010571a:	83 c4 10             	add    $0x10,%esp
8010571d:	85 c0                	test   %eax,%eax
8010571f:	0f 84 49 01 00 00    	je     8010586e <sys_unlink+0x1c8>
80105725:	83 ec 08             	sub    $0x8,%esp
80105728:	68 68 ab 10 80       	push   $0x8010ab68
8010572d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105730:	50                   	push   %eax
80105731:	e8 7c ca ff ff       	call   801021b2 <namecmp>
80105736:	83 c4 10             	add    $0x10,%esp
80105739:	85 c0                	test   %eax,%eax
8010573b:	0f 84 2d 01 00 00    	je     8010586e <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105741:	83 ec 04             	sub    $0x4,%esp
80105744:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105747:	50                   	push   %eax
80105748:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010574b:	50                   	push   %eax
8010574c:	ff 75 f4             	push   -0xc(%ebp)
8010574f:	e8 79 ca ff ff       	call   801021cd <dirlookup>
80105754:	83 c4 10             	add    $0x10,%esp
80105757:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010575a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010575e:	0f 84 0d 01 00 00    	je     80105871 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105764:	83 ec 0c             	sub    $0xc,%esp
80105767:	ff 75 f0             	push   -0x10(%ebp)
8010576a:	e8 7c c2 ff ff       	call   801019eb <ilock>
8010576f:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105772:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105775:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105779:	66 85 c0             	test   %ax,%ax
8010577c:	7f 0d                	jg     8010578b <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010577e:	83 ec 0c             	sub    $0xc,%esp
80105781:	68 6b ab 10 80       	push   $0x8010ab6b
80105786:	e8 1e ae ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010578b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010578e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105792:	66 83 f8 01          	cmp    $0x1,%ax
80105796:	75 25                	jne    801057bd <sys_unlink+0x117>
80105798:	83 ec 0c             	sub    $0xc,%esp
8010579b:	ff 75 f0             	push   -0x10(%ebp)
8010579e:	e8 a0 fe ff ff       	call   80105643 <isdirempty>
801057a3:	83 c4 10             	add    $0x10,%esp
801057a6:	85 c0                	test   %eax,%eax
801057a8:	75 13                	jne    801057bd <sys_unlink+0x117>
    iunlockput(ip);
801057aa:	83 ec 0c             	sub    $0xc,%esp
801057ad:	ff 75 f0             	push   -0x10(%ebp)
801057b0:	e8 67 c4 ff ff       	call   80101c1c <iunlockput>
801057b5:	83 c4 10             	add    $0x10,%esp
    goto bad;
801057b8:	e9 b5 00 00 00       	jmp    80105872 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801057bd:	83 ec 04             	sub    $0x4,%esp
801057c0:	6a 10                	push   $0x10
801057c2:	6a 00                	push   $0x0
801057c4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057c7:	50                   	push   %eax
801057c8:	e8 cf f5 ff ff       	call   80104d9c <memset>
801057cd:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801057d0:	8b 45 c8             	mov    -0x38(%ebp),%eax
801057d3:	6a 10                	push   $0x10
801057d5:	50                   	push   %eax
801057d6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057d9:	50                   	push   %eax
801057da:	ff 75 f4             	push   -0xc(%ebp)
801057dd:	e8 4a c8 ff ff       	call   8010202c <writei>
801057e2:	83 c4 10             	add    $0x10,%esp
801057e5:	83 f8 10             	cmp    $0x10,%eax
801057e8:	74 0d                	je     801057f7 <sys_unlink+0x151>
    panic("unlink: writei");
801057ea:	83 ec 0c             	sub    $0xc,%esp
801057ed:	68 7d ab 10 80       	push   $0x8010ab7d
801057f2:	e8 b2 ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801057f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057fa:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801057fe:	66 83 f8 01          	cmp    $0x1,%ax
80105802:	75 21                	jne    80105825 <sys_unlink+0x17f>
    dp->nlink--;
80105804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105807:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010580b:	83 e8 01             	sub    $0x1,%eax
8010580e:	89 c2                	mov    %eax,%edx
80105810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105813:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105817:	83 ec 0c             	sub    $0xc,%esp
8010581a:	ff 75 f4             	push   -0xc(%ebp)
8010581d:	e8 ec bf ff ff       	call   8010180e <iupdate>
80105822:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105825:	83 ec 0c             	sub    $0xc,%esp
80105828:	ff 75 f4             	push   -0xc(%ebp)
8010582b:	e8 ec c3 ff ff       	call   80101c1c <iunlockput>
80105830:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105833:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105836:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010583a:	83 e8 01             	sub    $0x1,%eax
8010583d:	89 c2                	mov    %eax,%edx
8010583f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105842:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105846:	83 ec 0c             	sub    $0xc,%esp
80105849:	ff 75 f0             	push   -0x10(%ebp)
8010584c:	e8 bd bf ff ff       	call   8010180e <iupdate>
80105851:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105854:	83 ec 0c             	sub    $0xc,%esp
80105857:	ff 75 f0             	push   -0x10(%ebp)
8010585a:	e8 bd c3 ff ff       	call   80101c1c <iunlockput>
8010585f:	83 c4 10             	add    $0x10,%esp

  end_op();
80105862:	e8 62 d8 ff ff       	call   801030c9 <end_op>

  return 0;
80105867:	b8 00 00 00 00       	mov    $0x0,%eax
8010586c:	eb 1c                	jmp    8010588a <sys_unlink+0x1e4>
    goto bad;
8010586e:	90                   	nop
8010586f:	eb 01                	jmp    80105872 <sys_unlink+0x1cc>
    goto bad;
80105871:	90                   	nop

bad:
  iunlockput(dp);
80105872:	83 ec 0c             	sub    $0xc,%esp
80105875:	ff 75 f4             	push   -0xc(%ebp)
80105878:	e8 9f c3 ff ff       	call   80101c1c <iunlockput>
8010587d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105880:	e8 44 d8 ff ff       	call   801030c9 <end_op>
  return -1;
80105885:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010588a:	c9                   	leave  
8010588b:	c3                   	ret    

8010588c <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010588c:	55                   	push   %ebp
8010588d:	89 e5                	mov    %esp,%ebp
8010588f:	83 ec 38             	sub    $0x38,%esp
80105892:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105895:	8b 55 10             	mov    0x10(%ebp),%edx
80105898:	8b 45 14             	mov    0x14(%ebp),%eax
8010589b:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010589f:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801058a3:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801058a7:	83 ec 08             	sub    $0x8,%esp
801058aa:	8d 45 de             	lea    -0x22(%ebp),%eax
801058ad:	50                   	push   %eax
801058ae:	ff 75 08             	push   0x8(%ebp)
801058b1:	e8 84 cc ff ff       	call   8010253a <nameiparent>
801058b6:	83 c4 10             	add    $0x10,%esp
801058b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058c0:	75 0a                	jne    801058cc <create+0x40>
    return 0;
801058c2:	b8 00 00 00 00       	mov    $0x0,%eax
801058c7:	e9 90 01 00 00       	jmp    80105a5c <create+0x1d0>
  ilock(dp);
801058cc:	83 ec 0c             	sub    $0xc,%esp
801058cf:	ff 75 f4             	push   -0xc(%ebp)
801058d2:	e8 14 c1 ff ff       	call   801019eb <ilock>
801058d7:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801058da:	83 ec 04             	sub    $0x4,%esp
801058dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058e0:	50                   	push   %eax
801058e1:	8d 45 de             	lea    -0x22(%ebp),%eax
801058e4:	50                   	push   %eax
801058e5:	ff 75 f4             	push   -0xc(%ebp)
801058e8:	e8 e0 c8 ff ff       	call   801021cd <dirlookup>
801058ed:	83 c4 10             	add    $0x10,%esp
801058f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801058f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058f7:	74 50                	je     80105949 <create+0xbd>
    iunlockput(dp);
801058f9:	83 ec 0c             	sub    $0xc,%esp
801058fc:	ff 75 f4             	push   -0xc(%ebp)
801058ff:	e8 18 c3 ff ff       	call   80101c1c <iunlockput>
80105904:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105907:	83 ec 0c             	sub    $0xc,%esp
8010590a:	ff 75 f0             	push   -0x10(%ebp)
8010590d:	e8 d9 c0 ff ff       	call   801019eb <ilock>
80105912:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105915:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010591a:	75 15                	jne    80105931 <create+0xa5>
8010591c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010591f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105923:	66 83 f8 02          	cmp    $0x2,%ax
80105927:	75 08                	jne    80105931 <create+0xa5>
      return ip;
80105929:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010592c:	e9 2b 01 00 00       	jmp    80105a5c <create+0x1d0>
    iunlockput(ip);
80105931:	83 ec 0c             	sub    $0xc,%esp
80105934:	ff 75 f0             	push   -0x10(%ebp)
80105937:	e8 e0 c2 ff ff       	call   80101c1c <iunlockput>
8010593c:	83 c4 10             	add    $0x10,%esp
    return 0;
8010593f:	b8 00 00 00 00       	mov    $0x0,%eax
80105944:	e9 13 01 00 00       	jmp    80105a5c <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105949:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010594d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105950:	8b 00                	mov    (%eax),%eax
80105952:	83 ec 08             	sub    $0x8,%esp
80105955:	52                   	push   %edx
80105956:	50                   	push   %eax
80105957:	e8 db bd ff ff       	call   80101737 <ialloc>
8010595c:	83 c4 10             	add    $0x10,%esp
8010595f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105962:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105966:	75 0d                	jne    80105975 <create+0xe9>
    panic("create: ialloc");
80105968:	83 ec 0c             	sub    $0xc,%esp
8010596b:	68 8c ab 10 80       	push   $0x8010ab8c
80105970:	e8 34 ac ff ff       	call   801005a9 <panic>

  ilock(ip);
80105975:	83 ec 0c             	sub    $0xc,%esp
80105978:	ff 75 f0             	push   -0x10(%ebp)
8010597b:	e8 6b c0 ff ff       	call   801019eb <ilock>
80105980:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105983:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105986:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010598a:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
8010598e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105991:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105995:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105999:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010599c:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801059a2:	83 ec 0c             	sub    $0xc,%esp
801059a5:	ff 75 f0             	push   -0x10(%ebp)
801059a8:	e8 61 be ff ff       	call   8010180e <iupdate>
801059ad:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801059b0:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801059b5:	75 6a                	jne    80105a21 <create+0x195>
    dp->nlink++;  // for ".."
801059b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ba:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059be:	83 c0 01             	add    $0x1,%eax
801059c1:	89 c2                	mov    %eax,%edx
801059c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c6:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801059ca:	83 ec 0c             	sub    $0xc,%esp
801059cd:	ff 75 f4             	push   -0xc(%ebp)
801059d0:	e8 39 be ff ff       	call   8010180e <iupdate>
801059d5:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801059d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059db:	8b 40 04             	mov    0x4(%eax),%eax
801059de:	83 ec 04             	sub    $0x4,%esp
801059e1:	50                   	push   %eax
801059e2:	68 66 ab 10 80       	push   $0x8010ab66
801059e7:	ff 75 f0             	push   -0x10(%ebp)
801059ea:	e8 98 c8 ff ff       	call   80102287 <dirlink>
801059ef:	83 c4 10             	add    $0x10,%esp
801059f2:	85 c0                	test   %eax,%eax
801059f4:	78 1e                	js     80105a14 <create+0x188>
801059f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f9:	8b 40 04             	mov    0x4(%eax),%eax
801059fc:	83 ec 04             	sub    $0x4,%esp
801059ff:	50                   	push   %eax
80105a00:	68 68 ab 10 80       	push   $0x8010ab68
80105a05:	ff 75 f0             	push   -0x10(%ebp)
80105a08:	e8 7a c8 ff ff       	call   80102287 <dirlink>
80105a0d:	83 c4 10             	add    $0x10,%esp
80105a10:	85 c0                	test   %eax,%eax
80105a12:	79 0d                	jns    80105a21 <create+0x195>
      panic("create dots");
80105a14:	83 ec 0c             	sub    $0xc,%esp
80105a17:	68 9b ab 10 80       	push   $0x8010ab9b
80105a1c:	e8 88 ab ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a24:	8b 40 04             	mov    0x4(%eax),%eax
80105a27:	83 ec 04             	sub    $0x4,%esp
80105a2a:	50                   	push   %eax
80105a2b:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a2e:	50                   	push   %eax
80105a2f:	ff 75 f4             	push   -0xc(%ebp)
80105a32:	e8 50 c8 ff ff       	call   80102287 <dirlink>
80105a37:	83 c4 10             	add    $0x10,%esp
80105a3a:	85 c0                	test   %eax,%eax
80105a3c:	79 0d                	jns    80105a4b <create+0x1bf>
    panic("create: dirlink");
80105a3e:	83 ec 0c             	sub    $0xc,%esp
80105a41:	68 a7 ab 10 80       	push   $0x8010aba7
80105a46:	e8 5e ab ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105a4b:	83 ec 0c             	sub    $0xc,%esp
80105a4e:	ff 75 f4             	push   -0xc(%ebp)
80105a51:	e8 c6 c1 ff ff       	call   80101c1c <iunlockput>
80105a56:	83 c4 10             	add    $0x10,%esp

  return ip;
80105a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105a5c:	c9                   	leave  
80105a5d:	c3                   	ret    

80105a5e <sys_open>:

int
sys_open(void)
{
80105a5e:	55                   	push   %ebp
80105a5f:	89 e5                	mov    %esp,%ebp
80105a61:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105a64:	83 ec 08             	sub    $0x8,%esp
80105a67:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105a6a:	50                   	push   %eax
80105a6b:	6a 00                	push   $0x0
80105a6d:	e8 ea f6 ff ff       	call   8010515c <argstr>
80105a72:	83 c4 10             	add    $0x10,%esp
80105a75:	85 c0                	test   %eax,%eax
80105a77:	78 15                	js     80105a8e <sys_open+0x30>
80105a79:	83 ec 08             	sub    $0x8,%esp
80105a7c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a7f:	50                   	push   %eax
80105a80:	6a 01                	push   $0x1
80105a82:	e8 40 f6 ff ff       	call   801050c7 <argint>
80105a87:	83 c4 10             	add    $0x10,%esp
80105a8a:	85 c0                	test   %eax,%eax
80105a8c:	79 0a                	jns    80105a98 <sys_open+0x3a>
    return -1;
80105a8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a93:	e9 61 01 00 00       	jmp    80105bf9 <sys_open+0x19b>

  begin_op();
80105a98:	e8 a0 d5 ff ff       	call   8010303d <begin_op>

  if(omode & O_CREATE){
80105a9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105aa0:	25 00 02 00 00       	and    $0x200,%eax
80105aa5:	85 c0                	test   %eax,%eax
80105aa7:	74 2a                	je     80105ad3 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105aa9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105aac:	6a 00                	push   $0x0
80105aae:	6a 00                	push   $0x0
80105ab0:	6a 02                	push   $0x2
80105ab2:	50                   	push   %eax
80105ab3:	e8 d4 fd ff ff       	call   8010588c <create>
80105ab8:	83 c4 10             	add    $0x10,%esp
80105abb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105abe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ac2:	75 75                	jne    80105b39 <sys_open+0xdb>
      end_op();
80105ac4:	e8 00 d6 ff ff       	call   801030c9 <end_op>
      return -1;
80105ac9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ace:	e9 26 01 00 00       	jmp    80105bf9 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105ad3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ad6:	83 ec 0c             	sub    $0xc,%esp
80105ad9:	50                   	push   %eax
80105ada:	e8 3f ca ff ff       	call   8010251e <namei>
80105adf:	83 c4 10             	add    $0x10,%esp
80105ae2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ae5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ae9:	75 0f                	jne    80105afa <sys_open+0x9c>
      end_op();
80105aeb:	e8 d9 d5 ff ff       	call   801030c9 <end_op>
      return -1;
80105af0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af5:	e9 ff 00 00 00       	jmp    80105bf9 <sys_open+0x19b>
    }
    ilock(ip);
80105afa:	83 ec 0c             	sub    $0xc,%esp
80105afd:	ff 75 f4             	push   -0xc(%ebp)
80105b00:	e8 e6 be ff ff       	call   801019eb <ilock>
80105b05:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b0f:	66 83 f8 01          	cmp    $0x1,%ax
80105b13:	75 24                	jne    80105b39 <sys_open+0xdb>
80105b15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b18:	85 c0                	test   %eax,%eax
80105b1a:	74 1d                	je     80105b39 <sys_open+0xdb>
      iunlockput(ip);
80105b1c:	83 ec 0c             	sub    $0xc,%esp
80105b1f:	ff 75 f4             	push   -0xc(%ebp)
80105b22:	e8 f5 c0 ff ff       	call   80101c1c <iunlockput>
80105b27:	83 c4 10             	add    $0x10,%esp
      end_op();
80105b2a:	e8 9a d5 ff ff       	call   801030c9 <end_op>
      return -1;
80105b2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b34:	e9 c0 00 00 00       	jmp    80105bf9 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105b39:	e8 a0 b4 ff ff       	call   80100fde <filealloc>
80105b3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b41:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b45:	74 17                	je     80105b5e <sys_open+0x100>
80105b47:	83 ec 0c             	sub    $0xc,%esp
80105b4a:	ff 75 f0             	push   -0x10(%ebp)
80105b4d:	e8 33 f7 ff ff       	call   80105285 <fdalloc>
80105b52:	83 c4 10             	add    $0x10,%esp
80105b55:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105b58:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105b5c:	79 2e                	jns    80105b8c <sys_open+0x12e>
    if(f)
80105b5e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b62:	74 0e                	je     80105b72 <sys_open+0x114>
      fileclose(f);
80105b64:	83 ec 0c             	sub    $0xc,%esp
80105b67:	ff 75 f0             	push   -0x10(%ebp)
80105b6a:	e8 2d b5 ff ff       	call   8010109c <fileclose>
80105b6f:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105b72:	83 ec 0c             	sub    $0xc,%esp
80105b75:	ff 75 f4             	push   -0xc(%ebp)
80105b78:	e8 9f c0 ff ff       	call   80101c1c <iunlockput>
80105b7d:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b80:	e8 44 d5 ff ff       	call   801030c9 <end_op>
    return -1;
80105b85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b8a:	eb 6d                	jmp    80105bf9 <sys_open+0x19b>
  }
  iunlock(ip);
80105b8c:	83 ec 0c             	sub    $0xc,%esp
80105b8f:	ff 75 f4             	push   -0xc(%ebp)
80105b92:	e8 67 bf ff ff       	call   80101afe <iunlock>
80105b97:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b9a:	e8 2a d5 ff ff       	call   801030c9 <end_op>

  f->type = FD_INODE;
80105b9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba2:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bab:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bae:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105bbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bbe:	83 e0 01             	and    $0x1,%eax
80105bc1:	85 c0                	test   %eax,%eax
80105bc3:	0f 94 c0             	sete   %al
80105bc6:	89 c2                	mov    %eax,%edx
80105bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bcb:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105bce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bd1:	83 e0 01             	and    $0x1,%eax
80105bd4:	85 c0                	test   %eax,%eax
80105bd6:	75 0a                	jne    80105be2 <sys_open+0x184>
80105bd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bdb:	83 e0 02             	and    $0x2,%eax
80105bde:	85 c0                	test   %eax,%eax
80105be0:	74 07                	je     80105be9 <sys_open+0x18b>
80105be2:	b8 01 00 00 00       	mov    $0x1,%eax
80105be7:	eb 05                	jmp    80105bee <sys_open+0x190>
80105be9:	b8 00 00 00 00       	mov    $0x0,%eax
80105bee:	89 c2                	mov    %eax,%edx
80105bf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf3:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105bf6:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105bf9:	c9                   	leave  
80105bfa:	c3                   	ret    

80105bfb <sys_mkdir>:

int
sys_mkdir(void)
{
80105bfb:	55                   	push   %ebp
80105bfc:	89 e5                	mov    %esp,%ebp
80105bfe:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105c01:	e8 37 d4 ff ff       	call   8010303d <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105c06:	83 ec 08             	sub    $0x8,%esp
80105c09:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c0c:	50                   	push   %eax
80105c0d:	6a 00                	push   $0x0
80105c0f:	e8 48 f5 ff ff       	call   8010515c <argstr>
80105c14:	83 c4 10             	add    $0x10,%esp
80105c17:	85 c0                	test   %eax,%eax
80105c19:	78 1b                	js     80105c36 <sys_mkdir+0x3b>
80105c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1e:	6a 00                	push   $0x0
80105c20:	6a 00                	push   $0x0
80105c22:	6a 01                	push   $0x1
80105c24:	50                   	push   %eax
80105c25:	e8 62 fc ff ff       	call   8010588c <create>
80105c2a:	83 c4 10             	add    $0x10,%esp
80105c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c34:	75 0c                	jne    80105c42 <sys_mkdir+0x47>
    end_op();
80105c36:	e8 8e d4 ff ff       	call   801030c9 <end_op>
    return -1;
80105c3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c40:	eb 18                	jmp    80105c5a <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105c42:	83 ec 0c             	sub    $0xc,%esp
80105c45:	ff 75 f4             	push   -0xc(%ebp)
80105c48:	e8 cf bf ff ff       	call   80101c1c <iunlockput>
80105c4d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c50:	e8 74 d4 ff ff       	call   801030c9 <end_op>
  return 0;
80105c55:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c5a:	c9                   	leave  
80105c5b:	c3                   	ret    

80105c5c <sys_mknod>:

int
sys_mknod(void)
{
80105c5c:	55                   	push   %ebp
80105c5d:	89 e5                	mov    %esp,%ebp
80105c5f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105c62:	e8 d6 d3 ff ff       	call   8010303d <begin_op>
  if((argstr(0, &path)) < 0 ||
80105c67:	83 ec 08             	sub    $0x8,%esp
80105c6a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c6d:	50                   	push   %eax
80105c6e:	6a 00                	push   $0x0
80105c70:	e8 e7 f4 ff ff       	call   8010515c <argstr>
80105c75:	83 c4 10             	add    $0x10,%esp
80105c78:	85 c0                	test   %eax,%eax
80105c7a:	78 4f                	js     80105ccb <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105c7c:	83 ec 08             	sub    $0x8,%esp
80105c7f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c82:	50                   	push   %eax
80105c83:	6a 01                	push   $0x1
80105c85:	e8 3d f4 ff ff       	call   801050c7 <argint>
80105c8a:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105c8d:	85 c0                	test   %eax,%eax
80105c8f:	78 3a                	js     80105ccb <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105c91:	83 ec 08             	sub    $0x8,%esp
80105c94:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c97:	50                   	push   %eax
80105c98:	6a 02                	push   $0x2
80105c9a:	e8 28 f4 ff ff       	call   801050c7 <argint>
80105c9f:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105ca2:	85 c0                	test   %eax,%eax
80105ca4:	78 25                	js     80105ccb <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105ca6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ca9:	0f bf c8             	movswl %ax,%ecx
80105cac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105caf:	0f bf d0             	movswl %ax,%edx
80105cb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb5:	51                   	push   %ecx
80105cb6:	52                   	push   %edx
80105cb7:	6a 03                	push   $0x3
80105cb9:	50                   	push   %eax
80105cba:	e8 cd fb ff ff       	call   8010588c <create>
80105cbf:	83 c4 10             	add    $0x10,%esp
80105cc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105cc5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cc9:	75 0c                	jne    80105cd7 <sys_mknod+0x7b>
    end_op();
80105ccb:	e8 f9 d3 ff ff       	call   801030c9 <end_op>
    return -1;
80105cd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd5:	eb 18                	jmp    80105cef <sys_mknod+0x93>
  }
  iunlockput(ip);
80105cd7:	83 ec 0c             	sub    $0xc,%esp
80105cda:	ff 75 f4             	push   -0xc(%ebp)
80105cdd:	e8 3a bf ff ff       	call   80101c1c <iunlockput>
80105ce2:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ce5:	e8 df d3 ff ff       	call   801030c9 <end_op>
  return 0;
80105cea:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cef:	c9                   	leave  
80105cf0:	c3                   	ret    

80105cf1 <sys_chdir>:

int
sys_chdir(void)
{
80105cf1:	55                   	push   %ebp
80105cf2:	89 e5                	mov    %esp,%ebp
80105cf4:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105cf7:	e8 35 dd ff ff       	call   80103a31 <myproc>
80105cfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105cff:	e8 39 d3 ff ff       	call   8010303d <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105d04:	83 ec 08             	sub    $0x8,%esp
80105d07:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d0a:	50                   	push   %eax
80105d0b:	6a 00                	push   $0x0
80105d0d:	e8 4a f4 ff ff       	call   8010515c <argstr>
80105d12:	83 c4 10             	add    $0x10,%esp
80105d15:	85 c0                	test   %eax,%eax
80105d17:	78 18                	js     80105d31 <sys_chdir+0x40>
80105d19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d1c:	83 ec 0c             	sub    $0xc,%esp
80105d1f:	50                   	push   %eax
80105d20:	e8 f9 c7 ff ff       	call   8010251e <namei>
80105d25:	83 c4 10             	add    $0x10,%esp
80105d28:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d2b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d2f:	75 0c                	jne    80105d3d <sys_chdir+0x4c>
    end_op();
80105d31:	e8 93 d3 ff ff       	call   801030c9 <end_op>
    return -1;
80105d36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d3b:	eb 68                	jmp    80105da5 <sys_chdir+0xb4>
  }
  ilock(ip);
80105d3d:	83 ec 0c             	sub    $0xc,%esp
80105d40:	ff 75 f0             	push   -0x10(%ebp)
80105d43:	e8 a3 bc ff ff       	call   801019eb <ilock>
80105d48:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d4e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d52:	66 83 f8 01          	cmp    $0x1,%ax
80105d56:	74 1a                	je     80105d72 <sys_chdir+0x81>
    iunlockput(ip);
80105d58:	83 ec 0c             	sub    $0xc,%esp
80105d5b:	ff 75 f0             	push   -0x10(%ebp)
80105d5e:	e8 b9 be ff ff       	call   80101c1c <iunlockput>
80105d63:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d66:	e8 5e d3 ff ff       	call   801030c9 <end_op>
    return -1;
80105d6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d70:	eb 33                	jmp    80105da5 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105d72:	83 ec 0c             	sub    $0xc,%esp
80105d75:	ff 75 f0             	push   -0x10(%ebp)
80105d78:	e8 81 bd ff ff       	call   80101afe <iunlock>
80105d7d:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d83:	8b 40 68             	mov    0x68(%eax),%eax
80105d86:	83 ec 0c             	sub    $0xc,%esp
80105d89:	50                   	push   %eax
80105d8a:	e8 bd bd ff ff       	call   80101b4c <iput>
80105d8f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d92:	e8 32 d3 ff ff       	call   801030c9 <end_op>
  curproc->cwd = ip;
80105d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d9d:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105da0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105da5:	c9                   	leave  
80105da6:	c3                   	ret    

80105da7 <sys_exec>:

int
sys_exec(void)
{
80105da7:	55                   	push   %ebp
80105da8:	89 e5                	mov    %esp,%ebp
80105daa:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105db0:	83 ec 08             	sub    $0x8,%esp
80105db3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105db6:	50                   	push   %eax
80105db7:	6a 00                	push   $0x0
80105db9:	e8 9e f3 ff ff       	call   8010515c <argstr>
80105dbe:	83 c4 10             	add    $0x10,%esp
80105dc1:	85 c0                	test   %eax,%eax
80105dc3:	78 18                	js     80105ddd <sys_exec+0x36>
80105dc5:	83 ec 08             	sub    $0x8,%esp
80105dc8:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105dce:	50                   	push   %eax
80105dcf:	6a 01                	push   $0x1
80105dd1:	e8 f1 f2 ff ff       	call   801050c7 <argint>
80105dd6:	83 c4 10             	add    $0x10,%esp
80105dd9:	85 c0                	test   %eax,%eax
80105ddb:	79 0a                	jns    80105de7 <sys_exec+0x40>
    return -1;
80105ddd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de2:	e9 c6 00 00 00       	jmp    80105ead <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105de7:	83 ec 04             	sub    $0x4,%esp
80105dea:	68 80 00 00 00       	push   $0x80
80105def:	6a 00                	push   $0x0
80105df1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105df7:	50                   	push   %eax
80105df8:	e8 9f ef ff ff       	call   80104d9c <memset>
80105dfd:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105e00:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0a:	83 f8 1f             	cmp    $0x1f,%eax
80105e0d:	76 0a                	jbe    80105e19 <sys_exec+0x72>
      return -1;
80105e0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e14:	e9 94 00 00 00       	jmp    80105ead <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1c:	c1 e0 02             	shl    $0x2,%eax
80105e1f:	89 c2                	mov    %eax,%edx
80105e21:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105e27:	01 c2                	add    %eax,%edx
80105e29:	83 ec 08             	sub    $0x8,%esp
80105e2c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105e32:	50                   	push   %eax
80105e33:	52                   	push   %edx
80105e34:	e8 ed f1 ff ff       	call   80105026 <fetchint>
80105e39:	83 c4 10             	add    $0x10,%esp
80105e3c:	85 c0                	test   %eax,%eax
80105e3e:	79 07                	jns    80105e47 <sys_exec+0xa0>
      return -1;
80105e40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e45:	eb 66                	jmp    80105ead <sys_exec+0x106>
    if(uarg == 0){
80105e47:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e4d:	85 c0                	test   %eax,%eax
80105e4f:	75 27                	jne    80105e78 <sys_exec+0xd1>
      argv[i] = 0;
80105e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e54:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105e5b:	00 00 00 00 
      break;
80105e5f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e63:	83 ec 08             	sub    $0x8,%esp
80105e66:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e6c:	52                   	push   %edx
80105e6d:	50                   	push   %eax
80105e6e:	e8 0d ad ff ff       	call   80100b80 <exec>
80105e73:	83 c4 10             	add    $0x10,%esp
80105e76:	eb 35                	jmp    80105ead <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105e78:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e81:	c1 e0 02             	shl    $0x2,%eax
80105e84:	01 c2                	add    %eax,%edx
80105e86:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e8c:	83 ec 08             	sub    $0x8,%esp
80105e8f:	52                   	push   %edx
80105e90:	50                   	push   %eax
80105e91:	e8 cf f1 ff ff       	call   80105065 <fetchstr>
80105e96:	83 c4 10             	add    $0x10,%esp
80105e99:	85 c0                	test   %eax,%eax
80105e9b:	79 07                	jns    80105ea4 <sys_exec+0xfd>
      return -1;
80105e9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ea2:	eb 09                	jmp    80105ead <sys_exec+0x106>
  for(i=0;; i++){
80105ea4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ea8:	e9 5a ff ff ff       	jmp    80105e07 <sys_exec+0x60>
}
80105ead:	c9                   	leave  
80105eae:	c3                   	ret    

80105eaf <sys_pipe>:

int
sys_pipe(void)
{
80105eaf:	55                   	push   %ebp
80105eb0:	89 e5                	mov    %esp,%ebp
80105eb2:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105eb5:	83 ec 04             	sub    $0x4,%esp
80105eb8:	6a 08                	push   $0x8
80105eba:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ebd:	50                   	push   %eax
80105ebe:	6a 00                	push   $0x0
80105ec0:	e8 2f f2 ff ff       	call   801050f4 <argptr>
80105ec5:	83 c4 10             	add    $0x10,%esp
80105ec8:	85 c0                	test   %eax,%eax
80105eca:	79 0a                	jns    80105ed6 <sys_pipe+0x27>
    return -1;
80105ecc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed1:	e9 ae 00 00 00       	jmp    80105f84 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105ed6:	83 ec 08             	sub    $0x8,%esp
80105ed9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105edc:	50                   	push   %eax
80105edd:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ee0:	50                   	push   %eax
80105ee1:	e8 88 d6 ff ff       	call   8010356e <pipealloc>
80105ee6:	83 c4 10             	add    $0x10,%esp
80105ee9:	85 c0                	test   %eax,%eax
80105eeb:	79 0a                	jns    80105ef7 <sys_pipe+0x48>
    return -1;
80105eed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef2:	e9 8d 00 00 00       	jmp    80105f84 <sys_pipe+0xd5>
  fd0 = -1;
80105ef7:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105efe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f01:	83 ec 0c             	sub    $0xc,%esp
80105f04:	50                   	push   %eax
80105f05:	e8 7b f3 ff ff       	call   80105285 <fdalloc>
80105f0a:	83 c4 10             	add    $0x10,%esp
80105f0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f14:	78 18                	js     80105f2e <sys_pipe+0x7f>
80105f16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f19:	83 ec 0c             	sub    $0xc,%esp
80105f1c:	50                   	push   %eax
80105f1d:	e8 63 f3 ff ff       	call   80105285 <fdalloc>
80105f22:	83 c4 10             	add    $0x10,%esp
80105f25:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f2c:	79 3e                	jns    80105f6c <sys_pipe+0xbd>
    if(fd0 >= 0)
80105f2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f32:	78 13                	js     80105f47 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105f34:	e8 f8 da ff ff       	call   80103a31 <myproc>
80105f39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f3c:	83 c2 08             	add    $0x8,%edx
80105f3f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105f46:	00 
    fileclose(rf);
80105f47:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f4a:	83 ec 0c             	sub    $0xc,%esp
80105f4d:	50                   	push   %eax
80105f4e:	e8 49 b1 ff ff       	call   8010109c <fileclose>
80105f53:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105f56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f59:	83 ec 0c             	sub    $0xc,%esp
80105f5c:	50                   	push   %eax
80105f5d:	e8 3a b1 ff ff       	call   8010109c <fileclose>
80105f62:	83 c4 10             	add    $0x10,%esp
    return -1;
80105f65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f6a:	eb 18                	jmp    80105f84 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105f6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f72:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105f74:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f77:	8d 50 04             	lea    0x4(%eax),%edx
80105f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f7d:	89 02                	mov    %eax,(%edx)
  return 0;
80105f7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f84:	c9                   	leave  
80105f85:	c3                   	ret    

80105f86 <sys_fork>:
  struct proc proc[NPROC];
} ptable;

int
sys_fork(void)
{
80105f86:	55                   	push   %ebp
80105f87:	89 e5                	mov    %esp,%ebp
80105f89:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105f8c:	e8 fa dd ff ff       	call   80103d8b <fork>
}
80105f91:	c9                   	leave  
80105f92:	c3                   	ret    

80105f93 <sys_exit>:

int
sys_exit(void)
{
80105f93:	55                   	push   %ebp
80105f94:	89 e5                	mov    %esp,%ebp
80105f96:	83 ec 08             	sub    $0x8,%esp
  exit();
80105f99:	e8 66 df ff ff       	call   80103f04 <exit>
  return 0;  // not reached
80105f9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fa3:	c9                   	leave  
80105fa4:	c3                   	ret    

80105fa5 <sys_wait>:

int
sys_wait(void)
{
80105fa5:	55                   	push   %ebp
80105fa6:	89 e5                	mov    %esp,%ebp
80105fa8:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105fab:	e8 b8 e0 ff ff       	call   80104068 <wait>
}
80105fb0:	c9                   	leave  
80105fb1:	c3                   	ret    

80105fb2 <sys_kill>:

int
sys_kill(void)
{
80105fb2:	55                   	push   %ebp
80105fb3:	89 e5                	mov    %esp,%ebp
80105fb5:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105fb8:	83 ec 08             	sub    $0x8,%esp
80105fbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fbe:	50                   	push   %eax
80105fbf:	6a 00                	push   $0x0
80105fc1:	e8 01 f1 ff ff       	call   801050c7 <argint>
80105fc6:	83 c4 10             	add    $0x10,%esp
80105fc9:	85 c0                	test   %eax,%eax
80105fcb:	79 07                	jns    80105fd4 <sys_kill+0x22>
    return -1;
80105fcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd2:	eb 0f                	jmp    80105fe3 <sys_kill+0x31>
  return kill(pid);
80105fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd7:	83 ec 0c             	sub    $0xc,%esp
80105fda:	50                   	push   %eax
80105fdb:	e8 0d e8 ff ff       	call   801047ed <kill>
80105fe0:	83 c4 10             	add    $0x10,%esp
}
80105fe3:	c9                   	leave  
80105fe4:	c3                   	ret    

80105fe5 <sys_getpid>:

int
sys_getpid(void)
{
80105fe5:	55                   	push   %ebp
80105fe6:	89 e5                	mov    %esp,%ebp
80105fe8:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105feb:	e8 41 da ff ff       	call   80103a31 <myproc>
80105ff0:	8b 40 10             	mov    0x10(%eax),%eax
}
80105ff3:	c9                   	leave  
80105ff4:	c3                   	ret    

80105ff5 <sys_sbrk>:

int
sys_sbrk(void)
{
80105ff5:	55                   	push   %ebp
80105ff6:	89 e5                	mov    %esp,%ebp
80105ff8:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105ffb:	83 ec 08             	sub    $0x8,%esp
80105ffe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106001:	50                   	push   %eax
80106002:	6a 00                	push   $0x0
80106004:	e8 be f0 ff ff       	call   801050c7 <argint>
80106009:	83 c4 10             	add    $0x10,%esp
8010600c:	85 c0                	test   %eax,%eax
8010600e:	79 07                	jns    80106017 <sys_sbrk+0x22>
    return -1;
80106010:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106015:	eb 27                	jmp    8010603e <sys_sbrk+0x49>
  addr = myproc()->sz;
80106017:	e8 15 da ff ff       	call   80103a31 <myproc>
8010601c:	8b 00                	mov    (%eax),%eax
8010601e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106021:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106024:	83 ec 0c             	sub    $0xc,%esp
80106027:	50                   	push   %eax
80106028:	e8 c3 dc ff ff       	call   80103cf0 <growproc>
8010602d:	83 c4 10             	add    $0x10,%esp
80106030:	85 c0                	test   %eax,%eax
80106032:	79 07                	jns    8010603b <sys_sbrk+0x46>
    return -1;
80106034:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106039:	eb 03                	jmp    8010603e <sys_sbrk+0x49>
  return addr;
8010603b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010603e:	c9                   	leave  
8010603f:	c3                   	ret    

80106040 <sys_sleep>:

int
sys_sleep(void)
{
80106040:	55                   	push   %ebp
80106041:	89 e5                	mov    %esp,%ebp
80106043:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106046:	83 ec 08             	sub    $0x8,%esp
80106049:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010604c:	50                   	push   %eax
8010604d:	6a 00                	push   $0x0
8010604f:	e8 73 f0 ff ff       	call   801050c7 <argint>
80106054:	83 c4 10             	add    $0x10,%esp
80106057:	85 c0                	test   %eax,%eax
80106059:	79 07                	jns    80106062 <sys_sleep+0x22>
    return -1;
8010605b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106060:	eb 76                	jmp    801060d8 <sys_sleep+0x98>
  acquire(&tickslock);
80106062:	83 ec 0c             	sub    $0xc,%esp
80106065:	68 40 74 19 80       	push   $0x80197440
8010606a:	e8 b7 ea ff ff       	call   80104b26 <acquire>
8010606f:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106072:	a1 74 74 19 80       	mov    0x80197474,%eax
80106077:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010607a:	eb 38                	jmp    801060b4 <sys_sleep+0x74>
    if(myproc()->killed){
8010607c:	e8 b0 d9 ff ff       	call   80103a31 <myproc>
80106081:	8b 40 24             	mov    0x24(%eax),%eax
80106084:	85 c0                	test   %eax,%eax
80106086:	74 17                	je     8010609f <sys_sleep+0x5f>
      release(&tickslock);
80106088:	83 ec 0c             	sub    $0xc,%esp
8010608b:	68 40 74 19 80       	push   $0x80197440
80106090:	e8 ff ea ff ff       	call   80104b94 <release>
80106095:	83 c4 10             	add    $0x10,%esp
      return -1;
80106098:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010609d:	eb 39                	jmp    801060d8 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
8010609f:	83 ec 08             	sub    $0x8,%esp
801060a2:	68 40 74 19 80       	push   $0x80197440
801060a7:	68 74 74 19 80       	push   $0x80197474
801060ac:	e8 1b e6 ff ff       	call   801046cc <sleep>
801060b1:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801060b4:	a1 74 74 19 80       	mov    0x80197474,%eax
801060b9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801060bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060bf:	39 d0                	cmp    %edx,%eax
801060c1:	72 b9                	jb     8010607c <sys_sleep+0x3c>
  }
  release(&tickslock);
801060c3:	83 ec 0c             	sub    $0xc,%esp
801060c6:	68 40 74 19 80       	push   $0x80197440
801060cb:	e8 c4 ea ff ff       	call   80104b94 <release>
801060d0:	83 c4 10             	add    $0x10,%esp
  return 0;
801060d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060d8:	c9                   	leave  
801060d9:	c3                   	ret    

801060da <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801060da:	55                   	push   %ebp
801060db:	89 e5                	mov    %esp,%ebp
801060dd:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801060e0:	83 ec 0c             	sub    $0xc,%esp
801060e3:	68 40 74 19 80       	push   $0x80197440
801060e8:	e8 39 ea ff ff       	call   80104b26 <acquire>
801060ed:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801060f0:	a1 74 74 19 80       	mov    0x80197474,%eax
801060f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801060f8:	83 ec 0c             	sub    $0xc,%esp
801060fb:	68 40 74 19 80       	push   $0x80197440
80106100:	e8 8f ea ff ff       	call   80104b94 <release>
80106105:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106108:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010610b:	c9                   	leave  
8010610c:	c3                   	ret    

8010610d <sys_uthread_init>:

// 이거 추가
int
sys_uthread_init(void)
{
8010610d:	55                   	push   %ebp
8010610e:	89 e5                	mov    %esp,%ebp
80106110:	53                   	push   %ebx
80106111:	83 ec 14             	sub    $0x14,%esp
  int addr;
  if (argint(0, &addr) < 0)
80106114:	83 ec 08             	sub    $0x8,%esp
80106117:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010611a:	50                   	push   %eax
8010611b:	6a 00                	push   $0x0
8010611d:	e8 a5 ef ff ff       	call   801050c7 <argint>
80106122:	83 c4 10             	add    $0x10,%esp
80106125:	85 c0                	test   %eax,%eax
80106127:	79 07                	jns    80106130 <sys_uthread_init+0x23>
    return -1;
80106129:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010612e:	eb 12                	jmp    80106142 <sys_uthread_init+0x35>
  myproc()->scheduler = addr;
80106130:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80106133:	e8 f9 d8 ff ff       	call   80103a31 <myproc>
80106138:	89 da                	mov    %ebx,%edx
8010613a:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
8010613d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106142:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106145:	c9                   	leave  
80106146:	c3                   	ret    

80106147 <sys_check_thread>:



int
sys_check_thread(void) {
80106147:	55                   	push   %ebp
80106148:	89 e5                	mov    %esp,%ebp
8010614a:	83 ec 18             	sub    $0x18,%esp
  int op;
  if (argint(0, &op) < 0)  // 사용자로부터 인자 하나 받음
8010614d:	83 ec 08             	sub    $0x8,%esp
80106150:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106153:	50                   	push   %eax
80106154:	6a 00                	push   $0x0
80106156:	e8 6c ef ff ff       	call   801050c7 <argint>
8010615b:	83 c4 10             	add    $0x10,%esp
8010615e:	85 c0                	test   %eax,%eax
80106160:	79 07                	jns    80106169 <sys_check_thread+0x22>
    return -1;
80106162:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106167:	eb 24                	jmp    8010618d <sys_check_thread+0x46>

  struct proc* p = myproc();
80106169:	e8 c3 d8 ff ff       	call   80103a31 <myproc>
8010616e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p->check_thread += op;  // +1 또는 -1
80106171:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106174:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
8010617a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617d:	01 c2                	add    %eax,%edx
8010617f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106182:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  return 0;
80106188:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010618d:	c9                   	leave  
8010618e:	c3                   	ret    

8010618f <sys_getpinfo>:


int
sys_getpinfo(void) {
8010618f:	55                   	push   %ebp
80106190:	89 e5                	mov    %esp,%ebp
80106192:	53                   	push   %ebx
80106193:	83 ec 14             	sub    $0x14,%esp
  struct pstat *ps;
  if (argptr(0, (void *)&ps, sizeof(*ps)) < 0)
80106196:	83 ec 04             	sub    $0x4,%esp
80106199:	68 00 0c 00 00       	push   $0xc00
8010619e:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061a1:	50                   	push   %eax
801061a2:	6a 00                	push   $0x0
801061a4:	e8 4b ef ff ff       	call   801050f4 <argptr>
801061a9:	83 c4 10             	add    $0x10,%esp
801061ac:	85 c0                	test   %eax,%eax
801061ae:	79 0a                	jns    801061ba <sys_getpinfo+0x2b>
    return -1;
801061b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061b5:	e9 21 01 00 00       	jmp    801062db <sys_getpinfo+0x14c>

  acquire(&ptable.lock);
801061ba:	83 ec 0c             	sub    $0xc,%esp
801061bd:	68 00 4b 19 80       	push   $0x80194b00
801061c2:	e8 5f e9 ff ff       	call   80104b26 <acquire>
801061c7:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
801061ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801061d1:	e9 e6 00 00 00       	jmp    801062bc <sys_getpinfo+0x12d>
    struct proc *p = &ptable.proc[i];
801061d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d9:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
801061df:	83 c0 30             	add    $0x30,%eax
801061e2:	05 00 4b 19 80       	add    $0x80194b00,%eax
801061e7:	83 c0 04             	add    $0x4,%eax
801061ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
    ps->inuse[i] = (p->state != UNUSED);
801061ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061f0:	8b 40 0c             	mov    0xc(%eax),%eax
801061f3:	85 c0                	test   %eax,%eax
801061f5:	0f 95 c2             	setne  %dl
801061f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061fb:	0f b6 ca             	movzbl %dl,%ecx
801061fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106201:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    ps->pid[i] = p->pid;
80106204:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106207:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010620a:	8b 52 10             	mov    0x10(%edx),%edx
8010620d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80106210:	83 c1 40             	add    $0x40,%ecx
80106213:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->priority[i] = proc_priority[i];
80106216:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106219:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010621c:	8b 14 95 00 42 19 80 	mov    -0x7fe6be00(,%edx,4),%edx
80106223:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80106226:	83 e9 80             	sub    $0xffffff80,%ecx
80106229:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->state[i] = p->state;
8010622c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010622f:	8b 50 0c             	mov    0xc(%eax),%edx
80106232:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106235:	89 d1                	mov    %edx,%ecx
80106237:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010623a:	81 c2 c0 00 00 00    	add    $0xc0,%edx
80106240:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    for (int j = 0; j < 4; j++) {
80106243:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010624a:	eb 66                	jmp    801062b2 <sys_getpinfo+0x123>
      ps->ticks[i][j] = proc_ticks[i][j];
8010624c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010624f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106252:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
80106259:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010625c:	01 ca                	add    %ecx,%edx
8010625e:	8b 14 95 00 43 19 80 	mov    -0x7fe6bd00(,%edx,4),%edx
80106265:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80106268:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
8010626f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106272:	01 d9                	add    %ebx,%ecx
80106274:	81 c1 00 01 00 00    	add    $0x100,%ecx
8010627a:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = proc_wait_ticks[i][j];
8010627d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106280:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106283:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
8010628a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010628d:	01 ca                	add    %ecx,%edx
8010628f:	8b 14 95 00 47 19 80 	mov    -0x7fe6b900(,%edx,4),%edx
80106296:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80106299:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
801062a0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801062a3:	01 d9                	add    %ebx,%ecx
801062a5:	81 c1 00 02 00 00    	add    $0x200,%ecx
801062ab:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
801062ae:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801062b2:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
801062b6:	7e 94                	jle    8010624c <sys_getpinfo+0xbd>
  for (int i = 0; i < NPROC; i++) {
801062b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801062bc:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801062c0:	0f 8e 10 ff ff ff    	jle    801061d6 <sys_getpinfo+0x47>
    }
  }
  release(&ptable.lock);
801062c6:	83 ec 0c             	sub    $0xc,%esp
801062c9:	68 00 4b 19 80       	push   $0x80194b00
801062ce:	e8 c1 e8 ff ff       	call   80104b94 <release>
801062d3:	83 c4 10             	add    $0x10,%esp
  return 0;
801062d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801062de:	c9                   	leave  
801062df:	c3                   	ret    

801062e0 <sys_setSchedPolicy>:


int
sys_setSchedPolicy(void) {
801062e0:	55                   	push   %ebp
801062e1:	89 e5                	mov    %esp,%ebp
801062e3:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
801062e6:	83 ec 08             	sub    $0x8,%esp
801062e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801062ec:	50                   	push   %eax
801062ed:	6a 00                	push   $0x0
801062ef:	e8 d3 ed ff ff       	call   801050c7 <argint>
801062f4:	83 c4 10             	add    $0x10,%esp
801062f7:	85 c0                	test   %eax,%eax
801062f9:	79 07                	jns    80106302 <sys_setSchedPolicy+0x22>
    return -1;
801062fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106300:	eb 31                	jmp    80106333 <sys_setSchedPolicy+0x53>
  
  pushcli();
80106302:	e8 8a e9 ff ff       	call   80104c91 <pushcli>
  mycpu()->sched_policy = policy;
80106307:	e8 ad d6 ff ff       	call   801039b9 <mycpu>
8010630c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010630f:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
80106315:	e8 c4 e9 ff ff       	call   80104cde <popcli>

  cprintf("✅ sched_policy set to %d\n", policy);
8010631a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631d:	83 ec 08             	sub    $0x8,%esp
80106320:	50                   	push   %eax
80106321:	68 b7 ab 10 80       	push   $0x8010abb7
80106326:	e8 c9 a0 ff ff       	call   801003f4 <cprintf>
8010632b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010632e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106333:	c9                   	leave  
80106334:	c3                   	ret    

80106335 <sys_yield>:

int
sys_yield(void)
{
80106335:	55                   	push   %ebp
80106336:	89 e5                	mov    %esp,%ebp
80106338:	83 ec 08             	sub    $0x8,%esp
  yield();
8010633b:	e8 cb e2 ff ff       	call   8010460b <yield>
  return 0;
80106340:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106345:	c9                   	leave  
80106346:	c3                   	ret    

80106347 <print_user_page_table>:

void 
print_user_page_table(struct proc *p) {
80106347:	55                   	push   %ebp
80106348:	89 e5                	mov    %esp,%ebp
8010634a:	83 ec 28             	sub    $0x28,%esp
  cprintf("START PAGE TABLE (pid %d)\n", p->pid);
8010634d:	8b 45 08             	mov    0x8(%ebp),%eax
80106350:	8b 40 10             	mov    0x10(%eax),%eax
80106353:	83 ec 08             	sub    $0x8,%esp
80106356:	50                   	push   %eax
80106357:	68 d3 ab 10 80       	push   $0x8010abd3
8010635c:	e8 93 a0 ff ff       	call   801003f4 <cprintf>
80106361:	83 c4 10             	add    $0x10,%esp
  pde_t *pgdir = p->pgdir;
80106364:	8b 45 08             	mov    0x8(%ebp),%eax
80106367:	8b 40 04             	mov    0x4(%eax),%eax
8010636a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(uint va = 0; va < KERNBASE; va += PGSIZE) {
8010636d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106374:	e9 a0 00 00 00       	jmp    80106419 <print_user_page_table+0xd2>
    pte_t *pte = walkpgdir(pgdir, (void*)va, 0);
80106379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637c:	83 ec 04             	sub    $0x4,%esp
8010637f:	6a 00                	push   $0x0
80106381:	50                   	push   %eax
80106382:	ff 75 f0             	push   -0x10(%ebp)
80106385:	e8 a0 15 00 00       	call   8010792a <walkpgdir>
8010638a:	83 c4 10             	add    $0x10,%esp
8010638d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(!pte)
80106390:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106394:	74 78                	je     8010640e <print_user_page_table+0xc7>
      continue;
    if(!(*pte & PTE_P))
80106396:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106399:	8b 00                	mov    (%eax),%eax
8010639b:	83 e0 01             	and    $0x1,%eax
8010639e:	85 c0                	test   %eax,%eax
801063a0:	74 6f                	je     80106411 <print_user_page_table+0xca>
      continue;
    // 페이지 번호 = va / PGSIZE
    int vpn = va / PGSIZE;
801063a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a5:	c1 e8 0c             	shr    $0xc,%eax
801063a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    char uork = (*pte & PTE_U) ? 'U' : 'K';
801063ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063ae:	8b 00                	mov    (%eax),%eax
801063b0:	83 e0 04             	and    $0x4,%eax
801063b3:	85 c0                	test   %eax,%eax
801063b5:	74 07                	je     801063be <print_user_page_table+0x77>
801063b7:	b8 55 00 00 00       	mov    $0x55,%eax
801063bc:	eb 05                	jmp    801063c3 <print_user_page_table+0x7c>
801063be:	b8 4b 00 00 00       	mov    $0x4b,%eax
801063c3:	88 45 e7             	mov    %al,-0x19(%ebp)
    char w = (*pte & PTE_W) ? 'W' : '-';
801063c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063c9:	8b 00                	mov    (%eax),%eax
801063cb:	83 e0 02             	and    $0x2,%eax
801063ce:	85 c0                	test   %eax,%eax
801063d0:	74 07                	je     801063d9 <print_user_page_table+0x92>
801063d2:	b8 57 00 00 00       	mov    $0x57,%eax
801063d7:	eb 05                	jmp    801063de <print_user_page_table+0x97>
801063d9:	b8 2d 00 00 00       	mov    $0x2d,%eax
801063de:	88 45 e6             	mov    %al,-0x1a(%ebp)
    uint ppn = PTE_ADDR(*pte) >> 12; // 물리 페이지 번호
801063e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063e4:	8b 00                	mov    (%eax),%eax
801063e6:	c1 e8 0c             	shr    $0xc,%eax
801063e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    cprintf("%d P %c %c %x\n", vpn, uork, w, ppn);
801063ec:	0f be 55 e6          	movsbl -0x1a(%ebp),%edx
801063f0:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
801063f4:	83 ec 0c             	sub    $0xc,%esp
801063f7:	ff 75 e0             	push   -0x20(%ebp)
801063fa:	52                   	push   %edx
801063fb:	50                   	push   %eax
801063fc:	ff 75 e8             	push   -0x18(%ebp)
801063ff:	68 ee ab 10 80       	push   $0x8010abee
80106404:	e8 eb 9f ff ff       	call   801003f4 <cprintf>
80106409:	83 c4 20             	add    $0x20,%esp
8010640c:	eb 04                	jmp    80106412 <print_user_page_table+0xcb>
      continue;
8010640e:	90                   	nop
8010640f:	eb 01                	jmp    80106412 <print_user_page_table+0xcb>
      continue;
80106411:	90                   	nop
  for(uint va = 0; va < KERNBASE; va += PGSIZE) {
80106412:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80106419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010641c:	85 c0                	test   %eax,%eax
8010641e:	0f 89 55 ff ff ff    	jns    80106379 <print_user_page_table+0x32>
  }
  cprintf("END PAGE TABLE\n");
80106424:	83 ec 0c             	sub    $0xc,%esp
80106427:	68 fd ab 10 80       	push   $0x8010abfd
8010642c:	e8 c3 9f ff ff       	call   801003f4 <cprintf>
80106431:	83 c4 10             	add    $0x10,%esp
}
80106434:	90                   	nop
80106435:	c9                   	leave  
80106436:	c3                   	ret    

80106437 <sys_printpt>:

int 
sys_printpt(void) {
80106437:	55                   	push   %ebp
80106438:	89 e5                	mov    %esp,%ebp
8010643a:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if(argint(0, &pid) < 0)
8010643d:	83 ec 08             	sub    $0x8,%esp
80106440:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106443:	50                   	push   %eax
80106444:	6a 00                	push   $0x0
80106446:	e8 7c ec ff ff       	call   801050c7 <argint>
8010644b:	83 c4 10             	add    $0x10,%esp
8010644e:	85 c0                	test   %eax,%eax
80106450:	79 07                	jns    80106459 <sys_printpt+0x22>
    return -1;
80106452:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106457:	eb 32                	jmp    8010648b <sys_printpt+0x54>
  struct proc *p = find_proc_by_pid(pid); // 아래에 별도 구현
80106459:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010645c:	83 ec 0c             	sub    $0xc,%esp
8010645f:	50                   	push   %eax
80106460:	e8 0c e5 ff ff       	call   80104971 <find_proc_by_pid>
80106465:	83 c4 10             	add    $0x10,%esp
80106468:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!p)
8010646b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010646f:	75 07                	jne    80106478 <sys_printpt+0x41>
    return -1;
80106471:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106476:	eb 13                	jmp    8010648b <sys_printpt+0x54>
  print_user_page_table(p); // 별도 구현
80106478:	83 ec 0c             	sub    $0xc,%esp
8010647b:	ff 75 f4             	push   -0xc(%ebp)
8010647e:	e8 c4 fe ff ff       	call   80106347 <print_user_page_table>
80106483:	83 c4 10             	add    $0x10,%esp
  return 0;
80106486:	b8 00 00 00 00       	mov    $0x0,%eax
8010648b:	c9                   	leave  
8010648c:	c3                   	ret    

8010648d <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010648d:	1e                   	push   %ds
  pushl %es
8010648e:	06                   	push   %es
  pushl %fs
8010648f:	0f a0                	push   %fs
  pushl %gs
80106491:	0f a8                	push   %gs
  pushal
80106493:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106494:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106498:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010649a:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010649c:	54                   	push   %esp
  call trap
8010649d:	e8 d7 01 00 00       	call   80106679 <trap>
  addl $4, %esp
801064a2:	83 c4 04             	add    $0x4,%esp

801064a5 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801064a5:	61                   	popa   
  popl %gs
801064a6:	0f a9                	pop    %gs
  popl %fs
801064a8:	0f a1                	pop    %fs
  popl %es
801064aa:	07                   	pop    %es
  popl %ds
801064ab:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801064ac:	83 c4 08             	add    $0x8,%esp
  iret
801064af:	cf                   	iret   

801064b0 <lidt>:
{
801064b0:	55                   	push   %ebp
801064b1:	89 e5                	mov    %esp,%ebp
801064b3:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801064b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801064b9:	83 e8 01             	sub    $0x1,%eax
801064bc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801064c0:	8b 45 08             	mov    0x8(%ebp),%eax
801064c3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801064c7:	8b 45 08             	mov    0x8(%ebp),%eax
801064ca:	c1 e8 10             	shr    $0x10,%eax
801064cd:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801064d1:	8d 45 fa             	lea    -0x6(%ebp),%eax
801064d4:	0f 01 18             	lidtl  (%eax)
}
801064d7:	90                   	nop
801064d8:	c9                   	leave  
801064d9:	c3                   	ret    

801064da <rcr2>:

static inline uint
rcr2(void)
{
801064da:	55                   	push   %ebp
801064db:	89 e5                	mov    %esp,%ebp
801064dd:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801064e0:	0f 20 d0             	mov    %cr2,%eax
801064e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801064e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801064e9:	c9                   	leave  
801064ea:	c3                   	ret    

801064eb <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801064eb:	55                   	push   %ebp
801064ec:	89 e5                	mov    %esp,%ebp
801064ee:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801064f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801064f8:	e9 c3 00 00 00       	jmp    801065c0 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801064fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106500:	8b 04 85 90 f0 10 80 	mov    -0x7fef0f70(,%eax,4),%eax
80106507:	89 c2                	mov    %eax,%edx
80106509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010650c:	66 89 14 c5 40 6c 19 	mov    %dx,-0x7fe693c0(,%eax,8)
80106513:	80 
80106514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106517:	66 c7 04 c5 42 6c 19 	movw   $0x8,-0x7fe693be(,%eax,8)
8010651e:	80 08 00 
80106521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106524:	0f b6 14 c5 44 6c 19 	movzbl -0x7fe693bc(,%eax,8),%edx
8010652b:	80 
8010652c:	83 e2 e0             	and    $0xffffffe0,%edx
8010652f:	88 14 c5 44 6c 19 80 	mov    %dl,-0x7fe693bc(,%eax,8)
80106536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106539:	0f b6 14 c5 44 6c 19 	movzbl -0x7fe693bc(,%eax,8),%edx
80106540:	80 
80106541:	83 e2 1f             	and    $0x1f,%edx
80106544:	88 14 c5 44 6c 19 80 	mov    %dl,-0x7fe693bc(,%eax,8)
8010654b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010654e:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
80106555:	80 
80106556:	83 e2 f0             	and    $0xfffffff0,%edx
80106559:	83 ca 0e             	or     $0xe,%edx
8010655c:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
80106563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106566:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
8010656d:	80 
8010656e:	83 e2 ef             	and    $0xffffffef,%edx
80106571:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
80106578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657b:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
80106582:	80 
80106583:	83 e2 9f             	and    $0xffffff9f,%edx
80106586:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
8010658d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106590:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
80106597:	80 
80106598:	83 ca 80             	or     $0xffffff80,%edx
8010659b:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
801065a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a5:	8b 04 85 90 f0 10 80 	mov    -0x7fef0f70(,%eax,4),%eax
801065ac:	c1 e8 10             	shr    $0x10,%eax
801065af:	89 c2                	mov    %eax,%edx
801065b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b4:	66 89 14 c5 46 6c 19 	mov    %dx,-0x7fe693ba(,%eax,8)
801065bb:	80 
  for(i = 0; i < 256; i++)
801065bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801065c0:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801065c7:	0f 8e 30 ff ff ff    	jle    801064fd <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801065cd:	a1 90 f1 10 80       	mov    0x8010f190,%eax
801065d2:	66 a3 40 6e 19 80    	mov    %ax,0x80196e40
801065d8:	66 c7 05 42 6e 19 80 	movw   $0x8,0x80196e42
801065df:	08 00 
801065e1:	0f b6 05 44 6e 19 80 	movzbl 0x80196e44,%eax
801065e8:	83 e0 e0             	and    $0xffffffe0,%eax
801065eb:	a2 44 6e 19 80       	mov    %al,0x80196e44
801065f0:	0f b6 05 44 6e 19 80 	movzbl 0x80196e44,%eax
801065f7:	83 e0 1f             	and    $0x1f,%eax
801065fa:	a2 44 6e 19 80       	mov    %al,0x80196e44
801065ff:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
80106606:	83 c8 0f             	or     $0xf,%eax
80106609:	a2 45 6e 19 80       	mov    %al,0x80196e45
8010660e:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
80106615:	83 e0 ef             	and    $0xffffffef,%eax
80106618:	a2 45 6e 19 80       	mov    %al,0x80196e45
8010661d:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
80106624:	83 c8 60             	or     $0x60,%eax
80106627:	a2 45 6e 19 80       	mov    %al,0x80196e45
8010662c:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
80106633:	83 c8 80             	or     $0xffffff80,%eax
80106636:	a2 45 6e 19 80       	mov    %al,0x80196e45
8010663b:	a1 90 f1 10 80       	mov    0x8010f190,%eax
80106640:	c1 e8 10             	shr    $0x10,%eax
80106643:	66 a3 46 6e 19 80    	mov    %ax,0x80196e46

  initlock(&tickslock, "time");
80106649:	83 ec 08             	sub    $0x8,%esp
8010664c:	68 10 ac 10 80       	push   $0x8010ac10
80106651:	68 40 74 19 80       	push   $0x80197440
80106656:	e8 a9 e4 ff ff       	call   80104b04 <initlock>
8010665b:	83 c4 10             	add    $0x10,%esp
}
8010665e:	90                   	nop
8010665f:	c9                   	leave  
80106660:	c3                   	ret    

80106661 <idtinit>:

void
idtinit(void)
{
80106661:	55                   	push   %ebp
80106662:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106664:	68 00 08 00 00       	push   $0x800
80106669:	68 40 6c 19 80       	push   $0x80196c40
8010666e:	e8 3d fe ff ff       	call   801064b0 <lidt>
80106673:	83 c4 08             	add    $0x8,%esp
}
80106676:	90                   	nop
80106677:	c9                   	leave  
80106678:	c3                   	ret    

80106679 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106679:	55                   	push   %ebp
8010667a:	89 e5                	mov    %esp,%ebp
8010667c:	57                   	push   %edi
8010667d:	56                   	push   %esi
8010667e:	53                   	push   %ebx
8010667f:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106682:	8b 45 08             	mov    0x8(%ebp),%eax
80106685:	8b 40 30             	mov    0x30(%eax),%eax
80106688:	83 f8 40             	cmp    $0x40,%eax
8010668b:	75 3b                	jne    801066c8 <trap+0x4f>
    if(myproc()->killed)
8010668d:	e8 9f d3 ff ff       	call   80103a31 <myproc>
80106692:	8b 40 24             	mov    0x24(%eax),%eax
80106695:	85 c0                	test   %eax,%eax
80106697:	74 05                	je     8010669e <trap+0x25>
      exit();
80106699:	e8 66 d8 ff ff       	call   80103f04 <exit>
    myproc()->tf = tf;
8010669e:	e8 8e d3 ff ff       	call   80103a31 <myproc>
801066a3:	8b 55 08             	mov    0x8(%ebp),%edx
801066a6:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801066a9:	e8 e5 ea ff ff       	call   80105193 <syscall>
    if(myproc()->killed)
801066ae:	e8 7e d3 ff ff       	call   80103a31 <myproc>
801066b3:	8b 40 24             	mov    0x24(%eax),%eax
801066b6:	85 c0                	test   %eax,%eax
801066b8:	0f 84 68 02 00 00    	je     80106926 <trap+0x2ad>
      exit();
801066be:	e8 41 d8 ff ff       	call   80103f04 <exit>
    return;
801066c3:	e9 5e 02 00 00       	jmp    80106926 <trap+0x2ad>
  }

  switch(tf->trapno){
801066c8:	8b 45 08             	mov    0x8(%ebp),%eax
801066cb:	8b 40 30             	mov    0x30(%eax),%eax
801066ce:	83 e8 20             	sub    $0x20,%eax
801066d1:	83 f8 1f             	cmp    $0x1f,%eax
801066d4:	0f 87 14 01 00 00    	ja     801067ee <trap+0x175>
801066da:	8b 04 85 b8 ac 10 80 	mov    -0x7fef5348(,%eax,4),%eax
801066e1:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801066e3:	e8 b6 d2 ff ff       	call   8010399e <cpuid>
801066e8:	85 c0                	test   %eax,%eax
801066ea:	75 3d                	jne    80106729 <trap+0xb0>
      acquire(&tickslock);
801066ec:	83 ec 0c             	sub    $0xc,%esp
801066ef:	68 40 74 19 80       	push   $0x80197440
801066f4:	e8 2d e4 ff ff       	call   80104b26 <acquire>
801066f9:	83 c4 10             	add    $0x10,%esp
      ticks++;
801066fc:	a1 74 74 19 80       	mov    0x80197474,%eax
80106701:	83 c0 01             	add    $0x1,%eax
80106704:	a3 74 74 19 80       	mov    %eax,0x80197474
      wakeup(&ticks);
80106709:	83 ec 0c             	sub    $0xc,%esp
8010670c:	68 74 74 19 80       	push   $0x80197474
80106711:	e8 a0 e0 ff ff       	call   801047b6 <wakeup>
80106716:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106719:	83 ec 0c             	sub    $0xc,%esp
8010671c:	68 40 74 19 80       	push   $0x80197440
80106721:	e8 6e e4 ff ff       	call   80104b94 <release>
80106726:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106729:	e8 ef c3 ff ff       	call   80102b1d <lapiceoi>

    // 🔥 유저모드 + scheduler 설정된 경우만 실행
    struct proc *p = myproc();
8010672e:	e8 fe d2 ff ff       	call   80103a31 <myproc>
80106733:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p && p->state == RUNNING && p->scheduler) {
80106736:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010673a:	0f 84 65 01 00 00    	je     801068a5 <trap+0x22c>
80106740:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106743:	8b 40 0c             	mov    0xc(%eax),%eax
80106746:	83 f8 04             	cmp    $0x4,%eax
80106749:	0f 85 56 01 00 00    	jne    801068a5 <trap+0x22c>
8010674f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106752:	8b 40 7c             	mov    0x7c(%eax),%eax
80106755:	85 c0                	test   %eax,%eax
80106757:	0f 84 48 01 00 00    	je     801068a5 <trap+0x22c>
      if(p->check_thread >= 2){
8010675d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106760:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106766:	83 f8 01             	cmp    $0x1,%eax
80106769:	0f 8e 36 01 00 00    	jle    801068a5 <trap+0x22c>
        p->tf->eip = p->scheduler;
8010676f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106772:	8b 40 18             	mov    0x18(%eax),%eax
80106775:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106778:	8b 52 7c             	mov    0x7c(%edx),%edx
8010677b:	89 50 38             	mov    %edx,0x38(%eax)
      }
    }
    

    break;
8010677e:	e9 22 01 00 00       	jmp    801068a5 <trap+0x22c>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106783:	e8 f8 3e 00 00       	call   8010a680 <ideintr>
    lapiceoi();
80106788:	e8 90 c3 ff ff       	call   80102b1d <lapiceoi>
    break;
8010678d:	e9 14 01 00 00       	jmp    801068a6 <trap+0x22d>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106792:	e8 cb c1 ff ff       	call   80102962 <kbdintr>
    lapiceoi();
80106797:	e8 81 c3 ff ff       	call   80102b1d <lapiceoi>
    break;
8010679c:	e9 05 01 00 00       	jmp    801068a6 <trap+0x22d>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801067a1:	e8 56 03 00 00       	call   80106afc <uartintr>
    lapiceoi();
801067a6:	e8 72 c3 ff ff       	call   80102b1d <lapiceoi>
    break;
801067ab:	e9 f6 00 00 00       	jmp    801068a6 <trap+0x22d>
  case T_IRQ0 + 0xB:
    i8254_intr();
801067b0:	e8 7e 2b 00 00       	call   80109333 <i8254_intr>
    lapiceoi();
801067b5:	e8 63 c3 ff ff       	call   80102b1d <lapiceoi>
    break;
801067ba:	e9 e7 00 00 00       	jmp    801068a6 <trap+0x22d>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067bf:	8b 45 08             	mov    0x8(%ebp),%eax
801067c2:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801067c5:	8b 45 08             	mov    0x8(%ebp),%eax
801067c8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067cc:	0f b7 d8             	movzwl %ax,%ebx
801067cf:	e8 ca d1 ff ff       	call   8010399e <cpuid>
801067d4:	56                   	push   %esi
801067d5:	53                   	push   %ebx
801067d6:	50                   	push   %eax
801067d7:	68 18 ac 10 80       	push   $0x8010ac18
801067dc:	e8 13 9c ff ff       	call   801003f4 <cprintf>
801067e1:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801067e4:	e8 34 c3 ff ff       	call   80102b1d <lapiceoi>
    break;
801067e9:	e9 b8 00 00 00       	jmp    801068a6 <trap+0x22d>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801067ee:	e8 3e d2 ff ff       	call   80103a31 <myproc>
801067f3:	85 c0                	test   %eax,%eax
801067f5:	74 11                	je     80106808 <trap+0x18f>
801067f7:	8b 45 08             	mov    0x8(%ebp),%eax
801067fa:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067fe:	0f b7 c0             	movzwl %ax,%eax
80106801:	83 e0 03             	and    $0x3,%eax
80106804:	85 c0                	test   %eax,%eax
80106806:	75 39                	jne    80106841 <trap+0x1c8>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106808:	e8 cd fc ff ff       	call   801064da <rcr2>
8010680d:	89 c3                	mov    %eax,%ebx
8010680f:	8b 45 08             	mov    0x8(%ebp),%eax
80106812:	8b 70 38             	mov    0x38(%eax),%esi
80106815:	e8 84 d1 ff ff       	call   8010399e <cpuid>
8010681a:	8b 55 08             	mov    0x8(%ebp),%edx
8010681d:	8b 52 30             	mov    0x30(%edx),%edx
80106820:	83 ec 0c             	sub    $0xc,%esp
80106823:	53                   	push   %ebx
80106824:	56                   	push   %esi
80106825:	50                   	push   %eax
80106826:	52                   	push   %edx
80106827:	68 3c ac 10 80       	push   $0x8010ac3c
8010682c:	e8 c3 9b ff ff       	call   801003f4 <cprintf>
80106831:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106834:	83 ec 0c             	sub    $0xc,%esp
80106837:	68 6e ac 10 80       	push   $0x8010ac6e
8010683c:	e8 68 9d ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106841:	e8 94 fc ff ff       	call   801064da <rcr2>
80106846:	89 c6                	mov    %eax,%esi
80106848:	8b 45 08             	mov    0x8(%ebp),%eax
8010684b:	8b 40 38             	mov    0x38(%eax),%eax
8010684e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106851:	e8 48 d1 ff ff       	call   8010399e <cpuid>
80106856:	89 c3                	mov    %eax,%ebx
80106858:	8b 45 08             	mov    0x8(%ebp),%eax
8010685b:	8b 48 34             	mov    0x34(%eax),%ecx
8010685e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106861:	8b 45 08             	mov    0x8(%ebp),%eax
80106864:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106867:	e8 c5 d1 ff ff       	call   80103a31 <myproc>
8010686c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010686f:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106872:	e8 ba d1 ff ff       	call   80103a31 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106877:	8b 40 10             	mov    0x10(%eax),%eax
8010687a:	56                   	push   %esi
8010687b:	ff 75 d4             	push   -0x2c(%ebp)
8010687e:	53                   	push   %ebx
8010687f:	ff 75 d0             	push   -0x30(%ebp)
80106882:	57                   	push   %edi
80106883:	ff 75 cc             	push   -0x34(%ebp)
80106886:	50                   	push   %eax
80106887:	68 74 ac 10 80       	push   $0x8010ac74
8010688c:	e8 63 9b ff ff       	call   801003f4 <cprintf>
80106891:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106894:	e8 98 d1 ff ff       	call   80103a31 <myproc>
80106899:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801068a0:	eb 04                	jmp    801068a6 <trap+0x22d>
    break;
801068a2:	90                   	nop
801068a3:	eb 01                	jmp    801068a6 <trap+0x22d>
    break;
801068a5:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801068a6:	e8 86 d1 ff ff       	call   80103a31 <myproc>
801068ab:	85 c0                	test   %eax,%eax
801068ad:	74 23                	je     801068d2 <trap+0x259>
801068af:	e8 7d d1 ff ff       	call   80103a31 <myproc>
801068b4:	8b 40 24             	mov    0x24(%eax),%eax
801068b7:	85 c0                	test   %eax,%eax
801068b9:	74 17                	je     801068d2 <trap+0x259>
801068bb:	8b 45 08             	mov    0x8(%ebp),%eax
801068be:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801068c2:	0f b7 c0             	movzwl %ax,%eax
801068c5:	83 e0 03             	and    $0x3,%eax
801068c8:	83 f8 03             	cmp    $0x3,%eax
801068cb:	75 05                	jne    801068d2 <trap+0x259>
    exit();
801068cd:	e8 32 d6 ff ff       	call   80103f04 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801068d2:	e8 5a d1 ff ff       	call   80103a31 <myproc>
801068d7:	85 c0                	test   %eax,%eax
801068d9:	74 1d                	je     801068f8 <trap+0x27f>
801068db:	e8 51 d1 ff ff       	call   80103a31 <myproc>
801068e0:	8b 40 0c             	mov    0xc(%eax),%eax
801068e3:	83 f8 04             	cmp    $0x4,%eax
801068e6:	75 10                	jne    801068f8 <trap+0x27f>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801068e8:	8b 45 08             	mov    0x8(%ebp),%eax
801068eb:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801068ee:	83 f8 20             	cmp    $0x20,%eax
801068f1:	75 05                	jne    801068f8 <trap+0x27f>
    yield();
801068f3:	e8 13 dd ff ff       	call   8010460b <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801068f8:	e8 34 d1 ff ff       	call   80103a31 <myproc>
801068fd:	85 c0                	test   %eax,%eax
801068ff:	74 26                	je     80106927 <trap+0x2ae>
80106901:	e8 2b d1 ff ff       	call   80103a31 <myproc>
80106906:	8b 40 24             	mov    0x24(%eax),%eax
80106909:	85 c0                	test   %eax,%eax
8010690b:	74 1a                	je     80106927 <trap+0x2ae>
8010690d:	8b 45 08             	mov    0x8(%ebp),%eax
80106910:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106914:	0f b7 c0             	movzwl %ax,%eax
80106917:	83 e0 03             	and    $0x3,%eax
8010691a:	83 f8 03             	cmp    $0x3,%eax
8010691d:	75 08                	jne    80106927 <trap+0x2ae>
    exit();
8010691f:	e8 e0 d5 ff ff       	call   80103f04 <exit>
80106924:	eb 01                	jmp    80106927 <trap+0x2ae>
    return;
80106926:	90                   	nop
}
80106927:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010692a:	5b                   	pop    %ebx
8010692b:	5e                   	pop    %esi
8010692c:	5f                   	pop    %edi
8010692d:	5d                   	pop    %ebp
8010692e:	c3                   	ret    

8010692f <inb>:
{
8010692f:	55                   	push   %ebp
80106930:	89 e5                	mov    %esp,%ebp
80106932:	83 ec 14             	sub    $0x14,%esp
80106935:	8b 45 08             	mov    0x8(%ebp),%eax
80106938:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010693c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106940:	89 c2                	mov    %eax,%edx
80106942:	ec                   	in     (%dx),%al
80106943:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106946:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010694a:	c9                   	leave  
8010694b:	c3                   	ret    

8010694c <outb>:
{
8010694c:	55                   	push   %ebp
8010694d:	89 e5                	mov    %esp,%ebp
8010694f:	83 ec 08             	sub    $0x8,%esp
80106952:	8b 45 08             	mov    0x8(%ebp),%eax
80106955:	8b 55 0c             	mov    0xc(%ebp),%edx
80106958:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010695c:	89 d0                	mov    %edx,%eax
8010695e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106961:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106965:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106969:	ee                   	out    %al,(%dx)
}
8010696a:	90                   	nop
8010696b:	c9                   	leave  
8010696c:	c3                   	ret    

8010696d <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010696d:	55                   	push   %ebp
8010696e:	89 e5                	mov    %esp,%ebp
80106970:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106973:	6a 00                	push   $0x0
80106975:	68 fa 03 00 00       	push   $0x3fa
8010697a:	e8 cd ff ff ff       	call   8010694c <outb>
8010697f:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106982:	68 80 00 00 00       	push   $0x80
80106987:	68 fb 03 00 00       	push   $0x3fb
8010698c:	e8 bb ff ff ff       	call   8010694c <outb>
80106991:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106994:	6a 0c                	push   $0xc
80106996:	68 f8 03 00 00       	push   $0x3f8
8010699b:	e8 ac ff ff ff       	call   8010694c <outb>
801069a0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801069a3:	6a 00                	push   $0x0
801069a5:	68 f9 03 00 00       	push   $0x3f9
801069aa:	e8 9d ff ff ff       	call   8010694c <outb>
801069af:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801069b2:	6a 03                	push   $0x3
801069b4:	68 fb 03 00 00       	push   $0x3fb
801069b9:	e8 8e ff ff ff       	call   8010694c <outb>
801069be:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801069c1:	6a 00                	push   $0x0
801069c3:	68 fc 03 00 00       	push   $0x3fc
801069c8:	e8 7f ff ff ff       	call   8010694c <outb>
801069cd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801069d0:	6a 01                	push   $0x1
801069d2:	68 f9 03 00 00       	push   $0x3f9
801069d7:	e8 70 ff ff ff       	call   8010694c <outb>
801069dc:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801069df:	68 fd 03 00 00       	push   $0x3fd
801069e4:	e8 46 ff ff ff       	call   8010692f <inb>
801069e9:	83 c4 04             	add    $0x4,%esp
801069ec:	3c ff                	cmp    $0xff,%al
801069ee:	74 61                	je     80106a51 <uartinit+0xe4>
    return;
  uart = 1;
801069f0:	c7 05 78 74 19 80 01 	movl   $0x1,0x80197478
801069f7:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801069fa:	68 fa 03 00 00       	push   $0x3fa
801069ff:	e8 2b ff ff ff       	call   8010692f <inb>
80106a04:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106a07:	68 f8 03 00 00       	push   $0x3f8
80106a0c:	e8 1e ff ff ff       	call   8010692f <inb>
80106a11:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106a14:	83 ec 08             	sub    $0x8,%esp
80106a17:	6a 00                	push   $0x0
80106a19:	6a 04                	push   $0x4
80106a1b:	e8 0f bc ff ff       	call   8010262f <ioapicenable>
80106a20:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106a23:	c7 45 f4 38 ad 10 80 	movl   $0x8010ad38,-0xc(%ebp)
80106a2a:	eb 19                	jmp    80106a45 <uartinit+0xd8>
    uartputc(*p);
80106a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a2f:	0f b6 00             	movzbl (%eax),%eax
80106a32:	0f be c0             	movsbl %al,%eax
80106a35:	83 ec 0c             	sub    $0xc,%esp
80106a38:	50                   	push   %eax
80106a39:	e8 16 00 00 00       	call   80106a54 <uartputc>
80106a3e:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106a41:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a48:	0f b6 00             	movzbl (%eax),%eax
80106a4b:	84 c0                	test   %al,%al
80106a4d:	75 dd                	jne    80106a2c <uartinit+0xbf>
80106a4f:	eb 01                	jmp    80106a52 <uartinit+0xe5>
    return;
80106a51:	90                   	nop
}
80106a52:	c9                   	leave  
80106a53:	c3                   	ret    

80106a54 <uartputc>:

void
uartputc(int c)
{
80106a54:	55                   	push   %ebp
80106a55:	89 e5                	mov    %esp,%ebp
80106a57:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106a5a:	a1 78 74 19 80       	mov    0x80197478,%eax
80106a5f:	85 c0                	test   %eax,%eax
80106a61:	74 53                	je     80106ab6 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a6a:	eb 11                	jmp    80106a7d <uartputc+0x29>
    microdelay(10);
80106a6c:	83 ec 0c             	sub    $0xc,%esp
80106a6f:	6a 0a                	push   $0xa
80106a71:	e8 c2 c0 ff ff       	call   80102b38 <microdelay>
80106a76:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a79:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a7d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106a81:	7f 1a                	jg     80106a9d <uartputc+0x49>
80106a83:	83 ec 0c             	sub    $0xc,%esp
80106a86:	68 fd 03 00 00       	push   $0x3fd
80106a8b:	e8 9f fe ff ff       	call   8010692f <inb>
80106a90:	83 c4 10             	add    $0x10,%esp
80106a93:	0f b6 c0             	movzbl %al,%eax
80106a96:	83 e0 20             	and    $0x20,%eax
80106a99:	85 c0                	test   %eax,%eax
80106a9b:	74 cf                	je     80106a6c <uartputc+0x18>
  outb(COM1+0, c);
80106a9d:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa0:	0f b6 c0             	movzbl %al,%eax
80106aa3:	83 ec 08             	sub    $0x8,%esp
80106aa6:	50                   	push   %eax
80106aa7:	68 f8 03 00 00       	push   $0x3f8
80106aac:	e8 9b fe ff ff       	call   8010694c <outb>
80106ab1:	83 c4 10             	add    $0x10,%esp
80106ab4:	eb 01                	jmp    80106ab7 <uartputc+0x63>
    return;
80106ab6:	90                   	nop
}
80106ab7:	c9                   	leave  
80106ab8:	c3                   	ret    

80106ab9 <uartgetc>:

static int
uartgetc(void)
{
80106ab9:	55                   	push   %ebp
80106aba:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106abc:	a1 78 74 19 80       	mov    0x80197478,%eax
80106ac1:	85 c0                	test   %eax,%eax
80106ac3:	75 07                	jne    80106acc <uartgetc+0x13>
    return -1;
80106ac5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aca:	eb 2e                	jmp    80106afa <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106acc:	68 fd 03 00 00       	push   $0x3fd
80106ad1:	e8 59 fe ff ff       	call   8010692f <inb>
80106ad6:	83 c4 04             	add    $0x4,%esp
80106ad9:	0f b6 c0             	movzbl %al,%eax
80106adc:	83 e0 01             	and    $0x1,%eax
80106adf:	85 c0                	test   %eax,%eax
80106ae1:	75 07                	jne    80106aea <uartgetc+0x31>
    return -1;
80106ae3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ae8:	eb 10                	jmp    80106afa <uartgetc+0x41>
  return inb(COM1+0);
80106aea:	68 f8 03 00 00       	push   $0x3f8
80106aef:	e8 3b fe ff ff       	call   8010692f <inb>
80106af4:	83 c4 04             	add    $0x4,%esp
80106af7:	0f b6 c0             	movzbl %al,%eax
}
80106afa:	c9                   	leave  
80106afb:	c3                   	ret    

80106afc <uartintr>:

void
uartintr(void)
{
80106afc:	55                   	push   %ebp
80106afd:	89 e5                	mov    %esp,%ebp
80106aff:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106b02:	83 ec 0c             	sub    $0xc,%esp
80106b05:	68 b9 6a 10 80       	push   $0x80106ab9
80106b0a:	e8 c7 9c ff ff       	call   801007d6 <consoleintr>
80106b0f:	83 c4 10             	add    $0x10,%esp
}
80106b12:	90                   	nop
80106b13:	c9                   	leave  
80106b14:	c3                   	ret    

80106b15 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106b15:	6a 00                	push   $0x0
  pushl $0
80106b17:	6a 00                	push   $0x0
  jmp alltraps
80106b19:	e9 6f f9 ff ff       	jmp    8010648d <alltraps>

80106b1e <vector1>:
.globl vector1
vector1:
  pushl $0
80106b1e:	6a 00                	push   $0x0
  pushl $1
80106b20:	6a 01                	push   $0x1
  jmp alltraps
80106b22:	e9 66 f9 ff ff       	jmp    8010648d <alltraps>

80106b27 <vector2>:
.globl vector2
vector2:
  pushl $0
80106b27:	6a 00                	push   $0x0
  pushl $2
80106b29:	6a 02                	push   $0x2
  jmp alltraps
80106b2b:	e9 5d f9 ff ff       	jmp    8010648d <alltraps>

80106b30 <vector3>:
.globl vector3
vector3:
  pushl $0
80106b30:	6a 00                	push   $0x0
  pushl $3
80106b32:	6a 03                	push   $0x3
  jmp alltraps
80106b34:	e9 54 f9 ff ff       	jmp    8010648d <alltraps>

80106b39 <vector4>:
.globl vector4
vector4:
  pushl $0
80106b39:	6a 00                	push   $0x0
  pushl $4
80106b3b:	6a 04                	push   $0x4
  jmp alltraps
80106b3d:	e9 4b f9 ff ff       	jmp    8010648d <alltraps>

80106b42 <vector5>:
.globl vector5
vector5:
  pushl $0
80106b42:	6a 00                	push   $0x0
  pushl $5
80106b44:	6a 05                	push   $0x5
  jmp alltraps
80106b46:	e9 42 f9 ff ff       	jmp    8010648d <alltraps>

80106b4b <vector6>:
.globl vector6
vector6:
  pushl $0
80106b4b:	6a 00                	push   $0x0
  pushl $6
80106b4d:	6a 06                	push   $0x6
  jmp alltraps
80106b4f:	e9 39 f9 ff ff       	jmp    8010648d <alltraps>

80106b54 <vector7>:
.globl vector7
vector7:
  pushl $0
80106b54:	6a 00                	push   $0x0
  pushl $7
80106b56:	6a 07                	push   $0x7
  jmp alltraps
80106b58:	e9 30 f9 ff ff       	jmp    8010648d <alltraps>

80106b5d <vector8>:
.globl vector8
vector8:
  pushl $8
80106b5d:	6a 08                	push   $0x8
  jmp alltraps
80106b5f:	e9 29 f9 ff ff       	jmp    8010648d <alltraps>

80106b64 <vector9>:
.globl vector9
vector9:
  pushl $0
80106b64:	6a 00                	push   $0x0
  pushl $9
80106b66:	6a 09                	push   $0x9
  jmp alltraps
80106b68:	e9 20 f9 ff ff       	jmp    8010648d <alltraps>

80106b6d <vector10>:
.globl vector10
vector10:
  pushl $10
80106b6d:	6a 0a                	push   $0xa
  jmp alltraps
80106b6f:	e9 19 f9 ff ff       	jmp    8010648d <alltraps>

80106b74 <vector11>:
.globl vector11
vector11:
  pushl $11
80106b74:	6a 0b                	push   $0xb
  jmp alltraps
80106b76:	e9 12 f9 ff ff       	jmp    8010648d <alltraps>

80106b7b <vector12>:
.globl vector12
vector12:
  pushl $12
80106b7b:	6a 0c                	push   $0xc
  jmp alltraps
80106b7d:	e9 0b f9 ff ff       	jmp    8010648d <alltraps>

80106b82 <vector13>:
.globl vector13
vector13:
  pushl $13
80106b82:	6a 0d                	push   $0xd
  jmp alltraps
80106b84:	e9 04 f9 ff ff       	jmp    8010648d <alltraps>

80106b89 <vector14>:
.globl vector14
vector14:
  pushl $14
80106b89:	6a 0e                	push   $0xe
  jmp alltraps
80106b8b:	e9 fd f8 ff ff       	jmp    8010648d <alltraps>

80106b90 <vector15>:
.globl vector15
vector15:
  pushl $0
80106b90:	6a 00                	push   $0x0
  pushl $15
80106b92:	6a 0f                	push   $0xf
  jmp alltraps
80106b94:	e9 f4 f8 ff ff       	jmp    8010648d <alltraps>

80106b99 <vector16>:
.globl vector16
vector16:
  pushl $0
80106b99:	6a 00                	push   $0x0
  pushl $16
80106b9b:	6a 10                	push   $0x10
  jmp alltraps
80106b9d:	e9 eb f8 ff ff       	jmp    8010648d <alltraps>

80106ba2 <vector17>:
.globl vector17
vector17:
  pushl $17
80106ba2:	6a 11                	push   $0x11
  jmp alltraps
80106ba4:	e9 e4 f8 ff ff       	jmp    8010648d <alltraps>

80106ba9 <vector18>:
.globl vector18
vector18:
  pushl $0
80106ba9:	6a 00                	push   $0x0
  pushl $18
80106bab:	6a 12                	push   $0x12
  jmp alltraps
80106bad:	e9 db f8 ff ff       	jmp    8010648d <alltraps>

80106bb2 <vector19>:
.globl vector19
vector19:
  pushl $0
80106bb2:	6a 00                	push   $0x0
  pushl $19
80106bb4:	6a 13                	push   $0x13
  jmp alltraps
80106bb6:	e9 d2 f8 ff ff       	jmp    8010648d <alltraps>

80106bbb <vector20>:
.globl vector20
vector20:
  pushl $0
80106bbb:	6a 00                	push   $0x0
  pushl $20
80106bbd:	6a 14                	push   $0x14
  jmp alltraps
80106bbf:	e9 c9 f8 ff ff       	jmp    8010648d <alltraps>

80106bc4 <vector21>:
.globl vector21
vector21:
  pushl $0
80106bc4:	6a 00                	push   $0x0
  pushl $21
80106bc6:	6a 15                	push   $0x15
  jmp alltraps
80106bc8:	e9 c0 f8 ff ff       	jmp    8010648d <alltraps>

80106bcd <vector22>:
.globl vector22
vector22:
  pushl $0
80106bcd:	6a 00                	push   $0x0
  pushl $22
80106bcf:	6a 16                	push   $0x16
  jmp alltraps
80106bd1:	e9 b7 f8 ff ff       	jmp    8010648d <alltraps>

80106bd6 <vector23>:
.globl vector23
vector23:
  pushl $0
80106bd6:	6a 00                	push   $0x0
  pushl $23
80106bd8:	6a 17                	push   $0x17
  jmp alltraps
80106bda:	e9 ae f8 ff ff       	jmp    8010648d <alltraps>

80106bdf <vector24>:
.globl vector24
vector24:
  pushl $0
80106bdf:	6a 00                	push   $0x0
  pushl $24
80106be1:	6a 18                	push   $0x18
  jmp alltraps
80106be3:	e9 a5 f8 ff ff       	jmp    8010648d <alltraps>

80106be8 <vector25>:
.globl vector25
vector25:
  pushl $0
80106be8:	6a 00                	push   $0x0
  pushl $25
80106bea:	6a 19                	push   $0x19
  jmp alltraps
80106bec:	e9 9c f8 ff ff       	jmp    8010648d <alltraps>

80106bf1 <vector26>:
.globl vector26
vector26:
  pushl $0
80106bf1:	6a 00                	push   $0x0
  pushl $26
80106bf3:	6a 1a                	push   $0x1a
  jmp alltraps
80106bf5:	e9 93 f8 ff ff       	jmp    8010648d <alltraps>

80106bfa <vector27>:
.globl vector27
vector27:
  pushl $0
80106bfa:	6a 00                	push   $0x0
  pushl $27
80106bfc:	6a 1b                	push   $0x1b
  jmp alltraps
80106bfe:	e9 8a f8 ff ff       	jmp    8010648d <alltraps>

80106c03 <vector28>:
.globl vector28
vector28:
  pushl $0
80106c03:	6a 00                	push   $0x0
  pushl $28
80106c05:	6a 1c                	push   $0x1c
  jmp alltraps
80106c07:	e9 81 f8 ff ff       	jmp    8010648d <alltraps>

80106c0c <vector29>:
.globl vector29
vector29:
  pushl $0
80106c0c:	6a 00                	push   $0x0
  pushl $29
80106c0e:	6a 1d                	push   $0x1d
  jmp alltraps
80106c10:	e9 78 f8 ff ff       	jmp    8010648d <alltraps>

80106c15 <vector30>:
.globl vector30
vector30:
  pushl $0
80106c15:	6a 00                	push   $0x0
  pushl $30
80106c17:	6a 1e                	push   $0x1e
  jmp alltraps
80106c19:	e9 6f f8 ff ff       	jmp    8010648d <alltraps>

80106c1e <vector31>:
.globl vector31
vector31:
  pushl $0
80106c1e:	6a 00                	push   $0x0
  pushl $31
80106c20:	6a 1f                	push   $0x1f
  jmp alltraps
80106c22:	e9 66 f8 ff ff       	jmp    8010648d <alltraps>

80106c27 <vector32>:
.globl vector32
vector32:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $32
80106c29:	6a 20                	push   $0x20
  jmp alltraps
80106c2b:	e9 5d f8 ff ff       	jmp    8010648d <alltraps>

80106c30 <vector33>:
.globl vector33
vector33:
  pushl $0
80106c30:	6a 00                	push   $0x0
  pushl $33
80106c32:	6a 21                	push   $0x21
  jmp alltraps
80106c34:	e9 54 f8 ff ff       	jmp    8010648d <alltraps>

80106c39 <vector34>:
.globl vector34
vector34:
  pushl $0
80106c39:	6a 00                	push   $0x0
  pushl $34
80106c3b:	6a 22                	push   $0x22
  jmp alltraps
80106c3d:	e9 4b f8 ff ff       	jmp    8010648d <alltraps>

80106c42 <vector35>:
.globl vector35
vector35:
  pushl $0
80106c42:	6a 00                	push   $0x0
  pushl $35
80106c44:	6a 23                	push   $0x23
  jmp alltraps
80106c46:	e9 42 f8 ff ff       	jmp    8010648d <alltraps>

80106c4b <vector36>:
.globl vector36
vector36:
  pushl $0
80106c4b:	6a 00                	push   $0x0
  pushl $36
80106c4d:	6a 24                	push   $0x24
  jmp alltraps
80106c4f:	e9 39 f8 ff ff       	jmp    8010648d <alltraps>

80106c54 <vector37>:
.globl vector37
vector37:
  pushl $0
80106c54:	6a 00                	push   $0x0
  pushl $37
80106c56:	6a 25                	push   $0x25
  jmp alltraps
80106c58:	e9 30 f8 ff ff       	jmp    8010648d <alltraps>

80106c5d <vector38>:
.globl vector38
vector38:
  pushl $0
80106c5d:	6a 00                	push   $0x0
  pushl $38
80106c5f:	6a 26                	push   $0x26
  jmp alltraps
80106c61:	e9 27 f8 ff ff       	jmp    8010648d <alltraps>

80106c66 <vector39>:
.globl vector39
vector39:
  pushl $0
80106c66:	6a 00                	push   $0x0
  pushl $39
80106c68:	6a 27                	push   $0x27
  jmp alltraps
80106c6a:	e9 1e f8 ff ff       	jmp    8010648d <alltraps>

80106c6f <vector40>:
.globl vector40
vector40:
  pushl $0
80106c6f:	6a 00                	push   $0x0
  pushl $40
80106c71:	6a 28                	push   $0x28
  jmp alltraps
80106c73:	e9 15 f8 ff ff       	jmp    8010648d <alltraps>

80106c78 <vector41>:
.globl vector41
vector41:
  pushl $0
80106c78:	6a 00                	push   $0x0
  pushl $41
80106c7a:	6a 29                	push   $0x29
  jmp alltraps
80106c7c:	e9 0c f8 ff ff       	jmp    8010648d <alltraps>

80106c81 <vector42>:
.globl vector42
vector42:
  pushl $0
80106c81:	6a 00                	push   $0x0
  pushl $42
80106c83:	6a 2a                	push   $0x2a
  jmp alltraps
80106c85:	e9 03 f8 ff ff       	jmp    8010648d <alltraps>

80106c8a <vector43>:
.globl vector43
vector43:
  pushl $0
80106c8a:	6a 00                	push   $0x0
  pushl $43
80106c8c:	6a 2b                	push   $0x2b
  jmp alltraps
80106c8e:	e9 fa f7 ff ff       	jmp    8010648d <alltraps>

80106c93 <vector44>:
.globl vector44
vector44:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $44
80106c95:	6a 2c                	push   $0x2c
  jmp alltraps
80106c97:	e9 f1 f7 ff ff       	jmp    8010648d <alltraps>

80106c9c <vector45>:
.globl vector45
vector45:
  pushl $0
80106c9c:	6a 00                	push   $0x0
  pushl $45
80106c9e:	6a 2d                	push   $0x2d
  jmp alltraps
80106ca0:	e9 e8 f7 ff ff       	jmp    8010648d <alltraps>

80106ca5 <vector46>:
.globl vector46
vector46:
  pushl $0
80106ca5:	6a 00                	push   $0x0
  pushl $46
80106ca7:	6a 2e                	push   $0x2e
  jmp alltraps
80106ca9:	e9 df f7 ff ff       	jmp    8010648d <alltraps>

80106cae <vector47>:
.globl vector47
vector47:
  pushl $0
80106cae:	6a 00                	push   $0x0
  pushl $47
80106cb0:	6a 2f                	push   $0x2f
  jmp alltraps
80106cb2:	e9 d6 f7 ff ff       	jmp    8010648d <alltraps>

80106cb7 <vector48>:
.globl vector48
vector48:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $48
80106cb9:	6a 30                	push   $0x30
  jmp alltraps
80106cbb:	e9 cd f7 ff ff       	jmp    8010648d <alltraps>

80106cc0 <vector49>:
.globl vector49
vector49:
  pushl $0
80106cc0:	6a 00                	push   $0x0
  pushl $49
80106cc2:	6a 31                	push   $0x31
  jmp alltraps
80106cc4:	e9 c4 f7 ff ff       	jmp    8010648d <alltraps>

80106cc9 <vector50>:
.globl vector50
vector50:
  pushl $0
80106cc9:	6a 00                	push   $0x0
  pushl $50
80106ccb:	6a 32                	push   $0x32
  jmp alltraps
80106ccd:	e9 bb f7 ff ff       	jmp    8010648d <alltraps>

80106cd2 <vector51>:
.globl vector51
vector51:
  pushl $0
80106cd2:	6a 00                	push   $0x0
  pushl $51
80106cd4:	6a 33                	push   $0x33
  jmp alltraps
80106cd6:	e9 b2 f7 ff ff       	jmp    8010648d <alltraps>

80106cdb <vector52>:
.globl vector52
vector52:
  pushl $0
80106cdb:	6a 00                	push   $0x0
  pushl $52
80106cdd:	6a 34                	push   $0x34
  jmp alltraps
80106cdf:	e9 a9 f7 ff ff       	jmp    8010648d <alltraps>

80106ce4 <vector53>:
.globl vector53
vector53:
  pushl $0
80106ce4:	6a 00                	push   $0x0
  pushl $53
80106ce6:	6a 35                	push   $0x35
  jmp alltraps
80106ce8:	e9 a0 f7 ff ff       	jmp    8010648d <alltraps>

80106ced <vector54>:
.globl vector54
vector54:
  pushl $0
80106ced:	6a 00                	push   $0x0
  pushl $54
80106cef:	6a 36                	push   $0x36
  jmp alltraps
80106cf1:	e9 97 f7 ff ff       	jmp    8010648d <alltraps>

80106cf6 <vector55>:
.globl vector55
vector55:
  pushl $0
80106cf6:	6a 00                	push   $0x0
  pushl $55
80106cf8:	6a 37                	push   $0x37
  jmp alltraps
80106cfa:	e9 8e f7 ff ff       	jmp    8010648d <alltraps>

80106cff <vector56>:
.globl vector56
vector56:
  pushl $0
80106cff:	6a 00                	push   $0x0
  pushl $56
80106d01:	6a 38                	push   $0x38
  jmp alltraps
80106d03:	e9 85 f7 ff ff       	jmp    8010648d <alltraps>

80106d08 <vector57>:
.globl vector57
vector57:
  pushl $0
80106d08:	6a 00                	push   $0x0
  pushl $57
80106d0a:	6a 39                	push   $0x39
  jmp alltraps
80106d0c:	e9 7c f7 ff ff       	jmp    8010648d <alltraps>

80106d11 <vector58>:
.globl vector58
vector58:
  pushl $0
80106d11:	6a 00                	push   $0x0
  pushl $58
80106d13:	6a 3a                	push   $0x3a
  jmp alltraps
80106d15:	e9 73 f7 ff ff       	jmp    8010648d <alltraps>

80106d1a <vector59>:
.globl vector59
vector59:
  pushl $0
80106d1a:	6a 00                	push   $0x0
  pushl $59
80106d1c:	6a 3b                	push   $0x3b
  jmp alltraps
80106d1e:	e9 6a f7 ff ff       	jmp    8010648d <alltraps>

80106d23 <vector60>:
.globl vector60
vector60:
  pushl $0
80106d23:	6a 00                	push   $0x0
  pushl $60
80106d25:	6a 3c                	push   $0x3c
  jmp alltraps
80106d27:	e9 61 f7 ff ff       	jmp    8010648d <alltraps>

80106d2c <vector61>:
.globl vector61
vector61:
  pushl $0
80106d2c:	6a 00                	push   $0x0
  pushl $61
80106d2e:	6a 3d                	push   $0x3d
  jmp alltraps
80106d30:	e9 58 f7 ff ff       	jmp    8010648d <alltraps>

80106d35 <vector62>:
.globl vector62
vector62:
  pushl $0
80106d35:	6a 00                	push   $0x0
  pushl $62
80106d37:	6a 3e                	push   $0x3e
  jmp alltraps
80106d39:	e9 4f f7 ff ff       	jmp    8010648d <alltraps>

80106d3e <vector63>:
.globl vector63
vector63:
  pushl $0
80106d3e:	6a 00                	push   $0x0
  pushl $63
80106d40:	6a 3f                	push   $0x3f
  jmp alltraps
80106d42:	e9 46 f7 ff ff       	jmp    8010648d <alltraps>

80106d47 <vector64>:
.globl vector64
vector64:
  pushl $0
80106d47:	6a 00                	push   $0x0
  pushl $64
80106d49:	6a 40                	push   $0x40
  jmp alltraps
80106d4b:	e9 3d f7 ff ff       	jmp    8010648d <alltraps>

80106d50 <vector65>:
.globl vector65
vector65:
  pushl $0
80106d50:	6a 00                	push   $0x0
  pushl $65
80106d52:	6a 41                	push   $0x41
  jmp alltraps
80106d54:	e9 34 f7 ff ff       	jmp    8010648d <alltraps>

80106d59 <vector66>:
.globl vector66
vector66:
  pushl $0
80106d59:	6a 00                	push   $0x0
  pushl $66
80106d5b:	6a 42                	push   $0x42
  jmp alltraps
80106d5d:	e9 2b f7 ff ff       	jmp    8010648d <alltraps>

80106d62 <vector67>:
.globl vector67
vector67:
  pushl $0
80106d62:	6a 00                	push   $0x0
  pushl $67
80106d64:	6a 43                	push   $0x43
  jmp alltraps
80106d66:	e9 22 f7 ff ff       	jmp    8010648d <alltraps>

80106d6b <vector68>:
.globl vector68
vector68:
  pushl $0
80106d6b:	6a 00                	push   $0x0
  pushl $68
80106d6d:	6a 44                	push   $0x44
  jmp alltraps
80106d6f:	e9 19 f7 ff ff       	jmp    8010648d <alltraps>

80106d74 <vector69>:
.globl vector69
vector69:
  pushl $0
80106d74:	6a 00                	push   $0x0
  pushl $69
80106d76:	6a 45                	push   $0x45
  jmp alltraps
80106d78:	e9 10 f7 ff ff       	jmp    8010648d <alltraps>

80106d7d <vector70>:
.globl vector70
vector70:
  pushl $0
80106d7d:	6a 00                	push   $0x0
  pushl $70
80106d7f:	6a 46                	push   $0x46
  jmp alltraps
80106d81:	e9 07 f7 ff ff       	jmp    8010648d <alltraps>

80106d86 <vector71>:
.globl vector71
vector71:
  pushl $0
80106d86:	6a 00                	push   $0x0
  pushl $71
80106d88:	6a 47                	push   $0x47
  jmp alltraps
80106d8a:	e9 fe f6 ff ff       	jmp    8010648d <alltraps>

80106d8f <vector72>:
.globl vector72
vector72:
  pushl $0
80106d8f:	6a 00                	push   $0x0
  pushl $72
80106d91:	6a 48                	push   $0x48
  jmp alltraps
80106d93:	e9 f5 f6 ff ff       	jmp    8010648d <alltraps>

80106d98 <vector73>:
.globl vector73
vector73:
  pushl $0
80106d98:	6a 00                	push   $0x0
  pushl $73
80106d9a:	6a 49                	push   $0x49
  jmp alltraps
80106d9c:	e9 ec f6 ff ff       	jmp    8010648d <alltraps>

80106da1 <vector74>:
.globl vector74
vector74:
  pushl $0
80106da1:	6a 00                	push   $0x0
  pushl $74
80106da3:	6a 4a                	push   $0x4a
  jmp alltraps
80106da5:	e9 e3 f6 ff ff       	jmp    8010648d <alltraps>

80106daa <vector75>:
.globl vector75
vector75:
  pushl $0
80106daa:	6a 00                	push   $0x0
  pushl $75
80106dac:	6a 4b                	push   $0x4b
  jmp alltraps
80106dae:	e9 da f6 ff ff       	jmp    8010648d <alltraps>

80106db3 <vector76>:
.globl vector76
vector76:
  pushl $0
80106db3:	6a 00                	push   $0x0
  pushl $76
80106db5:	6a 4c                	push   $0x4c
  jmp alltraps
80106db7:	e9 d1 f6 ff ff       	jmp    8010648d <alltraps>

80106dbc <vector77>:
.globl vector77
vector77:
  pushl $0
80106dbc:	6a 00                	push   $0x0
  pushl $77
80106dbe:	6a 4d                	push   $0x4d
  jmp alltraps
80106dc0:	e9 c8 f6 ff ff       	jmp    8010648d <alltraps>

80106dc5 <vector78>:
.globl vector78
vector78:
  pushl $0
80106dc5:	6a 00                	push   $0x0
  pushl $78
80106dc7:	6a 4e                	push   $0x4e
  jmp alltraps
80106dc9:	e9 bf f6 ff ff       	jmp    8010648d <alltraps>

80106dce <vector79>:
.globl vector79
vector79:
  pushl $0
80106dce:	6a 00                	push   $0x0
  pushl $79
80106dd0:	6a 4f                	push   $0x4f
  jmp alltraps
80106dd2:	e9 b6 f6 ff ff       	jmp    8010648d <alltraps>

80106dd7 <vector80>:
.globl vector80
vector80:
  pushl $0
80106dd7:	6a 00                	push   $0x0
  pushl $80
80106dd9:	6a 50                	push   $0x50
  jmp alltraps
80106ddb:	e9 ad f6 ff ff       	jmp    8010648d <alltraps>

80106de0 <vector81>:
.globl vector81
vector81:
  pushl $0
80106de0:	6a 00                	push   $0x0
  pushl $81
80106de2:	6a 51                	push   $0x51
  jmp alltraps
80106de4:	e9 a4 f6 ff ff       	jmp    8010648d <alltraps>

80106de9 <vector82>:
.globl vector82
vector82:
  pushl $0
80106de9:	6a 00                	push   $0x0
  pushl $82
80106deb:	6a 52                	push   $0x52
  jmp alltraps
80106ded:	e9 9b f6 ff ff       	jmp    8010648d <alltraps>

80106df2 <vector83>:
.globl vector83
vector83:
  pushl $0
80106df2:	6a 00                	push   $0x0
  pushl $83
80106df4:	6a 53                	push   $0x53
  jmp alltraps
80106df6:	e9 92 f6 ff ff       	jmp    8010648d <alltraps>

80106dfb <vector84>:
.globl vector84
vector84:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $84
80106dfd:	6a 54                	push   $0x54
  jmp alltraps
80106dff:	e9 89 f6 ff ff       	jmp    8010648d <alltraps>

80106e04 <vector85>:
.globl vector85
vector85:
  pushl $0
80106e04:	6a 00                	push   $0x0
  pushl $85
80106e06:	6a 55                	push   $0x55
  jmp alltraps
80106e08:	e9 80 f6 ff ff       	jmp    8010648d <alltraps>

80106e0d <vector86>:
.globl vector86
vector86:
  pushl $0
80106e0d:	6a 00                	push   $0x0
  pushl $86
80106e0f:	6a 56                	push   $0x56
  jmp alltraps
80106e11:	e9 77 f6 ff ff       	jmp    8010648d <alltraps>

80106e16 <vector87>:
.globl vector87
vector87:
  pushl $0
80106e16:	6a 00                	push   $0x0
  pushl $87
80106e18:	6a 57                	push   $0x57
  jmp alltraps
80106e1a:	e9 6e f6 ff ff       	jmp    8010648d <alltraps>

80106e1f <vector88>:
.globl vector88
vector88:
  pushl $0
80106e1f:	6a 00                	push   $0x0
  pushl $88
80106e21:	6a 58                	push   $0x58
  jmp alltraps
80106e23:	e9 65 f6 ff ff       	jmp    8010648d <alltraps>

80106e28 <vector89>:
.globl vector89
vector89:
  pushl $0
80106e28:	6a 00                	push   $0x0
  pushl $89
80106e2a:	6a 59                	push   $0x59
  jmp alltraps
80106e2c:	e9 5c f6 ff ff       	jmp    8010648d <alltraps>

80106e31 <vector90>:
.globl vector90
vector90:
  pushl $0
80106e31:	6a 00                	push   $0x0
  pushl $90
80106e33:	6a 5a                	push   $0x5a
  jmp alltraps
80106e35:	e9 53 f6 ff ff       	jmp    8010648d <alltraps>

80106e3a <vector91>:
.globl vector91
vector91:
  pushl $0
80106e3a:	6a 00                	push   $0x0
  pushl $91
80106e3c:	6a 5b                	push   $0x5b
  jmp alltraps
80106e3e:	e9 4a f6 ff ff       	jmp    8010648d <alltraps>

80106e43 <vector92>:
.globl vector92
vector92:
  pushl $0
80106e43:	6a 00                	push   $0x0
  pushl $92
80106e45:	6a 5c                	push   $0x5c
  jmp alltraps
80106e47:	e9 41 f6 ff ff       	jmp    8010648d <alltraps>

80106e4c <vector93>:
.globl vector93
vector93:
  pushl $0
80106e4c:	6a 00                	push   $0x0
  pushl $93
80106e4e:	6a 5d                	push   $0x5d
  jmp alltraps
80106e50:	e9 38 f6 ff ff       	jmp    8010648d <alltraps>

80106e55 <vector94>:
.globl vector94
vector94:
  pushl $0
80106e55:	6a 00                	push   $0x0
  pushl $94
80106e57:	6a 5e                	push   $0x5e
  jmp alltraps
80106e59:	e9 2f f6 ff ff       	jmp    8010648d <alltraps>

80106e5e <vector95>:
.globl vector95
vector95:
  pushl $0
80106e5e:	6a 00                	push   $0x0
  pushl $95
80106e60:	6a 5f                	push   $0x5f
  jmp alltraps
80106e62:	e9 26 f6 ff ff       	jmp    8010648d <alltraps>

80106e67 <vector96>:
.globl vector96
vector96:
  pushl $0
80106e67:	6a 00                	push   $0x0
  pushl $96
80106e69:	6a 60                	push   $0x60
  jmp alltraps
80106e6b:	e9 1d f6 ff ff       	jmp    8010648d <alltraps>

80106e70 <vector97>:
.globl vector97
vector97:
  pushl $0
80106e70:	6a 00                	push   $0x0
  pushl $97
80106e72:	6a 61                	push   $0x61
  jmp alltraps
80106e74:	e9 14 f6 ff ff       	jmp    8010648d <alltraps>

80106e79 <vector98>:
.globl vector98
vector98:
  pushl $0
80106e79:	6a 00                	push   $0x0
  pushl $98
80106e7b:	6a 62                	push   $0x62
  jmp alltraps
80106e7d:	e9 0b f6 ff ff       	jmp    8010648d <alltraps>

80106e82 <vector99>:
.globl vector99
vector99:
  pushl $0
80106e82:	6a 00                	push   $0x0
  pushl $99
80106e84:	6a 63                	push   $0x63
  jmp alltraps
80106e86:	e9 02 f6 ff ff       	jmp    8010648d <alltraps>

80106e8b <vector100>:
.globl vector100
vector100:
  pushl $0
80106e8b:	6a 00                	push   $0x0
  pushl $100
80106e8d:	6a 64                	push   $0x64
  jmp alltraps
80106e8f:	e9 f9 f5 ff ff       	jmp    8010648d <alltraps>

80106e94 <vector101>:
.globl vector101
vector101:
  pushl $0
80106e94:	6a 00                	push   $0x0
  pushl $101
80106e96:	6a 65                	push   $0x65
  jmp alltraps
80106e98:	e9 f0 f5 ff ff       	jmp    8010648d <alltraps>

80106e9d <vector102>:
.globl vector102
vector102:
  pushl $0
80106e9d:	6a 00                	push   $0x0
  pushl $102
80106e9f:	6a 66                	push   $0x66
  jmp alltraps
80106ea1:	e9 e7 f5 ff ff       	jmp    8010648d <alltraps>

80106ea6 <vector103>:
.globl vector103
vector103:
  pushl $0
80106ea6:	6a 00                	push   $0x0
  pushl $103
80106ea8:	6a 67                	push   $0x67
  jmp alltraps
80106eaa:	e9 de f5 ff ff       	jmp    8010648d <alltraps>

80106eaf <vector104>:
.globl vector104
vector104:
  pushl $0
80106eaf:	6a 00                	push   $0x0
  pushl $104
80106eb1:	6a 68                	push   $0x68
  jmp alltraps
80106eb3:	e9 d5 f5 ff ff       	jmp    8010648d <alltraps>

80106eb8 <vector105>:
.globl vector105
vector105:
  pushl $0
80106eb8:	6a 00                	push   $0x0
  pushl $105
80106eba:	6a 69                	push   $0x69
  jmp alltraps
80106ebc:	e9 cc f5 ff ff       	jmp    8010648d <alltraps>

80106ec1 <vector106>:
.globl vector106
vector106:
  pushl $0
80106ec1:	6a 00                	push   $0x0
  pushl $106
80106ec3:	6a 6a                	push   $0x6a
  jmp alltraps
80106ec5:	e9 c3 f5 ff ff       	jmp    8010648d <alltraps>

80106eca <vector107>:
.globl vector107
vector107:
  pushl $0
80106eca:	6a 00                	push   $0x0
  pushl $107
80106ecc:	6a 6b                	push   $0x6b
  jmp alltraps
80106ece:	e9 ba f5 ff ff       	jmp    8010648d <alltraps>

80106ed3 <vector108>:
.globl vector108
vector108:
  pushl $0
80106ed3:	6a 00                	push   $0x0
  pushl $108
80106ed5:	6a 6c                	push   $0x6c
  jmp alltraps
80106ed7:	e9 b1 f5 ff ff       	jmp    8010648d <alltraps>

80106edc <vector109>:
.globl vector109
vector109:
  pushl $0
80106edc:	6a 00                	push   $0x0
  pushl $109
80106ede:	6a 6d                	push   $0x6d
  jmp alltraps
80106ee0:	e9 a8 f5 ff ff       	jmp    8010648d <alltraps>

80106ee5 <vector110>:
.globl vector110
vector110:
  pushl $0
80106ee5:	6a 00                	push   $0x0
  pushl $110
80106ee7:	6a 6e                	push   $0x6e
  jmp alltraps
80106ee9:	e9 9f f5 ff ff       	jmp    8010648d <alltraps>

80106eee <vector111>:
.globl vector111
vector111:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $111
80106ef0:	6a 6f                	push   $0x6f
  jmp alltraps
80106ef2:	e9 96 f5 ff ff       	jmp    8010648d <alltraps>

80106ef7 <vector112>:
.globl vector112
vector112:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $112
80106ef9:	6a 70                	push   $0x70
  jmp alltraps
80106efb:	e9 8d f5 ff ff       	jmp    8010648d <alltraps>

80106f00 <vector113>:
.globl vector113
vector113:
  pushl $0
80106f00:	6a 00                	push   $0x0
  pushl $113
80106f02:	6a 71                	push   $0x71
  jmp alltraps
80106f04:	e9 84 f5 ff ff       	jmp    8010648d <alltraps>

80106f09 <vector114>:
.globl vector114
vector114:
  pushl $0
80106f09:	6a 00                	push   $0x0
  pushl $114
80106f0b:	6a 72                	push   $0x72
  jmp alltraps
80106f0d:	e9 7b f5 ff ff       	jmp    8010648d <alltraps>

80106f12 <vector115>:
.globl vector115
vector115:
  pushl $0
80106f12:	6a 00                	push   $0x0
  pushl $115
80106f14:	6a 73                	push   $0x73
  jmp alltraps
80106f16:	e9 72 f5 ff ff       	jmp    8010648d <alltraps>

80106f1b <vector116>:
.globl vector116
vector116:
  pushl $0
80106f1b:	6a 00                	push   $0x0
  pushl $116
80106f1d:	6a 74                	push   $0x74
  jmp alltraps
80106f1f:	e9 69 f5 ff ff       	jmp    8010648d <alltraps>

80106f24 <vector117>:
.globl vector117
vector117:
  pushl $0
80106f24:	6a 00                	push   $0x0
  pushl $117
80106f26:	6a 75                	push   $0x75
  jmp alltraps
80106f28:	e9 60 f5 ff ff       	jmp    8010648d <alltraps>

80106f2d <vector118>:
.globl vector118
vector118:
  pushl $0
80106f2d:	6a 00                	push   $0x0
  pushl $118
80106f2f:	6a 76                	push   $0x76
  jmp alltraps
80106f31:	e9 57 f5 ff ff       	jmp    8010648d <alltraps>

80106f36 <vector119>:
.globl vector119
vector119:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $119
80106f38:	6a 77                	push   $0x77
  jmp alltraps
80106f3a:	e9 4e f5 ff ff       	jmp    8010648d <alltraps>

80106f3f <vector120>:
.globl vector120
vector120:
  pushl $0
80106f3f:	6a 00                	push   $0x0
  pushl $120
80106f41:	6a 78                	push   $0x78
  jmp alltraps
80106f43:	e9 45 f5 ff ff       	jmp    8010648d <alltraps>

80106f48 <vector121>:
.globl vector121
vector121:
  pushl $0
80106f48:	6a 00                	push   $0x0
  pushl $121
80106f4a:	6a 79                	push   $0x79
  jmp alltraps
80106f4c:	e9 3c f5 ff ff       	jmp    8010648d <alltraps>

80106f51 <vector122>:
.globl vector122
vector122:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $122
80106f53:	6a 7a                	push   $0x7a
  jmp alltraps
80106f55:	e9 33 f5 ff ff       	jmp    8010648d <alltraps>

80106f5a <vector123>:
.globl vector123
vector123:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $123
80106f5c:	6a 7b                	push   $0x7b
  jmp alltraps
80106f5e:	e9 2a f5 ff ff       	jmp    8010648d <alltraps>

80106f63 <vector124>:
.globl vector124
vector124:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $124
80106f65:	6a 7c                	push   $0x7c
  jmp alltraps
80106f67:	e9 21 f5 ff ff       	jmp    8010648d <alltraps>

80106f6c <vector125>:
.globl vector125
vector125:
  pushl $0
80106f6c:	6a 00                	push   $0x0
  pushl $125
80106f6e:	6a 7d                	push   $0x7d
  jmp alltraps
80106f70:	e9 18 f5 ff ff       	jmp    8010648d <alltraps>

80106f75 <vector126>:
.globl vector126
vector126:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $126
80106f77:	6a 7e                	push   $0x7e
  jmp alltraps
80106f79:	e9 0f f5 ff ff       	jmp    8010648d <alltraps>

80106f7e <vector127>:
.globl vector127
vector127:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $127
80106f80:	6a 7f                	push   $0x7f
  jmp alltraps
80106f82:	e9 06 f5 ff ff       	jmp    8010648d <alltraps>

80106f87 <vector128>:
.globl vector128
vector128:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $128
80106f89:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106f8e:	e9 fa f4 ff ff       	jmp    8010648d <alltraps>

80106f93 <vector129>:
.globl vector129
vector129:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $129
80106f95:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106f9a:	e9 ee f4 ff ff       	jmp    8010648d <alltraps>

80106f9f <vector130>:
.globl vector130
vector130:
  pushl $0
80106f9f:	6a 00                	push   $0x0
  pushl $130
80106fa1:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106fa6:	e9 e2 f4 ff ff       	jmp    8010648d <alltraps>

80106fab <vector131>:
.globl vector131
vector131:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $131
80106fad:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106fb2:	e9 d6 f4 ff ff       	jmp    8010648d <alltraps>

80106fb7 <vector132>:
.globl vector132
vector132:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $132
80106fb9:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106fbe:	e9 ca f4 ff ff       	jmp    8010648d <alltraps>

80106fc3 <vector133>:
.globl vector133
vector133:
  pushl $0
80106fc3:	6a 00                	push   $0x0
  pushl $133
80106fc5:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106fca:	e9 be f4 ff ff       	jmp    8010648d <alltraps>

80106fcf <vector134>:
.globl vector134
vector134:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $134
80106fd1:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106fd6:	e9 b2 f4 ff ff       	jmp    8010648d <alltraps>

80106fdb <vector135>:
.globl vector135
vector135:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $135
80106fdd:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106fe2:	e9 a6 f4 ff ff       	jmp    8010648d <alltraps>

80106fe7 <vector136>:
.globl vector136
vector136:
  pushl $0
80106fe7:	6a 00                	push   $0x0
  pushl $136
80106fe9:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106fee:	e9 9a f4 ff ff       	jmp    8010648d <alltraps>

80106ff3 <vector137>:
.globl vector137
vector137:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $137
80106ff5:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106ffa:	e9 8e f4 ff ff       	jmp    8010648d <alltraps>

80106fff <vector138>:
.globl vector138
vector138:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $138
80107001:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107006:	e9 82 f4 ff ff       	jmp    8010648d <alltraps>

8010700b <vector139>:
.globl vector139
vector139:
  pushl $0
8010700b:	6a 00                	push   $0x0
  pushl $139
8010700d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107012:	e9 76 f4 ff ff       	jmp    8010648d <alltraps>

80107017 <vector140>:
.globl vector140
vector140:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $140
80107019:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010701e:	e9 6a f4 ff ff       	jmp    8010648d <alltraps>

80107023 <vector141>:
.globl vector141
vector141:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $141
80107025:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010702a:	e9 5e f4 ff ff       	jmp    8010648d <alltraps>

8010702f <vector142>:
.globl vector142
vector142:
  pushl $0
8010702f:	6a 00                	push   $0x0
  pushl $142
80107031:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107036:	e9 52 f4 ff ff       	jmp    8010648d <alltraps>

8010703b <vector143>:
.globl vector143
vector143:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $143
8010703d:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107042:	e9 46 f4 ff ff       	jmp    8010648d <alltraps>

80107047 <vector144>:
.globl vector144
vector144:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $144
80107049:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010704e:	e9 3a f4 ff ff       	jmp    8010648d <alltraps>

80107053 <vector145>:
.globl vector145
vector145:
  pushl $0
80107053:	6a 00                	push   $0x0
  pushl $145
80107055:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010705a:	e9 2e f4 ff ff       	jmp    8010648d <alltraps>

8010705f <vector146>:
.globl vector146
vector146:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $146
80107061:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107066:	e9 22 f4 ff ff       	jmp    8010648d <alltraps>

8010706b <vector147>:
.globl vector147
vector147:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $147
8010706d:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107072:	e9 16 f4 ff ff       	jmp    8010648d <alltraps>

80107077 <vector148>:
.globl vector148
vector148:
  pushl $0
80107077:	6a 00                	push   $0x0
  pushl $148
80107079:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010707e:	e9 0a f4 ff ff       	jmp    8010648d <alltraps>

80107083 <vector149>:
.globl vector149
vector149:
  pushl $0
80107083:	6a 00                	push   $0x0
  pushl $149
80107085:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010708a:	e9 fe f3 ff ff       	jmp    8010648d <alltraps>

8010708f <vector150>:
.globl vector150
vector150:
  pushl $0
8010708f:	6a 00                	push   $0x0
  pushl $150
80107091:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107096:	e9 f2 f3 ff ff       	jmp    8010648d <alltraps>

8010709b <vector151>:
.globl vector151
vector151:
  pushl $0
8010709b:	6a 00                	push   $0x0
  pushl $151
8010709d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801070a2:	e9 e6 f3 ff ff       	jmp    8010648d <alltraps>

801070a7 <vector152>:
.globl vector152
vector152:
  pushl $0
801070a7:	6a 00                	push   $0x0
  pushl $152
801070a9:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801070ae:	e9 da f3 ff ff       	jmp    8010648d <alltraps>

801070b3 <vector153>:
.globl vector153
vector153:
  pushl $0
801070b3:	6a 00                	push   $0x0
  pushl $153
801070b5:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801070ba:	e9 ce f3 ff ff       	jmp    8010648d <alltraps>

801070bf <vector154>:
.globl vector154
vector154:
  pushl $0
801070bf:	6a 00                	push   $0x0
  pushl $154
801070c1:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801070c6:	e9 c2 f3 ff ff       	jmp    8010648d <alltraps>

801070cb <vector155>:
.globl vector155
vector155:
  pushl $0
801070cb:	6a 00                	push   $0x0
  pushl $155
801070cd:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801070d2:	e9 b6 f3 ff ff       	jmp    8010648d <alltraps>

801070d7 <vector156>:
.globl vector156
vector156:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $156
801070d9:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801070de:	e9 aa f3 ff ff       	jmp    8010648d <alltraps>

801070e3 <vector157>:
.globl vector157
vector157:
  pushl $0
801070e3:	6a 00                	push   $0x0
  pushl $157
801070e5:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801070ea:	e9 9e f3 ff ff       	jmp    8010648d <alltraps>

801070ef <vector158>:
.globl vector158
vector158:
  pushl $0
801070ef:	6a 00                	push   $0x0
  pushl $158
801070f1:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801070f6:	e9 92 f3 ff ff       	jmp    8010648d <alltraps>

801070fb <vector159>:
.globl vector159
vector159:
  pushl $0
801070fb:	6a 00                	push   $0x0
  pushl $159
801070fd:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107102:	e9 86 f3 ff ff       	jmp    8010648d <alltraps>

80107107 <vector160>:
.globl vector160
vector160:
  pushl $0
80107107:	6a 00                	push   $0x0
  pushl $160
80107109:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010710e:	e9 7a f3 ff ff       	jmp    8010648d <alltraps>

80107113 <vector161>:
.globl vector161
vector161:
  pushl $0
80107113:	6a 00                	push   $0x0
  pushl $161
80107115:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010711a:	e9 6e f3 ff ff       	jmp    8010648d <alltraps>

8010711f <vector162>:
.globl vector162
vector162:
  pushl $0
8010711f:	6a 00                	push   $0x0
  pushl $162
80107121:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107126:	e9 62 f3 ff ff       	jmp    8010648d <alltraps>

8010712b <vector163>:
.globl vector163
vector163:
  pushl $0
8010712b:	6a 00                	push   $0x0
  pushl $163
8010712d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107132:	e9 56 f3 ff ff       	jmp    8010648d <alltraps>

80107137 <vector164>:
.globl vector164
vector164:
  pushl $0
80107137:	6a 00                	push   $0x0
  pushl $164
80107139:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010713e:	e9 4a f3 ff ff       	jmp    8010648d <alltraps>

80107143 <vector165>:
.globl vector165
vector165:
  pushl $0
80107143:	6a 00                	push   $0x0
  pushl $165
80107145:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010714a:	e9 3e f3 ff ff       	jmp    8010648d <alltraps>

8010714f <vector166>:
.globl vector166
vector166:
  pushl $0
8010714f:	6a 00                	push   $0x0
  pushl $166
80107151:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107156:	e9 32 f3 ff ff       	jmp    8010648d <alltraps>

8010715b <vector167>:
.globl vector167
vector167:
  pushl $0
8010715b:	6a 00                	push   $0x0
  pushl $167
8010715d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107162:	e9 26 f3 ff ff       	jmp    8010648d <alltraps>

80107167 <vector168>:
.globl vector168
vector168:
  pushl $0
80107167:	6a 00                	push   $0x0
  pushl $168
80107169:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010716e:	e9 1a f3 ff ff       	jmp    8010648d <alltraps>

80107173 <vector169>:
.globl vector169
vector169:
  pushl $0
80107173:	6a 00                	push   $0x0
  pushl $169
80107175:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010717a:	e9 0e f3 ff ff       	jmp    8010648d <alltraps>

8010717f <vector170>:
.globl vector170
vector170:
  pushl $0
8010717f:	6a 00                	push   $0x0
  pushl $170
80107181:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107186:	e9 02 f3 ff ff       	jmp    8010648d <alltraps>

8010718b <vector171>:
.globl vector171
vector171:
  pushl $0
8010718b:	6a 00                	push   $0x0
  pushl $171
8010718d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107192:	e9 f6 f2 ff ff       	jmp    8010648d <alltraps>

80107197 <vector172>:
.globl vector172
vector172:
  pushl $0
80107197:	6a 00                	push   $0x0
  pushl $172
80107199:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010719e:	e9 ea f2 ff ff       	jmp    8010648d <alltraps>

801071a3 <vector173>:
.globl vector173
vector173:
  pushl $0
801071a3:	6a 00                	push   $0x0
  pushl $173
801071a5:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801071aa:	e9 de f2 ff ff       	jmp    8010648d <alltraps>

801071af <vector174>:
.globl vector174
vector174:
  pushl $0
801071af:	6a 00                	push   $0x0
  pushl $174
801071b1:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801071b6:	e9 d2 f2 ff ff       	jmp    8010648d <alltraps>

801071bb <vector175>:
.globl vector175
vector175:
  pushl $0
801071bb:	6a 00                	push   $0x0
  pushl $175
801071bd:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801071c2:	e9 c6 f2 ff ff       	jmp    8010648d <alltraps>

801071c7 <vector176>:
.globl vector176
vector176:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $176
801071c9:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801071ce:	e9 ba f2 ff ff       	jmp    8010648d <alltraps>

801071d3 <vector177>:
.globl vector177
vector177:
  pushl $0
801071d3:	6a 00                	push   $0x0
  pushl $177
801071d5:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801071da:	e9 ae f2 ff ff       	jmp    8010648d <alltraps>

801071df <vector178>:
.globl vector178
vector178:
  pushl $0
801071df:	6a 00                	push   $0x0
  pushl $178
801071e1:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801071e6:	e9 a2 f2 ff ff       	jmp    8010648d <alltraps>

801071eb <vector179>:
.globl vector179
vector179:
  pushl $0
801071eb:	6a 00                	push   $0x0
  pushl $179
801071ed:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801071f2:	e9 96 f2 ff ff       	jmp    8010648d <alltraps>

801071f7 <vector180>:
.globl vector180
vector180:
  pushl $0
801071f7:	6a 00                	push   $0x0
  pushl $180
801071f9:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801071fe:	e9 8a f2 ff ff       	jmp    8010648d <alltraps>

80107203 <vector181>:
.globl vector181
vector181:
  pushl $0
80107203:	6a 00                	push   $0x0
  pushl $181
80107205:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010720a:	e9 7e f2 ff ff       	jmp    8010648d <alltraps>

8010720f <vector182>:
.globl vector182
vector182:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $182
80107211:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107216:	e9 72 f2 ff ff       	jmp    8010648d <alltraps>

8010721b <vector183>:
.globl vector183
vector183:
  pushl $0
8010721b:	6a 00                	push   $0x0
  pushl $183
8010721d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107222:	e9 66 f2 ff ff       	jmp    8010648d <alltraps>

80107227 <vector184>:
.globl vector184
vector184:
  pushl $0
80107227:	6a 00                	push   $0x0
  pushl $184
80107229:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010722e:	e9 5a f2 ff ff       	jmp    8010648d <alltraps>

80107233 <vector185>:
.globl vector185
vector185:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $185
80107235:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010723a:	e9 4e f2 ff ff       	jmp    8010648d <alltraps>

8010723f <vector186>:
.globl vector186
vector186:
  pushl $0
8010723f:	6a 00                	push   $0x0
  pushl $186
80107241:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107246:	e9 42 f2 ff ff       	jmp    8010648d <alltraps>

8010724b <vector187>:
.globl vector187
vector187:
  pushl $0
8010724b:	6a 00                	push   $0x0
  pushl $187
8010724d:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107252:	e9 36 f2 ff ff       	jmp    8010648d <alltraps>

80107257 <vector188>:
.globl vector188
vector188:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $188
80107259:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010725e:	e9 2a f2 ff ff       	jmp    8010648d <alltraps>

80107263 <vector189>:
.globl vector189
vector189:
  pushl $0
80107263:	6a 00                	push   $0x0
  pushl $189
80107265:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010726a:	e9 1e f2 ff ff       	jmp    8010648d <alltraps>

8010726f <vector190>:
.globl vector190
vector190:
  pushl $0
8010726f:	6a 00                	push   $0x0
  pushl $190
80107271:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107276:	e9 12 f2 ff ff       	jmp    8010648d <alltraps>

8010727b <vector191>:
.globl vector191
vector191:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $191
8010727d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107282:	e9 06 f2 ff ff       	jmp    8010648d <alltraps>

80107287 <vector192>:
.globl vector192
vector192:
  pushl $0
80107287:	6a 00                	push   $0x0
  pushl $192
80107289:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010728e:	e9 fa f1 ff ff       	jmp    8010648d <alltraps>

80107293 <vector193>:
.globl vector193
vector193:
  pushl $0
80107293:	6a 00                	push   $0x0
  pushl $193
80107295:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010729a:	e9 ee f1 ff ff       	jmp    8010648d <alltraps>

8010729f <vector194>:
.globl vector194
vector194:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $194
801072a1:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801072a6:	e9 e2 f1 ff ff       	jmp    8010648d <alltraps>

801072ab <vector195>:
.globl vector195
vector195:
  pushl $0
801072ab:	6a 00                	push   $0x0
  pushl $195
801072ad:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801072b2:	e9 d6 f1 ff ff       	jmp    8010648d <alltraps>

801072b7 <vector196>:
.globl vector196
vector196:
  pushl $0
801072b7:	6a 00                	push   $0x0
  pushl $196
801072b9:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801072be:	e9 ca f1 ff ff       	jmp    8010648d <alltraps>

801072c3 <vector197>:
.globl vector197
vector197:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $197
801072c5:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801072ca:	e9 be f1 ff ff       	jmp    8010648d <alltraps>

801072cf <vector198>:
.globl vector198
vector198:
  pushl $0
801072cf:	6a 00                	push   $0x0
  pushl $198
801072d1:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801072d6:	e9 b2 f1 ff ff       	jmp    8010648d <alltraps>

801072db <vector199>:
.globl vector199
vector199:
  pushl $0
801072db:	6a 00                	push   $0x0
  pushl $199
801072dd:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801072e2:	e9 a6 f1 ff ff       	jmp    8010648d <alltraps>

801072e7 <vector200>:
.globl vector200
vector200:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $200
801072e9:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801072ee:	e9 9a f1 ff ff       	jmp    8010648d <alltraps>

801072f3 <vector201>:
.globl vector201
vector201:
  pushl $0
801072f3:	6a 00                	push   $0x0
  pushl $201
801072f5:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801072fa:	e9 8e f1 ff ff       	jmp    8010648d <alltraps>

801072ff <vector202>:
.globl vector202
vector202:
  pushl $0
801072ff:	6a 00                	push   $0x0
  pushl $202
80107301:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107306:	e9 82 f1 ff ff       	jmp    8010648d <alltraps>

8010730b <vector203>:
.globl vector203
vector203:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $203
8010730d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107312:	e9 76 f1 ff ff       	jmp    8010648d <alltraps>

80107317 <vector204>:
.globl vector204
vector204:
  pushl $0
80107317:	6a 00                	push   $0x0
  pushl $204
80107319:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010731e:	e9 6a f1 ff ff       	jmp    8010648d <alltraps>

80107323 <vector205>:
.globl vector205
vector205:
  pushl $0
80107323:	6a 00                	push   $0x0
  pushl $205
80107325:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010732a:	e9 5e f1 ff ff       	jmp    8010648d <alltraps>

8010732f <vector206>:
.globl vector206
vector206:
  pushl $0
8010732f:	6a 00                	push   $0x0
  pushl $206
80107331:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107336:	e9 52 f1 ff ff       	jmp    8010648d <alltraps>

8010733b <vector207>:
.globl vector207
vector207:
  pushl $0
8010733b:	6a 00                	push   $0x0
  pushl $207
8010733d:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107342:	e9 46 f1 ff ff       	jmp    8010648d <alltraps>

80107347 <vector208>:
.globl vector208
vector208:
  pushl $0
80107347:	6a 00                	push   $0x0
  pushl $208
80107349:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010734e:	e9 3a f1 ff ff       	jmp    8010648d <alltraps>

80107353 <vector209>:
.globl vector209
vector209:
  pushl $0
80107353:	6a 00                	push   $0x0
  pushl $209
80107355:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010735a:	e9 2e f1 ff ff       	jmp    8010648d <alltraps>

8010735f <vector210>:
.globl vector210
vector210:
  pushl $0
8010735f:	6a 00                	push   $0x0
  pushl $210
80107361:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107366:	e9 22 f1 ff ff       	jmp    8010648d <alltraps>

8010736b <vector211>:
.globl vector211
vector211:
  pushl $0
8010736b:	6a 00                	push   $0x0
  pushl $211
8010736d:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107372:	e9 16 f1 ff ff       	jmp    8010648d <alltraps>

80107377 <vector212>:
.globl vector212
vector212:
  pushl $0
80107377:	6a 00                	push   $0x0
  pushl $212
80107379:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010737e:	e9 0a f1 ff ff       	jmp    8010648d <alltraps>

80107383 <vector213>:
.globl vector213
vector213:
  pushl $0
80107383:	6a 00                	push   $0x0
  pushl $213
80107385:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010738a:	e9 fe f0 ff ff       	jmp    8010648d <alltraps>

8010738f <vector214>:
.globl vector214
vector214:
  pushl $0
8010738f:	6a 00                	push   $0x0
  pushl $214
80107391:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107396:	e9 f2 f0 ff ff       	jmp    8010648d <alltraps>

8010739b <vector215>:
.globl vector215
vector215:
  pushl $0
8010739b:	6a 00                	push   $0x0
  pushl $215
8010739d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801073a2:	e9 e6 f0 ff ff       	jmp    8010648d <alltraps>

801073a7 <vector216>:
.globl vector216
vector216:
  pushl $0
801073a7:	6a 00                	push   $0x0
  pushl $216
801073a9:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801073ae:	e9 da f0 ff ff       	jmp    8010648d <alltraps>

801073b3 <vector217>:
.globl vector217
vector217:
  pushl $0
801073b3:	6a 00                	push   $0x0
  pushl $217
801073b5:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801073ba:	e9 ce f0 ff ff       	jmp    8010648d <alltraps>

801073bf <vector218>:
.globl vector218
vector218:
  pushl $0
801073bf:	6a 00                	push   $0x0
  pushl $218
801073c1:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801073c6:	e9 c2 f0 ff ff       	jmp    8010648d <alltraps>

801073cb <vector219>:
.globl vector219
vector219:
  pushl $0
801073cb:	6a 00                	push   $0x0
  pushl $219
801073cd:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801073d2:	e9 b6 f0 ff ff       	jmp    8010648d <alltraps>

801073d7 <vector220>:
.globl vector220
vector220:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $220
801073d9:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801073de:	e9 aa f0 ff ff       	jmp    8010648d <alltraps>

801073e3 <vector221>:
.globl vector221
vector221:
  pushl $0
801073e3:	6a 00                	push   $0x0
  pushl $221
801073e5:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801073ea:	e9 9e f0 ff ff       	jmp    8010648d <alltraps>

801073ef <vector222>:
.globl vector222
vector222:
  pushl $0
801073ef:	6a 00                	push   $0x0
  pushl $222
801073f1:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801073f6:	e9 92 f0 ff ff       	jmp    8010648d <alltraps>

801073fb <vector223>:
.globl vector223
vector223:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $223
801073fd:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107402:	e9 86 f0 ff ff       	jmp    8010648d <alltraps>

80107407 <vector224>:
.globl vector224
vector224:
  pushl $0
80107407:	6a 00                	push   $0x0
  pushl $224
80107409:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010740e:	e9 7a f0 ff ff       	jmp    8010648d <alltraps>

80107413 <vector225>:
.globl vector225
vector225:
  pushl $0
80107413:	6a 00                	push   $0x0
  pushl $225
80107415:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010741a:	e9 6e f0 ff ff       	jmp    8010648d <alltraps>

8010741f <vector226>:
.globl vector226
vector226:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $226
80107421:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107426:	e9 62 f0 ff ff       	jmp    8010648d <alltraps>

8010742b <vector227>:
.globl vector227
vector227:
  pushl $0
8010742b:	6a 00                	push   $0x0
  pushl $227
8010742d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107432:	e9 56 f0 ff ff       	jmp    8010648d <alltraps>

80107437 <vector228>:
.globl vector228
vector228:
  pushl $0
80107437:	6a 00                	push   $0x0
  pushl $228
80107439:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010743e:	e9 4a f0 ff ff       	jmp    8010648d <alltraps>

80107443 <vector229>:
.globl vector229
vector229:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $229
80107445:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010744a:	e9 3e f0 ff ff       	jmp    8010648d <alltraps>

8010744f <vector230>:
.globl vector230
vector230:
  pushl $0
8010744f:	6a 00                	push   $0x0
  pushl $230
80107451:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107456:	e9 32 f0 ff ff       	jmp    8010648d <alltraps>

8010745b <vector231>:
.globl vector231
vector231:
  pushl $0
8010745b:	6a 00                	push   $0x0
  pushl $231
8010745d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107462:	e9 26 f0 ff ff       	jmp    8010648d <alltraps>

80107467 <vector232>:
.globl vector232
vector232:
  pushl $0
80107467:	6a 00                	push   $0x0
  pushl $232
80107469:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010746e:	e9 1a f0 ff ff       	jmp    8010648d <alltraps>

80107473 <vector233>:
.globl vector233
vector233:
  pushl $0
80107473:	6a 00                	push   $0x0
  pushl $233
80107475:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010747a:	e9 0e f0 ff ff       	jmp    8010648d <alltraps>

8010747f <vector234>:
.globl vector234
vector234:
  pushl $0
8010747f:	6a 00                	push   $0x0
  pushl $234
80107481:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107486:	e9 02 f0 ff ff       	jmp    8010648d <alltraps>

8010748b <vector235>:
.globl vector235
vector235:
  pushl $0
8010748b:	6a 00                	push   $0x0
  pushl $235
8010748d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107492:	e9 f6 ef ff ff       	jmp    8010648d <alltraps>

80107497 <vector236>:
.globl vector236
vector236:
  pushl $0
80107497:	6a 00                	push   $0x0
  pushl $236
80107499:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010749e:	e9 ea ef ff ff       	jmp    8010648d <alltraps>

801074a3 <vector237>:
.globl vector237
vector237:
  pushl $0
801074a3:	6a 00                	push   $0x0
  pushl $237
801074a5:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801074aa:	e9 de ef ff ff       	jmp    8010648d <alltraps>

801074af <vector238>:
.globl vector238
vector238:
  pushl $0
801074af:	6a 00                	push   $0x0
  pushl $238
801074b1:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801074b6:	e9 d2 ef ff ff       	jmp    8010648d <alltraps>

801074bb <vector239>:
.globl vector239
vector239:
  pushl $0
801074bb:	6a 00                	push   $0x0
  pushl $239
801074bd:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801074c2:	e9 c6 ef ff ff       	jmp    8010648d <alltraps>

801074c7 <vector240>:
.globl vector240
vector240:
  pushl $0
801074c7:	6a 00                	push   $0x0
  pushl $240
801074c9:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801074ce:	e9 ba ef ff ff       	jmp    8010648d <alltraps>

801074d3 <vector241>:
.globl vector241
vector241:
  pushl $0
801074d3:	6a 00                	push   $0x0
  pushl $241
801074d5:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801074da:	e9 ae ef ff ff       	jmp    8010648d <alltraps>

801074df <vector242>:
.globl vector242
vector242:
  pushl $0
801074df:	6a 00                	push   $0x0
  pushl $242
801074e1:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801074e6:	e9 a2 ef ff ff       	jmp    8010648d <alltraps>

801074eb <vector243>:
.globl vector243
vector243:
  pushl $0
801074eb:	6a 00                	push   $0x0
  pushl $243
801074ed:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801074f2:	e9 96 ef ff ff       	jmp    8010648d <alltraps>

801074f7 <vector244>:
.globl vector244
vector244:
  pushl $0
801074f7:	6a 00                	push   $0x0
  pushl $244
801074f9:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801074fe:	e9 8a ef ff ff       	jmp    8010648d <alltraps>

80107503 <vector245>:
.globl vector245
vector245:
  pushl $0
80107503:	6a 00                	push   $0x0
  pushl $245
80107505:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010750a:	e9 7e ef ff ff       	jmp    8010648d <alltraps>

8010750f <vector246>:
.globl vector246
vector246:
  pushl $0
8010750f:	6a 00                	push   $0x0
  pushl $246
80107511:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107516:	e9 72 ef ff ff       	jmp    8010648d <alltraps>

8010751b <vector247>:
.globl vector247
vector247:
  pushl $0
8010751b:	6a 00                	push   $0x0
  pushl $247
8010751d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107522:	e9 66 ef ff ff       	jmp    8010648d <alltraps>

80107527 <vector248>:
.globl vector248
vector248:
  pushl $0
80107527:	6a 00                	push   $0x0
  pushl $248
80107529:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010752e:	e9 5a ef ff ff       	jmp    8010648d <alltraps>

80107533 <vector249>:
.globl vector249
vector249:
  pushl $0
80107533:	6a 00                	push   $0x0
  pushl $249
80107535:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010753a:	e9 4e ef ff ff       	jmp    8010648d <alltraps>

8010753f <vector250>:
.globl vector250
vector250:
  pushl $0
8010753f:	6a 00                	push   $0x0
  pushl $250
80107541:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107546:	e9 42 ef ff ff       	jmp    8010648d <alltraps>

8010754b <vector251>:
.globl vector251
vector251:
  pushl $0
8010754b:	6a 00                	push   $0x0
  pushl $251
8010754d:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107552:	e9 36 ef ff ff       	jmp    8010648d <alltraps>

80107557 <vector252>:
.globl vector252
vector252:
  pushl $0
80107557:	6a 00                	push   $0x0
  pushl $252
80107559:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010755e:	e9 2a ef ff ff       	jmp    8010648d <alltraps>

80107563 <vector253>:
.globl vector253
vector253:
  pushl $0
80107563:	6a 00                	push   $0x0
  pushl $253
80107565:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010756a:	e9 1e ef ff ff       	jmp    8010648d <alltraps>

8010756f <vector254>:
.globl vector254
vector254:
  pushl $0
8010756f:	6a 00                	push   $0x0
  pushl $254
80107571:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107576:	e9 12 ef ff ff       	jmp    8010648d <alltraps>

8010757b <vector255>:
.globl vector255
vector255:
  pushl $0
8010757b:	6a 00                	push   $0x0
  pushl $255
8010757d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107582:	e9 06 ef ff ff       	jmp    8010648d <alltraps>

80107587 <lgdt>:
{
80107587:	55                   	push   %ebp
80107588:	89 e5                	mov    %esp,%ebp
8010758a:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010758d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107590:	83 e8 01             	sub    $0x1,%eax
80107593:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107597:	8b 45 08             	mov    0x8(%ebp),%eax
8010759a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010759e:	8b 45 08             	mov    0x8(%ebp),%eax
801075a1:	c1 e8 10             	shr    $0x10,%eax
801075a4:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801075a8:	8d 45 fa             	lea    -0x6(%ebp),%eax
801075ab:	0f 01 10             	lgdtl  (%eax)
}
801075ae:	90                   	nop
801075af:	c9                   	leave  
801075b0:	c3                   	ret    

801075b1 <ltr>:
{
801075b1:	55                   	push   %ebp
801075b2:	89 e5                	mov    %esp,%ebp
801075b4:	83 ec 04             	sub    $0x4,%esp
801075b7:	8b 45 08             	mov    0x8(%ebp),%eax
801075ba:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801075be:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801075c2:	0f 00 d8             	ltr    %ax
}
801075c5:	90                   	nop
801075c6:	c9                   	leave  
801075c7:	c3                   	ret    

801075c8 <lcr3>:

static inline void
lcr3(uint val)
{
801075c8:	55                   	push   %ebp
801075c9:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801075cb:	8b 45 08             	mov    0x8(%ebp),%eax
801075ce:	0f 22 d8             	mov    %eax,%cr3
}
801075d1:	90                   	nop
801075d2:	5d                   	pop    %ebp
801075d3:	c3                   	ret    

801075d4 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801075d4:	55                   	push   %ebp
801075d5:	89 e5                	mov    %esp,%ebp
801075d7:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801075da:	e8 bf c3 ff ff       	call   8010399e <cpuid>
801075df:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801075e5:	05 80 74 19 80       	add    $0x80197480,%eax
801075ea:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801075ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f0:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801075f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f9:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801075ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107602:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107609:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010760d:	83 e2 f0             	and    $0xfffffff0,%edx
80107610:	83 ca 0a             	or     $0xa,%edx
80107613:	88 50 7d             	mov    %dl,0x7d(%eax)
80107616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107619:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010761d:	83 ca 10             	or     $0x10,%edx
80107620:	88 50 7d             	mov    %dl,0x7d(%eax)
80107623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107626:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010762a:	83 e2 9f             	and    $0xffffff9f,%edx
8010762d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107633:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107637:	83 ca 80             	or     $0xffffff80,%edx
8010763a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010763d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107640:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107644:	83 ca 0f             	or     $0xf,%edx
80107647:	88 50 7e             	mov    %dl,0x7e(%eax)
8010764a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107651:	83 e2 ef             	and    $0xffffffef,%edx
80107654:	88 50 7e             	mov    %dl,0x7e(%eax)
80107657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010765a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010765e:	83 e2 df             	and    $0xffffffdf,%edx
80107661:	88 50 7e             	mov    %dl,0x7e(%eax)
80107664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107667:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010766b:	83 ca 40             	or     $0x40,%edx
8010766e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107674:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107678:	83 ca 80             	or     $0xffffff80,%edx
8010767b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010767e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107681:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107688:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010768f:	ff ff 
80107691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107694:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010769b:	00 00 
8010769d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a0:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801076a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076aa:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076b1:	83 e2 f0             	and    $0xfffffff0,%edx
801076b4:	83 ca 02             	or     $0x2,%edx
801076b7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076c7:	83 ca 10             	or     $0x10,%edx
801076ca:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076da:	83 e2 9f             	and    $0xffffff9f,%edx
801076dd:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076ed:	83 ca 80             	or     $0xffffff80,%edx
801076f0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107700:	83 ca 0f             	or     $0xf,%edx
80107703:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010770c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107713:	83 e2 ef             	and    $0xffffffef,%edx
80107716:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010771c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107726:	83 e2 df             	and    $0xffffffdf,%edx
80107729:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010772f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107732:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107739:	83 ca 40             	or     $0x40,%edx
8010773c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107745:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010774c:	83 ca 80             	or     $0xffffff80,%edx
8010774f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107758:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010775f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107762:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107769:	ff ff 
8010776b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776e:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107775:	00 00 
80107777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777a:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107781:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107784:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010778b:	83 e2 f0             	and    $0xfffffff0,%edx
8010778e:	83 ca 0a             	or     $0xa,%edx
80107791:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077a1:	83 ca 10             	or     $0x10,%edx
801077a4:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801077aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ad:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077b4:	83 ca 60             	or     $0x60,%edx
801077b7:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801077bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077c7:	83 ca 80             	or     $0xffffff80,%edx
801077ca:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801077d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d3:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077da:	83 ca 0f             	or     $0xf,%edx
801077dd:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e6:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077ed:	83 e2 ef             	and    $0xffffffef,%edx
801077f0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107800:	83 e2 df             	and    $0xffffffdf,%edx
80107803:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107809:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107813:	83 ca 40             	or     $0x40,%edx
80107816:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010781c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107826:	83 ca 80             	or     $0xffffff80,%edx
80107829:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010782f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107832:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783c:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107843:	ff ff 
80107845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107848:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010784f:	00 00 
80107851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107854:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010785b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107865:	83 e2 f0             	and    $0xfffffff0,%edx
80107868:	83 ca 02             	or     $0x2,%edx
8010786b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107874:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010787b:	83 ca 10             	or     $0x10,%edx
8010787e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107887:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010788e:	83 ca 60             	or     $0x60,%edx
80107891:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801078a1:	83 ca 80             	or     $0xffffff80,%edx
801078a4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ad:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078b4:	83 ca 0f             	or     $0xf,%edx
801078b7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078c7:	83 e2 ef             	and    $0xffffffef,%edx
801078ca:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078da:	83 e2 df             	and    $0xffffffdf,%edx
801078dd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078ed:	83 ca 40             	or     $0x40,%edx
801078f0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107900:	83 ca 80             	or     $0xffffff80,%edx
80107903:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790c:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107916:	83 c0 70             	add    $0x70,%eax
80107919:	83 ec 08             	sub    $0x8,%esp
8010791c:	6a 30                	push   $0x30
8010791e:	50                   	push   %eax
8010791f:	e8 63 fc ff ff       	call   80107587 <lgdt>
80107924:	83 c4 10             	add    $0x10,%esp
}
80107927:	90                   	nop
80107928:	c9                   	leave  
80107929:	c3                   	ret    

8010792a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010792a:	55                   	push   %ebp
8010792b:	89 e5                	mov    %esp,%ebp
8010792d:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107930:	8b 45 0c             	mov    0xc(%ebp),%eax
80107933:	c1 e8 16             	shr    $0x16,%eax
80107936:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010793d:	8b 45 08             	mov    0x8(%ebp),%eax
80107940:	01 d0                	add    %edx,%eax
80107942:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107945:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107948:	8b 00                	mov    (%eax),%eax
8010794a:	83 e0 01             	and    $0x1,%eax
8010794d:	85 c0                	test   %eax,%eax
8010794f:	74 14                	je     80107965 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107951:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107954:	8b 00                	mov    (%eax),%eax
80107956:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010795b:	05 00 00 00 80       	add    $0x80000000,%eax
80107960:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107963:	eb 42                	jmp    801079a7 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107965:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107969:	74 0e                	je     80107979 <walkpgdir+0x4f>
8010796b:	e8 31 ae ff ff       	call   801027a1 <kalloc>
80107970:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107973:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107977:	75 07                	jne    80107980 <walkpgdir+0x56>
      return 0;
80107979:	b8 00 00 00 00       	mov    $0x0,%eax
8010797e:	eb 3e                	jmp    801079be <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107980:	83 ec 04             	sub    $0x4,%esp
80107983:	68 00 10 00 00       	push   $0x1000
80107988:	6a 00                	push   $0x0
8010798a:	ff 75 f4             	push   -0xc(%ebp)
8010798d:	e8 0a d4 ff ff       	call   80104d9c <memset>
80107992:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107998:	05 00 00 00 80       	add    $0x80000000,%eax
8010799d:	83 c8 07             	or     $0x7,%eax
801079a0:	89 c2                	mov    %eax,%edx
801079a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079a5:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801079a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801079aa:	c1 e8 0c             	shr    $0xc,%eax
801079ad:	25 ff 03 00 00       	and    $0x3ff,%eax
801079b2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801079b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079bc:	01 d0                	add    %edx,%eax
}
801079be:	c9                   	leave  
801079bf:	c3                   	ret    

801079c0 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801079c0:	55                   	push   %ebp
801079c1:	89 e5                	mov    %esp,%ebp
801079c3:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801079c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801079c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801079d1:	8b 55 0c             	mov    0xc(%ebp),%edx
801079d4:	8b 45 10             	mov    0x10(%ebp),%eax
801079d7:	01 d0                	add    %edx,%eax
801079d9:	83 e8 01             	sub    $0x1,%eax
801079dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801079e4:	83 ec 04             	sub    $0x4,%esp
801079e7:	6a 01                	push   $0x1
801079e9:	ff 75 f4             	push   -0xc(%ebp)
801079ec:	ff 75 08             	push   0x8(%ebp)
801079ef:	e8 36 ff ff ff       	call   8010792a <walkpgdir>
801079f4:	83 c4 10             	add    $0x10,%esp
801079f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801079fa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801079fe:	75 07                	jne    80107a07 <mappages+0x47>
      return -1;
80107a00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a05:	eb 47                	jmp    80107a4e <mappages+0x8e>
    if(*pte & PTE_P)
80107a07:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a0a:	8b 00                	mov    (%eax),%eax
80107a0c:	83 e0 01             	and    $0x1,%eax
80107a0f:	85 c0                	test   %eax,%eax
80107a11:	74 0d                	je     80107a20 <mappages+0x60>
      panic("remap");
80107a13:	83 ec 0c             	sub    $0xc,%esp
80107a16:	68 40 ad 10 80       	push   $0x8010ad40
80107a1b:	e8 89 8b ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107a20:	8b 45 18             	mov    0x18(%ebp),%eax
80107a23:	0b 45 14             	or     0x14(%ebp),%eax
80107a26:	83 c8 01             	or     $0x1,%eax
80107a29:	89 c2                	mov    %eax,%edx
80107a2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a2e:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a33:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107a36:	74 10                	je     80107a48 <mappages+0x88>
      break;
    a += PGSIZE;
80107a38:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107a3f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107a46:	eb 9c                	jmp    801079e4 <mappages+0x24>
      break;
80107a48:	90                   	nop
  }
  return 0;
80107a49:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a4e:	c9                   	leave  
80107a4f:	c3                   	ret    

80107a50 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107a50:	55                   	push   %ebp
80107a51:	89 e5                	mov    %esp,%ebp
80107a53:	53                   	push   %ebx
80107a54:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107a57:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107a5e:	8b 15 60 77 19 80    	mov    0x80197760,%edx
80107a64:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107a69:	29 d0                	sub    %edx,%eax
80107a6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107a6e:	a1 58 77 19 80       	mov    0x80197758,%eax
80107a73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107a76:	8b 15 58 77 19 80    	mov    0x80197758,%edx
80107a7c:	a1 60 77 19 80       	mov    0x80197760,%eax
80107a81:	01 d0                	add    %edx,%eax
80107a83:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107a86:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a90:	83 c0 30             	add    $0x30,%eax
80107a93:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107a96:	89 10                	mov    %edx,(%eax)
80107a98:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107a9b:	89 50 04             	mov    %edx,0x4(%eax)
80107a9e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107aa1:	89 50 08             	mov    %edx,0x8(%eax)
80107aa4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107aa7:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107aaa:	e8 f2 ac ff ff       	call   801027a1 <kalloc>
80107aaf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ab2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ab6:	75 07                	jne    80107abf <setupkvm+0x6f>
    return 0;
80107ab8:	b8 00 00 00 00       	mov    $0x0,%eax
80107abd:	eb 78                	jmp    80107b37 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107abf:	83 ec 04             	sub    $0x4,%esp
80107ac2:	68 00 10 00 00       	push   $0x1000
80107ac7:	6a 00                	push   $0x0
80107ac9:	ff 75 f0             	push   -0x10(%ebp)
80107acc:	e8 cb d2 ff ff       	call   80104d9c <memset>
80107ad1:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ad4:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107adb:	eb 4e                	jmp    80107b2b <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae0:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae6:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aec:	8b 58 08             	mov    0x8(%eax),%ebx
80107aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af2:	8b 40 04             	mov    0x4(%eax),%eax
80107af5:	29 c3                	sub    %eax,%ebx
80107af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afa:	8b 00                	mov    (%eax),%eax
80107afc:	83 ec 0c             	sub    $0xc,%esp
80107aff:	51                   	push   %ecx
80107b00:	52                   	push   %edx
80107b01:	53                   	push   %ebx
80107b02:	50                   	push   %eax
80107b03:	ff 75 f0             	push   -0x10(%ebp)
80107b06:	e8 b5 fe ff ff       	call   801079c0 <mappages>
80107b0b:	83 c4 20             	add    $0x20,%esp
80107b0e:	85 c0                	test   %eax,%eax
80107b10:	79 15                	jns    80107b27 <setupkvm+0xd7>
      freevm(pgdir);
80107b12:	83 ec 0c             	sub    $0xc,%esp
80107b15:	ff 75 f0             	push   -0x10(%ebp)
80107b18:	e8 f5 04 00 00       	call   80108012 <freevm>
80107b1d:	83 c4 10             	add    $0x10,%esp
      return 0;
80107b20:	b8 00 00 00 00       	mov    $0x0,%eax
80107b25:	eb 10                	jmp    80107b37 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107b27:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107b2b:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107b32:	72 a9                	jb     80107add <setupkvm+0x8d>
    }
  return pgdir;
80107b34:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107b37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107b3a:	c9                   	leave  
80107b3b:	c3                   	ret    

80107b3c <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107b3c:	55                   	push   %ebp
80107b3d:	89 e5                	mov    %esp,%ebp
80107b3f:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107b42:	e8 09 ff ff ff       	call   80107a50 <setupkvm>
80107b47:	a3 7c 74 19 80       	mov    %eax,0x8019747c
  switchkvm();
80107b4c:	e8 03 00 00 00       	call   80107b54 <switchkvm>
}
80107b51:	90                   	nop
80107b52:	c9                   	leave  
80107b53:	c3                   	ret    

80107b54 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107b54:	55                   	push   %ebp
80107b55:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107b57:	a1 7c 74 19 80       	mov    0x8019747c,%eax
80107b5c:	05 00 00 00 80       	add    $0x80000000,%eax
80107b61:	50                   	push   %eax
80107b62:	e8 61 fa ff ff       	call   801075c8 <lcr3>
80107b67:	83 c4 04             	add    $0x4,%esp
}
80107b6a:	90                   	nop
80107b6b:	c9                   	leave  
80107b6c:	c3                   	ret    

80107b6d <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107b6d:	55                   	push   %ebp
80107b6e:	89 e5                	mov    %esp,%ebp
80107b70:	56                   	push   %esi
80107b71:	53                   	push   %ebx
80107b72:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107b75:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107b79:	75 0d                	jne    80107b88 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107b7b:	83 ec 0c             	sub    $0xc,%esp
80107b7e:	68 46 ad 10 80       	push   $0x8010ad46
80107b83:	e8 21 8a ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107b88:	8b 45 08             	mov    0x8(%ebp),%eax
80107b8b:	8b 40 08             	mov    0x8(%eax),%eax
80107b8e:	85 c0                	test   %eax,%eax
80107b90:	75 0d                	jne    80107b9f <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107b92:	83 ec 0c             	sub    $0xc,%esp
80107b95:	68 5c ad 10 80       	push   $0x8010ad5c
80107b9a:	e8 0a 8a ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80107ba2:	8b 40 04             	mov    0x4(%eax),%eax
80107ba5:	85 c0                	test   %eax,%eax
80107ba7:	75 0d                	jne    80107bb6 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107ba9:	83 ec 0c             	sub    $0xc,%esp
80107bac:	68 71 ad 10 80       	push   $0x8010ad71
80107bb1:	e8 f3 89 ff ff       	call   801005a9 <panic>

  pushcli();
80107bb6:	e8 d6 d0 ff ff       	call   80104c91 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107bbb:	e8 f9 bd ff ff       	call   801039b9 <mycpu>
80107bc0:	89 c3                	mov    %eax,%ebx
80107bc2:	e8 f2 bd ff ff       	call   801039b9 <mycpu>
80107bc7:	83 c0 08             	add    $0x8,%eax
80107bca:	89 c6                	mov    %eax,%esi
80107bcc:	e8 e8 bd ff ff       	call   801039b9 <mycpu>
80107bd1:	83 c0 08             	add    $0x8,%eax
80107bd4:	c1 e8 10             	shr    $0x10,%eax
80107bd7:	88 45 f7             	mov    %al,-0x9(%ebp)
80107bda:	e8 da bd ff ff       	call   801039b9 <mycpu>
80107bdf:	83 c0 08             	add    $0x8,%eax
80107be2:	c1 e8 18             	shr    $0x18,%eax
80107be5:	89 c2                	mov    %eax,%edx
80107be7:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107bee:	67 00 
80107bf0:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107bf7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107bfb:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107c01:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c08:	83 e0 f0             	and    $0xfffffff0,%eax
80107c0b:	83 c8 09             	or     $0x9,%eax
80107c0e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c14:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c1b:	83 c8 10             	or     $0x10,%eax
80107c1e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c24:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c2b:	83 e0 9f             	and    $0xffffff9f,%eax
80107c2e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c34:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c3b:	83 c8 80             	or     $0xffffff80,%eax
80107c3e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c44:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c4b:	83 e0 f0             	and    $0xfffffff0,%eax
80107c4e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c54:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c5b:	83 e0 ef             	and    $0xffffffef,%eax
80107c5e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c64:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c6b:	83 e0 df             	and    $0xffffffdf,%eax
80107c6e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c74:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c7b:	83 c8 40             	or     $0x40,%eax
80107c7e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c84:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c8b:	83 e0 7f             	and    $0x7f,%eax
80107c8e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c94:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107c9a:	e8 1a bd ff ff       	call   801039b9 <mycpu>
80107c9f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ca6:	83 e2 ef             	and    $0xffffffef,%edx
80107ca9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107caf:	e8 05 bd ff ff       	call   801039b9 <mycpu>
80107cb4:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107cba:	8b 45 08             	mov    0x8(%ebp),%eax
80107cbd:	8b 40 08             	mov    0x8(%eax),%eax
80107cc0:	89 c3                	mov    %eax,%ebx
80107cc2:	e8 f2 bc ff ff       	call   801039b9 <mycpu>
80107cc7:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107ccd:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107cd0:	e8 e4 bc ff ff       	call   801039b9 <mycpu>
80107cd5:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107cdb:	83 ec 0c             	sub    $0xc,%esp
80107cde:	6a 28                	push   $0x28
80107ce0:	e8 cc f8 ff ff       	call   801075b1 <ltr>
80107ce5:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107ce8:	8b 45 08             	mov    0x8(%ebp),%eax
80107ceb:	8b 40 04             	mov    0x4(%eax),%eax
80107cee:	05 00 00 00 80       	add    $0x80000000,%eax
80107cf3:	83 ec 0c             	sub    $0xc,%esp
80107cf6:	50                   	push   %eax
80107cf7:	e8 cc f8 ff ff       	call   801075c8 <lcr3>
80107cfc:	83 c4 10             	add    $0x10,%esp
  popcli();
80107cff:	e8 da cf ff ff       	call   80104cde <popcli>
}
80107d04:	90                   	nop
80107d05:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107d08:	5b                   	pop    %ebx
80107d09:	5e                   	pop    %esi
80107d0a:	5d                   	pop    %ebp
80107d0b:	c3                   	ret    

80107d0c <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107d0c:	55                   	push   %ebp
80107d0d:	89 e5                	mov    %esp,%ebp
80107d0f:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107d12:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107d19:	76 0d                	jbe    80107d28 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107d1b:	83 ec 0c             	sub    $0xc,%esp
80107d1e:	68 85 ad 10 80       	push   $0x8010ad85
80107d23:	e8 81 88 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107d28:	e8 74 aa ff ff       	call   801027a1 <kalloc>
80107d2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107d30:	83 ec 04             	sub    $0x4,%esp
80107d33:	68 00 10 00 00       	push   $0x1000
80107d38:	6a 00                	push   $0x0
80107d3a:	ff 75 f4             	push   -0xc(%ebp)
80107d3d:	e8 5a d0 ff ff       	call   80104d9c <memset>
80107d42:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d48:	05 00 00 00 80       	add    $0x80000000,%eax
80107d4d:	83 ec 0c             	sub    $0xc,%esp
80107d50:	6a 06                	push   $0x6
80107d52:	50                   	push   %eax
80107d53:	68 00 10 00 00       	push   $0x1000
80107d58:	6a 00                	push   $0x0
80107d5a:	ff 75 08             	push   0x8(%ebp)
80107d5d:	e8 5e fc ff ff       	call   801079c0 <mappages>
80107d62:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107d65:	83 ec 04             	sub    $0x4,%esp
80107d68:	ff 75 10             	push   0x10(%ebp)
80107d6b:	ff 75 0c             	push   0xc(%ebp)
80107d6e:	ff 75 f4             	push   -0xc(%ebp)
80107d71:	e8 e5 d0 ff ff       	call   80104e5b <memmove>
80107d76:	83 c4 10             	add    $0x10,%esp
}
80107d79:	90                   	nop
80107d7a:	c9                   	leave  
80107d7b:	c3                   	ret    

80107d7c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107d7c:	55                   	push   %ebp
80107d7d:	89 e5                	mov    %esp,%ebp
80107d7f:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107d82:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d85:	25 ff 0f 00 00       	and    $0xfff,%eax
80107d8a:	85 c0                	test   %eax,%eax
80107d8c:	74 0d                	je     80107d9b <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107d8e:	83 ec 0c             	sub    $0xc,%esp
80107d91:	68 a0 ad 10 80       	push   $0x8010ada0
80107d96:	e8 0e 88 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107d9b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107da2:	e9 8f 00 00 00       	jmp    80107e36 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107da7:	8b 55 0c             	mov    0xc(%ebp),%edx
80107daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dad:	01 d0                	add    %edx,%eax
80107daf:	83 ec 04             	sub    $0x4,%esp
80107db2:	6a 00                	push   $0x0
80107db4:	50                   	push   %eax
80107db5:	ff 75 08             	push   0x8(%ebp)
80107db8:	e8 6d fb ff ff       	call   8010792a <walkpgdir>
80107dbd:	83 c4 10             	add    $0x10,%esp
80107dc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107dc3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107dc7:	75 0d                	jne    80107dd6 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107dc9:	83 ec 0c             	sub    $0xc,%esp
80107dcc:	68 c3 ad 10 80       	push   $0x8010adc3
80107dd1:	e8 d3 87 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107dd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107dd9:	8b 00                	mov    (%eax),%eax
80107ddb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107de0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107de3:	8b 45 18             	mov    0x18(%ebp),%eax
80107de6:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107de9:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107dee:	77 0b                	ja     80107dfb <loaduvm+0x7f>
      n = sz - i;
80107df0:	8b 45 18             	mov    0x18(%ebp),%eax
80107df3:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107df6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107df9:	eb 07                	jmp    80107e02 <loaduvm+0x86>
    else
      n = PGSIZE;
80107dfb:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107e02:	8b 55 14             	mov    0x14(%ebp),%edx
80107e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e08:	01 d0                	add    %edx,%eax
80107e0a:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107e0d:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107e13:	ff 75 f0             	push   -0x10(%ebp)
80107e16:	50                   	push   %eax
80107e17:	52                   	push   %edx
80107e18:	ff 75 10             	push   0x10(%ebp)
80107e1b:	e8 b7 a0 ff ff       	call   80101ed7 <readi>
80107e20:	83 c4 10             	add    $0x10,%esp
80107e23:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107e26:	74 07                	je     80107e2f <loaduvm+0xb3>
      return -1;
80107e28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e2d:	eb 18                	jmp    80107e47 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107e2f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e39:	3b 45 18             	cmp    0x18(%ebp),%eax
80107e3c:	0f 82 65 ff ff ff    	jb     80107da7 <loaduvm+0x2b>
  }
  return 0;
80107e42:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e47:	c9                   	leave  
80107e48:	c3                   	ret    

80107e49 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107e49:	55                   	push   %ebp
80107e4a:	89 e5                	mov    %esp,%ebp
80107e4c:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107e4f:	8b 45 10             	mov    0x10(%ebp),%eax
80107e52:	85 c0                	test   %eax,%eax
80107e54:	79 0a                	jns    80107e60 <allocuvm+0x17>
    return 0;
80107e56:	b8 00 00 00 00       	mov    $0x0,%eax
80107e5b:	e9 ec 00 00 00       	jmp    80107f4c <allocuvm+0x103>
  if(newsz < oldsz)
80107e60:	8b 45 10             	mov    0x10(%ebp),%eax
80107e63:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e66:	73 08                	jae    80107e70 <allocuvm+0x27>
    return oldsz;
80107e68:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e6b:	e9 dc 00 00 00       	jmp    80107f4c <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107e70:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e73:	05 ff 0f 00 00       	add    $0xfff,%eax
80107e78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107e80:	e9 b8 00 00 00       	jmp    80107f3d <allocuvm+0xf4>
    mem = kalloc();
80107e85:	e8 17 a9 ff ff       	call   801027a1 <kalloc>
80107e8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107e8d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e91:	75 2e                	jne    80107ec1 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107e93:	83 ec 0c             	sub    $0xc,%esp
80107e96:	68 e1 ad 10 80       	push   $0x8010ade1
80107e9b:	e8 54 85 ff ff       	call   801003f4 <cprintf>
80107ea0:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107ea3:	83 ec 04             	sub    $0x4,%esp
80107ea6:	ff 75 0c             	push   0xc(%ebp)
80107ea9:	ff 75 10             	push   0x10(%ebp)
80107eac:	ff 75 08             	push   0x8(%ebp)
80107eaf:	e8 9a 00 00 00       	call   80107f4e <deallocuvm>
80107eb4:	83 c4 10             	add    $0x10,%esp
      return 0;
80107eb7:	b8 00 00 00 00       	mov    $0x0,%eax
80107ebc:	e9 8b 00 00 00       	jmp    80107f4c <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107ec1:	83 ec 04             	sub    $0x4,%esp
80107ec4:	68 00 10 00 00       	push   $0x1000
80107ec9:	6a 00                	push   $0x0
80107ecb:	ff 75 f0             	push   -0x10(%ebp)
80107ece:	e8 c9 ce ff ff       	call   80104d9c <memset>
80107ed3:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107ed6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ed9:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee2:	83 ec 0c             	sub    $0xc,%esp
80107ee5:	6a 06                	push   $0x6
80107ee7:	52                   	push   %edx
80107ee8:	68 00 10 00 00       	push   $0x1000
80107eed:	50                   	push   %eax
80107eee:	ff 75 08             	push   0x8(%ebp)
80107ef1:	e8 ca fa ff ff       	call   801079c0 <mappages>
80107ef6:	83 c4 20             	add    $0x20,%esp
80107ef9:	85 c0                	test   %eax,%eax
80107efb:	79 39                	jns    80107f36 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107efd:	83 ec 0c             	sub    $0xc,%esp
80107f00:	68 f9 ad 10 80       	push   $0x8010adf9
80107f05:	e8 ea 84 ff ff       	call   801003f4 <cprintf>
80107f0a:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107f0d:	83 ec 04             	sub    $0x4,%esp
80107f10:	ff 75 0c             	push   0xc(%ebp)
80107f13:	ff 75 10             	push   0x10(%ebp)
80107f16:	ff 75 08             	push   0x8(%ebp)
80107f19:	e8 30 00 00 00       	call   80107f4e <deallocuvm>
80107f1e:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107f21:	83 ec 0c             	sub    $0xc,%esp
80107f24:	ff 75 f0             	push   -0x10(%ebp)
80107f27:	e8 db a7 ff ff       	call   80102707 <kfree>
80107f2c:	83 c4 10             	add    $0x10,%esp
      return 0;
80107f2f:	b8 00 00 00 00       	mov    $0x0,%eax
80107f34:	eb 16                	jmp    80107f4c <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107f36:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f40:	3b 45 10             	cmp    0x10(%ebp),%eax
80107f43:	0f 82 3c ff ff ff    	jb     80107e85 <allocuvm+0x3c>
    }
  }
  return newsz;
80107f49:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f4c:	c9                   	leave  
80107f4d:	c3                   	ret    

80107f4e <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107f4e:	55                   	push   %ebp
80107f4f:	89 e5                	mov    %esp,%ebp
80107f51:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107f54:	8b 45 10             	mov    0x10(%ebp),%eax
80107f57:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f5a:	72 08                	jb     80107f64 <deallocuvm+0x16>
    return oldsz;
80107f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f5f:	e9 ac 00 00 00       	jmp    80108010 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107f64:	8b 45 10             	mov    0x10(%ebp),%eax
80107f67:	05 ff 0f 00 00       	add    $0xfff,%eax
80107f6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f71:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107f74:	e9 88 00 00 00       	jmp    80108001 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7c:	83 ec 04             	sub    $0x4,%esp
80107f7f:	6a 00                	push   $0x0
80107f81:	50                   	push   %eax
80107f82:	ff 75 08             	push   0x8(%ebp)
80107f85:	e8 a0 f9 ff ff       	call   8010792a <walkpgdir>
80107f8a:	83 c4 10             	add    $0x10,%esp
80107f8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107f90:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f94:	75 16                	jne    80107fac <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f99:	c1 e8 16             	shr    $0x16,%eax
80107f9c:	83 c0 01             	add    $0x1,%eax
80107f9f:	c1 e0 16             	shl    $0x16,%eax
80107fa2:	2d 00 10 00 00       	sub    $0x1000,%eax
80107fa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107faa:	eb 4e                	jmp    80107ffa <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107faf:	8b 00                	mov    (%eax),%eax
80107fb1:	83 e0 01             	and    $0x1,%eax
80107fb4:	85 c0                	test   %eax,%eax
80107fb6:	74 42                	je     80107ffa <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107fb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fbb:	8b 00                	mov    (%eax),%eax
80107fbd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fc2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107fc5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fc9:	75 0d                	jne    80107fd8 <deallocuvm+0x8a>
        panic("kfree");
80107fcb:	83 ec 0c             	sub    $0xc,%esp
80107fce:	68 15 ae 10 80       	push   $0x8010ae15
80107fd3:	e8 d1 85 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107fd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fdb:	05 00 00 00 80       	add    $0x80000000,%eax
80107fe0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107fe3:	83 ec 0c             	sub    $0xc,%esp
80107fe6:	ff 75 e8             	push   -0x18(%ebp)
80107fe9:	e8 19 a7 ff ff       	call   80102707 <kfree>
80107fee:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107ff1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ff4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107ffa:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108001:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108004:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108007:	0f 82 6c ff ff ff    	jb     80107f79 <deallocuvm+0x2b>
    }
  }
  return newsz;
8010800d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108010:	c9                   	leave  
80108011:	c3                   	ret    

80108012 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108012:	55                   	push   %ebp
80108013:	89 e5                	mov    %esp,%ebp
80108015:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108018:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010801c:	75 0d                	jne    8010802b <freevm+0x19>
    panic("freevm: no pgdir");
8010801e:	83 ec 0c             	sub    $0xc,%esp
80108021:	68 1b ae 10 80       	push   $0x8010ae1b
80108026:	e8 7e 85 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010802b:	83 ec 04             	sub    $0x4,%esp
8010802e:	6a 00                	push   $0x0
80108030:	68 00 00 00 80       	push   $0x80000000
80108035:	ff 75 08             	push   0x8(%ebp)
80108038:	e8 11 ff ff ff       	call   80107f4e <deallocuvm>
8010803d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108040:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108047:	eb 48                	jmp    80108091 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80108049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108053:	8b 45 08             	mov    0x8(%ebp),%eax
80108056:	01 d0                	add    %edx,%eax
80108058:	8b 00                	mov    (%eax),%eax
8010805a:	83 e0 01             	and    $0x1,%eax
8010805d:	85 c0                	test   %eax,%eax
8010805f:	74 2c                	je     8010808d <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108064:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010806b:	8b 45 08             	mov    0x8(%ebp),%eax
8010806e:	01 d0                	add    %edx,%eax
80108070:	8b 00                	mov    (%eax),%eax
80108072:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108077:	05 00 00 00 80       	add    $0x80000000,%eax
8010807c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010807f:	83 ec 0c             	sub    $0xc,%esp
80108082:	ff 75 f0             	push   -0x10(%ebp)
80108085:	e8 7d a6 ff ff       	call   80102707 <kfree>
8010808a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010808d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108091:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108098:	76 af                	jbe    80108049 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010809a:	83 ec 0c             	sub    $0xc,%esp
8010809d:	ff 75 08             	push   0x8(%ebp)
801080a0:	e8 62 a6 ff ff       	call   80102707 <kfree>
801080a5:	83 c4 10             	add    $0x10,%esp
}
801080a8:	90                   	nop
801080a9:	c9                   	leave  
801080aa:	c3                   	ret    

801080ab <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801080ab:	55                   	push   %ebp
801080ac:	89 e5                	mov    %esp,%ebp
801080ae:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801080b1:	83 ec 04             	sub    $0x4,%esp
801080b4:	6a 00                	push   $0x0
801080b6:	ff 75 0c             	push   0xc(%ebp)
801080b9:	ff 75 08             	push   0x8(%ebp)
801080bc:	e8 69 f8 ff ff       	call   8010792a <walkpgdir>
801080c1:	83 c4 10             	add    $0x10,%esp
801080c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801080c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801080cb:	75 0d                	jne    801080da <clearpteu+0x2f>
    panic("clearpteu");
801080cd:	83 ec 0c             	sub    $0xc,%esp
801080d0:	68 2c ae 10 80       	push   $0x8010ae2c
801080d5:	e8 cf 84 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
801080da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080dd:	8b 00                	mov    (%eax),%eax
801080df:	83 e0 fb             	and    $0xfffffffb,%eax
801080e2:	89 c2                	mov    %eax,%edx
801080e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e7:	89 10                	mov    %edx,(%eax)
}
801080e9:	90                   	nop
801080ea:	c9                   	leave  
801080eb:	c3                   	ret    

801080ec <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801080ec:	55                   	push   %ebp
801080ed:	89 e5                	mov    %esp,%ebp
801080ef:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801080f2:	e8 59 f9 ff ff       	call   80107a50 <setupkvm>
801080f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080fe:	75 0a                	jne    8010810a <copyuvm+0x1e>
    return 0;
80108100:	b8 00 00 00 00       	mov    $0x0,%eax
80108105:	e9 eb 00 00 00       	jmp    801081f5 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
8010810a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108111:	e9 b7 00 00 00       	jmp    801081cd <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108119:	83 ec 04             	sub    $0x4,%esp
8010811c:	6a 00                	push   $0x0
8010811e:	50                   	push   %eax
8010811f:	ff 75 08             	push   0x8(%ebp)
80108122:	e8 03 f8 ff ff       	call   8010792a <walkpgdir>
80108127:	83 c4 10             	add    $0x10,%esp
8010812a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010812d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108131:	75 0d                	jne    80108140 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80108133:	83 ec 0c             	sub    $0xc,%esp
80108136:	68 36 ae 10 80       	push   $0x8010ae36
8010813b:	e8 69 84 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80108140:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108143:	8b 00                	mov    (%eax),%eax
80108145:	83 e0 01             	and    $0x1,%eax
80108148:	85 c0                	test   %eax,%eax
8010814a:	75 0d                	jne    80108159 <copyuvm+0x6d>
      panic("copyuvm: page not present");
8010814c:	83 ec 0c             	sub    $0xc,%esp
8010814f:	68 50 ae 10 80       	push   $0x8010ae50
80108154:	e8 50 84 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80108159:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010815c:	8b 00                	mov    (%eax),%eax
8010815e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108163:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108166:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108169:	8b 00                	mov    (%eax),%eax
8010816b:	25 ff 0f 00 00       	and    $0xfff,%eax
80108170:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108173:	e8 29 a6 ff ff       	call   801027a1 <kalloc>
80108178:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010817b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010817f:	74 5d                	je     801081de <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108181:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108184:	05 00 00 00 80       	add    $0x80000000,%eax
80108189:	83 ec 04             	sub    $0x4,%esp
8010818c:	68 00 10 00 00       	push   $0x1000
80108191:	50                   	push   %eax
80108192:	ff 75 e0             	push   -0x20(%ebp)
80108195:	e8 c1 cc ff ff       	call   80104e5b <memmove>
8010819a:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
8010819d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801081a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801081a3:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801081a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ac:	83 ec 0c             	sub    $0xc,%esp
801081af:	52                   	push   %edx
801081b0:	51                   	push   %ecx
801081b1:	68 00 10 00 00       	push   $0x1000
801081b6:	50                   	push   %eax
801081b7:	ff 75 f0             	push   -0x10(%ebp)
801081ba:	e8 01 f8 ff ff       	call   801079c0 <mappages>
801081bf:	83 c4 20             	add    $0x20,%esp
801081c2:	85 c0                	test   %eax,%eax
801081c4:	78 1b                	js     801081e1 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
801081c6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081d3:	0f 82 3d ff ff ff    	jb     80108116 <copyuvm+0x2a>
      goto bad;
  }
  return d;
801081d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081dc:	eb 17                	jmp    801081f5 <copyuvm+0x109>
      goto bad;
801081de:	90                   	nop
801081df:	eb 01                	jmp    801081e2 <copyuvm+0xf6>
      goto bad;
801081e1:	90                   	nop

bad:
  freevm(d);
801081e2:	83 ec 0c             	sub    $0xc,%esp
801081e5:	ff 75 f0             	push   -0x10(%ebp)
801081e8:	e8 25 fe ff ff       	call   80108012 <freevm>
801081ed:	83 c4 10             	add    $0x10,%esp
  return 0;
801081f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801081f5:	c9                   	leave  
801081f6:	c3                   	ret    

801081f7 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801081f7:	55                   	push   %ebp
801081f8:	89 e5                	mov    %esp,%ebp
801081fa:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801081fd:	83 ec 04             	sub    $0x4,%esp
80108200:	6a 00                	push   $0x0
80108202:	ff 75 0c             	push   0xc(%ebp)
80108205:	ff 75 08             	push   0x8(%ebp)
80108208:	e8 1d f7 ff ff       	call   8010792a <walkpgdir>
8010820d:	83 c4 10             	add    $0x10,%esp
80108210:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108213:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108216:	8b 00                	mov    (%eax),%eax
80108218:	83 e0 01             	and    $0x1,%eax
8010821b:	85 c0                	test   %eax,%eax
8010821d:	75 07                	jne    80108226 <uva2ka+0x2f>
    return 0;
8010821f:	b8 00 00 00 00       	mov    $0x0,%eax
80108224:	eb 22                	jmp    80108248 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108226:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108229:	8b 00                	mov    (%eax),%eax
8010822b:	83 e0 04             	and    $0x4,%eax
8010822e:	85 c0                	test   %eax,%eax
80108230:	75 07                	jne    80108239 <uva2ka+0x42>
    return 0;
80108232:	b8 00 00 00 00       	mov    $0x0,%eax
80108237:	eb 0f                	jmp    80108248 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80108239:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010823c:	8b 00                	mov    (%eax),%eax
8010823e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108243:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108248:	c9                   	leave  
80108249:	c3                   	ret    

8010824a <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010824a:	55                   	push   %ebp
8010824b:	89 e5                	mov    %esp,%ebp
8010824d:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108250:	8b 45 10             	mov    0x10(%ebp),%eax
80108253:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108256:	eb 7f                	jmp    801082d7 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108258:	8b 45 0c             	mov    0xc(%ebp),%eax
8010825b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108260:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108263:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108266:	83 ec 08             	sub    $0x8,%esp
80108269:	50                   	push   %eax
8010826a:	ff 75 08             	push   0x8(%ebp)
8010826d:	e8 85 ff ff ff       	call   801081f7 <uva2ka>
80108272:	83 c4 10             	add    $0x10,%esp
80108275:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108278:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010827c:	75 07                	jne    80108285 <copyout+0x3b>
      return -1;
8010827e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108283:	eb 61                	jmp    801082e6 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108285:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108288:	2b 45 0c             	sub    0xc(%ebp),%eax
8010828b:	05 00 10 00 00       	add    $0x1000,%eax
80108290:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108293:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108296:	3b 45 14             	cmp    0x14(%ebp),%eax
80108299:	76 06                	jbe    801082a1 <copyout+0x57>
      n = len;
8010829b:	8b 45 14             	mov    0x14(%ebp),%eax
8010829e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801082a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801082a4:	2b 45 ec             	sub    -0x14(%ebp),%eax
801082a7:	89 c2                	mov    %eax,%edx
801082a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082ac:	01 d0                	add    %edx,%eax
801082ae:	83 ec 04             	sub    $0x4,%esp
801082b1:	ff 75 f0             	push   -0x10(%ebp)
801082b4:	ff 75 f4             	push   -0xc(%ebp)
801082b7:	50                   	push   %eax
801082b8:	e8 9e cb ff ff       	call   80104e5b <memmove>
801082bd:	83 c4 10             	add    $0x10,%esp
    len -= n;
801082c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082c3:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801082c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082c9:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801082cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082cf:	05 00 10 00 00       	add    $0x1000,%eax
801082d4:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801082d7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801082db:	0f 85 77 ff ff ff    	jne    80108258 <copyout+0xe>
  }
  return 0;
801082e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082e6:	c9                   	leave  
801082e7:	c3                   	ret    

801082e8 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801082e8:	55                   	push   %ebp
801082e9:	89 e5                	mov    %esp,%ebp
801082eb:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801082ee:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801082f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801082f8:	8b 40 08             	mov    0x8(%eax),%eax
801082fb:	05 00 00 00 80       	add    $0x80000000,%eax
80108300:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108303:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
8010830a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010830d:	8b 40 24             	mov    0x24(%eax),%eax
80108310:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80108315:	c7 05 50 77 19 80 00 	movl   $0x0,0x80197750
8010831c:	00 00 00 

  while(i<madt->len){
8010831f:	90                   	nop
80108320:	e9 bd 00 00 00       	jmp    801083e2 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80108325:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108328:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010832b:	01 d0                	add    %edx,%eax
8010832d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108330:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108333:	0f b6 00             	movzbl (%eax),%eax
80108336:	0f b6 c0             	movzbl %al,%eax
80108339:	83 f8 05             	cmp    $0x5,%eax
8010833c:	0f 87 a0 00 00 00    	ja     801083e2 <mpinit_uefi+0xfa>
80108342:	8b 04 85 6c ae 10 80 	mov    -0x7fef5194(,%eax,4),%eax
80108349:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
8010834b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010834e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108351:	a1 50 77 19 80       	mov    0x80197750,%eax
80108356:	83 f8 03             	cmp    $0x3,%eax
80108359:	7f 28                	jg     80108383 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
8010835b:	8b 15 50 77 19 80    	mov    0x80197750,%edx
80108361:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108364:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108368:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
8010836e:	81 c2 80 74 19 80    	add    $0x80197480,%edx
80108374:	88 02                	mov    %al,(%edx)
          ncpu++;
80108376:	a1 50 77 19 80       	mov    0x80197750,%eax
8010837b:	83 c0 01             	add    $0x1,%eax
8010837e:	a3 50 77 19 80       	mov    %eax,0x80197750
        }
        i += lapic_entry->record_len;
80108383:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108386:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010838a:	0f b6 c0             	movzbl %al,%eax
8010838d:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108390:	eb 50                	jmp    801083e2 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108392:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108395:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108398:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010839b:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010839f:	a2 54 77 19 80       	mov    %al,0x80197754
        i += ioapic->record_len;
801083a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801083a7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083ab:	0f b6 c0             	movzbl %al,%eax
801083ae:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801083b1:	eb 2f                	jmp    801083e2 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801083b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083b6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801083b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083bc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083c0:	0f b6 c0             	movzbl %al,%eax
801083c3:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801083c6:	eb 1a                	jmp    801083e2 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801083c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801083ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083d1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083d5:	0f b6 c0             	movzbl %al,%eax
801083d8:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801083db:	eb 05                	jmp    801083e2 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
801083dd:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801083e1:	90                   	nop
  while(i<madt->len){
801083e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e5:	8b 40 04             	mov    0x4(%eax),%eax
801083e8:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801083eb:	0f 82 34 ff ff ff    	jb     80108325 <mpinit_uefi+0x3d>
    }
  }

}
801083f1:	90                   	nop
801083f2:	90                   	nop
801083f3:	c9                   	leave  
801083f4:	c3                   	ret    

801083f5 <inb>:
{
801083f5:	55                   	push   %ebp
801083f6:	89 e5                	mov    %esp,%ebp
801083f8:	83 ec 14             	sub    $0x14,%esp
801083fb:	8b 45 08             	mov    0x8(%ebp),%eax
801083fe:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108402:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108406:	89 c2                	mov    %eax,%edx
80108408:	ec                   	in     (%dx),%al
80108409:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010840c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108410:	c9                   	leave  
80108411:	c3                   	ret    

80108412 <outb>:
{
80108412:	55                   	push   %ebp
80108413:	89 e5                	mov    %esp,%ebp
80108415:	83 ec 08             	sub    $0x8,%esp
80108418:	8b 45 08             	mov    0x8(%ebp),%eax
8010841b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010841e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108422:	89 d0                	mov    %edx,%eax
80108424:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108427:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010842b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010842f:	ee                   	out    %al,(%dx)
}
80108430:	90                   	nop
80108431:	c9                   	leave  
80108432:	c3                   	ret    

80108433 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108433:	55                   	push   %ebp
80108434:	89 e5                	mov    %esp,%ebp
80108436:	83 ec 28             	sub    $0x28,%esp
80108439:	8b 45 08             	mov    0x8(%ebp),%eax
8010843c:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
8010843f:	6a 00                	push   $0x0
80108441:	68 fa 03 00 00       	push   $0x3fa
80108446:	e8 c7 ff ff ff       	call   80108412 <outb>
8010844b:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010844e:	68 80 00 00 00       	push   $0x80
80108453:	68 fb 03 00 00       	push   $0x3fb
80108458:	e8 b5 ff ff ff       	call   80108412 <outb>
8010845d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108460:	6a 0c                	push   $0xc
80108462:	68 f8 03 00 00       	push   $0x3f8
80108467:	e8 a6 ff ff ff       	call   80108412 <outb>
8010846c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010846f:	6a 00                	push   $0x0
80108471:	68 f9 03 00 00       	push   $0x3f9
80108476:	e8 97 ff ff ff       	call   80108412 <outb>
8010847b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010847e:	6a 03                	push   $0x3
80108480:	68 fb 03 00 00       	push   $0x3fb
80108485:	e8 88 ff ff ff       	call   80108412 <outb>
8010848a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010848d:	6a 00                	push   $0x0
8010848f:	68 fc 03 00 00       	push   $0x3fc
80108494:	e8 79 ff ff ff       	call   80108412 <outb>
80108499:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010849c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084a3:	eb 11                	jmp    801084b6 <uart_debug+0x83>
801084a5:	83 ec 0c             	sub    $0xc,%esp
801084a8:	6a 0a                	push   $0xa
801084aa:	e8 89 a6 ff ff       	call   80102b38 <microdelay>
801084af:	83 c4 10             	add    $0x10,%esp
801084b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801084b6:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801084ba:	7f 1a                	jg     801084d6 <uart_debug+0xa3>
801084bc:	83 ec 0c             	sub    $0xc,%esp
801084bf:	68 fd 03 00 00       	push   $0x3fd
801084c4:	e8 2c ff ff ff       	call   801083f5 <inb>
801084c9:	83 c4 10             	add    $0x10,%esp
801084cc:	0f b6 c0             	movzbl %al,%eax
801084cf:	83 e0 20             	and    $0x20,%eax
801084d2:	85 c0                	test   %eax,%eax
801084d4:	74 cf                	je     801084a5 <uart_debug+0x72>
  outb(COM1+0, p);
801084d6:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801084da:	0f b6 c0             	movzbl %al,%eax
801084dd:	83 ec 08             	sub    $0x8,%esp
801084e0:	50                   	push   %eax
801084e1:	68 f8 03 00 00       	push   $0x3f8
801084e6:	e8 27 ff ff ff       	call   80108412 <outb>
801084eb:	83 c4 10             	add    $0x10,%esp
}
801084ee:	90                   	nop
801084ef:	c9                   	leave  
801084f0:	c3                   	ret    

801084f1 <uart_debugs>:

void uart_debugs(char *p){
801084f1:	55                   	push   %ebp
801084f2:	89 e5                	mov    %esp,%ebp
801084f4:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801084f7:	eb 1b                	jmp    80108514 <uart_debugs+0x23>
    uart_debug(*p++);
801084f9:	8b 45 08             	mov    0x8(%ebp),%eax
801084fc:	8d 50 01             	lea    0x1(%eax),%edx
801084ff:	89 55 08             	mov    %edx,0x8(%ebp)
80108502:	0f b6 00             	movzbl (%eax),%eax
80108505:	0f be c0             	movsbl %al,%eax
80108508:	83 ec 0c             	sub    $0xc,%esp
8010850b:	50                   	push   %eax
8010850c:	e8 22 ff ff ff       	call   80108433 <uart_debug>
80108511:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108514:	8b 45 08             	mov    0x8(%ebp),%eax
80108517:	0f b6 00             	movzbl (%eax),%eax
8010851a:	84 c0                	test   %al,%al
8010851c:	75 db                	jne    801084f9 <uart_debugs+0x8>
  }
}
8010851e:	90                   	nop
8010851f:	90                   	nop
80108520:	c9                   	leave  
80108521:	c3                   	ret    

80108522 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108522:	55                   	push   %ebp
80108523:	89 e5                	mov    %esp,%ebp
80108525:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108528:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010852f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108532:	8b 50 14             	mov    0x14(%eax),%edx
80108535:	8b 40 10             	mov    0x10(%eax),%eax
80108538:	a3 58 77 19 80       	mov    %eax,0x80197758
  gpu.vram_size = boot_param->graphic_config.frame_size;
8010853d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108540:	8b 50 1c             	mov    0x1c(%eax),%edx
80108543:	8b 40 18             	mov    0x18(%eax),%eax
80108546:	a3 60 77 19 80       	mov    %eax,0x80197760
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
8010854b:	8b 15 60 77 19 80    	mov    0x80197760,%edx
80108551:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80108556:	29 d0                	sub    %edx,%eax
80108558:	a3 5c 77 19 80       	mov    %eax,0x8019775c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010855d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108560:	8b 50 24             	mov    0x24(%eax),%edx
80108563:	8b 40 20             	mov    0x20(%eax),%eax
80108566:	a3 64 77 19 80       	mov    %eax,0x80197764
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
8010856b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010856e:	8b 50 2c             	mov    0x2c(%eax),%edx
80108571:	8b 40 28             	mov    0x28(%eax),%eax
80108574:	a3 68 77 19 80       	mov    %eax,0x80197768
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108579:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010857c:	8b 50 34             	mov    0x34(%eax),%edx
8010857f:	8b 40 30             	mov    0x30(%eax),%eax
80108582:	a3 6c 77 19 80       	mov    %eax,0x8019776c
}
80108587:	90                   	nop
80108588:	c9                   	leave  
80108589:	c3                   	ret    

8010858a <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010858a:	55                   	push   %ebp
8010858b:	89 e5                	mov    %esp,%ebp
8010858d:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108590:	8b 15 6c 77 19 80    	mov    0x8019776c,%edx
80108596:	8b 45 0c             	mov    0xc(%ebp),%eax
80108599:	0f af d0             	imul   %eax,%edx
8010859c:	8b 45 08             	mov    0x8(%ebp),%eax
8010859f:	01 d0                	add    %edx,%eax
801085a1:	c1 e0 02             	shl    $0x2,%eax
801085a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801085a7:	8b 15 5c 77 19 80    	mov    0x8019775c,%edx
801085ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801085b0:	01 d0                	add    %edx,%eax
801085b2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801085b5:	8b 45 10             	mov    0x10(%ebp),%eax
801085b8:	0f b6 10             	movzbl (%eax),%edx
801085bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801085be:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801085c0:	8b 45 10             	mov    0x10(%ebp),%eax
801085c3:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801085c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801085ca:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801085cd:	8b 45 10             	mov    0x10(%ebp),%eax
801085d0:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801085d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801085d7:	88 50 02             	mov    %dl,0x2(%eax)
}
801085da:	90                   	nop
801085db:	c9                   	leave  
801085dc:	c3                   	ret    

801085dd <graphic_scroll_up>:

void graphic_scroll_up(int height){
801085dd:	55                   	push   %ebp
801085de:	89 e5                	mov    %esp,%ebp
801085e0:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801085e3:	8b 15 6c 77 19 80    	mov    0x8019776c,%edx
801085e9:	8b 45 08             	mov    0x8(%ebp),%eax
801085ec:	0f af c2             	imul   %edx,%eax
801085ef:	c1 e0 02             	shl    $0x2,%eax
801085f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801085f5:	a1 60 77 19 80       	mov    0x80197760,%eax
801085fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085fd:	29 d0                	sub    %edx,%eax
801085ff:	8b 0d 5c 77 19 80    	mov    0x8019775c,%ecx
80108605:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108608:	01 ca                	add    %ecx,%edx
8010860a:	89 d1                	mov    %edx,%ecx
8010860c:	8b 15 5c 77 19 80    	mov    0x8019775c,%edx
80108612:	83 ec 04             	sub    $0x4,%esp
80108615:	50                   	push   %eax
80108616:	51                   	push   %ecx
80108617:	52                   	push   %edx
80108618:	e8 3e c8 ff ff       	call   80104e5b <memmove>
8010861d:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108623:	8b 0d 5c 77 19 80    	mov    0x8019775c,%ecx
80108629:	8b 15 60 77 19 80    	mov    0x80197760,%edx
8010862f:	01 ca                	add    %ecx,%edx
80108631:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108634:	29 ca                	sub    %ecx,%edx
80108636:	83 ec 04             	sub    $0x4,%esp
80108639:	50                   	push   %eax
8010863a:	6a 00                	push   $0x0
8010863c:	52                   	push   %edx
8010863d:	e8 5a c7 ff ff       	call   80104d9c <memset>
80108642:	83 c4 10             	add    $0x10,%esp
}
80108645:	90                   	nop
80108646:	c9                   	leave  
80108647:	c3                   	ret    

80108648 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108648:	55                   	push   %ebp
80108649:	89 e5                	mov    %esp,%ebp
8010864b:	53                   	push   %ebx
8010864c:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
8010864f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108656:	e9 b1 00 00 00       	jmp    8010870c <font_render+0xc4>
    for(int j=14;j>-1;j--){
8010865b:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108662:	e9 97 00 00 00       	jmp    801086fe <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108667:	8b 45 10             	mov    0x10(%ebp),%eax
8010866a:	83 e8 20             	sub    $0x20,%eax
8010866d:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108673:	01 d0                	add    %edx,%eax
80108675:	0f b7 84 00 a0 ae 10 	movzwl -0x7fef5160(%eax,%eax,1),%eax
8010867c:	80 
8010867d:	0f b7 d0             	movzwl %ax,%edx
80108680:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108683:	bb 01 00 00 00       	mov    $0x1,%ebx
80108688:	89 c1                	mov    %eax,%ecx
8010868a:	d3 e3                	shl    %cl,%ebx
8010868c:	89 d8                	mov    %ebx,%eax
8010868e:	21 d0                	and    %edx,%eax
80108690:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108693:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108696:	ba 01 00 00 00       	mov    $0x1,%edx
8010869b:	89 c1                	mov    %eax,%ecx
8010869d:	d3 e2                	shl    %cl,%edx
8010869f:	89 d0                	mov    %edx,%eax
801086a1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801086a4:	75 2b                	jne    801086d1 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801086a6:	8b 55 0c             	mov    0xc(%ebp),%edx
801086a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ac:	01 c2                	add    %eax,%edx
801086ae:	b8 0e 00 00 00       	mov    $0xe,%eax
801086b3:	2b 45 f0             	sub    -0x10(%ebp),%eax
801086b6:	89 c1                	mov    %eax,%ecx
801086b8:	8b 45 08             	mov    0x8(%ebp),%eax
801086bb:	01 c8                	add    %ecx,%eax
801086bd:	83 ec 04             	sub    $0x4,%esp
801086c0:	68 00 f5 10 80       	push   $0x8010f500
801086c5:	52                   	push   %edx
801086c6:	50                   	push   %eax
801086c7:	e8 be fe ff ff       	call   8010858a <graphic_draw_pixel>
801086cc:	83 c4 10             	add    $0x10,%esp
801086cf:	eb 29                	jmp    801086fa <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801086d1:	8b 55 0c             	mov    0xc(%ebp),%edx
801086d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d7:	01 c2                	add    %eax,%edx
801086d9:	b8 0e 00 00 00       	mov    $0xe,%eax
801086de:	2b 45 f0             	sub    -0x10(%ebp),%eax
801086e1:	89 c1                	mov    %eax,%ecx
801086e3:	8b 45 08             	mov    0x8(%ebp),%eax
801086e6:	01 c8                	add    %ecx,%eax
801086e8:	83 ec 04             	sub    $0x4,%esp
801086eb:	68 70 77 19 80       	push   $0x80197770
801086f0:	52                   	push   %edx
801086f1:	50                   	push   %eax
801086f2:	e8 93 fe ff ff       	call   8010858a <graphic_draw_pixel>
801086f7:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801086fa:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801086fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108702:	0f 89 5f ff ff ff    	jns    80108667 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108708:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010870c:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108710:	0f 8e 45 ff ff ff    	jle    8010865b <font_render+0x13>
      }
    }
  }
}
80108716:	90                   	nop
80108717:	90                   	nop
80108718:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010871b:	c9                   	leave  
8010871c:	c3                   	ret    

8010871d <font_render_string>:

void font_render_string(char *string,int row){
8010871d:	55                   	push   %ebp
8010871e:	89 e5                	mov    %esp,%ebp
80108720:	53                   	push   %ebx
80108721:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108724:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010872b:	eb 33                	jmp    80108760 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
8010872d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108730:	8b 45 08             	mov    0x8(%ebp),%eax
80108733:	01 d0                	add    %edx,%eax
80108735:	0f b6 00             	movzbl (%eax),%eax
80108738:	0f be c8             	movsbl %al,%ecx
8010873b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010873e:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108741:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80108744:	89 d8                	mov    %ebx,%eax
80108746:	c1 e0 04             	shl    $0x4,%eax
80108749:	29 d8                	sub    %ebx,%eax
8010874b:	83 c0 02             	add    $0x2,%eax
8010874e:	83 ec 04             	sub    $0x4,%esp
80108751:	51                   	push   %ecx
80108752:	52                   	push   %edx
80108753:	50                   	push   %eax
80108754:	e8 ef fe ff ff       	call   80108648 <font_render>
80108759:	83 c4 10             	add    $0x10,%esp
    i++;
8010875c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108760:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108763:	8b 45 08             	mov    0x8(%ebp),%eax
80108766:	01 d0                	add    %edx,%eax
80108768:	0f b6 00             	movzbl (%eax),%eax
8010876b:	84 c0                	test   %al,%al
8010876d:	74 06                	je     80108775 <font_render_string+0x58>
8010876f:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108773:	7e b8                	jle    8010872d <font_render_string+0x10>
  }
}
80108775:	90                   	nop
80108776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108779:	c9                   	leave  
8010877a:	c3                   	ret    

8010877b <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010877b:	55                   	push   %ebp
8010877c:	89 e5                	mov    %esp,%ebp
8010877e:	53                   	push   %ebx
8010877f:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108782:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108789:	eb 6b                	jmp    801087f6 <pci_init+0x7b>
    for(int j=0;j<32;j++){
8010878b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108792:	eb 58                	jmp    801087ec <pci_init+0x71>
      for(int k=0;k<8;k++){
80108794:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010879b:	eb 45                	jmp    801087e2 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
8010879d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801087a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801087a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a6:	83 ec 0c             	sub    $0xc,%esp
801087a9:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801087ac:	53                   	push   %ebx
801087ad:	6a 00                	push   $0x0
801087af:	51                   	push   %ecx
801087b0:	52                   	push   %edx
801087b1:	50                   	push   %eax
801087b2:	e8 b0 00 00 00       	call   80108867 <pci_access_config>
801087b7:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801087ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087bd:	0f b7 c0             	movzwl %ax,%eax
801087c0:	3d ff ff 00 00       	cmp    $0xffff,%eax
801087c5:	74 17                	je     801087de <pci_init+0x63>
        pci_init_device(i,j,k);
801087c7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801087ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
801087cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d0:	83 ec 04             	sub    $0x4,%esp
801087d3:	51                   	push   %ecx
801087d4:	52                   	push   %edx
801087d5:	50                   	push   %eax
801087d6:	e8 37 01 00 00       	call   80108912 <pci_init_device>
801087db:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801087de:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801087e2:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801087e6:	7e b5                	jle    8010879d <pci_init+0x22>
    for(int j=0;j<32;j++){
801087e8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801087ec:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801087f0:	7e a2                	jle    80108794 <pci_init+0x19>
  for(int i=0;i<256;i++){
801087f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801087f6:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801087fd:	7e 8c                	jle    8010878b <pci_init+0x10>
      }
      }
    }
  }
}
801087ff:	90                   	nop
80108800:	90                   	nop
80108801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108804:	c9                   	leave  
80108805:	c3                   	ret    

80108806 <pci_write_config>:

void pci_write_config(uint config){
80108806:	55                   	push   %ebp
80108807:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108809:	8b 45 08             	mov    0x8(%ebp),%eax
8010880c:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108811:	89 c0                	mov    %eax,%eax
80108813:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108814:	90                   	nop
80108815:	5d                   	pop    %ebp
80108816:	c3                   	ret    

80108817 <pci_write_data>:

void pci_write_data(uint config){
80108817:	55                   	push   %ebp
80108818:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
8010881a:	8b 45 08             	mov    0x8(%ebp),%eax
8010881d:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108822:	89 c0                	mov    %eax,%eax
80108824:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108825:	90                   	nop
80108826:	5d                   	pop    %ebp
80108827:	c3                   	ret    

80108828 <pci_read_config>:
uint pci_read_config(){
80108828:	55                   	push   %ebp
80108829:	89 e5                	mov    %esp,%ebp
8010882b:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
8010882e:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108833:	ed                   	in     (%dx),%eax
80108834:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108837:	83 ec 0c             	sub    $0xc,%esp
8010883a:	68 c8 00 00 00       	push   $0xc8
8010883f:	e8 f4 a2 ff ff       	call   80102b38 <microdelay>
80108844:	83 c4 10             	add    $0x10,%esp
  return data;
80108847:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010884a:	c9                   	leave  
8010884b:	c3                   	ret    

8010884c <pci_test>:


void pci_test(){
8010884c:	55                   	push   %ebp
8010884d:	89 e5                	mov    %esp,%ebp
8010884f:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108852:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108859:	ff 75 fc             	push   -0x4(%ebp)
8010885c:	e8 a5 ff ff ff       	call   80108806 <pci_write_config>
80108861:	83 c4 04             	add    $0x4,%esp
}
80108864:	90                   	nop
80108865:	c9                   	leave  
80108866:	c3                   	ret    

80108867 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108867:	55                   	push   %ebp
80108868:	89 e5                	mov    %esp,%ebp
8010886a:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010886d:	8b 45 08             	mov    0x8(%ebp),%eax
80108870:	c1 e0 10             	shl    $0x10,%eax
80108873:	25 00 00 ff 00       	and    $0xff0000,%eax
80108878:	89 c2                	mov    %eax,%edx
8010887a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010887d:	c1 e0 0b             	shl    $0xb,%eax
80108880:	0f b7 c0             	movzwl %ax,%eax
80108883:	09 c2                	or     %eax,%edx
80108885:	8b 45 10             	mov    0x10(%ebp),%eax
80108888:	c1 e0 08             	shl    $0x8,%eax
8010888b:	25 00 07 00 00       	and    $0x700,%eax
80108890:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108892:	8b 45 14             	mov    0x14(%ebp),%eax
80108895:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010889a:	09 d0                	or     %edx,%eax
8010889c:	0d 00 00 00 80       	or     $0x80000000,%eax
801088a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801088a4:	ff 75 f4             	push   -0xc(%ebp)
801088a7:	e8 5a ff ff ff       	call   80108806 <pci_write_config>
801088ac:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801088af:	e8 74 ff ff ff       	call   80108828 <pci_read_config>
801088b4:	8b 55 18             	mov    0x18(%ebp),%edx
801088b7:	89 02                	mov    %eax,(%edx)
}
801088b9:	90                   	nop
801088ba:	c9                   	leave  
801088bb:	c3                   	ret    

801088bc <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801088bc:	55                   	push   %ebp
801088bd:	89 e5                	mov    %esp,%ebp
801088bf:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801088c2:	8b 45 08             	mov    0x8(%ebp),%eax
801088c5:	c1 e0 10             	shl    $0x10,%eax
801088c8:	25 00 00 ff 00       	and    $0xff0000,%eax
801088cd:	89 c2                	mov    %eax,%edx
801088cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801088d2:	c1 e0 0b             	shl    $0xb,%eax
801088d5:	0f b7 c0             	movzwl %ax,%eax
801088d8:	09 c2                	or     %eax,%edx
801088da:	8b 45 10             	mov    0x10(%ebp),%eax
801088dd:	c1 e0 08             	shl    $0x8,%eax
801088e0:	25 00 07 00 00       	and    $0x700,%eax
801088e5:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801088e7:	8b 45 14             	mov    0x14(%ebp),%eax
801088ea:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801088ef:	09 d0                	or     %edx,%eax
801088f1:	0d 00 00 00 80       	or     $0x80000000,%eax
801088f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801088f9:	ff 75 fc             	push   -0x4(%ebp)
801088fc:	e8 05 ff ff ff       	call   80108806 <pci_write_config>
80108901:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108904:	ff 75 18             	push   0x18(%ebp)
80108907:	e8 0b ff ff ff       	call   80108817 <pci_write_data>
8010890c:	83 c4 04             	add    $0x4,%esp
}
8010890f:	90                   	nop
80108910:	c9                   	leave  
80108911:	c3                   	ret    

80108912 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108912:	55                   	push   %ebp
80108913:	89 e5                	mov    %esp,%ebp
80108915:	53                   	push   %ebx
80108916:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108919:	8b 45 08             	mov    0x8(%ebp),%eax
8010891c:	a2 74 77 19 80       	mov    %al,0x80197774
  dev.device_num = device_num;
80108921:	8b 45 0c             	mov    0xc(%ebp),%eax
80108924:	a2 75 77 19 80       	mov    %al,0x80197775
  dev.function_num = function_num;
80108929:	8b 45 10             	mov    0x10(%ebp),%eax
8010892c:	a2 76 77 19 80       	mov    %al,0x80197776
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108931:	ff 75 10             	push   0x10(%ebp)
80108934:	ff 75 0c             	push   0xc(%ebp)
80108937:	ff 75 08             	push   0x8(%ebp)
8010893a:	68 e4 c4 10 80       	push   $0x8010c4e4
8010893f:	e8 b0 7a ff ff       	call   801003f4 <cprintf>
80108944:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108947:	83 ec 0c             	sub    $0xc,%esp
8010894a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010894d:	50                   	push   %eax
8010894e:	6a 00                	push   $0x0
80108950:	ff 75 10             	push   0x10(%ebp)
80108953:	ff 75 0c             	push   0xc(%ebp)
80108956:	ff 75 08             	push   0x8(%ebp)
80108959:	e8 09 ff ff ff       	call   80108867 <pci_access_config>
8010895e:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108961:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108964:	c1 e8 10             	shr    $0x10,%eax
80108967:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010896a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010896d:	25 ff ff 00 00       	and    $0xffff,%eax
80108972:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108978:	a3 78 77 19 80       	mov    %eax,0x80197778
  dev.vendor_id = vendor_id;
8010897d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108980:	a3 7c 77 19 80       	mov    %eax,0x8019777c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108985:	83 ec 04             	sub    $0x4,%esp
80108988:	ff 75 f0             	push   -0x10(%ebp)
8010898b:	ff 75 f4             	push   -0xc(%ebp)
8010898e:	68 18 c5 10 80       	push   $0x8010c518
80108993:	e8 5c 7a ff ff       	call   801003f4 <cprintf>
80108998:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010899b:	83 ec 0c             	sub    $0xc,%esp
8010899e:	8d 45 ec             	lea    -0x14(%ebp),%eax
801089a1:	50                   	push   %eax
801089a2:	6a 08                	push   $0x8
801089a4:	ff 75 10             	push   0x10(%ebp)
801089a7:	ff 75 0c             	push   0xc(%ebp)
801089aa:	ff 75 08             	push   0x8(%ebp)
801089ad:	e8 b5 fe ff ff       	call   80108867 <pci_access_config>
801089b2:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801089b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089b8:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801089bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089be:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801089c1:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801089c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089c7:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801089ca:	0f b6 c0             	movzbl %al,%eax
801089cd:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801089d0:	c1 eb 18             	shr    $0x18,%ebx
801089d3:	83 ec 0c             	sub    $0xc,%esp
801089d6:	51                   	push   %ecx
801089d7:	52                   	push   %edx
801089d8:	50                   	push   %eax
801089d9:	53                   	push   %ebx
801089da:	68 3c c5 10 80       	push   $0x8010c53c
801089df:	e8 10 7a ff ff       	call   801003f4 <cprintf>
801089e4:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
801089e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089ea:	c1 e8 18             	shr    $0x18,%eax
801089ed:	a2 80 77 19 80       	mov    %al,0x80197780
  dev.sub_class = (data>>16)&0xFF;
801089f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089f5:	c1 e8 10             	shr    $0x10,%eax
801089f8:	a2 81 77 19 80       	mov    %al,0x80197781
  dev.interface = (data>>8)&0xFF;
801089fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a00:	c1 e8 08             	shr    $0x8,%eax
80108a03:	a2 82 77 19 80       	mov    %al,0x80197782
  dev.revision_id = data&0xFF;
80108a08:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a0b:	a2 83 77 19 80       	mov    %al,0x80197783
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108a10:	83 ec 0c             	sub    $0xc,%esp
80108a13:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a16:	50                   	push   %eax
80108a17:	6a 10                	push   $0x10
80108a19:	ff 75 10             	push   0x10(%ebp)
80108a1c:	ff 75 0c             	push   0xc(%ebp)
80108a1f:	ff 75 08             	push   0x8(%ebp)
80108a22:	e8 40 fe ff ff       	call   80108867 <pci_access_config>
80108a27:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108a2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a2d:	a3 84 77 19 80       	mov    %eax,0x80197784
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108a32:	83 ec 0c             	sub    $0xc,%esp
80108a35:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a38:	50                   	push   %eax
80108a39:	6a 14                	push   $0x14
80108a3b:	ff 75 10             	push   0x10(%ebp)
80108a3e:	ff 75 0c             	push   0xc(%ebp)
80108a41:	ff 75 08             	push   0x8(%ebp)
80108a44:	e8 1e fe ff ff       	call   80108867 <pci_access_config>
80108a49:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108a4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a4f:	a3 88 77 19 80       	mov    %eax,0x80197788
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108a54:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108a5b:	75 5a                	jne    80108ab7 <pci_init_device+0x1a5>
80108a5d:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108a64:	75 51                	jne    80108ab7 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108a66:	83 ec 0c             	sub    $0xc,%esp
80108a69:	68 81 c5 10 80       	push   $0x8010c581
80108a6e:	e8 81 79 ff ff       	call   801003f4 <cprintf>
80108a73:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108a76:	83 ec 0c             	sub    $0xc,%esp
80108a79:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a7c:	50                   	push   %eax
80108a7d:	68 f0 00 00 00       	push   $0xf0
80108a82:	ff 75 10             	push   0x10(%ebp)
80108a85:	ff 75 0c             	push   0xc(%ebp)
80108a88:	ff 75 08             	push   0x8(%ebp)
80108a8b:	e8 d7 fd ff ff       	call   80108867 <pci_access_config>
80108a90:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108a93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a96:	83 ec 08             	sub    $0x8,%esp
80108a99:	50                   	push   %eax
80108a9a:	68 9b c5 10 80       	push   $0x8010c59b
80108a9f:	e8 50 79 ff ff       	call   801003f4 <cprintf>
80108aa4:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108aa7:	83 ec 0c             	sub    $0xc,%esp
80108aaa:	68 74 77 19 80       	push   $0x80197774
80108aaf:	e8 09 00 00 00       	call   80108abd <i8254_init>
80108ab4:	83 c4 10             	add    $0x10,%esp
  }
}
80108ab7:	90                   	nop
80108ab8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108abb:	c9                   	leave  
80108abc:	c3                   	ret    

80108abd <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108abd:	55                   	push   %ebp
80108abe:	89 e5                	mov    %esp,%ebp
80108ac0:	53                   	push   %ebx
80108ac1:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80108ac7:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108acb:	0f b6 c8             	movzbl %al,%ecx
80108ace:	8b 45 08             	mov    0x8(%ebp),%eax
80108ad1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108ad5:	0f b6 d0             	movzbl %al,%edx
80108ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80108adb:	0f b6 00             	movzbl (%eax),%eax
80108ade:	0f b6 c0             	movzbl %al,%eax
80108ae1:	83 ec 0c             	sub    $0xc,%esp
80108ae4:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108ae7:	53                   	push   %ebx
80108ae8:	6a 04                	push   $0x4
80108aea:	51                   	push   %ecx
80108aeb:	52                   	push   %edx
80108aec:	50                   	push   %eax
80108aed:	e8 75 fd ff ff       	call   80108867 <pci_access_config>
80108af2:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108af5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108af8:	83 c8 04             	or     $0x4,%eax
80108afb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108afe:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108b01:	8b 45 08             	mov    0x8(%ebp),%eax
80108b04:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108b08:	0f b6 c8             	movzbl %al,%ecx
80108b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80108b0e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108b12:	0f b6 d0             	movzbl %al,%edx
80108b15:	8b 45 08             	mov    0x8(%ebp),%eax
80108b18:	0f b6 00             	movzbl (%eax),%eax
80108b1b:	0f b6 c0             	movzbl %al,%eax
80108b1e:	83 ec 0c             	sub    $0xc,%esp
80108b21:	53                   	push   %ebx
80108b22:	6a 04                	push   $0x4
80108b24:	51                   	push   %ecx
80108b25:	52                   	push   %edx
80108b26:	50                   	push   %eax
80108b27:	e8 90 fd ff ff       	call   801088bc <pci_write_config_register>
80108b2c:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80108b32:	8b 40 10             	mov    0x10(%eax),%eax
80108b35:	05 00 00 00 40       	add    $0x40000000,%eax
80108b3a:	a3 8c 77 19 80       	mov    %eax,0x8019778c
  uint *ctrl = (uint *)base_addr;
80108b3f:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108b47:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b4c:	05 d8 00 00 00       	add    $0xd8,%eax
80108b51:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108b54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b57:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b60:	8b 00                	mov    (%eax),%eax
80108b62:	0d 00 00 00 04       	or     $0x4000000,%eax
80108b67:	89 c2                	mov    %eax,%edx
80108b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b6c:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108b6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b71:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b7a:	8b 00                	mov    (%eax),%eax
80108b7c:	83 c8 40             	or     $0x40,%eax
80108b7f:	89 c2                	mov    %eax,%edx
80108b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b84:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b89:	8b 10                	mov    (%eax),%edx
80108b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b8e:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108b90:	83 ec 0c             	sub    $0xc,%esp
80108b93:	68 b0 c5 10 80       	push   $0x8010c5b0
80108b98:	e8 57 78 ff ff       	call   801003f4 <cprintf>
80108b9d:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108ba0:	e8 fc 9b ff ff       	call   801027a1 <kalloc>
80108ba5:	a3 98 77 19 80       	mov    %eax,0x80197798
  *intr_addr = 0;
80108baa:	a1 98 77 19 80       	mov    0x80197798,%eax
80108baf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108bb5:	a1 98 77 19 80       	mov    0x80197798,%eax
80108bba:	83 ec 08             	sub    $0x8,%esp
80108bbd:	50                   	push   %eax
80108bbe:	68 d2 c5 10 80       	push   $0x8010c5d2
80108bc3:	e8 2c 78 ff ff       	call   801003f4 <cprintf>
80108bc8:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108bcb:	e8 50 00 00 00       	call   80108c20 <i8254_init_recv>
  i8254_init_send();
80108bd0:	e8 69 03 00 00       	call   80108f3e <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108bd5:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108bdc:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108bdf:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108be6:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108be9:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108bf0:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108bf3:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108bfa:	0f b6 c0             	movzbl %al,%eax
80108bfd:	83 ec 0c             	sub    $0xc,%esp
80108c00:	53                   	push   %ebx
80108c01:	51                   	push   %ecx
80108c02:	52                   	push   %edx
80108c03:	50                   	push   %eax
80108c04:	68 e0 c5 10 80       	push   $0x8010c5e0
80108c09:	e8 e6 77 ff ff       	call   801003f4 <cprintf>
80108c0e:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c14:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108c1a:	90                   	nop
80108c1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c1e:	c9                   	leave  
80108c1f:	c3                   	ret    

80108c20 <i8254_init_recv>:

void i8254_init_recv(){
80108c20:	55                   	push   %ebp
80108c21:	89 e5                	mov    %esp,%ebp
80108c23:	57                   	push   %edi
80108c24:	56                   	push   %esi
80108c25:	53                   	push   %ebx
80108c26:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108c29:	83 ec 0c             	sub    $0xc,%esp
80108c2c:	6a 00                	push   $0x0
80108c2e:	e8 e8 04 00 00       	call   8010911b <i8254_read_eeprom>
80108c33:	83 c4 10             	add    $0x10,%esp
80108c36:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108c39:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108c3c:	a2 90 77 19 80       	mov    %al,0x80197790
  mac_addr[1] = data_l>>8;
80108c41:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108c44:	c1 e8 08             	shr    $0x8,%eax
80108c47:	a2 91 77 19 80       	mov    %al,0x80197791
  uint data_m = i8254_read_eeprom(0x1);
80108c4c:	83 ec 0c             	sub    $0xc,%esp
80108c4f:	6a 01                	push   $0x1
80108c51:	e8 c5 04 00 00       	call   8010911b <i8254_read_eeprom>
80108c56:	83 c4 10             	add    $0x10,%esp
80108c59:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108c5c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c5f:	a2 92 77 19 80       	mov    %al,0x80197792
  mac_addr[3] = data_m>>8;
80108c64:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c67:	c1 e8 08             	shr    $0x8,%eax
80108c6a:	a2 93 77 19 80       	mov    %al,0x80197793
  uint data_h = i8254_read_eeprom(0x2);
80108c6f:	83 ec 0c             	sub    $0xc,%esp
80108c72:	6a 02                	push   $0x2
80108c74:	e8 a2 04 00 00       	call   8010911b <i8254_read_eeprom>
80108c79:	83 c4 10             	add    $0x10,%esp
80108c7c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108c7f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c82:	a2 94 77 19 80       	mov    %al,0x80197794
  mac_addr[5] = data_h>>8;
80108c87:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c8a:	c1 e8 08             	shr    $0x8,%eax
80108c8d:	a2 95 77 19 80       	mov    %al,0x80197795
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108c92:	0f b6 05 95 77 19 80 	movzbl 0x80197795,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c99:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108c9c:	0f b6 05 94 77 19 80 	movzbl 0x80197794,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ca3:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108ca6:	0f b6 05 93 77 19 80 	movzbl 0x80197793,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cad:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108cb0:	0f b6 05 92 77 19 80 	movzbl 0x80197792,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cb7:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108cba:	0f b6 05 91 77 19 80 	movzbl 0x80197791,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cc1:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108cc4:	0f b6 05 90 77 19 80 	movzbl 0x80197790,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ccb:	0f b6 c0             	movzbl %al,%eax
80108cce:	83 ec 04             	sub    $0x4,%esp
80108cd1:	57                   	push   %edi
80108cd2:	56                   	push   %esi
80108cd3:	53                   	push   %ebx
80108cd4:	51                   	push   %ecx
80108cd5:	52                   	push   %edx
80108cd6:	50                   	push   %eax
80108cd7:	68 f8 c5 10 80       	push   $0x8010c5f8
80108cdc:	e8 13 77 ff ff       	call   801003f4 <cprintf>
80108ce1:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108ce4:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108ce9:	05 00 54 00 00       	add    $0x5400,%eax
80108cee:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108cf1:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108cf6:	05 04 54 00 00       	add    $0x5404,%eax
80108cfb:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108cfe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d01:	c1 e0 10             	shl    $0x10,%eax
80108d04:	0b 45 d8             	or     -0x28(%ebp),%eax
80108d07:	89 c2                	mov    %eax,%edx
80108d09:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108d0c:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108d0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d11:	0d 00 00 00 80       	or     $0x80000000,%eax
80108d16:	89 c2                	mov    %eax,%edx
80108d18:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108d1b:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108d1d:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d22:	05 00 52 00 00       	add    $0x5200,%eax
80108d27:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108d2a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108d31:	eb 19                	jmp    80108d4c <i8254_init_recv+0x12c>
    mta[i] = 0;
80108d33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d3d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108d40:	01 d0                	add    %edx,%eax
80108d42:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108d48:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108d4c:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108d50:	7e e1                	jle    80108d33 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108d52:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d57:	05 d0 00 00 00       	add    $0xd0,%eax
80108d5c:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108d5f:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108d62:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108d68:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d6d:	05 c8 00 00 00       	add    $0xc8,%eax
80108d72:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108d75:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108d78:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108d7e:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d83:	05 28 28 00 00       	add    $0x2828,%eax
80108d88:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108d8b:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108d8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108d94:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d99:	05 00 01 00 00       	add    $0x100,%eax
80108d9e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108da1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108da4:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108daa:	e8 f2 99 ff ff       	call   801027a1 <kalloc>
80108daf:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108db2:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108db7:	05 00 28 00 00       	add    $0x2800,%eax
80108dbc:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108dbf:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108dc4:	05 04 28 00 00       	add    $0x2804,%eax
80108dc9:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108dcc:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108dd1:	05 08 28 00 00       	add    $0x2808,%eax
80108dd6:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108dd9:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108dde:	05 10 28 00 00       	add    $0x2810,%eax
80108de3:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108de6:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108deb:	05 18 28 00 00       	add    $0x2818,%eax
80108df0:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108df3:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108df6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108dfc:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108dff:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108e01:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108e04:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108e0a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108e0d:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108e13:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108e16:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108e1c:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108e1f:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108e25:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108e28:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108e2b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108e32:	eb 73                	jmp    80108ea7 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108e34:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e37:	c1 e0 04             	shl    $0x4,%eax
80108e3a:	89 c2                	mov    %eax,%edx
80108e3c:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e3f:	01 d0                	add    %edx,%eax
80108e41:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108e48:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e4b:	c1 e0 04             	shl    $0x4,%eax
80108e4e:	89 c2                	mov    %eax,%edx
80108e50:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e53:	01 d0                	add    %edx,%eax
80108e55:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108e5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e5e:	c1 e0 04             	shl    $0x4,%eax
80108e61:	89 c2                	mov    %eax,%edx
80108e63:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e66:	01 d0                	add    %edx,%eax
80108e68:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108e6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e71:	c1 e0 04             	shl    $0x4,%eax
80108e74:	89 c2                	mov    %eax,%edx
80108e76:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e79:	01 d0                	add    %edx,%eax
80108e7b:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108e7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e82:	c1 e0 04             	shl    $0x4,%eax
80108e85:	89 c2                	mov    %eax,%edx
80108e87:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e8a:	01 d0                	add    %edx,%eax
80108e8c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108e90:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e93:	c1 e0 04             	shl    $0x4,%eax
80108e96:	89 c2                	mov    %eax,%edx
80108e98:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e9b:	01 d0                	add    %edx,%eax
80108e9d:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108ea3:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108ea7:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108eae:	7e 84                	jle    80108e34 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108eb0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108eb7:	eb 57                	jmp    80108f10 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108eb9:	e8 e3 98 ff ff       	call   801027a1 <kalloc>
80108ebe:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108ec1:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108ec5:	75 12                	jne    80108ed9 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108ec7:	83 ec 0c             	sub    $0xc,%esp
80108eca:	68 18 c6 10 80       	push   $0x8010c618
80108ecf:	e8 20 75 ff ff       	call   801003f4 <cprintf>
80108ed4:	83 c4 10             	add    $0x10,%esp
      break;
80108ed7:	eb 3d                	jmp    80108f16 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108ed9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108edc:	c1 e0 04             	shl    $0x4,%eax
80108edf:	89 c2                	mov    %eax,%edx
80108ee1:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ee4:	01 d0                	add    %edx,%eax
80108ee6:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108ee9:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108eef:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108ef1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ef4:	83 c0 01             	add    $0x1,%eax
80108ef7:	c1 e0 04             	shl    $0x4,%eax
80108efa:	89 c2                	mov    %eax,%edx
80108efc:	8b 45 98             	mov    -0x68(%ebp),%eax
80108eff:	01 d0                	add    %edx,%eax
80108f01:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108f04:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108f0a:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108f0c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108f10:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108f14:	7e a3                	jle    80108eb9 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108f16:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108f19:	8b 00                	mov    (%eax),%eax
80108f1b:	83 c8 02             	or     $0x2,%eax
80108f1e:	89 c2                	mov    %eax,%edx
80108f20:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108f23:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108f25:	83 ec 0c             	sub    $0xc,%esp
80108f28:	68 38 c6 10 80       	push   $0x8010c638
80108f2d:	e8 c2 74 ff ff       	call   801003f4 <cprintf>
80108f32:	83 c4 10             	add    $0x10,%esp
}
80108f35:	90                   	nop
80108f36:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108f39:	5b                   	pop    %ebx
80108f3a:	5e                   	pop    %esi
80108f3b:	5f                   	pop    %edi
80108f3c:	5d                   	pop    %ebp
80108f3d:	c3                   	ret    

80108f3e <i8254_init_send>:

void i8254_init_send(){
80108f3e:	55                   	push   %ebp
80108f3f:	89 e5                	mov    %esp,%ebp
80108f41:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108f44:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108f49:	05 28 38 00 00       	add    $0x3828,%eax
80108f4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108f51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f54:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108f5a:	e8 42 98 ff ff       	call   801027a1 <kalloc>
80108f5f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108f62:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108f67:	05 00 38 00 00       	add    $0x3800,%eax
80108f6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108f6f:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108f74:	05 04 38 00 00       	add    $0x3804,%eax
80108f79:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108f7c:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108f81:	05 08 38 00 00       	add    $0x3808,%eax
80108f86:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108f89:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f8c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108f92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f95:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108f97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f9a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108fa0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108fa3:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108fa9:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108fae:	05 10 38 00 00       	add    $0x3810,%eax
80108fb3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108fb6:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108fbb:	05 18 38 00 00       	add    $0x3818,%eax
80108fc0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108fc3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108fc6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108fcc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108fcf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108fd5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fd8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108fdb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108fe2:	e9 82 00 00 00       	jmp    80109069 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fea:	c1 e0 04             	shl    $0x4,%eax
80108fed:	89 c2                	mov    %eax,%edx
80108fef:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ff2:	01 d0                	add    %edx,%eax
80108ff4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ffe:	c1 e0 04             	shl    $0x4,%eax
80109001:	89 c2                	mov    %eax,%edx
80109003:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109006:	01 d0                	add    %edx,%eax
80109008:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
8010900e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109011:	c1 e0 04             	shl    $0x4,%eax
80109014:	89 c2                	mov    %eax,%edx
80109016:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109019:	01 d0                	add    %edx,%eax
8010901b:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
8010901f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109022:	c1 e0 04             	shl    $0x4,%eax
80109025:	89 c2                	mov    %eax,%edx
80109027:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010902a:	01 d0                	add    %edx,%eax
8010902c:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80109030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109033:	c1 e0 04             	shl    $0x4,%eax
80109036:	89 c2                	mov    %eax,%edx
80109038:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010903b:	01 d0                	add    %edx,%eax
8010903d:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80109041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109044:	c1 e0 04             	shl    $0x4,%eax
80109047:	89 c2                	mov    %eax,%edx
80109049:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010904c:	01 d0                	add    %edx,%eax
8010904e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80109052:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109055:	c1 e0 04             	shl    $0x4,%eax
80109058:	89 c2                	mov    %eax,%edx
8010905a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010905d:	01 d0                	add    %edx,%eax
8010905f:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109065:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109069:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109070:	0f 8e 71 ff ff ff    	jle    80108fe7 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109076:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010907d:	eb 57                	jmp    801090d6 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
8010907f:	e8 1d 97 ff ff       	call   801027a1 <kalloc>
80109084:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109087:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
8010908b:	75 12                	jne    8010909f <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
8010908d:	83 ec 0c             	sub    $0xc,%esp
80109090:	68 18 c6 10 80       	push   $0x8010c618
80109095:	e8 5a 73 ff ff       	call   801003f4 <cprintf>
8010909a:	83 c4 10             	add    $0x10,%esp
      break;
8010909d:	eb 3d                	jmp    801090dc <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
8010909f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090a2:	c1 e0 04             	shl    $0x4,%eax
801090a5:	89 c2                	mov    %eax,%edx
801090a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090aa:	01 d0                	add    %edx,%eax
801090ac:	8b 55 cc             	mov    -0x34(%ebp),%edx
801090af:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801090b5:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801090b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090ba:	83 c0 01             	add    $0x1,%eax
801090bd:	c1 e0 04             	shl    $0x4,%eax
801090c0:	89 c2                	mov    %eax,%edx
801090c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090c5:	01 d0                	add    %edx,%eax
801090c7:	8b 55 cc             	mov    -0x34(%ebp),%edx
801090ca:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801090d0:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801090d2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801090d6:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801090da:	7e a3                	jle    8010907f <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
801090dc:	a1 8c 77 19 80       	mov    0x8019778c,%eax
801090e1:	05 00 04 00 00       	add    $0x400,%eax
801090e6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
801090e9:	8b 45 c8             	mov    -0x38(%ebp),%eax
801090ec:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
801090f2:	a1 8c 77 19 80       	mov    0x8019778c,%eax
801090f7:	05 10 04 00 00       	add    $0x410,%eax
801090fc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
801090ff:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109102:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109108:	83 ec 0c             	sub    $0xc,%esp
8010910b:	68 58 c6 10 80       	push   $0x8010c658
80109110:	e8 df 72 ff ff       	call   801003f4 <cprintf>
80109115:	83 c4 10             	add    $0x10,%esp

}
80109118:	90                   	nop
80109119:	c9                   	leave  
8010911a:	c3                   	ret    

8010911b <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
8010911b:	55                   	push   %ebp
8010911c:	89 e5                	mov    %esp,%ebp
8010911e:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80109121:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80109126:	83 c0 14             	add    $0x14,%eax
80109129:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
8010912c:	8b 45 08             	mov    0x8(%ebp),%eax
8010912f:	c1 e0 08             	shl    $0x8,%eax
80109132:	0f b7 c0             	movzwl %ax,%eax
80109135:	83 c8 01             	or     $0x1,%eax
80109138:	89 c2                	mov    %eax,%edx
8010913a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010913d:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
8010913f:	83 ec 0c             	sub    $0xc,%esp
80109142:	68 78 c6 10 80       	push   $0x8010c678
80109147:	e8 a8 72 ff ff       	call   801003f4 <cprintf>
8010914c:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
8010914f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109152:	8b 00                	mov    (%eax),%eax
80109154:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109157:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010915a:	83 e0 10             	and    $0x10,%eax
8010915d:	85 c0                	test   %eax,%eax
8010915f:	75 02                	jne    80109163 <i8254_read_eeprom+0x48>
  while(1){
80109161:	eb dc                	jmp    8010913f <i8254_read_eeprom+0x24>
      break;
80109163:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80109164:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109167:	8b 00                	mov    (%eax),%eax
80109169:	c1 e8 10             	shr    $0x10,%eax
}
8010916c:	c9                   	leave  
8010916d:	c3                   	ret    

8010916e <i8254_recv>:
void i8254_recv(){
8010916e:	55                   	push   %ebp
8010916f:	89 e5                	mov    %esp,%ebp
80109171:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80109174:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80109179:	05 10 28 00 00       	add    $0x2810,%eax
8010917e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109181:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80109186:	05 18 28 00 00       	add    $0x2818,%eax
8010918b:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
8010918e:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80109193:	05 00 28 00 00       	add    $0x2800,%eax
80109198:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
8010919b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010919e:	8b 00                	mov    (%eax),%eax
801091a0:	05 00 00 00 80       	add    $0x80000000,%eax
801091a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
801091a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ab:	8b 10                	mov    (%eax),%edx
801091ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091b0:	8b 08                	mov    (%eax),%ecx
801091b2:	89 d0                	mov    %edx,%eax
801091b4:	29 c8                	sub    %ecx,%eax
801091b6:	25 ff 00 00 00       	and    $0xff,%eax
801091bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
801091be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801091c2:	7e 37                	jle    801091fb <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
801091c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091c7:	8b 00                	mov    (%eax),%eax
801091c9:	c1 e0 04             	shl    $0x4,%eax
801091cc:	89 c2                	mov    %eax,%edx
801091ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091d1:	01 d0                	add    %edx,%eax
801091d3:	8b 00                	mov    (%eax),%eax
801091d5:	05 00 00 00 80       	add    $0x80000000,%eax
801091da:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
801091dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091e0:	8b 00                	mov    (%eax),%eax
801091e2:	83 c0 01             	add    $0x1,%eax
801091e5:	0f b6 d0             	movzbl %al,%edx
801091e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091eb:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
801091ed:	83 ec 0c             	sub    $0xc,%esp
801091f0:	ff 75 e0             	push   -0x20(%ebp)
801091f3:	e8 15 09 00 00       	call   80109b0d <eth_proc>
801091f8:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
801091fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091fe:	8b 10                	mov    (%eax),%edx
80109200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109203:	8b 00                	mov    (%eax),%eax
80109205:	39 c2                	cmp    %eax,%edx
80109207:	75 9f                	jne    801091a8 <i8254_recv+0x3a>
      (*rdt)--;
80109209:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010920c:	8b 00                	mov    (%eax),%eax
8010920e:	8d 50 ff             	lea    -0x1(%eax),%edx
80109211:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109214:	89 10                	mov    %edx,(%eax)
  while(1){
80109216:	eb 90                	jmp    801091a8 <i8254_recv+0x3a>

80109218 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80109218:	55                   	push   %ebp
80109219:	89 e5                	mov    %esp,%ebp
8010921b:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
8010921e:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80109223:	05 10 38 00 00       	add    $0x3810,%eax
80109228:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010922b:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80109230:	05 18 38 00 00       	add    $0x3818,%eax
80109235:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109238:	a1 8c 77 19 80       	mov    0x8019778c,%eax
8010923d:	05 00 38 00 00       	add    $0x3800,%eax
80109242:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109245:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109248:	8b 00                	mov    (%eax),%eax
8010924a:	05 00 00 00 80       	add    $0x80000000,%eax
8010924f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109252:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109255:	8b 10                	mov    (%eax),%edx
80109257:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010925a:	8b 08                	mov    (%eax),%ecx
8010925c:	89 d0                	mov    %edx,%eax
8010925e:	29 c8                	sub    %ecx,%eax
80109260:	0f b6 d0             	movzbl %al,%edx
80109263:	b8 00 01 00 00       	mov    $0x100,%eax
80109268:	29 d0                	sub    %edx,%eax
8010926a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
8010926d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109270:	8b 00                	mov    (%eax),%eax
80109272:	25 ff 00 00 00       	and    $0xff,%eax
80109277:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
8010927a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010927e:	0f 8e a8 00 00 00    	jle    8010932c <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109284:	8b 45 08             	mov    0x8(%ebp),%eax
80109287:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010928a:	89 d1                	mov    %edx,%ecx
8010928c:	c1 e1 04             	shl    $0x4,%ecx
8010928f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109292:	01 ca                	add    %ecx,%edx
80109294:	8b 12                	mov    (%edx),%edx
80109296:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010929c:	83 ec 04             	sub    $0x4,%esp
8010929f:	ff 75 0c             	push   0xc(%ebp)
801092a2:	50                   	push   %eax
801092a3:	52                   	push   %edx
801092a4:	e8 b2 bb ff ff       	call   80104e5b <memmove>
801092a9:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801092ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092af:	c1 e0 04             	shl    $0x4,%eax
801092b2:	89 c2                	mov    %eax,%edx
801092b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092b7:	01 d0                	add    %edx,%eax
801092b9:	8b 55 0c             	mov    0xc(%ebp),%edx
801092bc:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
801092c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092c3:	c1 e0 04             	shl    $0x4,%eax
801092c6:	89 c2                	mov    %eax,%edx
801092c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092cb:	01 d0                	add    %edx,%eax
801092cd:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
801092d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092d4:	c1 e0 04             	shl    $0x4,%eax
801092d7:	89 c2                	mov    %eax,%edx
801092d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092dc:	01 d0                	add    %edx,%eax
801092de:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801092e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092e5:	c1 e0 04             	shl    $0x4,%eax
801092e8:	89 c2                	mov    %eax,%edx
801092ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092ed:	01 d0                	add    %edx,%eax
801092ef:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801092f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092f6:	c1 e0 04             	shl    $0x4,%eax
801092f9:	89 c2                	mov    %eax,%edx
801092fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092fe:	01 d0                	add    %edx,%eax
80109300:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109306:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109309:	c1 e0 04             	shl    $0x4,%eax
8010930c:	89 c2                	mov    %eax,%edx
8010930e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109311:	01 d0                	add    %edx,%eax
80109313:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109317:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010931a:	8b 00                	mov    (%eax),%eax
8010931c:	83 c0 01             	add    $0x1,%eax
8010931f:	0f b6 d0             	movzbl %al,%edx
80109322:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109325:	89 10                	mov    %edx,(%eax)
    return len;
80109327:	8b 45 0c             	mov    0xc(%ebp),%eax
8010932a:	eb 05                	jmp    80109331 <i8254_send+0x119>
  }else{
    return -1;
8010932c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109331:	c9                   	leave  
80109332:	c3                   	ret    

80109333 <i8254_intr>:

void i8254_intr(){
80109333:	55                   	push   %ebp
80109334:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109336:	a1 98 77 19 80       	mov    0x80197798,%eax
8010933b:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109341:	90                   	nop
80109342:	5d                   	pop    %ebp
80109343:	c3                   	ret    

80109344 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109344:	55                   	push   %ebp
80109345:	89 e5                	mov    %esp,%ebp
80109347:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
8010934a:	8b 45 08             	mov    0x8(%ebp),%eax
8010934d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109350:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109353:	0f b7 00             	movzwl (%eax),%eax
80109356:	66 3d 00 01          	cmp    $0x100,%ax
8010935a:	74 0a                	je     80109366 <arp_proc+0x22>
8010935c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109361:	e9 4f 01 00 00       	jmp    801094b5 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109369:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010936d:	66 83 f8 08          	cmp    $0x8,%ax
80109371:	74 0a                	je     8010937d <arp_proc+0x39>
80109373:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109378:	e9 38 01 00 00       	jmp    801094b5 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
8010937d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109380:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109384:	3c 06                	cmp    $0x6,%al
80109386:	74 0a                	je     80109392 <arp_proc+0x4e>
80109388:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010938d:	e9 23 01 00 00       	jmp    801094b5 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109392:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109395:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109399:	3c 04                	cmp    $0x4,%al
8010939b:	74 0a                	je     801093a7 <arp_proc+0x63>
8010939d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801093a2:	e9 0e 01 00 00       	jmp    801094b5 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801093a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093aa:	83 c0 18             	add    $0x18,%eax
801093ad:	83 ec 04             	sub    $0x4,%esp
801093b0:	6a 04                	push   $0x4
801093b2:	50                   	push   %eax
801093b3:	68 04 f5 10 80       	push   $0x8010f504
801093b8:	e8 46 ba ff ff       	call   80104e03 <memcmp>
801093bd:	83 c4 10             	add    $0x10,%esp
801093c0:	85 c0                	test   %eax,%eax
801093c2:	74 27                	je     801093eb <arp_proc+0xa7>
801093c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c7:	83 c0 0e             	add    $0xe,%eax
801093ca:	83 ec 04             	sub    $0x4,%esp
801093cd:	6a 04                	push   $0x4
801093cf:	50                   	push   %eax
801093d0:	68 04 f5 10 80       	push   $0x8010f504
801093d5:	e8 29 ba ff ff       	call   80104e03 <memcmp>
801093da:	83 c4 10             	add    $0x10,%esp
801093dd:	85 c0                	test   %eax,%eax
801093df:	74 0a                	je     801093eb <arp_proc+0xa7>
801093e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801093e6:	e9 ca 00 00 00       	jmp    801094b5 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801093eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ee:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801093f2:	66 3d 00 01          	cmp    $0x100,%ax
801093f6:	75 69                	jne    80109461 <arp_proc+0x11d>
801093f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093fb:	83 c0 18             	add    $0x18,%eax
801093fe:	83 ec 04             	sub    $0x4,%esp
80109401:	6a 04                	push   $0x4
80109403:	50                   	push   %eax
80109404:	68 04 f5 10 80       	push   $0x8010f504
80109409:	e8 f5 b9 ff ff       	call   80104e03 <memcmp>
8010940e:	83 c4 10             	add    $0x10,%esp
80109411:	85 c0                	test   %eax,%eax
80109413:	75 4c                	jne    80109461 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109415:	e8 87 93 ff ff       	call   801027a1 <kalloc>
8010941a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
8010941d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109424:	83 ec 04             	sub    $0x4,%esp
80109427:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010942a:	50                   	push   %eax
8010942b:	ff 75 f0             	push   -0x10(%ebp)
8010942e:	ff 75 f4             	push   -0xc(%ebp)
80109431:	e8 1f 04 00 00       	call   80109855 <arp_reply_pkt_create>
80109436:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109439:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010943c:	83 ec 08             	sub    $0x8,%esp
8010943f:	50                   	push   %eax
80109440:	ff 75 f0             	push   -0x10(%ebp)
80109443:	e8 d0 fd ff ff       	call   80109218 <i8254_send>
80109448:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
8010944b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010944e:	83 ec 0c             	sub    $0xc,%esp
80109451:	50                   	push   %eax
80109452:	e8 b0 92 ff ff       	call   80102707 <kfree>
80109457:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010945a:	b8 02 00 00 00       	mov    $0x2,%eax
8010945f:	eb 54                	jmp    801094b5 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109464:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109468:	66 3d 00 02          	cmp    $0x200,%ax
8010946c:	75 42                	jne    801094b0 <arp_proc+0x16c>
8010946e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109471:	83 c0 18             	add    $0x18,%eax
80109474:	83 ec 04             	sub    $0x4,%esp
80109477:	6a 04                	push   $0x4
80109479:	50                   	push   %eax
8010947a:	68 04 f5 10 80       	push   $0x8010f504
8010947f:	e8 7f b9 ff ff       	call   80104e03 <memcmp>
80109484:	83 c4 10             	add    $0x10,%esp
80109487:	85 c0                	test   %eax,%eax
80109489:	75 25                	jne    801094b0 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
8010948b:	83 ec 0c             	sub    $0xc,%esp
8010948e:	68 7c c6 10 80       	push   $0x8010c67c
80109493:	e8 5c 6f ff ff       	call   801003f4 <cprintf>
80109498:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010949b:	83 ec 0c             	sub    $0xc,%esp
8010949e:	ff 75 f4             	push   -0xc(%ebp)
801094a1:	e8 af 01 00 00       	call   80109655 <arp_table_update>
801094a6:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801094a9:	b8 01 00 00 00       	mov    $0x1,%eax
801094ae:	eb 05                	jmp    801094b5 <arp_proc+0x171>
  }else{
    return -1;
801094b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801094b5:	c9                   	leave  
801094b6:	c3                   	ret    

801094b7 <arp_scan>:

void arp_scan(){
801094b7:	55                   	push   %ebp
801094b8:	89 e5                	mov    %esp,%ebp
801094ba:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801094bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801094c4:	eb 6f                	jmp    80109535 <arp_scan+0x7e>
    uint send = (uint)kalloc();
801094c6:	e8 d6 92 ff ff       	call   801027a1 <kalloc>
801094cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801094ce:	83 ec 04             	sub    $0x4,%esp
801094d1:	ff 75 f4             	push   -0xc(%ebp)
801094d4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801094d7:	50                   	push   %eax
801094d8:	ff 75 ec             	push   -0x14(%ebp)
801094db:	e8 62 00 00 00       	call   80109542 <arp_broadcast>
801094e0:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801094e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094e6:	83 ec 08             	sub    $0x8,%esp
801094e9:	50                   	push   %eax
801094ea:	ff 75 ec             	push   -0x14(%ebp)
801094ed:	e8 26 fd ff ff       	call   80109218 <i8254_send>
801094f2:	83 c4 10             	add    $0x10,%esp
801094f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801094f8:	eb 22                	jmp    8010951c <arp_scan+0x65>
      microdelay(1);
801094fa:	83 ec 0c             	sub    $0xc,%esp
801094fd:	6a 01                	push   $0x1
801094ff:	e8 34 96 ff ff       	call   80102b38 <microdelay>
80109504:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109507:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010950a:	83 ec 08             	sub    $0x8,%esp
8010950d:	50                   	push   %eax
8010950e:	ff 75 ec             	push   -0x14(%ebp)
80109511:	e8 02 fd ff ff       	call   80109218 <i8254_send>
80109516:	83 c4 10             	add    $0x10,%esp
80109519:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010951c:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109520:	74 d8                	je     801094fa <arp_scan+0x43>
    }
    kfree((char *)send);
80109522:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109525:	83 ec 0c             	sub    $0xc,%esp
80109528:	50                   	push   %eax
80109529:	e8 d9 91 ff ff       	call   80102707 <kfree>
8010952e:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109531:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109535:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010953c:	7e 88                	jle    801094c6 <arp_scan+0xf>
  }
}
8010953e:	90                   	nop
8010953f:	90                   	nop
80109540:	c9                   	leave  
80109541:	c3                   	ret    

80109542 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109542:	55                   	push   %ebp
80109543:	89 e5                	mov    %esp,%ebp
80109545:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109548:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
8010954c:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109550:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109554:	8b 45 10             	mov    0x10(%ebp),%eax
80109557:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
8010955a:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109561:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109567:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010956e:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109574:	8b 45 0c             	mov    0xc(%ebp),%eax
80109577:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010957d:	8b 45 08             	mov    0x8(%ebp),%eax
80109580:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109583:	8b 45 08             	mov    0x8(%ebp),%eax
80109586:	83 c0 0e             	add    $0xe,%eax
80109589:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010958c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010958f:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109596:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
8010959a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010959d:	83 ec 04             	sub    $0x4,%esp
801095a0:	6a 06                	push   $0x6
801095a2:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801095a5:	52                   	push   %edx
801095a6:	50                   	push   %eax
801095a7:	e8 af b8 ff ff       	call   80104e5b <memmove>
801095ac:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801095af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095b2:	83 c0 06             	add    $0x6,%eax
801095b5:	83 ec 04             	sub    $0x4,%esp
801095b8:	6a 06                	push   $0x6
801095ba:	68 90 77 19 80       	push   $0x80197790
801095bf:	50                   	push   %eax
801095c0:	e8 96 b8 ff ff       	call   80104e5b <memmove>
801095c5:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801095c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095cb:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801095d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095d3:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801095d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095dc:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801095e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095e3:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801095e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095ea:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801095f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095f3:	8d 50 12             	lea    0x12(%eax),%edx
801095f6:	83 ec 04             	sub    $0x4,%esp
801095f9:	6a 06                	push   $0x6
801095fb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801095fe:	50                   	push   %eax
801095ff:	52                   	push   %edx
80109600:	e8 56 b8 ff ff       	call   80104e5b <memmove>
80109605:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109608:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010960b:	8d 50 18             	lea    0x18(%eax),%edx
8010960e:	83 ec 04             	sub    $0x4,%esp
80109611:	6a 04                	push   $0x4
80109613:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109616:	50                   	push   %eax
80109617:	52                   	push   %edx
80109618:	e8 3e b8 ff ff       	call   80104e5b <memmove>
8010961d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109620:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109623:	83 c0 08             	add    $0x8,%eax
80109626:	83 ec 04             	sub    $0x4,%esp
80109629:	6a 06                	push   $0x6
8010962b:	68 90 77 19 80       	push   $0x80197790
80109630:	50                   	push   %eax
80109631:	e8 25 b8 ff ff       	call   80104e5b <memmove>
80109636:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109639:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010963c:	83 c0 0e             	add    $0xe,%eax
8010963f:	83 ec 04             	sub    $0x4,%esp
80109642:	6a 04                	push   $0x4
80109644:	68 04 f5 10 80       	push   $0x8010f504
80109649:	50                   	push   %eax
8010964a:	e8 0c b8 ff ff       	call   80104e5b <memmove>
8010964f:	83 c4 10             	add    $0x10,%esp
}
80109652:	90                   	nop
80109653:	c9                   	leave  
80109654:	c3                   	ret    

80109655 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109655:	55                   	push   %ebp
80109656:	89 e5                	mov    %esp,%ebp
80109658:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
8010965b:	8b 45 08             	mov    0x8(%ebp),%eax
8010965e:	83 c0 0e             	add    $0xe,%eax
80109661:	83 ec 0c             	sub    $0xc,%esp
80109664:	50                   	push   %eax
80109665:	e8 bc 00 00 00       	call   80109726 <arp_table_search>
8010966a:	83 c4 10             	add    $0x10,%esp
8010966d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109674:	78 2d                	js     801096a3 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109676:	8b 45 08             	mov    0x8(%ebp),%eax
80109679:	8d 48 08             	lea    0x8(%eax),%ecx
8010967c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010967f:	89 d0                	mov    %edx,%eax
80109681:	c1 e0 02             	shl    $0x2,%eax
80109684:	01 d0                	add    %edx,%eax
80109686:	01 c0                	add    %eax,%eax
80109688:	01 d0                	add    %edx,%eax
8010968a:	05 a0 77 19 80       	add    $0x801977a0,%eax
8010968f:	83 c0 04             	add    $0x4,%eax
80109692:	83 ec 04             	sub    $0x4,%esp
80109695:	6a 06                	push   $0x6
80109697:	51                   	push   %ecx
80109698:	50                   	push   %eax
80109699:	e8 bd b7 ff ff       	call   80104e5b <memmove>
8010969e:	83 c4 10             	add    $0x10,%esp
801096a1:	eb 70                	jmp    80109713 <arp_table_update+0xbe>
  }else{
    index += 1;
801096a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801096a7:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801096aa:	8b 45 08             	mov    0x8(%ebp),%eax
801096ad:	8d 48 08             	lea    0x8(%eax),%ecx
801096b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801096b3:	89 d0                	mov    %edx,%eax
801096b5:	c1 e0 02             	shl    $0x2,%eax
801096b8:	01 d0                	add    %edx,%eax
801096ba:	01 c0                	add    %eax,%eax
801096bc:	01 d0                	add    %edx,%eax
801096be:	05 a0 77 19 80       	add    $0x801977a0,%eax
801096c3:	83 c0 04             	add    $0x4,%eax
801096c6:	83 ec 04             	sub    $0x4,%esp
801096c9:	6a 06                	push   $0x6
801096cb:	51                   	push   %ecx
801096cc:	50                   	push   %eax
801096cd:	e8 89 b7 ff ff       	call   80104e5b <memmove>
801096d2:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801096d5:	8b 45 08             	mov    0x8(%ebp),%eax
801096d8:	8d 48 0e             	lea    0xe(%eax),%ecx
801096db:	8b 55 f4             	mov    -0xc(%ebp),%edx
801096de:	89 d0                	mov    %edx,%eax
801096e0:	c1 e0 02             	shl    $0x2,%eax
801096e3:	01 d0                	add    %edx,%eax
801096e5:	01 c0                	add    %eax,%eax
801096e7:	01 d0                	add    %edx,%eax
801096e9:	05 a0 77 19 80       	add    $0x801977a0,%eax
801096ee:	83 ec 04             	sub    $0x4,%esp
801096f1:	6a 04                	push   $0x4
801096f3:	51                   	push   %ecx
801096f4:	50                   	push   %eax
801096f5:	e8 61 b7 ff ff       	call   80104e5b <memmove>
801096fa:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801096fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109700:	89 d0                	mov    %edx,%eax
80109702:	c1 e0 02             	shl    $0x2,%eax
80109705:	01 d0                	add    %edx,%eax
80109707:	01 c0                	add    %eax,%eax
80109709:	01 d0                	add    %edx,%eax
8010970b:	05 aa 77 19 80       	add    $0x801977aa,%eax
80109710:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109713:	83 ec 0c             	sub    $0xc,%esp
80109716:	68 a0 77 19 80       	push   $0x801977a0
8010971b:	e8 83 00 00 00       	call   801097a3 <print_arp_table>
80109720:	83 c4 10             	add    $0x10,%esp
}
80109723:	90                   	nop
80109724:	c9                   	leave  
80109725:	c3                   	ret    

80109726 <arp_table_search>:

int arp_table_search(uchar *ip){
80109726:	55                   	push   %ebp
80109727:	89 e5                	mov    %esp,%ebp
80109729:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
8010972c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109733:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010973a:	eb 59                	jmp    80109795 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
8010973c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010973f:	89 d0                	mov    %edx,%eax
80109741:	c1 e0 02             	shl    $0x2,%eax
80109744:	01 d0                	add    %edx,%eax
80109746:	01 c0                	add    %eax,%eax
80109748:	01 d0                	add    %edx,%eax
8010974a:	05 a0 77 19 80       	add    $0x801977a0,%eax
8010974f:	83 ec 04             	sub    $0x4,%esp
80109752:	6a 04                	push   $0x4
80109754:	ff 75 08             	push   0x8(%ebp)
80109757:	50                   	push   %eax
80109758:	e8 a6 b6 ff ff       	call   80104e03 <memcmp>
8010975d:	83 c4 10             	add    $0x10,%esp
80109760:	85 c0                	test   %eax,%eax
80109762:	75 05                	jne    80109769 <arp_table_search+0x43>
      return i;
80109764:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109767:	eb 38                	jmp    801097a1 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109769:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010976c:	89 d0                	mov    %edx,%eax
8010976e:	c1 e0 02             	shl    $0x2,%eax
80109771:	01 d0                	add    %edx,%eax
80109773:	01 c0                	add    %eax,%eax
80109775:	01 d0                	add    %edx,%eax
80109777:	05 aa 77 19 80       	add    $0x801977aa,%eax
8010977c:	0f b6 00             	movzbl (%eax),%eax
8010977f:	84 c0                	test   %al,%al
80109781:	75 0e                	jne    80109791 <arp_table_search+0x6b>
80109783:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109787:	75 08                	jne    80109791 <arp_table_search+0x6b>
      empty = -i;
80109789:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010978c:	f7 d8                	neg    %eax
8010978e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109791:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109795:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109799:	7e a1                	jle    8010973c <arp_table_search+0x16>
    }
  }
  return empty-1;
8010979b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010979e:	83 e8 01             	sub    $0x1,%eax
}
801097a1:	c9                   	leave  
801097a2:	c3                   	ret    

801097a3 <print_arp_table>:

void print_arp_table(){
801097a3:	55                   	push   %ebp
801097a4:	89 e5                	mov    %esp,%ebp
801097a6:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801097a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801097b0:	e9 92 00 00 00       	jmp    80109847 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
801097b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097b8:	89 d0                	mov    %edx,%eax
801097ba:	c1 e0 02             	shl    $0x2,%eax
801097bd:	01 d0                	add    %edx,%eax
801097bf:	01 c0                	add    %eax,%eax
801097c1:	01 d0                	add    %edx,%eax
801097c3:	05 aa 77 19 80       	add    $0x801977aa,%eax
801097c8:	0f b6 00             	movzbl (%eax),%eax
801097cb:	84 c0                	test   %al,%al
801097cd:	74 74                	je     80109843 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
801097cf:	83 ec 08             	sub    $0x8,%esp
801097d2:	ff 75 f4             	push   -0xc(%ebp)
801097d5:	68 8f c6 10 80       	push   $0x8010c68f
801097da:	e8 15 6c ff ff       	call   801003f4 <cprintf>
801097df:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801097e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097e5:	89 d0                	mov    %edx,%eax
801097e7:	c1 e0 02             	shl    $0x2,%eax
801097ea:	01 d0                	add    %edx,%eax
801097ec:	01 c0                	add    %eax,%eax
801097ee:	01 d0                	add    %edx,%eax
801097f0:	05 a0 77 19 80       	add    $0x801977a0,%eax
801097f5:	83 ec 0c             	sub    $0xc,%esp
801097f8:	50                   	push   %eax
801097f9:	e8 54 02 00 00       	call   80109a52 <print_ipv4>
801097fe:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109801:	83 ec 0c             	sub    $0xc,%esp
80109804:	68 9e c6 10 80       	push   $0x8010c69e
80109809:	e8 e6 6b ff ff       	call   801003f4 <cprintf>
8010980e:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109811:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109814:	89 d0                	mov    %edx,%eax
80109816:	c1 e0 02             	shl    $0x2,%eax
80109819:	01 d0                	add    %edx,%eax
8010981b:	01 c0                	add    %eax,%eax
8010981d:	01 d0                	add    %edx,%eax
8010981f:	05 a0 77 19 80       	add    $0x801977a0,%eax
80109824:	83 c0 04             	add    $0x4,%eax
80109827:	83 ec 0c             	sub    $0xc,%esp
8010982a:	50                   	push   %eax
8010982b:	e8 70 02 00 00       	call   80109aa0 <print_mac>
80109830:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109833:	83 ec 0c             	sub    $0xc,%esp
80109836:	68 a0 c6 10 80       	push   $0x8010c6a0
8010983b:	e8 b4 6b ff ff       	call   801003f4 <cprintf>
80109840:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109843:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109847:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010984b:	0f 8e 64 ff ff ff    	jle    801097b5 <print_arp_table+0x12>
    }
  }
}
80109851:	90                   	nop
80109852:	90                   	nop
80109853:	c9                   	leave  
80109854:	c3                   	ret    

80109855 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109855:	55                   	push   %ebp
80109856:	89 e5                	mov    %esp,%ebp
80109858:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010985b:	8b 45 10             	mov    0x10(%ebp),%eax
8010985e:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109864:	8b 45 0c             	mov    0xc(%ebp),%eax
80109867:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010986a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010986d:	83 c0 0e             	add    $0xe,%eax
80109870:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109876:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010987a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010987d:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109881:	8b 45 08             	mov    0x8(%ebp),%eax
80109884:	8d 50 08             	lea    0x8(%eax),%edx
80109887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010988a:	83 ec 04             	sub    $0x4,%esp
8010988d:	6a 06                	push   $0x6
8010988f:	52                   	push   %edx
80109890:	50                   	push   %eax
80109891:	e8 c5 b5 ff ff       	call   80104e5b <memmove>
80109896:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010989c:	83 c0 06             	add    $0x6,%eax
8010989f:	83 ec 04             	sub    $0x4,%esp
801098a2:	6a 06                	push   $0x6
801098a4:	68 90 77 19 80       	push   $0x80197790
801098a9:	50                   	push   %eax
801098aa:	e8 ac b5 ff ff       	call   80104e5b <memmove>
801098af:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801098b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098b5:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801098ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098bd:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801098c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098c6:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801098ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098cd:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801098d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098d4:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801098da:	8b 45 08             	mov    0x8(%ebp),%eax
801098dd:	8d 50 08             	lea    0x8(%eax),%edx
801098e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098e3:	83 c0 12             	add    $0x12,%eax
801098e6:	83 ec 04             	sub    $0x4,%esp
801098e9:	6a 06                	push   $0x6
801098eb:	52                   	push   %edx
801098ec:	50                   	push   %eax
801098ed:	e8 69 b5 ff ff       	call   80104e5b <memmove>
801098f2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801098f5:	8b 45 08             	mov    0x8(%ebp),%eax
801098f8:	8d 50 0e             	lea    0xe(%eax),%edx
801098fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098fe:	83 c0 18             	add    $0x18,%eax
80109901:	83 ec 04             	sub    $0x4,%esp
80109904:	6a 04                	push   $0x4
80109906:	52                   	push   %edx
80109907:	50                   	push   %eax
80109908:	e8 4e b5 ff ff       	call   80104e5b <memmove>
8010990d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109913:	83 c0 08             	add    $0x8,%eax
80109916:	83 ec 04             	sub    $0x4,%esp
80109919:	6a 06                	push   $0x6
8010991b:	68 90 77 19 80       	push   $0x80197790
80109920:	50                   	push   %eax
80109921:	e8 35 b5 ff ff       	call   80104e5b <memmove>
80109926:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109929:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010992c:	83 c0 0e             	add    $0xe,%eax
8010992f:	83 ec 04             	sub    $0x4,%esp
80109932:	6a 04                	push   $0x4
80109934:	68 04 f5 10 80       	push   $0x8010f504
80109939:	50                   	push   %eax
8010993a:	e8 1c b5 ff ff       	call   80104e5b <memmove>
8010993f:	83 c4 10             	add    $0x10,%esp
}
80109942:	90                   	nop
80109943:	c9                   	leave  
80109944:	c3                   	ret    

80109945 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109945:	55                   	push   %ebp
80109946:	89 e5                	mov    %esp,%ebp
80109948:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
8010994b:	83 ec 0c             	sub    $0xc,%esp
8010994e:	68 a2 c6 10 80       	push   $0x8010c6a2
80109953:	e8 9c 6a ff ff       	call   801003f4 <cprintf>
80109958:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
8010995b:	8b 45 08             	mov    0x8(%ebp),%eax
8010995e:	83 c0 0e             	add    $0xe,%eax
80109961:	83 ec 0c             	sub    $0xc,%esp
80109964:	50                   	push   %eax
80109965:	e8 e8 00 00 00       	call   80109a52 <print_ipv4>
8010996a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010996d:	83 ec 0c             	sub    $0xc,%esp
80109970:	68 a0 c6 10 80       	push   $0x8010c6a0
80109975:	e8 7a 6a ff ff       	call   801003f4 <cprintf>
8010997a:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010997d:	8b 45 08             	mov    0x8(%ebp),%eax
80109980:	83 c0 08             	add    $0x8,%eax
80109983:	83 ec 0c             	sub    $0xc,%esp
80109986:	50                   	push   %eax
80109987:	e8 14 01 00 00       	call   80109aa0 <print_mac>
8010998c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010998f:	83 ec 0c             	sub    $0xc,%esp
80109992:	68 a0 c6 10 80       	push   $0x8010c6a0
80109997:	e8 58 6a ff ff       	call   801003f4 <cprintf>
8010999c:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010999f:	83 ec 0c             	sub    $0xc,%esp
801099a2:	68 b9 c6 10 80       	push   $0x8010c6b9
801099a7:	e8 48 6a ff ff       	call   801003f4 <cprintf>
801099ac:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801099af:	8b 45 08             	mov    0x8(%ebp),%eax
801099b2:	83 c0 18             	add    $0x18,%eax
801099b5:	83 ec 0c             	sub    $0xc,%esp
801099b8:	50                   	push   %eax
801099b9:	e8 94 00 00 00       	call   80109a52 <print_ipv4>
801099be:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801099c1:	83 ec 0c             	sub    $0xc,%esp
801099c4:	68 a0 c6 10 80       	push   $0x8010c6a0
801099c9:	e8 26 6a ff ff       	call   801003f4 <cprintf>
801099ce:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
801099d1:	8b 45 08             	mov    0x8(%ebp),%eax
801099d4:	83 c0 12             	add    $0x12,%eax
801099d7:	83 ec 0c             	sub    $0xc,%esp
801099da:	50                   	push   %eax
801099db:	e8 c0 00 00 00       	call   80109aa0 <print_mac>
801099e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801099e3:	83 ec 0c             	sub    $0xc,%esp
801099e6:	68 a0 c6 10 80       	push   $0x8010c6a0
801099eb:	e8 04 6a ff ff       	call   801003f4 <cprintf>
801099f0:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
801099f3:	83 ec 0c             	sub    $0xc,%esp
801099f6:	68 d0 c6 10 80       	push   $0x8010c6d0
801099fb:	e8 f4 69 ff ff       	call   801003f4 <cprintf>
80109a00:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109a03:	8b 45 08             	mov    0x8(%ebp),%eax
80109a06:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109a0a:	66 3d 00 01          	cmp    $0x100,%ax
80109a0e:	75 12                	jne    80109a22 <print_arp_info+0xdd>
80109a10:	83 ec 0c             	sub    $0xc,%esp
80109a13:	68 dc c6 10 80       	push   $0x8010c6dc
80109a18:	e8 d7 69 ff ff       	call   801003f4 <cprintf>
80109a1d:	83 c4 10             	add    $0x10,%esp
80109a20:	eb 1d                	jmp    80109a3f <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109a22:	8b 45 08             	mov    0x8(%ebp),%eax
80109a25:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109a29:	66 3d 00 02          	cmp    $0x200,%ax
80109a2d:	75 10                	jne    80109a3f <print_arp_info+0xfa>
    cprintf("Reply\n");
80109a2f:	83 ec 0c             	sub    $0xc,%esp
80109a32:	68 e5 c6 10 80       	push   $0x8010c6e5
80109a37:	e8 b8 69 ff ff       	call   801003f4 <cprintf>
80109a3c:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109a3f:	83 ec 0c             	sub    $0xc,%esp
80109a42:	68 a0 c6 10 80       	push   $0x8010c6a0
80109a47:	e8 a8 69 ff ff       	call   801003f4 <cprintf>
80109a4c:	83 c4 10             	add    $0x10,%esp
}
80109a4f:	90                   	nop
80109a50:	c9                   	leave  
80109a51:	c3                   	ret    

80109a52 <print_ipv4>:

void print_ipv4(uchar *ip){
80109a52:	55                   	push   %ebp
80109a53:	89 e5                	mov    %esp,%ebp
80109a55:	53                   	push   %ebx
80109a56:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109a59:	8b 45 08             	mov    0x8(%ebp),%eax
80109a5c:	83 c0 03             	add    $0x3,%eax
80109a5f:	0f b6 00             	movzbl (%eax),%eax
80109a62:	0f b6 d8             	movzbl %al,%ebx
80109a65:	8b 45 08             	mov    0x8(%ebp),%eax
80109a68:	83 c0 02             	add    $0x2,%eax
80109a6b:	0f b6 00             	movzbl (%eax),%eax
80109a6e:	0f b6 c8             	movzbl %al,%ecx
80109a71:	8b 45 08             	mov    0x8(%ebp),%eax
80109a74:	83 c0 01             	add    $0x1,%eax
80109a77:	0f b6 00             	movzbl (%eax),%eax
80109a7a:	0f b6 d0             	movzbl %al,%edx
80109a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a80:	0f b6 00             	movzbl (%eax),%eax
80109a83:	0f b6 c0             	movzbl %al,%eax
80109a86:	83 ec 0c             	sub    $0xc,%esp
80109a89:	53                   	push   %ebx
80109a8a:	51                   	push   %ecx
80109a8b:	52                   	push   %edx
80109a8c:	50                   	push   %eax
80109a8d:	68 ec c6 10 80       	push   $0x8010c6ec
80109a92:	e8 5d 69 ff ff       	call   801003f4 <cprintf>
80109a97:	83 c4 20             	add    $0x20,%esp
}
80109a9a:	90                   	nop
80109a9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109a9e:	c9                   	leave  
80109a9f:	c3                   	ret    

80109aa0 <print_mac>:

void print_mac(uchar *mac){
80109aa0:	55                   	push   %ebp
80109aa1:	89 e5                	mov    %esp,%ebp
80109aa3:	57                   	push   %edi
80109aa4:	56                   	push   %esi
80109aa5:	53                   	push   %ebx
80109aa6:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80109aac:	83 c0 05             	add    $0x5,%eax
80109aaf:	0f b6 00             	movzbl (%eax),%eax
80109ab2:	0f b6 f8             	movzbl %al,%edi
80109ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ab8:	83 c0 04             	add    $0x4,%eax
80109abb:	0f b6 00             	movzbl (%eax),%eax
80109abe:	0f b6 f0             	movzbl %al,%esi
80109ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ac4:	83 c0 03             	add    $0x3,%eax
80109ac7:	0f b6 00             	movzbl (%eax),%eax
80109aca:	0f b6 d8             	movzbl %al,%ebx
80109acd:	8b 45 08             	mov    0x8(%ebp),%eax
80109ad0:	83 c0 02             	add    $0x2,%eax
80109ad3:	0f b6 00             	movzbl (%eax),%eax
80109ad6:	0f b6 c8             	movzbl %al,%ecx
80109ad9:	8b 45 08             	mov    0x8(%ebp),%eax
80109adc:	83 c0 01             	add    $0x1,%eax
80109adf:	0f b6 00             	movzbl (%eax),%eax
80109ae2:	0f b6 d0             	movzbl %al,%edx
80109ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ae8:	0f b6 00             	movzbl (%eax),%eax
80109aeb:	0f b6 c0             	movzbl %al,%eax
80109aee:	83 ec 04             	sub    $0x4,%esp
80109af1:	57                   	push   %edi
80109af2:	56                   	push   %esi
80109af3:	53                   	push   %ebx
80109af4:	51                   	push   %ecx
80109af5:	52                   	push   %edx
80109af6:	50                   	push   %eax
80109af7:	68 04 c7 10 80       	push   $0x8010c704
80109afc:	e8 f3 68 ff ff       	call   801003f4 <cprintf>
80109b01:	83 c4 20             	add    $0x20,%esp
}
80109b04:	90                   	nop
80109b05:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109b08:	5b                   	pop    %ebx
80109b09:	5e                   	pop    %esi
80109b0a:	5f                   	pop    %edi
80109b0b:	5d                   	pop    %ebp
80109b0c:	c3                   	ret    

80109b0d <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109b0d:	55                   	push   %ebp
80109b0e:	89 e5                	mov    %esp,%ebp
80109b10:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109b13:	8b 45 08             	mov    0x8(%ebp),%eax
80109b16:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109b19:	8b 45 08             	mov    0x8(%ebp),%eax
80109b1c:	83 c0 0e             	add    $0xe,%eax
80109b1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b25:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109b29:	3c 08                	cmp    $0x8,%al
80109b2b:	75 1b                	jne    80109b48 <eth_proc+0x3b>
80109b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b30:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b34:	3c 06                	cmp    $0x6,%al
80109b36:	75 10                	jne    80109b48 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109b38:	83 ec 0c             	sub    $0xc,%esp
80109b3b:	ff 75 f0             	push   -0x10(%ebp)
80109b3e:	e8 01 f8 ff ff       	call   80109344 <arp_proc>
80109b43:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109b46:	eb 24                	jmp    80109b6c <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b4b:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109b4f:	3c 08                	cmp    $0x8,%al
80109b51:	75 19                	jne    80109b6c <eth_proc+0x5f>
80109b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b56:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b5a:	84 c0                	test   %al,%al
80109b5c:	75 0e                	jne    80109b6c <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109b5e:	83 ec 0c             	sub    $0xc,%esp
80109b61:	ff 75 08             	push   0x8(%ebp)
80109b64:	e8 a3 00 00 00       	call   80109c0c <ipv4_proc>
80109b69:	83 c4 10             	add    $0x10,%esp
}
80109b6c:	90                   	nop
80109b6d:	c9                   	leave  
80109b6e:	c3                   	ret    

80109b6f <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109b6f:	55                   	push   %ebp
80109b70:	89 e5                	mov    %esp,%ebp
80109b72:	83 ec 04             	sub    $0x4,%esp
80109b75:	8b 45 08             	mov    0x8(%ebp),%eax
80109b78:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109b7c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b80:	c1 e0 08             	shl    $0x8,%eax
80109b83:	89 c2                	mov    %eax,%edx
80109b85:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b89:	66 c1 e8 08          	shr    $0x8,%ax
80109b8d:	01 d0                	add    %edx,%eax
}
80109b8f:	c9                   	leave  
80109b90:	c3                   	ret    

80109b91 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109b91:	55                   	push   %ebp
80109b92:	89 e5                	mov    %esp,%ebp
80109b94:	83 ec 04             	sub    $0x4,%esp
80109b97:	8b 45 08             	mov    0x8(%ebp),%eax
80109b9a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109b9e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109ba2:	c1 e0 08             	shl    $0x8,%eax
80109ba5:	89 c2                	mov    %eax,%edx
80109ba7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109bab:	66 c1 e8 08          	shr    $0x8,%ax
80109baf:	01 d0                	add    %edx,%eax
}
80109bb1:	c9                   	leave  
80109bb2:	c3                   	ret    

80109bb3 <H2N_uint>:

uint H2N_uint(uint value){
80109bb3:	55                   	push   %ebp
80109bb4:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80109bb9:	c1 e0 18             	shl    $0x18,%eax
80109bbc:	25 00 00 00 0f       	and    $0xf000000,%eax
80109bc1:	89 c2                	mov    %eax,%edx
80109bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80109bc6:	c1 e0 08             	shl    $0x8,%eax
80109bc9:	25 00 f0 00 00       	and    $0xf000,%eax
80109bce:	09 c2                	or     %eax,%edx
80109bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80109bd3:	c1 e8 08             	shr    $0x8,%eax
80109bd6:	83 e0 0f             	and    $0xf,%eax
80109bd9:	01 d0                	add    %edx,%eax
}
80109bdb:	5d                   	pop    %ebp
80109bdc:	c3                   	ret    

80109bdd <N2H_uint>:

uint N2H_uint(uint value){
80109bdd:	55                   	push   %ebp
80109bde:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109be0:	8b 45 08             	mov    0x8(%ebp),%eax
80109be3:	c1 e0 18             	shl    $0x18,%eax
80109be6:	89 c2                	mov    %eax,%edx
80109be8:	8b 45 08             	mov    0x8(%ebp),%eax
80109beb:	c1 e0 08             	shl    $0x8,%eax
80109bee:	25 00 00 ff 00       	and    $0xff0000,%eax
80109bf3:	01 c2                	add    %eax,%edx
80109bf5:	8b 45 08             	mov    0x8(%ebp),%eax
80109bf8:	c1 e8 08             	shr    $0x8,%eax
80109bfb:	25 00 ff 00 00       	and    $0xff00,%eax
80109c00:	01 c2                	add    %eax,%edx
80109c02:	8b 45 08             	mov    0x8(%ebp),%eax
80109c05:	c1 e8 18             	shr    $0x18,%eax
80109c08:	01 d0                	add    %edx,%eax
}
80109c0a:	5d                   	pop    %ebp
80109c0b:	c3                   	ret    

80109c0c <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109c0c:	55                   	push   %ebp
80109c0d:	89 e5                	mov    %esp,%ebp
80109c0f:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109c12:	8b 45 08             	mov    0x8(%ebp),%eax
80109c15:	83 c0 0e             	add    $0xe,%eax
80109c18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c1e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c22:	0f b7 d0             	movzwl %ax,%edx
80109c25:	a1 08 f5 10 80       	mov    0x8010f508,%eax
80109c2a:	39 c2                	cmp    %eax,%edx
80109c2c:	74 60                	je     80109c8e <ipv4_proc+0x82>
80109c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c31:	83 c0 0c             	add    $0xc,%eax
80109c34:	83 ec 04             	sub    $0x4,%esp
80109c37:	6a 04                	push   $0x4
80109c39:	50                   	push   %eax
80109c3a:	68 04 f5 10 80       	push   $0x8010f504
80109c3f:	e8 bf b1 ff ff       	call   80104e03 <memcmp>
80109c44:	83 c4 10             	add    $0x10,%esp
80109c47:	85 c0                	test   %eax,%eax
80109c49:	74 43                	je     80109c8e <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c4e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c52:	0f b7 c0             	movzwl %ax,%eax
80109c55:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c5d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109c61:	3c 01                	cmp    $0x1,%al
80109c63:	75 10                	jne    80109c75 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109c65:	83 ec 0c             	sub    $0xc,%esp
80109c68:	ff 75 08             	push   0x8(%ebp)
80109c6b:	e8 a3 00 00 00       	call   80109d13 <icmp_proc>
80109c70:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109c73:	eb 19                	jmp    80109c8e <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c78:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109c7c:	3c 06                	cmp    $0x6,%al
80109c7e:	75 0e                	jne    80109c8e <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109c80:	83 ec 0c             	sub    $0xc,%esp
80109c83:	ff 75 08             	push   0x8(%ebp)
80109c86:	e8 b3 03 00 00       	call   8010a03e <tcp_proc>
80109c8b:	83 c4 10             	add    $0x10,%esp
}
80109c8e:	90                   	nop
80109c8f:	c9                   	leave  
80109c90:	c3                   	ret    

80109c91 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109c91:	55                   	push   %ebp
80109c92:	89 e5                	mov    %esp,%ebp
80109c94:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109c97:	8b 45 08             	mov    0x8(%ebp),%eax
80109c9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ca0:	0f b6 00             	movzbl (%eax),%eax
80109ca3:	83 e0 0f             	and    $0xf,%eax
80109ca6:	01 c0                	add    %eax,%eax
80109ca8:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109cab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109cb2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109cb9:	eb 48                	jmp    80109d03 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109cbb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109cbe:	01 c0                	add    %eax,%eax
80109cc0:	89 c2                	mov    %eax,%edx
80109cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cc5:	01 d0                	add    %edx,%eax
80109cc7:	0f b6 00             	movzbl (%eax),%eax
80109cca:	0f b6 c0             	movzbl %al,%eax
80109ccd:	c1 e0 08             	shl    $0x8,%eax
80109cd0:	89 c2                	mov    %eax,%edx
80109cd2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109cd5:	01 c0                	add    %eax,%eax
80109cd7:	8d 48 01             	lea    0x1(%eax),%ecx
80109cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cdd:	01 c8                	add    %ecx,%eax
80109cdf:	0f b6 00             	movzbl (%eax),%eax
80109ce2:	0f b6 c0             	movzbl %al,%eax
80109ce5:	01 d0                	add    %edx,%eax
80109ce7:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109cea:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109cf1:	76 0c                	jbe    80109cff <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109cf3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109cf6:	0f b7 c0             	movzwl %ax,%eax
80109cf9:	83 c0 01             	add    $0x1,%eax
80109cfc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109cff:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109d03:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109d07:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109d0a:	7c af                	jl     80109cbb <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109d0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d0f:	f7 d0                	not    %eax
}
80109d11:	c9                   	leave  
80109d12:	c3                   	ret    

80109d13 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109d13:	55                   	push   %ebp
80109d14:	89 e5                	mov    %esp,%ebp
80109d16:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109d19:	8b 45 08             	mov    0x8(%ebp),%eax
80109d1c:	83 c0 0e             	add    $0xe,%eax
80109d1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d25:	0f b6 00             	movzbl (%eax),%eax
80109d28:	0f b6 c0             	movzbl %al,%eax
80109d2b:	83 e0 0f             	and    $0xf,%eax
80109d2e:	c1 e0 02             	shl    $0x2,%eax
80109d31:	89 c2                	mov    %eax,%edx
80109d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d36:	01 d0                	add    %edx,%eax
80109d38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d3e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109d42:	84 c0                	test   %al,%al
80109d44:	75 4f                	jne    80109d95 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109d46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d49:	0f b6 00             	movzbl (%eax),%eax
80109d4c:	3c 08                	cmp    $0x8,%al
80109d4e:	75 45                	jne    80109d95 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109d50:	e8 4c 8a ff ff       	call   801027a1 <kalloc>
80109d55:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109d58:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109d5f:	83 ec 04             	sub    $0x4,%esp
80109d62:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109d65:	50                   	push   %eax
80109d66:	ff 75 ec             	push   -0x14(%ebp)
80109d69:	ff 75 08             	push   0x8(%ebp)
80109d6c:	e8 78 00 00 00       	call   80109de9 <icmp_reply_pkt_create>
80109d71:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109d74:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d77:	83 ec 08             	sub    $0x8,%esp
80109d7a:	50                   	push   %eax
80109d7b:	ff 75 ec             	push   -0x14(%ebp)
80109d7e:	e8 95 f4 ff ff       	call   80109218 <i8254_send>
80109d83:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109d86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d89:	83 ec 0c             	sub    $0xc,%esp
80109d8c:	50                   	push   %eax
80109d8d:	e8 75 89 ff ff       	call   80102707 <kfree>
80109d92:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109d95:	90                   	nop
80109d96:	c9                   	leave  
80109d97:	c3                   	ret    

80109d98 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109d98:	55                   	push   %ebp
80109d99:	89 e5                	mov    %esp,%ebp
80109d9b:	53                   	push   %ebx
80109d9c:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80109da2:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109da6:	0f b7 c0             	movzwl %ax,%eax
80109da9:	83 ec 0c             	sub    $0xc,%esp
80109dac:	50                   	push   %eax
80109dad:	e8 bd fd ff ff       	call   80109b6f <N2H_ushort>
80109db2:	83 c4 10             	add    $0x10,%esp
80109db5:	0f b7 d8             	movzwl %ax,%ebx
80109db8:	8b 45 08             	mov    0x8(%ebp),%eax
80109dbb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109dbf:	0f b7 c0             	movzwl %ax,%eax
80109dc2:	83 ec 0c             	sub    $0xc,%esp
80109dc5:	50                   	push   %eax
80109dc6:	e8 a4 fd ff ff       	call   80109b6f <N2H_ushort>
80109dcb:	83 c4 10             	add    $0x10,%esp
80109dce:	0f b7 c0             	movzwl %ax,%eax
80109dd1:	83 ec 04             	sub    $0x4,%esp
80109dd4:	53                   	push   %ebx
80109dd5:	50                   	push   %eax
80109dd6:	68 23 c7 10 80       	push   $0x8010c723
80109ddb:	e8 14 66 ff ff       	call   801003f4 <cprintf>
80109de0:	83 c4 10             	add    $0x10,%esp
}
80109de3:	90                   	nop
80109de4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109de7:	c9                   	leave  
80109de8:	c3                   	ret    

80109de9 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109de9:	55                   	push   %ebp
80109dea:	89 e5                	mov    %esp,%ebp
80109dec:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109def:	8b 45 08             	mov    0x8(%ebp),%eax
80109df2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109df5:	8b 45 08             	mov    0x8(%ebp),%eax
80109df8:	83 c0 0e             	add    $0xe,%eax
80109dfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109dfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e01:	0f b6 00             	movzbl (%eax),%eax
80109e04:	0f b6 c0             	movzbl %al,%eax
80109e07:	83 e0 0f             	and    $0xf,%eax
80109e0a:	c1 e0 02             	shl    $0x2,%eax
80109e0d:	89 c2                	mov    %eax,%edx
80109e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e12:	01 d0                	add    %edx,%eax
80109e14:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109e17:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e20:	83 c0 0e             	add    $0xe,%eax
80109e23:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109e26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e29:	83 c0 14             	add    $0x14,%eax
80109e2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109e2f:	8b 45 10             	mov    0x10(%ebp),%eax
80109e32:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e3b:	8d 50 06             	lea    0x6(%eax),%edx
80109e3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e41:	83 ec 04             	sub    $0x4,%esp
80109e44:	6a 06                	push   $0x6
80109e46:	52                   	push   %edx
80109e47:	50                   	push   %eax
80109e48:	e8 0e b0 ff ff       	call   80104e5b <memmove>
80109e4d:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109e50:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e53:	83 c0 06             	add    $0x6,%eax
80109e56:	83 ec 04             	sub    $0x4,%esp
80109e59:	6a 06                	push   $0x6
80109e5b:	68 90 77 19 80       	push   $0x80197790
80109e60:	50                   	push   %eax
80109e61:	e8 f5 af ff ff       	call   80104e5b <memmove>
80109e66:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109e69:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e6c:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109e70:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e73:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109e77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e7a:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e80:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109e84:	83 ec 0c             	sub    $0xc,%esp
80109e87:	6a 54                	push   $0x54
80109e89:	e8 03 fd ff ff       	call   80109b91 <H2N_ushort>
80109e8e:	83 c4 10             	add    $0x10,%esp
80109e91:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e94:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109e98:	0f b7 15 60 7a 19 80 	movzwl 0x80197a60,%edx
80109e9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ea2:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109ea6:	0f b7 05 60 7a 19 80 	movzwl 0x80197a60,%eax
80109ead:	83 c0 01             	add    $0x1,%eax
80109eb0:	66 a3 60 7a 19 80    	mov    %ax,0x80197a60
  ipv4_send->fragment = H2N_ushort(0x4000);
80109eb6:	83 ec 0c             	sub    $0xc,%esp
80109eb9:	68 00 40 00 00       	push   $0x4000
80109ebe:	e8 ce fc ff ff       	call   80109b91 <H2N_ushort>
80109ec3:	83 c4 10             	add    $0x10,%esp
80109ec6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ec9:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109ecd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ed0:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109ed4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ed7:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109edb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ede:	83 c0 0c             	add    $0xc,%eax
80109ee1:	83 ec 04             	sub    $0x4,%esp
80109ee4:	6a 04                	push   $0x4
80109ee6:	68 04 f5 10 80       	push   $0x8010f504
80109eeb:	50                   	push   %eax
80109eec:	e8 6a af ff ff       	call   80104e5b <memmove>
80109ef1:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109ef4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ef7:	8d 50 0c             	lea    0xc(%eax),%edx
80109efa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109efd:	83 c0 10             	add    $0x10,%eax
80109f00:	83 ec 04             	sub    $0x4,%esp
80109f03:	6a 04                	push   $0x4
80109f05:	52                   	push   %edx
80109f06:	50                   	push   %eax
80109f07:	e8 4f af ff ff       	call   80104e5b <memmove>
80109f0c:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109f0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f12:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109f18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f1b:	83 ec 0c             	sub    $0xc,%esp
80109f1e:	50                   	push   %eax
80109f1f:	e8 6d fd ff ff       	call   80109c91 <ipv4_chksum>
80109f24:	83 c4 10             	add    $0x10,%esp
80109f27:	0f b7 c0             	movzwl %ax,%eax
80109f2a:	83 ec 0c             	sub    $0xc,%esp
80109f2d:	50                   	push   %eax
80109f2e:	e8 5e fc ff ff       	call   80109b91 <H2N_ushort>
80109f33:	83 c4 10             	add    $0x10,%esp
80109f36:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109f39:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109f3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f40:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109f43:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f46:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109f4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f4d:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109f51:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f54:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109f58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f5b:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109f5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f62:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109f66:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f69:	8d 50 08             	lea    0x8(%eax),%edx
80109f6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f6f:	83 c0 08             	add    $0x8,%eax
80109f72:	83 ec 04             	sub    $0x4,%esp
80109f75:	6a 08                	push   $0x8
80109f77:	52                   	push   %edx
80109f78:	50                   	push   %eax
80109f79:	e8 dd ae ff ff       	call   80104e5b <memmove>
80109f7e:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109f81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f84:	8d 50 10             	lea    0x10(%eax),%edx
80109f87:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f8a:	83 c0 10             	add    $0x10,%eax
80109f8d:	83 ec 04             	sub    $0x4,%esp
80109f90:	6a 30                	push   $0x30
80109f92:	52                   	push   %edx
80109f93:	50                   	push   %eax
80109f94:	e8 c2 ae ff ff       	call   80104e5b <memmove>
80109f99:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109f9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f9f:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109fa5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fa8:	83 ec 0c             	sub    $0xc,%esp
80109fab:	50                   	push   %eax
80109fac:	e8 1c 00 00 00       	call   80109fcd <icmp_chksum>
80109fb1:	83 c4 10             	add    $0x10,%esp
80109fb4:	0f b7 c0             	movzwl %ax,%eax
80109fb7:	83 ec 0c             	sub    $0xc,%esp
80109fba:	50                   	push   %eax
80109fbb:	e8 d1 fb ff ff       	call   80109b91 <H2N_ushort>
80109fc0:	83 c4 10             	add    $0x10,%esp
80109fc3:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109fc6:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109fca:	90                   	nop
80109fcb:	c9                   	leave  
80109fcc:	c3                   	ret    

80109fcd <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109fcd:	55                   	push   %ebp
80109fce:	89 e5                	mov    %esp,%ebp
80109fd0:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109fd3:	8b 45 08             	mov    0x8(%ebp),%eax
80109fd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109fd9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109fe0:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109fe7:	eb 48                	jmp    8010a031 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109fe9:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109fec:	01 c0                	add    %eax,%eax
80109fee:	89 c2                	mov    %eax,%edx
80109ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ff3:	01 d0                	add    %edx,%eax
80109ff5:	0f b6 00             	movzbl (%eax),%eax
80109ff8:	0f b6 c0             	movzbl %al,%eax
80109ffb:	c1 e0 08             	shl    $0x8,%eax
80109ffe:	89 c2                	mov    %eax,%edx
8010a000:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a003:	01 c0                	add    %eax,%eax
8010a005:	8d 48 01             	lea    0x1(%eax),%ecx
8010a008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a00b:	01 c8                	add    %ecx,%eax
8010a00d:	0f b6 00             	movzbl (%eax),%eax
8010a010:	0f b6 c0             	movzbl %al,%eax
8010a013:	01 d0                	add    %edx,%eax
8010a015:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a018:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a01f:	76 0c                	jbe    8010a02d <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a021:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a024:	0f b7 c0             	movzwl %ax,%eax
8010a027:	83 c0 01             	add    $0x1,%eax
8010a02a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a02d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a031:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a035:	7e b2                	jle    80109fe9 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
8010a037:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a03a:	f7 d0                	not    %eax
}
8010a03c:	c9                   	leave  
8010a03d:	c3                   	ret    

8010a03e <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a03e:	55                   	push   %ebp
8010a03f:	89 e5                	mov    %esp,%ebp
8010a041:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a044:	8b 45 08             	mov    0x8(%ebp),%eax
8010a047:	83 c0 0e             	add    $0xe,%eax
8010a04a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a04d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a050:	0f b6 00             	movzbl (%eax),%eax
8010a053:	0f b6 c0             	movzbl %al,%eax
8010a056:	83 e0 0f             	and    $0xf,%eax
8010a059:	c1 e0 02             	shl    $0x2,%eax
8010a05c:	89 c2                	mov    %eax,%edx
8010a05e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a061:	01 d0                	add    %edx,%eax
8010a063:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a066:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a069:	83 c0 14             	add    $0x14,%eax
8010a06c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a06f:	e8 2d 87 ff ff       	call   801027a1 <kalloc>
8010a074:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a077:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a07e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a081:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a085:	0f b6 c0             	movzbl %al,%eax
8010a088:	83 e0 02             	and    $0x2,%eax
8010a08b:	85 c0                	test   %eax,%eax
8010a08d:	74 3d                	je     8010a0cc <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a08f:	83 ec 0c             	sub    $0xc,%esp
8010a092:	6a 00                	push   $0x0
8010a094:	6a 12                	push   $0x12
8010a096:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a099:	50                   	push   %eax
8010a09a:	ff 75 e8             	push   -0x18(%ebp)
8010a09d:	ff 75 08             	push   0x8(%ebp)
8010a0a0:	e8 a2 01 00 00       	call   8010a247 <tcp_pkt_create>
8010a0a5:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a0a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0ab:	83 ec 08             	sub    $0x8,%esp
8010a0ae:	50                   	push   %eax
8010a0af:	ff 75 e8             	push   -0x18(%ebp)
8010a0b2:	e8 61 f1 ff ff       	call   80109218 <i8254_send>
8010a0b7:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a0ba:	a1 64 7a 19 80       	mov    0x80197a64,%eax
8010a0bf:	83 c0 01             	add    $0x1,%eax
8010a0c2:	a3 64 7a 19 80       	mov    %eax,0x80197a64
8010a0c7:	e9 69 01 00 00       	jmp    8010a235 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a0cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0cf:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a0d3:	3c 18                	cmp    $0x18,%al
8010a0d5:	0f 85 10 01 00 00    	jne    8010a1eb <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a0db:	83 ec 04             	sub    $0x4,%esp
8010a0de:	6a 03                	push   $0x3
8010a0e0:	68 3e c7 10 80       	push   $0x8010c73e
8010a0e5:	ff 75 ec             	push   -0x14(%ebp)
8010a0e8:	e8 16 ad ff ff       	call   80104e03 <memcmp>
8010a0ed:	83 c4 10             	add    $0x10,%esp
8010a0f0:	85 c0                	test   %eax,%eax
8010a0f2:	74 74                	je     8010a168 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a0f4:	83 ec 0c             	sub    $0xc,%esp
8010a0f7:	68 42 c7 10 80       	push   $0x8010c742
8010a0fc:	e8 f3 62 ff ff       	call   801003f4 <cprintf>
8010a101:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a104:	83 ec 0c             	sub    $0xc,%esp
8010a107:	6a 00                	push   $0x0
8010a109:	6a 10                	push   $0x10
8010a10b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a10e:	50                   	push   %eax
8010a10f:	ff 75 e8             	push   -0x18(%ebp)
8010a112:	ff 75 08             	push   0x8(%ebp)
8010a115:	e8 2d 01 00 00       	call   8010a247 <tcp_pkt_create>
8010a11a:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a11d:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a120:	83 ec 08             	sub    $0x8,%esp
8010a123:	50                   	push   %eax
8010a124:	ff 75 e8             	push   -0x18(%ebp)
8010a127:	e8 ec f0 ff ff       	call   80109218 <i8254_send>
8010a12c:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a12f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a132:	83 c0 36             	add    $0x36,%eax
8010a135:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a138:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a13b:	50                   	push   %eax
8010a13c:	ff 75 e0             	push   -0x20(%ebp)
8010a13f:	6a 00                	push   $0x0
8010a141:	6a 00                	push   $0x0
8010a143:	e8 5a 04 00 00       	call   8010a5a2 <http_proc>
8010a148:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a14b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a14e:	83 ec 0c             	sub    $0xc,%esp
8010a151:	50                   	push   %eax
8010a152:	6a 18                	push   $0x18
8010a154:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a157:	50                   	push   %eax
8010a158:	ff 75 e8             	push   -0x18(%ebp)
8010a15b:	ff 75 08             	push   0x8(%ebp)
8010a15e:	e8 e4 00 00 00       	call   8010a247 <tcp_pkt_create>
8010a163:	83 c4 20             	add    $0x20,%esp
8010a166:	eb 62                	jmp    8010a1ca <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a168:	83 ec 0c             	sub    $0xc,%esp
8010a16b:	6a 00                	push   $0x0
8010a16d:	6a 10                	push   $0x10
8010a16f:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a172:	50                   	push   %eax
8010a173:	ff 75 e8             	push   -0x18(%ebp)
8010a176:	ff 75 08             	push   0x8(%ebp)
8010a179:	e8 c9 00 00 00       	call   8010a247 <tcp_pkt_create>
8010a17e:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a181:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a184:	83 ec 08             	sub    $0x8,%esp
8010a187:	50                   	push   %eax
8010a188:	ff 75 e8             	push   -0x18(%ebp)
8010a18b:	e8 88 f0 ff ff       	call   80109218 <i8254_send>
8010a190:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a193:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a196:	83 c0 36             	add    $0x36,%eax
8010a199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a19c:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a19f:	50                   	push   %eax
8010a1a0:	ff 75 e4             	push   -0x1c(%ebp)
8010a1a3:	6a 00                	push   $0x0
8010a1a5:	6a 00                	push   $0x0
8010a1a7:	e8 f6 03 00 00       	call   8010a5a2 <http_proc>
8010a1ac:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a1af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a1b2:	83 ec 0c             	sub    $0xc,%esp
8010a1b5:	50                   	push   %eax
8010a1b6:	6a 18                	push   $0x18
8010a1b8:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a1bb:	50                   	push   %eax
8010a1bc:	ff 75 e8             	push   -0x18(%ebp)
8010a1bf:	ff 75 08             	push   0x8(%ebp)
8010a1c2:	e8 80 00 00 00       	call   8010a247 <tcp_pkt_create>
8010a1c7:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a1ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a1cd:	83 ec 08             	sub    $0x8,%esp
8010a1d0:	50                   	push   %eax
8010a1d1:	ff 75 e8             	push   -0x18(%ebp)
8010a1d4:	e8 3f f0 ff ff       	call   80109218 <i8254_send>
8010a1d9:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a1dc:	a1 64 7a 19 80       	mov    0x80197a64,%eax
8010a1e1:	83 c0 01             	add    $0x1,%eax
8010a1e4:	a3 64 7a 19 80       	mov    %eax,0x80197a64
8010a1e9:	eb 4a                	jmp    8010a235 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a1eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1ee:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a1f2:	3c 10                	cmp    $0x10,%al
8010a1f4:	75 3f                	jne    8010a235 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a1f6:	a1 68 7a 19 80       	mov    0x80197a68,%eax
8010a1fb:	83 f8 01             	cmp    $0x1,%eax
8010a1fe:	75 35                	jne    8010a235 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a200:	83 ec 0c             	sub    $0xc,%esp
8010a203:	6a 00                	push   $0x0
8010a205:	6a 01                	push   $0x1
8010a207:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a20a:	50                   	push   %eax
8010a20b:	ff 75 e8             	push   -0x18(%ebp)
8010a20e:	ff 75 08             	push   0x8(%ebp)
8010a211:	e8 31 00 00 00       	call   8010a247 <tcp_pkt_create>
8010a216:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a219:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a21c:	83 ec 08             	sub    $0x8,%esp
8010a21f:	50                   	push   %eax
8010a220:	ff 75 e8             	push   -0x18(%ebp)
8010a223:	e8 f0 ef ff ff       	call   80109218 <i8254_send>
8010a228:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a22b:	c7 05 68 7a 19 80 00 	movl   $0x0,0x80197a68
8010a232:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a235:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a238:	83 ec 0c             	sub    $0xc,%esp
8010a23b:	50                   	push   %eax
8010a23c:	e8 c6 84 ff ff       	call   80102707 <kfree>
8010a241:	83 c4 10             	add    $0x10,%esp
}
8010a244:	90                   	nop
8010a245:	c9                   	leave  
8010a246:	c3                   	ret    

8010a247 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a247:	55                   	push   %ebp
8010a248:	89 e5                	mov    %esp,%ebp
8010a24a:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a24d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a250:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a253:	8b 45 08             	mov    0x8(%ebp),%eax
8010a256:	83 c0 0e             	add    $0xe,%eax
8010a259:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a25c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a25f:	0f b6 00             	movzbl (%eax),%eax
8010a262:	0f b6 c0             	movzbl %al,%eax
8010a265:	83 e0 0f             	and    $0xf,%eax
8010a268:	c1 e0 02             	shl    $0x2,%eax
8010a26b:	89 c2                	mov    %eax,%edx
8010a26d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a270:	01 d0                	add    %edx,%eax
8010a272:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a275:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a278:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a27b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a27e:	83 c0 0e             	add    $0xe,%eax
8010a281:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a284:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a287:	83 c0 14             	add    $0x14,%eax
8010a28a:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a28d:	8b 45 18             	mov    0x18(%ebp),%eax
8010a290:	8d 50 36             	lea    0x36(%eax),%edx
8010a293:	8b 45 10             	mov    0x10(%ebp),%eax
8010a296:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a29b:	8d 50 06             	lea    0x6(%eax),%edx
8010a29e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2a1:	83 ec 04             	sub    $0x4,%esp
8010a2a4:	6a 06                	push   $0x6
8010a2a6:	52                   	push   %edx
8010a2a7:	50                   	push   %eax
8010a2a8:	e8 ae ab ff ff       	call   80104e5b <memmove>
8010a2ad:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a2b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2b3:	83 c0 06             	add    $0x6,%eax
8010a2b6:	83 ec 04             	sub    $0x4,%esp
8010a2b9:	6a 06                	push   $0x6
8010a2bb:	68 90 77 19 80       	push   $0x80197790
8010a2c0:	50                   	push   %eax
8010a2c1:	e8 95 ab ff ff       	call   80104e5b <memmove>
8010a2c6:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a2c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2cc:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a2d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2d3:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a2d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2da:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a2dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2e0:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a2e4:	8b 45 18             	mov    0x18(%ebp),%eax
8010a2e7:	83 c0 28             	add    $0x28,%eax
8010a2ea:	0f b7 c0             	movzwl %ax,%eax
8010a2ed:	83 ec 0c             	sub    $0xc,%esp
8010a2f0:	50                   	push   %eax
8010a2f1:	e8 9b f8 ff ff       	call   80109b91 <H2N_ushort>
8010a2f6:	83 c4 10             	add    $0x10,%esp
8010a2f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a2fc:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a300:	0f b7 15 60 7a 19 80 	movzwl 0x80197a60,%edx
8010a307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a30a:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a30e:	0f b7 05 60 7a 19 80 	movzwl 0x80197a60,%eax
8010a315:	83 c0 01             	add    $0x1,%eax
8010a318:	66 a3 60 7a 19 80    	mov    %ax,0x80197a60
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a31e:	83 ec 0c             	sub    $0xc,%esp
8010a321:	6a 00                	push   $0x0
8010a323:	e8 69 f8 ff ff       	call   80109b91 <H2N_ushort>
8010a328:	83 c4 10             	add    $0x10,%esp
8010a32b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a32e:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a332:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a335:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a339:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a33c:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a340:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a343:	83 c0 0c             	add    $0xc,%eax
8010a346:	83 ec 04             	sub    $0x4,%esp
8010a349:	6a 04                	push   $0x4
8010a34b:	68 04 f5 10 80       	push   $0x8010f504
8010a350:	50                   	push   %eax
8010a351:	e8 05 ab ff ff       	call   80104e5b <memmove>
8010a356:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a35c:	8d 50 0c             	lea    0xc(%eax),%edx
8010a35f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a362:	83 c0 10             	add    $0x10,%eax
8010a365:	83 ec 04             	sub    $0x4,%esp
8010a368:	6a 04                	push   $0x4
8010a36a:	52                   	push   %edx
8010a36b:	50                   	push   %eax
8010a36c:	e8 ea aa ff ff       	call   80104e5b <memmove>
8010a371:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a374:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a377:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a37d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a380:	83 ec 0c             	sub    $0xc,%esp
8010a383:	50                   	push   %eax
8010a384:	e8 08 f9 ff ff       	call   80109c91 <ipv4_chksum>
8010a389:	83 c4 10             	add    $0x10,%esp
8010a38c:	0f b7 c0             	movzwl %ax,%eax
8010a38f:	83 ec 0c             	sub    $0xc,%esp
8010a392:	50                   	push   %eax
8010a393:	e8 f9 f7 ff ff       	call   80109b91 <H2N_ushort>
8010a398:	83 c4 10             	add    $0x10,%esp
8010a39b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a39e:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a3a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3a5:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a3a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3ac:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a3af:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3b2:	0f b7 10             	movzwl (%eax),%edx
8010a3b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3b8:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a3bc:	a1 64 7a 19 80       	mov    0x80197a64,%eax
8010a3c1:	83 ec 0c             	sub    $0xc,%esp
8010a3c4:	50                   	push   %eax
8010a3c5:	e8 e9 f7 ff ff       	call   80109bb3 <H2N_uint>
8010a3ca:	83 c4 10             	add    $0x10,%esp
8010a3cd:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a3d0:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a3d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3d6:	8b 40 04             	mov    0x4(%eax),%eax
8010a3d9:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a3df:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3e2:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a3e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3e8:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a3ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3ef:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a3f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3f6:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a3fa:	8b 45 14             	mov    0x14(%ebp),%eax
8010a3fd:	89 c2                	mov    %eax,%edx
8010a3ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a402:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a405:	83 ec 0c             	sub    $0xc,%esp
8010a408:	68 90 38 00 00       	push   $0x3890
8010a40d:	e8 7f f7 ff ff       	call   80109b91 <H2N_ushort>
8010a412:	83 c4 10             	add    $0x10,%esp
8010a415:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a418:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a41c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a41f:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a425:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a428:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a42e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a431:	83 ec 0c             	sub    $0xc,%esp
8010a434:	50                   	push   %eax
8010a435:	e8 1f 00 00 00       	call   8010a459 <tcp_chksum>
8010a43a:	83 c4 10             	add    $0x10,%esp
8010a43d:	83 c0 08             	add    $0x8,%eax
8010a440:	0f b7 c0             	movzwl %ax,%eax
8010a443:	83 ec 0c             	sub    $0xc,%esp
8010a446:	50                   	push   %eax
8010a447:	e8 45 f7 ff ff       	call   80109b91 <H2N_ushort>
8010a44c:	83 c4 10             	add    $0x10,%esp
8010a44f:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a452:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a456:	90                   	nop
8010a457:	c9                   	leave  
8010a458:	c3                   	ret    

8010a459 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a459:	55                   	push   %ebp
8010a45a:	89 e5                	mov    %esp,%ebp
8010a45c:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a45f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a462:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a465:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a468:	83 c0 14             	add    $0x14,%eax
8010a46b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a46e:	83 ec 04             	sub    $0x4,%esp
8010a471:	6a 04                	push   $0x4
8010a473:	68 04 f5 10 80       	push   $0x8010f504
8010a478:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a47b:	50                   	push   %eax
8010a47c:	e8 da a9 ff ff       	call   80104e5b <memmove>
8010a481:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a484:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a487:	83 c0 0c             	add    $0xc,%eax
8010a48a:	83 ec 04             	sub    $0x4,%esp
8010a48d:	6a 04                	push   $0x4
8010a48f:	50                   	push   %eax
8010a490:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a493:	83 c0 04             	add    $0x4,%eax
8010a496:	50                   	push   %eax
8010a497:	e8 bf a9 ff ff       	call   80104e5b <memmove>
8010a49c:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a49f:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a4a3:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a4a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a4aa:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a4ae:	0f b7 c0             	movzwl %ax,%eax
8010a4b1:	83 ec 0c             	sub    $0xc,%esp
8010a4b4:	50                   	push   %eax
8010a4b5:	e8 b5 f6 ff ff       	call   80109b6f <N2H_ushort>
8010a4ba:	83 c4 10             	add    $0x10,%esp
8010a4bd:	83 e8 14             	sub    $0x14,%eax
8010a4c0:	0f b7 c0             	movzwl %ax,%eax
8010a4c3:	83 ec 0c             	sub    $0xc,%esp
8010a4c6:	50                   	push   %eax
8010a4c7:	e8 c5 f6 ff ff       	call   80109b91 <H2N_ushort>
8010a4cc:	83 c4 10             	add    $0x10,%esp
8010a4cf:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a4d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a4da:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a4dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a4e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a4e7:	eb 33                	jmp    8010a51c <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a4e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4ec:	01 c0                	add    %eax,%eax
8010a4ee:	89 c2                	mov    %eax,%edx
8010a4f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4f3:	01 d0                	add    %edx,%eax
8010a4f5:	0f b6 00             	movzbl (%eax),%eax
8010a4f8:	0f b6 c0             	movzbl %al,%eax
8010a4fb:	c1 e0 08             	shl    $0x8,%eax
8010a4fe:	89 c2                	mov    %eax,%edx
8010a500:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a503:	01 c0                	add    %eax,%eax
8010a505:	8d 48 01             	lea    0x1(%eax),%ecx
8010a508:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a50b:	01 c8                	add    %ecx,%eax
8010a50d:	0f b6 00             	movzbl (%eax),%eax
8010a510:	0f b6 c0             	movzbl %al,%eax
8010a513:	01 d0                	add    %edx,%eax
8010a515:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a518:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a51c:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a520:	7e c7                	jle    8010a4e9 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a522:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a525:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a528:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a52f:	eb 33                	jmp    8010a564 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a531:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a534:	01 c0                	add    %eax,%eax
8010a536:	89 c2                	mov    %eax,%edx
8010a538:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a53b:	01 d0                	add    %edx,%eax
8010a53d:	0f b6 00             	movzbl (%eax),%eax
8010a540:	0f b6 c0             	movzbl %al,%eax
8010a543:	c1 e0 08             	shl    $0x8,%eax
8010a546:	89 c2                	mov    %eax,%edx
8010a548:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a54b:	01 c0                	add    %eax,%eax
8010a54d:	8d 48 01             	lea    0x1(%eax),%ecx
8010a550:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a553:	01 c8                	add    %ecx,%eax
8010a555:	0f b6 00             	movzbl (%eax),%eax
8010a558:	0f b6 c0             	movzbl %al,%eax
8010a55b:	01 d0                	add    %edx,%eax
8010a55d:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a560:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a564:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a568:	0f b7 c0             	movzwl %ax,%eax
8010a56b:	83 ec 0c             	sub    $0xc,%esp
8010a56e:	50                   	push   %eax
8010a56f:	e8 fb f5 ff ff       	call   80109b6f <N2H_ushort>
8010a574:	83 c4 10             	add    $0x10,%esp
8010a577:	66 d1 e8             	shr    %ax
8010a57a:	0f b7 c0             	movzwl %ax,%eax
8010a57d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a580:	7c af                	jl     8010a531 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a582:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a585:	c1 e8 10             	shr    $0x10,%eax
8010a588:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a58b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a58e:	f7 d0                	not    %eax
}
8010a590:	c9                   	leave  
8010a591:	c3                   	ret    

8010a592 <tcp_fin>:

void tcp_fin(){
8010a592:	55                   	push   %ebp
8010a593:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a595:	c7 05 68 7a 19 80 01 	movl   $0x1,0x80197a68
8010a59c:	00 00 00 
}
8010a59f:	90                   	nop
8010a5a0:	5d                   	pop    %ebp
8010a5a1:	c3                   	ret    

8010a5a2 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a5a2:	55                   	push   %ebp
8010a5a3:	89 e5                	mov    %esp,%ebp
8010a5a5:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a5a8:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5ab:	83 ec 04             	sub    $0x4,%esp
8010a5ae:	6a 00                	push   $0x0
8010a5b0:	68 4b c7 10 80       	push   $0x8010c74b
8010a5b5:	50                   	push   %eax
8010a5b6:	e8 65 00 00 00       	call   8010a620 <http_strcpy>
8010a5bb:	83 c4 10             	add    $0x10,%esp
8010a5be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a5c1:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5c4:	83 ec 04             	sub    $0x4,%esp
8010a5c7:	ff 75 f4             	push   -0xc(%ebp)
8010a5ca:	68 5e c7 10 80       	push   $0x8010c75e
8010a5cf:	50                   	push   %eax
8010a5d0:	e8 4b 00 00 00       	call   8010a620 <http_strcpy>
8010a5d5:	83 c4 10             	add    $0x10,%esp
8010a5d8:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a5db:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5de:	83 ec 04             	sub    $0x4,%esp
8010a5e1:	ff 75 f4             	push   -0xc(%ebp)
8010a5e4:	68 79 c7 10 80       	push   $0x8010c779
8010a5e9:	50                   	push   %eax
8010a5ea:	e8 31 00 00 00       	call   8010a620 <http_strcpy>
8010a5ef:	83 c4 10             	add    $0x10,%esp
8010a5f2:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a5f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a5f8:	83 e0 01             	and    $0x1,%eax
8010a5fb:	85 c0                	test   %eax,%eax
8010a5fd:	74 11                	je     8010a610 <http_proc+0x6e>
    char *payload = (char *)send;
8010a5ff:	8b 45 10             	mov    0x10(%ebp),%eax
8010a602:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a605:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a608:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a60b:	01 d0                	add    %edx,%eax
8010a60d:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a610:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a613:	8b 45 14             	mov    0x14(%ebp),%eax
8010a616:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a618:	e8 75 ff ff ff       	call   8010a592 <tcp_fin>
}
8010a61d:	90                   	nop
8010a61e:	c9                   	leave  
8010a61f:	c3                   	ret    

8010a620 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a620:	55                   	push   %ebp
8010a621:	89 e5                	mov    %esp,%ebp
8010a623:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a626:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a62d:	eb 20                	jmp    8010a64f <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a62f:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a632:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a635:	01 d0                	add    %edx,%eax
8010a637:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a63a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a63d:	01 ca                	add    %ecx,%edx
8010a63f:	89 d1                	mov    %edx,%ecx
8010a641:	8b 55 08             	mov    0x8(%ebp),%edx
8010a644:	01 ca                	add    %ecx,%edx
8010a646:	0f b6 00             	movzbl (%eax),%eax
8010a649:	88 02                	mov    %al,(%edx)
    i++;
8010a64b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a64f:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a652:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a655:	01 d0                	add    %edx,%eax
8010a657:	0f b6 00             	movzbl (%eax),%eax
8010a65a:	84 c0                	test   %al,%al
8010a65c:	75 d1                	jne    8010a62f <http_strcpy+0xf>
  }
  return i;
8010a65e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a661:	c9                   	leave  
8010a662:	c3                   	ret    

8010a663 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a663:	55                   	push   %ebp
8010a664:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a666:	c7 05 70 7a 19 80 c2 	movl   $0x8010f5c2,0x80197a70
8010a66d:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a670:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a675:	c1 e8 09             	shr    $0x9,%eax
8010a678:	a3 6c 7a 19 80       	mov    %eax,0x80197a6c
}
8010a67d:	90                   	nop
8010a67e:	5d                   	pop    %ebp
8010a67f:	c3                   	ret    

8010a680 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a680:	55                   	push   %ebp
8010a681:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a683:	90                   	nop
8010a684:	5d                   	pop    %ebp
8010a685:	c3                   	ret    

8010a686 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a686:	55                   	push   %ebp
8010a687:	89 e5                	mov    %esp,%ebp
8010a689:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a68c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a68f:	83 c0 0c             	add    $0xc,%eax
8010a692:	83 ec 0c             	sub    $0xc,%esp
8010a695:	50                   	push   %eax
8010a696:	e8 fa a3 ff ff       	call   80104a95 <holdingsleep>
8010a69b:	83 c4 10             	add    $0x10,%esp
8010a69e:	85 c0                	test   %eax,%eax
8010a6a0:	75 0d                	jne    8010a6af <iderw+0x29>
    panic("iderw: buf not locked");
8010a6a2:	83 ec 0c             	sub    $0xc,%esp
8010a6a5:	68 8a c7 10 80       	push   $0x8010c78a
8010a6aa:	e8 fa 5e ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a6af:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6b2:	8b 00                	mov    (%eax),%eax
8010a6b4:	83 e0 06             	and    $0x6,%eax
8010a6b7:	83 f8 02             	cmp    $0x2,%eax
8010a6ba:	75 0d                	jne    8010a6c9 <iderw+0x43>
    panic("iderw: nothing to do");
8010a6bc:	83 ec 0c             	sub    $0xc,%esp
8010a6bf:	68 a0 c7 10 80       	push   $0x8010c7a0
8010a6c4:	e8 e0 5e ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a6c9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6cc:	8b 40 04             	mov    0x4(%eax),%eax
8010a6cf:	83 f8 01             	cmp    $0x1,%eax
8010a6d2:	74 0d                	je     8010a6e1 <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a6d4:	83 ec 0c             	sub    $0xc,%esp
8010a6d7:	68 b5 c7 10 80       	push   $0x8010c7b5
8010a6dc:	e8 c8 5e ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a6e1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6e4:	8b 40 08             	mov    0x8(%eax),%eax
8010a6e7:	8b 15 6c 7a 19 80    	mov    0x80197a6c,%edx
8010a6ed:	39 d0                	cmp    %edx,%eax
8010a6ef:	72 0d                	jb     8010a6fe <iderw+0x78>
    panic("iderw: block out of range");
8010a6f1:	83 ec 0c             	sub    $0xc,%esp
8010a6f4:	68 d3 c7 10 80       	push   $0x8010c7d3
8010a6f9:	e8 ab 5e ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a6fe:	8b 15 70 7a 19 80    	mov    0x80197a70,%edx
8010a704:	8b 45 08             	mov    0x8(%ebp),%eax
8010a707:	8b 40 08             	mov    0x8(%eax),%eax
8010a70a:	c1 e0 09             	shl    $0x9,%eax
8010a70d:	01 d0                	add    %edx,%eax
8010a70f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a712:	8b 45 08             	mov    0x8(%ebp),%eax
8010a715:	8b 00                	mov    (%eax),%eax
8010a717:	83 e0 04             	and    $0x4,%eax
8010a71a:	85 c0                	test   %eax,%eax
8010a71c:	74 2b                	je     8010a749 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a71e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a721:	8b 00                	mov    (%eax),%eax
8010a723:	83 e0 fb             	and    $0xfffffffb,%eax
8010a726:	89 c2                	mov    %eax,%edx
8010a728:	8b 45 08             	mov    0x8(%ebp),%eax
8010a72b:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a72d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a730:	83 c0 5c             	add    $0x5c,%eax
8010a733:	83 ec 04             	sub    $0x4,%esp
8010a736:	68 00 02 00 00       	push   $0x200
8010a73b:	50                   	push   %eax
8010a73c:	ff 75 f4             	push   -0xc(%ebp)
8010a73f:	e8 17 a7 ff ff       	call   80104e5b <memmove>
8010a744:	83 c4 10             	add    $0x10,%esp
8010a747:	eb 1a                	jmp    8010a763 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a749:	8b 45 08             	mov    0x8(%ebp),%eax
8010a74c:	83 c0 5c             	add    $0x5c,%eax
8010a74f:	83 ec 04             	sub    $0x4,%esp
8010a752:	68 00 02 00 00       	push   $0x200
8010a757:	ff 75 f4             	push   -0xc(%ebp)
8010a75a:	50                   	push   %eax
8010a75b:	e8 fb a6 ff ff       	call   80104e5b <memmove>
8010a760:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a763:	8b 45 08             	mov    0x8(%ebp),%eax
8010a766:	8b 00                	mov    (%eax),%eax
8010a768:	83 c8 02             	or     $0x2,%eax
8010a76b:	89 c2                	mov    %eax,%edx
8010a76d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a770:	89 10                	mov    %edx,(%eax)
}
8010a772:	90                   	nop
8010a773:	c9                   	leave  
8010a774:	c3                   	ret    
