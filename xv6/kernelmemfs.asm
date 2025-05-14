
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
8010005f:	ba 65 33 10 80       	mov    $0x80103365,%edx
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
8010006f:	68 00 a6 10 80       	push   $0x8010a600
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 4f 4a 00 00       	call   80104acd <initlock>
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
801000bd:	68 07 a6 10 80       	push   $0x8010a607
801000c2:	50                   	push   %eax
801000c3:	e8 a8 48 00 00       	call   80104970 <initsleeplock>
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
80100101:	e8 e9 49 00 00       	call   80104aef <acquire>
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
80100140:	e8 18 4a 00 00       	call   80104b5d <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 55 48 00 00       	call   801049ac <acquiresleep>
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
801001c1:	e8 97 49 00 00       	call   80104b5d <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 d4 47 00 00       	call   801049ac <acquiresleep>
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
801001f5:	68 0e a6 10 80       	push   $0x8010a60e
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
8010022d:	e8 d7 a2 00 00       	call   8010a509 <iderw>
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
8010024a:	e8 0f 48 00 00       	call   80104a5e <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 1f a6 10 80       	push   $0x8010a61f
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
80100278:	e8 8c a2 00 00       	call   8010a509 <iderw>
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
80100293:	e8 c6 47 00 00       	call   80104a5e <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 26 a6 10 80       	push   $0x8010a626
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 55 47 00 00       	call   80104a10 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 24 48 00 00       	call   80104aef <acquire>
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
80100336:	e8 22 48 00 00       	call   80104b5d <release>
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
80100410:	e8 da 46 00 00       	call   80104aef <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 2d a6 10 80       	push   $0x8010a62d
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
80100510:	c7 45 ec 36 a6 10 80 	movl   $0x8010a636,-0x14(%ebp)
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
8010059e:	e8 ba 45 00 00       	call   80104b5d <release>
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
801005be:	e8 37 25 00 00       	call   80102afa <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 3d a6 10 80       	push   $0x8010a63d
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
801005e6:	68 51 a6 10 80       	push   $0x8010a651
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 ac 45 00 00       	call   80104baf <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 53 a6 10 80       	push   $0x8010a653
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
801006a0:	e8 bb 7d 00 00       	call   80108460 <graphic_scroll_up>
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
801006f3:	e8 68 7d 00 00       	call   80108460 <graphic_scroll_up>
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
80100757:	e8 6f 7d 00 00       	call   801084cb <font_render>
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
80100793:	e8 3f 61 00 00       	call   801068d7 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 32 61 00 00       	call   801068d7 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 25 61 00 00       	call   801068d7 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 15 61 00 00       	call   801068d7 <uartputc>
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
801007eb:	e8 ff 42 00 00       	call   80104aef <acquire>
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
8010093f:	e8 71 3e 00 00       	call   801047b5 <wakeup>
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
80100962:	e8 f6 41 00 00       	call   80104b5d <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 fe 3e 00 00       	call   80104873 <procdump>
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
80100984:	e8 74 11 00 00       	call   80101afd <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 50 41 00 00       	call   80104aef <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 84 30 00 00       	call   80103a30 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 9d 41 00 00       	call   80104b5d <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 1c 10 00 00       	call   801019ea <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 de 3c 00 00       	call   801046cb <sleep>
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
80100a66:	e8 f2 40 00 00       	call   80104b5d <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 71 0f 00 00       	call   801019ea <ilock>
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
80100a92:	e8 66 10 00 00       	call   80101afd <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 48 40 00 00       	call   80104aef <acquire>
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
80100ae4:	e8 74 40 00 00       	call   80104b5d <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 f3 0e 00 00       	call   801019ea <ilock>
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
80100b12:	68 57 a6 10 80       	push   $0x8010a657
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 ac 3f 00 00       	call   80104acd <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 5f a6 10 80 	movl   $0x8010a65f,-0xc(%ebp)
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
80100b75:	e8 b4 1a 00 00       	call   8010262e <ioapicenable>
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
80100b89:	e8 a2 2e 00 00       	call   80103a30 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 a6 24 00 00       	call   8010303c <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7c 19 00 00       	call   8010251d <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 16 25 00 00       	call   801030c8 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 75 a6 10 80       	push   $0x8010a675
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 f1 03 00 00       	jmp    80100fbd <exec+0x43d>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 13 0e 00 00       	call   801019ea <ilock>
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
80100bef:	e8 e2 12 00 00       	call   80101ed6 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 66 03 00 00    	jne    80100f66 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 58 03 00 00    	jne    80100f69 <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 bd 6c 00 00       	call   801078d3 <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 49 03 00 00    	je     80100f6c <exec+0x3ec>
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
80100c4f:	e8 82 12 00 00       	call   80101ed6 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 0f 03 00 00    	jne    80100f6f <exec+0x3ef>
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
80100c7d:	0f 82 ef 02 00 00    	jb     80100f72 <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 d6 02 00 00    	jb     80100f75 <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 10 70 00 00       	call   80107ccc <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 ac 02 00 00    	je     80100f78 <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 9c 02 00 00    	jne    80100f7b <exec+0x3fb>
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
80100cfd:	e8 fd 6e 00 00       	call   80107bff <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 71 02 00 00    	js     80100f7e <exec+0x3fe>
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
80100d36:	e8 e0 0e 00 00       	call   80101c1b <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 85 23 00 00       	call   801030c8 <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4d:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d57:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	05 00 20 00 00       	add    $0x2000,%eax
80100d62:	83 ec 04             	sub    $0x4,%esp
80100d65:	50                   	push   %eax
80100d66:	ff 75 e0             	push   -0x20(%ebp)
80100d69:	ff 75 d4             	push   -0x2c(%ebp)
80100d6c:	e8 5b 6f 00 00       	call   80107ccc <allocuvm>
80100d71:	83 c4 10             	add    $0x10,%esp
80100d74:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d77:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7b:	0f 84 00 02 00 00    	je     80100f81 <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d84:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d89:	83 ec 08             	sub    $0x8,%esp
80100d8c:	50                   	push   %eax
80100d8d:	ff 75 d4             	push   -0x2c(%ebp)
80100d90:	e8 99 71 00 00       	call   80107f2e <clearpteu>
80100d95:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100da5:	e9 96 00 00 00       	jmp    80100e40 <exec+0x2c0>
    if(argc >= MAXARG)
80100daa:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100dae:	0f 87 d0 01 00 00    	ja     80100f84 <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	8b 00                	mov    (%eax),%eax
80100dc5:	83 ec 0c             	sub    $0xc,%esp
80100dc8:	50                   	push   %eax
80100dc9:	e8 e5 41 00 00       	call   80104fb3 <strlen>
80100dce:	83 c4 10             	add    $0x10,%esp
80100dd1:	89 c2                	mov    %eax,%edx
80100dd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dd6:	29 d0                	sub    %edx,%eax
80100dd8:	83 e8 01             	sub    $0x1,%eax
80100ddb:	83 e0 fc             	and    $0xfffffffc,%eax
80100dde:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dee:	01 d0                	add    %edx,%eax
80100df0:	8b 00                	mov    (%eax),%eax
80100df2:	83 ec 0c             	sub    $0xc,%esp
80100df5:	50                   	push   %eax
80100df6:	e8 b8 41 00 00       	call   80104fb3 <strlen>
80100dfb:	83 c4 10             	add    $0x10,%esp
80100dfe:	83 c0 01             	add    $0x1,%eax
80100e01:	89 c2                	mov    %eax,%edx
80100e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e06:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e10:	01 c8                	add    %ecx,%eax
80100e12:	8b 00                	mov    (%eax),%eax
80100e14:	52                   	push   %edx
80100e15:	50                   	push   %eax
80100e16:	ff 75 dc             	push   -0x24(%ebp)
80100e19:	ff 75 d4             	push   -0x2c(%ebp)
80100e1c:	e8 ac 72 00 00       	call   801080cd <copyout>
80100e21:	83 c4 10             	add    $0x10,%esp
80100e24:	85 c0                	test   %eax,%eax
80100e26:	0f 88 5b 01 00 00    	js     80100f87 <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	8d 50 03             	lea    0x3(%eax),%edx
80100e32:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e35:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e3c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4d:	01 d0                	add    %edx,%eax
80100e4f:	8b 00                	mov    (%eax),%eax
80100e51:	85 c0                	test   %eax,%eax
80100e53:	0f 85 51 ff ff ff    	jne    80100daa <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5c:	83 c0 03             	add    $0x3,%eax
80100e5f:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e66:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e6a:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e71:	ff ff ff 
  ustack[1] = argc;
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	83 c0 01             	add    $0x1,%eax
80100e83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8d:	29 d0                	sub    %edx,%eax
80100e8f:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e98:	83 c0 04             	add    $0x4,%eax
80100e9b:	c1 e0 02             	shl    $0x2,%eax
80100e9e:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea4:	83 c0 04             	add    $0x4,%eax
80100ea7:	c1 e0 02             	shl    $0x2,%eax
80100eaa:	50                   	push   %eax
80100eab:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100eb1:	50                   	push   %eax
80100eb2:	ff 75 dc             	push   -0x24(%ebp)
80100eb5:	ff 75 d4             	push   -0x2c(%ebp)
80100eb8:	e8 10 72 00 00       	call   801080cd <copyout>
80100ebd:	83 c4 10             	add    $0x10,%esp
80100ec0:	85 c0                	test   %eax,%eax
80100ec2:	0f 88 c2 00 00 00    	js     80100f8a <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80100ecb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ed4:	eb 17                	jmp    80100eed <exec+0x36d>
    if(*s == '/')
80100ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed9:	0f b6 00             	movzbl (%eax),%eax
80100edc:	3c 2f                	cmp    $0x2f,%al
80100ede:	75 09                	jne    80100ee9 <exec+0x369>
      last = s+1;
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	83 c0 01             	add    $0x1,%eax
80100ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ee9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef0:	0f b6 00             	movzbl (%eax),%eax
80100ef3:	84 c0                	test   %al,%al
80100ef5:	75 df                	jne    80100ed6 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ef7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100efa:	83 c0 6c             	add    $0x6c,%eax
80100efd:	83 ec 04             	sub    $0x4,%esp
80100f00:	6a 10                	push   $0x10
80100f02:	ff 75 f0             	push   -0x10(%ebp)
80100f05:	50                   	push   %eax
80100f06:	e8 5d 40 00 00       	call   80104f68 <safestrcpy>
80100f0b:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f11:	8b 40 04             	mov    0x4(%eax),%eax
80100f14:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f17:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f1d:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f20:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f23:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f26:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f28:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2b:	8b 40 18             	mov    0x18(%eax),%eax
80100f2e:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f34:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f37:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3a:	8b 40 18             	mov    0x18(%eax),%eax
80100f3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f40:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f43:	83 ec 0c             	sub    $0xc,%esp
80100f46:	ff 75 d0             	push   -0x30(%ebp)
80100f49:	e8 a2 6a 00 00       	call   801079f0 <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 39 6f 00 00       	call   80107e95 <freevm>
80100f5c:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f5f:	b8 00 00 00 00       	mov    $0x0,%eax
80100f64:	eb 57                	jmp    80100fbd <exec+0x43d>
    goto bad;
80100f66:	90                   	nop
80100f67:	eb 22                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f69:	90                   	nop
80100f6a:	eb 1f                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f6c:	90                   	nop
80100f6d:	eb 1c                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f6f:	90                   	nop
80100f70:	eb 19                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f72:	90                   	nop
80100f73:	eb 16                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f75:	90                   	nop
80100f76:	eb 13                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f78:	90                   	nop
80100f79:	eb 10                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7b:	90                   	nop
80100f7c:	eb 0d                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7e:	90                   	nop
80100f7f:	eb 0a                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f81:	90                   	nop
80100f82:	eb 07                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f84:	90                   	nop
80100f85:	eb 04                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f87:	90                   	nop
80100f88:	eb 01                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f8a:	90                   	nop

 bad:
  if(pgdir)
80100f8b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f8f:	74 0e                	je     80100f9f <exec+0x41f>
    freevm(pgdir);
80100f91:	83 ec 0c             	sub    $0xc,%esp
80100f94:	ff 75 d4             	push   -0x2c(%ebp)
80100f97:	e8 f9 6e 00 00       	call   80107e95 <freevm>
80100f9c:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f9f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa3:	74 13                	je     80100fb8 <exec+0x438>
    iunlockput(ip);
80100fa5:	83 ec 0c             	sub    $0xc,%esp
80100fa8:	ff 75 d8             	push   -0x28(%ebp)
80100fab:	e8 6b 0c 00 00       	call   80101c1b <iunlockput>
80100fb0:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fb3:	e8 10 21 00 00       	call   801030c8 <end_op>
  }
  return -1;
80100fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fbd:	c9                   	leave  
80100fbe:	c3                   	ret    

80100fbf <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fbf:	55                   	push   %ebp
80100fc0:	89 e5                	mov    %esp,%ebp
80100fc2:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fc5:	83 ec 08             	sub    $0x8,%esp
80100fc8:	68 81 a6 10 80       	push   $0x8010a681
80100fcd:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd2:	e8 f6 3a 00 00       	call   80104acd <initlock>
80100fd7:	83 c4 10             	add    $0x10,%esp
}
80100fda:	90                   	nop
80100fdb:	c9                   	leave  
80100fdc:	c3                   	ret    

80100fdd <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fdd:	55                   	push   %ebp
80100fde:	89 e5                	mov    %esp,%ebp
80100fe0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe3:	83 ec 0c             	sub    $0xc,%esp
80100fe6:	68 a0 1a 19 80       	push   $0x80191aa0
80100feb:	e8 ff 3a 00 00       	call   80104aef <acquire>
80100ff0:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff3:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80100ffa:	eb 2d                	jmp    80101029 <filealloc+0x4c>
    if(f->ref == 0){
80100ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fff:	8b 40 04             	mov    0x4(%eax),%eax
80101002:	85 c0                	test   %eax,%eax
80101004:	75 1f                	jne    80101025 <filealloc+0x48>
      f->ref = 1;
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101010:	83 ec 0c             	sub    $0xc,%esp
80101013:	68 a0 1a 19 80       	push   $0x80191aa0
80101018:	e8 40 3b 00 00       	call   80104b5d <release>
8010101d:	83 c4 10             	add    $0x10,%esp
      return f;
80101020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101023:	eb 23                	jmp    80101048 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101025:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101029:	b8 34 24 19 80       	mov    $0x80192434,%eax
8010102e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101031:	72 c9                	jb     80100ffc <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	68 a0 1a 19 80       	push   $0x80191aa0
8010103b:	e8 1d 3b 00 00       	call   80104b5d <release>
80101040:	83 c4 10             	add    $0x10,%esp
  return 0;
80101043:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101048:	c9                   	leave  
80101049:	c3                   	ret    

8010104a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010104a:	55                   	push   %ebp
8010104b:	89 e5                	mov    %esp,%ebp
8010104d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101050:	83 ec 0c             	sub    $0xc,%esp
80101053:	68 a0 1a 19 80       	push   $0x80191aa0
80101058:	e8 92 3a 00 00       	call   80104aef <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 88 a6 10 80       	push   $0x8010a688
80101072:	e8 32 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101077:	8b 45 08             	mov    0x8(%ebp),%eax
8010107a:	8b 40 04             	mov    0x4(%eax),%eax
8010107d:	8d 50 01             	lea    0x1(%eax),%edx
80101080:	8b 45 08             	mov    0x8(%ebp),%eax
80101083:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101086:	83 ec 0c             	sub    $0xc,%esp
80101089:	68 a0 1a 19 80       	push   $0x80191aa0
8010108e:	e8 ca 3a 00 00       	call   80104b5d <release>
80101093:	83 c4 10             	add    $0x10,%esp
  return f;
80101096:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101099:	c9                   	leave  
8010109a:	c3                   	ret    

8010109b <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010109b:	55                   	push   %ebp
8010109c:	89 e5                	mov    %esp,%ebp
8010109e:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010a1:	83 ec 0c             	sub    $0xc,%esp
801010a4:	68 a0 1a 19 80       	push   $0x80191aa0
801010a9:	e8 41 3a 00 00       	call   80104aef <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 90 a6 10 80       	push   $0x8010a690
801010c3:	e8 e1 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010c8:	8b 45 08             	mov    0x8(%ebp),%eax
801010cb:	8b 40 04             	mov    0x4(%eax),%eax
801010ce:	8d 50 ff             	lea    -0x1(%eax),%edx
801010d1:	8b 45 08             	mov    0x8(%ebp),%eax
801010d4:	89 50 04             	mov    %edx,0x4(%eax)
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 04             	mov    0x4(%eax),%eax
801010dd:	85 c0                	test   %eax,%eax
801010df:	7e 15                	jle    801010f6 <fileclose+0x5b>
    release(&ftable.lock);
801010e1:	83 ec 0c             	sub    $0xc,%esp
801010e4:	68 a0 1a 19 80       	push   $0x80191aa0
801010e9:	e8 6f 3a 00 00       	call   80104b5d <release>
801010ee:	83 c4 10             	add    $0x10,%esp
801010f1:	e9 8b 00 00 00       	jmp    80101181 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
801010f9:	8b 10                	mov    (%eax),%edx
801010fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010fe:	8b 50 04             	mov    0x4(%eax),%edx
80101101:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101104:	8b 50 08             	mov    0x8(%eax),%edx
80101107:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010110a:	8b 50 0c             	mov    0xc(%eax),%edx
8010110d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101110:	8b 50 10             	mov    0x10(%eax),%edx
80101113:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101116:	8b 40 14             	mov    0x14(%eax),%eax
80101119:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010111c:	8b 45 08             	mov    0x8(%ebp),%eax
8010111f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010112f:	83 ec 0c             	sub    $0xc,%esp
80101132:	68 a0 1a 19 80       	push   $0x80191aa0
80101137:	e8 21 3a 00 00       	call   80104b5d <release>
8010113c:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010113f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101142:	83 f8 01             	cmp    $0x1,%eax
80101145:	75 19                	jne    80101160 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101147:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010114b:	0f be d0             	movsbl %al,%edx
8010114e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101151:	83 ec 08             	sub    $0x8,%esp
80101154:	52                   	push   %edx
80101155:	50                   	push   %eax
80101156:	e8 64 25 00 00       	call   801036bf <pipeclose>
8010115b:	83 c4 10             	add    $0x10,%esp
8010115e:	eb 21                	jmp    80101181 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101160:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101163:	83 f8 02             	cmp    $0x2,%eax
80101166:	75 19                	jne    80101181 <fileclose+0xe6>
    begin_op();
80101168:	e8 cf 1e 00 00       	call   8010303c <begin_op>
    iput(ff.ip);
8010116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101170:	83 ec 0c             	sub    $0xc,%esp
80101173:	50                   	push   %eax
80101174:	e8 d2 09 00 00       	call   80101b4b <iput>
80101179:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117c:	e8 47 1f 00 00       	call   801030c8 <end_op>
  }
}
80101181:	c9                   	leave  
80101182:	c3                   	ret    

80101183 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101183:	55                   	push   %ebp
80101184:	89 e5                	mov    %esp,%ebp
80101186:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101189:	8b 45 08             	mov    0x8(%ebp),%eax
8010118c:	8b 00                	mov    (%eax),%eax
8010118e:	83 f8 02             	cmp    $0x2,%eax
80101191:	75 40                	jne    801011d3 <filestat+0x50>
    ilock(f->ip);
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 40 10             	mov    0x10(%eax),%eax
80101199:	83 ec 0c             	sub    $0xc,%esp
8010119c:	50                   	push   %eax
8010119d:	e8 48 08 00 00       	call   801019ea <ilock>
801011a2:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011a5:	8b 45 08             	mov    0x8(%ebp),%eax
801011a8:	8b 40 10             	mov    0x10(%eax),%eax
801011ab:	83 ec 08             	sub    $0x8,%esp
801011ae:	ff 75 0c             	push   0xc(%ebp)
801011b1:	50                   	push   %eax
801011b2:	e8 d9 0c 00 00       	call   80101e90 <stati>
801011b7:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011ba:	8b 45 08             	mov    0x8(%ebp),%eax
801011bd:	8b 40 10             	mov    0x10(%eax),%eax
801011c0:	83 ec 0c             	sub    $0xc,%esp
801011c3:	50                   	push   %eax
801011c4:	e8 34 09 00 00       	call   80101afd <iunlock>
801011c9:	83 c4 10             	add    $0x10,%esp
    return 0;
801011cc:	b8 00 00 00 00       	mov    $0x0,%eax
801011d1:	eb 05                	jmp    801011d8 <filestat+0x55>
  }
  return -1;
801011d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d8:	c9                   	leave  
801011d9:	c3                   	ret    

801011da <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011da:	55                   	push   %ebp
801011db:	89 e5                	mov    %esp,%ebp
801011dd:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011e0:	8b 45 08             	mov    0x8(%ebp),%eax
801011e3:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011e7:	84 c0                	test   %al,%al
801011e9:	75 0a                	jne    801011f5 <fileread+0x1b>
    return -1;
801011eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011f0:	e9 9b 00 00 00       	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011f5:	8b 45 08             	mov    0x8(%ebp),%eax
801011f8:	8b 00                	mov    (%eax),%eax
801011fa:	83 f8 01             	cmp    $0x1,%eax
801011fd:	75 1a                	jne    80101219 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 40 0c             	mov    0xc(%eax),%eax
80101205:	83 ec 04             	sub    $0x4,%esp
80101208:	ff 75 10             	push   0x10(%ebp)
8010120b:	ff 75 0c             	push   0xc(%ebp)
8010120e:	50                   	push   %eax
8010120f:	e8 58 26 00 00       	call   8010386c <piperead>
80101214:	83 c4 10             	add    $0x10,%esp
80101217:	eb 77                	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_INODE){
80101219:	8b 45 08             	mov    0x8(%ebp),%eax
8010121c:	8b 00                	mov    (%eax),%eax
8010121e:	83 f8 02             	cmp    $0x2,%eax
80101221:	75 60                	jne    80101283 <fileread+0xa9>
    ilock(f->ip);
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 40 10             	mov    0x10(%eax),%eax
80101229:	83 ec 0c             	sub    $0xc,%esp
8010122c:	50                   	push   %eax
8010122d:	e8 b8 07 00 00       	call   801019ea <ilock>
80101232:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101235:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 50 14             	mov    0x14(%eax),%edx
8010123e:	8b 45 08             	mov    0x8(%ebp),%eax
80101241:	8b 40 10             	mov    0x10(%eax),%eax
80101244:	51                   	push   %ecx
80101245:	52                   	push   %edx
80101246:	ff 75 0c             	push   0xc(%ebp)
80101249:	50                   	push   %eax
8010124a:	e8 87 0c 00 00       	call   80101ed6 <readi>
8010124f:	83 c4 10             	add    $0x10,%esp
80101252:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101255:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101259:	7e 11                	jle    8010126c <fileread+0x92>
      f->off += r;
8010125b:	8b 45 08             	mov    0x8(%ebp),%eax
8010125e:	8b 50 14             	mov    0x14(%eax),%edx
80101261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101264:	01 c2                	add    %eax,%edx
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010126c:	8b 45 08             	mov    0x8(%ebp),%eax
8010126f:	8b 40 10             	mov    0x10(%eax),%eax
80101272:	83 ec 0c             	sub    $0xc,%esp
80101275:	50                   	push   %eax
80101276:	e8 82 08 00 00       	call   80101afd <iunlock>
8010127b:	83 c4 10             	add    $0x10,%esp
    return r;
8010127e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101281:	eb 0d                	jmp    80101290 <fileread+0xb6>
  }
  panic("fileread");
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	68 9a a6 10 80       	push   $0x8010a69a
8010128b:	e8 19 f3 ff ff       	call   801005a9 <panic>
}
80101290:	c9                   	leave  
80101291:	c3                   	ret    

80101292 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101292:	55                   	push   %ebp
80101293:	89 e5                	mov    %esp,%ebp
80101295:	53                   	push   %ebx
80101296:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101299:	8b 45 08             	mov    0x8(%ebp),%eax
8010129c:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012a0:	84 c0                	test   %al,%al
801012a2:	75 0a                	jne    801012ae <filewrite+0x1c>
    return -1;
801012a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012a9:	e9 1b 01 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 00                	mov    (%eax),%eax
801012b3:	83 f8 01             	cmp    $0x1,%eax
801012b6:	75 1d                	jne    801012d5 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 40 0c             	mov    0xc(%eax),%eax
801012be:	83 ec 04             	sub    $0x4,%esp
801012c1:	ff 75 10             	push   0x10(%ebp)
801012c4:	ff 75 0c             	push   0xc(%ebp)
801012c7:	50                   	push   %eax
801012c8:	e8 9d 24 00 00       	call   8010376a <pipewrite>
801012cd:	83 c4 10             	add    $0x10,%esp
801012d0:	e9 f4 00 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_INODE){
801012d5:	8b 45 08             	mov    0x8(%ebp),%eax
801012d8:	8b 00                	mov    (%eax),%eax
801012da:	83 f8 02             	cmp    $0x2,%eax
801012dd:	0f 85 d9 00 00 00    	jne    801013bc <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012e3:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012f1:	e9 a3 00 00 00       	jmp    80101399 <filewrite+0x107>
      int n1 = n - i;
801012f6:	8b 45 10             	mov    0x10(%ebp),%eax
801012f9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101302:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101305:	7e 06                	jle    8010130d <filewrite+0x7b>
        n1 = max;
80101307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010130a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010130d:	e8 2a 1d 00 00       	call   8010303c <begin_op>
      ilock(f->ip);
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	8b 40 10             	mov    0x10(%eax),%eax
80101318:	83 ec 0c             	sub    $0xc,%esp
8010131b:	50                   	push   %eax
8010131c:	e8 c9 06 00 00       	call   801019ea <ilock>
80101321:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101324:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101327:	8b 45 08             	mov    0x8(%ebp),%eax
8010132a:	8b 50 14             	mov    0x14(%eax),%edx
8010132d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101330:	8b 45 0c             	mov    0xc(%ebp),%eax
80101333:	01 c3                	add    %eax,%ebx
80101335:	8b 45 08             	mov    0x8(%ebp),%eax
80101338:	8b 40 10             	mov    0x10(%eax),%eax
8010133b:	51                   	push   %ecx
8010133c:	52                   	push   %edx
8010133d:	53                   	push   %ebx
8010133e:	50                   	push   %eax
8010133f:	e8 e7 0c 00 00       	call   8010202b <writei>
80101344:	83 c4 10             	add    $0x10,%esp
80101347:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010134a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010134e:	7e 11                	jle    80101361 <filewrite+0xcf>
        f->off += r;
80101350:	8b 45 08             	mov    0x8(%ebp),%eax
80101353:	8b 50 14             	mov    0x14(%eax),%edx
80101356:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101359:	01 c2                	add    %eax,%edx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101361:	8b 45 08             	mov    0x8(%ebp),%eax
80101364:	8b 40 10             	mov    0x10(%eax),%eax
80101367:	83 ec 0c             	sub    $0xc,%esp
8010136a:	50                   	push   %eax
8010136b:	e8 8d 07 00 00       	call   80101afd <iunlock>
80101370:	83 c4 10             	add    $0x10,%esp
      end_op();
80101373:	e8 50 1d 00 00       	call   801030c8 <end_op>

      if(r < 0)
80101378:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010137c:	78 29                	js     801013a7 <filewrite+0x115>
        break;
      if(r != n1)
8010137e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101381:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101384:	74 0d                	je     80101393 <filewrite+0x101>
        panic("short filewrite");
80101386:	83 ec 0c             	sub    $0xc,%esp
80101389:	68 a3 a6 10 80       	push   $0x8010a6a3
8010138e:	e8 16 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101393:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101396:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010139f:	0f 8c 51 ff ff ff    	jl     801012f6 <filewrite+0x64>
801013a5:	eb 01                	jmp    801013a8 <filewrite+0x116>
        break;
801013a7:	90                   	nop
    }
    return i == n ? n : -1;
801013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ab:	3b 45 10             	cmp    0x10(%ebp),%eax
801013ae:	75 05                	jne    801013b5 <filewrite+0x123>
801013b0:	8b 45 10             	mov    0x10(%ebp),%eax
801013b3:	eb 14                	jmp    801013c9 <filewrite+0x137>
801013b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013ba:	eb 0d                	jmp    801013c9 <filewrite+0x137>
  }
  panic("filewrite");
801013bc:	83 ec 0c             	sub    $0xc,%esp
801013bf:	68 b3 a6 10 80       	push   $0x8010a6b3
801013c4:	e8 e0 f1 ff ff       	call   801005a9 <panic>
}
801013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013cc:	c9                   	leave  
801013cd:	c3                   	ret    

801013ce <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013ce:	55                   	push   %ebp
801013cf:	89 e5                	mov    %esp,%ebp
801013d1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013d4:	8b 45 08             	mov    0x8(%ebp),%eax
801013d7:	83 ec 08             	sub    $0x8,%esp
801013da:	6a 01                	push   $0x1
801013dc:	50                   	push   %eax
801013dd:	e8 1f ee ff ff       	call   80100201 <bread>
801013e2:	83 c4 10             	add    $0x10,%esp
801013e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013eb:	83 c0 5c             	add    $0x5c,%eax
801013ee:	83 ec 04             	sub    $0x4,%esp
801013f1:	6a 1c                	push   $0x1c
801013f3:	50                   	push   %eax
801013f4:	ff 75 0c             	push   0xc(%ebp)
801013f7:	e8 28 3a 00 00       	call   80104e24 <memmove>
801013fc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ff:	83 ec 0c             	sub    $0xc,%esp
80101402:	ff 75 f4             	push   -0xc(%ebp)
80101405:	e8 79 ee ff ff       	call   80100283 <brelse>
8010140a:	83 c4 10             	add    $0x10,%esp
}
8010140d:	90                   	nop
8010140e:	c9                   	leave  
8010140f:	c3                   	ret    

80101410 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101410:	55                   	push   %ebp
80101411:	89 e5                	mov    %esp,%ebp
80101413:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101416:	8b 55 0c             	mov    0xc(%ebp),%edx
80101419:	8b 45 08             	mov    0x8(%ebp),%eax
8010141c:	83 ec 08             	sub    $0x8,%esp
8010141f:	52                   	push   %edx
80101420:	50                   	push   %eax
80101421:	e8 db ed ff ff       	call   80100201 <bread>
80101426:	83 c4 10             	add    $0x10,%esp
80101429:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010142c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142f:	83 c0 5c             	add    $0x5c,%eax
80101432:	83 ec 04             	sub    $0x4,%esp
80101435:	68 00 02 00 00       	push   $0x200
8010143a:	6a 00                	push   $0x0
8010143c:	50                   	push   %eax
8010143d:	e8 23 39 00 00       	call   80104d65 <memset>
80101442:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101445:	83 ec 0c             	sub    $0xc,%esp
80101448:	ff 75 f4             	push   -0xc(%ebp)
8010144b:	e8 25 1e 00 00       	call   80103275 <log_write>
80101450:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101453:	83 ec 0c             	sub    $0xc,%esp
80101456:	ff 75 f4             	push   -0xc(%ebp)
80101459:	e8 25 ee ff ff       	call   80100283 <brelse>
8010145e:	83 c4 10             	add    $0x10,%esp
}
80101461:	90                   	nop
80101462:	c9                   	leave  
80101463:	c3                   	ret    

80101464 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101464:	55                   	push   %ebp
80101465:	89 e5                	mov    %esp,%ebp
80101467:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010146a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101471:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101478:	e9 0b 01 00 00       	jmp    80101588 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101480:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101486:	85 c0                	test   %eax,%eax
80101488:	0f 48 c2             	cmovs  %edx,%eax
8010148b:	c1 f8 0c             	sar    $0xc,%eax
8010148e:	89 c2                	mov    %eax,%edx
80101490:	a1 58 24 19 80       	mov    0x80192458,%eax
80101495:	01 d0                	add    %edx,%eax
80101497:	83 ec 08             	sub    $0x8,%esp
8010149a:	50                   	push   %eax
8010149b:	ff 75 08             	push   0x8(%ebp)
8010149e:	e8 5e ed ff ff       	call   80100201 <bread>
801014a3:	83 c4 10             	add    $0x10,%esp
801014a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014b0:	e9 9e 00 00 00       	jmp    80101553 <balloc+0xef>
      m = 1 << (bi % 8);
801014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b8:	83 e0 07             	and    $0x7,%eax
801014bb:	ba 01 00 00 00       	mov    $0x1,%edx
801014c0:	89 c1                	mov    %eax,%ecx
801014c2:	d3 e2                	shl    %cl,%edx
801014c4:	89 d0                	mov    %edx,%eax
801014c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cc:	8d 50 07             	lea    0x7(%eax),%edx
801014cf:	85 c0                	test   %eax,%eax
801014d1:	0f 48 c2             	cmovs  %edx,%eax
801014d4:	c1 f8 03             	sar    $0x3,%eax
801014d7:	89 c2                	mov    %eax,%edx
801014d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014dc:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014e1:	0f b6 c0             	movzbl %al,%eax
801014e4:	23 45 e8             	and    -0x18(%ebp),%eax
801014e7:	85 c0                	test   %eax,%eax
801014e9:	75 64                	jne    8010154f <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ee:	8d 50 07             	lea    0x7(%eax),%edx
801014f1:	85 c0                	test   %eax,%eax
801014f3:	0f 48 c2             	cmovs  %edx,%eax
801014f6:	c1 f8 03             	sar    $0x3,%eax
801014f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014fc:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101501:	89 d1                	mov    %edx,%ecx
80101503:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101506:	09 ca                	or     %ecx,%edx
80101508:	89 d1                	mov    %edx,%ecx
8010150a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010150d:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101511:	83 ec 0c             	sub    $0xc,%esp
80101514:	ff 75 ec             	push   -0x14(%ebp)
80101517:	e8 59 1d 00 00       	call   80103275 <log_write>
8010151c:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010151f:	83 ec 0c             	sub    $0xc,%esp
80101522:	ff 75 ec             	push   -0x14(%ebp)
80101525:	e8 59 ed ff ff       	call   80100283 <brelse>
8010152a:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010152d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101533:	01 c2                	add    %eax,%edx
80101535:	8b 45 08             	mov    0x8(%ebp),%eax
80101538:	83 ec 08             	sub    $0x8,%esp
8010153b:	52                   	push   %edx
8010153c:	50                   	push   %eax
8010153d:	e8 ce fe ff ff       	call   80101410 <bzero>
80101542:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101545:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101548:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154b:	01 d0                	add    %edx,%eax
8010154d:	eb 57                	jmp    801015a6 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010154f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101553:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010155a:	7f 17                	jg     80101573 <balloc+0x10f>
8010155c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010155f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101562:	01 d0                	add    %edx,%eax
80101564:	89 c2                	mov    %eax,%edx
80101566:	a1 40 24 19 80       	mov    0x80192440,%eax
8010156b:	39 c2                	cmp    %eax,%edx
8010156d:	0f 82 42 ff ff ff    	jb     801014b5 <balloc+0x51>
      }
    }
    brelse(bp);
80101573:	83 ec 0c             	sub    $0xc,%esp
80101576:	ff 75 ec             	push   -0x14(%ebp)
80101579:	e8 05 ed ff ff       	call   80100283 <brelse>
8010157e:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101581:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101588:	8b 15 40 24 19 80    	mov    0x80192440,%edx
8010158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101591:	39 c2                	cmp    %eax,%edx
80101593:	0f 87 e4 fe ff ff    	ja     8010147d <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101599:	83 ec 0c             	sub    $0xc,%esp
8010159c:	68 c0 a6 10 80       	push   $0x8010a6c0
801015a1:	e8 03 f0 ff ff       	call   801005a9 <panic>
}
801015a6:	c9                   	leave  
801015a7:	c3                   	ret    

801015a8 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015a8:	55                   	push   %ebp
801015a9:	89 e5                	mov    %esp,%ebp
801015ab:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015ae:	83 ec 08             	sub    $0x8,%esp
801015b1:	68 40 24 19 80       	push   $0x80192440
801015b6:	ff 75 08             	push   0x8(%ebp)
801015b9:	e8 10 fe ff ff       	call   801013ce <readsb>
801015be:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c4:	c1 e8 0c             	shr    $0xc,%eax
801015c7:	89 c2                	mov    %eax,%edx
801015c9:	a1 58 24 19 80       	mov    0x80192458,%eax
801015ce:	01 c2                	add    %eax,%edx
801015d0:	8b 45 08             	mov    0x8(%ebp),%eax
801015d3:	83 ec 08             	sub    $0x8,%esp
801015d6:	52                   	push   %edx
801015d7:	50                   	push   %eax
801015d8:	e8 24 ec ff ff       	call   80100201 <bread>
801015dd:	83 c4 10             	add    $0x10,%esp
801015e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e6:	25 ff 0f 00 00       	and    $0xfff,%eax
801015eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f1:	83 e0 07             	and    $0x7,%eax
801015f4:	ba 01 00 00 00       	mov    $0x1,%edx
801015f9:	89 c1                	mov    %eax,%ecx
801015fb:	d3 e2                	shl    %cl,%edx
801015fd:	89 d0                	mov    %edx,%eax
801015ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101605:	8d 50 07             	lea    0x7(%eax),%edx
80101608:	85 c0                	test   %eax,%eax
8010160a:	0f 48 c2             	cmovs  %edx,%eax
8010160d:	c1 f8 03             	sar    $0x3,%eax
80101610:	89 c2                	mov    %eax,%edx
80101612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101615:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010161a:	0f b6 c0             	movzbl %al,%eax
8010161d:	23 45 ec             	and    -0x14(%ebp),%eax
80101620:	85 c0                	test   %eax,%eax
80101622:	75 0d                	jne    80101631 <bfree+0x89>
    panic("freeing free block");
80101624:	83 ec 0c             	sub    $0xc,%esp
80101627:	68 d6 a6 10 80       	push   $0x8010a6d6
8010162c:	e8 78 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101634:	8d 50 07             	lea    0x7(%eax),%edx
80101637:	85 c0                	test   %eax,%eax
80101639:	0f 48 c2             	cmovs  %edx,%eax
8010163c:	c1 f8 03             	sar    $0x3,%eax
8010163f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101642:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101647:	89 d1                	mov    %edx,%ecx
80101649:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164c:	f7 d2                	not    %edx
8010164e:	21 ca                	and    %ecx,%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101655:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101659:	83 ec 0c             	sub    $0xc,%esp
8010165c:	ff 75 f4             	push   -0xc(%ebp)
8010165f:	e8 11 1c 00 00       	call   80103275 <log_write>
80101664:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101667:	83 ec 0c             	sub    $0xc,%esp
8010166a:	ff 75 f4             	push   -0xc(%ebp)
8010166d:	e8 11 ec ff ff       	call   80100283 <brelse>
80101672:	83 c4 10             	add    $0x10,%esp
}
80101675:	90                   	nop
80101676:	c9                   	leave  
80101677:	c3                   	ret    

80101678 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101678:	55                   	push   %ebp
80101679:	89 e5                	mov    %esp,%ebp
8010167b:	57                   	push   %edi
8010167c:	56                   	push   %esi
8010167d:	53                   	push   %ebx
8010167e:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101681:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101688:	83 ec 08             	sub    $0x8,%esp
8010168b:	68 e9 a6 10 80       	push   $0x8010a6e9
80101690:	68 60 24 19 80       	push   $0x80192460
80101695:	e8 33 34 00 00       	call   80104acd <initlock>
8010169a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010169d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016a4:	eb 2d                	jmp    801016d3 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016a9:	89 d0                	mov    %edx,%eax
801016ab:	c1 e0 03             	shl    $0x3,%eax
801016ae:	01 d0                	add    %edx,%eax
801016b0:	c1 e0 04             	shl    $0x4,%eax
801016b3:	83 c0 30             	add    $0x30,%eax
801016b6:	05 60 24 19 80       	add    $0x80192460,%eax
801016bb:	83 c0 10             	add    $0x10,%eax
801016be:	83 ec 08             	sub    $0x8,%esp
801016c1:	68 f0 a6 10 80       	push   $0x8010a6f0
801016c6:	50                   	push   %eax
801016c7:	e8 a4 32 00 00       	call   80104970 <initsleeplock>
801016cc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016cf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d7:	7e cd                	jle    801016a6 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016d9:	83 ec 08             	sub    $0x8,%esp
801016dc:	68 40 24 19 80       	push   $0x80192440
801016e1:	ff 75 08             	push   0x8(%ebp)
801016e4:	e8 e5 fc ff ff       	call   801013ce <readsb>
801016e9:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ec:	a1 58 24 19 80       	mov    0x80192458,%eax
801016f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f4:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016fa:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101700:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
80101706:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
8010170c:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101712:	a1 40 24 19 80       	mov    0x80192440,%eax
80101717:	ff 75 d4             	push   -0x2c(%ebp)
8010171a:	57                   	push   %edi
8010171b:	56                   	push   %esi
8010171c:	53                   	push   %ebx
8010171d:	51                   	push   %ecx
8010171e:	52                   	push   %edx
8010171f:	50                   	push   %eax
80101720:	68 f8 a6 10 80       	push   $0x8010a6f8
80101725:	e8 ca ec ff ff       	call   801003f4 <cprintf>
8010172a:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010172d:	90                   	nop
8010172e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101731:	5b                   	pop    %ebx
80101732:	5e                   	pop    %esi
80101733:	5f                   	pop    %edi
80101734:	5d                   	pop    %ebp
80101735:	c3                   	ret    

80101736 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101736:	55                   	push   %ebp
80101737:	89 e5                	mov    %esp,%ebp
80101739:	83 ec 28             	sub    $0x28,%esp
8010173c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010173f:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101743:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010174a:	e9 9e 00 00 00       	jmp    801017ed <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101752:	c1 e8 03             	shr    $0x3,%eax
80101755:	89 c2                	mov    %eax,%edx
80101757:	a1 54 24 19 80       	mov    0x80192454,%eax
8010175c:	01 d0                	add    %edx,%eax
8010175e:	83 ec 08             	sub    $0x8,%esp
80101761:	50                   	push   %eax
80101762:	ff 75 08             	push   0x8(%ebp)
80101765:	e8 97 ea ff ff       	call   80100201 <bread>
8010176a:	83 c4 10             	add    $0x10,%esp
8010176d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101773:	8d 50 5c             	lea    0x5c(%eax),%edx
80101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101779:	83 e0 07             	and    $0x7,%eax
8010177c:	c1 e0 06             	shl    $0x6,%eax
8010177f:	01 d0                	add    %edx,%eax
80101781:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101784:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101787:	0f b7 00             	movzwl (%eax),%eax
8010178a:	66 85 c0             	test   %ax,%ax
8010178d:	75 4c                	jne    801017db <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010178f:	83 ec 04             	sub    $0x4,%esp
80101792:	6a 40                	push   $0x40
80101794:	6a 00                	push   $0x0
80101796:	ff 75 ec             	push   -0x14(%ebp)
80101799:	e8 c7 35 00 00       	call   80104d65 <memset>
8010179e:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ab:	83 ec 0c             	sub    $0xc,%esp
801017ae:	ff 75 f0             	push   -0x10(%ebp)
801017b1:	e8 bf 1a 00 00       	call   80103275 <log_write>
801017b6:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017b9:	83 ec 0c             	sub    $0xc,%esp
801017bc:	ff 75 f0             	push   -0x10(%ebp)
801017bf:	e8 bf ea ff ff       	call   80100283 <brelse>
801017c4:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ca:	83 ec 08             	sub    $0x8,%esp
801017cd:	50                   	push   %eax
801017ce:	ff 75 08             	push   0x8(%ebp)
801017d1:	e8 f8 00 00 00       	call   801018ce <iget>
801017d6:	83 c4 10             	add    $0x10,%esp
801017d9:	eb 30                	jmp    8010180b <ialloc+0xd5>
    }
    brelse(bp);
801017db:	83 ec 0c             	sub    $0xc,%esp
801017de:	ff 75 f0             	push   -0x10(%ebp)
801017e1:	e8 9d ea ff ff       	call   80100283 <brelse>
801017e6:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017ed:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	39 c2                	cmp    %eax,%edx
801017f8:	0f 87 51 ff ff ff    	ja     8010174f <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017fe:	83 ec 0c             	sub    $0xc,%esp
80101801:	68 4b a7 10 80       	push   $0x8010a74b
80101806:	e8 9e ed ff ff       	call   801005a9 <panic>
}
8010180b:	c9                   	leave  
8010180c:	c3                   	ret    

8010180d <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010180d:	55                   	push   %ebp
8010180e:	89 e5                	mov    %esp,%ebp
80101810:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101813:	8b 45 08             	mov    0x8(%ebp),%eax
80101816:	8b 40 04             	mov    0x4(%eax),%eax
80101819:	c1 e8 03             	shr    $0x3,%eax
8010181c:	89 c2                	mov    %eax,%edx
8010181e:	a1 54 24 19 80       	mov    0x80192454,%eax
80101823:	01 c2                	add    %eax,%edx
80101825:	8b 45 08             	mov    0x8(%ebp),%eax
80101828:	8b 00                	mov    (%eax),%eax
8010182a:	83 ec 08             	sub    $0x8,%esp
8010182d:	52                   	push   %edx
8010182e:	50                   	push   %eax
8010182f:	e8 cd e9 ff ff       	call   80100201 <bread>
80101834:	83 c4 10             	add    $0x10,%esp
80101837:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101840:	8b 45 08             	mov    0x8(%ebp),%eax
80101843:	8b 40 04             	mov    0x4(%eax),%eax
80101846:	83 e0 07             	and    $0x7,%eax
80101849:	c1 e0 06             	shl    $0x6,%eax
8010184c:	01 d0                	add    %edx,%eax
8010184e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101858:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010185e:	8b 45 08             	mov    0x8(%ebp),%eax
80101861:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101865:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101868:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101873:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101876:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010187a:	8b 45 08             	mov    0x8(%ebp),%eax
8010187d:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101884:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101888:	8b 45 08             	mov    0x8(%ebp),%eax
8010188b:	8b 50 58             	mov    0x58(%eax),%edx
8010188e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101891:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101894:	8b 45 08             	mov    0x8(%ebp),%eax
80101897:	8d 50 5c             	lea    0x5c(%eax),%edx
8010189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189d:	83 c0 0c             	add    $0xc,%eax
801018a0:	83 ec 04             	sub    $0x4,%esp
801018a3:	6a 34                	push   $0x34
801018a5:	52                   	push   %edx
801018a6:	50                   	push   %eax
801018a7:	e8 78 35 00 00       	call   80104e24 <memmove>
801018ac:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018af:	83 ec 0c             	sub    $0xc,%esp
801018b2:	ff 75 f4             	push   -0xc(%ebp)
801018b5:	e8 bb 19 00 00       	call   80103275 <log_write>
801018ba:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018bd:	83 ec 0c             	sub    $0xc,%esp
801018c0:	ff 75 f4             	push   -0xc(%ebp)
801018c3:	e8 bb e9 ff ff       	call   80100283 <brelse>
801018c8:	83 c4 10             	add    $0x10,%esp
}
801018cb:	90                   	nop
801018cc:	c9                   	leave  
801018cd:	c3                   	ret    

801018ce <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018ce:	55                   	push   %ebp
801018cf:	89 e5                	mov    %esp,%ebp
801018d1:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018d4:	83 ec 0c             	sub    $0xc,%esp
801018d7:	68 60 24 19 80       	push   $0x80192460
801018dc:	e8 0e 32 00 00       	call   80104aef <acquire>
801018e1:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018eb:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018f2:	eb 60                	jmp    80101954 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f7:	8b 40 08             	mov    0x8(%eax),%eax
801018fa:	85 c0                	test   %eax,%eax
801018fc:	7e 39                	jle    80101937 <iget+0x69>
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8b 00                	mov    (%eax),%eax
80101903:	39 45 08             	cmp    %eax,0x8(%ebp)
80101906:	75 2f                	jne    80101937 <iget+0x69>
80101908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190b:	8b 40 04             	mov    0x4(%eax),%eax
8010190e:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101911:	75 24                	jne    80101937 <iget+0x69>
      ip->ref++;
80101913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101916:	8b 40 08             	mov    0x8(%eax),%eax
80101919:	8d 50 01             	lea    0x1(%eax),%edx
8010191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101922:	83 ec 0c             	sub    $0xc,%esp
80101925:	68 60 24 19 80       	push   $0x80192460
8010192a:	e8 2e 32 00 00       	call   80104b5d <release>
8010192f:	83 c4 10             	add    $0x10,%esp
      return ip;
80101932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101935:	eb 77                	jmp    801019ae <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101937:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010193b:	75 10                	jne    8010194d <iget+0x7f>
8010193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101940:	8b 40 08             	mov    0x8(%eax),%eax
80101943:	85 c0                	test   %eax,%eax
80101945:	75 06                	jne    8010194d <iget+0x7f>
      empty = ip;
80101947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010194d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101954:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
8010195b:	72 97                	jb     801018f4 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101961:	75 0d                	jne    80101970 <iget+0xa2>
    panic("iget: no inodes");
80101963:	83 ec 0c             	sub    $0xc,%esp
80101966:	68 5d a7 10 80       	push   $0x8010a75d
8010196b:	e8 39 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101970:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101973:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101979:	8b 55 08             	mov    0x8(%ebp),%edx
8010197c:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 0c             	mov    0xc(%ebp),%edx
80101984:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101994:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010199b:	83 ec 0c             	sub    $0xc,%esp
8010199e:	68 60 24 19 80       	push   $0x80192460
801019a3:	e8 b5 31 00 00       	call   80104b5d <release>
801019a8:	83 c4 10             	add    $0x10,%esp

  return ip;
801019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019ae:	c9                   	leave  
801019af:	c3                   	ret    

801019b0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019b6:	83 ec 0c             	sub    $0xc,%esp
801019b9:	68 60 24 19 80       	push   $0x80192460
801019be:	e8 2c 31 00 00       	call   80104aef <acquire>
801019c3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c6:	8b 45 08             	mov    0x8(%ebp),%eax
801019c9:	8b 40 08             	mov    0x8(%eax),%eax
801019cc:	8d 50 01             	lea    0x1(%eax),%edx
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d5:	83 ec 0c             	sub    $0xc,%esp
801019d8:	68 60 24 19 80       	push   $0x80192460
801019dd:	e8 7b 31 00 00       	call   80104b5d <release>
801019e2:	83 c4 10             	add    $0x10,%esp
  return ip;
801019e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019e8:	c9                   	leave  
801019e9:	c3                   	ret    

801019ea <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019ea:	55                   	push   %ebp
801019eb:	89 e5                	mov    %esp,%ebp
801019ed:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019f4:	74 0a                	je     80101a00 <ilock+0x16>
801019f6:	8b 45 08             	mov    0x8(%ebp),%eax
801019f9:	8b 40 08             	mov    0x8(%eax),%eax
801019fc:	85 c0                	test   %eax,%eax
801019fe:	7f 0d                	jg     80101a0d <ilock+0x23>
    panic("ilock");
80101a00:	83 ec 0c             	sub    $0xc,%esp
80101a03:	68 6d a7 10 80       	push   $0x8010a76d
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 90 2f 00 00       	call   801049ac <acquiresleep>
80101a1c:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a22:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a25:	85 c0                	test   %eax,%eax
80101a27:	0f 85 cd 00 00 00    	jne    80101afa <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	8b 40 04             	mov    0x4(%eax),%eax
80101a33:	c1 e8 03             	shr    $0x3,%eax
80101a36:	89 c2                	mov    %eax,%edx
80101a38:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a3d:	01 c2                	add    %eax,%edx
80101a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a42:	8b 00                	mov    (%eax),%eax
80101a44:	83 ec 08             	sub    $0x8,%esp
80101a47:	52                   	push   %edx
80101a48:	50                   	push   %eax
80101a49:	e8 b3 e7 ff ff       	call   80100201 <bread>
80101a4e:	83 c4 10             	add    $0x10,%esp
80101a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a57:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5d:	8b 40 04             	mov    0x4(%eax),%eax
80101a60:	83 e0 07             	and    $0x7,%eax
80101a63:	c1 e0 06             	shl    $0x6,%eax
80101a66:	01 d0                	add    %edx,%eax
80101a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6e:	0f b7 10             	movzwl (%eax),%edx
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7b:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a82:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a89:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a97:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa5:	8b 50 08             	mov    0x8(%eax),%edx
80101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aab:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab1:	8d 50 0c             	lea    0xc(%eax),%edx
80101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab7:	83 c0 5c             	add    $0x5c,%eax
80101aba:	83 ec 04             	sub    $0x4,%esp
80101abd:	6a 34                	push   $0x34
80101abf:	52                   	push   %edx
80101ac0:	50                   	push   %eax
80101ac1:	e8 5e 33 00 00       	call   80104e24 <memmove>
80101ac6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ac9:	83 ec 0c             	sub    $0xc,%esp
80101acc:	ff 75 f4             	push   -0xc(%ebp)
80101acf:	e8 af e7 ff ff       	call   80100283 <brelse>
80101ad4:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ae8:	66 85 c0             	test   %ax,%ax
80101aeb:	75 0d                	jne    80101afa <ilock+0x110>
      panic("ilock: no type");
80101aed:	83 ec 0c             	sub    $0xc,%esp
80101af0:	68 73 a7 10 80       	push   $0x8010a773
80101af5:	e8 af ea ff ff       	call   801005a9 <panic>
  }
}
80101afa:	90                   	nop
80101afb:	c9                   	leave  
80101afc:	c3                   	ret    

80101afd <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101afd:	55                   	push   %ebp
80101afe:	89 e5                	mov    %esp,%ebp
80101b00:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b07:	74 20                	je     80101b29 <iunlock+0x2c>
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	83 c0 0c             	add    $0xc,%eax
80101b0f:	83 ec 0c             	sub    $0xc,%esp
80101b12:	50                   	push   %eax
80101b13:	e8 46 2f 00 00       	call   80104a5e <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 82 a7 10 80       	push   $0x8010a782
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 cb 2e 00 00       	call   80104a10 <releasesleep>
80101b45:	83 c4 10             	add    $0x10,%esp
}
80101b48:	90                   	nop
80101b49:	c9                   	leave  
80101b4a:	c3                   	ret    

80101b4b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b4b:	55                   	push   %ebp
80101b4c:	89 e5                	mov    %esp,%ebp
80101b4e:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	83 c0 0c             	add    $0xc,%eax
80101b57:	83 ec 0c             	sub    $0xc,%esp
80101b5a:	50                   	push   %eax
80101b5b:	e8 4c 2e 00 00       	call   801049ac <acquiresleep>
80101b60:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b69:	85 c0                	test   %eax,%eax
80101b6b:	74 6a                	je     80101bd7 <iput+0x8c>
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b74:	66 85 c0             	test   %ax,%ax
80101b77:	75 5e                	jne    80101bd7 <iput+0x8c>
    acquire(&icache.lock);
80101b79:	83 ec 0c             	sub    $0xc,%esp
80101b7c:	68 60 24 19 80       	push   $0x80192460
80101b81:	e8 69 2f 00 00       	call   80104aef <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 24 19 80       	push   $0x80192460
80101b9a:	e8 be 2f 00 00       	call   80104b5d <release>
80101b9f:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ba2:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ba6:	75 2f                	jne    80101bd7 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ba8:	83 ec 0c             	sub    $0xc,%esp
80101bab:	ff 75 08             	push   0x8(%ebp)
80101bae:	e8 ad 01 00 00       	call   80101d60 <itrunc>
80101bb3:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb9:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bbf:	83 ec 0c             	sub    $0xc,%esp
80101bc2:	ff 75 08             	push   0x8(%ebp)
80101bc5:	e8 43 fc ff ff       	call   8010180d <iupdate>
80101bca:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd0:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bda:	83 c0 0c             	add    $0xc,%eax
80101bdd:	83 ec 0c             	sub    $0xc,%esp
80101be0:	50                   	push   %eax
80101be1:	e8 2a 2e 00 00       	call   80104a10 <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 24 19 80       	push   $0x80192460
80101bf1:	e8 f9 2e 00 00       	call   80104aef <acquire>
80101bf6:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 40 08             	mov    0x8(%eax),%eax
80101bff:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c08:	83 ec 0c             	sub    $0xc,%esp
80101c0b:	68 60 24 19 80       	push   $0x80192460
80101c10:	e8 48 2f 00 00       	call   80104b5d <release>
80101c15:	83 c4 10             	add    $0x10,%esp
}
80101c18:	90                   	nop
80101c19:	c9                   	leave  
80101c1a:	c3                   	ret    

80101c1b <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c1b:	55                   	push   %ebp
80101c1c:	89 e5                	mov    %esp,%ebp
80101c1e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c21:	83 ec 0c             	sub    $0xc,%esp
80101c24:	ff 75 08             	push   0x8(%ebp)
80101c27:	e8 d1 fe ff ff       	call   80101afd <iunlock>
80101c2c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c2f:	83 ec 0c             	sub    $0xc,%esp
80101c32:	ff 75 08             	push   0x8(%ebp)
80101c35:	e8 11 ff ff ff       	call   80101b4b <iput>
80101c3a:	83 c4 10             	add    $0x10,%esp
}
80101c3d:	90                   	nop
80101c3e:	c9                   	leave  
80101c3f:	c3                   	ret    

80101c40 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c40:	55                   	push   %ebp
80101c41:	89 e5                	mov    %esp,%ebp
80101c43:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c46:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c4a:	77 42                	ja     80101c8e <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c52:	83 c2 14             	add    $0x14,%edx
80101c55:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c60:	75 24                	jne    80101c86 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c62:	8b 45 08             	mov    0x8(%ebp),%eax
80101c65:	8b 00                	mov    (%eax),%eax
80101c67:	83 ec 0c             	sub    $0xc,%esp
80101c6a:	50                   	push   %eax
80101c6b:	e8 f4 f7 ff ff       	call   80101464 <balloc>
80101c70:	83 c4 10             	add    $0x10,%esp
80101c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c7c:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c82:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c89:	e9 d0 00 00 00       	jmp    80101d5e <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c8e:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c92:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c96:	0f 87 b5 00 00 00    	ja     80101d51 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cac:	75 20                	jne    80101cce <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	8b 00                	mov    (%eax),%eax
80101cb3:	83 ec 0c             	sub    $0xc,%esp
80101cb6:	50                   	push   %eax
80101cb7:	e8 a8 f7 ff ff       	call   80101464 <balloc>
80101cbc:	83 c4 10             	add    $0x10,%esp
80101cbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc8:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	8b 00                	mov    (%eax),%eax
80101cd3:	83 ec 08             	sub    $0x8,%esp
80101cd6:	ff 75 f4             	push   -0xc(%ebp)
80101cd9:	50                   	push   %eax
80101cda:	e8 22 e5 ff ff       	call   80100201 <bread>
80101cdf:	83 c4 10             	add    $0x10,%esp
80101ce2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce8:	83 c0 5c             	add    $0x5c,%eax
80101ceb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cfb:	01 d0                	add    %edx,%eax
80101cfd:	8b 00                	mov    (%eax),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 36                	jne    80101d3e <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 4e f7 ff ff       	call   80101464 <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d29:	01 c2                	add    %eax,%edx
80101d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2e:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d30:	83 ec 0c             	sub    $0xc,%esp
80101d33:	ff 75 f0             	push   -0x10(%ebp)
80101d36:	e8 3a 15 00 00       	call   80103275 <log_write>
80101d3b:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d3e:	83 ec 0c             	sub    $0xc,%esp
80101d41:	ff 75 f0             	push   -0x10(%ebp)
80101d44:	e8 3a e5 ff ff       	call   80100283 <brelse>
80101d49:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d4f:	eb 0d                	jmp    80101d5e <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d51:	83 ec 0c             	sub    $0xc,%esp
80101d54:	68 8a a7 10 80       	push   $0x8010a78a
80101d59:	e8 4b e8 ff ff       	call   801005a9 <panic>
}
80101d5e:	c9                   	leave  
80101d5f:	c3                   	ret    

80101d60 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d60:	55                   	push   %ebp
80101d61:	89 e5                	mov    %esp,%ebp
80101d63:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d6d:	eb 45                	jmp    80101db4 <itrunc+0x54>
    if(ip->addrs[i]){
80101d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d75:	83 c2 14             	add    $0x14,%edx
80101d78:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d7c:	85 c0                	test   %eax,%eax
80101d7e:	74 30                	je     80101db0 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d86:	83 c2 14             	add    $0x14,%edx
80101d89:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8d:	8b 55 08             	mov    0x8(%ebp),%edx
80101d90:	8b 12                	mov    (%edx),%edx
80101d92:	83 ec 08             	sub    $0x8,%esp
80101d95:	50                   	push   %eax
80101d96:	52                   	push   %edx
80101d97:	e8 0c f8 ff ff       	call   801015a8 <bfree>
80101d9c:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da5:	83 c2 14             	add    $0x14,%edx
80101da8:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101daf:	00 
  for(i = 0; i < NDIRECT; i++){
80101db0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101db4:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101db8:	7e b5                	jle    80101d6f <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dba:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbd:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dc3:	85 c0                	test   %eax,%eax
80101dc5:	0f 84 aa 00 00 00    	je     80101e75 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd7:	8b 00                	mov    (%eax),%eax
80101dd9:	83 ec 08             	sub    $0x8,%esp
80101ddc:	52                   	push   %edx
80101ddd:	50                   	push   %eax
80101dde:	e8 1e e4 ff ff       	call   80100201 <bread>
80101de3:	83 c4 10             	add    $0x10,%esp
80101de6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dec:	83 c0 5c             	add    $0x5c,%eax
80101def:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101df2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101df9:	eb 3c                	jmp    80101e37 <itrunc+0xd7>
      if(a[j])
80101dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e08:	01 d0                	add    %edx,%eax
80101e0a:	8b 00                	mov    (%eax),%eax
80101e0c:	85 c0                	test   %eax,%eax
80101e0e:	74 23                	je     80101e33 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e1d:	01 d0                	add    %edx,%eax
80101e1f:	8b 00                	mov    (%eax),%eax
80101e21:	8b 55 08             	mov    0x8(%ebp),%edx
80101e24:	8b 12                	mov    (%edx),%edx
80101e26:	83 ec 08             	sub    $0x8,%esp
80101e29:	50                   	push   %eax
80101e2a:	52                   	push   %edx
80101e2b:	e8 78 f7 ff ff       	call   801015a8 <bfree>
80101e30:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e33:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e3a:	83 f8 7f             	cmp    $0x7f,%eax
80101e3d:	76 bc                	jbe    80101dfb <itrunc+0x9b>
    }
    brelse(bp);
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	ff 75 ec             	push   -0x14(%ebp)
80101e45:	e8 39 e4 ff ff       	call   80100283 <brelse>
80101e4a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e50:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e56:	8b 55 08             	mov    0x8(%ebp),%edx
80101e59:	8b 12                	mov    (%edx),%edx
80101e5b:	83 ec 08             	sub    $0x8,%esp
80101e5e:	50                   	push   %eax
80101e5f:	52                   	push   %edx
80101e60:	e8 43 f7 ff ff       	call   801015a8 <bfree>
80101e65:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e68:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6b:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e72:	00 00 00 
  }

  ip->size = 0;
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e7f:	83 ec 0c             	sub    $0xc,%esp
80101e82:	ff 75 08             	push   0x8(%ebp)
80101e85:	e8 83 f9 ff ff       	call   8010180d <iupdate>
80101e8a:	83 c4 10             	add    $0x10,%esp
}
80101e8d:	90                   	nop
80101e8e:	c9                   	leave  
80101e8f:	c3                   	ret    

80101e90 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e90:	55                   	push   %ebp
80101e91:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	8b 00                	mov    (%eax),%eax
80101e98:	89 c2                	mov    %eax,%edx
80101e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9d:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea3:	8b 50 04             	mov    0x4(%eax),%edx
80101ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea9:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eac:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaf:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec3:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eca:	8b 50 58             	mov    0x58(%eax),%edx
80101ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed0:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed3:	90                   	nop
80101ed4:	5d                   	pop    %ebp
80101ed5:	c3                   	ret    

80101ed6 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed6:	55                   	push   %ebp
80101ed7:	89 e5                	mov    %esp,%ebp
80101ed9:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ee3:	66 83 f8 03          	cmp    $0x3,%ax
80101ee7:	75 5c                	jne    80101f45 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef0:	66 85 c0             	test   %ax,%ax
80101ef3:	78 20                	js     80101f15 <readi+0x3f>
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efc:	66 83 f8 09          	cmp    $0x9,%ax
80101f00:	7f 13                	jg     80101f15 <readi+0x3f>
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f09:	98                   	cwtl   
80101f0a:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <readi+0x49>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 0a 01 00 00       	jmp    80102029 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f2e:	8b 55 14             	mov    0x14(%ebp),%edx
80101f31:	83 ec 04             	sub    $0x4,%esp
80101f34:	52                   	push   %edx
80101f35:	ff 75 0c             	push   0xc(%ebp)
80101f38:	ff 75 08             	push   0x8(%ebp)
80101f3b:	ff d0                	call   *%eax
80101f3d:	83 c4 10             	add    $0x10,%esp
80101f40:	e9 e4 00 00 00       	jmp    80102029 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 40 58             	mov    0x58(%eax),%eax
80101f4b:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f4e:	77 0d                	ja     80101f5d <readi+0x87>
80101f50:	8b 55 10             	mov    0x10(%ebp),%edx
80101f53:	8b 45 14             	mov    0x14(%ebp),%eax
80101f56:	01 d0                	add    %edx,%eax
80101f58:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f5b:	76 0a                	jbe    80101f67 <readi+0x91>
    return -1;
80101f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f62:	e9 c2 00 00 00       	jmp    80102029 <readi+0x153>
  if(off + n > ip->size)
80101f67:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6d:	01 c2                	add    %eax,%edx
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 40 58             	mov    0x58(%eax),%eax
80101f75:	39 c2                	cmp    %eax,%edx
80101f77:	76 0c                	jbe    80101f85 <readi+0xaf>
    n = ip->size - off;
80101f79:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7c:	8b 40 58             	mov    0x58(%eax),%eax
80101f7f:	2b 45 10             	sub    0x10(%ebp),%eax
80101f82:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8c:	e9 89 00 00 00       	jmp    8010201a <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f91:	8b 45 10             	mov    0x10(%ebp),%eax
80101f94:	c1 e8 09             	shr    $0x9,%eax
80101f97:	83 ec 08             	sub    $0x8,%esp
80101f9a:	50                   	push   %eax
80101f9b:	ff 75 08             	push   0x8(%ebp)
80101f9e:	e8 9d fc ff ff       	call   80101c40 <bmap>
80101fa3:	83 c4 10             	add    $0x10,%esp
80101fa6:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa9:	8b 12                	mov    (%edx),%edx
80101fab:	83 ec 08             	sub    $0x8,%esp
80101fae:	50                   	push   %eax
80101faf:	52                   	push   %edx
80101fb0:	e8 4c e2 ff ff       	call   80100201 <bread>
80101fb5:	83 c4 10             	add    $0x10,%esp
80101fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbb:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbe:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc3:	ba 00 02 00 00       	mov    $0x200,%edx
80101fc8:	29 c2                	sub    %eax,%edx
80101fca:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd0:	39 c2                	cmp    %eax,%edx
80101fd2:	0f 46 c2             	cmovbe %edx,%eax
80101fd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdb:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fde:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe1:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe6:	01 d0                	add    %edx,%eax
80101fe8:	83 ec 04             	sub    $0x4,%esp
80101feb:	ff 75 ec             	push   -0x14(%ebp)
80101fee:	50                   	push   %eax
80101fef:	ff 75 0c             	push   0xc(%ebp)
80101ff2:	e8 2d 2e 00 00       	call   80104e24 <memmove>
80101ff7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffa:	83 ec 0c             	sub    $0xc,%esp
80101ffd:	ff 75 f0             	push   -0x10(%ebp)
80102000:	e8 7e e2 ff ff       	call   80100283 <brelse>
80102005:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102008:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010200e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102011:	01 45 10             	add    %eax,0x10(%ebp)
80102014:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102017:	01 45 0c             	add    %eax,0xc(%ebp)
8010201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102020:	0f 82 6b ff ff ff    	jb     80101f91 <readi+0xbb>
  }
  return n;
80102026:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102029:	c9                   	leave  
8010202a:	c3                   	ret    

8010202b <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202b:	55                   	push   %ebp
8010202c:	89 e5                	mov    %esp,%ebp
8010202e:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102031:	8b 45 08             	mov    0x8(%ebp),%eax
80102034:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102038:	66 83 f8 03          	cmp    $0x3,%ax
8010203c:	75 5c                	jne    8010209a <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010203e:	8b 45 08             	mov    0x8(%ebp),%eax
80102041:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102045:	66 85 c0             	test   %ax,%ax
80102048:	78 20                	js     8010206a <writei+0x3f>
8010204a:	8b 45 08             	mov    0x8(%ebp),%eax
8010204d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102051:	66 83 f8 09          	cmp    $0x9,%ax
80102055:	7f 13                	jg     8010206a <writei+0x3f>
80102057:	8b 45 08             	mov    0x8(%ebp),%eax
8010205a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205e:	98                   	cwtl   
8010205f:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102066:	85 c0                	test   %eax,%eax
80102068:	75 0a                	jne    80102074 <writei+0x49>
      return -1;
8010206a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206f:	e9 3b 01 00 00       	jmp    801021af <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207b:	98                   	cwtl   
8010207c:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102083:	8b 55 14             	mov    0x14(%ebp),%edx
80102086:	83 ec 04             	sub    $0x4,%esp
80102089:	52                   	push   %edx
8010208a:	ff 75 0c             	push   0xc(%ebp)
8010208d:	ff 75 08             	push   0x8(%ebp)
80102090:	ff d0                	call   *%eax
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	e9 15 01 00 00       	jmp    801021af <writei+0x184>
  }

  if(off > ip->size || off + n < off)
8010209a:	8b 45 08             	mov    0x8(%ebp),%eax
8010209d:	8b 40 58             	mov    0x58(%eax),%eax
801020a0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a3:	77 0d                	ja     801020b2 <writei+0x87>
801020a5:	8b 55 10             	mov    0x10(%ebp),%edx
801020a8:	8b 45 14             	mov    0x14(%ebp),%eax
801020ab:	01 d0                	add    %edx,%eax
801020ad:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b0:	76 0a                	jbe    801020bc <writei+0x91>
    return -1;
801020b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b7:	e9 f3 00 00 00       	jmp    801021af <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020bc:	8b 55 10             	mov    0x10(%ebp),%edx
801020bf:	8b 45 14             	mov    0x14(%ebp),%eax
801020c2:	01 d0                	add    %edx,%eax
801020c4:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020c9:	76 0a                	jbe    801020d5 <writei+0xaa>
    return -1;
801020cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d0:	e9 da 00 00 00       	jmp    801021af <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dc:	e9 97 00 00 00       	jmp    80102178 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e1:	8b 45 10             	mov    0x10(%ebp),%eax
801020e4:	c1 e8 09             	shr    $0x9,%eax
801020e7:	83 ec 08             	sub    $0x8,%esp
801020ea:	50                   	push   %eax
801020eb:	ff 75 08             	push   0x8(%ebp)
801020ee:	e8 4d fb ff ff       	call   80101c40 <bmap>
801020f3:	83 c4 10             	add    $0x10,%esp
801020f6:	8b 55 08             	mov    0x8(%ebp),%edx
801020f9:	8b 12                	mov    (%edx),%edx
801020fb:	83 ec 08             	sub    $0x8,%esp
801020fe:	50                   	push   %eax
801020ff:	52                   	push   %edx
80102100:	e8 fc e0 ff ff       	call   80100201 <bread>
80102105:	83 c4 10             	add    $0x10,%esp
80102108:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210b:	8b 45 10             	mov    0x10(%ebp),%eax
8010210e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102113:	ba 00 02 00 00       	mov    $0x200,%edx
80102118:	29 c2                	sub    %eax,%edx
8010211a:	8b 45 14             	mov    0x14(%ebp),%eax
8010211d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102120:	39 c2                	cmp    %eax,%edx
80102122:	0f 46 c2             	cmovbe %edx,%eax
80102125:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010212b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010212e:	8b 45 10             	mov    0x10(%ebp),%eax
80102131:	25 ff 01 00 00       	and    $0x1ff,%eax
80102136:	01 d0                	add    %edx,%eax
80102138:	83 ec 04             	sub    $0x4,%esp
8010213b:	ff 75 ec             	push   -0x14(%ebp)
8010213e:	ff 75 0c             	push   0xc(%ebp)
80102141:	50                   	push   %eax
80102142:	e8 dd 2c 00 00       	call   80104e24 <memmove>
80102147:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214a:	83 ec 0c             	sub    $0xc,%esp
8010214d:	ff 75 f0             	push   -0x10(%ebp)
80102150:	e8 20 11 00 00       	call   80103275 <log_write>
80102155:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102158:	83 ec 0c             	sub    $0xc,%esp
8010215b:	ff 75 f0             	push   -0x10(%ebp)
8010215e:	e8 20 e1 ff ff       	call   80100283 <brelse>
80102163:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102166:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102169:	01 45 f4             	add    %eax,-0xc(%ebp)
8010216c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216f:	01 45 10             	add    %eax,0x10(%ebp)
80102172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102175:	01 45 0c             	add    %eax,0xc(%ebp)
80102178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010217e:	0f 82 5d ff ff ff    	jb     801020e1 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102184:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102188:	74 22                	je     801021ac <writei+0x181>
8010218a:	8b 45 08             	mov    0x8(%ebp),%eax
8010218d:	8b 40 58             	mov    0x58(%eax),%eax
80102190:	39 45 10             	cmp    %eax,0x10(%ebp)
80102193:	76 17                	jbe    801021ac <writei+0x181>
    ip->size = off;
80102195:	8b 45 08             	mov    0x8(%ebp),%eax
80102198:	8b 55 10             	mov    0x10(%ebp),%edx
8010219b:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010219e:	83 ec 0c             	sub    $0xc,%esp
801021a1:	ff 75 08             	push   0x8(%ebp)
801021a4:	e8 64 f6 ff ff       	call   8010180d <iupdate>
801021a9:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021ac:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021af:	c9                   	leave  
801021b0:	c3                   	ret    

801021b1 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b1:	55                   	push   %ebp
801021b2:	89 e5                	mov    %esp,%ebp
801021b4:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021b7:	83 ec 04             	sub    $0x4,%esp
801021ba:	6a 0e                	push   $0xe
801021bc:	ff 75 0c             	push   0xc(%ebp)
801021bf:	ff 75 08             	push   0x8(%ebp)
801021c2:	e8 f3 2c 00 00       	call   80104eba <strncmp>
801021c7:	83 c4 10             	add    $0x10,%esp
}
801021ca:	c9                   	leave  
801021cb:	c3                   	ret    

801021cc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021cc:	55                   	push   %ebp
801021cd:	89 e5                	mov    %esp,%ebp
801021cf:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d2:	8b 45 08             	mov    0x8(%ebp),%eax
801021d5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021d9:	66 83 f8 01          	cmp    $0x1,%ax
801021dd:	74 0d                	je     801021ec <dirlookup+0x20>
    panic("dirlookup not DIR");
801021df:	83 ec 0c             	sub    $0xc,%esp
801021e2:	68 9d a7 10 80       	push   $0x8010a79d
801021e7:	e8 bd e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f3:	eb 7b                	jmp    80102270 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f5:	6a 10                	push   $0x10
801021f7:	ff 75 f4             	push   -0xc(%ebp)
801021fa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021fd:	50                   	push   %eax
801021fe:	ff 75 08             	push   0x8(%ebp)
80102201:	e8 d0 fc ff ff       	call   80101ed6 <readi>
80102206:	83 c4 10             	add    $0x10,%esp
80102209:	83 f8 10             	cmp    $0x10,%eax
8010220c:	74 0d                	je     8010221b <dirlookup+0x4f>
      panic("dirlookup read");
8010220e:	83 ec 0c             	sub    $0xc,%esp
80102211:	68 af a7 10 80       	push   $0x8010a7af
80102216:	e8 8e e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
8010221b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010221f:	66 85 c0             	test   %ax,%ax
80102222:	74 47                	je     8010226b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102224:	83 ec 08             	sub    $0x8,%esp
80102227:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222a:	83 c0 02             	add    $0x2,%eax
8010222d:	50                   	push   %eax
8010222e:	ff 75 0c             	push   0xc(%ebp)
80102231:	e8 7b ff ff ff       	call   801021b1 <namecmp>
80102236:	83 c4 10             	add    $0x10,%esp
80102239:	85 c0                	test   %eax,%eax
8010223b:	75 2f                	jne    8010226c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010223d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102241:	74 08                	je     8010224b <dirlookup+0x7f>
        *poff = off;
80102243:	8b 45 10             	mov    0x10(%ebp),%eax
80102246:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102249:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010224b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010224f:	0f b7 c0             	movzwl %ax,%eax
80102252:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102255:	8b 45 08             	mov    0x8(%ebp),%eax
80102258:	8b 00                	mov    (%eax),%eax
8010225a:	83 ec 08             	sub    $0x8,%esp
8010225d:	ff 75 f0             	push   -0x10(%ebp)
80102260:	50                   	push   %eax
80102261:	e8 68 f6 ff ff       	call   801018ce <iget>
80102266:	83 c4 10             	add    $0x10,%esp
80102269:	eb 19                	jmp    80102284 <dirlookup+0xb8>
      continue;
8010226b:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102270:	8b 45 08             	mov    0x8(%ebp),%eax
80102273:	8b 40 58             	mov    0x58(%eax),%eax
80102276:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102279:	0f 82 76 ff ff ff    	jb     801021f5 <dirlookup+0x29>
    }
  }

  return 0;
8010227f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102286:	55                   	push   %ebp
80102287:	89 e5                	mov    %esp,%ebp
80102289:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010228c:	83 ec 04             	sub    $0x4,%esp
8010228f:	6a 00                	push   $0x0
80102291:	ff 75 0c             	push   0xc(%ebp)
80102294:	ff 75 08             	push   0x8(%ebp)
80102297:	e8 30 ff ff ff       	call   801021cc <dirlookup>
8010229c:	83 c4 10             	add    $0x10,%esp
8010229f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022a6:	74 18                	je     801022c0 <dirlink+0x3a>
    iput(ip);
801022a8:	83 ec 0c             	sub    $0xc,%esp
801022ab:	ff 75 f0             	push   -0x10(%ebp)
801022ae:	e8 98 f8 ff ff       	call   80101b4b <iput>
801022b3:	83 c4 10             	add    $0x10,%esp
    return -1;
801022b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022bb:	e9 9c 00 00 00       	jmp    8010235c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c7:	eb 39                	jmp    80102302 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cc:	6a 10                	push   $0x10
801022ce:	50                   	push   %eax
801022cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d2:	50                   	push   %eax
801022d3:	ff 75 08             	push   0x8(%ebp)
801022d6:	e8 fb fb ff ff       	call   80101ed6 <readi>
801022db:	83 c4 10             	add    $0x10,%esp
801022de:	83 f8 10             	cmp    $0x10,%eax
801022e1:	74 0d                	je     801022f0 <dirlink+0x6a>
      panic("dirlink read");
801022e3:	83 ec 0c             	sub    $0xc,%esp
801022e6:	68 be a7 10 80       	push   $0x8010a7be
801022eb:	e8 b9 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f0:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f4:	66 85 c0             	test   %ax,%ax
801022f7:	74 18                	je     80102311 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fc:	83 c0 10             	add    $0x10,%eax
801022ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102302:	8b 45 08             	mov    0x8(%ebp),%eax
80102305:	8b 50 58             	mov    0x58(%eax),%edx
80102308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230b:	39 c2                	cmp    %eax,%edx
8010230d:	77 ba                	ja     801022c9 <dirlink+0x43>
8010230f:	eb 01                	jmp    80102312 <dirlink+0x8c>
      break;
80102311:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102312:	83 ec 04             	sub    $0x4,%esp
80102315:	6a 0e                	push   $0xe
80102317:	ff 75 0c             	push   0xc(%ebp)
8010231a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010231d:	83 c0 02             	add    $0x2,%eax
80102320:	50                   	push   %eax
80102321:	e8 ea 2b 00 00       	call   80104f10 <strncpy>
80102326:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102329:	8b 45 10             	mov    0x10(%ebp),%eax
8010232c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102333:	6a 10                	push   $0x10
80102335:	50                   	push   %eax
80102336:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102339:	50                   	push   %eax
8010233a:	ff 75 08             	push   0x8(%ebp)
8010233d:	e8 e9 fc ff ff       	call   8010202b <writei>
80102342:	83 c4 10             	add    $0x10,%esp
80102345:	83 f8 10             	cmp    $0x10,%eax
80102348:	74 0d                	je     80102357 <dirlink+0xd1>
    panic("dirlink");
8010234a:	83 ec 0c             	sub    $0xc,%esp
8010234d:	68 cb a7 10 80       	push   $0x8010a7cb
80102352:	e8 52 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102357:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010235c:	c9                   	leave  
8010235d:	c3                   	ret    

8010235e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010235e:	55                   	push   %ebp
8010235f:	89 e5                	mov    %esp,%ebp
80102361:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102364:	eb 04                	jmp    8010236a <skipelem+0xc>
    path++;
80102366:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010236a:	8b 45 08             	mov    0x8(%ebp),%eax
8010236d:	0f b6 00             	movzbl (%eax),%eax
80102370:	3c 2f                	cmp    $0x2f,%al
80102372:	74 f2                	je     80102366 <skipelem+0x8>
  if(*path == 0)
80102374:	8b 45 08             	mov    0x8(%ebp),%eax
80102377:	0f b6 00             	movzbl (%eax),%eax
8010237a:	84 c0                	test   %al,%al
8010237c:	75 07                	jne    80102385 <skipelem+0x27>
    return 0;
8010237e:	b8 00 00 00 00       	mov    $0x0,%eax
80102383:	eb 77                	jmp    801023fc <skipelem+0x9e>
  s = path;
80102385:	8b 45 08             	mov    0x8(%ebp),%eax
80102388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010238b:	eb 04                	jmp    80102391 <skipelem+0x33>
    path++;
8010238d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102391:	8b 45 08             	mov    0x8(%ebp),%eax
80102394:	0f b6 00             	movzbl (%eax),%eax
80102397:	3c 2f                	cmp    $0x2f,%al
80102399:	74 0a                	je     801023a5 <skipelem+0x47>
8010239b:	8b 45 08             	mov    0x8(%ebp),%eax
8010239e:	0f b6 00             	movzbl (%eax),%eax
801023a1:	84 c0                	test   %al,%al
801023a3:	75 e8                	jne    8010238d <skipelem+0x2f>
  len = path - s;
801023a5:	8b 45 08             	mov    0x8(%ebp),%eax
801023a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023b2:	7e 15                	jle    801023c9 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023b4:	83 ec 04             	sub    $0x4,%esp
801023b7:	6a 0e                	push   $0xe
801023b9:	ff 75 f4             	push   -0xc(%ebp)
801023bc:	ff 75 0c             	push   0xc(%ebp)
801023bf:	e8 60 2a 00 00       	call   80104e24 <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 49 2a 00 00       	call   80104e24 <memmove>
801023db:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023de:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e4:	01 d0                	add    %edx,%eax
801023e6:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023e9:	eb 04                	jmp    801023ef <skipelem+0x91>
    path++;
801023eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023ef:	8b 45 08             	mov    0x8(%ebp),%eax
801023f2:	0f b6 00             	movzbl (%eax),%eax
801023f5:	3c 2f                	cmp    $0x2f,%al
801023f7:	74 f2                	je     801023eb <skipelem+0x8d>
  return path;
801023f9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023fc:	c9                   	leave  
801023fd:	c3                   	ret    

801023fe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023fe:	55                   	push   %ebp
801023ff:	89 e5                	mov    %esp,%ebp
80102401:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102404:	8b 45 08             	mov    0x8(%ebp),%eax
80102407:	0f b6 00             	movzbl (%eax),%eax
8010240a:	3c 2f                	cmp    $0x2f,%al
8010240c:	75 17                	jne    80102425 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010240e:	83 ec 08             	sub    $0x8,%esp
80102411:	6a 01                	push   $0x1
80102413:	6a 01                	push   $0x1
80102415:	e8 b4 f4 ff ff       	call   801018ce <iget>
8010241a:	83 c4 10             	add    $0x10,%esp
8010241d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102420:	e9 ba 00 00 00       	jmp    801024df <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102425:	e8 06 16 00 00       	call   80103a30 <myproc>
8010242a:	8b 40 68             	mov    0x68(%eax),%eax
8010242d:	83 ec 0c             	sub    $0xc,%esp
80102430:	50                   	push   %eax
80102431:	e8 7a f5 ff ff       	call   801019b0 <idup>
80102436:	83 c4 10             	add    $0x10,%esp
80102439:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010243c:	e9 9e 00 00 00       	jmp    801024df <namex+0xe1>
    ilock(ip);
80102441:	83 ec 0c             	sub    $0xc,%esp
80102444:	ff 75 f4             	push   -0xc(%ebp)
80102447:	e8 9e f5 ff ff       	call   801019ea <ilock>
8010244c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010244f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102452:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102456:	66 83 f8 01          	cmp    $0x1,%ax
8010245a:	74 18                	je     80102474 <namex+0x76>
      iunlockput(ip);
8010245c:	83 ec 0c             	sub    $0xc,%esp
8010245f:	ff 75 f4             	push   -0xc(%ebp)
80102462:	e8 b4 f7 ff ff       	call   80101c1b <iunlockput>
80102467:	83 c4 10             	add    $0x10,%esp
      return 0;
8010246a:	b8 00 00 00 00       	mov    $0x0,%eax
8010246f:	e9 a7 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102474:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102478:	74 20                	je     8010249a <namex+0x9c>
8010247a:	8b 45 08             	mov    0x8(%ebp),%eax
8010247d:	0f b6 00             	movzbl (%eax),%eax
80102480:	84 c0                	test   %al,%al
80102482:	75 16                	jne    8010249a <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102484:	83 ec 0c             	sub    $0xc,%esp
80102487:	ff 75 f4             	push   -0xc(%ebp)
8010248a:	e8 6e f6 ff ff       	call   80101afd <iunlock>
8010248f:	83 c4 10             	add    $0x10,%esp
      return ip;
80102492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102495:	e9 81 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010249a:	83 ec 04             	sub    $0x4,%esp
8010249d:	6a 00                	push   $0x0
8010249f:	ff 75 10             	push   0x10(%ebp)
801024a2:	ff 75 f4             	push   -0xc(%ebp)
801024a5:	e8 22 fd ff ff       	call   801021cc <dirlookup>
801024aa:	83 c4 10             	add    $0x10,%esp
801024ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024b4:	75 15                	jne    801024cb <namex+0xcd>
      iunlockput(ip);
801024b6:	83 ec 0c             	sub    $0xc,%esp
801024b9:	ff 75 f4             	push   -0xc(%ebp)
801024bc:	e8 5a f7 ff ff       	call   80101c1b <iunlockput>
801024c1:	83 c4 10             	add    $0x10,%esp
      return 0;
801024c4:	b8 00 00 00 00       	mov    $0x0,%eax
801024c9:	eb 50                	jmp    8010251b <namex+0x11d>
    }
    iunlockput(ip);
801024cb:	83 ec 0c             	sub    $0xc,%esp
801024ce:	ff 75 f4             	push   -0xc(%ebp)
801024d1:	e8 45 f7 ff ff       	call   80101c1b <iunlockput>
801024d6:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024df:	83 ec 08             	sub    $0x8,%esp
801024e2:	ff 75 10             	push   0x10(%ebp)
801024e5:	ff 75 08             	push   0x8(%ebp)
801024e8:	e8 71 fe ff ff       	call   8010235e <skipelem>
801024ed:	83 c4 10             	add    $0x10,%esp
801024f0:	89 45 08             	mov    %eax,0x8(%ebp)
801024f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f7:	0f 85 44 ff ff ff    	jne    80102441 <namex+0x43>
  }
  if(nameiparent){
801024fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102501:	74 15                	je     80102518 <namex+0x11a>
    iput(ip);
80102503:	83 ec 0c             	sub    $0xc,%esp
80102506:	ff 75 f4             	push   -0xc(%ebp)
80102509:	e8 3d f6 ff ff       	call   80101b4b <iput>
8010250e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102511:	b8 00 00 00 00       	mov    $0x0,%eax
80102516:	eb 03                	jmp    8010251b <namex+0x11d>
  }
  return ip;
80102518:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010251b:	c9                   	leave  
8010251c:	c3                   	ret    

8010251d <namei>:

struct inode*
namei(char *path)
{
8010251d:	55                   	push   %ebp
8010251e:	89 e5                	mov    %esp,%ebp
80102520:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102523:	83 ec 04             	sub    $0x4,%esp
80102526:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102529:	50                   	push   %eax
8010252a:	6a 00                	push   $0x0
8010252c:	ff 75 08             	push   0x8(%ebp)
8010252f:	e8 ca fe ff ff       	call   801023fe <namex>
80102534:	83 c4 10             	add    $0x10,%esp
}
80102537:	c9                   	leave  
80102538:	c3                   	ret    

80102539 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102539:	55                   	push   %ebp
8010253a:	89 e5                	mov    %esp,%ebp
8010253c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010253f:	83 ec 04             	sub    $0x4,%esp
80102542:	ff 75 0c             	push   0xc(%ebp)
80102545:	6a 01                	push   $0x1
80102547:	ff 75 08             	push   0x8(%ebp)
8010254a:	e8 af fe ff ff       	call   801023fe <namex>
8010254f:	83 c4 10             	add    $0x10,%esp
}
80102552:	c9                   	leave  
80102553:	c3                   	ret    

80102554 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102554:	55                   	push   %ebp
80102555:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102557:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010255c:	8b 55 08             	mov    0x8(%ebp),%edx
8010255f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102561:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102566:	8b 40 10             	mov    0x10(%eax),%eax
}
80102569:	5d                   	pop    %ebp
8010256a:	c3                   	ret    

8010256b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010256b:	55                   	push   %ebp
8010256c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010256e:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102573:	8b 55 08             	mov    0x8(%ebp),%edx
80102576:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102578:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102580:	89 50 10             	mov    %edx,0x10(%eax)
}
80102583:	90                   	nop
80102584:	5d                   	pop    %ebp
80102585:	c3                   	ret    

80102586 <ioapicinit>:

void
ioapicinit(void)
{
80102586:	55                   	push   %ebp
80102587:	89 e5                	mov    %esp,%ebp
80102589:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010258c:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
80102593:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102596:	6a 01                	push   $0x1
80102598:	e8 b7 ff ff ff       	call   80102554 <ioapicread>
8010259d:	83 c4 04             	add    $0x4,%esp
801025a0:	c1 e8 10             	shr    $0x10,%eax
801025a3:	25 ff 00 00 00       	and    $0xff,%eax
801025a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025ab:	6a 00                	push   $0x0
801025ad:	e8 a2 ff ff ff       	call   80102554 <ioapicread>
801025b2:	83 c4 04             	add    $0x4,%esp
801025b5:	c1 e8 18             	shr    $0x18,%eax
801025b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025bb:	0f b6 05 54 77 19 80 	movzbl 0x80197754,%eax
801025c2:	0f b6 c0             	movzbl %al,%eax
801025c5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025c8:	74 10                	je     801025da <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025ca:	83 ec 0c             	sub    $0xc,%esp
801025cd:	68 d4 a7 10 80       	push   $0x8010a7d4
801025d2:	e8 1d de ff ff       	call   801003f4 <cprintf>
801025d7:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e1:	eb 3f                	jmp    80102622 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e6:	83 c0 20             	add    $0x20,%eax
801025e9:	0d 00 00 01 00       	or     $0x10000,%eax
801025ee:	89 c2                	mov    %eax,%edx
801025f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f3:	83 c0 08             	add    $0x8,%eax
801025f6:	01 c0                	add    %eax,%eax
801025f8:	83 ec 08             	sub    $0x8,%esp
801025fb:	52                   	push   %edx
801025fc:	50                   	push   %eax
801025fd:	e8 69 ff ff ff       	call   8010256b <ioapicwrite>
80102602:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102608:	83 c0 08             	add    $0x8,%eax
8010260b:	01 c0                	add    %eax,%eax
8010260d:	83 c0 01             	add    $0x1,%eax
80102610:	83 ec 08             	sub    $0x8,%esp
80102613:	6a 00                	push   $0x0
80102615:	50                   	push   %eax
80102616:	e8 50 ff ff ff       	call   8010256b <ioapicwrite>
8010261b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010261e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102625:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102628:	7e b9                	jle    801025e3 <ioapicinit+0x5d>
  }
}
8010262a:	90                   	nop
8010262b:	90                   	nop
8010262c:	c9                   	leave  
8010262d:	c3                   	ret    

8010262e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010262e:	55                   	push   %ebp
8010262f:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102631:	8b 45 08             	mov    0x8(%ebp),%eax
80102634:	83 c0 20             	add    $0x20,%eax
80102637:	89 c2                	mov    %eax,%edx
80102639:	8b 45 08             	mov    0x8(%ebp),%eax
8010263c:	83 c0 08             	add    $0x8,%eax
8010263f:	01 c0                	add    %eax,%eax
80102641:	52                   	push   %edx
80102642:	50                   	push   %eax
80102643:	e8 23 ff ff ff       	call   8010256b <ioapicwrite>
80102648:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010264b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010264e:	c1 e0 18             	shl    $0x18,%eax
80102651:	89 c2                	mov    %eax,%edx
80102653:	8b 45 08             	mov    0x8(%ebp),%eax
80102656:	83 c0 08             	add    $0x8,%eax
80102659:	01 c0                	add    %eax,%eax
8010265b:	83 c0 01             	add    $0x1,%eax
8010265e:	52                   	push   %edx
8010265f:	50                   	push   %eax
80102660:	e8 06 ff ff ff       	call   8010256b <ioapicwrite>
80102665:	83 c4 08             	add    $0x8,%esp
}
80102668:	90                   	nop
80102669:	c9                   	leave  
8010266a:	c3                   	ret    

8010266b <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010266b:	55                   	push   %ebp
8010266c:	89 e5                	mov    %esp,%ebp
8010266e:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102671:	83 ec 08             	sub    $0x8,%esp
80102674:	68 06 a8 10 80       	push   $0x8010a806
80102679:	68 c0 40 19 80       	push   $0x801940c0
8010267e:	e8 4a 24 00 00       	call   80104acd <initlock>
80102683:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102686:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
8010268d:	00 00 00 
  freerange(vstart, vend);
80102690:	83 ec 08             	sub    $0x8,%esp
80102693:	ff 75 0c             	push   0xc(%ebp)
80102696:	ff 75 08             	push   0x8(%ebp)
80102699:	e8 2a 00 00 00       	call   801026c8 <freerange>
8010269e:	83 c4 10             	add    $0x10,%esp
}
801026a1:	90                   	nop
801026a2:	c9                   	leave  
801026a3:	c3                   	ret    

801026a4 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026a4:	55                   	push   %ebp
801026a5:	89 e5                	mov    %esp,%ebp
801026a7:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026aa:	83 ec 08             	sub    $0x8,%esp
801026ad:	ff 75 0c             	push   0xc(%ebp)
801026b0:	ff 75 08             	push   0x8(%ebp)
801026b3:	e8 10 00 00 00       	call   801026c8 <freerange>
801026b8:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026bb:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026c2:	00 00 00 
}
801026c5:	90                   	nop
801026c6:	c9                   	leave  
801026c7:	c3                   	ret    

801026c8 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026c8:	55                   	push   %ebp
801026c9:	89 e5                	mov    %esp,%ebp
801026cb:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026ce:	8b 45 08             	mov    0x8(%ebp),%eax
801026d1:	05 ff 0f 00 00       	add    $0xfff,%eax
801026d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026de:	eb 15                	jmp    801026f5 <freerange+0x2d>
    kfree(p);
801026e0:	83 ec 0c             	sub    $0xc,%esp
801026e3:	ff 75 f4             	push   -0xc(%ebp)
801026e6:	e8 1b 00 00 00       	call   80102706 <kfree>
801026eb:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026ee:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f8:	05 00 10 00 00       	add    $0x1000,%eax
801026fd:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102700:	73 de                	jae    801026e0 <freerange+0x18>
}
80102702:	90                   	nop
80102703:	90                   	nop
80102704:	c9                   	leave  
80102705:	c3                   	ret    

80102706 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102706:	55                   	push   %ebp
80102707:	89 e5                	mov    %esp,%ebp
80102709:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010270c:	8b 45 08             	mov    0x8(%ebp),%eax
8010270f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102714:	85 c0                	test   %eax,%eax
80102716:	75 18                	jne    80102730 <kfree+0x2a>
80102718:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
8010271f:	72 0f                	jb     80102730 <kfree+0x2a>
80102721:	8b 45 08             	mov    0x8(%ebp),%eax
80102724:	05 00 00 00 80       	add    $0x80000000,%eax
80102729:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010272e:	76 0d                	jbe    8010273d <kfree+0x37>
    panic("kfree");
80102730:	83 ec 0c             	sub    $0xc,%esp
80102733:	68 0b a8 10 80       	push   $0x8010a80b
80102738:	e8 6c de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273d:	83 ec 04             	sub    $0x4,%esp
80102740:	68 00 10 00 00       	push   $0x1000
80102745:	6a 01                	push   $0x1
80102747:	ff 75 08             	push   0x8(%ebp)
8010274a:	e8 16 26 00 00       	call   80104d65 <memset>
8010274f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102752:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102757:	85 c0                	test   %eax,%eax
80102759:	74 10                	je     8010276b <kfree+0x65>
    acquire(&kmem.lock);
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 c0 40 19 80       	push   $0x801940c0
80102763:	e8 87 23 00 00       	call   80104aef <acquire>
80102768:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010276b:	8b 45 08             	mov    0x8(%ebp),%eax
8010276e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102771:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
80102777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277a:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010277c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277f:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
80102784:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102789:	85 c0                	test   %eax,%eax
8010278b:	74 10                	je     8010279d <kfree+0x97>
    release(&kmem.lock);
8010278d:	83 ec 0c             	sub    $0xc,%esp
80102790:	68 c0 40 19 80       	push   $0x801940c0
80102795:	e8 c3 23 00 00       	call   80104b5d <release>
8010279a:	83 c4 10             	add    $0x10,%esp
}
8010279d:	90                   	nop
8010279e:	c9                   	leave  
8010279f:	c3                   	ret    

801027a0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027a0:	55                   	push   %ebp
801027a1:	89 e5                	mov    %esp,%ebp
801027a3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027a6:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027ab:	85 c0                	test   %eax,%eax
801027ad:	74 10                	je     801027bf <kalloc+0x1f>
    acquire(&kmem.lock);
801027af:	83 ec 0c             	sub    $0xc,%esp
801027b2:	68 c0 40 19 80       	push   $0x801940c0
801027b7:	e8 33 23 00 00       	call   80104aef <acquire>
801027bc:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027bf:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027cb:	74 0a                	je     801027d7 <kalloc+0x37>
    kmem.freelist = r->next;
801027cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d0:	8b 00                	mov    (%eax),%eax
801027d2:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027d7:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027dc:	85 c0                	test   %eax,%eax
801027de:	74 10                	je     801027f0 <kalloc+0x50>
    release(&kmem.lock);
801027e0:	83 ec 0c             	sub    $0xc,%esp
801027e3:	68 c0 40 19 80       	push   $0x801940c0
801027e8:	e8 70 23 00 00       	call   80104b5d <release>
801027ed:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027f3:	c9                   	leave  
801027f4:	c3                   	ret    

801027f5 <inb>:
{
801027f5:	55                   	push   %ebp
801027f6:	89 e5                	mov    %esp,%ebp
801027f8:	83 ec 14             	sub    $0x14,%esp
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102802:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102806:	89 c2                	mov    %eax,%edx
80102808:	ec                   	in     (%dx),%al
80102809:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010280c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102810:	c9                   	leave  
80102811:	c3                   	ret    

80102812 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102812:	55                   	push   %ebp
80102813:	89 e5                	mov    %esp,%ebp
80102815:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102818:	6a 64                	push   $0x64
8010281a:	e8 d6 ff ff ff       	call   801027f5 <inb>
8010281f:	83 c4 04             	add    $0x4,%esp
80102822:	0f b6 c0             	movzbl %al,%eax
80102825:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282b:	83 e0 01             	and    $0x1,%eax
8010282e:	85 c0                	test   %eax,%eax
80102830:	75 0a                	jne    8010283c <kbdgetc+0x2a>
    return -1;
80102832:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102837:	e9 23 01 00 00       	jmp    8010295f <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010283c:	6a 60                	push   $0x60
8010283e:	e8 b2 ff ff ff       	call   801027f5 <inb>
80102843:	83 c4 04             	add    $0x4,%esp
80102846:	0f b6 c0             	movzbl %al,%eax
80102849:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010284c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102853:	75 17                	jne    8010286c <kbdgetc+0x5a>
    shift |= E0ESC;
80102855:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010285a:	83 c8 40             	or     $0x40,%eax
8010285d:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102862:	b8 00 00 00 00       	mov    $0x0,%eax
80102867:	e9 f3 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(data & 0x80){
8010286c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010286f:	25 80 00 00 00       	and    $0x80,%eax
80102874:	85 c0                	test   %eax,%eax
80102876:	74 45                	je     801028bd <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102878:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010287d:	83 e0 40             	and    $0x40,%eax
80102880:	85 c0                	test   %eax,%eax
80102882:	75 08                	jne    8010288c <kbdgetc+0x7a>
80102884:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102887:	83 e0 7f             	and    $0x7f,%eax
8010288a:	eb 03                	jmp    8010288f <kbdgetc+0x7d>
8010288c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010288f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102892:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102895:	05 20 d0 10 80       	add    $0x8010d020,%eax
8010289a:	0f b6 00             	movzbl (%eax),%eax
8010289d:	83 c8 40             	or     $0x40,%eax
801028a0:	0f b6 c0             	movzbl %al,%eax
801028a3:	f7 d0                	not    %eax
801028a5:	89 c2                	mov    %eax,%edx
801028a7:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ac:	21 d0                	and    %edx,%eax
801028ae:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028b3:	b8 00 00 00 00       	mov    $0x0,%eax
801028b8:	e9 a2 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028bd:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028c2:	83 e0 40             	and    $0x40,%eax
801028c5:	85 c0                	test   %eax,%eax
801028c7:	74 14                	je     801028dd <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028c9:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d0:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028d5:	83 e0 bf             	and    $0xffffffbf,%eax
801028d8:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e0:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028e5:	0f b6 00             	movzbl (%eax),%eax
801028e8:	0f b6 d0             	movzbl %al,%edx
801028eb:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f0:	09 d0                	or     %edx,%eax
801028f2:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028fa:	05 20 d1 10 80       	add    $0x8010d120,%eax
801028ff:	0f b6 00             	movzbl (%eax),%eax
80102902:	0f b6 d0             	movzbl %al,%edx
80102905:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010290a:	31 d0                	xor    %edx,%eax
8010290c:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102911:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102916:	83 e0 03             	and    $0x3,%eax
80102919:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102920:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102923:	01 d0                	add    %edx,%eax
80102925:	0f b6 00             	movzbl (%eax),%eax
80102928:	0f b6 c0             	movzbl %al,%eax
8010292b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010292e:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102933:	83 e0 08             	and    $0x8,%eax
80102936:	85 c0                	test   %eax,%eax
80102938:	74 22                	je     8010295c <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010293a:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010293e:	76 0c                	jbe    8010294c <kbdgetc+0x13a>
80102940:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102944:	77 06                	ja     8010294c <kbdgetc+0x13a>
      c += 'A' - 'a';
80102946:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010294a:	eb 10                	jmp    8010295c <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010294c:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102950:	76 0a                	jbe    8010295c <kbdgetc+0x14a>
80102952:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102956:	77 04                	ja     8010295c <kbdgetc+0x14a>
      c += 'a' - 'A';
80102958:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010295c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010295f:	c9                   	leave  
80102960:	c3                   	ret    

80102961 <kbdintr>:

void
kbdintr(void)
{
80102961:	55                   	push   %ebp
80102962:	89 e5                	mov    %esp,%ebp
80102964:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102967:	83 ec 0c             	sub    $0xc,%esp
8010296a:	68 12 28 10 80       	push   $0x80102812
8010296f:	e8 62 de ff ff       	call   801007d6 <consoleintr>
80102974:	83 c4 10             	add    $0x10,%esp
}
80102977:	90                   	nop
80102978:	c9                   	leave  
80102979:	c3                   	ret    

8010297a <inb>:
{
8010297a:	55                   	push   %ebp
8010297b:	89 e5                	mov    %esp,%ebp
8010297d:	83 ec 14             	sub    $0x14,%esp
80102980:	8b 45 08             	mov    0x8(%ebp),%eax
80102983:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102987:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010298b:	89 c2                	mov    %eax,%edx
8010298d:	ec                   	in     (%dx),%al
8010298e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102991:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102995:	c9                   	leave  
80102996:	c3                   	ret    

80102997 <outb>:
{
80102997:	55                   	push   %ebp
80102998:	89 e5                	mov    %esp,%ebp
8010299a:	83 ec 08             	sub    $0x8,%esp
8010299d:	8b 45 08             	mov    0x8(%ebp),%eax
801029a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801029a3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801029a7:	89 d0                	mov    %edx,%eax
801029a9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029ac:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029b4:	ee                   	out    %al,(%dx)
}
801029b5:	90                   	nop
801029b6:	c9                   	leave  
801029b7:	c3                   	ret    

801029b8 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029b8:	55                   	push   %ebp
801029b9:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029bb:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029c1:	8b 45 08             	mov    0x8(%ebp),%eax
801029c4:	c1 e0 02             	shl    $0x2,%eax
801029c7:	01 c2                	add    %eax,%edx
801029c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801029cc:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029ce:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d3:	83 c0 20             	add    $0x20,%eax
801029d6:	8b 00                	mov    (%eax),%eax
}
801029d8:	90                   	nop
801029d9:	5d                   	pop    %ebp
801029da:	c3                   	ret    

801029db <lapicinit>:

void
lapicinit(void)
{
801029db:	55                   	push   %ebp
801029dc:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029de:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e3:	85 c0                	test   %eax,%eax
801029e5:	0f 84 0c 01 00 00    	je     80102af7 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029eb:	68 3f 01 00 00       	push   $0x13f
801029f0:	6a 3c                	push   $0x3c
801029f2:	e8 c1 ff ff ff       	call   801029b8 <lapicw>
801029f7:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029fa:	6a 0b                	push   $0xb
801029fc:	68 f8 00 00 00       	push   $0xf8
80102a01:	e8 b2 ff ff ff       	call   801029b8 <lapicw>
80102a06:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a09:	68 20 00 02 00       	push   $0x20020
80102a0e:	68 c8 00 00 00       	push   $0xc8
80102a13:	e8 a0 ff ff ff       	call   801029b8 <lapicw>
80102a18:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a1b:	68 80 96 98 00       	push   $0x989680
80102a20:	68 e0 00 00 00       	push   $0xe0
80102a25:	e8 8e ff ff ff       	call   801029b8 <lapicw>
80102a2a:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a2d:	68 00 00 01 00       	push   $0x10000
80102a32:	68 d4 00 00 00       	push   $0xd4
80102a37:	e8 7c ff ff ff       	call   801029b8 <lapicw>
80102a3c:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a3f:	68 00 00 01 00       	push   $0x10000
80102a44:	68 d8 00 00 00       	push   $0xd8
80102a49:	e8 6a ff ff ff       	call   801029b8 <lapicw>
80102a4e:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a51:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a56:	83 c0 30             	add    $0x30,%eax
80102a59:	8b 00                	mov    (%eax),%eax
80102a5b:	c1 e8 10             	shr    $0x10,%eax
80102a5e:	25 fc 00 00 00       	and    $0xfc,%eax
80102a63:	85 c0                	test   %eax,%eax
80102a65:	74 12                	je     80102a79 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a67:	68 00 00 01 00       	push   $0x10000
80102a6c:	68 d0 00 00 00       	push   $0xd0
80102a71:	e8 42 ff ff ff       	call   801029b8 <lapicw>
80102a76:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a79:	6a 33                	push   $0x33
80102a7b:	68 dc 00 00 00       	push   $0xdc
80102a80:	e8 33 ff ff ff       	call   801029b8 <lapicw>
80102a85:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a88:	6a 00                	push   $0x0
80102a8a:	68 a0 00 00 00       	push   $0xa0
80102a8f:	e8 24 ff ff ff       	call   801029b8 <lapicw>
80102a94:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a97:	6a 00                	push   $0x0
80102a99:	68 a0 00 00 00       	push   $0xa0
80102a9e:	e8 15 ff ff ff       	call   801029b8 <lapicw>
80102aa3:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa6:	6a 00                	push   $0x0
80102aa8:	6a 2c                	push   $0x2c
80102aaa:	e8 09 ff ff ff       	call   801029b8 <lapicw>
80102aaf:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab2:	6a 00                	push   $0x0
80102ab4:	68 c4 00 00 00       	push   $0xc4
80102ab9:	e8 fa fe ff ff       	call   801029b8 <lapicw>
80102abe:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac1:	68 00 85 08 00       	push   $0x88500
80102ac6:	68 c0 00 00 00       	push   $0xc0
80102acb:	e8 e8 fe ff ff       	call   801029b8 <lapicw>
80102ad0:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad3:	90                   	nop
80102ad4:	a1 00 41 19 80       	mov    0x80194100,%eax
80102ad9:	05 00 03 00 00       	add    $0x300,%eax
80102ade:	8b 00                	mov    (%eax),%eax
80102ae0:	25 00 10 00 00       	and    $0x1000,%eax
80102ae5:	85 c0                	test   %eax,%eax
80102ae7:	75 eb                	jne    80102ad4 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ae9:	6a 00                	push   $0x0
80102aeb:	6a 20                	push   $0x20
80102aed:	e8 c6 fe ff ff       	call   801029b8 <lapicw>
80102af2:	83 c4 08             	add    $0x8,%esp
80102af5:	eb 01                	jmp    80102af8 <lapicinit+0x11d>
    return;
80102af7:	90                   	nop
}
80102af8:	c9                   	leave  
80102af9:	c3                   	ret    

80102afa <lapicid>:

int
lapicid(void)
{
80102afa:	55                   	push   %ebp
80102afb:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102afd:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b02:	85 c0                	test   %eax,%eax
80102b04:	75 07                	jne    80102b0d <lapicid+0x13>
    return 0;
80102b06:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0b:	eb 0d                	jmp    80102b1a <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0d:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b12:	83 c0 20             	add    $0x20,%eax
80102b15:	8b 00                	mov    (%eax),%eax
80102b17:	c1 e8 18             	shr    $0x18,%eax
}
80102b1a:	5d                   	pop    %ebp
80102b1b:	c3                   	ret    

80102b1c <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1c:	55                   	push   %ebp
80102b1d:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b1f:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b24:	85 c0                	test   %eax,%eax
80102b26:	74 0c                	je     80102b34 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b28:	6a 00                	push   $0x0
80102b2a:	6a 2c                	push   $0x2c
80102b2c:	e8 87 fe ff ff       	call   801029b8 <lapicw>
80102b31:	83 c4 08             	add    $0x8,%esp
}
80102b34:	90                   	nop
80102b35:	c9                   	leave  
80102b36:	c3                   	ret    

80102b37 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b37:	55                   	push   %ebp
80102b38:	89 e5                	mov    %esp,%ebp
}
80102b3a:	90                   	nop
80102b3b:	5d                   	pop    %ebp
80102b3c:	c3                   	ret    

80102b3d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3d:	55                   	push   %ebp
80102b3e:	89 e5                	mov    %esp,%ebp
80102b40:	83 ec 14             	sub    $0x14,%esp
80102b43:	8b 45 08             	mov    0x8(%ebp),%eax
80102b46:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b49:	6a 0f                	push   $0xf
80102b4b:	6a 70                	push   $0x70
80102b4d:	e8 45 fe ff ff       	call   80102997 <outb>
80102b52:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b55:	6a 0a                	push   $0xa
80102b57:	6a 71                	push   $0x71
80102b59:	e8 39 fe ff ff       	call   80102997 <outb>
80102b5e:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b61:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b68:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b70:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b73:	c1 e8 04             	shr    $0x4,%eax
80102b76:	89 c2                	mov    %eax,%edx
80102b78:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7b:	83 c0 02             	add    $0x2,%eax
80102b7e:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b81:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b85:	c1 e0 18             	shl    $0x18,%eax
80102b88:	50                   	push   %eax
80102b89:	68 c4 00 00 00       	push   $0xc4
80102b8e:	e8 25 fe ff ff       	call   801029b8 <lapicw>
80102b93:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b96:	68 00 c5 00 00       	push   $0xc500
80102b9b:	68 c0 00 00 00       	push   $0xc0
80102ba0:	e8 13 fe ff ff       	call   801029b8 <lapicw>
80102ba5:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102ba8:	68 c8 00 00 00       	push   $0xc8
80102bad:	e8 85 ff ff ff       	call   80102b37 <microdelay>
80102bb2:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb5:	68 00 85 00 00       	push   $0x8500
80102bba:	68 c0 00 00 00       	push   $0xc0
80102bbf:	e8 f4 fd ff ff       	call   801029b8 <lapicw>
80102bc4:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc7:	6a 64                	push   $0x64
80102bc9:	e8 69 ff ff ff       	call   80102b37 <microdelay>
80102bce:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bd8:	eb 3d                	jmp    80102c17 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bda:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bde:	c1 e0 18             	shl    $0x18,%eax
80102be1:	50                   	push   %eax
80102be2:	68 c4 00 00 00       	push   $0xc4
80102be7:	e8 cc fd ff ff       	call   801029b8 <lapicw>
80102bec:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bef:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf2:	c1 e8 0c             	shr    $0xc,%eax
80102bf5:	80 cc 06             	or     $0x6,%ah
80102bf8:	50                   	push   %eax
80102bf9:	68 c0 00 00 00       	push   $0xc0
80102bfe:	e8 b5 fd ff ff       	call   801029b8 <lapicw>
80102c03:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c06:	68 c8 00 00 00       	push   $0xc8
80102c0b:	e8 27 ff ff ff       	call   80102b37 <microdelay>
80102c10:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c13:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c17:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1b:	7e bd                	jle    80102bda <lapicstartap+0x9d>
  }
}
80102c1d:	90                   	nop
80102c1e:	90                   	nop
80102c1f:	c9                   	leave  
80102c20:	c3                   	ret    

80102c21 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c21:	55                   	push   %ebp
80102c22:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c24:	8b 45 08             	mov    0x8(%ebp),%eax
80102c27:	0f b6 c0             	movzbl %al,%eax
80102c2a:	50                   	push   %eax
80102c2b:	6a 70                	push   $0x70
80102c2d:	e8 65 fd ff ff       	call   80102997 <outb>
80102c32:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c35:	68 c8 00 00 00       	push   $0xc8
80102c3a:	e8 f8 fe ff ff       	call   80102b37 <microdelay>
80102c3f:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c42:	6a 71                	push   $0x71
80102c44:	e8 31 fd ff ff       	call   8010297a <inb>
80102c49:	83 c4 04             	add    $0x4,%esp
80102c4c:	0f b6 c0             	movzbl %al,%eax
}
80102c4f:	c9                   	leave  
80102c50:	c3                   	ret    

80102c51 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c51:	55                   	push   %ebp
80102c52:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c54:	6a 00                	push   $0x0
80102c56:	e8 c6 ff ff ff       	call   80102c21 <cmos_read>
80102c5b:	83 c4 04             	add    $0x4,%esp
80102c5e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c61:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c63:	6a 02                	push   $0x2
80102c65:	e8 b7 ff ff ff       	call   80102c21 <cmos_read>
80102c6a:	83 c4 04             	add    $0x4,%esp
80102c6d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c70:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c73:	6a 04                	push   $0x4
80102c75:	e8 a7 ff ff ff       	call   80102c21 <cmos_read>
80102c7a:	83 c4 04             	add    $0x4,%esp
80102c7d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c80:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c83:	6a 07                	push   $0x7
80102c85:	e8 97 ff ff ff       	call   80102c21 <cmos_read>
80102c8a:	83 c4 04             	add    $0x4,%esp
80102c8d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c90:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c93:	6a 08                	push   $0x8
80102c95:	e8 87 ff ff ff       	call   80102c21 <cmos_read>
80102c9a:	83 c4 04             	add    $0x4,%esp
80102c9d:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca0:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca3:	6a 09                	push   $0x9
80102ca5:	e8 77 ff ff ff       	call   80102c21 <cmos_read>
80102caa:	83 c4 04             	add    $0x4,%esp
80102cad:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb0:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb3:	90                   	nop
80102cb4:	c9                   	leave  
80102cb5:	c3                   	ret    

80102cb6 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb6:	55                   	push   %ebp
80102cb7:	89 e5                	mov    %esp,%ebp
80102cb9:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbc:	6a 0b                	push   $0xb
80102cbe:	e8 5e ff ff ff       	call   80102c21 <cmos_read>
80102cc3:	83 c4 04             	add    $0x4,%esp
80102cc6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccc:	83 e0 04             	and    $0x4,%eax
80102ccf:	85 c0                	test   %eax,%eax
80102cd1:	0f 94 c0             	sete   %al
80102cd4:	0f b6 c0             	movzbl %al,%eax
80102cd7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cda:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cdd:	50                   	push   %eax
80102cde:	e8 6e ff ff ff       	call   80102c51 <fill_rtcdate>
80102ce3:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce6:	6a 0a                	push   $0xa
80102ce8:	e8 34 ff ff ff       	call   80102c21 <cmos_read>
80102ced:	83 c4 04             	add    $0x4,%esp
80102cf0:	25 80 00 00 00       	and    $0x80,%eax
80102cf5:	85 c0                	test   %eax,%eax
80102cf7:	75 27                	jne    80102d20 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cf9:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfc:	50                   	push   %eax
80102cfd:	e8 4f ff ff ff       	call   80102c51 <fill_rtcdate>
80102d02:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d05:	83 ec 04             	sub    $0x4,%esp
80102d08:	6a 18                	push   $0x18
80102d0a:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0d:	50                   	push   %eax
80102d0e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d11:	50                   	push   %eax
80102d12:	e8 b5 20 00 00       	call   80104dcc <memcmp>
80102d17:	83 c4 10             	add    $0x10,%esp
80102d1a:	85 c0                	test   %eax,%eax
80102d1c:	74 05                	je     80102d23 <cmostime+0x6d>
80102d1e:	eb ba                	jmp    80102cda <cmostime+0x24>
        continue;
80102d20:	90                   	nop
    fill_rtcdate(&t1);
80102d21:	eb b7                	jmp    80102cda <cmostime+0x24>
      break;
80102d23:	90                   	nop
  }

  // convert
  if(bcd) {
80102d24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d28:	0f 84 b4 00 00 00    	je     80102de2 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d31:	c1 e8 04             	shr    $0x4,%eax
80102d34:	89 c2                	mov    %eax,%edx
80102d36:	89 d0                	mov    %edx,%eax
80102d38:	c1 e0 02             	shl    $0x2,%eax
80102d3b:	01 d0                	add    %edx,%eax
80102d3d:	01 c0                	add    %eax,%eax
80102d3f:	89 c2                	mov    %eax,%edx
80102d41:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d44:	83 e0 0f             	and    $0xf,%eax
80102d47:	01 d0                	add    %edx,%eax
80102d49:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d4f:	c1 e8 04             	shr    $0x4,%eax
80102d52:	89 c2                	mov    %eax,%edx
80102d54:	89 d0                	mov    %edx,%eax
80102d56:	c1 e0 02             	shl    $0x2,%eax
80102d59:	01 d0                	add    %edx,%eax
80102d5b:	01 c0                	add    %eax,%eax
80102d5d:	89 c2                	mov    %eax,%edx
80102d5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d62:	83 e0 0f             	and    $0xf,%eax
80102d65:	01 d0                	add    %edx,%eax
80102d67:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6d:	c1 e8 04             	shr    $0x4,%eax
80102d70:	89 c2                	mov    %eax,%edx
80102d72:	89 d0                	mov    %edx,%eax
80102d74:	c1 e0 02             	shl    $0x2,%eax
80102d77:	01 d0                	add    %edx,%eax
80102d79:	01 c0                	add    %eax,%eax
80102d7b:	89 c2                	mov    %eax,%edx
80102d7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d80:	83 e0 0f             	and    $0xf,%eax
80102d83:	01 d0                	add    %edx,%eax
80102d85:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8b:	c1 e8 04             	shr    $0x4,%eax
80102d8e:	89 c2                	mov    %eax,%edx
80102d90:	89 d0                	mov    %edx,%eax
80102d92:	c1 e0 02             	shl    $0x2,%eax
80102d95:	01 d0                	add    %edx,%eax
80102d97:	01 c0                	add    %eax,%eax
80102d99:	89 c2                	mov    %eax,%edx
80102d9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d9e:	83 e0 0f             	and    $0xf,%eax
80102da1:	01 d0                	add    %edx,%eax
80102da3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102da9:	c1 e8 04             	shr    $0x4,%eax
80102dac:	89 c2                	mov    %eax,%edx
80102dae:	89 d0                	mov    %edx,%eax
80102db0:	c1 e0 02             	shl    $0x2,%eax
80102db3:	01 d0                	add    %edx,%eax
80102db5:	01 c0                	add    %eax,%eax
80102db7:	89 c2                	mov    %eax,%edx
80102db9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbc:	83 e0 0f             	and    $0xf,%eax
80102dbf:	01 d0                	add    %edx,%eax
80102dc1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc7:	c1 e8 04             	shr    $0x4,%eax
80102dca:	89 c2                	mov    %eax,%edx
80102dcc:	89 d0                	mov    %edx,%eax
80102dce:	c1 e0 02             	shl    $0x2,%eax
80102dd1:	01 d0                	add    %edx,%eax
80102dd3:	01 c0                	add    %eax,%eax
80102dd5:	89 c2                	mov    %eax,%edx
80102dd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dda:	83 e0 0f             	and    $0xf,%eax
80102ddd:	01 d0                	add    %edx,%eax
80102ddf:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de2:	8b 45 08             	mov    0x8(%ebp),%eax
80102de5:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102de8:	89 10                	mov    %edx,(%eax)
80102dea:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102ded:	89 50 04             	mov    %edx,0x4(%eax)
80102df0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df3:	89 50 08             	mov    %edx,0x8(%eax)
80102df6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102df9:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfc:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102dff:	89 50 10             	mov    %edx,0x10(%eax)
80102e02:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e05:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e08:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0b:	8b 40 14             	mov    0x14(%eax),%eax
80102e0e:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e14:	8b 45 08             	mov    0x8(%ebp),%eax
80102e17:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1a:	90                   	nop
80102e1b:	c9                   	leave  
80102e1c:	c3                   	ret    

80102e1d <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e1d:	55                   	push   %ebp
80102e1e:	89 e5                	mov    %esp,%ebp
80102e20:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e23:	83 ec 08             	sub    $0x8,%esp
80102e26:	68 11 a8 10 80       	push   $0x8010a811
80102e2b:	68 20 41 19 80       	push   $0x80194120
80102e30:	e8 98 1c 00 00       	call   80104acd <initlock>
80102e35:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e38:	83 ec 08             	sub    $0x8,%esp
80102e3b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e3e:	50                   	push   %eax
80102e3f:	ff 75 08             	push   0x8(%ebp)
80102e42:	e8 87 e5 ff ff       	call   801013ce <readsb>
80102e47:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4d:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e55:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5d:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e62:	e8 b3 01 00 00       	call   8010301a <recover_from_log>
}
80102e67:	90                   	nop
80102e68:	c9                   	leave  
80102e69:	c3                   	ret    

80102e6a <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e6a:	55                   	push   %ebp
80102e6b:	89 e5                	mov    %esp,%ebp
80102e6d:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e77:	e9 95 00 00 00       	jmp    80102f11 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e7c:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e85:	01 d0                	add    %edx,%eax
80102e87:	83 c0 01             	add    $0x1,%eax
80102e8a:	89 c2                	mov    %eax,%edx
80102e8c:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e91:	83 ec 08             	sub    $0x8,%esp
80102e94:	52                   	push   %edx
80102e95:	50                   	push   %eax
80102e96:	e8 66 d3 ff ff       	call   80100201 <bread>
80102e9b:	83 c4 10             	add    $0x10,%esp
80102e9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea4:	83 c0 10             	add    $0x10,%eax
80102ea7:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eae:	89 c2                	mov    %eax,%edx
80102eb0:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb5:	83 ec 08             	sub    $0x8,%esp
80102eb8:	52                   	push   %edx
80102eb9:	50                   	push   %eax
80102eba:	e8 42 d3 ff ff       	call   80100201 <bread>
80102ebf:	83 c4 10             	add    $0x10,%esp
80102ec2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ec8:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ece:	83 c0 5c             	add    $0x5c,%eax
80102ed1:	83 ec 04             	sub    $0x4,%esp
80102ed4:	68 00 02 00 00       	push   $0x200
80102ed9:	52                   	push   %edx
80102eda:	50                   	push   %eax
80102edb:	e8 44 1f 00 00       	call   80104e24 <memmove>
80102ee0:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ee3:	83 ec 0c             	sub    $0xc,%esp
80102ee6:	ff 75 ec             	push   -0x14(%ebp)
80102ee9:	e8 4c d3 ff ff       	call   8010023a <bwrite>
80102eee:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ef1:	83 ec 0c             	sub    $0xc,%esp
80102ef4:	ff 75 f0             	push   -0x10(%ebp)
80102ef7:	e8 87 d3 ff ff       	call   80100283 <brelse>
80102efc:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102eff:	83 ec 0c             	sub    $0xc,%esp
80102f02:	ff 75 ec             	push   -0x14(%ebp)
80102f05:	e8 79 d3 ff ff       	call   80100283 <brelse>
80102f0a:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f11:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f16:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f19:	0f 8c 5d ff ff ff    	jl     80102e7c <install_trans+0x12>
  }
}
80102f1f:	90                   	nop
80102f20:	90                   	nop
80102f21:	c9                   	leave  
80102f22:	c3                   	ret    

80102f23 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f23:	55                   	push   %ebp
80102f24:	89 e5                	mov    %esp,%ebp
80102f26:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f29:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f2e:	89 c2                	mov    %eax,%edx
80102f30:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f35:	83 ec 08             	sub    $0x8,%esp
80102f38:	52                   	push   %edx
80102f39:	50                   	push   %eax
80102f3a:	e8 c2 d2 ff ff       	call   80100201 <bread>
80102f3f:	83 c4 10             	add    $0x10,%esp
80102f42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f48:	83 c0 5c             	add    $0x5c,%eax
80102f4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f51:	8b 00                	mov    (%eax),%eax
80102f53:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f5f:	eb 1b                	jmp    80102f7c <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f67:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f6e:	83 c2 10             	add    $0x10,%edx
80102f71:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7c:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f81:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f84:	7c db                	jl     80102f61 <read_head+0x3e>
  }
  brelse(buf);
80102f86:	83 ec 0c             	sub    $0xc,%esp
80102f89:	ff 75 f0             	push   -0x10(%ebp)
80102f8c:	e8 f2 d2 ff ff       	call   80100283 <brelse>
80102f91:	83 c4 10             	add    $0x10,%esp
}
80102f94:	90                   	nop
80102f95:	c9                   	leave  
80102f96:	c3                   	ret    

80102f97 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f97:	55                   	push   %ebp
80102f98:	89 e5                	mov    %esp,%ebp
80102f9a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f9d:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa2:	89 c2                	mov    %eax,%edx
80102fa4:	a1 64 41 19 80       	mov    0x80194164,%eax
80102fa9:	83 ec 08             	sub    $0x8,%esp
80102fac:	52                   	push   %edx
80102fad:	50                   	push   %eax
80102fae:	e8 4e d2 ff ff       	call   80100201 <bread>
80102fb3:	83 c4 10             	add    $0x10,%esp
80102fb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbc:	83 c0 5c             	add    $0x5c,%eax
80102fbf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fc2:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcb:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fcd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd4:	eb 1b                	jmp    80102ff1 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fd9:	83 c0 10             	add    $0x10,%eax
80102fdc:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fe9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff1:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ff9:	7c db                	jl     80102fd6 <write_head+0x3f>
  }
  bwrite(buf);
80102ffb:	83 ec 0c             	sub    $0xc,%esp
80102ffe:	ff 75 f0             	push   -0x10(%ebp)
80103001:	e8 34 d2 ff ff       	call   8010023a <bwrite>
80103006:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103009:	83 ec 0c             	sub    $0xc,%esp
8010300c:	ff 75 f0             	push   -0x10(%ebp)
8010300f:	e8 6f d2 ff ff       	call   80100283 <brelse>
80103014:	83 c4 10             	add    $0x10,%esp
}
80103017:	90                   	nop
80103018:	c9                   	leave  
80103019:	c3                   	ret    

8010301a <recover_from_log>:

static void
recover_from_log(void)
{
8010301a:	55                   	push   %ebp
8010301b:	89 e5                	mov    %esp,%ebp
8010301d:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103020:	e8 fe fe ff ff       	call   80102f23 <read_head>
  install_trans(); // if committed, copy from log to disk
80103025:	e8 40 fe ff ff       	call   80102e6a <install_trans>
  log.lh.n = 0;
8010302a:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103031:	00 00 00 
  write_head(); // clear the log
80103034:	e8 5e ff ff ff       	call   80102f97 <write_head>
}
80103039:	90                   	nop
8010303a:	c9                   	leave  
8010303b:	c3                   	ret    

8010303c <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010303c:	55                   	push   %ebp
8010303d:	89 e5                	mov    %esp,%ebp
8010303f:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103042:	83 ec 0c             	sub    $0xc,%esp
80103045:	68 20 41 19 80       	push   $0x80194120
8010304a:	e8 a0 1a 00 00       	call   80104aef <acquire>
8010304f:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103052:	a1 60 41 19 80       	mov    0x80194160,%eax
80103057:	85 c0                	test   %eax,%eax
80103059:	74 17                	je     80103072 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305b:	83 ec 08             	sub    $0x8,%esp
8010305e:	68 20 41 19 80       	push   $0x80194120
80103063:	68 20 41 19 80       	push   $0x80194120
80103068:	e8 5e 16 00 00       	call   801046cb <sleep>
8010306d:	83 c4 10             	add    $0x10,%esp
80103070:	eb e0                	jmp    80103052 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103072:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
80103078:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307d:	8d 50 01             	lea    0x1(%eax),%edx
80103080:	89 d0                	mov    %edx,%eax
80103082:	c1 e0 02             	shl    $0x2,%eax
80103085:	01 d0                	add    %edx,%eax
80103087:	01 c0                	add    %eax,%eax
80103089:	01 c8                	add    %ecx,%eax
8010308b:	83 f8 1e             	cmp    $0x1e,%eax
8010308e:	7e 17                	jle    801030a7 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103090:	83 ec 08             	sub    $0x8,%esp
80103093:	68 20 41 19 80       	push   $0x80194120
80103098:	68 20 41 19 80       	push   $0x80194120
8010309d:	e8 29 16 00 00       	call   801046cb <sleep>
801030a2:	83 c4 10             	add    $0x10,%esp
801030a5:	eb ab                	jmp    80103052 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a7:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ac:	83 c0 01             	add    $0x1,%eax
801030af:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030b4:	83 ec 0c             	sub    $0xc,%esp
801030b7:	68 20 41 19 80       	push   $0x80194120
801030bc:	e8 9c 1a 00 00       	call   80104b5d <release>
801030c1:	83 c4 10             	add    $0x10,%esp
      break;
801030c4:	90                   	nop
    }
  }
}
801030c5:	90                   	nop
801030c6:	c9                   	leave  
801030c7:	c3                   	ret    

801030c8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030c8:	55                   	push   %ebp
801030c9:	89 e5                	mov    %esp,%ebp
801030cb:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d5:	83 ec 0c             	sub    $0xc,%esp
801030d8:	68 20 41 19 80       	push   $0x80194120
801030dd:	e8 0d 1a 00 00       	call   80104aef <acquire>
801030e2:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e5:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ea:	83 e8 01             	sub    $0x1,%eax
801030ed:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030f2:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f7:	85 c0                	test   %eax,%eax
801030f9:	74 0d                	je     80103108 <end_op+0x40>
    panic("log.committing");
801030fb:	83 ec 0c             	sub    $0xc,%esp
801030fe:	68 15 a8 10 80       	push   $0x8010a815
80103103:	e8 a1 d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
80103108:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310d:	85 c0                	test   %eax,%eax
8010310f:	75 13                	jne    80103124 <end_op+0x5c>
    do_commit = 1;
80103111:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103118:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
8010311f:	00 00 00 
80103122:	eb 10                	jmp    80103134 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103124:	83 ec 0c             	sub    $0xc,%esp
80103127:	68 20 41 19 80       	push   $0x80194120
8010312c:	e8 84 16 00 00       	call   801047b5 <wakeup>
80103131:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103134:	83 ec 0c             	sub    $0xc,%esp
80103137:	68 20 41 19 80       	push   $0x80194120
8010313c:	e8 1c 1a 00 00       	call   80104b5d <release>
80103141:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103144:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103148:	74 3f                	je     80103189 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010314a:	e8 f6 00 00 00       	call   80103245 <commit>
    acquire(&log.lock);
8010314f:	83 ec 0c             	sub    $0xc,%esp
80103152:	68 20 41 19 80       	push   $0x80194120
80103157:	e8 93 19 00 00       	call   80104aef <acquire>
8010315c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010315f:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103166:	00 00 00 
    wakeup(&log);
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	68 20 41 19 80       	push   $0x80194120
80103171:	e8 3f 16 00 00       	call   801047b5 <wakeup>
80103176:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103179:	83 ec 0c             	sub    $0xc,%esp
8010317c:	68 20 41 19 80       	push   $0x80194120
80103181:	e8 d7 19 00 00       	call   80104b5d <release>
80103186:	83 c4 10             	add    $0x10,%esp
  }
}
80103189:	90                   	nop
8010318a:	c9                   	leave  
8010318b:	c3                   	ret    

8010318c <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010318c:	55                   	push   %ebp
8010318d:	89 e5                	mov    %esp,%ebp
8010318f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103192:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103199:	e9 95 00 00 00       	jmp    80103233 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010319e:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a7:	01 d0                	add    %edx,%eax
801031a9:	83 c0 01             	add    $0x1,%eax
801031ac:	89 c2                	mov    %eax,%edx
801031ae:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b3:	83 ec 08             	sub    $0x8,%esp
801031b6:	52                   	push   %edx
801031b7:	50                   	push   %eax
801031b8:	e8 44 d0 ff ff       	call   80100201 <bread>
801031bd:	83 c4 10             	add    $0x10,%esp
801031c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c6:	83 c0 10             	add    $0x10,%eax
801031c9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d0:	89 c2                	mov    %eax,%edx
801031d2:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d7:	83 ec 08             	sub    $0x8,%esp
801031da:	52                   	push   %edx
801031db:	50                   	push   %eax
801031dc:	e8 20 d0 ff ff       	call   80100201 <bread>
801031e1:	83 c4 10             	add    $0x10,%esp
801031e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ea:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f0:	83 c0 5c             	add    $0x5c,%eax
801031f3:	83 ec 04             	sub    $0x4,%esp
801031f6:	68 00 02 00 00       	push   $0x200
801031fb:	52                   	push   %edx
801031fc:	50                   	push   %eax
801031fd:	e8 22 1c 00 00       	call   80104e24 <memmove>
80103202:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103205:	83 ec 0c             	sub    $0xc,%esp
80103208:	ff 75 f0             	push   -0x10(%ebp)
8010320b:	e8 2a d0 ff ff       	call   8010023a <bwrite>
80103210:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103213:	83 ec 0c             	sub    $0xc,%esp
80103216:	ff 75 ec             	push   -0x14(%ebp)
80103219:	e8 65 d0 ff ff       	call   80100283 <brelse>
8010321e:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103221:	83 ec 0c             	sub    $0xc,%esp
80103224:	ff 75 f0             	push   -0x10(%ebp)
80103227:	e8 57 d0 ff ff       	call   80100283 <brelse>
8010322c:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010322f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103233:	a1 68 41 19 80       	mov    0x80194168,%eax
80103238:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323b:	0f 8c 5d ff ff ff    	jl     8010319e <write_log+0x12>
  }
}
80103241:	90                   	nop
80103242:	90                   	nop
80103243:	c9                   	leave  
80103244:	c3                   	ret    

80103245 <commit>:

static void
commit()
{
80103245:	55                   	push   %ebp
80103246:	89 e5                	mov    %esp,%ebp
80103248:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010324b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103250:	85 c0                	test   %eax,%eax
80103252:	7e 1e                	jle    80103272 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103254:	e8 33 ff ff ff       	call   8010318c <write_log>
    write_head();    // Write header to disk -- the real commit
80103259:	e8 39 fd ff ff       	call   80102f97 <write_head>
    install_trans(); // Now install writes to home locations
8010325e:	e8 07 fc ff ff       	call   80102e6a <install_trans>
    log.lh.n = 0;
80103263:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326a:	00 00 00 
    write_head();    // Erase the transaction from the log
8010326d:	e8 25 fd ff ff       	call   80102f97 <write_head>
  }
}
80103272:	90                   	nop
80103273:	c9                   	leave  
80103274:	c3                   	ret    

80103275 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103275:	55                   	push   %ebp
80103276:	89 e5                	mov    %esp,%ebp
80103278:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010327b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103280:	83 f8 1d             	cmp    $0x1d,%eax
80103283:	7f 12                	jg     80103297 <log_write+0x22>
80103285:	a1 68 41 19 80       	mov    0x80194168,%eax
8010328a:	8b 15 58 41 19 80    	mov    0x80194158,%edx
80103290:	83 ea 01             	sub    $0x1,%edx
80103293:	39 d0                	cmp    %edx,%eax
80103295:	7c 0d                	jl     801032a4 <log_write+0x2f>
    panic("too big a transaction");
80103297:	83 ec 0c             	sub    $0xc,%esp
8010329a:	68 24 a8 10 80       	push   $0x8010a824
8010329f:	e8 05 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a4:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	7f 0d                	jg     801032ba <log_write+0x45>
    panic("log_write outside of trans");
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 3a a8 10 80       	push   $0x8010a83a
801032b5:	e8 ef d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ba:	83 ec 0c             	sub    $0xc,%esp
801032bd:	68 20 41 19 80       	push   $0x80194120
801032c2:	e8 28 18 00 00       	call   80104aef <acquire>
801032c7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d1:	eb 1d                	jmp    801032f0 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d6:	83 c0 10             	add    $0x10,%eax
801032d9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e0:	89 c2                	mov    %eax,%edx
801032e2:	8b 45 08             	mov    0x8(%ebp),%eax
801032e5:	8b 40 08             	mov    0x8(%eax),%eax
801032e8:	39 c2                	cmp    %eax,%edx
801032ea:	74 10                	je     801032fc <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f0:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032f8:	7c d9                	jl     801032d3 <log_write+0x5e>
801032fa:	eb 01                	jmp    801032fd <log_write+0x88>
      break;
801032fc:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103300:	8b 40 08             	mov    0x8(%eax),%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103308:	83 c0 10             	add    $0x10,%eax
8010330b:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103312:	a1 68 41 19 80       	mov    0x80194168,%eax
80103317:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331a:	75 0d                	jne    80103329 <log_write+0xb4>
    log.lh.n++;
8010331c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103321:	83 c0 01             	add    $0x1,%eax
80103324:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
80103329:	8b 45 08             	mov    0x8(%ebp),%eax
8010332c:	8b 00                	mov    (%eax),%eax
8010332e:	83 c8 04             	or     $0x4,%eax
80103331:	89 c2                	mov    %eax,%edx
80103333:	8b 45 08             	mov    0x8(%ebp),%eax
80103336:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103338:	83 ec 0c             	sub    $0xc,%esp
8010333b:	68 20 41 19 80       	push   $0x80194120
80103340:	e8 18 18 00 00       	call   80104b5d <release>
80103345:	83 c4 10             	add    $0x10,%esp
}
80103348:	90                   	nop
80103349:	c9                   	leave  
8010334a:	c3                   	ret    

8010334b <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334b:	55                   	push   %ebp
8010334c:	89 e5                	mov    %esp,%ebp
8010334e:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103351:	8b 55 08             	mov    0x8(%ebp),%edx
80103354:	8b 45 0c             	mov    0xc(%ebp),%eax
80103357:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335a:	f0 87 02             	lock xchg %eax,(%edx)
8010335d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103360:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103363:	c9                   	leave  
80103364:	c3                   	ret    

80103365 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103365:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103369:	83 e4 f0             	and    $0xfffffff0,%esp
8010336c:	ff 71 fc             	push   -0x4(%ecx)
8010336f:	55                   	push   %ebp
80103370:	89 e5                	mov    %esp,%ebp
80103372:	51                   	push   %ecx
80103373:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103376:	e8 2a 50 00 00       	call   801083a5 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337b:	83 ec 08             	sub    $0x8,%esp
8010337e:	68 00 00 40 80       	push   $0x80400000
80103383:	68 00 90 19 80       	push   $0x80199000
80103388:	e8 de f2 ff ff       	call   8010266b <kinit1>
8010338d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103390:	e8 2a 46 00 00       	call   801079bf <kvmalloc>
  mpinit_uefi();
80103395:	e8 d1 4d 00 00       	call   8010816b <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339a:	e8 3c f6 ff ff       	call   801029db <lapicinit>
  seginit();       // segment descriptors
8010339f:	e8 b3 40 00 00       	call   80107457 <seginit>
  picinit();    // disable pic
801033a4:	e8 9d 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033a9:	e8 d8 f1 ff ff       	call   80102586 <ioapicinit>
  consoleinit();   // console hardware
801033ae:	e8 4c d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b3:	e8 38 34 00 00       	call   801067f0 <uartinit>
  pinit();         // process table
801033b8:	e8 c2 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bd:	e8 ac 2f 00 00       	call   8010636e <tvinit>
  binit();         // buffer cache
801033c2:	e8 9f cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c7:	e8 f3 db ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801033cc:	e8 15 71 00 00       	call   8010a4e6 <ideinit>
  startothers();   // start other processors
801033d1:	e8 8a 00 00 00       	call   80103460 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	68 00 00 00 a0       	push   $0xa0000000
801033de:	68 00 00 40 80       	push   $0x80400000
801033e3:	e8 bc f2 ff ff       	call   801026a4 <kinit2>
801033e8:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033eb:	e8 0e 52 00 00       	call   801085fe <pci_init>
  arp_scan();
801033f0:	e8 45 5f 00 00       	call   8010933a <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f5:	e8 be 07 00 00       	call   80103bb8 <userinit>

  mpmain();        // finish this processor's setup
801033fa:	e8 1a 00 00 00       	call   80103419 <mpmain>

801033ff <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801033ff:	55                   	push   %ebp
80103400:	89 e5                	mov    %esp,%ebp
80103402:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103405:	e8 cd 45 00 00       	call   801079d7 <switchkvm>
  seginit();
8010340a:	e8 48 40 00 00       	call   80107457 <seginit>
  lapicinit();
8010340f:	e8 c7 f5 ff ff       	call   801029db <lapicinit>
  mpmain();
80103414:	e8 00 00 00 00       	call   80103419 <mpmain>

80103419 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103419:	55                   	push   %ebp
8010341a:	89 e5                	mov    %esp,%ebp
8010341c:	53                   	push   %ebx
8010341d:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103420:	e8 78 05 00 00       	call   8010399d <cpuid>
80103425:	89 c3                	mov    %eax,%ebx
80103427:	e8 71 05 00 00       	call   8010399d <cpuid>
8010342c:	83 ec 04             	sub    $0x4,%esp
8010342f:	53                   	push   %ebx
80103430:	50                   	push   %eax
80103431:	68 55 a8 10 80       	push   $0x8010a855
80103436:	e8 b9 cf ff ff       	call   801003f4 <cprintf>
8010343b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343e:	e8 a1 30 00 00       	call   801064e4 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103443:	e8 70 05 00 00       	call   801039b8 <mycpu>
80103448:	05 a0 00 00 00       	add    $0xa0,%eax
8010344d:	83 ec 08             	sub    $0x8,%esp
80103450:	6a 01                	push   $0x1
80103452:	50                   	push   %eax
80103453:	e8 f3 fe ff ff       	call   8010334b <xchg>
80103458:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345b:	e8 2a 0d 00 00       	call   8010418a <scheduler>

80103460 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103460:	55                   	push   %ebp
80103461:	89 e5                	mov    %esp,%ebp
80103463:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103466:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346d:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103472:	83 ec 04             	sub    $0x4,%esp
80103475:	50                   	push   %eax
80103476:	68 38 f5 10 80       	push   $0x8010f538
8010347b:	ff 75 f0             	push   -0x10(%ebp)
8010347e:	e8 a1 19 00 00       	call   80104e24 <memmove>
80103483:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103486:	c7 45 f4 80 74 19 80 	movl   $0x80197480,-0xc(%ebp)
8010348d:	eb 79                	jmp    80103508 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
8010348f:	e8 24 05 00 00       	call   801039b8 <mycpu>
80103494:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103497:	74 67                	je     80103500 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103499:	e8 02 f3 ff ff       	call   801027a0 <kalloc>
8010349e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a4:	83 e8 04             	sub    $0x4,%eax
801034a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034aa:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b0:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b5:	83 e8 08             	sub    $0x8,%eax
801034b8:	c7 00 ff 33 10 80    	movl   $0x801033ff,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034be:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c3:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cc:	83 e8 0c             	sub    $0xc,%eax
801034cf:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034dd:	0f b6 00             	movzbl (%eax),%eax
801034e0:	0f b6 c0             	movzbl %al,%eax
801034e3:	83 ec 08             	sub    $0x8,%esp
801034e6:	52                   	push   %edx
801034e7:	50                   	push   %eax
801034e8:	e8 50 f6 ff ff       	call   80102b3d <lapicstartap>
801034ed:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f0:	90                   	nop
801034f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fa:	85 c0                	test   %eax,%eax
801034fc:	74 f3                	je     801034f1 <startothers+0x91>
801034fe:	eb 01                	jmp    80103501 <startothers+0xa1>
      continue;
80103500:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103501:	81 45 f4 b4 00 00 00 	addl   $0xb4,-0xc(%ebp)
80103508:	a1 50 77 19 80       	mov    0x80197750,%eax
8010350d:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103513:	05 80 74 19 80       	add    $0x80197480,%eax
80103518:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351b:	0f 82 6e ff ff ff    	jb     8010348f <startothers+0x2f>
      ;
  }
}
80103521:	90                   	nop
80103522:	90                   	nop
80103523:	c9                   	leave  
80103524:	c3                   	ret    

80103525 <outb>:
{
80103525:	55                   	push   %ebp
80103526:	89 e5                	mov    %esp,%ebp
80103528:	83 ec 08             	sub    $0x8,%esp
8010352b:	8b 45 08             	mov    0x8(%ebp),%eax
8010352e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103531:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103535:	89 d0                	mov    %edx,%eax
80103537:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010353a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103542:	ee                   	out    %al,(%dx)
}
80103543:	90                   	nop
80103544:	c9                   	leave  
80103545:	c3                   	ret    

80103546 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103549:	68 ff 00 00 00       	push   $0xff
8010354e:	6a 21                	push   $0x21
80103550:	e8 d0 ff ff ff       	call   80103525 <outb>
80103555:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103558:	68 ff 00 00 00       	push   $0xff
8010355d:	68 a1 00 00 00       	push   $0xa1
80103562:	e8 be ff ff ff       	call   80103525 <outb>
80103567:	83 c4 08             	add    $0x8,%esp
}
8010356a:	90                   	nop
8010356b:	c9                   	leave  
8010356c:	c3                   	ret    

8010356d <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010356d:	55                   	push   %ebp
8010356e:	89 e5                	mov    %esp,%ebp
80103570:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103573:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010357a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103583:	8b 45 0c             	mov    0xc(%ebp),%eax
80103586:	8b 10                	mov    (%eax),%edx
80103588:	8b 45 08             	mov    0x8(%ebp),%eax
8010358b:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010358d:	e8 4b da ff ff       	call   80100fdd <filealloc>
80103592:	8b 55 08             	mov    0x8(%ebp),%edx
80103595:	89 02                	mov    %eax,(%edx)
80103597:	8b 45 08             	mov    0x8(%ebp),%eax
8010359a:	8b 00                	mov    (%eax),%eax
8010359c:	85 c0                	test   %eax,%eax
8010359e:	0f 84 c8 00 00 00    	je     8010366c <pipealloc+0xff>
801035a4:	e8 34 da ff ff       	call   80100fdd <filealloc>
801035a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ac:	89 02                	mov    %eax,(%edx)
801035ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b1:	8b 00                	mov    (%eax),%eax
801035b3:	85 c0                	test   %eax,%eax
801035b5:	0f 84 b1 00 00 00    	je     8010366c <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035bb:	e8 e0 f1 ff ff       	call   801027a0 <kalloc>
801035c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c7:	0f 84 a2 00 00 00    	je     8010366f <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d7:	00 00 00 
  p->writeopen = 1;
801035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035dd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e4:	00 00 00 
  p->nwrite = 0;
801035e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ea:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f1:	00 00 00 
  p->nread = 0;
801035f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f7:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035fe:	00 00 00 
  initlock(&p->lock, "pipe");
80103601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103604:	83 ec 08             	sub    $0x8,%esp
80103607:	68 69 a8 10 80       	push   $0x8010a869
8010360c:	50                   	push   %eax
8010360d:	e8 bb 14 00 00       	call   80104acd <initlock>
80103612:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103615:	8b 45 08             	mov    0x8(%ebp),%eax
80103618:	8b 00                	mov    (%eax),%eax
8010361a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103620:	8b 45 08             	mov    0x8(%ebp),%eax
80103623:	8b 00                	mov    (%eax),%eax
80103625:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103629:	8b 45 08             	mov    0x8(%ebp),%eax
8010362c:	8b 00                	mov    (%eax),%eax
8010362e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103632:	8b 45 08             	mov    0x8(%ebp),%eax
80103635:	8b 00                	mov    (%eax),%eax
80103637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010363d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103640:	8b 00                	mov    (%eax),%eax
80103642:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364b:	8b 00                	mov    (%eax),%eax
8010364d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103651:	8b 45 0c             	mov    0xc(%ebp),%eax
80103654:	8b 00                	mov    (%eax),%eax
80103656:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010365a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365d:	8b 00                	mov    (%eax),%eax
8010365f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103662:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103665:	b8 00 00 00 00       	mov    $0x0,%eax
8010366a:	eb 51                	jmp    801036bd <pipealloc+0x150>
    goto bad;
8010366c:	90                   	nop
8010366d:	eb 01                	jmp    80103670 <pipealloc+0x103>
    goto bad;
8010366f:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103674:	74 0e                	je     80103684 <pipealloc+0x117>
    kfree((char*)p);
80103676:	83 ec 0c             	sub    $0xc,%esp
80103679:	ff 75 f4             	push   -0xc(%ebp)
8010367c:	e8 85 f0 ff ff       	call   80102706 <kfree>
80103681:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 00                	mov    (%eax),%eax
80103689:	85 c0                	test   %eax,%eax
8010368b:	74 11                	je     8010369e <pipealloc+0x131>
    fileclose(*f0);
8010368d:	8b 45 08             	mov    0x8(%ebp),%eax
80103690:	8b 00                	mov    (%eax),%eax
80103692:	83 ec 0c             	sub    $0xc,%esp
80103695:	50                   	push   %eax
80103696:	e8 00 da ff ff       	call   8010109b <fileclose>
8010369b:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369e:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a1:	8b 00                	mov    (%eax),%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	74 11                	je     801036b8 <pipealloc+0x14b>
    fileclose(*f1);
801036a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801036aa:	8b 00                	mov    (%eax),%eax
801036ac:	83 ec 0c             	sub    $0xc,%esp
801036af:	50                   	push   %eax
801036b0:	e8 e6 d9 ff ff       	call   8010109b <fileclose>
801036b5:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036bd:	c9                   	leave  
801036be:	c3                   	ret    

801036bf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036bf:	55                   	push   %ebp
801036c0:	89 e5                	mov    %esp,%ebp
801036c2:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c5:	8b 45 08             	mov    0x8(%ebp),%eax
801036c8:	83 ec 0c             	sub    $0xc,%esp
801036cb:	50                   	push   %eax
801036cc:	e8 1e 14 00 00       	call   80104aef <acquire>
801036d1:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d8:	74 23                	je     801036fd <pipeclose+0x3e>
    p->writeopen = 0;
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e4:	00 00 00 
    wakeup(&p->nread);
801036e7:	8b 45 08             	mov    0x8(%ebp),%eax
801036ea:	05 34 02 00 00       	add    $0x234,%eax
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	50                   	push   %eax
801036f3:	e8 bd 10 00 00       	call   801047b5 <wakeup>
801036f8:	83 c4 10             	add    $0x10,%esp
801036fb:	eb 21                	jmp    8010371e <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103700:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103707:	00 00 00 
    wakeup(&p->nwrite);
8010370a:	8b 45 08             	mov    0x8(%ebp),%eax
8010370d:	05 38 02 00 00       	add    $0x238,%eax
80103712:	83 ec 0c             	sub    $0xc,%esp
80103715:	50                   	push   %eax
80103716:	e8 9a 10 00 00       	call   801047b5 <wakeup>
8010371b:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103727:	85 c0                	test   %eax,%eax
80103729:	75 2c                	jne    80103757 <pipeclose+0x98>
8010372b:	8b 45 08             	mov    0x8(%ebp),%eax
8010372e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	75 1f                	jne    80103757 <pipeclose+0x98>
    release(&p->lock);
80103738:	8b 45 08             	mov    0x8(%ebp),%eax
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	50                   	push   %eax
8010373f:	e8 19 14 00 00       	call   80104b5d <release>
80103744:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	ff 75 08             	push   0x8(%ebp)
8010374d:	e8 b4 ef ff ff       	call   80102706 <kfree>
80103752:	83 c4 10             	add    $0x10,%esp
80103755:	eb 10                	jmp    80103767 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103757:	8b 45 08             	mov    0x8(%ebp),%eax
8010375a:	83 ec 0c             	sub    $0xc,%esp
8010375d:	50                   	push   %eax
8010375e:	e8 fa 13 00 00       	call   80104b5d <release>
80103763:	83 c4 10             	add    $0x10,%esp
}
80103766:	90                   	nop
80103767:	90                   	nop
80103768:	c9                   	leave  
80103769:	c3                   	ret    

8010376a <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	53                   	push   %ebx
8010376e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103771:	8b 45 08             	mov    0x8(%ebp),%eax
80103774:	83 ec 0c             	sub    $0xc,%esp
80103777:	50                   	push   %eax
80103778:	e8 72 13 00 00       	call   80104aef <acquire>
8010377d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103787:	e9 ad 00 00 00       	jmp    80103839 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010378c:	8b 45 08             	mov    0x8(%ebp),%eax
8010378f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103795:	85 c0                	test   %eax,%eax
80103797:	74 0c                	je     801037a5 <pipewrite+0x3b>
80103799:	e8 92 02 00 00       	call   80103a30 <myproc>
8010379e:	8b 40 24             	mov    0x24(%eax),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	74 19                	je     801037be <pipewrite+0x54>
        release(&p->lock);
801037a5:	8b 45 08             	mov    0x8(%ebp),%eax
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	50                   	push   %eax
801037ac:	e8 ac 13 00 00       	call   80104b5d <release>
801037b1:	83 c4 10             	add    $0x10,%esp
        return -1;
801037b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037b9:	e9 a9 00 00 00       	jmp    80103867 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037be:	8b 45 08             	mov    0x8(%ebp),%eax
801037c1:	05 34 02 00 00       	add    $0x234,%eax
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	50                   	push   %eax
801037ca:	e8 e6 0f 00 00       	call   801047b5 <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 e3 0e 00 00       	call   801046cb <sleep>
801037e8:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037eb:	8b 45 08             	mov    0x8(%ebp),%eax
801037ee:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f4:	8b 45 08             	mov    0x8(%ebp),%eax
801037f7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fd:	05 00 02 00 00       	add    $0x200,%eax
80103802:	39 c2                	cmp    %eax,%edx
80103804:	74 86                	je     8010378c <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103806:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010380f:	8b 45 08             	mov    0x8(%ebp),%eax
80103812:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103818:	8d 48 01             	lea    0x1(%eax),%ecx
8010381b:	8b 55 08             	mov    0x8(%ebp),%edx
8010381e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103824:	25 ff 01 00 00       	and    $0x1ff,%eax
80103829:	89 c1                	mov    %eax,%ecx
8010382b:	0f b6 13             	movzbl (%ebx),%edx
8010382e:	8b 45 08             	mov    0x8(%ebp),%eax
80103831:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103835:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010383f:	7c aa                	jl     801037eb <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103841:	8b 45 08             	mov    0x8(%ebp),%eax
80103844:	05 34 02 00 00       	add    $0x234,%eax
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	50                   	push   %eax
8010384d:	e8 63 0f 00 00       	call   801047b5 <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 fc 12 00 00       	call   80104b5d <release>
80103861:	83 c4 10             	add    $0x10,%esp
  return n;
80103864:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386a:	c9                   	leave  
8010386b:	c3                   	ret    

8010386c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010386c:	55                   	push   %ebp
8010386d:	89 e5                	mov    %esp,%ebp
8010386f:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103872:	8b 45 08             	mov    0x8(%ebp),%eax
80103875:	83 ec 0c             	sub    $0xc,%esp
80103878:	50                   	push   %eax
80103879:	e8 71 12 00 00       	call   80104aef <acquire>
8010387e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103881:	eb 3e                	jmp    801038c1 <piperead+0x55>
    if(myproc()->killed){
80103883:	e8 a8 01 00 00       	call   80103a30 <myproc>
80103888:	8b 40 24             	mov    0x24(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	74 19                	je     801038a8 <piperead+0x3c>
      release(&p->lock);
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 c2 12 00 00       	call   80104b5d <release>
8010389b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010389e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a3:	e9 be 00 00 00       	jmp    80103966 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a8:	8b 45 08             	mov    0x8(%ebp),%eax
801038ab:	8b 55 08             	mov    0x8(%ebp),%edx
801038ae:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b4:	83 ec 08             	sub    $0x8,%esp
801038b7:	50                   	push   %eax
801038b8:	52                   	push   %edx
801038b9:	e8 0d 0e 00 00       	call   801046cb <sleep>
801038be:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c1:	8b 45 08             	mov    0x8(%ebp),%eax
801038c4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038ca:	8b 45 08             	mov    0x8(%ebp),%eax
801038cd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d3:	39 c2                	cmp    %eax,%edx
801038d5:	75 0d                	jne    801038e4 <piperead+0x78>
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e0:	85 c0                	test   %eax,%eax
801038e2:	75 9f                	jne    80103883 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038eb:	eb 48                	jmp    80103935 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f6:	8b 45 08             	mov    0x8(%ebp),%eax
801038f9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038ff:	39 c2                	cmp    %eax,%edx
80103901:	74 3c                	je     8010393f <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103903:	8b 45 08             	mov    0x8(%ebp),%eax
80103906:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390c:	8d 48 01             	lea    0x1(%eax),%ecx
8010390f:	8b 55 08             	mov    0x8(%ebp),%edx
80103912:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103918:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391d:	89 c1                	mov    %eax,%ecx
8010391f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103922:	8b 45 0c             	mov    0xc(%ebp),%eax
80103925:	01 c2                	add    %eax,%edx
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010392f:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103931:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103938:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393b:	7c b0                	jl     801038ed <piperead+0x81>
8010393d:	eb 01                	jmp    80103940 <piperead+0xd4>
      break;
8010393f:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103940:	8b 45 08             	mov    0x8(%ebp),%eax
80103943:	05 38 02 00 00       	add    $0x238,%eax
80103948:	83 ec 0c             	sub    $0xc,%esp
8010394b:	50                   	push   %eax
8010394c:	e8 64 0e 00 00       	call   801047b5 <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 fd 11 00 00       	call   80104b5d <release>
80103960:	83 c4 10             	add    $0x10,%esp
  return i;
80103963:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103966:	c9                   	leave  
80103967:	c3                   	ret    

80103968 <readeflags>:
{
80103968:	55                   	push   %ebp
80103969:	89 e5                	mov    %esp,%ebp
8010396b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396e:	9c                   	pushf  
8010396f:	58                   	pop    %eax
80103970:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103973:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103976:	c9                   	leave  
80103977:	c3                   	ret    

80103978 <sti>:
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010397b:	fb                   	sti    
}
8010397c:	90                   	nop
8010397d:	5d                   	pop    %ebp
8010397e:	c3                   	ret    

8010397f <pinit>:
extern void trapret(void);

static void wakeup1(void *chan);

void pinit(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 70 a8 10 80       	push   $0x8010a870
8010398d:	68 00 4b 19 80       	push   $0x80194b00
80103992:	e8 36 11 00 00       	call   80104acd <initlock>
80103997:	83 c4 10             	add    $0x10,%esp
}
8010399a:	90                   	nop
8010399b:	c9                   	leave  
8010399c:	c3                   	ret    

8010399d <cpuid>:

// Must be called with interrupts disabled
int cpuid()
{
8010399d:	55                   	push   %ebp
8010399e:	89 e5                	mov    %esp,%ebp
801039a0:	83 ec 08             	sub    $0x8,%esp
  return mycpu() - cpus;
801039a3:	e8 10 00 00 00       	call   801039b8 <mycpu>
801039a8:	2d 80 74 19 80       	sub    $0x80197480,%eax
801039ad:	c1 f8 02             	sar    $0x2,%eax
801039b0:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
}
801039b6:	c9                   	leave  
801039b7:	c3                   	ret    

801039b8 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu *
mycpu(void)
{
801039b8:	55                   	push   %ebp
801039b9:	89 e5                	mov    %esp,%ebp
801039bb:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;

  if (readeflags() & FL_IF)
801039be:	e8 a5 ff ff ff       	call   80103968 <readeflags>
801039c3:	25 00 02 00 00       	and    $0x200,%eax
801039c8:	85 c0                	test   %eax,%eax
801039ca:	74 0d                	je     801039d9 <mycpu+0x21>
  {
    panic("mycpu called with interrupts enabled\n");
801039cc:	83 ec 0c             	sub    $0xc,%esp
801039cf:	68 78 a8 10 80       	push   $0x8010a878
801039d4:	e8 d0 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039d9:	e8 1c f1 ff ff       	call   80102afa <lapicid>
801039de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i)
801039e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e8:	eb 2d                	jmp    80103a17 <mycpu+0x5f>
  {
    if (cpus[i].apicid == apicid)
801039ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ed:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801039f3:	05 80 74 19 80       	add    $0x80197480,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
    {
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103a0c:	05 80 74 19 80       	add    $0x80197480,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i)
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 50 77 19 80       	mov    0x80197750,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 9e a8 10 80       	push   $0x8010a89e
80103a29:	e8 7b cb ff ff       	call   801005a9 <panic>
}
80103a2e:	c9                   	leave  
80103a2f:	c3                   	ret    

80103a30 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc *
myproc(void)
{
80103a30:	55                   	push   %ebp
80103a31:	89 e5                	mov    %esp,%ebp
80103a33:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a36:	e8 1f 12 00 00       	call   80104c5a <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 53 12 00 00       	call   80104ca7 <popcli>
  return p;
80103a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a57:	c9                   	leave  
80103a58:	c3                   	ret    

80103a59 <allocproc>:
//  If found, change state to EMBRYO and initialize
//  state required to run in the kernel.
//  Otherwise return 0.
static struct proc *
allocproc(void)
{
80103a59:	55                   	push   %ebp
80103a5a:	89 e5                	mov    %esp,%ebp
80103a5c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a5f:	83 ec 0c             	sub    $0xc,%esp
80103a62:	68 00 4b 19 80       	push   $0x80194b00
80103a67:	e8 83 10 00 00       	call   80104aef <acquire>
80103a6c:	83 c4 10             	add    $0x10,%esp

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6f:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
80103a76:	eb 11                	jmp    80103a89 <allocproc+0x30>
    if (p->state == UNUSED)
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	74 2a                	je     80103aac <allocproc+0x53>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a82:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80103a89:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
80103a90:	72 e6                	jb     80103a78 <allocproc+0x1f>
    {
      goto found;
    }

  release(&ptable.lock);
80103a92:	83 ec 0c             	sub    $0xc,%esp
80103a95:	68 00 4b 19 80       	push   $0x80194b00
80103a9a:	e8 be 10 00 00       	call   80104b5d <release>
80103a9f:	83 c4 10             	add    $0x10,%esp
  return 0;
80103aa2:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa7:	e9 0a 01 00 00       	jmp    80103bb6 <allocproc+0x15d>
      goto found;
80103aac:	90                   	nop

found:
  p->state = EMBRYO;
80103aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab7:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103abc:	8d 50 01             	lea    0x1(%eax),%edx
80103abf:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac8:	89 42 10             	mov    %eax,0x10(%edx)

  int idx = p - ptable.proc; // 해당 프로세스의 인덱스 계산
80103acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ace:	2d 34 4b 19 80       	sub    $0x80194b34,%eax
80103ad3:	c1 f8 02             	sar    $0x2,%eax
80103ad6:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
80103adc:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // MLFQ 전역 배열 초기화
  proc_priority[idx] = 3; // Q3가 가장 높은 우선순위
80103adf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ae2:	c7 04 85 00 42 19 80 	movl   $0x3,-0x7fe6be00(,%eax,4)
80103ae9:	03 00 00 00 
  memset(proc_ticks[idx], 0, sizeof(proc_ticks[idx]));
80103aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103af0:	c1 e0 04             	shl    $0x4,%eax
80103af3:	05 00 43 19 80       	add    $0x80194300,%eax
80103af8:	83 ec 04             	sub    $0x4,%esp
80103afb:	6a 10                	push   $0x10
80103afd:	6a 00                	push   $0x0
80103aff:	50                   	push   %eax
80103b00:	e8 60 12 00 00       	call   80104d65 <memset>
80103b05:	83 c4 10             	add    $0x10,%esp
  memset(proc_wait_ticks[idx], 0, sizeof(proc_wait_ticks[idx]));
80103b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b0b:	c1 e0 04             	shl    $0x4,%eax
80103b0e:	05 00 47 19 80       	add    $0x80194700,%eax
80103b13:	83 ec 04             	sub    $0x4,%esp
80103b16:	6a 10                	push   $0x10
80103b18:	6a 00                	push   $0x0
80103b1a:	50                   	push   %eax
80103b1b:	e8 45 12 00 00       	call   80104d65 <memset>
80103b20:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103b23:	83 ec 0c             	sub    $0xc,%esp
80103b26:	68 00 4b 19 80       	push   $0x80194b00
80103b2b:	e8 2d 10 00 00       	call   80104b5d <release>
80103b30:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if ((p->kstack = kalloc()) == 0)
80103b33:	e8 68 ec ff ff       	call   801027a0 <kalloc>
80103b38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b3b:	89 42 08             	mov    %eax,0x8(%edx)
80103b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b41:	8b 40 08             	mov    0x8(%eax),%eax
80103b44:	85 c0                	test   %eax,%eax
80103b46:	75 11                	jne    80103b59 <allocproc+0x100>
  {
    p->state = UNUSED;
80103b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103b52:	b8 00 00 00 00       	mov    $0x0,%eax
80103b57:	eb 5d                	jmp    80103bb6 <allocproc+0x15d>
  }
  sp = p->kstack + KSTACKSIZE;
80103b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b5c:	8b 40 08             	mov    0x8(%eax),%eax
80103b5f:	05 00 10 00 00       	add    $0x1000,%eax
80103b64:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b67:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe *)sp;
80103b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b71:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b74:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint *)sp = (uint)trapret;
80103b78:	ba 28 63 10 80       	mov    $0x80106328,%edx
80103b7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b80:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b82:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context *)sp;
80103b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b89:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b8c:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b92:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b95:	83 ec 04             	sub    $0x4,%esp
80103b98:	6a 14                	push   $0x14
80103b9a:	6a 00                	push   $0x0
80103b9c:	50                   	push   %eax
80103b9d:	e8 c3 11 00 00       	call   80104d65 <memset>
80103ba2:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba8:	8b 40 1c             	mov    0x1c(%eax),%eax
80103bab:	ba 85 46 10 80       	mov    $0x80104685,%edx
80103bb0:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103bb6:	c9                   	leave  
80103bb7:	c3                   	ret    

80103bb8 <userinit>:

// PAGEBREAK: 32
//  Set up first user process.
void userinit(void)
{
80103bb8:	55                   	push   %ebp
80103bb9:	89 e5                	mov    %esp,%ebp
80103bbb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103bbe:	e8 96 fe ff ff       	call   80103a59 <allocproc>
80103bc3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  initproc = p;
80103bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc9:	a3 34 6c 19 80       	mov    %eax,0x80196c34
  if ((p->pgdir = setupkvm()) == 0)
80103bce:	e8 00 3d 00 00       	call   801078d3 <setupkvm>
80103bd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bd6:	89 42 04             	mov    %eax,0x4(%edx)
80103bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bdc:	8b 40 04             	mov    0x4(%eax),%eax
80103bdf:	85 c0                	test   %eax,%eax
80103be1:	75 0d                	jne    80103bf0 <userinit+0x38>
  {
    panic("userinit: out of memory?");
80103be3:	83 ec 0c             	sub    $0xc,%esp
80103be6:	68 ae a8 10 80       	push   $0x8010a8ae
80103beb:	e8 b9 c9 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103bf0:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf8:	8b 40 04             	mov    0x4(%eax),%eax
80103bfb:	83 ec 04             	sub    $0x4,%esp
80103bfe:	52                   	push   %edx
80103bff:	68 0c f5 10 80       	push   $0x8010f50c
80103c04:	50                   	push   %eax
80103c05:	e8 85 3f 00 00       	call   80107b8f <inituvm>
80103c0a:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c10:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c19:	8b 40 18             	mov    0x18(%eax),%eax
80103c1c:	83 ec 04             	sub    $0x4,%esp
80103c1f:	6a 4c                	push   $0x4c
80103c21:	6a 00                	push   $0x0
80103c23:	50                   	push   %eax
80103c24:	e8 3c 11 00 00       	call   80104d65 <memset>
80103c29:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2f:	8b 40 18             	mov    0x18(%eax),%eax
80103c32:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3b:	8b 40 18             	mov    0x18(%eax),%eax
80103c3e:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c47:	8b 50 18             	mov    0x18(%eax),%edx
80103c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c4d:	8b 40 18             	mov    0x18(%eax),%eax
80103c50:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c54:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5b:	8b 50 18             	mov    0x18(%eax),%edx
80103c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c61:	8b 40 18             	mov    0x18(%eax),%eax
80103c64:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c68:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6f:	8b 40 18             	mov    0x18(%eax),%eax
80103c72:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7c:	8b 40 18             	mov    0x18(%eax),%eax
80103c7f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0; // beginning of initcode.S
80103c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c89:	8b 40 18             	mov    0x18(%eax),%eax
80103c8c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c96:	83 c0 6c             	add    $0x6c,%eax
80103c99:	83 ec 04             	sub    $0x4,%esp
80103c9c:	6a 10                	push   $0x10
80103c9e:	68 c7 a8 10 80       	push   $0x8010a8c7
80103ca3:	50                   	push   %eax
80103ca4:	e8 bf 12 00 00       	call   80104f68 <safestrcpy>
80103ca9:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103cac:	83 ec 0c             	sub    $0xc,%esp
80103caf:	68 d0 a8 10 80       	push   $0x8010a8d0
80103cb4:	e8 64 e8 ff ff       	call   8010251d <namei>
80103cb9:	83 c4 10             	add    $0x10,%esp
80103cbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cbf:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103cc2:	83 ec 0c             	sub    $0xc,%esp
80103cc5:	68 00 4b 19 80       	push   $0x80194b00
80103cca:	e8 20 0e 00 00       	call   80104aef <acquire>
80103ccf:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103cdc:	83 ec 0c             	sub    $0xc,%esp
80103cdf:	68 00 4b 19 80       	push   $0x80194b00
80103ce4:	e8 74 0e 00 00       	call   80104b5d <release>
80103ce9:	83 c4 10             	add    $0x10,%esp
}
80103cec:	90                   	nop
80103ced:	c9                   	leave  
80103cee:	c3                   	ret    

80103cef <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int growproc(int n)
{
80103cef:	55                   	push   %ebp
80103cf0:	89 e5                	mov    %esp,%ebp
80103cf2:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103cf5:	e8 36 fd ff ff       	call   80103a30 <myproc>
80103cfa:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103cfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d00:	8b 00                	mov    (%eax),%eax
80103d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (n > 0)
80103d05:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d09:	7e 2e                	jle    80103d39 <growproc+0x4a>
  {
    if ((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d0b:	8b 55 08             	mov    0x8(%ebp),%edx
80103d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d11:	01 c2                	add    %eax,%edx
80103d13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d16:	8b 40 04             	mov    0x4(%eax),%eax
80103d19:	83 ec 04             	sub    $0x4,%esp
80103d1c:	52                   	push   %edx
80103d1d:	ff 75 f4             	push   -0xc(%ebp)
80103d20:	50                   	push   %eax
80103d21:	e8 a6 3f 00 00       	call   80107ccc <allocuvm>
80103d26:	83 c4 10             	add    $0x10,%esp
80103d29:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d2c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d30:	75 3b                	jne    80103d6d <growproc+0x7e>
      return -1;
80103d32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d37:	eb 4f                	jmp    80103d88 <growproc+0x99>
  }
  else if (n < 0)
80103d39:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d3d:	79 2e                	jns    80103d6d <growproc+0x7e>
  {
    if ((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d3f:	8b 55 08             	mov    0x8(%ebp),%edx
80103d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d45:	01 c2                	add    %eax,%edx
80103d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d4a:	8b 40 04             	mov    0x4(%eax),%eax
80103d4d:	83 ec 04             	sub    $0x4,%esp
80103d50:	52                   	push   %edx
80103d51:	ff 75 f4             	push   -0xc(%ebp)
80103d54:	50                   	push   %eax
80103d55:	e8 77 40 00 00       	call   80107dd1 <deallocuvm>
80103d5a:	83 c4 10             	add    $0x10,%esp
80103d5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d60:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d64:	75 07                	jne    80103d6d <growproc+0x7e>
      return -1;
80103d66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d6b:	eb 1b                	jmp    80103d88 <growproc+0x99>
  }
  curproc->sz = sz;
80103d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d73:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d75:	83 ec 0c             	sub    $0xc,%esp
80103d78:	ff 75 f0             	push   -0x10(%ebp)
80103d7b:	e8 70 3c 00 00       	call   801079f0 <switchuvm>
80103d80:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d83:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d88:	c9                   	leave  
80103d89:	c3                   	ret    

80103d8a <fork>:

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int fork(void)
{
80103d8a:	55                   	push   %ebp
80103d8b:	89 e5                	mov    %esp,%ebp
80103d8d:	57                   	push   %edi
80103d8e:	56                   	push   %esi
80103d8f:	53                   	push   %ebx
80103d90:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d93:	e8 98 fc ff ff       	call   80103a30 <myproc>
80103d98:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if ((np = allocproc()) == 0)
80103d9b:	e8 b9 fc ff ff       	call   80103a59 <allocproc>
80103da0:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103da3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103da7:	75 0a                	jne    80103db3 <fork+0x29>
  {
    return -1;
80103da9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dae:	e9 48 01 00 00       	jmp    80103efb <fork+0x171>
  }

  // Copy process state from proc.
  if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0)
80103db3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db6:	8b 10                	mov    (%eax),%edx
80103db8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dbb:	8b 40 04             	mov    0x4(%eax),%eax
80103dbe:	83 ec 08             	sub    $0x8,%esp
80103dc1:	52                   	push   %edx
80103dc2:	50                   	push   %eax
80103dc3:	e8 a7 41 00 00       	call   80107f6f <copyuvm>
80103dc8:	83 c4 10             	add    $0x10,%esp
80103dcb:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103dce:	89 42 04             	mov    %eax,0x4(%edx)
80103dd1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dd4:	8b 40 04             	mov    0x4(%eax),%eax
80103dd7:	85 c0                	test   %eax,%eax
80103dd9:	75 30                	jne    80103e0b <fork+0x81>
  {
    kfree(np->kstack);
80103ddb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dde:	8b 40 08             	mov    0x8(%eax),%eax
80103de1:	83 ec 0c             	sub    $0xc,%esp
80103de4:	50                   	push   %eax
80103de5:	e8 1c e9 ff ff       	call   80102706 <kfree>
80103dea:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103ded:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103df0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103df7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dfa:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103e01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e06:	e9 f0 00 00 00       	jmp    80103efb <fork+0x171>
  }
  np->sz = curproc->sz;
80103e0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e0e:	8b 10                	mov    (%eax),%edx
80103e10:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e13:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e18:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103e1b:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103e1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e21:	8b 48 18             	mov    0x18(%eax),%ecx
80103e24:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e27:	8b 40 18             	mov    0x18(%eax),%eax
80103e2a:	89 c2                	mov    %eax,%edx
80103e2c:	89 cb                	mov    %ecx,%ebx
80103e2e:	b8 13 00 00 00       	mov    $0x13,%eax
80103e33:	89 d7                	mov    %edx,%edi
80103e35:	89 de                	mov    %ebx,%esi
80103e37:	89 c1                	mov    %eax,%ecx
80103e39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103e3b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e3e:	8b 40 18             	mov    0x18(%eax),%eax
80103e41:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for (i = 0; i < NOFILE; i++)
80103e48:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103e4f:	eb 3b                	jmp    80103e8c <fork+0x102>
    if (curproc->ofile[i])
80103e51:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e57:	83 c2 08             	add    $0x8,%edx
80103e5a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e5e:	85 c0                	test   %eax,%eax
80103e60:	74 26                	je     80103e88 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e62:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e65:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e68:	83 c2 08             	add    $0x8,%edx
80103e6b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e6f:	83 ec 0c             	sub    $0xc,%esp
80103e72:	50                   	push   %eax
80103e73:	e8 d2 d1 ff ff       	call   8010104a <filedup>
80103e78:	83 c4 10             	add    $0x10,%esp
80103e7b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e7e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e81:	83 c1 08             	add    $0x8,%ecx
80103e84:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for (i = 0; i < NOFILE; i++)
80103e88:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e8c:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e90:	7e bf                	jle    80103e51 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e92:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e95:	8b 40 68             	mov    0x68(%eax),%eax
80103e98:	83 ec 0c             	sub    $0xc,%esp
80103e9b:	50                   	push   %eax
80103e9c:	e8 0f db ff ff       	call   801019b0 <idup>
80103ea1:	83 c4 10             	add    $0x10,%esp
80103ea4:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103ea7:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103eaa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ead:	8d 50 6c             	lea    0x6c(%eax),%edx
80103eb0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103eb3:	83 c0 6c             	add    $0x6c,%eax
80103eb6:	83 ec 04             	sub    $0x4,%esp
80103eb9:	6a 10                	push   $0x10
80103ebb:	52                   	push   %edx
80103ebc:	50                   	push   %eax
80103ebd:	e8 a6 10 00 00       	call   80104f68 <safestrcpy>
80103ec2:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103ec5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ec8:	8b 40 10             	mov    0x10(%eax),%eax
80103ecb:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103ece:	83 ec 0c             	sub    $0xc,%esp
80103ed1:	68 00 4b 19 80       	push   $0x80194b00
80103ed6:	e8 14 0c 00 00       	call   80104aef <acquire>
80103edb:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103ede:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ee1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103ee8:	83 ec 0c             	sub    $0xc,%esp
80103eeb:	68 00 4b 19 80       	push   $0x80194b00
80103ef0:	e8 68 0c 00 00       	call   80104b5d <release>
80103ef5:	83 c4 10             	add    $0x10,%esp

  return pid;
80103ef8:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103efb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103efe:	5b                   	pop    %ebx
80103eff:	5e                   	pop    %esi
80103f00:	5f                   	pop    %edi
80103f01:	5d                   	pop    %ebp
80103f02:	c3                   	ret    

80103f03 <exit>:

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void exit(void)
{
80103f03:	55                   	push   %ebp
80103f04:	89 e5                	mov    %esp,%ebp
80103f06:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103f09:	e8 22 fb ff ff       	call   80103a30 <myproc>
80103f0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if (curproc == initproc)
80103f11:	a1 34 6c 19 80       	mov    0x80196c34,%eax
80103f16:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f19:	75 0d                	jne    80103f28 <exit+0x25>
    panic("init exiting");
80103f1b:	83 ec 0c             	sub    $0xc,%esp
80103f1e:	68 d2 a8 10 80       	push   $0x8010a8d2
80103f23:	e8 81 c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for (fd = 0; fd < NOFILE; fd++)
80103f28:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103f2f:	eb 3f                	jmp    80103f70 <exit+0x6d>
  {
    if (curproc->ofile[fd])
80103f31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f34:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f37:	83 c2 08             	add    $0x8,%edx
80103f3a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f3e:	85 c0                	test   %eax,%eax
80103f40:	74 2a                	je     80103f6c <exit+0x69>
    {
      fileclose(curproc->ofile[fd]);
80103f42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f45:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f48:	83 c2 08             	add    $0x8,%edx
80103f4b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f4f:	83 ec 0c             	sub    $0xc,%esp
80103f52:	50                   	push   %eax
80103f53:	e8 43 d1 ff ff       	call   8010109b <fileclose>
80103f58:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f5e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f61:	83 c2 08             	add    $0x8,%edx
80103f64:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f6b:	00 
  for (fd = 0; fd < NOFILE; fd++)
80103f6c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f70:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f74:	7e bb                	jle    80103f31 <exit+0x2e>
    }
  }

  begin_op();
80103f76:	e8 c1 f0 ff ff       	call   8010303c <begin_op>
  iput(curproc->cwd);
80103f7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f7e:	8b 40 68             	mov    0x68(%eax),%eax
80103f81:	83 ec 0c             	sub    $0xc,%esp
80103f84:	50                   	push   %eax
80103f85:	e8 c1 db ff ff       	call   80101b4b <iput>
80103f8a:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f8d:	e8 36 f1 ff ff       	call   801030c8 <end_op>
  curproc->cwd = 0;
80103f92:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f95:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f9c:	83 ec 0c             	sub    $0xc,%esp
80103f9f:	68 00 4b 19 80       	push   $0x80194b00
80103fa4:	e8 46 0b 00 00       	call   80104aef <acquire>
80103fa9:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103fac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103faf:	8b 40 14             	mov    0x14(%eax),%eax
80103fb2:	83 ec 0c             	sub    $0xc,%esp
80103fb5:	50                   	push   %eax
80103fb6:	e8 b7 07 00 00       	call   80104772 <wakeup1>
80103fbb:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103fbe:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
80103fc5:	eb 3a                	jmp    80104001 <exit+0xfe>
  {
    if (p->parent == curproc)
80103fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fca:	8b 40 14             	mov    0x14(%eax),%eax
80103fcd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103fd0:	75 28                	jne    80103ffa <exit+0xf7>
    {
      p->parent = initproc;
80103fd2:	8b 15 34 6c 19 80    	mov    0x80196c34,%edx
80103fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fdb:	89 50 14             	mov    %edx,0x14(%eax)
      if (p->state == ZOMBIE)
80103fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe1:	8b 40 0c             	mov    0xc(%eax),%eax
80103fe4:	83 f8 05             	cmp    $0x5,%eax
80103fe7:	75 11                	jne    80103ffa <exit+0xf7>
        wakeup1(initproc);
80103fe9:	a1 34 6c 19 80       	mov    0x80196c34,%eax
80103fee:	83 ec 0c             	sub    $0xc,%esp
80103ff1:	50                   	push   %eax
80103ff2:	e8 7b 07 00 00       	call   80104772 <wakeup1>
80103ff7:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103ffa:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104001:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
80104008:	72 bd                	jb     80103fc7 <exit+0xc4>
    }
  }

  int idx = myproc() - ptable.proc;
8010400a:	e8 21 fa ff ff       	call   80103a30 <myproc>
8010400f:	2d 34 4b 19 80       	sub    $0x80194b34,%eax
80104014:	c1 f8 02             	sar    $0x2,%eax
80104017:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
8010401d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  proc_ticks[idx][proc_priority[idx]]++;
80104020:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104023:	8b 0c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ecx
8010402a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010402d:	c1 e0 02             	shl    $0x2,%eax
80104030:	01 c8                	add    %ecx,%eax
80104032:	8b 04 85 00 43 19 80 	mov    -0x7fe6bd00(,%eax,4),%eax
80104039:	8d 50 01             	lea    0x1(%eax),%edx
8010403c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010403f:	c1 e0 02             	shl    $0x2,%eax
80104042:	01 c8                	add    %ecx,%eax
80104044:	89 14 85 00 43 19 80 	mov    %edx,-0x7fe6bd00(,%eax,4)

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010404b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010404e:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104055:	e8 f7 04 00 00       	call   80104551 <sched>
  panic("zombie exit");
8010405a:	83 ec 0c             	sub    $0xc,%esp
8010405d:	68 df a8 10 80       	push   $0x8010a8df
80104062:	e8 42 c5 ff ff       	call   801005a9 <panic>

80104067 <wait>:
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int wait(void)
{
80104067:	55                   	push   %ebp
80104068:	89 e5                	mov    %esp,%ebp
8010406a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010406d:	e8 be f9 ff ff       	call   80103a30 <myproc>
80104072:	89 45 ec             	mov    %eax,-0x14(%ebp)

  acquire(&ptable.lock);
80104075:	83 ec 0c             	sub    $0xc,%esp
80104078:	68 00 4b 19 80       	push   $0x80194b00
8010407d:	e8 6d 0a 00 00       	call   80104aef <acquire>
80104082:	83 c4 10             	add    $0x10,%esp
  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
80104085:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010408c:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
80104093:	e9 a4 00 00 00       	jmp    8010413c <wait+0xd5>
    {
      if (p->parent != curproc)
80104098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409b:	8b 40 14             	mov    0x14(%eax),%eax
8010409e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801040a1:	0f 85 8d 00 00 00    	jne    80104134 <wait+0xcd>
        continue;
      havekids = 1;
801040a7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if (p->state == ZOMBIE)
801040ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b1:	8b 40 0c             	mov    0xc(%eax),%eax
801040b4:	83 f8 05             	cmp    $0x5,%eax
801040b7:	75 7c                	jne    80104135 <wait+0xce>
      {
        // Found one.
        pid = p->pid;
801040b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040bc:	8b 40 10             	mov    0x10(%eax),%eax
801040bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801040c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c5:	8b 40 08             	mov    0x8(%eax),%eax
801040c8:	83 ec 0c             	sub    $0xc,%esp
801040cb:	50                   	push   %eax
801040cc:	e8 35 e6 ff ff       	call   80102706 <kfree>
801040d1:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801040d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801040de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e1:	8b 40 04             	mov    0x4(%eax),%eax
801040e4:	83 ec 0c             	sub    $0xc,%esp
801040e7:	50                   	push   %eax
801040e8:	e8 a8 3d 00 00       	call   80107e95 <freevm>
801040ed:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801040f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f3:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801040fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040fd:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104107:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010410b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010410e:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104118:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010411f:	83 ec 0c             	sub    $0xc,%esp
80104122:	68 00 4b 19 80       	push   $0x80194b00
80104127:	e8 31 0a 00 00       	call   80104b5d <release>
8010412c:	83 c4 10             	add    $0x10,%esp
        return pid;
8010412f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104132:	eb 54                	jmp    80104188 <wait+0x121>
        continue;
80104134:	90                   	nop
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104135:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010413c:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
80104143:	0f 82 4f ff ff ff    	jb     80104098 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if (!havekids || curproc->killed)
80104149:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010414d:	74 0a                	je     80104159 <wait+0xf2>
8010414f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104152:	8b 40 24             	mov    0x24(%eax),%eax
80104155:	85 c0                	test   %eax,%eax
80104157:	74 17                	je     80104170 <wait+0x109>
    {
      release(&ptable.lock);
80104159:	83 ec 0c             	sub    $0xc,%esp
8010415c:	68 00 4b 19 80       	push   $0x80194b00
80104161:	e8 f7 09 00 00       	call   80104b5d <release>
80104166:	83 c4 10             	add    $0x10,%esp
      return -1;
80104169:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010416e:	eb 18                	jmp    80104188 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock); // DOC: wait-sleep
80104170:	83 ec 08             	sub    $0x8,%esp
80104173:	68 00 4b 19 80       	push   $0x80194b00
80104178:	ff 75 ec             	push   -0x14(%ebp)
8010417b:	e8 4b 05 00 00       	call   801046cb <sleep>
80104180:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104183:	e9 fd fe ff ff       	jmp    80104085 <wait+0x1e>
  }
}
80104188:	c9                   	leave  
80104189:	c3                   	ret    

8010418a <scheduler>:
//   - choose a process to run
//   - swtch to start running that process
//   - eventually that process transfers control
//       via swtch back to the scheduler.
void scheduler(void)
{
8010418a:	55                   	push   %ebp
8010418b:	89 e5                	mov    %esp,%ebp
8010418d:	83 ec 58             	sub    $0x58,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104190:	e8 23 f8 ff ff       	call   801039b8 <mycpu>
80104195:	89 45 e8             	mov    %eax,-0x18(%ebp)
  c->proc = 0;
80104198:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010419b:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801041a2:	00 00 00 

  for (;;) {
    sti(); // Enable interrupts
801041a5:	e8 ce f7 ff ff       	call   80103978 <sti>
    acquire(&ptable.lock);
801041aa:	83 ec 0c             	sub    $0xc,%esp
801041ad:	68 00 4b 19 80       	push   $0x80194b00
801041b2:	e8 38 09 00 00       	call   80104aef <acquire>
801041b7:	83 c4 10             	add    $0x10,%esp

    int policy = c->sched_policy;
801041ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041bd:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801041c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    struct proc *chosen = 0;
801041c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

    if (policy == 0) {
801041cd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801041d1:	75 7b                	jne    8010424e <scheduler+0xc4>
      // Round-robin scheduling
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801041d3:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
801041da:	eb 64                	jmp    80104240 <scheduler+0xb6>
        if (p->state != RUNNABLE)
801041dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041df:	8b 40 0c             	mov    0xc(%eax),%eax
801041e2:	83 f8 03             	cmp    $0x3,%eax
801041e5:	75 51                	jne    80104238 <scheduler+0xae>
          continue;

        c->proc = p;
801041e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041ed:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
801041f3:	83 ec 0c             	sub    $0xc,%esp
801041f6:	ff 75 f4             	push   -0xc(%ebp)
801041f9:	e8 f2 37 00 00       	call   801079f0 <switchuvm>
801041fe:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
80104201:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104204:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
8010420b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010420e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104211:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104214:	83 c2 04             	add    $0x4,%edx
80104217:	83 ec 08             	sub    $0x8,%esp
8010421a:	50                   	push   %eax
8010421b:	52                   	push   %edx
8010421c:	e8 b9 0d 00 00       	call   80104fda <swtch>
80104221:	83 c4 10             	add    $0x10,%esp
        switchkvm();
80104224:	e8 ae 37 00 00       	call   801079d7 <switchkvm>

        c->proc = 0;
80104229:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010422c:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104233:	00 00 00 
80104236:	eb 01                	jmp    80104239 <scheduler+0xaf>
          continue;
80104238:	90                   	nop
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104239:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104240:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
80104247:	72 93                	jb     801041dc <scheduler+0x52>
80104249:	e9 ee 02 00 00       	jmp    8010453c <scheduler+0x3b2>
      }
    } else {
      // MLFQ scheduling
      int level;
      for (level = 3; level >= 0; level--) {
8010424e:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)
80104255:	eb 53                	jmp    801042aa <scheduler+0x120>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104257:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
8010425e:	eb 3d                	jmp    8010429d <scheduler+0x113>
          int idx = p - ptable.proc;
80104260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104263:	2d 34 4b 19 80       	sub    $0x80194b34,%eax
80104268:	c1 f8 02             	sar    $0x2,%eax
8010426b:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
80104271:	89 45 e0             	mov    %eax,-0x20(%ebp)
          if (p->state == RUNNABLE && proc_priority[idx] == level) {
80104274:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104277:	8b 40 0c             	mov    0xc(%eax),%eax
8010427a:	83 f8 03             	cmp    $0x3,%eax
8010427d:	75 17                	jne    80104296 <scheduler+0x10c>
8010427f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104282:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104289:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010428c:	75 08                	jne    80104296 <scheduler+0x10c>
            chosen = p;
8010428e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104291:	89 45 f0             	mov    %eax,-0x10(%ebp)
            goto found;
80104294:	eb 1b                	jmp    801042b1 <scheduler+0x127>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104296:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010429d:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
801042a4:	72 ba                	jb     80104260 <scheduler+0xd6>
      for (level = 3; level >= 0; level--) {
801042a6:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
801042aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801042ae:	79 a7                	jns    80104257 <scheduler+0xcd>
          }
        }
      }

    found:
801042b0:	90                   	nop
      if (chosen) {
801042b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801042b5:	0f 84 15 01 00 00    	je     801043d0 <scheduler+0x246>
        int cidx = chosen - ptable.proc;
801042bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042be:	2d 34 4b 19 80       	sub    $0x80194b34,%eax
801042c3:	c1 f8 02             	sar    $0x2,%eax
801042c6:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
801042cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
        c->proc = chosen;
801042cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801042d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801042d5:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(chosen);
801042db:	83 ec 0c             	sub    $0xc,%esp
801042de:	ff 75 f0             	push   -0x10(%ebp)
801042e1:	e8 0a 37 00 00       	call   801079f0 <switchuvm>
801042e6:	83 c4 10             	add    $0x10,%esp
        chosen->state = RUNNING;
801042e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042ec:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&c->scheduler, chosen->context);
801042f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042f6:	8b 40 1c             	mov    0x1c(%eax),%eax
801042f9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801042fc:	83 c2 04             	add    $0x4,%edx
801042ff:	83 ec 08             	sub    $0x8,%esp
80104302:	50                   	push   %eax
80104303:	52                   	push   %edx
80104304:	e8 d1 0c 00 00       	call   80104fda <swtch>
80104309:	83 c4 10             	add    $0x10,%esp
        switchkvm();
8010430c:	e8 c6 36 00 00       	call   801079d7 <switchkvm>

        proc_ticks[cidx][proc_priority[cidx]]++;
80104311:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104314:	8b 0c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ecx
8010431b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010431e:	c1 e0 02             	shl    $0x2,%eax
80104321:	01 c8                	add    %ecx,%eax
80104323:	8b 04 85 00 43 19 80 	mov    -0x7fe6bd00(,%eax,4),%eax
8010432a:	8d 50 01             	lea    0x1(%eax),%edx
8010432d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104330:	c1 e0 02             	shl    $0x2,%eax
80104333:	01 c8                	add    %ecx,%eax
80104335:	89 14 85 00 43 19 80 	mov    %edx,-0x7fe6bd00(,%eax,4)

        if (proc_ticks[cidx][proc_priority[cidx]] >= (int[]){0,32,16,8}[proc_priority[cidx]]
8010433c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010433f:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
80104346:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104349:	c1 e0 02             	shl    $0x2,%eax
8010434c:	01 d0                	add    %edx,%eax
8010434e:	8b 14 85 00 43 19 80 	mov    -0x7fe6bd00(,%eax,4),%edx
80104355:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%ebp)
8010435c:	c7 45 c0 20 00 00 00 	movl   $0x20,-0x40(%ebp)
80104363:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
8010436a:	c7 45 c8 08 00 00 00 	movl   $0x8,-0x38(%ebp)
80104371:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104374:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
8010437b:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
8010437f:	39 c2                	cmp    %eax,%edx
80104381:	7c 40                	jl     801043c3 <scheduler+0x239>
            && proc_priority[cidx] > 0) {
80104383:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104386:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
8010438d:	85 c0                	test   %eax,%eax
8010438f:	7e 32                	jle    801043c3 <scheduler+0x239>
          proc_priority[cidx]--;
80104391:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104394:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
8010439b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010439e:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043a1:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
          memset(proc_wait_ticks[cidx], 0, sizeof(proc_wait_ticks[cidx]));
801043a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043ab:	c1 e0 04             	shl    $0x4,%eax
801043ae:	05 00 47 19 80       	add    $0x80194700,%eax
801043b3:	83 ec 04             	sub    $0x4,%esp
801043b6:	6a 10                	push   $0x10
801043b8:	6a 00                	push   $0x0
801043ba:	50                   	push   %eax
801043bb:	e8 a5 09 00 00       	call   80104d65 <memset>
801043c0:	83 c4 10             	add    $0x10,%esp
        }

        c->proc = 0;
801043c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801043c6:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801043cd:	00 00 00 
      }

      // wait_ticks 증가
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801043d0:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
801043d7:	eb 59                	jmp    80104432 <scheduler+0x2a8>
        int idx = p - ptable.proc;
801043d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043dc:	2d 34 4b 19 80       	sub    $0x80194b34,%eax
801043e1:	c1 f8 02             	sar    $0x2,%eax
801043e4:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
801043ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
        if (p->state == RUNNABLE && p != chosen) {
801043ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f0:	8b 40 0c             	mov    0xc(%eax),%eax
801043f3:	83 f8 03             	cmp    $0x3,%eax
801043f6:	75 33                	jne    8010442b <scheduler+0x2a1>
801043f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801043fe:	74 2b                	je     8010442b <scheduler+0x2a1>
          proc_wait_ticks[idx][proc_priority[idx]]++;
80104400:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104403:	8b 0c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ecx
8010440a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010440d:	c1 e0 02             	shl    $0x2,%eax
80104410:	01 c8                	add    %ecx,%eax
80104412:	8b 04 85 00 47 19 80 	mov    -0x7fe6b900(,%eax,4),%eax
80104419:	8d 50 01             	lea    0x1(%eax),%edx
8010441c:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010441f:	c1 e0 02             	shl    $0x2,%eax
80104422:	01 c8                	add    %ecx,%eax
80104424:	89 14 85 00 47 19 80 	mov    %edx,-0x7fe6b900(,%eax,4)
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010442b:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104432:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
80104439:	72 9e                	jb     801043d9 <scheduler+0x24f>
        }
      }

      // Boosting (policy 1, 2만)
      if (policy != 3) {
8010443b:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
8010443f:	0f 84 f7 00 00 00    	je     8010453c <scheduler+0x3b2>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104445:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
8010444c:	e9 de 00 00 00       	jmp    8010452f <scheduler+0x3a5>
          int idx = p - ptable.proc;
80104451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104454:	2d 34 4b 19 80       	sub    $0x80194b34,%eax
80104459:	c1 f8 02             	sar    $0x2,%eax
8010445c:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
80104462:	89 45 d8             	mov    %eax,-0x28(%ebp)
          if (p->state == RUNNABLE && proc_priority[idx] < 3) {
80104465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104468:	8b 40 0c             	mov    0xc(%eax),%eax
8010446b:	83 f8 03             	cmp    $0x3,%eax
8010446e:	0f 85 b4 00 00 00    	jne    80104528 <scheduler+0x39e>
80104474:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104477:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
8010447e:	83 f8 02             	cmp    $0x2,%eax
80104481:	0f 8f a1 00 00 00    	jg     80104528 <scheduler+0x39e>
            int waited = proc_wait_ticks[idx][proc_priority[idx]];
80104487:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010448a:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
80104491:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104494:	c1 e0 02             	shl    $0x2,%eax
80104497:	01 d0                	add    %edx,%eax
80104499:	8b 04 85 00 47 19 80 	mov    -0x7fe6b900(,%eax,4),%eax
801044a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
            int required = (proc_priority[idx] == 0) ? 500 : 10 * (int[]){0,32,16,8}[proc_priority[idx]];
801044a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801044a6:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
801044ad:	85 c0                	test   %eax,%eax
801044af:	74 35                	je     801044e6 <scheduler+0x35c>
801044b1:	c7 45 ac 00 00 00 00 	movl   $0x0,-0x54(%ebp)
801044b8:	c7 45 b0 20 00 00 00 	movl   $0x20,-0x50(%ebp)
801044bf:	c7 45 b4 10 00 00 00 	movl   $0x10,-0x4c(%ebp)
801044c6:	c7 45 b8 08 00 00 00 	movl   $0x8,-0x48(%ebp)
801044cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801044d0:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
801044d7:	8b 54 85 ac          	mov    -0x54(%ebp,%eax,4),%edx
801044db:	89 d0                	mov    %edx,%eax
801044dd:	c1 e0 02             	shl    $0x2,%eax
801044e0:	01 d0                	add    %edx,%eax
801044e2:	01 c0                	add    %eax,%eax
801044e4:	eb 05                	jmp    801044eb <scheduler+0x361>
801044e6:	b8 f4 01 00 00       	mov    $0x1f4,%eax
801044eb:	89 45 d0             	mov    %eax,-0x30(%ebp)

            if (waited >= required) {
801044ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801044f1:	3b 45 d0             	cmp    -0x30(%ebp),%eax
801044f4:	7c 32                	jl     80104528 <scheduler+0x39e>
              proc_priority[idx]++;
801044f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801044f9:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104500:	8d 50 01             	lea    0x1(%eax),%edx
80104503:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104506:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
              memset(proc_wait_ticks[idx], 0, sizeof(proc_wait_ticks[idx]));
8010450d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104510:	c1 e0 04             	shl    $0x4,%eax
80104513:	05 00 47 19 80       	add    $0x80194700,%eax
80104518:	83 ec 04             	sub    $0x4,%esp
8010451b:	6a 10                	push   $0x10
8010451d:	6a 00                	push   $0x0
8010451f:	50                   	push   %eax
80104520:	e8 40 08 00 00       	call   80104d65 <memset>
80104525:	83 c4 10             	add    $0x10,%esp
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104528:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010452f:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
80104536:	0f 82 15 ff ff ff    	jb     80104451 <scheduler+0x2c7>
          }
        }
      }
    }

    release(&ptable.lock);
8010453c:	83 ec 0c             	sub    $0xc,%esp
8010453f:	68 00 4b 19 80       	push   $0x80194b00
80104544:	e8 14 06 00 00       	call   80104b5d <release>
80104549:	83 c4 10             	add    $0x10,%esp
  for (;;) {
8010454c:	e9 54 fc ff ff       	jmp    801041a5 <scheduler+0x1b>

80104551 <sched>:
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void sched(void)
{
80104551:	55                   	push   %ebp
80104552:	89 e5                	mov    %esp,%ebp
80104554:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104557:	e8 d4 f4 ff ff       	call   80103a30 <myproc>
8010455c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if (!holding(&ptable.lock))
8010455f:	83 ec 0c             	sub    $0xc,%esp
80104562:	68 00 4b 19 80       	push   $0x80194b00
80104567:	e8 be 06 00 00       	call   80104c2a <holding>
8010456c:	83 c4 10             	add    $0x10,%esp
8010456f:	85 c0                	test   %eax,%eax
80104571:	75 0d                	jne    80104580 <sched+0x2f>
    panic("sched ptable.lock");
80104573:	83 ec 0c             	sub    $0xc,%esp
80104576:	68 eb a8 10 80       	push   $0x8010a8eb
8010457b:	e8 29 c0 ff ff       	call   801005a9 <panic>
  if (mycpu()->ncli != 1)
80104580:	e8 33 f4 ff ff       	call   801039b8 <mycpu>
80104585:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010458b:	83 f8 01             	cmp    $0x1,%eax
8010458e:	74 0d                	je     8010459d <sched+0x4c>
    panic("sched locks");
80104590:	83 ec 0c             	sub    $0xc,%esp
80104593:	68 fd a8 10 80       	push   $0x8010a8fd
80104598:	e8 0c c0 ff ff       	call   801005a9 <panic>
  if (p->state == RUNNING)
8010459d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a0:	8b 40 0c             	mov    0xc(%eax),%eax
801045a3:	83 f8 04             	cmp    $0x4,%eax
801045a6:	75 0d                	jne    801045b5 <sched+0x64>
    panic("sched running");
801045a8:	83 ec 0c             	sub    $0xc,%esp
801045ab:	68 09 a9 10 80       	push   $0x8010a909
801045b0:	e8 f4 bf ff ff       	call   801005a9 <panic>
  if (readeflags() & FL_IF)
801045b5:	e8 ae f3 ff ff       	call   80103968 <readeflags>
801045ba:	25 00 02 00 00       	and    $0x200,%eax
801045bf:	85 c0                	test   %eax,%eax
801045c1:	74 0d                	je     801045d0 <sched+0x7f>
    panic("sched interruptible");
801045c3:	83 ec 0c             	sub    $0xc,%esp
801045c6:	68 17 a9 10 80       	push   $0x8010a917
801045cb:	e8 d9 bf ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
801045d0:	e8 e3 f3 ff ff       	call   801039b8 <mycpu>
801045d5:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801045db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801045de:	e8 d5 f3 ff ff       	call   801039b8 <mycpu>
801045e3:	8b 40 04             	mov    0x4(%eax),%eax
801045e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045e9:	83 c2 1c             	add    $0x1c,%edx
801045ec:	83 ec 08             	sub    $0x8,%esp
801045ef:	50                   	push   %eax
801045f0:	52                   	push   %edx
801045f1:	e8 e4 09 00 00       	call   80104fda <swtch>
801045f6:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801045f9:	e8 ba f3 ff ff       	call   801039b8 <mycpu>
801045fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104601:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104607:	90                   	nop
80104608:	c9                   	leave  
80104609:	c3                   	ret    

8010460a <yield>:

// Give up the CPU for one scheduling round.
void yield(void)
{
8010460a:	55                   	push   %ebp
8010460b:	89 e5                	mov    %esp,%ebp
8010460d:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock); // DOC: yieldlock
80104610:	83 ec 0c             	sub    $0xc,%esp
80104613:	68 00 4b 19 80       	push   $0x80194b00
80104618:	e8 d2 04 00 00       	call   80104aef <acquire>
8010461d:	83 c4 10             	add    $0x10,%esp

  int idx = myproc() - ptable.proc;
80104620:	e8 0b f4 ff ff       	call   80103a30 <myproc>
80104625:	2d 34 4b 19 80       	sub    $0x80194b34,%eax
8010462a:	c1 f8 02             	sar    $0x2,%eax
8010462d:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
80104633:	89 45 f4             	mov    %eax,-0xc(%ebp)
  proc_ticks[idx][proc_priority[idx]]++;
80104636:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104639:	8b 0c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ecx
80104640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104643:	c1 e0 02             	shl    $0x2,%eax
80104646:	01 c8                	add    %ecx,%eax
80104648:	8b 04 85 00 43 19 80 	mov    -0x7fe6bd00(,%eax,4),%eax
8010464f:	8d 50 01             	lea    0x1(%eax),%edx
80104652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104655:	c1 e0 02             	shl    $0x2,%eax
80104658:	01 c8                	add    %ecx,%eax
8010465a:	89 14 85 00 43 19 80 	mov    %edx,-0x7fe6bd00(,%eax,4)

  myproc()->state = RUNNABLE;
80104661:	e8 ca f3 ff ff       	call   80103a30 <myproc>
80104666:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010466d:	e8 df fe ff ff       	call   80104551 <sched>
  release(&ptable.lock);
80104672:	83 ec 0c             	sub    $0xc,%esp
80104675:	68 00 4b 19 80       	push   $0x80194b00
8010467a:	e8 de 04 00 00       	call   80104b5d <release>
8010467f:	83 c4 10             	add    $0x10,%esp
}
80104682:	90                   	nop
80104683:	c9                   	leave  
80104684:	c3                   	ret    

80104685 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void forkret(void)
{
80104685:	55                   	push   %ebp
80104686:	89 e5                	mov    %esp,%ebp
80104688:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010468b:	83 ec 0c             	sub    $0xc,%esp
8010468e:	68 00 4b 19 80       	push   $0x80194b00
80104693:	e8 c5 04 00 00       	call   80104b5d <release>
80104698:	83 c4 10             	add    $0x10,%esp

  if (first)
8010469b:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801046a0:	85 c0                	test   %eax,%eax
801046a2:	74 24                	je     801046c8 <forkret+0x43>
  {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801046a4:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801046ab:	00 00 00 
    iinit(ROOTDEV);
801046ae:	83 ec 0c             	sub    $0xc,%esp
801046b1:	6a 01                	push   $0x1
801046b3:	e8 c0 cf ff ff       	call   80101678 <iinit>
801046b8:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801046bb:	83 ec 0c             	sub    $0xc,%esp
801046be:	6a 01                	push   $0x1
801046c0:	e8 58 e7 ff ff       	call   80102e1d <initlog>
801046c5:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801046c8:	90                   	nop
801046c9:	c9                   	leave  
801046ca:	c3                   	ret    

801046cb <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
801046cb:	55                   	push   %ebp
801046cc:	89 e5                	mov    %esp,%ebp
801046ce:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801046d1:	e8 5a f3 ff ff       	call   80103a30 <myproc>
801046d6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if (p == 0)
801046d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046dd:	75 0d                	jne    801046ec <sleep+0x21>
    panic("sleep");
801046df:	83 ec 0c             	sub    $0xc,%esp
801046e2:	68 2b a9 10 80       	push   $0x8010a92b
801046e7:	e8 bd be ff ff       	call   801005a9 <panic>

  if (lk == 0)
801046ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801046f0:	75 0d                	jne    801046ff <sleep+0x34>
    panic("sleep without lk");
801046f2:	83 ec 0c             	sub    $0xc,%esp
801046f5:	68 31 a9 10 80       	push   $0x8010a931
801046fa:	e8 aa be ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if (lk != &ptable.lock)
801046ff:	81 7d 0c 00 4b 19 80 	cmpl   $0x80194b00,0xc(%ebp)
80104706:	74 1e                	je     80104726 <sleep+0x5b>
  {                        // DOC: sleeplock0
    acquire(&ptable.lock); // DOC: sleeplock1
80104708:	83 ec 0c             	sub    $0xc,%esp
8010470b:	68 00 4b 19 80       	push   $0x80194b00
80104710:	e8 da 03 00 00       	call   80104aef <acquire>
80104715:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104718:	83 ec 0c             	sub    $0xc,%esp
8010471b:	ff 75 0c             	push   0xc(%ebp)
8010471e:	e8 3a 04 00 00       	call   80104b5d <release>
80104723:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104729:	8b 55 08             	mov    0x8(%ebp),%edx
8010472c:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010472f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104732:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104739:	e8 13 fe ff ff       	call   80104551 <sched>

  // Tidy up.
  p->chan = 0;
8010473e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104741:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if (lk != &ptable.lock)
80104748:	81 7d 0c 00 4b 19 80 	cmpl   $0x80194b00,0xc(%ebp)
8010474f:	74 1e                	je     8010476f <sleep+0xa4>
  { // DOC: sleeplock2
    release(&ptable.lock);
80104751:	83 ec 0c             	sub    $0xc,%esp
80104754:	68 00 4b 19 80       	push   $0x80194b00
80104759:	e8 ff 03 00 00       	call   80104b5d <release>
8010475e:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104761:	83 ec 0c             	sub    $0xc,%esp
80104764:	ff 75 0c             	push   0xc(%ebp)
80104767:	e8 83 03 00 00       	call   80104aef <acquire>
8010476c:	83 c4 10             	add    $0x10,%esp
  }
}
8010476f:	90                   	nop
80104770:	c9                   	leave  
80104771:	c3                   	ret    

80104772 <wakeup1>:
// PAGEBREAK!
//  Wake up all processes sleeping on chan.
//  The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104772:	55                   	push   %ebp
80104773:	89 e5                	mov    %esp,%ebp
80104775:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104778:	c7 45 fc 34 4b 19 80 	movl   $0x80194b34,-0x4(%ebp)
8010477f:	eb 27                	jmp    801047a8 <wakeup1+0x36>
    if (p->state == SLEEPING && p->chan == chan)
80104781:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104784:	8b 40 0c             	mov    0xc(%eax),%eax
80104787:	83 f8 02             	cmp    $0x2,%eax
8010478a:	75 15                	jne    801047a1 <wakeup1+0x2f>
8010478c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010478f:	8b 40 20             	mov    0x20(%eax),%eax
80104792:	39 45 08             	cmp    %eax,0x8(%ebp)
80104795:	75 0a                	jne    801047a1 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104797:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010479a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801047a1:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
801047a8:	81 7d fc 34 6c 19 80 	cmpl   $0x80196c34,-0x4(%ebp)
801047af:	72 d0                	jb     80104781 <wakeup1+0xf>
}
801047b1:	90                   	nop
801047b2:	90                   	nop
801047b3:	c9                   	leave  
801047b4:	c3                   	ret    

801047b5 <wakeup>:

// Wake up all processes sleeping on chan.
void wakeup(void *chan)
{
801047b5:	55                   	push   %ebp
801047b6:	89 e5                	mov    %esp,%ebp
801047b8:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801047bb:	83 ec 0c             	sub    $0xc,%esp
801047be:	68 00 4b 19 80       	push   $0x80194b00
801047c3:	e8 27 03 00 00       	call   80104aef <acquire>
801047c8:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801047cb:	83 ec 0c             	sub    $0xc,%esp
801047ce:	ff 75 08             	push   0x8(%ebp)
801047d1:	e8 9c ff ff ff       	call   80104772 <wakeup1>
801047d6:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801047d9:	83 ec 0c             	sub    $0xc,%esp
801047dc:	68 00 4b 19 80       	push   $0x80194b00
801047e1:	e8 77 03 00 00       	call   80104b5d <release>
801047e6:	83 c4 10             	add    $0x10,%esp
}
801047e9:	90                   	nop
801047ea:	c9                   	leave  
801047eb:	c3                   	ret    

801047ec <kill>:

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int kill(int pid)
{
801047ec:	55                   	push   %ebp
801047ed:	89 e5                	mov    %esp,%ebp
801047ef:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801047f2:	83 ec 0c             	sub    $0xc,%esp
801047f5:	68 00 4b 19 80       	push   $0x80194b00
801047fa:	e8 f0 02 00 00       	call   80104aef <acquire>
801047ff:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104802:	c7 45 f4 34 4b 19 80 	movl   $0x80194b34,-0xc(%ebp)
80104809:	eb 48                	jmp    80104853 <kill+0x67>
  {
    if (p->pid == pid)
8010480b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480e:	8b 40 10             	mov    0x10(%eax),%eax
80104811:	39 45 08             	cmp    %eax,0x8(%ebp)
80104814:	75 36                	jne    8010484c <kill+0x60>
    {
      p->killed = 1;
80104816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104819:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if (p->state == SLEEPING)
80104820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104823:	8b 40 0c             	mov    0xc(%eax),%eax
80104826:	83 f8 02             	cmp    $0x2,%eax
80104829:	75 0a                	jne    80104835 <kill+0x49>
        p->state = RUNNABLE;
8010482b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104835:	83 ec 0c             	sub    $0xc,%esp
80104838:	68 00 4b 19 80       	push   $0x80194b00
8010483d:	e8 1b 03 00 00       	call   80104b5d <release>
80104842:	83 c4 10             	add    $0x10,%esp
      return 0;
80104845:	b8 00 00 00 00       	mov    $0x0,%eax
8010484a:	eb 25                	jmp    80104871 <kill+0x85>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010484c:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104853:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
8010485a:	72 af                	jb     8010480b <kill+0x1f>
    }
  }
  release(&ptable.lock);
8010485c:	83 ec 0c             	sub    $0xc,%esp
8010485f:	68 00 4b 19 80       	push   $0x80194b00
80104864:	e8 f4 02 00 00       	call   80104b5d <release>
80104869:	83 c4 10             	add    $0x10,%esp
  return -1;
8010486c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104871:	c9                   	leave  
80104872:	c3                   	ret    

80104873 <procdump>:
// PAGEBREAK: 36
//  Print a process listing to console.  For debugging.
//  Runs when user types ^P on console.
//  No lock to avoid wedging a stuck machine further.
void procdump(void)
{
80104873:	55                   	push   %ebp
80104874:	89 e5                	mov    %esp,%ebp
80104876:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104879:	c7 45 f0 34 4b 19 80 	movl   $0x80194b34,-0x10(%ebp)
80104880:	e9 da 00 00 00       	jmp    8010495f <procdump+0xec>
  {
    if (p->state == UNUSED)
80104885:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104888:	8b 40 0c             	mov    0xc(%eax),%eax
8010488b:	85 c0                	test   %eax,%eax
8010488d:	0f 84 c4 00 00 00    	je     80104957 <procdump+0xe4>
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104893:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104896:	8b 40 0c             	mov    0xc(%eax),%eax
80104899:	83 f8 05             	cmp    $0x5,%eax
8010489c:	77 23                	ja     801048c1 <procdump+0x4e>
8010489e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048a1:	8b 40 0c             	mov    0xc(%eax),%eax
801048a4:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801048ab:	85 c0                	test   %eax,%eax
801048ad:	74 12                	je     801048c1 <procdump+0x4e>
      state = states[p->state];
801048af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048b2:	8b 40 0c             	mov    0xc(%eax),%eax
801048b5:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801048bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801048bf:	eb 07                	jmp    801048c8 <procdump+0x55>
    else
      state = "???";
801048c1:	c7 45 ec 42 a9 10 80 	movl   $0x8010a942,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801048c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048cb:	8d 50 6c             	lea    0x6c(%eax),%edx
801048ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048d1:	8b 40 10             	mov    0x10(%eax),%eax
801048d4:	52                   	push   %edx
801048d5:	ff 75 ec             	push   -0x14(%ebp)
801048d8:	50                   	push   %eax
801048d9:	68 46 a9 10 80       	push   $0x8010a946
801048de:	e8 11 bb ff ff       	call   801003f4 <cprintf>
801048e3:	83 c4 10             	add    $0x10,%esp
    if (p->state == SLEEPING)
801048e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048e9:	8b 40 0c             	mov    0xc(%eax),%eax
801048ec:	83 f8 02             	cmp    $0x2,%eax
801048ef:	75 54                	jne    80104945 <procdump+0xd2>
    {
      getcallerpcs((uint *)p->context->ebp + 2, pc);
801048f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048f4:	8b 40 1c             	mov    0x1c(%eax),%eax
801048f7:	8b 40 0c             	mov    0xc(%eax),%eax
801048fa:	83 c0 08             	add    $0x8,%eax
801048fd:	89 c2                	mov    %eax,%edx
801048ff:	83 ec 08             	sub    $0x8,%esp
80104902:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104905:	50                   	push   %eax
80104906:	52                   	push   %edx
80104907:	e8 a3 02 00 00       	call   80104baf <getcallerpcs>
8010490c:	83 c4 10             	add    $0x10,%esp
      for (i = 0; i < 10 && pc[i] != 0; i++)
8010490f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104916:	eb 1c                	jmp    80104934 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010491f:	83 ec 08             	sub    $0x8,%esp
80104922:	50                   	push   %eax
80104923:	68 4f a9 10 80       	push   $0x8010a94f
80104928:	e8 c7 ba ff ff       	call   801003f4 <cprintf>
8010492d:	83 c4 10             	add    $0x10,%esp
      for (i = 0; i < 10 && pc[i] != 0; i++)
80104930:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104934:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104938:	7f 0b                	jg     80104945 <procdump+0xd2>
8010493a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493d:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104941:	85 c0                	test   %eax,%eax
80104943:	75 d3                	jne    80104918 <procdump+0xa5>
    }
    cprintf("\n");
80104945:	83 ec 0c             	sub    $0xc,%esp
80104948:	68 53 a9 10 80       	push   $0x8010a953
8010494d:	e8 a2 ba ff ff       	call   801003f4 <cprintf>
80104952:	83 c4 10             	add    $0x10,%esp
80104955:	eb 01                	jmp    80104958 <procdump+0xe5>
      continue;
80104957:	90                   	nop
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104958:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
8010495f:	81 7d f0 34 6c 19 80 	cmpl   $0x80196c34,-0x10(%ebp)
80104966:	0f 82 19 ff ff ff    	jb     80104885 <procdump+0x12>
  }
}
8010496c:	90                   	nop
8010496d:	90                   	nop
8010496e:	c9                   	leave  
8010496f:	c3                   	ret    

80104970 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104970:	55                   	push   %ebp
80104971:	89 e5                	mov    %esp,%ebp
80104973:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104976:	8b 45 08             	mov    0x8(%ebp),%eax
80104979:	83 c0 04             	add    $0x4,%eax
8010497c:	83 ec 08             	sub    $0x8,%esp
8010497f:	68 7f a9 10 80       	push   $0x8010a97f
80104984:	50                   	push   %eax
80104985:	e8 43 01 00 00       	call   80104acd <initlock>
8010498a:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010498d:	8b 45 08             	mov    0x8(%ebp),%eax
80104990:	8b 55 0c             	mov    0xc(%ebp),%edx
80104993:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104996:	8b 45 08             	mov    0x8(%ebp),%eax
80104999:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010499f:	8b 45 08             	mov    0x8(%ebp),%eax
801049a2:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801049a9:	90                   	nop
801049aa:	c9                   	leave  
801049ab:	c3                   	ret    

801049ac <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801049ac:	55                   	push   %ebp
801049ad:	89 e5                	mov    %esp,%ebp
801049af:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801049b2:	8b 45 08             	mov    0x8(%ebp),%eax
801049b5:	83 c0 04             	add    $0x4,%eax
801049b8:	83 ec 0c             	sub    $0xc,%esp
801049bb:	50                   	push   %eax
801049bc:	e8 2e 01 00 00       	call   80104aef <acquire>
801049c1:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801049c4:	eb 15                	jmp    801049db <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801049c6:	8b 45 08             	mov    0x8(%ebp),%eax
801049c9:	83 c0 04             	add    $0x4,%eax
801049cc:	83 ec 08             	sub    $0x8,%esp
801049cf:	50                   	push   %eax
801049d0:	ff 75 08             	push   0x8(%ebp)
801049d3:	e8 f3 fc ff ff       	call   801046cb <sleep>
801049d8:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801049db:	8b 45 08             	mov    0x8(%ebp),%eax
801049de:	8b 00                	mov    (%eax),%eax
801049e0:	85 c0                	test   %eax,%eax
801049e2:	75 e2                	jne    801049c6 <acquiresleep+0x1a>
  }
  lk->locked = 1;
801049e4:	8b 45 08             	mov    0x8(%ebp),%eax
801049e7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801049ed:	e8 3e f0 ff ff       	call   80103a30 <myproc>
801049f2:	8b 50 10             	mov    0x10(%eax),%edx
801049f5:	8b 45 08             	mov    0x8(%ebp),%eax
801049f8:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801049fb:	8b 45 08             	mov    0x8(%ebp),%eax
801049fe:	83 c0 04             	add    $0x4,%eax
80104a01:	83 ec 0c             	sub    $0xc,%esp
80104a04:	50                   	push   %eax
80104a05:	e8 53 01 00 00       	call   80104b5d <release>
80104a0a:	83 c4 10             	add    $0x10,%esp
}
80104a0d:	90                   	nop
80104a0e:	c9                   	leave  
80104a0f:	c3                   	ret    

80104a10 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104a10:	55                   	push   %ebp
80104a11:	89 e5                	mov    %esp,%ebp
80104a13:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104a16:	8b 45 08             	mov    0x8(%ebp),%eax
80104a19:	83 c0 04             	add    $0x4,%eax
80104a1c:	83 ec 0c             	sub    $0xc,%esp
80104a1f:	50                   	push   %eax
80104a20:	e8 ca 00 00 00       	call   80104aef <acquire>
80104a25:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104a28:	8b 45 08             	mov    0x8(%ebp),%eax
80104a2b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104a31:	8b 45 08             	mov    0x8(%ebp),%eax
80104a34:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104a3b:	83 ec 0c             	sub    $0xc,%esp
80104a3e:	ff 75 08             	push   0x8(%ebp)
80104a41:	e8 6f fd ff ff       	call   801047b5 <wakeup>
80104a46:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104a49:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4c:	83 c0 04             	add    $0x4,%eax
80104a4f:	83 ec 0c             	sub    $0xc,%esp
80104a52:	50                   	push   %eax
80104a53:	e8 05 01 00 00       	call   80104b5d <release>
80104a58:	83 c4 10             	add    $0x10,%esp
}
80104a5b:	90                   	nop
80104a5c:	c9                   	leave  
80104a5d:	c3                   	ret    

80104a5e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104a5e:	55                   	push   %ebp
80104a5f:	89 e5                	mov    %esp,%ebp
80104a61:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104a64:	8b 45 08             	mov    0x8(%ebp),%eax
80104a67:	83 c0 04             	add    $0x4,%eax
80104a6a:	83 ec 0c             	sub    $0xc,%esp
80104a6d:	50                   	push   %eax
80104a6e:	e8 7c 00 00 00       	call   80104aef <acquire>
80104a73:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104a76:	8b 45 08             	mov    0x8(%ebp),%eax
80104a79:	8b 00                	mov    (%eax),%eax
80104a7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a81:	83 c0 04             	add    $0x4,%eax
80104a84:	83 ec 0c             	sub    $0xc,%esp
80104a87:	50                   	push   %eax
80104a88:	e8 d0 00 00 00       	call   80104b5d <release>
80104a8d:	83 c4 10             	add    $0x10,%esp
  return r;
80104a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104a93:	c9                   	leave  
80104a94:	c3                   	ret    

80104a95 <readeflags>:
{
80104a95:	55                   	push   %ebp
80104a96:	89 e5                	mov    %esp,%ebp
80104a98:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104a9b:	9c                   	pushf  
80104a9c:	58                   	pop    %eax
80104a9d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104aa0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104aa3:	c9                   	leave  
80104aa4:	c3                   	ret    

80104aa5 <cli>:
{
80104aa5:	55                   	push   %ebp
80104aa6:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104aa8:	fa                   	cli    
}
80104aa9:	90                   	nop
80104aaa:	5d                   	pop    %ebp
80104aab:	c3                   	ret    

80104aac <sti>:
{
80104aac:	55                   	push   %ebp
80104aad:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104aaf:	fb                   	sti    
}
80104ab0:	90                   	nop
80104ab1:	5d                   	pop    %ebp
80104ab2:	c3                   	ret    

80104ab3 <xchg>:
{
80104ab3:	55                   	push   %ebp
80104ab4:	89 e5                	mov    %esp,%ebp
80104ab6:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104ab9:	8b 55 08             	mov    0x8(%ebp),%edx
80104abc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104abf:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ac2:	f0 87 02             	lock xchg %eax,(%edx)
80104ac5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104ac8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104acb:	c9                   	leave  
80104acc:	c3                   	ret    

80104acd <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104acd:	55                   	push   %ebp
80104ace:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ad3:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ad6:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104ad9:	8b 45 08             	mov    0x8(%ebp),%eax
80104adc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104aec:	90                   	nop
80104aed:	5d                   	pop    %ebp
80104aee:	c3                   	ret    

80104aef <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104aef:	55                   	push   %ebp
80104af0:	89 e5                	mov    %esp,%ebp
80104af2:	53                   	push   %ebx
80104af3:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104af6:	e8 5f 01 00 00       	call   80104c5a <pushcli>
  if(holding(lk)){
80104afb:	8b 45 08             	mov    0x8(%ebp),%eax
80104afe:	83 ec 0c             	sub    $0xc,%esp
80104b01:	50                   	push   %eax
80104b02:	e8 23 01 00 00       	call   80104c2a <holding>
80104b07:	83 c4 10             	add    $0x10,%esp
80104b0a:	85 c0                	test   %eax,%eax
80104b0c:	74 0d                	je     80104b1b <acquire+0x2c>
    panic("acquire");
80104b0e:	83 ec 0c             	sub    $0xc,%esp
80104b11:	68 8a a9 10 80       	push   $0x8010a98a
80104b16:	e8 8e ba ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104b1b:	90                   	nop
80104b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1f:	83 ec 08             	sub    $0x8,%esp
80104b22:	6a 01                	push   $0x1
80104b24:	50                   	push   %eax
80104b25:	e8 89 ff ff ff       	call   80104ab3 <xchg>
80104b2a:	83 c4 10             	add    $0x10,%esp
80104b2d:	85 c0                	test   %eax,%eax
80104b2f:	75 eb                	jne    80104b1c <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104b31:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104b36:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104b39:	e8 7a ee ff ff       	call   801039b8 <mycpu>
80104b3e:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104b41:	8b 45 08             	mov    0x8(%ebp),%eax
80104b44:	83 c0 0c             	add    $0xc,%eax
80104b47:	83 ec 08             	sub    $0x8,%esp
80104b4a:	50                   	push   %eax
80104b4b:	8d 45 08             	lea    0x8(%ebp),%eax
80104b4e:	50                   	push   %eax
80104b4f:	e8 5b 00 00 00       	call   80104baf <getcallerpcs>
80104b54:	83 c4 10             	add    $0x10,%esp
}
80104b57:	90                   	nop
80104b58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b5b:	c9                   	leave  
80104b5c:	c3                   	ret    

80104b5d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104b5d:	55                   	push   %ebp
80104b5e:	89 e5                	mov    %esp,%ebp
80104b60:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104b63:	83 ec 0c             	sub    $0xc,%esp
80104b66:	ff 75 08             	push   0x8(%ebp)
80104b69:	e8 bc 00 00 00       	call   80104c2a <holding>
80104b6e:	83 c4 10             	add    $0x10,%esp
80104b71:	85 c0                	test   %eax,%eax
80104b73:	75 0d                	jne    80104b82 <release+0x25>
    panic("release");
80104b75:	83 ec 0c             	sub    $0xc,%esp
80104b78:	68 92 a9 10 80       	push   $0x8010a992
80104b7d:	e8 27 ba ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104b82:	8b 45 08             	mov    0x8(%ebp),%eax
80104b85:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b8f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104b96:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104b9b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b9e:	8b 55 08             	mov    0x8(%ebp),%edx
80104ba1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104ba7:	e8 fb 00 00 00       	call   80104ca7 <popcli>
}
80104bac:	90                   	nop
80104bad:	c9                   	leave  
80104bae:	c3                   	ret    

80104baf <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104baf:	55                   	push   %ebp
80104bb0:	89 e5                	mov    %esp,%ebp
80104bb2:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb8:	83 e8 08             	sub    $0x8,%eax
80104bbb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104bbe:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104bc5:	eb 38                	jmp    80104bff <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104bc7:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104bcb:	74 53                	je     80104c20 <getcallerpcs+0x71>
80104bcd:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104bd4:	76 4a                	jbe    80104c20 <getcallerpcs+0x71>
80104bd6:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104bda:	74 44                	je     80104c20 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104bdc:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bdf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104be6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104be9:	01 c2                	add    %eax,%edx
80104beb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bee:	8b 40 04             	mov    0x4(%eax),%eax
80104bf1:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104bf3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bf6:	8b 00                	mov    (%eax),%eax
80104bf8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104bfb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104bff:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c03:	7e c2                	jle    80104bc7 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104c05:	eb 19                	jmp    80104c20 <getcallerpcs+0x71>
    pcs[i] = 0;
80104c07:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c0a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c11:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c14:	01 d0                	add    %edx,%eax
80104c16:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104c1c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c20:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c24:	7e e1                	jle    80104c07 <getcallerpcs+0x58>
}
80104c26:	90                   	nop
80104c27:	90                   	nop
80104c28:	c9                   	leave  
80104c29:	c3                   	ret    

80104c2a <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104c2a:	55                   	push   %ebp
80104c2b:	89 e5                	mov    %esp,%ebp
80104c2d:	53                   	push   %ebx
80104c2e:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104c31:	8b 45 08             	mov    0x8(%ebp),%eax
80104c34:	8b 00                	mov    (%eax),%eax
80104c36:	85 c0                	test   %eax,%eax
80104c38:	74 16                	je     80104c50 <holding+0x26>
80104c3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3d:	8b 58 08             	mov    0x8(%eax),%ebx
80104c40:	e8 73 ed ff ff       	call   801039b8 <mycpu>
80104c45:	39 c3                	cmp    %eax,%ebx
80104c47:	75 07                	jne    80104c50 <holding+0x26>
80104c49:	b8 01 00 00 00       	mov    $0x1,%eax
80104c4e:	eb 05                	jmp    80104c55 <holding+0x2b>
80104c50:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c58:	c9                   	leave  
80104c59:	c3                   	ret    

80104c5a <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104c5a:	55                   	push   %ebp
80104c5b:	89 e5                	mov    %esp,%ebp
80104c5d:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104c60:	e8 30 fe ff ff       	call   80104a95 <readeflags>
80104c65:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104c68:	e8 38 fe ff ff       	call   80104aa5 <cli>
  if(mycpu()->ncli == 0)
80104c6d:	e8 46 ed ff ff       	call   801039b8 <mycpu>
80104c72:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104c78:	85 c0                	test   %eax,%eax
80104c7a:	75 14                	jne    80104c90 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104c7c:	e8 37 ed ff ff       	call   801039b8 <mycpu>
80104c81:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c84:	81 e2 00 02 00 00    	and    $0x200,%edx
80104c8a:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104c90:	e8 23 ed ff ff       	call   801039b8 <mycpu>
80104c95:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104c9b:	83 c2 01             	add    $0x1,%edx
80104c9e:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104ca4:	90                   	nop
80104ca5:	c9                   	leave  
80104ca6:	c3                   	ret    

80104ca7 <popcli>:

void
popcli(void)
{
80104ca7:	55                   	push   %ebp
80104ca8:	89 e5                	mov    %esp,%ebp
80104caa:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104cad:	e8 e3 fd ff ff       	call   80104a95 <readeflags>
80104cb2:	25 00 02 00 00       	and    $0x200,%eax
80104cb7:	85 c0                	test   %eax,%eax
80104cb9:	74 0d                	je     80104cc8 <popcli+0x21>
    panic("popcli - interruptible");
80104cbb:	83 ec 0c             	sub    $0xc,%esp
80104cbe:	68 9a a9 10 80       	push   $0x8010a99a
80104cc3:	e8 e1 b8 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104cc8:	e8 eb ec ff ff       	call   801039b8 <mycpu>
80104ccd:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104cd3:	83 ea 01             	sub    $0x1,%edx
80104cd6:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104cdc:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ce2:	85 c0                	test   %eax,%eax
80104ce4:	79 0d                	jns    80104cf3 <popcli+0x4c>
    panic("popcli");
80104ce6:	83 ec 0c             	sub    $0xc,%esp
80104ce9:	68 b1 a9 10 80       	push   $0x8010a9b1
80104cee:	e8 b6 b8 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104cf3:	e8 c0 ec ff ff       	call   801039b8 <mycpu>
80104cf8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104cfe:	85 c0                	test   %eax,%eax
80104d00:	75 14                	jne    80104d16 <popcli+0x6f>
80104d02:	e8 b1 ec ff ff       	call   801039b8 <mycpu>
80104d07:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104d0d:	85 c0                	test   %eax,%eax
80104d0f:	74 05                	je     80104d16 <popcli+0x6f>
    sti();
80104d11:	e8 96 fd ff ff       	call   80104aac <sti>
}
80104d16:	90                   	nop
80104d17:	c9                   	leave  
80104d18:	c3                   	ret    

80104d19 <stosb>:
{
80104d19:	55                   	push   %ebp
80104d1a:	89 e5                	mov    %esp,%ebp
80104d1c:	57                   	push   %edi
80104d1d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104d1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d21:	8b 55 10             	mov    0x10(%ebp),%edx
80104d24:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d27:	89 cb                	mov    %ecx,%ebx
80104d29:	89 df                	mov    %ebx,%edi
80104d2b:	89 d1                	mov    %edx,%ecx
80104d2d:	fc                   	cld    
80104d2e:	f3 aa                	rep stos %al,%es:(%edi)
80104d30:	89 ca                	mov    %ecx,%edx
80104d32:	89 fb                	mov    %edi,%ebx
80104d34:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d37:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d3a:	90                   	nop
80104d3b:	5b                   	pop    %ebx
80104d3c:	5f                   	pop    %edi
80104d3d:	5d                   	pop    %ebp
80104d3e:	c3                   	ret    

80104d3f <stosl>:
{
80104d3f:	55                   	push   %ebp
80104d40:	89 e5                	mov    %esp,%ebp
80104d42:	57                   	push   %edi
80104d43:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104d44:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d47:	8b 55 10             	mov    0x10(%ebp),%edx
80104d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d4d:	89 cb                	mov    %ecx,%ebx
80104d4f:	89 df                	mov    %ebx,%edi
80104d51:	89 d1                	mov    %edx,%ecx
80104d53:	fc                   	cld    
80104d54:	f3 ab                	rep stos %eax,%es:(%edi)
80104d56:	89 ca                	mov    %ecx,%edx
80104d58:	89 fb                	mov    %edi,%ebx
80104d5a:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d5d:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d60:	90                   	nop
80104d61:	5b                   	pop    %ebx
80104d62:	5f                   	pop    %edi
80104d63:	5d                   	pop    %ebp
80104d64:	c3                   	ret    

80104d65 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104d65:	55                   	push   %ebp
80104d66:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104d68:	8b 45 08             	mov    0x8(%ebp),%eax
80104d6b:	83 e0 03             	and    $0x3,%eax
80104d6e:	85 c0                	test   %eax,%eax
80104d70:	75 43                	jne    80104db5 <memset+0x50>
80104d72:	8b 45 10             	mov    0x10(%ebp),%eax
80104d75:	83 e0 03             	and    $0x3,%eax
80104d78:	85 c0                	test   %eax,%eax
80104d7a:	75 39                	jne    80104db5 <memset+0x50>
    c &= 0xFF;
80104d7c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104d83:	8b 45 10             	mov    0x10(%ebp),%eax
80104d86:	c1 e8 02             	shr    $0x2,%eax
80104d89:	89 c2                	mov    %eax,%edx
80104d8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d8e:	c1 e0 18             	shl    $0x18,%eax
80104d91:	89 c1                	mov    %eax,%ecx
80104d93:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d96:	c1 e0 10             	shl    $0x10,%eax
80104d99:	09 c1                	or     %eax,%ecx
80104d9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d9e:	c1 e0 08             	shl    $0x8,%eax
80104da1:	09 c8                	or     %ecx,%eax
80104da3:	0b 45 0c             	or     0xc(%ebp),%eax
80104da6:	52                   	push   %edx
80104da7:	50                   	push   %eax
80104da8:	ff 75 08             	push   0x8(%ebp)
80104dab:	e8 8f ff ff ff       	call   80104d3f <stosl>
80104db0:	83 c4 0c             	add    $0xc,%esp
80104db3:	eb 12                	jmp    80104dc7 <memset+0x62>
  } else
    stosb(dst, c, n);
80104db5:	8b 45 10             	mov    0x10(%ebp),%eax
80104db8:	50                   	push   %eax
80104db9:	ff 75 0c             	push   0xc(%ebp)
80104dbc:	ff 75 08             	push   0x8(%ebp)
80104dbf:	e8 55 ff ff ff       	call   80104d19 <stosb>
80104dc4:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104dc7:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104dca:	c9                   	leave  
80104dcb:	c3                   	ret    

80104dcc <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104dcc:	55                   	push   %ebp
80104dcd:	89 e5                	mov    %esp,%ebp
80104dcf:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ddb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104dde:	eb 30                	jmp    80104e10 <memcmp+0x44>
    if(*s1 != *s2)
80104de0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104de3:	0f b6 10             	movzbl (%eax),%edx
80104de6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104de9:	0f b6 00             	movzbl (%eax),%eax
80104dec:	38 c2                	cmp    %al,%dl
80104dee:	74 18                	je     80104e08 <memcmp+0x3c>
      return *s1 - *s2;
80104df0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104df3:	0f b6 00             	movzbl (%eax),%eax
80104df6:	0f b6 d0             	movzbl %al,%edx
80104df9:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104dfc:	0f b6 00             	movzbl (%eax),%eax
80104dff:	0f b6 c8             	movzbl %al,%ecx
80104e02:	89 d0                	mov    %edx,%eax
80104e04:	29 c8                	sub    %ecx,%eax
80104e06:	eb 1a                	jmp    80104e22 <memcmp+0x56>
    s1++, s2++;
80104e08:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104e0c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104e10:	8b 45 10             	mov    0x10(%ebp),%eax
80104e13:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e16:	89 55 10             	mov    %edx,0x10(%ebp)
80104e19:	85 c0                	test   %eax,%eax
80104e1b:	75 c3                	jne    80104de0 <memcmp+0x14>
  }

  return 0;
80104e1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e22:	c9                   	leave  
80104e23:	c3                   	ret    

80104e24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104e24:	55                   	push   %ebp
80104e25:	89 e5                	mov    %esp,%ebp
80104e27:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e2d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104e30:	8b 45 08             	mov    0x8(%ebp),%eax
80104e33:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104e36:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e39:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e3c:	73 54                	jae    80104e92 <memmove+0x6e>
80104e3e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e41:	8b 45 10             	mov    0x10(%ebp),%eax
80104e44:	01 d0                	add    %edx,%eax
80104e46:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104e49:	73 47                	jae    80104e92 <memmove+0x6e>
    s += n;
80104e4b:	8b 45 10             	mov    0x10(%ebp),%eax
80104e4e:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104e51:	8b 45 10             	mov    0x10(%ebp),%eax
80104e54:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104e57:	eb 13                	jmp    80104e6c <memmove+0x48>
      *--d = *--s;
80104e59:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104e5d:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104e61:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e64:	0f b6 10             	movzbl (%eax),%edx
80104e67:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e6a:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104e6c:	8b 45 10             	mov    0x10(%ebp),%eax
80104e6f:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e72:	89 55 10             	mov    %edx,0x10(%ebp)
80104e75:	85 c0                	test   %eax,%eax
80104e77:	75 e0                	jne    80104e59 <memmove+0x35>
  if(s < d && s + n > d){
80104e79:	eb 24                	jmp    80104e9f <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104e7b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e7e:	8d 42 01             	lea    0x1(%edx),%eax
80104e81:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104e84:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e87:	8d 48 01             	lea    0x1(%eax),%ecx
80104e8a:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104e8d:	0f b6 12             	movzbl (%edx),%edx
80104e90:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104e92:	8b 45 10             	mov    0x10(%ebp),%eax
80104e95:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e98:	89 55 10             	mov    %edx,0x10(%ebp)
80104e9b:	85 c0                	test   %eax,%eax
80104e9d:	75 dc                	jne    80104e7b <memmove+0x57>

  return dst;
80104e9f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ea2:	c9                   	leave  
80104ea3:	c3                   	ret    

80104ea4 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104ea4:	55                   	push   %ebp
80104ea5:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104ea7:	ff 75 10             	push   0x10(%ebp)
80104eaa:	ff 75 0c             	push   0xc(%ebp)
80104ead:	ff 75 08             	push   0x8(%ebp)
80104eb0:	e8 6f ff ff ff       	call   80104e24 <memmove>
80104eb5:	83 c4 0c             	add    $0xc,%esp
}
80104eb8:	c9                   	leave  
80104eb9:	c3                   	ret    

80104eba <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104eba:	55                   	push   %ebp
80104ebb:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ebd:	eb 0c                	jmp    80104ecb <strncmp+0x11>
    n--, p++, q++;
80104ebf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ec3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104ec7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104ecb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ecf:	74 1a                	je     80104eeb <strncmp+0x31>
80104ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed4:	0f b6 00             	movzbl (%eax),%eax
80104ed7:	84 c0                	test   %al,%al
80104ed9:	74 10                	je     80104eeb <strncmp+0x31>
80104edb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ede:	0f b6 10             	movzbl (%eax),%edx
80104ee1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ee4:	0f b6 00             	movzbl (%eax),%eax
80104ee7:	38 c2                	cmp    %al,%dl
80104ee9:	74 d4                	je     80104ebf <strncmp+0x5>
  if(n == 0)
80104eeb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104eef:	75 07                	jne    80104ef8 <strncmp+0x3e>
    return 0;
80104ef1:	b8 00 00 00 00       	mov    $0x0,%eax
80104ef6:	eb 16                	jmp    80104f0e <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80104efb:	0f b6 00             	movzbl (%eax),%eax
80104efe:	0f b6 d0             	movzbl %al,%edx
80104f01:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f04:	0f b6 00             	movzbl (%eax),%eax
80104f07:	0f b6 c8             	movzbl %al,%ecx
80104f0a:	89 d0                	mov    %edx,%eax
80104f0c:	29 c8                	sub    %ecx,%eax
}
80104f0e:	5d                   	pop    %ebp
80104f0f:	c3                   	ret    

80104f10 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104f10:	55                   	push   %ebp
80104f11:	89 e5                	mov    %esp,%ebp
80104f13:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f16:	8b 45 08             	mov    0x8(%ebp),%eax
80104f19:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104f1c:	90                   	nop
80104f1d:	8b 45 10             	mov    0x10(%ebp),%eax
80104f20:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f23:	89 55 10             	mov    %edx,0x10(%ebp)
80104f26:	85 c0                	test   %eax,%eax
80104f28:	7e 2c                	jle    80104f56 <strncpy+0x46>
80104f2a:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f2d:	8d 42 01             	lea    0x1(%edx),%eax
80104f30:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f33:	8b 45 08             	mov    0x8(%ebp),%eax
80104f36:	8d 48 01             	lea    0x1(%eax),%ecx
80104f39:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104f3c:	0f b6 12             	movzbl (%edx),%edx
80104f3f:	88 10                	mov    %dl,(%eax)
80104f41:	0f b6 00             	movzbl (%eax),%eax
80104f44:	84 c0                	test   %al,%al
80104f46:	75 d5                	jne    80104f1d <strncpy+0xd>
    ;
  while(n-- > 0)
80104f48:	eb 0c                	jmp    80104f56 <strncpy+0x46>
    *s++ = 0;
80104f4a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f4d:	8d 50 01             	lea    0x1(%eax),%edx
80104f50:	89 55 08             	mov    %edx,0x8(%ebp)
80104f53:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104f56:	8b 45 10             	mov    0x10(%ebp),%eax
80104f59:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f5c:	89 55 10             	mov    %edx,0x10(%ebp)
80104f5f:	85 c0                	test   %eax,%eax
80104f61:	7f e7                	jg     80104f4a <strncpy+0x3a>
  return os;
80104f63:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f66:	c9                   	leave  
80104f67:	c3                   	ret    

80104f68 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104f68:	55                   	push   %ebp
80104f69:	89 e5                	mov    %esp,%ebp
80104f6b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f6e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f71:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104f74:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f78:	7f 05                	jg     80104f7f <safestrcpy+0x17>
    return os;
80104f7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f7d:	eb 32                	jmp    80104fb1 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104f7f:	90                   	nop
80104f80:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f84:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f88:	7e 1e                	jle    80104fa8 <safestrcpy+0x40>
80104f8a:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f8d:	8d 42 01             	lea    0x1(%edx),%eax
80104f90:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f93:	8b 45 08             	mov    0x8(%ebp),%eax
80104f96:	8d 48 01             	lea    0x1(%eax),%ecx
80104f99:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104f9c:	0f b6 12             	movzbl (%edx),%edx
80104f9f:	88 10                	mov    %dl,(%eax)
80104fa1:	0f b6 00             	movzbl (%eax),%eax
80104fa4:	84 c0                	test   %al,%al
80104fa6:	75 d8                	jne    80104f80 <safestrcpy+0x18>
    ;
  *s = 0;
80104fa8:	8b 45 08             	mov    0x8(%ebp),%eax
80104fab:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104fae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fb1:	c9                   	leave  
80104fb2:	c3                   	ret    

80104fb3 <strlen>:

int
strlen(const char *s)
{
80104fb3:	55                   	push   %ebp
80104fb4:	89 e5                	mov    %esp,%ebp
80104fb6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104fb9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104fc0:	eb 04                	jmp    80104fc6 <strlen+0x13>
80104fc2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104fc6:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80104fcc:	01 d0                	add    %edx,%eax
80104fce:	0f b6 00             	movzbl (%eax),%eax
80104fd1:	84 c0                	test   %al,%al
80104fd3:	75 ed                	jne    80104fc2 <strlen+0xf>
    ;
  return n;
80104fd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fd8:	c9                   	leave  
80104fd9:	c3                   	ret    

80104fda <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104fda:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104fde:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104fe2:	55                   	push   %ebp
  pushl %ebx
80104fe3:	53                   	push   %ebx
  pushl %esi
80104fe4:	56                   	push   %esi
  pushl %edi
80104fe5:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104fe6:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104fe8:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104fea:	5f                   	pop    %edi
  popl %esi
80104feb:	5e                   	pop    %esi
  popl %ebx
80104fec:	5b                   	pop    %ebx
  popl %ebp
80104fed:	5d                   	pop    %ebp
  ret
80104fee:	c3                   	ret    

80104fef <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104fef:	55                   	push   %ebp
80104ff0:	89 e5                	mov    %esp,%ebp
80104ff2:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104ff5:	e8 36 ea ff ff       	call   80103a30 <myproc>
80104ffa:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105000:	8b 00                	mov    (%eax),%eax
80105002:	39 45 08             	cmp    %eax,0x8(%ebp)
80105005:	73 0f                	jae    80105016 <fetchint+0x27>
80105007:	8b 45 08             	mov    0x8(%ebp),%eax
8010500a:	8d 50 04             	lea    0x4(%eax),%edx
8010500d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105010:	8b 00                	mov    (%eax),%eax
80105012:	39 c2                	cmp    %eax,%edx
80105014:	76 07                	jbe    8010501d <fetchint+0x2e>
    return -1;
80105016:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010501b:	eb 0f                	jmp    8010502c <fetchint+0x3d>
  *ip = *(int*)(addr);
8010501d:	8b 45 08             	mov    0x8(%ebp),%eax
80105020:	8b 10                	mov    (%eax),%edx
80105022:	8b 45 0c             	mov    0xc(%ebp),%eax
80105025:	89 10                	mov    %edx,(%eax)
  return 0;
80105027:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010502c:	c9                   	leave  
8010502d:	c3                   	ret    

8010502e <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010502e:	55                   	push   %ebp
8010502f:	89 e5                	mov    %esp,%ebp
80105031:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105034:	e8 f7 e9 ff ff       	call   80103a30 <myproc>
80105039:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010503c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010503f:	8b 00                	mov    (%eax),%eax
80105041:	39 45 08             	cmp    %eax,0x8(%ebp)
80105044:	72 07                	jb     8010504d <fetchstr+0x1f>
    return -1;
80105046:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010504b:	eb 41                	jmp    8010508e <fetchstr+0x60>
  *pp = (char*)addr;
8010504d:	8b 55 08             	mov    0x8(%ebp),%edx
80105050:	8b 45 0c             	mov    0xc(%ebp),%eax
80105053:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105055:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105058:	8b 00                	mov    (%eax),%eax
8010505a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010505d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105060:	8b 00                	mov    (%eax),%eax
80105062:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105065:	eb 1a                	jmp    80105081 <fetchstr+0x53>
    if(*s == 0)
80105067:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010506a:	0f b6 00             	movzbl (%eax),%eax
8010506d:	84 c0                	test   %al,%al
8010506f:	75 0c                	jne    8010507d <fetchstr+0x4f>
      return s - *pp;
80105071:	8b 45 0c             	mov    0xc(%ebp),%eax
80105074:	8b 10                	mov    (%eax),%edx
80105076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105079:	29 d0                	sub    %edx,%eax
8010507b:	eb 11                	jmp    8010508e <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
8010507d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105084:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105087:	72 de                	jb     80105067 <fetchstr+0x39>
  }
  return -1;
80105089:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010508e:	c9                   	leave  
8010508f:	c3                   	ret    

80105090 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105090:	55                   	push   %ebp
80105091:	89 e5                	mov    %esp,%ebp
80105093:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105096:	e8 95 e9 ff ff       	call   80103a30 <myproc>
8010509b:	8b 40 18             	mov    0x18(%eax),%eax
8010509e:	8b 50 44             	mov    0x44(%eax),%edx
801050a1:	8b 45 08             	mov    0x8(%ebp),%eax
801050a4:	c1 e0 02             	shl    $0x2,%eax
801050a7:	01 d0                	add    %edx,%eax
801050a9:	83 c0 04             	add    $0x4,%eax
801050ac:	83 ec 08             	sub    $0x8,%esp
801050af:	ff 75 0c             	push   0xc(%ebp)
801050b2:	50                   	push   %eax
801050b3:	e8 37 ff ff ff       	call   80104fef <fetchint>
801050b8:	83 c4 10             	add    $0x10,%esp
}
801050bb:	c9                   	leave  
801050bc:	c3                   	ret    

801050bd <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801050bd:	55                   	push   %ebp
801050be:	89 e5                	mov    %esp,%ebp
801050c0:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801050c3:	e8 68 e9 ff ff       	call   80103a30 <myproc>
801050c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801050cb:	83 ec 08             	sub    $0x8,%esp
801050ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050d1:	50                   	push   %eax
801050d2:	ff 75 08             	push   0x8(%ebp)
801050d5:	e8 b6 ff ff ff       	call   80105090 <argint>
801050da:	83 c4 10             	add    $0x10,%esp
801050dd:	85 c0                	test   %eax,%eax
801050df:	79 07                	jns    801050e8 <argptr+0x2b>
    return -1;
801050e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050e6:	eb 3b                	jmp    80105123 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801050e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050ec:	78 1f                	js     8010510d <argptr+0x50>
801050ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f1:	8b 00                	mov    (%eax),%eax
801050f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050f6:	39 d0                	cmp    %edx,%eax
801050f8:	76 13                	jbe    8010510d <argptr+0x50>
801050fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050fd:	89 c2                	mov    %eax,%edx
801050ff:	8b 45 10             	mov    0x10(%ebp),%eax
80105102:	01 c2                	add    %eax,%edx
80105104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105107:	8b 00                	mov    (%eax),%eax
80105109:	39 c2                	cmp    %eax,%edx
8010510b:	76 07                	jbe    80105114 <argptr+0x57>
    return -1;
8010510d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105112:	eb 0f                	jmp    80105123 <argptr+0x66>
  *pp = (char*)i;
80105114:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105117:	89 c2                	mov    %eax,%edx
80105119:	8b 45 0c             	mov    0xc(%ebp),%eax
8010511c:	89 10                	mov    %edx,(%eax)
  return 0;
8010511e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105123:	c9                   	leave  
80105124:	c3                   	ret    

80105125 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105125:	55                   	push   %ebp
80105126:	89 e5                	mov    %esp,%ebp
80105128:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010512b:	83 ec 08             	sub    $0x8,%esp
8010512e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105131:	50                   	push   %eax
80105132:	ff 75 08             	push   0x8(%ebp)
80105135:	e8 56 ff ff ff       	call   80105090 <argint>
8010513a:	83 c4 10             	add    $0x10,%esp
8010513d:	85 c0                	test   %eax,%eax
8010513f:	79 07                	jns    80105148 <argstr+0x23>
    return -1;
80105141:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105146:	eb 12                	jmp    8010515a <argstr+0x35>
  return fetchstr(addr, pp);
80105148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010514b:	83 ec 08             	sub    $0x8,%esp
8010514e:	ff 75 0c             	push   0xc(%ebp)
80105151:	50                   	push   %eax
80105152:	e8 d7 fe ff ff       	call   8010502e <fetchstr>
80105157:	83 c4 10             	add    $0x10,%esp
}
8010515a:	c9                   	leave  
8010515b:	c3                   	ret    

8010515c <syscall>:
[SYS_yield]    sys_yield,
};

void
syscall(void)
{
8010515c:	55                   	push   %ebp
8010515d:	89 e5                	mov    %esp,%ebp
8010515f:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105162:	e8 c9 e8 ff ff       	call   80103a30 <myproc>
80105167:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010516a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010516d:	8b 40 18             	mov    0x18(%eax),%eax
80105170:	8b 40 1c             	mov    0x1c(%eax),%eax
80105173:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105176:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010517a:	7e 2f                	jle    801051ab <syscall+0x4f>
8010517c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010517f:	83 f8 1a             	cmp    $0x1a,%eax
80105182:	77 27                	ja     801051ab <syscall+0x4f>
80105184:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105187:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010518e:	85 c0                	test   %eax,%eax
80105190:	74 19                	je     801051ab <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105192:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105195:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010519c:	ff d0                	call   *%eax
8010519e:	89 c2                	mov    %eax,%edx
801051a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a3:	8b 40 18             	mov    0x18(%eax),%eax
801051a6:	89 50 1c             	mov    %edx,0x1c(%eax)
801051a9:	eb 2c                	jmp    801051d7 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801051ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ae:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801051b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b4:	8b 40 10             	mov    0x10(%eax),%eax
801051b7:	ff 75 f0             	push   -0x10(%ebp)
801051ba:	52                   	push   %edx
801051bb:	50                   	push   %eax
801051bc:	68 b8 a9 10 80       	push   $0x8010a9b8
801051c1:	e8 2e b2 ff ff       	call   801003f4 <cprintf>
801051c6:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801051c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051cc:	8b 40 18             	mov    0x18(%eax),%eax
801051cf:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801051d6:	90                   	nop
801051d7:	90                   	nop
801051d8:	c9                   	leave  
801051d9:	c3                   	ret    

801051da <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801051da:	55                   	push   %ebp
801051db:	89 e5                	mov    %esp,%ebp
801051dd:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801051e0:	83 ec 08             	sub    $0x8,%esp
801051e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051e6:	50                   	push   %eax
801051e7:	ff 75 08             	push   0x8(%ebp)
801051ea:	e8 a1 fe ff ff       	call   80105090 <argint>
801051ef:	83 c4 10             	add    $0x10,%esp
801051f2:	85 c0                	test   %eax,%eax
801051f4:	79 07                	jns    801051fd <argfd+0x23>
    return -1;
801051f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051fb:	eb 4f                	jmp    8010524c <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801051fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105200:	85 c0                	test   %eax,%eax
80105202:	78 20                	js     80105224 <argfd+0x4a>
80105204:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105207:	83 f8 0f             	cmp    $0xf,%eax
8010520a:	7f 18                	jg     80105224 <argfd+0x4a>
8010520c:	e8 1f e8 ff ff       	call   80103a30 <myproc>
80105211:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105214:	83 c2 08             	add    $0x8,%edx
80105217:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010521b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010521e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105222:	75 07                	jne    8010522b <argfd+0x51>
    return -1;
80105224:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105229:	eb 21                	jmp    8010524c <argfd+0x72>
  if(pfd)
8010522b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010522f:	74 08                	je     80105239 <argfd+0x5f>
    *pfd = fd;
80105231:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105234:	8b 45 0c             	mov    0xc(%ebp),%eax
80105237:	89 10                	mov    %edx,(%eax)
  if(pf)
80105239:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010523d:	74 08                	je     80105247 <argfd+0x6d>
    *pf = f;
8010523f:	8b 45 10             	mov    0x10(%ebp),%eax
80105242:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105245:	89 10                	mov    %edx,(%eax)
  return 0;
80105247:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010524c:	c9                   	leave  
8010524d:	c3                   	ret    

8010524e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010524e:	55                   	push   %ebp
8010524f:	89 e5                	mov    %esp,%ebp
80105251:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105254:	e8 d7 e7 ff ff       	call   80103a30 <myproc>
80105259:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010525c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105263:	eb 2a                	jmp    8010528f <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105265:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105268:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010526b:	83 c2 08             	add    $0x8,%edx
8010526e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105272:	85 c0                	test   %eax,%eax
80105274:	75 15                	jne    8010528b <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105276:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105279:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010527c:	8d 4a 08             	lea    0x8(%edx),%ecx
8010527f:	8b 55 08             	mov    0x8(%ebp),%edx
80105282:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105289:	eb 0f                	jmp    8010529a <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
8010528b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010528f:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105293:	7e d0                	jle    80105265 <fdalloc+0x17>
    }
  }
  return -1;
80105295:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010529a:	c9                   	leave  
8010529b:	c3                   	ret    

8010529c <sys_dup>:

int
sys_dup(void)
{
8010529c:	55                   	push   %ebp
8010529d:	89 e5                	mov    %esp,%ebp
8010529f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801052a2:	83 ec 04             	sub    $0x4,%esp
801052a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052a8:	50                   	push   %eax
801052a9:	6a 00                	push   $0x0
801052ab:	6a 00                	push   $0x0
801052ad:	e8 28 ff ff ff       	call   801051da <argfd>
801052b2:	83 c4 10             	add    $0x10,%esp
801052b5:	85 c0                	test   %eax,%eax
801052b7:	79 07                	jns    801052c0 <sys_dup+0x24>
    return -1;
801052b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052be:	eb 31                	jmp    801052f1 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801052c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052c3:	83 ec 0c             	sub    $0xc,%esp
801052c6:	50                   	push   %eax
801052c7:	e8 82 ff ff ff       	call   8010524e <fdalloc>
801052cc:	83 c4 10             	add    $0x10,%esp
801052cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052d6:	79 07                	jns    801052df <sys_dup+0x43>
    return -1;
801052d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052dd:	eb 12                	jmp    801052f1 <sys_dup+0x55>
  filedup(f);
801052df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052e2:	83 ec 0c             	sub    $0xc,%esp
801052e5:	50                   	push   %eax
801052e6:	e8 5f bd ff ff       	call   8010104a <filedup>
801052eb:	83 c4 10             	add    $0x10,%esp
  return fd;
801052ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801052f1:	c9                   	leave  
801052f2:	c3                   	ret    

801052f3 <sys_read>:

int
sys_read(void)
{
801052f3:	55                   	push   %ebp
801052f4:	89 e5                	mov    %esp,%ebp
801052f6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801052f9:	83 ec 04             	sub    $0x4,%esp
801052fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052ff:	50                   	push   %eax
80105300:	6a 00                	push   $0x0
80105302:	6a 00                	push   $0x0
80105304:	e8 d1 fe ff ff       	call   801051da <argfd>
80105309:	83 c4 10             	add    $0x10,%esp
8010530c:	85 c0                	test   %eax,%eax
8010530e:	78 2e                	js     8010533e <sys_read+0x4b>
80105310:	83 ec 08             	sub    $0x8,%esp
80105313:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105316:	50                   	push   %eax
80105317:	6a 02                	push   $0x2
80105319:	e8 72 fd ff ff       	call   80105090 <argint>
8010531e:	83 c4 10             	add    $0x10,%esp
80105321:	85 c0                	test   %eax,%eax
80105323:	78 19                	js     8010533e <sys_read+0x4b>
80105325:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105328:	83 ec 04             	sub    $0x4,%esp
8010532b:	50                   	push   %eax
8010532c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010532f:	50                   	push   %eax
80105330:	6a 01                	push   $0x1
80105332:	e8 86 fd ff ff       	call   801050bd <argptr>
80105337:	83 c4 10             	add    $0x10,%esp
8010533a:	85 c0                	test   %eax,%eax
8010533c:	79 07                	jns    80105345 <sys_read+0x52>
    return -1;
8010533e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105343:	eb 17                	jmp    8010535c <sys_read+0x69>
  return fileread(f, p, n);
80105345:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105348:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010534b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010534e:	83 ec 04             	sub    $0x4,%esp
80105351:	51                   	push   %ecx
80105352:	52                   	push   %edx
80105353:	50                   	push   %eax
80105354:	e8 81 be ff ff       	call   801011da <fileread>
80105359:	83 c4 10             	add    $0x10,%esp
}
8010535c:	c9                   	leave  
8010535d:	c3                   	ret    

8010535e <sys_write>:

int
sys_write(void)
{
8010535e:	55                   	push   %ebp
8010535f:	89 e5                	mov    %esp,%ebp
80105361:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105364:	83 ec 04             	sub    $0x4,%esp
80105367:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010536a:	50                   	push   %eax
8010536b:	6a 00                	push   $0x0
8010536d:	6a 00                	push   $0x0
8010536f:	e8 66 fe ff ff       	call   801051da <argfd>
80105374:	83 c4 10             	add    $0x10,%esp
80105377:	85 c0                	test   %eax,%eax
80105379:	78 2e                	js     801053a9 <sys_write+0x4b>
8010537b:	83 ec 08             	sub    $0x8,%esp
8010537e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105381:	50                   	push   %eax
80105382:	6a 02                	push   $0x2
80105384:	e8 07 fd ff ff       	call   80105090 <argint>
80105389:	83 c4 10             	add    $0x10,%esp
8010538c:	85 c0                	test   %eax,%eax
8010538e:	78 19                	js     801053a9 <sys_write+0x4b>
80105390:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105393:	83 ec 04             	sub    $0x4,%esp
80105396:	50                   	push   %eax
80105397:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010539a:	50                   	push   %eax
8010539b:	6a 01                	push   $0x1
8010539d:	e8 1b fd ff ff       	call   801050bd <argptr>
801053a2:	83 c4 10             	add    $0x10,%esp
801053a5:	85 c0                	test   %eax,%eax
801053a7:	79 07                	jns    801053b0 <sys_write+0x52>
    return -1;
801053a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053ae:	eb 17                	jmp    801053c7 <sys_write+0x69>
  return filewrite(f, p, n);
801053b0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053b9:	83 ec 04             	sub    $0x4,%esp
801053bc:	51                   	push   %ecx
801053bd:	52                   	push   %edx
801053be:	50                   	push   %eax
801053bf:	e8 ce be ff ff       	call   80101292 <filewrite>
801053c4:	83 c4 10             	add    $0x10,%esp
}
801053c7:	c9                   	leave  
801053c8:	c3                   	ret    

801053c9 <sys_close>:

int
sys_close(void)
{
801053c9:	55                   	push   %ebp
801053ca:	89 e5                	mov    %esp,%ebp
801053cc:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801053cf:	83 ec 04             	sub    $0x4,%esp
801053d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053d5:	50                   	push   %eax
801053d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053d9:	50                   	push   %eax
801053da:	6a 00                	push   $0x0
801053dc:	e8 f9 fd ff ff       	call   801051da <argfd>
801053e1:	83 c4 10             	add    $0x10,%esp
801053e4:	85 c0                	test   %eax,%eax
801053e6:	79 07                	jns    801053ef <sys_close+0x26>
    return -1;
801053e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053ed:	eb 27                	jmp    80105416 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801053ef:	e8 3c e6 ff ff       	call   80103a30 <myproc>
801053f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053f7:	83 c2 08             	add    $0x8,%edx
801053fa:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105401:	00 
  fileclose(f);
80105402:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105405:	83 ec 0c             	sub    $0xc,%esp
80105408:	50                   	push   %eax
80105409:	e8 8d bc ff ff       	call   8010109b <fileclose>
8010540e:	83 c4 10             	add    $0x10,%esp
  return 0;
80105411:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105416:	c9                   	leave  
80105417:	c3                   	ret    

80105418 <sys_fstat>:

int
sys_fstat(void)
{
80105418:	55                   	push   %ebp
80105419:	89 e5                	mov    %esp,%ebp
8010541b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010541e:	83 ec 04             	sub    $0x4,%esp
80105421:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105424:	50                   	push   %eax
80105425:	6a 00                	push   $0x0
80105427:	6a 00                	push   $0x0
80105429:	e8 ac fd ff ff       	call   801051da <argfd>
8010542e:	83 c4 10             	add    $0x10,%esp
80105431:	85 c0                	test   %eax,%eax
80105433:	78 17                	js     8010544c <sys_fstat+0x34>
80105435:	83 ec 04             	sub    $0x4,%esp
80105438:	6a 14                	push   $0x14
8010543a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010543d:	50                   	push   %eax
8010543e:	6a 01                	push   $0x1
80105440:	e8 78 fc ff ff       	call   801050bd <argptr>
80105445:	83 c4 10             	add    $0x10,%esp
80105448:	85 c0                	test   %eax,%eax
8010544a:	79 07                	jns    80105453 <sys_fstat+0x3b>
    return -1;
8010544c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105451:	eb 13                	jmp    80105466 <sys_fstat+0x4e>
  return filestat(f, st);
80105453:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105456:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105459:	83 ec 08             	sub    $0x8,%esp
8010545c:	52                   	push   %edx
8010545d:	50                   	push   %eax
8010545e:	e8 20 bd ff ff       	call   80101183 <filestat>
80105463:	83 c4 10             	add    $0x10,%esp
}
80105466:	c9                   	leave  
80105467:	c3                   	ret    

80105468 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105468:	55                   	push   %ebp
80105469:	89 e5                	mov    %esp,%ebp
8010546b:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010546e:	83 ec 08             	sub    $0x8,%esp
80105471:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105474:	50                   	push   %eax
80105475:	6a 00                	push   $0x0
80105477:	e8 a9 fc ff ff       	call   80105125 <argstr>
8010547c:	83 c4 10             	add    $0x10,%esp
8010547f:	85 c0                	test   %eax,%eax
80105481:	78 15                	js     80105498 <sys_link+0x30>
80105483:	83 ec 08             	sub    $0x8,%esp
80105486:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105489:	50                   	push   %eax
8010548a:	6a 01                	push   $0x1
8010548c:	e8 94 fc ff ff       	call   80105125 <argstr>
80105491:	83 c4 10             	add    $0x10,%esp
80105494:	85 c0                	test   %eax,%eax
80105496:	79 0a                	jns    801054a2 <sys_link+0x3a>
    return -1;
80105498:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010549d:	e9 68 01 00 00       	jmp    8010560a <sys_link+0x1a2>

  begin_op();
801054a2:	e8 95 db ff ff       	call   8010303c <begin_op>
  if((ip = namei(old)) == 0){
801054a7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801054aa:	83 ec 0c             	sub    $0xc,%esp
801054ad:	50                   	push   %eax
801054ae:	e8 6a d0 ff ff       	call   8010251d <namei>
801054b3:	83 c4 10             	add    $0x10,%esp
801054b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054bd:	75 0f                	jne    801054ce <sys_link+0x66>
    end_op();
801054bf:	e8 04 dc ff ff       	call   801030c8 <end_op>
    return -1;
801054c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054c9:	e9 3c 01 00 00       	jmp    8010560a <sys_link+0x1a2>
  }

  ilock(ip);
801054ce:	83 ec 0c             	sub    $0xc,%esp
801054d1:	ff 75 f4             	push   -0xc(%ebp)
801054d4:	e8 11 c5 ff ff       	call   801019ea <ilock>
801054d9:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801054dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054df:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801054e3:	66 83 f8 01          	cmp    $0x1,%ax
801054e7:	75 1d                	jne    80105506 <sys_link+0x9e>
    iunlockput(ip);
801054e9:	83 ec 0c             	sub    $0xc,%esp
801054ec:	ff 75 f4             	push   -0xc(%ebp)
801054ef:	e8 27 c7 ff ff       	call   80101c1b <iunlockput>
801054f4:	83 c4 10             	add    $0x10,%esp
    end_op();
801054f7:	e8 cc db ff ff       	call   801030c8 <end_op>
    return -1;
801054fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105501:	e9 04 01 00 00       	jmp    8010560a <sys_link+0x1a2>
  }

  ip->nlink++;
80105506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105509:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010550d:	83 c0 01             	add    $0x1,%eax
80105510:	89 c2                	mov    %eax,%edx
80105512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105515:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105519:	83 ec 0c             	sub    $0xc,%esp
8010551c:	ff 75 f4             	push   -0xc(%ebp)
8010551f:	e8 e9 c2 ff ff       	call   8010180d <iupdate>
80105524:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105527:	83 ec 0c             	sub    $0xc,%esp
8010552a:	ff 75 f4             	push   -0xc(%ebp)
8010552d:	e8 cb c5 ff ff       	call   80101afd <iunlock>
80105532:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105535:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105538:	83 ec 08             	sub    $0x8,%esp
8010553b:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010553e:	52                   	push   %edx
8010553f:	50                   	push   %eax
80105540:	e8 f4 cf ff ff       	call   80102539 <nameiparent>
80105545:	83 c4 10             	add    $0x10,%esp
80105548:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010554b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010554f:	74 71                	je     801055c2 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105551:	83 ec 0c             	sub    $0xc,%esp
80105554:	ff 75 f0             	push   -0x10(%ebp)
80105557:	e8 8e c4 ff ff       	call   801019ea <ilock>
8010555c:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010555f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105562:	8b 10                	mov    (%eax),%edx
80105564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105567:	8b 00                	mov    (%eax),%eax
80105569:	39 c2                	cmp    %eax,%edx
8010556b:	75 1d                	jne    8010558a <sys_link+0x122>
8010556d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105570:	8b 40 04             	mov    0x4(%eax),%eax
80105573:	83 ec 04             	sub    $0x4,%esp
80105576:	50                   	push   %eax
80105577:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010557a:	50                   	push   %eax
8010557b:	ff 75 f0             	push   -0x10(%ebp)
8010557e:	e8 03 cd ff ff       	call   80102286 <dirlink>
80105583:	83 c4 10             	add    $0x10,%esp
80105586:	85 c0                	test   %eax,%eax
80105588:	79 10                	jns    8010559a <sys_link+0x132>
    iunlockput(dp);
8010558a:	83 ec 0c             	sub    $0xc,%esp
8010558d:	ff 75 f0             	push   -0x10(%ebp)
80105590:	e8 86 c6 ff ff       	call   80101c1b <iunlockput>
80105595:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105598:	eb 29                	jmp    801055c3 <sys_link+0x15b>
  }
  iunlockput(dp);
8010559a:	83 ec 0c             	sub    $0xc,%esp
8010559d:	ff 75 f0             	push   -0x10(%ebp)
801055a0:	e8 76 c6 ff ff       	call   80101c1b <iunlockput>
801055a5:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801055a8:	83 ec 0c             	sub    $0xc,%esp
801055ab:	ff 75 f4             	push   -0xc(%ebp)
801055ae:	e8 98 c5 ff ff       	call   80101b4b <iput>
801055b3:	83 c4 10             	add    $0x10,%esp

  end_op();
801055b6:	e8 0d db ff ff       	call   801030c8 <end_op>

  return 0;
801055bb:	b8 00 00 00 00       	mov    $0x0,%eax
801055c0:	eb 48                	jmp    8010560a <sys_link+0x1a2>
    goto bad;
801055c2:	90                   	nop

bad:
  ilock(ip);
801055c3:	83 ec 0c             	sub    $0xc,%esp
801055c6:	ff 75 f4             	push   -0xc(%ebp)
801055c9:	e8 1c c4 ff ff       	call   801019ea <ilock>
801055ce:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801055d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055d8:	83 e8 01             	sub    $0x1,%eax
801055db:	89 c2                	mov    %eax,%edx
801055dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e0:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801055e4:	83 ec 0c             	sub    $0xc,%esp
801055e7:	ff 75 f4             	push   -0xc(%ebp)
801055ea:	e8 1e c2 ff ff       	call   8010180d <iupdate>
801055ef:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801055f2:	83 ec 0c             	sub    $0xc,%esp
801055f5:	ff 75 f4             	push   -0xc(%ebp)
801055f8:	e8 1e c6 ff ff       	call   80101c1b <iunlockput>
801055fd:	83 c4 10             	add    $0x10,%esp
  end_op();
80105600:	e8 c3 da ff ff       	call   801030c8 <end_op>
  return -1;
80105605:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010560a:	c9                   	leave  
8010560b:	c3                   	ret    

8010560c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010560c:	55                   	push   %ebp
8010560d:	89 e5                	mov    %esp,%ebp
8010560f:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105612:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105619:	eb 40                	jmp    8010565b <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010561b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010561e:	6a 10                	push   $0x10
80105620:	50                   	push   %eax
80105621:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105624:	50                   	push   %eax
80105625:	ff 75 08             	push   0x8(%ebp)
80105628:	e8 a9 c8 ff ff       	call   80101ed6 <readi>
8010562d:	83 c4 10             	add    $0x10,%esp
80105630:	83 f8 10             	cmp    $0x10,%eax
80105633:	74 0d                	je     80105642 <isdirempty+0x36>
      panic("isdirempty: readi");
80105635:	83 ec 0c             	sub    $0xc,%esp
80105638:	68 d4 a9 10 80       	push   $0x8010a9d4
8010563d:	e8 67 af ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105642:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105646:	66 85 c0             	test   %ax,%ax
80105649:	74 07                	je     80105652 <isdirempty+0x46>
      return 0;
8010564b:	b8 00 00 00 00       	mov    $0x0,%eax
80105650:	eb 1b                	jmp    8010566d <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105655:	83 c0 10             	add    $0x10,%eax
80105658:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010565b:	8b 45 08             	mov    0x8(%ebp),%eax
8010565e:	8b 50 58             	mov    0x58(%eax),%edx
80105661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105664:	39 c2                	cmp    %eax,%edx
80105666:	77 b3                	ja     8010561b <isdirempty+0xf>
  }
  return 1;
80105668:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010566d:	c9                   	leave  
8010566e:	c3                   	ret    

8010566f <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010566f:	55                   	push   %ebp
80105670:	89 e5                	mov    %esp,%ebp
80105672:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105675:	83 ec 08             	sub    $0x8,%esp
80105678:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010567b:	50                   	push   %eax
8010567c:	6a 00                	push   $0x0
8010567e:	e8 a2 fa ff ff       	call   80105125 <argstr>
80105683:	83 c4 10             	add    $0x10,%esp
80105686:	85 c0                	test   %eax,%eax
80105688:	79 0a                	jns    80105694 <sys_unlink+0x25>
    return -1;
8010568a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010568f:	e9 bf 01 00 00       	jmp    80105853 <sys_unlink+0x1e4>

  begin_op();
80105694:	e8 a3 d9 ff ff       	call   8010303c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105699:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010569c:	83 ec 08             	sub    $0x8,%esp
8010569f:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801056a2:	52                   	push   %edx
801056a3:	50                   	push   %eax
801056a4:	e8 90 ce ff ff       	call   80102539 <nameiparent>
801056a9:	83 c4 10             	add    $0x10,%esp
801056ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056b3:	75 0f                	jne    801056c4 <sys_unlink+0x55>
    end_op();
801056b5:	e8 0e da ff ff       	call   801030c8 <end_op>
    return -1;
801056ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056bf:	e9 8f 01 00 00       	jmp    80105853 <sys_unlink+0x1e4>
  }

  ilock(dp);
801056c4:	83 ec 0c             	sub    $0xc,%esp
801056c7:	ff 75 f4             	push   -0xc(%ebp)
801056ca:	e8 1b c3 ff ff       	call   801019ea <ilock>
801056cf:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801056d2:	83 ec 08             	sub    $0x8,%esp
801056d5:	68 e6 a9 10 80       	push   $0x8010a9e6
801056da:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801056dd:	50                   	push   %eax
801056de:	e8 ce ca ff ff       	call   801021b1 <namecmp>
801056e3:	83 c4 10             	add    $0x10,%esp
801056e6:	85 c0                	test   %eax,%eax
801056e8:	0f 84 49 01 00 00    	je     80105837 <sys_unlink+0x1c8>
801056ee:	83 ec 08             	sub    $0x8,%esp
801056f1:	68 e8 a9 10 80       	push   $0x8010a9e8
801056f6:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801056f9:	50                   	push   %eax
801056fa:	e8 b2 ca ff ff       	call   801021b1 <namecmp>
801056ff:	83 c4 10             	add    $0x10,%esp
80105702:	85 c0                	test   %eax,%eax
80105704:	0f 84 2d 01 00 00    	je     80105837 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010570a:	83 ec 04             	sub    $0x4,%esp
8010570d:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105710:	50                   	push   %eax
80105711:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105714:	50                   	push   %eax
80105715:	ff 75 f4             	push   -0xc(%ebp)
80105718:	e8 af ca ff ff       	call   801021cc <dirlookup>
8010571d:	83 c4 10             	add    $0x10,%esp
80105720:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105723:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105727:	0f 84 0d 01 00 00    	je     8010583a <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
8010572d:	83 ec 0c             	sub    $0xc,%esp
80105730:	ff 75 f0             	push   -0x10(%ebp)
80105733:	e8 b2 c2 ff ff       	call   801019ea <ilock>
80105738:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010573b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010573e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105742:	66 85 c0             	test   %ax,%ax
80105745:	7f 0d                	jg     80105754 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105747:	83 ec 0c             	sub    $0xc,%esp
8010574a:	68 eb a9 10 80       	push   $0x8010a9eb
8010574f:	e8 55 ae ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105754:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105757:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010575b:	66 83 f8 01          	cmp    $0x1,%ax
8010575f:	75 25                	jne    80105786 <sys_unlink+0x117>
80105761:	83 ec 0c             	sub    $0xc,%esp
80105764:	ff 75 f0             	push   -0x10(%ebp)
80105767:	e8 a0 fe ff ff       	call   8010560c <isdirempty>
8010576c:	83 c4 10             	add    $0x10,%esp
8010576f:	85 c0                	test   %eax,%eax
80105771:	75 13                	jne    80105786 <sys_unlink+0x117>
    iunlockput(ip);
80105773:	83 ec 0c             	sub    $0xc,%esp
80105776:	ff 75 f0             	push   -0x10(%ebp)
80105779:	e8 9d c4 ff ff       	call   80101c1b <iunlockput>
8010577e:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105781:	e9 b5 00 00 00       	jmp    8010583b <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105786:	83 ec 04             	sub    $0x4,%esp
80105789:	6a 10                	push   $0x10
8010578b:	6a 00                	push   $0x0
8010578d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105790:	50                   	push   %eax
80105791:	e8 cf f5 ff ff       	call   80104d65 <memset>
80105796:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105799:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010579c:	6a 10                	push   $0x10
8010579e:	50                   	push   %eax
8010579f:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057a2:	50                   	push   %eax
801057a3:	ff 75 f4             	push   -0xc(%ebp)
801057a6:	e8 80 c8 ff ff       	call   8010202b <writei>
801057ab:	83 c4 10             	add    $0x10,%esp
801057ae:	83 f8 10             	cmp    $0x10,%eax
801057b1:	74 0d                	je     801057c0 <sys_unlink+0x151>
    panic("unlink: writei");
801057b3:	83 ec 0c             	sub    $0xc,%esp
801057b6:	68 fd a9 10 80       	push   $0x8010a9fd
801057bb:	e8 e9 ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801057c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057c3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801057c7:	66 83 f8 01          	cmp    $0x1,%ax
801057cb:	75 21                	jne    801057ee <sys_unlink+0x17f>
    dp->nlink--;
801057cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057d4:	83 e8 01             	sub    $0x1,%eax
801057d7:	89 c2                	mov    %eax,%edx
801057d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057dc:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801057e0:	83 ec 0c             	sub    $0xc,%esp
801057e3:	ff 75 f4             	push   -0xc(%ebp)
801057e6:	e8 22 c0 ff ff       	call   8010180d <iupdate>
801057eb:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801057ee:	83 ec 0c             	sub    $0xc,%esp
801057f1:	ff 75 f4             	push   -0xc(%ebp)
801057f4:	e8 22 c4 ff ff       	call   80101c1b <iunlockput>
801057f9:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801057fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ff:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105803:	83 e8 01             	sub    $0x1,%eax
80105806:	89 c2                	mov    %eax,%edx
80105808:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580b:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010580f:	83 ec 0c             	sub    $0xc,%esp
80105812:	ff 75 f0             	push   -0x10(%ebp)
80105815:	e8 f3 bf ff ff       	call   8010180d <iupdate>
8010581a:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010581d:	83 ec 0c             	sub    $0xc,%esp
80105820:	ff 75 f0             	push   -0x10(%ebp)
80105823:	e8 f3 c3 ff ff       	call   80101c1b <iunlockput>
80105828:	83 c4 10             	add    $0x10,%esp

  end_op();
8010582b:	e8 98 d8 ff ff       	call   801030c8 <end_op>

  return 0;
80105830:	b8 00 00 00 00       	mov    $0x0,%eax
80105835:	eb 1c                	jmp    80105853 <sys_unlink+0x1e4>
    goto bad;
80105837:	90                   	nop
80105838:	eb 01                	jmp    8010583b <sys_unlink+0x1cc>
    goto bad;
8010583a:	90                   	nop

bad:
  iunlockput(dp);
8010583b:	83 ec 0c             	sub    $0xc,%esp
8010583e:	ff 75 f4             	push   -0xc(%ebp)
80105841:	e8 d5 c3 ff ff       	call   80101c1b <iunlockput>
80105846:	83 c4 10             	add    $0x10,%esp
  end_op();
80105849:	e8 7a d8 ff ff       	call   801030c8 <end_op>
  return -1;
8010584e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105853:	c9                   	leave  
80105854:	c3                   	ret    

80105855 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105855:	55                   	push   %ebp
80105856:	89 e5                	mov    %esp,%ebp
80105858:	83 ec 38             	sub    $0x38,%esp
8010585b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010585e:	8b 55 10             	mov    0x10(%ebp),%edx
80105861:	8b 45 14             	mov    0x14(%ebp),%eax
80105864:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105868:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010586c:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105870:	83 ec 08             	sub    $0x8,%esp
80105873:	8d 45 de             	lea    -0x22(%ebp),%eax
80105876:	50                   	push   %eax
80105877:	ff 75 08             	push   0x8(%ebp)
8010587a:	e8 ba cc ff ff       	call   80102539 <nameiparent>
8010587f:	83 c4 10             	add    $0x10,%esp
80105882:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105885:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105889:	75 0a                	jne    80105895 <create+0x40>
    return 0;
8010588b:	b8 00 00 00 00       	mov    $0x0,%eax
80105890:	e9 90 01 00 00       	jmp    80105a25 <create+0x1d0>
  ilock(dp);
80105895:	83 ec 0c             	sub    $0xc,%esp
80105898:	ff 75 f4             	push   -0xc(%ebp)
8010589b:	e8 4a c1 ff ff       	call   801019ea <ilock>
801058a0:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801058a3:	83 ec 04             	sub    $0x4,%esp
801058a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058a9:	50                   	push   %eax
801058aa:	8d 45 de             	lea    -0x22(%ebp),%eax
801058ad:	50                   	push   %eax
801058ae:	ff 75 f4             	push   -0xc(%ebp)
801058b1:	e8 16 c9 ff ff       	call   801021cc <dirlookup>
801058b6:	83 c4 10             	add    $0x10,%esp
801058b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801058bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058c0:	74 50                	je     80105912 <create+0xbd>
    iunlockput(dp);
801058c2:	83 ec 0c             	sub    $0xc,%esp
801058c5:	ff 75 f4             	push   -0xc(%ebp)
801058c8:	e8 4e c3 ff ff       	call   80101c1b <iunlockput>
801058cd:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801058d0:	83 ec 0c             	sub    $0xc,%esp
801058d3:	ff 75 f0             	push   -0x10(%ebp)
801058d6:	e8 0f c1 ff ff       	call   801019ea <ilock>
801058db:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801058de:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801058e3:	75 15                	jne    801058fa <create+0xa5>
801058e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801058ec:	66 83 f8 02          	cmp    $0x2,%ax
801058f0:	75 08                	jne    801058fa <create+0xa5>
      return ip;
801058f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f5:	e9 2b 01 00 00       	jmp    80105a25 <create+0x1d0>
    iunlockput(ip);
801058fa:	83 ec 0c             	sub    $0xc,%esp
801058fd:	ff 75 f0             	push   -0x10(%ebp)
80105900:	e8 16 c3 ff ff       	call   80101c1b <iunlockput>
80105905:	83 c4 10             	add    $0x10,%esp
    return 0;
80105908:	b8 00 00 00 00       	mov    $0x0,%eax
8010590d:	e9 13 01 00 00       	jmp    80105a25 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105912:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105919:	8b 00                	mov    (%eax),%eax
8010591b:	83 ec 08             	sub    $0x8,%esp
8010591e:	52                   	push   %edx
8010591f:	50                   	push   %eax
80105920:	e8 11 be ff ff       	call   80101736 <ialloc>
80105925:	83 c4 10             	add    $0x10,%esp
80105928:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010592b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010592f:	75 0d                	jne    8010593e <create+0xe9>
    panic("create: ialloc");
80105931:	83 ec 0c             	sub    $0xc,%esp
80105934:	68 0c aa 10 80       	push   $0x8010aa0c
80105939:	e8 6b ac ff ff       	call   801005a9 <panic>

  ilock(ip);
8010593e:	83 ec 0c             	sub    $0xc,%esp
80105941:	ff 75 f0             	push   -0x10(%ebp)
80105944:	e8 a1 c0 ff ff       	call   801019ea <ilock>
80105949:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010594c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010594f:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105953:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105957:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010595a:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010595e:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105962:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105965:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010596b:	83 ec 0c             	sub    $0xc,%esp
8010596e:	ff 75 f0             	push   -0x10(%ebp)
80105971:	e8 97 be ff ff       	call   8010180d <iupdate>
80105976:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105979:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010597e:	75 6a                	jne    801059ea <create+0x195>
    dp->nlink++;  // for ".."
80105980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105983:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105987:	83 c0 01             	add    $0x1,%eax
8010598a:	89 c2                	mov    %eax,%edx
8010598c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010598f:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105993:	83 ec 0c             	sub    $0xc,%esp
80105996:	ff 75 f4             	push   -0xc(%ebp)
80105999:	e8 6f be ff ff       	call   8010180d <iupdate>
8010599e:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801059a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a4:	8b 40 04             	mov    0x4(%eax),%eax
801059a7:	83 ec 04             	sub    $0x4,%esp
801059aa:	50                   	push   %eax
801059ab:	68 e6 a9 10 80       	push   $0x8010a9e6
801059b0:	ff 75 f0             	push   -0x10(%ebp)
801059b3:	e8 ce c8 ff ff       	call   80102286 <dirlink>
801059b8:	83 c4 10             	add    $0x10,%esp
801059bb:	85 c0                	test   %eax,%eax
801059bd:	78 1e                	js     801059dd <create+0x188>
801059bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c2:	8b 40 04             	mov    0x4(%eax),%eax
801059c5:	83 ec 04             	sub    $0x4,%esp
801059c8:	50                   	push   %eax
801059c9:	68 e8 a9 10 80       	push   $0x8010a9e8
801059ce:	ff 75 f0             	push   -0x10(%ebp)
801059d1:	e8 b0 c8 ff ff       	call   80102286 <dirlink>
801059d6:	83 c4 10             	add    $0x10,%esp
801059d9:	85 c0                	test   %eax,%eax
801059db:	79 0d                	jns    801059ea <create+0x195>
      panic("create dots");
801059dd:	83 ec 0c             	sub    $0xc,%esp
801059e0:	68 1b aa 10 80       	push   $0x8010aa1b
801059e5:	e8 bf ab ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801059ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ed:	8b 40 04             	mov    0x4(%eax),%eax
801059f0:	83 ec 04             	sub    $0x4,%esp
801059f3:	50                   	push   %eax
801059f4:	8d 45 de             	lea    -0x22(%ebp),%eax
801059f7:	50                   	push   %eax
801059f8:	ff 75 f4             	push   -0xc(%ebp)
801059fb:	e8 86 c8 ff ff       	call   80102286 <dirlink>
80105a00:	83 c4 10             	add    $0x10,%esp
80105a03:	85 c0                	test   %eax,%eax
80105a05:	79 0d                	jns    80105a14 <create+0x1bf>
    panic("create: dirlink");
80105a07:	83 ec 0c             	sub    $0xc,%esp
80105a0a:	68 27 aa 10 80       	push   $0x8010aa27
80105a0f:	e8 95 ab ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105a14:	83 ec 0c             	sub    $0xc,%esp
80105a17:	ff 75 f4             	push   -0xc(%ebp)
80105a1a:	e8 fc c1 ff ff       	call   80101c1b <iunlockput>
80105a1f:	83 c4 10             	add    $0x10,%esp

  return ip;
80105a22:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105a25:	c9                   	leave  
80105a26:	c3                   	ret    

80105a27 <sys_open>:

int
sys_open(void)
{
80105a27:	55                   	push   %ebp
80105a28:	89 e5                	mov    %esp,%ebp
80105a2a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105a2d:	83 ec 08             	sub    $0x8,%esp
80105a30:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105a33:	50                   	push   %eax
80105a34:	6a 00                	push   $0x0
80105a36:	e8 ea f6 ff ff       	call   80105125 <argstr>
80105a3b:	83 c4 10             	add    $0x10,%esp
80105a3e:	85 c0                	test   %eax,%eax
80105a40:	78 15                	js     80105a57 <sys_open+0x30>
80105a42:	83 ec 08             	sub    $0x8,%esp
80105a45:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a48:	50                   	push   %eax
80105a49:	6a 01                	push   $0x1
80105a4b:	e8 40 f6 ff ff       	call   80105090 <argint>
80105a50:	83 c4 10             	add    $0x10,%esp
80105a53:	85 c0                	test   %eax,%eax
80105a55:	79 0a                	jns    80105a61 <sys_open+0x3a>
    return -1;
80105a57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a5c:	e9 61 01 00 00       	jmp    80105bc2 <sys_open+0x19b>

  begin_op();
80105a61:	e8 d6 d5 ff ff       	call   8010303c <begin_op>

  if(omode & O_CREATE){
80105a66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a69:	25 00 02 00 00       	and    $0x200,%eax
80105a6e:	85 c0                	test   %eax,%eax
80105a70:	74 2a                	je     80105a9c <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105a72:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a75:	6a 00                	push   $0x0
80105a77:	6a 00                	push   $0x0
80105a79:	6a 02                	push   $0x2
80105a7b:	50                   	push   %eax
80105a7c:	e8 d4 fd ff ff       	call   80105855 <create>
80105a81:	83 c4 10             	add    $0x10,%esp
80105a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105a87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a8b:	75 75                	jne    80105b02 <sys_open+0xdb>
      end_op();
80105a8d:	e8 36 d6 ff ff       	call   801030c8 <end_op>
      return -1;
80105a92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a97:	e9 26 01 00 00       	jmp    80105bc2 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105a9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a9f:	83 ec 0c             	sub    $0xc,%esp
80105aa2:	50                   	push   %eax
80105aa3:	e8 75 ca ff ff       	call   8010251d <namei>
80105aa8:	83 c4 10             	add    $0x10,%esp
80105aab:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ab2:	75 0f                	jne    80105ac3 <sys_open+0x9c>
      end_op();
80105ab4:	e8 0f d6 ff ff       	call   801030c8 <end_op>
      return -1;
80105ab9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105abe:	e9 ff 00 00 00       	jmp    80105bc2 <sys_open+0x19b>
    }
    ilock(ip);
80105ac3:	83 ec 0c             	sub    $0xc,%esp
80105ac6:	ff 75 f4             	push   -0xc(%ebp)
80105ac9:	e8 1c bf ff ff       	call   801019ea <ilock>
80105ace:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ad8:	66 83 f8 01          	cmp    $0x1,%ax
80105adc:	75 24                	jne    80105b02 <sys_open+0xdb>
80105ade:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ae1:	85 c0                	test   %eax,%eax
80105ae3:	74 1d                	je     80105b02 <sys_open+0xdb>
      iunlockput(ip);
80105ae5:	83 ec 0c             	sub    $0xc,%esp
80105ae8:	ff 75 f4             	push   -0xc(%ebp)
80105aeb:	e8 2b c1 ff ff       	call   80101c1b <iunlockput>
80105af0:	83 c4 10             	add    $0x10,%esp
      end_op();
80105af3:	e8 d0 d5 ff ff       	call   801030c8 <end_op>
      return -1;
80105af8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105afd:	e9 c0 00 00 00       	jmp    80105bc2 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105b02:	e8 d6 b4 ff ff       	call   80100fdd <filealloc>
80105b07:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b0e:	74 17                	je     80105b27 <sys_open+0x100>
80105b10:	83 ec 0c             	sub    $0xc,%esp
80105b13:	ff 75 f0             	push   -0x10(%ebp)
80105b16:	e8 33 f7 ff ff       	call   8010524e <fdalloc>
80105b1b:	83 c4 10             	add    $0x10,%esp
80105b1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105b21:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105b25:	79 2e                	jns    80105b55 <sys_open+0x12e>
    if(f)
80105b27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b2b:	74 0e                	je     80105b3b <sys_open+0x114>
      fileclose(f);
80105b2d:	83 ec 0c             	sub    $0xc,%esp
80105b30:	ff 75 f0             	push   -0x10(%ebp)
80105b33:	e8 63 b5 ff ff       	call   8010109b <fileclose>
80105b38:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105b3b:	83 ec 0c             	sub    $0xc,%esp
80105b3e:	ff 75 f4             	push   -0xc(%ebp)
80105b41:	e8 d5 c0 ff ff       	call   80101c1b <iunlockput>
80105b46:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b49:	e8 7a d5 ff ff       	call   801030c8 <end_op>
    return -1;
80105b4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b53:	eb 6d                	jmp    80105bc2 <sys_open+0x19b>
  }
  iunlock(ip);
80105b55:	83 ec 0c             	sub    $0xc,%esp
80105b58:	ff 75 f4             	push   -0xc(%ebp)
80105b5b:	e8 9d bf ff ff       	call   80101afd <iunlock>
80105b60:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b63:	e8 60 d5 ff ff       	call   801030c8 <end_op>

  f->type = FD_INODE;
80105b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6b:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b74:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b77:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105b84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b87:	83 e0 01             	and    $0x1,%eax
80105b8a:	85 c0                	test   %eax,%eax
80105b8c:	0f 94 c0             	sete   %al
80105b8f:	89 c2                	mov    %eax,%edx
80105b91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b94:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105b97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b9a:	83 e0 01             	and    $0x1,%eax
80105b9d:	85 c0                	test   %eax,%eax
80105b9f:	75 0a                	jne    80105bab <sys_open+0x184>
80105ba1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ba4:	83 e0 02             	and    $0x2,%eax
80105ba7:	85 c0                	test   %eax,%eax
80105ba9:	74 07                	je     80105bb2 <sys_open+0x18b>
80105bab:	b8 01 00 00 00       	mov    $0x1,%eax
80105bb0:	eb 05                	jmp    80105bb7 <sys_open+0x190>
80105bb2:	b8 00 00 00 00       	mov    $0x0,%eax
80105bb7:	89 c2                	mov    %eax,%edx
80105bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bbc:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105bbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105bc2:	c9                   	leave  
80105bc3:	c3                   	ret    

80105bc4 <sys_mkdir>:

int
sys_mkdir(void)
{
80105bc4:	55                   	push   %ebp
80105bc5:	89 e5                	mov    %esp,%ebp
80105bc7:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105bca:	e8 6d d4 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105bcf:	83 ec 08             	sub    $0x8,%esp
80105bd2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bd5:	50                   	push   %eax
80105bd6:	6a 00                	push   $0x0
80105bd8:	e8 48 f5 ff ff       	call   80105125 <argstr>
80105bdd:	83 c4 10             	add    $0x10,%esp
80105be0:	85 c0                	test   %eax,%eax
80105be2:	78 1b                	js     80105bff <sys_mkdir+0x3b>
80105be4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105be7:	6a 00                	push   $0x0
80105be9:	6a 00                	push   $0x0
80105beb:	6a 01                	push   $0x1
80105bed:	50                   	push   %eax
80105bee:	e8 62 fc ff ff       	call   80105855 <create>
80105bf3:	83 c4 10             	add    $0x10,%esp
80105bf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bf9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bfd:	75 0c                	jne    80105c0b <sys_mkdir+0x47>
    end_op();
80105bff:	e8 c4 d4 ff ff       	call   801030c8 <end_op>
    return -1;
80105c04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c09:	eb 18                	jmp    80105c23 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105c0b:	83 ec 0c             	sub    $0xc,%esp
80105c0e:	ff 75 f4             	push   -0xc(%ebp)
80105c11:	e8 05 c0 ff ff       	call   80101c1b <iunlockput>
80105c16:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c19:	e8 aa d4 ff ff       	call   801030c8 <end_op>
  return 0;
80105c1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c23:	c9                   	leave  
80105c24:	c3                   	ret    

80105c25 <sys_mknod>:

int
sys_mknod(void)
{
80105c25:	55                   	push   %ebp
80105c26:	89 e5                	mov    %esp,%ebp
80105c28:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105c2b:	e8 0c d4 ff ff       	call   8010303c <begin_op>
  if((argstr(0, &path)) < 0 ||
80105c30:	83 ec 08             	sub    $0x8,%esp
80105c33:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c36:	50                   	push   %eax
80105c37:	6a 00                	push   $0x0
80105c39:	e8 e7 f4 ff ff       	call   80105125 <argstr>
80105c3e:	83 c4 10             	add    $0x10,%esp
80105c41:	85 c0                	test   %eax,%eax
80105c43:	78 4f                	js     80105c94 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105c45:	83 ec 08             	sub    $0x8,%esp
80105c48:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c4b:	50                   	push   %eax
80105c4c:	6a 01                	push   $0x1
80105c4e:	e8 3d f4 ff ff       	call   80105090 <argint>
80105c53:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105c56:	85 c0                	test   %eax,%eax
80105c58:	78 3a                	js     80105c94 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105c5a:	83 ec 08             	sub    $0x8,%esp
80105c5d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c60:	50                   	push   %eax
80105c61:	6a 02                	push   $0x2
80105c63:	e8 28 f4 ff ff       	call   80105090 <argint>
80105c68:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105c6b:	85 c0                	test   %eax,%eax
80105c6d:	78 25                	js     80105c94 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105c6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c72:	0f bf c8             	movswl %ax,%ecx
80105c75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c78:	0f bf d0             	movswl %ax,%edx
80105c7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7e:	51                   	push   %ecx
80105c7f:	52                   	push   %edx
80105c80:	6a 03                	push   $0x3
80105c82:	50                   	push   %eax
80105c83:	e8 cd fb ff ff       	call   80105855 <create>
80105c88:	83 c4 10             	add    $0x10,%esp
80105c8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105c8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c92:	75 0c                	jne    80105ca0 <sys_mknod+0x7b>
    end_op();
80105c94:	e8 2f d4 ff ff       	call   801030c8 <end_op>
    return -1;
80105c99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c9e:	eb 18                	jmp    80105cb8 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105ca0:	83 ec 0c             	sub    $0xc,%esp
80105ca3:	ff 75 f4             	push   -0xc(%ebp)
80105ca6:	e8 70 bf ff ff       	call   80101c1b <iunlockput>
80105cab:	83 c4 10             	add    $0x10,%esp
  end_op();
80105cae:	e8 15 d4 ff ff       	call   801030c8 <end_op>
  return 0;
80105cb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cb8:	c9                   	leave  
80105cb9:	c3                   	ret    

80105cba <sys_chdir>:

int
sys_chdir(void)
{
80105cba:	55                   	push   %ebp
80105cbb:	89 e5                	mov    %esp,%ebp
80105cbd:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105cc0:	e8 6b dd ff ff       	call   80103a30 <myproc>
80105cc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105cc8:	e8 6f d3 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105ccd:	83 ec 08             	sub    $0x8,%esp
80105cd0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cd3:	50                   	push   %eax
80105cd4:	6a 00                	push   $0x0
80105cd6:	e8 4a f4 ff ff       	call   80105125 <argstr>
80105cdb:	83 c4 10             	add    $0x10,%esp
80105cde:	85 c0                	test   %eax,%eax
80105ce0:	78 18                	js     80105cfa <sys_chdir+0x40>
80105ce2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ce5:	83 ec 0c             	sub    $0xc,%esp
80105ce8:	50                   	push   %eax
80105ce9:	e8 2f c8 ff ff       	call   8010251d <namei>
80105cee:	83 c4 10             	add    $0x10,%esp
80105cf1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cf4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cf8:	75 0c                	jne    80105d06 <sys_chdir+0x4c>
    end_op();
80105cfa:	e8 c9 d3 ff ff       	call   801030c8 <end_op>
    return -1;
80105cff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d04:	eb 68                	jmp    80105d6e <sys_chdir+0xb4>
  }
  ilock(ip);
80105d06:	83 ec 0c             	sub    $0xc,%esp
80105d09:	ff 75 f0             	push   -0x10(%ebp)
80105d0c:	e8 d9 bc ff ff       	call   801019ea <ilock>
80105d11:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105d14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d17:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d1b:	66 83 f8 01          	cmp    $0x1,%ax
80105d1f:	74 1a                	je     80105d3b <sys_chdir+0x81>
    iunlockput(ip);
80105d21:	83 ec 0c             	sub    $0xc,%esp
80105d24:	ff 75 f0             	push   -0x10(%ebp)
80105d27:	e8 ef be ff ff       	call   80101c1b <iunlockput>
80105d2c:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d2f:	e8 94 d3 ff ff       	call   801030c8 <end_op>
    return -1;
80105d34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d39:	eb 33                	jmp    80105d6e <sys_chdir+0xb4>
  }
  iunlock(ip);
80105d3b:	83 ec 0c             	sub    $0xc,%esp
80105d3e:	ff 75 f0             	push   -0x10(%ebp)
80105d41:	e8 b7 bd ff ff       	call   80101afd <iunlock>
80105d46:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4c:	8b 40 68             	mov    0x68(%eax),%eax
80105d4f:	83 ec 0c             	sub    $0xc,%esp
80105d52:	50                   	push   %eax
80105d53:	e8 f3 bd ff ff       	call   80101b4b <iput>
80105d58:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d5b:	e8 68 d3 ff ff       	call   801030c8 <end_op>
  curproc->cwd = ip;
80105d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d63:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d66:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105d69:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d6e:	c9                   	leave  
80105d6f:	c3                   	ret    

80105d70 <sys_exec>:

int
sys_exec(void)
{
80105d70:	55                   	push   %ebp
80105d71:	89 e5                	mov    %esp,%ebp
80105d73:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105d79:	83 ec 08             	sub    $0x8,%esp
80105d7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d7f:	50                   	push   %eax
80105d80:	6a 00                	push   $0x0
80105d82:	e8 9e f3 ff ff       	call   80105125 <argstr>
80105d87:	83 c4 10             	add    $0x10,%esp
80105d8a:	85 c0                	test   %eax,%eax
80105d8c:	78 18                	js     80105da6 <sys_exec+0x36>
80105d8e:	83 ec 08             	sub    $0x8,%esp
80105d91:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105d97:	50                   	push   %eax
80105d98:	6a 01                	push   $0x1
80105d9a:	e8 f1 f2 ff ff       	call   80105090 <argint>
80105d9f:	83 c4 10             	add    $0x10,%esp
80105da2:	85 c0                	test   %eax,%eax
80105da4:	79 0a                	jns    80105db0 <sys_exec+0x40>
    return -1;
80105da6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dab:	e9 c6 00 00 00       	jmp    80105e76 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105db0:	83 ec 04             	sub    $0x4,%esp
80105db3:	68 80 00 00 00       	push   $0x80
80105db8:	6a 00                	push   $0x0
80105dba:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105dc0:	50                   	push   %eax
80105dc1:	e8 9f ef ff ff       	call   80104d65 <memset>
80105dc6:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105dc9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd3:	83 f8 1f             	cmp    $0x1f,%eax
80105dd6:	76 0a                	jbe    80105de2 <sys_exec+0x72>
      return -1;
80105dd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ddd:	e9 94 00 00 00       	jmp    80105e76 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de5:	c1 e0 02             	shl    $0x2,%eax
80105de8:	89 c2                	mov    %eax,%edx
80105dea:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105df0:	01 c2                	add    %eax,%edx
80105df2:	83 ec 08             	sub    $0x8,%esp
80105df5:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105dfb:	50                   	push   %eax
80105dfc:	52                   	push   %edx
80105dfd:	e8 ed f1 ff ff       	call   80104fef <fetchint>
80105e02:	83 c4 10             	add    $0x10,%esp
80105e05:	85 c0                	test   %eax,%eax
80105e07:	79 07                	jns    80105e10 <sys_exec+0xa0>
      return -1;
80105e09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e0e:	eb 66                	jmp    80105e76 <sys_exec+0x106>
    if(uarg == 0){
80105e10:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e16:	85 c0                	test   %eax,%eax
80105e18:	75 27                	jne    80105e41 <sys_exec+0xd1>
      argv[i] = 0;
80105e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105e24:	00 00 00 00 
      break;
80105e28:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e2c:	83 ec 08             	sub    $0x8,%esp
80105e2f:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e35:	52                   	push   %edx
80105e36:	50                   	push   %eax
80105e37:	e8 44 ad ff ff       	call   80100b80 <exec>
80105e3c:	83 c4 10             	add    $0x10,%esp
80105e3f:	eb 35                	jmp    80105e76 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105e41:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4a:	c1 e0 02             	shl    $0x2,%eax
80105e4d:	01 c2                	add    %eax,%edx
80105e4f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e55:	83 ec 08             	sub    $0x8,%esp
80105e58:	52                   	push   %edx
80105e59:	50                   	push   %eax
80105e5a:	e8 cf f1 ff ff       	call   8010502e <fetchstr>
80105e5f:	83 c4 10             	add    $0x10,%esp
80105e62:	85 c0                	test   %eax,%eax
80105e64:	79 07                	jns    80105e6d <sys_exec+0xfd>
      return -1;
80105e66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e6b:	eb 09                	jmp    80105e76 <sys_exec+0x106>
  for(i=0;; i++){
80105e6d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e71:	e9 5a ff ff ff       	jmp    80105dd0 <sys_exec+0x60>
}
80105e76:	c9                   	leave  
80105e77:	c3                   	ret    

80105e78 <sys_pipe>:

int
sys_pipe(void)
{
80105e78:	55                   	push   %ebp
80105e79:	89 e5                	mov    %esp,%ebp
80105e7b:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105e7e:	83 ec 04             	sub    $0x4,%esp
80105e81:	6a 08                	push   $0x8
80105e83:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e86:	50                   	push   %eax
80105e87:	6a 00                	push   $0x0
80105e89:	e8 2f f2 ff ff       	call   801050bd <argptr>
80105e8e:	83 c4 10             	add    $0x10,%esp
80105e91:	85 c0                	test   %eax,%eax
80105e93:	79 0a                	jns    80105e9f <sys_pipe+0x27>
    return -1;
80105e95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e9a:	e9 ae 00 00 00       	jmp    80105f4d <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105e9f:	83 ec 08             	sub    $0x8,%esp
80105ea2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ea5:	50                   	push   %eax
80105ea6:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ea9:	50                   	push   %eax
80105eaa:	e8 be d6 ff ff       	call   8010356d <pipealloc>
80105eaf:	83 c4 10             	add    $0x10,%esp
80105eb2:	85 c0                	test   %eax,%eax
80105eb4:	79 0a                	jns    80105ec0 <sys_pipe+0x48>
    return -1;
80105eb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ebb:	e9 8d 00 00 00       	jmp    80105f4d <sys_pipe+0xd5>
  fd0 = -1;
80105ec0:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105ec7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105eca:	83 ec 0c             	sub    $0xc,%esp
80105ecd:	50                   	push   %eax
80105ece:	e8 7b f3 ff ff       	call   8010524e <fdalloc>
80105ed3:	83 c4 10             	add    $0x10,%esp
80105ed6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ed9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105edd:	78 18                	js     80105ef7 <sys_pipe+0x7f>
80105edf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ee2:	83 ec 0c             	sub    $0xc,%esp
80105ee5:	50                   	push   %eax
80105ee6:	e8 63 f3 ff ff       	call   8010524e <fdalloc>
80105eeb:	83 c4 10             	add    $0x10,%esp
80105eee:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ef1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ef5:	79 3e                	jns    80105f35 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105ef7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105efb:	78 13                	js     80105f10 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105efd:	e8 2e db ff ff       	call   80103a30 <myproc>
80105f02:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f05:	83 c2 08             	add    $0x8,%edx
80105f08:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105f0f:	00 
    fileclose(rf);
80105f10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f13:	83 ec 0c             	sub    $0xc,%esp
80105f16:	50                   	push   %eax
80105f17:	e8 7f b1 ff ff       	call   8010109b <fileclose>
80105f1c:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105f1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f22:	83 ec 0c             	sub    $0xc,%esp
80105f25:	50                   	push   %eax
80105f26:	e8 70 b1 ff ff       	call   8010109b <fileclose>
80105f2b:	83 c4 10             	add    $0x10,%esp
    return -1;
80105f2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f33:	eb 18                	jmp    80105f4d <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105f35:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f3b:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105f3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f40:	8d 50 04             	lea    0x4(%eax),%edx
80105f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f46:	89 02                	mov    %eax,(%edx)
  return 0;
80105f48:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f4d:	c9                   	leave  
80105f4e:	c3                   	ret    

80105f4f <sys_fork>:
  struct proc proc[NPROC];
} ptable;

int
sys_fork(void)
{
80105f4f:	55                   	push   %ebp
80105f50:	89 e5                	mov    %esp,%ebp
80105f52:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105f55:	e8 30 de ff ff       	call   80103d8a <fork>
}
80105f5a:	c9                   	leave  
80105f5b:	c3                   	ret    

80105f5c <sys_exit>:

int
sys_exit(void)
{
80105f5c:	55                   	push   %ebp
80105f5d:	89 e5                	mov    %esp,%ebp
80105f5f:	83 ec 08             	sub    $0x8,%esp
  exit();
80105f62:	e8 9c df ff ff       	call   80103f03 <exit>
  return 0;  // not reached
80105f67:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f6c:	c9                   	leave  
80105f6d:	c3                   	ret    

80105f6e <sys_wait>:

int
sys_wait(void)
{
80105f6e:	55                   	push   %ebp
80105f6f:	89 e5                	mov    %esp,%ebp
80105f71:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105f74:	e8 ee e0 ff ff       	call   80104067 <wait>
}
80105f79:	c9                   	leave  
80105f7a:	c3                   	ret    

80105f7b <sys_kill>:

int
sys_kill(void)
{
80105f7b:	55                   	push   %ebp
80105f7c:	89 e5                	mov    %esp,%ebp
80105f7e:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105f81:	83 ec 08             	sub    $0x8,%esp
80105f84:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f87:	50                   	push   %eax
80105f88:	6a 00                	push   $0x0
80105f8a:	e8 01 f1 ff ff       	call   80105090 <argint>
80105f8f:	83 c4 10             	add    $0x10,%esp
80105f92:	85 c0                	test   %eax,%eax
80105f94:	79 07                	jns    80105f9d <sys_kill+0x22>
    return -1;
80105f96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f9b:	eb 0f                	jmp    80105fac <sys_kill+0x31>
  return kill(pid);
80105f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa0:	83 ec 0c             	sub    $0xc,%esp
80105fa3:	50                   	push   %eax
80105fa4:	e8 43 e8 ff ff       	call   801047ec <kill>
80105fa9:	83 c4 10             	add    $0x10,%esp
}
80105fac:	c9                   	leave  
80105fad:	c3                   	ret    

80105fae <sys_getpid>:

int
sys_getpid(void)
{
80105fae:	55                   	push   %ebp
80105faf:	89 e5                	mov    %esp,%ebp
80105fb1:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105fb4:	e8 77 da ff ff       	call   80103a30 <myproc>
80105fb9:	8b 40 10             	mov    0x10(%eax),%eax
}
80105fbc:	c9                   	leave  
80105fbd:	c3                   	ret    

80105fbe <sys_sbrk>:

int
sys_sbrk(void)
{
80105fbe:	55                   	push   %ebp
80105fbf:	89 e5                	mov    %esp,%ebp
80105fc1:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105fc4:	83 ec 08             	sub    $0x8,%esp
80105fc7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105fca:	50                   	push   %eax
80105fcb:	6a 00                	push   $0x0
80105fcd:	e8 be f0 ff ff       	call   80105090 <argint>
80105fd2:	83 c4 10             	add    $0x10,%esp
80105fd5:	85 c0                	test   %eax,%eax
80105fd7:	79 07                	jns    80105fe0 <sys_sbrk+0x22>
    return -1;
80105fd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fde:	eb 27                	jmp    80106007 <sys_sbrk+0x49>
  addr = myproc()->sz;
80105fe0:	e8 4b da ff ff       	call   80103a30 <myproc>
80105fe5:	8b 00                	mov    (%eax),%eax
80105fe7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fed:	83 ec 0c             	sub    $0xc,%esp
80105ff0:	50                   	push   %eax
80105ff1:	e8 f9 dc ff ff       	call   80103cef <growproc>
80105ff6:	83 c4 10             	add    $0x10,%esp
80105ff9:	85 c0                	test   %eax,%eax
80105ffb:	79 07                	jns    80106004 <sys_sbrk+0x46>
    return -1;
80105ffd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106002:	eb 03                	jmp    80106007 <sys_sbrk+0x49>
  return addr;
80106004:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106007:	c9                   	leave  
80106008:	c3                   	ret    

80106009 <sys_sleep>:

int
sys_sleep(void)
{
80106009:	55                   	push   %ebp
8010600a:	89 e5                	mov    %esp,%ebp
8010600c:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010600f:	83 ec 08             	sub    $0x8,%esp
80106012:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106015:	50                   	push   %eax
80106016:	6a 00                	push   $0x0
80106018:	e8 73 f0 ff ff       	call   80105090 <argint>
8010601d:	83 c4 10             	add    $0x10,%esp
80106020:	85 c0                	test   %eax,%eax
80106022:	79 07                	jns    8010602b <sys_sleep+0x22>
    return -1;
80106024:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106029:	eb 76                	jmp    801060a1 <sys_sleep+0x98>
  acquire(&tickslock);
8010602b:	83 ec 0c             	sub    $0xc,%esp
8010602e:	68 40 74 19 80       	push   $0x80197440
80106033:	e8 b7 ea ff ff       	call   80104aef <acquire>
80106038:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010603b:	a1 74 74 19 80       	mov    0x80197474,%eax
80106040:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106043:	eb 38                	jmp    8010607d <sys_sleep+0x74>
    if(myproc()->killed){
80106045:	e8 e6 d9 ff ff       	call   80103a30 <myproc>
8010604a:	8b 40 24             	mov    0x24(%eax),%eax
8010604d:	85 c0                	test   %eax,%eax
8010604f:	74 17                	je     80106068 <sys_sleep+0x5f>
      release(&tickslock);
80106051:	83 ec 0c             	sub    $0xc,%esp
80106054:	68 40 74 19 80       	push   $0x80197440
80106059:	e8 ff ea ff ff       	call   80104b5d <release>
8010605e:	83 c4 10             	add    $0x10,%esp
      return -1;
80106061:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106066:	eb 39                	jmp    801060a1 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80106068:	83 ec 08             	sub    $0x8,%esp
8010606b:	68 40 74 19 80       	push   $0x80197440
80106070:	68 74 74 19 80       	push   $0x80197474
80106075:	e8 51 e6 ff ff       	call   801046cb <sleep>
8010607a:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010607d:	a1 74 74 19 80       	mov    0x80197474,%eax
80106082:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106085:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106088:	39 d0                	cmp    %edx,%eax
8010608a:	72 b9                	jb     80106045 <sys_sleep+0x3c>
  }
  release(&tickslock);
8010608c:	83 ec 0c             	sub    $0xc,%esp
8010608f:	68 40 74 19 80       	push   $0x80197440
80106094:	e8 c4 ea ff ff       	call   80104b5d <release>
80106099:	83 c4 10             	add    $0x10,%esp
  return 0;
8010609c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060a1:	c9                   	leave  
801060a2:	c3                   	ret    

801060a3 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801060a3:	55                   	push   %ebp
801060a4:	89 e5                	mov    %esp,%ebp
801060a6:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801060a9:	83 ec 0c             	sub    $0xc,%esp
801060ac:	68 40 74 19 80       	push   $0x80197440
801060b1:	e8 39 ea ff ff       	call   80104aef <acquire>
801060b6:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801060b9:	a1 74 74 19 80       	mov    0x80197474,%eax
801060be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801060c1:	83 ec 0c             	sub    $0xc,%esp
801060c4:	68 40 74 19 80       	push   $0x80197440
801060c9:	e8 8f ea ff ff       	call   80104b5d <release>
801060ce:	83 c4 10             	add    $0x10,%esp
  return xticks;
801060d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801060d4:	c9                   	leave  
801060d5:	c3                   	ret    

801060d6 <sys_uthread_init>:

// 이거 추가
int
sys_uthread_init(void)
{
801060d6:	55                   	push   %ebp
801060d7:	89 e5                	mov    %esp,%ebp
801060d9:	53                   	push   %ebx
801060da:	83 ec 14             	sub    $0x14,%esp
  int addr;
  if (argint(0, &addr) < 0)
801060dd:	83 ec 08             	sub    $0x8,%esp
801060e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801060e3:	50                   	push   %eax
801060e4:	6a 00                	push   $0x0
801060e6:	e8 a5 ef ff ff       	call   80105090 <argint>
801060eb:	83 c4 10             	add    $0x10,%esp
801060ee:	85 c0                	test   %eax,%eax
801060f0:	79 07                	jns    801060f9 <sys_uthread_init+0x23>
    return -1;
801060f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f7:	eb 12                	jmp    8010610b <sys_uthread_init+0x35>
  myproc()->scheduler = addr;
801060f9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801060fc:	e8 2f d9 ff ff       	call   80103a30 <myproc>
80106101:	89 da                	mov    %ebx,%edx
80106103:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
80106106:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010610b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010610e:	c9                   	leave  
8010610f:	c3                   	ret    

80106110 <sys_check_thread>:



int
sys_check_thread(void) {
80106110:	55                   	push   %ebp
80106111:	89 e5                	mov    %esp,%ebp
80106113:	83 ec 18             	sub    $0x18,%esp
  int op;
  if (argint(0, &op) < 0)  // 사용자로부터 인자 하나 받음
80106116:	83 ec 08             	sub    $0x8,%esp
80106119:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010611c:	50                   	push   %eax
8010611d:	6a 00                	push   $0x0
8010611f:	e8 6c ef ff ff       	call   80105090 <argint>
80106124:	83 c4 10             	add    $0x10,%esp
80106127:	85 c0                	test   %eax,%eax
80106129:	79 07                	jns    80106132 <sys_check_thread+0x22>
    return -1;
8010612b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106130:	eb 24                	jmp    80106156 <sys_check_thread+0x46>

  struct proc* p = myproc();
80106132:	e8 f9 d8 ff ff       	call   80103a30 <myproc>
80106137:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p->check_thread += op;  // +1 또는 -1
8010613a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010613d:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80106143:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106146:	01 c2                	add    %eax,%edx
80106148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010614b:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  return 0;
80106151:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106156:	c9                   	leave  
80106157:	c3                   	ret    

80106158 <sys_getpinfo>:


int
sys_getpinfo(void) {
80106158:	55                   	push   %ebp
80106159:	89 e5                	mov    %esp,%ebp
8010615b:	53                   	push   %ebx
8010615c:	83 ec 14             	sub    $0x14,%esp
  struct pstat *ps;
  if (argptr(0, (void *)&ps, sizeof(*ps)) < 0)
8010615f:	83 ec 04             	sub    $0x4,%esp
80106162:	68 00 0c 00 00       	push   $0xc00
80106167:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010616a:	50                   	push   %eax
8010616b:	6a 00                	push   $0x0
8010616d:	e8 4b ef ff ff       	call   801050bd <argptr>
80106172:	83 c4 10             	add    $0x10,%esp
80106175:	85 c0                	test   %eax,%eax
80106177:	79 0a                	jns    80106183 <sys_getpinfo+0x2b>
    return -1;
80106179:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010617e:	e9 21 01 00 00       	jmp    801062a4 <sys_getpinfo+0x14c>

  acquire(&ptable.lock);
80106183:	83 ec 0c             	sub    $0xc,%esp
80106186:	68 00 4b 19 80       	push   $0x80194b00
8010618b:	e8 5f e9 ff ff       	call   80104aef <acquire>
80106190:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
80106193:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010619a:	e9 e6 00 00 00       	jmp    80106285 <sys_getpinfo+0x12d>
    struct proc *p = &ptable.proc[i];
8010619f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a2:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
801061a8:	83 c0 30             	add    $0x30,%eax
801061ab:	05 00 4b 19 80       	add    $0x80194b00,%eax
801061b0:	83 c0 04             	add    $0x4,%eax
801061b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    ps->inuse[i] = (p->state != UNUSED);
801061b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061b9:	8b 40 0c             	mov    0xc(%eax),%eax
801061bc:	85 c0                	test   %eax,%eax
801061be:	0f 95 c2             	setne  %dl
801061c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061c4:	0f b6 ca             	movzbl %dl,%ecx
801061c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061ca:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    ps->pid[i] = p->pid;
801061cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801061d3:	8b 52 10             	mov    0x10(%edx),%edx
801061d6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801061d9:	83 c1 40             	add    $0x40,%ecx
801061dc:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->priority[i] = proc_priority[i];
801061df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061e5:	8b 14 95 00 42 19 80 	mov    -0x7fe6be00(,%edx,4),%edx
801061ec:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801061ef:	83 e9 80             	sub    $0xffffff80,%ecx
801061f2:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->state[i] = p->state;
801061f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061f8:	8b 50 0c             	mov    0xc(%eax),%edx
801061fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061fe:	89 d1                	mov    %edx,%ecx
80106200:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106203:	81 c2 c0 00 00 00    	add    $0xc0,%edx
80106209:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    for (int j = 0; j < 4; j++) {
8010620c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106213:	eb 66                	jmp    8010627b <sys_getpinfo+0x123>
      ps->ticks[i][j] = proc_ticks[i][j];
80106215:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106218:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010621b:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
80106222:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106225:	01 ca                	add    %ecx,%edx
80106227:	8b 14 95 00 43 19 80 	mov    -0x7fe6bd00(,%edx,4),%edx
8010622e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80106231:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80106238:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010623b:	01 d9                	add    %ebx,%ecx
8010623d:	81 c1 00 01 00 00    	add    $0x100,%ecx
80106243:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = proc_wait_ticks[i][j];
80106246:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106249:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010624c:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
80106253:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106256:	01 ca                	add    %ecx,%edx
80106258:	8b 14 95 00 47 19 80 	mov    -0x7fe6b900(,%edx,4),%edx
8010625f:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80106262:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80106269:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010626c:	01 d9                	add    %ebx,%ecx
8010626e:	81 c1 00 02 00 00    	add    $0x200,%ecx
80106274:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80106277:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010627b:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
8010627f:	7e 94                	jle    80106215 <sys_getpinfo+0xbd>
  for (int i = 0; i < NPROC; i++) {
80106281:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106285:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80106289:	0f 8e 10 ff ff ff    	jle    8010619f <sys_getpinfo+0x47>
    }
  }
  release(&ptable.lock);
8010628f:	83 ec 0c             	sub    $0xc,%esp
80106292:	68 00 4b 19 80       	push   $0x80194b00
80106297:	e8 c1 e8 ff ff       	call   80104b5d <release>
8010629c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010629f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801062a7:	c9                   	leave  
801062a8:	c3                   	ret    

801062a9 <sys_setSchedPolicy>:


int
sys_setSchedPolicy(void) {
801062a9:	55                   	push   %ebp
801062aa:	89 e5                	mov    %esp,%ebp
801062ac:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
801062af:	83 ec 08             	sub    $0x8,%esp
801062b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801062b5:	50                   	push   %eax
801062b6:	6a 00                	push   $0x0
801062b8:	e8 d3 ed ff ff       	call   80105090 <argint>
801062bd:	83 c4 10             	add    $0x10,%esp
801062c0:	85 c0                	test   %eax,%eax
801062c2:	79 07                	jns    801062cb <sys_setSchedPolicy+0x22>
    return -1;
801062c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c9:	eb 31                	jmp    801062fc <sys_setSchedPolicy+0x53>
  
  pushcli();  // ✅ 인터럽트 끄기 (mycpu 안전하게 호출하려면 필요)
801062cb:	e8 8a e9 ff ff       	call   80104c5a <pushcli>
  mycpu()->sched_policy = policy;
801062d0:	e8 e3 d6 ff ff       	call   801039b8 <mycpu>
801062d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062d8:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();   // ✅ 다시 인터럽트 복원
801062de:	e8 c4 e9 ff ff       	call   80104ca7 <popcli>

  cprintf("✅ sched_policy set to %d\n", policy);  // 💬 확인 로그!
801062e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e6:	83 ec 08             	sub    $0x8,%esp
801062e9:	50                   	push   %eax
801062ea:	68 37 aa 10 80       	push   $0x8010aa37
801062ef:	e8 00 a1 ff ff       	call   801003f4 <cprintf>
801062f4:	83 c4 10             	add    $0x10,%esp
  return 0;
801062f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062fc:	c9                   	leave  
801062fd:	c3                   	ret    

801062fe <sys_yield>:

int
sys_yield(void)
{
801062fe:	55                   	push   %ebp
801062ff:	89 e5                	mov    %esp,%ebp
80106301:	83 ec 08             	sub    $0x8,%esp
  yield();
80106304:	e8 01 e3 ff ff       	call   8010460a <yield>
  return 0;
80106309:	b8 00 00 00 00       	mov    $0x0,%eax
8010630e:	c9                   	leave  
8010630f:	c3                   	ret    

80106310 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106310:	1e                   	push   %ds
  pushl %es
80106311:	06                   	push   %es
  pushl %fs
80106312:	0f a0                	push   %fs
  pushl %gs
80106314:	0f a8                	push   %gs
  pushal
80106316:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106317:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010631b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010631d:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010631f:	54                   	push   %esp
  call trap
80106320:	e8 d7 01 00 00       	call   801064fc <trap>
  addl $4, %esp
80106325:	83 c4 04             	add    $0x4,%esp

80106328 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106328:	61                   	popa   
  popl %gs
80106329:	0f a9                	pop    %gs
  popl %fs
8010632b:	0f a1                	pop    %fs
  popl %es
8010632d:	07                   	pop    %es
  popl %ds
8010632e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010632f:	83 c4 08             	add    $0x8,%esp
  iret
80106332:	cf                   	iret   

80106333 <lidt>:
{
80106333:	55                   	push   %ebp
80106334:	89 e5                	mov    %esp,%ebp
80106336:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106339:	8b 45 0c             	mov    0xc(%ebp),%eax
8010633c:	83 e8 01             	sub    $0x1,%eax
8010633f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106343:	8b 45 08             	mov    0x8(%ebp),%eax
80106346:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010634a:	8b 45 08             	mov    0x8(%ebp),%eax
8010634d:	c1 e8 10             	shr    $0x10,%eax
80106350:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106354:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106357:	0f 01 18             	lidtl  (%eax)
}
8010635a:	90                   	nop
8010635b:	c9                   	leave  
8010635c:	c3                   	ret    

8010635d <rcr2>:

static inline uint
rcr2(void)
{
8010635d:	55                   	push   %ebp
8010635e:	89 e5                	mov    %esp,%ebp
80106360:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106363:	0f 20 d0             	mov    %cr2,%eax
80106366:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106369:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010636c:	c9                   	leave  
8010636d:	c3                   	ret    

8010636e <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010636e:	55                   	push   %ebp
8010636f:	89 e5                	mov    %esp,%ebp
80106371:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106374:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010637b:	e9 c3 00 00 00       	jmp    80106443 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106383:	8b 04 85 8c f0 10 80 	mov    -0x7fef0f74(,%eax,4),%eax
8010638a:	89 c2                	mov    %eax,%edx
8010638c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010638f:	66 89 14 c5 40 6c 19 	mov    %dx,-0x7fe693c0(,%eax,8)
80106396:	80 
80106397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010639a:	66 c7 04 c5 42 6c 19 	movw   $0x8,-0x7fe693be(,%eax,8)
801063a1:	80 08 00 
801063a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a7:	0f b6 14 c5 44 6c 19 	movzbl -0x7fe693bc(,%eax,8),%edx
801063ae:	80 
801063af:	83 e2 e0             	and    $0xffffffe0,%edx
801063b2:	88 14 c5 44 6c 19 80 	mov    %dl,-0x7fe693bc(,%eax,8)
801063b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063bc:	0f b6 14 c5 44 6c 19 	movzbl -0x7fe693bc(,%eax,8),%edx
801063c3:	80 
801063c4:	83 e2 1f             	and    $0x1f,%edx
801063c7:	88 14 c5 44 6c 19 80 	mov    %dl,-0x7fe693bc(,%eax,8)
801063ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d1:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
801063d8:	80 
801063d9:	83 e2 f0             	and    $0xfffffff0,%edx
801063dc:	83 ca 0e             	or     $0xe,%edx
801063df:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
801063e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e9:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
801063f0:	80 
801063f1:	83 e2 ef             	and    $0xffffffef,%edx
801063f4:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
801063fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063fe:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
80106405:	80 
80106406:	83 e2 9f             	and    $0xffffff9f,%edx
80106409:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
80106410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106413:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
8010641a:	80 
8010641b:	83 ca 80             	or     $0xffffff80,%edx
8010641e:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
80106425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106428:	8b 04 85 8c f0 10 80 	mov    -0x7fef0f74(,%eax,4),%eax
8010642f:	c1 e8 10             	shr    $0x10,%eax
80106432:	89 c2                	mov    %eax,%edx
80106434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106437:	66 89 14 c5 46 6c 19 	mov    %dx,-0x7fe693ba(,%eax,8)
8010643e:	80 
  for(i = 0; i < 256; i++)
8010643f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106443:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010644a:	0f 8e 30 ff ff ff    	jle    80106380 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106450:	a1 8c f1 10 80       	mov    0x8010f18c,%eax
80106455:	66 a3 40 6e 19 80    	mov    %ax,0x80196e40
8010645b:	66 c7 05 42 6e 19 80 	movw   $0x8,0x80196e42
80106462:	08 00 
80106464:	0f b6 05 44 6e 19 80 	movzbl 0x80196e44,%eax
8010646b:	83 e0 e0             	and    $0xffffffe0,%eax
8010646e:	a2 44 6e 19 80       	mov    %al,0x80196e44
80106473:	0f b6 05 44 6e 19 80 	movzbl 0x80196e44,%eax
8010647a:	83 e0 1f             	and    $0x1f,%eax
8010647d:	a2 44 6e 19 80       	mov    %al,0x80196e44
80106482:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
80106489:	83 c8 0f             	or     $0xf,%eax
8010648c:	a2 45 6e 19 80       	mov    %al,0x80196e45
80106491:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
80106498:	83 e0 ef             	and    $0xffffffef,%eax
8010649b:	a2 45 6e 19 80       	mov    %al,0x80196e45
801064a0:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
801064a7:	83 c8 60             	or     $0x60,%eax
801064aa:	a2 45 6e 19 80       	mov    %al,0x80196e45
801064af:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
801064b6:	83 c8 80             	or     $0xffffff80,%eax
801064b9:	a2 45 6e 19 80       	mov    %al,0x80196e45
801064be:	a1 8c f1 10 80       	mov    0x8010f18c,%eax
801064c3:	c1 e8 10             	shr    $0x10,%eax
801064c6:	66 a3 46 6e 19 80    	mov    %ax,0x80196e46

  initlock(&tickslock, "time");
801064cc:	83 ec 08             	sub    $0x8,%esp
801064cf:	68 54 aa 10 80       	push   $0x8010aa54
801064d4:	68 40 74 19 80       	push   $0x80197440
801064d9:	e8 ef e5 ff ff       	call   80104acd <initlock>
801064de:	83 c4 10             	add    $0x10,%esp
}
801064e1:	90                   	nop
801064e2:	c9                   	leave  
801064e3:	c3                   	ret    

801064e4 <idtinit>:

void
idtinit(void)
{
801064e4:	55                   	push   %ebp
801064e5:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801064e7:	68 00 08 00 00       	push   $0x800
801064ec:	68 40 6c 19 80       	push   $0x80196c40
801064f1:	e8 3d fe ff ff       	call   80106333 <lidt>
801064f6:	83 c4 08             	add    $0x8,%esp
}
801064f9:	90                   	nop
801064fa:	c9                   	leave  
801064fb:	c3                   	ret    

801064fc <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801064fc:	55                   	push   %ebp
801064fd:	89 e5                	mov    %esp,%ebp
801064ff:	57                   	push   %edi
80106500:	56                   	push   %esi
80106501:	53                   	push   %ebx
80106502:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106505:	8b 45 08             	mov    0x8(%ebp),%eax
80106508:	8b 40 30             	mov    0x30(%eax),%eax
8010650b:	83 f8 40             	cmp    $0x40,%eax
8010650e:	75 3b                	jne    8010654b <trap+0x4f>
    if(myproc()->killed)
80106510:	e8 1b d5 ff ff       	call   80103a30 <myproc>
80106515:	8b 40 24             	mov    0x24(%eax),%eax
80106518:	85 c0                	test   %eax,%eax
8010651a:	74 05                	je     80106521 <trap+0x25>
      exit();
8010651c:	e8 e2 d9 ff ff       	call   80103f03 <exit>
    myproc()->tf = tf;
80106521:	e8 0a d5 ff ff       	call   80103a30 <myproc>
80106526:	8b 55 08             	mov    0x8(%ebp),%edx
80106529:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010652c:	e8 2b ec ff ff       	call   8010515c <syscall>
    if(myproc()->killed)
80106531:	e8 fa d4 ff ff       	call   80103a30 <myproc>
80106536:	8b 40 24             	mov    0x24(%eax),%eax
80106539:	85 c0                	test   %eax,%eax
8010653b:	0f 84 68 02 00 00    	je     801067a9 <trap+0x2ad>
      exit();
80106541:	e8 bd d9 ff ff       	call   80103f03 <exit>
    return;
80106546:	e9 5e 02 00 00       	jmp    801067a9 <trap+0x2ad>
  }

  switch(tf->trapno){
8010654b:	8b 45 08             	mov    0x8(%ebp),%eax
8010654e:	8b 40 30             	mov    0x30(%eax),%eax
80106551:	83 e8 20             	sub    $0x20,%eax
80106554:	83 f8 1f             	cmp    $0x1f,%eax
80106557:	0f 87 14 01 00 00    	ja     80106671 <trap+0x175>
8010655d:	8b 04 85 fc aa 10 80 	mov    -0x7fef5504(,%eax,4),%eax
80106564:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106566:	e8 32 d4 ff ff       	call   8010399d <cpuid>
8010656b:	85 c0                	test   %eax,%eax
8010656d:	75 3d                	jne    801065ac <trap+0xb0>
      acquire(&tickslock);
8010656f:	83 ec 0c             	sub    $0xc,%esp
80106572:	68 40 74 19 80       	push   $0x80197440
80106577:	e8 73 e5 ff ff       	call   80104aef <acquire>
8010657c:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010657f:	a1 74 74 19 80       	mov    0x80197474,%eax
80106584:	83 c0 01             	add    $0x1,%eax
80106587:	a3 74 74 19 80       	mov    %eax,0x80197474
      wakeup(&ticks);
8010658c:	83 ec 0c             	sub    $0xc,%esp
8010658f:	68 74 74 19 80       	push   $0x80197474
80106594:	e8 1c e2 ff ff       	call   801047b5 <wakeup>
80106599:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010659c:	83 ec 0c             	sub    $0xc,%esp
8010659f:	68 40 74 19 80       	push   $0x80197440
801065a4:	e8 b4 e5 ff ff       	call   80104b5d <release>
801065a9:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801065ac:	e8 6b c5 ff ff       	call   80102b1c <lapiceoi>

    // 🔥 유저모드 + scheduler 설정된 경우만 실행
    struct proc *p = myproc();
801065b1:	e8 7a d4 ff ff       	call   80103a30 <myproc>
801065b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p && p->state == RUNNING && p->scheduler) {
801065b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801065bd:	0f 84 65 01 00 00    	je     80106728 <trap+0x22c>
801065c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065c6:	8b 40 0c             	mov    0xc(%eax),%eax
801065c9:	83 f8 04             	cmp    $0x4,%eax
801065cc:	0f 85 56 01 00 00    	jne    80106728 <trap+0x22c>
801065d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065d5:	8b 40 7c             	mov    0x7c(%eax),%eax
801065d8:	85 c0                	test   %eax,%eax
801065da:	0f 84 48 01 00 00    	je     80106728 <trap+0x22c>
      if(p->check_thread >= 2){
801065e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065e3:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801065e9:	83 f8 01             	cmp    $0x1,%eax
801065ec:	0f 8e 36 01 00 00    	jle    80106728 <trap+0x22c>
        p->tf->eip = p->scheduler;
801065f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065f5:	8b 40 18             	mov    0x18(%eax),%eax
801065f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801065fb:	8b 52 7c             	mov    0x7c(%edx),%edx
801065fe:	89 50 38             	mov    %edx,0x38(%eax)
      }
    }
    

    break;
80106601:	e9 22 01 00 00       	jmp    80106728 <trap+0x22c>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106606:	e8 f8 3e 00 00       	call   8010a503 <ideintr>
    lapiceoi();
8010660b:	e8 0c c5 ff ff       	call   80102b1c <lapiceoi>
    break;
80106610:	e9 14 01 00 00       	jmp    80106729 <trap+0x22d>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106615:	e8 47 c3 ff ff       	call   80102961 <kbdintr>
    lapiceoi();
8010661a:	e8 fd c4 ff ff       	call   80102b1c <lapiceoi>
    break;
8010661f:	e9 05 01 00 00       	jmp    80106729 <trap+0x22d>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106624:	e8 56 03 00 00       	call   8010697f <uartintr>
    lapiceoi();
80106629:	e8 ee c4 ff ff       	call   80102b1c <lapiceoi>
    break;
8010662e:	e9 f6 00 00 00       	jmp    80106729 <trap+0x22d>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106633:	e8 7e 2b 00 00       	call   801091b6 <i8254_intr>
    lapiceoi();
80106638:	e8 df c4 ff ff       	call   80102b1c <lapiceoi>
    break;
8010663d:	e9 e7 00 00 00       	jmp    80106729 <trap+0x22d>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106642:	8b 45 08             	mov    0x8(%ebp),%eax
80106645:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106648:	8b 45 08             	mov    0x8(%ebp),%eax
8010664b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010664f:	0f b7 d8             	movzwl %ax,%ebx
80106652:	e8 46 d3 ff ff       	call   8010399d <cpuid>
80106657:	56                   	push   %esi
80106658:	53                   	push   %ebx
80106659:	50                   	push   %eax
8010665a:	68 5c aa 10 80       	push   $0x8010aa5c
8010665f:	e8 90 9d ff ff       	call   801003f4 <cprintf>
80106664:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106667:	e8 b0 c4 ff ff       	call   80102b1c <lapiceoi>
    break;
8010666c:	e9 b8 00 00 00       	jmp    80106729 <trap+0x22d>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106671:	e8 ba d3 ff ff       	call   80103a30 <myproc>
80106676:	85 c0                	test   %eax,%eax
80106678:	74 11                	je     8010668b <trap+0x18f>
8010667a:	8b 45 08             	mov    0x8(%ebp),%eax
8010667d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106681:	0f b7 c0             	movzwl %ax,%eax
80106684:	83 e0 03             	and    $0x3,%eax
80106687:	85 c0                	test   %eax,%eax
80106689:	75 39                	jne    801066c4 <trap+0x1c8>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010668b:	e8 cd fc ff ff       	call   8010635d <rcr2>
80106690:	89 c3                	mov    %eax,%ebx
80106692:	8b 45 08             	mov    0x8(%ebp),%eax
80106695:	8b 70 38             	mov    0x38(%eax),%esi
80106698:	e8 00 d3 ff ff       	call   8010399d <cpuid>
8010669d:	8b 55 08             	mov    0x8(%ebp),%edx
801066a0:	8b 52 30             	mov    0x30(%edx),%edx
801066a3:	83 ec 0c             	sub    $0xc,%esp
801066a6:	53                   	push   %ebx
801066a7:	56                   	push   %esi
801066a8:	50                   	push   %eax
801066a9:	52                   	push   %edx
801066aa:	68 80 aa 10 80       	push   $0x8010aa80
801066af:	e8 40 9d ff ff       	call   801003f4 <cprintf>
801066b4:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801066b7:	83 ec 0c             	sub    $0xc,%esp
801066ba:	68 b2 aa 10 80       	push   $0x8010aab2
801066bf:	e8 e5 9e ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801066c4:	e8 94 fc ff ff       	call   8010635d <rcr2>
801066c9:	89 c6                	mov    %eax,%esi
801066cb:	8b 45 08             	mov    0x8(%ebp),%eax
801066ce:	8b 40 38             	mov    0x38(%eax),%eax
801066d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801066d4:	e8 c4 d2 ff ff       	call   8010399d <cpuid>
801066d9:	89 c3                	mov    %eax,%ebx
801066db:	8b 45 08             	mov    0x8(%ebp),%eax
801066de:	8b 48 34             	mov    0x34(%eax),%ecx
801066e1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801066e4:	8b 45 08             	mov    0x8(%ebp),%eax
801066e7:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801066ea:	e8 41 d3 ff ff       	call   80103a30 <myproc>
801066ef:	8d 50 6c             	lea    0x6c(%eax),%edx
801066f2:	89 55 cc             	mov    %edx,-0x34(%ebp)
801066f5:	e8 36 d3 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801066fa:	8b 40 10             	mov    0x10(%eax),%eax
801066fd:	56                   	push   %esi
801066fe:	ff 75 d4             	push   -0x2c(%ebp)
80106701:	53                   	push   %ebx
80106702:	ff 75 d0             	push   -0x30(%ebp)
80106705:	57                   	push   %edi
80106706:	ff 75 cc             	push   -0x34(%ebp)
80106709:	50                   	push   %eax
8010670a:	68 b8 aa 10 80       	push   $0x8010aab8
8010670f:	e8 e0 9c ff ff       	call   801003f4 <cprintf>
80106714:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106717:	e8 14 d3 ff ff       	call   80103a30 <myproc>
8010671c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106723:	eb 04                	jmp    80106729 <trap+0x22d>
    break;
80106725:	90                   	nop
80106726:	eb 01                	jmp    80106729 <trap+0x22d>
    break;
80106728:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106729:	e8 02 d3 ff ff       	call   80103a30 <myproc>
8010672e:	85 c0                	test   %eax,%eax
80106730:	74 23                	je     80106755 <trap+0x259>
80106732:	e8 f9 d2 ff ff       	call   80103a30 <myproc>
80106737:	8b 40 24             	mov    0x24(%eax),%eax
8010673a:	85 c0                	test   %eax,%eax
8010673c:	74 17                	je     80106755 <trap+0x259>
8010673e:	8b 45 08             	mov    0x8(%ebp),%eax
80106741:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106745:	0f b7 c0             	movzwl %ax,%eax
80106748:	83 e0 03             	and    $0x3,%eax
8010674b:	83 f8 03             	cmp    $0x3,%eax
8010674e:	75 05                	jne    80106755 <trap+0x259>
    exit();
80106750:	e8 ae d7 ff ff       	call   80103f03 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106755:	e8 d6 d2 ff ff       	call   80103a30 <myproc>
8010675a:	85 c0                	test   %eax,%eax
8010675c:	74 1d                	je     8010677b <trap+0x27f>
8010675e:	e8 cd d2 ff ff       	call   80103a30 <myproc>
80106763:	8b 40 0c             	mov    0xc(%eax),%eax
80106766:	83 f8 04             	cmp    $0x4,%eax
80106769:	75 10                	jne    8010677b <trap+0x27f>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010676b:	8b 45 08             	mov    0x8(%ebp),%eax
8010676e:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106771:	83 f8 20             	cmp    $0x20,%eax
80106774:	75 05                	jne    8010677b <trap+0x27f>
    yield();
80106776:	e8 8f de ff ff       	call   8010460a <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010677b:	e8 b0 d2 ff ff       	call   80103a30 <myproc>
80106780:	85 c0                	test   %eax,%eax
80106782:	74 26                	je     801067aa <trap+0x2ae>
80106784:	e8 a7 d2 ff ff       	call   80103a30 <myproc>
80106789:	8b 40 24             	mov    0x24(%eax),%eax
8010678c:	85 c0                	test   %eax,%eax
8010678e:	74 1a                	je     801067aa <trap+0x2ae>
80106790:	8b 45 08             	mov    0x8(%ebp),%eax
80106793:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106797:	0f b7 c0             	movzwl %ax,%eax
8010679a:	83 e0 03             	and    $0x3,%eax
8010679d:	83 f8 03             	cmp    $0x3,%eax
801067a0:	75 08                	jne    801067aa <trap+0x2ae>
    exit();
801067a2:	e8 5c d7 ff ff       	call   80103f03 <exit>
801067a7:	eb 01                	jmp    801067aa <trap+0x2ae>
    return;
801067a9:	90                   	nop
}
801067aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801067ad:	5b                   	pop    %ebx
801067ae:	5e                   	pop    %esi
801067af:	5f                   	pop    %edi
801067b0:	5d                   	pop    %ebp
801067b1:	c3                   	ret    

801067b2 <inb>:
{
801067b2:	55                   	push   %ebp
801067b3:	89 e5                	mov    %esp,%ebp
801067b5:	83 ec 14             	sub    $0x14,%esp
801067b8:	8b 45 08             	mov    0x8(%ebp),%eax
801067bb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801067bf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801067c3:	89 c2                	mov    %eax,%edx
801067c5:	ec                   	in     (%dx),%al
801067c6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801067c9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801067cd:	c9                   	leave  
801067ce:	c3                   	ret    

801067cf <outb>:
{
801067cf:	55                   	push   %ebp
801067d0:	89 e5                	mov    %esp,%ebp
801067d2:	83 ec 08             	sub    $0x8,%esp
801067d5:	8b 45 08             	mov    0x8(%ebp),%eax
801067d8:	8b 55 0c             	mov    0xc(%ebp),%edx
801067db:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801067df:	89 d0                	mov    %edx,%eax
801067e1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801067e4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801067e8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801067ec:	ee                   	out    %al,(%dx)
}
801067ed:	90                   	nop
801067ee:	c9                   	leave  
801067ef:	c3                   	ret    

801067f0 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801067f0:	55                   	push   %ebp
801067f1:	89 e5                	mov    %esp,%ebp
801067f3:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801067f6:	6a 00                	push   $0x0
801067f8:	68 fa 03 00 00       	push   $0x3fa
801067fd:	e8 cd ff ff ff       	call   801067cf <outb>
80106802:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106805:	68 80 00 00 00       	push   $0x80
8010680a:	68 fb 03 00 00       	push   $0x3fb
8010680f:	e8 bb ff ff ff       	call   801067cf <outb>
80106814:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106817:	6a 0c                	push   $0xc
80106819:	68 f8 03 00 00       	push   $0x3f8
8010681e:	e8 ac ff ff ff       	call   801067cf <outb>
80106823:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106826:	6a 00                	push   $0x0
80106828:	68 f9 03 00 00       	push   $0x3f9
8010682d:	e8 9d ff ff ff       	call   801067cf <outb>
80106832:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106835:	6a 03                	push   $0x3
80106837:	68 fb 03 00 00       	push   $0x3fb
8010683c:	e8 8e ff ff ff       	call   801067cf <outb>
80106841:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106844:	6a 00                	push   $0x0
80106846:	68 fc 03 00 00       	push   $0x3fc
8010684b:	e8 7f ff ff ff       	call   801067cf <outb>
80106850:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106853:	6a 01                	push   $0x1
80106855:	68 f9 03 00 00       	push   $0x3f9
8010685a:	e8 70 ff ff ff       	call   801067cf <outb>
8010685f:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106862:	68 fd 03 00 00       	push   $0x3fd
80106867:	e8 46 ff ff ff       	call   801067b2 <inb>
8010686c:	83 c4 04             	add    $0x4,%esp
8010686f:	3c ff                	cmp    $0xff,%al
80106871:	74 61                	je     801068d4 <uartinit+0xe4>
    return;
  uart = 1;
80106873:	c7 05 78 74 19 80 01 	movl   $0x1,0x80197478
8010687a:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010687d:	68 fa 03 00 00       	push   $0x3fa
80106882:	e8 2b ff ff ff       	call   801067b2 <inb>
80106887:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010688a:	68 f8 03 00 00       	push   $0x3f8
8010688f:	e8 1e ff ff ff       	call   801067b2 <inb>
80106894:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106897:	83 ec 08             	sub    $0x8,%esp
8010689a:	6a 00                	push   $0x0
8010689c:	6a 04                	push   $0x4
8010689e:	e8 8b bd ff ff       	call   8010262e <ioapicenable>
801068a3:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801068a6:	c7 45 f4 7c ab 10 80 	movl   $0x8010ab7c,-0xc(%ebp)
801068ad:	eb 19                	jmp    801068c8 <uartinit+0xd8>
    uartputc(*p);
801068af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068b2:	0f b6 00             	movzbl (%eax),%eax
801068b5:	0f be c0             	movsbl %al,%eax
801068b8:	83 ec 0c             	sub    $0xc,%esp
801068bb:	50                   	push   %eax
801068bc:	e8 16 00 00 00       	call   801068d7 <uartputc>
801068c1:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801068c4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801068c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068cb:	0f b6 00             	movzbl (%eax),%eax
801068ce:	84 c0                	test   %al,%al
801068d0:	75 dd                	jne    801068af <uartinit+0xbf>
801068d2:	eb 01                	jmp    801068d5 <uartinit+0xe5>
    return;
801068d4:	90                   	nop
}
801068d5:	c9                   	leave  
801068d6:	c3                   	ret    

801068d7 <uartputc>:

void
uartputc(int c)
{
801068d7:	55                   	push   %ebp
801068d8:	89 e5                	mov    %esp,%ebp
801068da:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801068dd:	a1 78 74 19 80       	mov    0x80197478,%eax
801068e2:	85 c0                	test   %eax,%eax
801068e4:	74 53                	je     80106939 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801068e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801068ed:	eb 11                	jmp    80106900 <uartputc+0x29>
    microdelay(10);
801068ef:	83 ec 0c             	sub    $0xc,%esp
801068f2:	6a 0a                	push   $0xa
801068f4:	e8 3e c2 ff ff       	call   80102b37 <microdelay>
801068f9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801068fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106900:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106904:	7f 1a                	jg     80106920 <uartputc+0x49>
80106906:	83 ec 0c             	sub    $0xc,%esp
80106909:	68 fd 03 00 00       	push   $0x3fd
8010690e:	e8 9f fe ff ff       	call   801067b2 <inb>
80106913:	83 c4 10             	add    $0x10,%esp
80106916:	0f b6 c0             	movzbl %al,%eax
80106919:	83 e0 20             	and    $0x20,%eax
8010691c:	85 c0                	test   %eax,%eax
8010691e:	74 cf                	je     801068ef <uartputc+0x18>
  outb(COM1+0, c);
80106920:	8b 45 08             	mov    0x8(%ebp),%eax
80106923:	0f b6 c0             	movzbl %al,%eax
80106926:	83 ec 08             	sub    $0x8,%esp
80106929:	50                   	push   %eax
8010692a:	68 f8 03 00 00       	push   $0x3f8
8010692f:	e8 9b fe ff ff       	call   801067cf <outb>
80106934:	83 c4 10             	add    $0x10,%esp
80106937:	eb 01                	jmp    8010693a <uartputc+0x63>
    return;
80106939:	90                   	nop
}
8010693a:	c9                   	leave  
8010693b:	c3                   	ret    

8010693c <uartgetc>:

static int
uartgetc(void)
{
8010693c:	55                   	push   %ebp
8010693d:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010693f:	a1 78 74 19 80       	mov    0x80197478,%eax
80106944:	85 c0                	test   %eax,%eax
80106946:	75 07                	jne    8010694f <uartgetc+0x13>
    return -1;
80106948:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010694d:	eb 2e                	jmp    8010697d <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010694f:	68 fd 03 00 00       	push   $0x3fd
80106954:	e8 59 fe ff ff       	call   801067b2 <inb>
80106959:	83 c4 04             	add    $0x4,%esp
8010695c:	0f b6 c0             	movzbl %al,%eax
8010695f:	83 e0 01             	and    $0x1,%eax
80106962:	85 c0                	test   %eax,%eax
80106964:	75 07                	jne    8010696d <uartgetc+0x31>
    return -1;
80106966:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010696b:	eb 10                	jmp    8010697d <uartgetc+0x41>
  return inb(COM1+0);
8010696d:	68 f8 03 00 00       	push   $0x3f8
80106972:	e8 3b fe ff ff       	call   801067b2 <inb>
80106977:	83 c4 04             	add    $0x4,%esp
8010697a:	0f b6 c0             	movzbl %al,%eax
}
8010697d:	c9                   	leave  
8010697e:	c3                   	ret    

8010697f <uartintr>:

void
uartintr(void)
{
8010697f:	55                   	push   %ebp
80106980:	89 e5                	mov    %esp,%ebp
80106982:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106985:	83 ec 0c             	sub    $0xc,%esp
80106988:	68 3c 69 10 80       	push   $0x8010693c
8010698d:	e8 44 9e ff ff       	call   801007d6 <consoleintr>
80106992:	83 c4 10             	add    $0x10,%esp
}
80106995:	90                   	nop
80106996:	c9                   	leave  
80106997:	c3                   	ret    

80106998 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106998:	6a 00                	push   $0x0
  pushl $0
8010699a:	6a 00                	push   $0x0
  jmp alltraps
8010699c:	e9 6f f9 ff ff       	jmp    80106310 <alltraps>

801069a1 <vector1>:
.globl vector1
vector1:
  pushl $0
801069a1:	6a 00                	push   $0x0
  pushl $1
801069a3:	6a 01                	push   $0x1
  jmp alltraps
801069a5:	e9 66 f9 ff ff       	jmp    80106310 <alltraps>

801069aa <vector2>:
.globl vector2
vector2:
  pushl $0
801069aa:	6a 00                	push   $0x0
  pushl $2
801069ac:	6a 02                	push   $0x2
  jmp alltraps
801069ae:	e9 5d f9 ff ff       	jmp    80106310 <alltraps>

801069b3 <vector3>:
.globl vector3
vector3:
  pushl $0
801069b3:	6a 00                	push   $0x0
  pushl $3
801069b5:	6a 03                	push   $0x3
  jmp alltraps
801069b7:	e9 54 f9 ff ff       	jmp    80106310 <alltraps>

801069bc <vector4>:
.globl vector4
vector4:
  pushl $0
801069bc:	6a 00                	push   $0x0
  pushl $4
801069be:	6a 04                	push   $0x4
  jmp alltraps
801069c0:	e9 4b f9 ff ff       	jmp    80106310 <alltraps>

801069c5 <vector5>:
.globl vector5
vector5:
  pushl $0
801069c5:	6a 00                	push   $0x0
  pushl $5
801069c7:	6a 05                	push   $0x5
  jmp alltraps
801069c9:	e9 42 f9 ff ff       	jmp    80106310 <alltraps>

801069ce <vector6>:
.globl vector6
vector6:
  pushl $0
801069ce:	6a 00                	push   $0x0
  pushl $6
801069d0:	6a 06                	push   $0x6
  jmp alltraps
801069d2:	e9 39 f9 ff ff       	jmp    80106310 <alltraps>

801069d7 <vector7>:
.globl vector7
vector7:
  pushl $0
801069d7:	6a 00                	push   $0x0
  pushl $7
801069d9:	6a 07                	push   $0x7
  jmp alltraps
801069db:	e9 30 f9 ff ff       	jmp    80106310 <alltraps>

801069e0 <vector8>:
.globl vector8
vector8:
  pushl $8
801069e0:	6a 08                	push   $0x8
  jmp alltraps
801069e2:	e9 29 f9 ff ff       	jmp    80106310 <alltraps>

801069e7 <vector9>:
.globl vector9
vector9:
  pushl $0
801069e7:	6a 00                	push   $0x0
  pushl $9
801069e9:	6a 09                	push   $0x9
  jmp alltraps
801069eb:	e9 20 f9 ff ff       	jmp    80106310 <alltraps>

801069f0 <vector10>:
.globl vector10
vector10:
  pushl $10
801069f0:	6a 0a                	push   $0xa
  jmp alltraps
801069f2:	e9 19 f9 ff ff       	jmp    80106310 <alltraps>

801069f7 <vector11>:
.globl vector11
vector11:
  pushl $11
801069f7:	6a 0b                	push   $0xb
  jmp alltraps
801069f9:	e9 12 f9 ff ff       	jmp    80106310 <alltraps>

801069fe <vector12>:
.globl vector12
vector12:
  pushl $12
801069fe:	6a 0c                	push   $0xc
  jmp alltraps
80106a00:	e9 0b f9 ff ff       	jmp    80106310 <alltraps>

80106a05 <vector13>:
.globl vector13
vector13:
  pushl $13
80106a05:	6a 0d                	push   $0xd
  jmp alltraps
80106a07:	e9 04 f9 ff ff       	jmp    80106310 <alltraps>

80106a0c <vector14>:
.globl vector14
vector14:
  pushl $14
80106a0c:	6a 0e                	push   $0xe
  jmp alltraps
80106a0e:	e9 fd f8 ff ff       	jmp    80106310 <alltraps>

80106a13 <vector15>:
.globl vector15
vector15:
  pushl $0
80106a13:	6a 00                	push   $0x0
  pushl $15
80106a15:	6a 0f                	push   $0xf
  jmp alltraps
80106a17:	e9 f4 f8 ff ff       	jmp    80106310 <alltraps>

80106a1c <vector16>:
.globl vector16
vector16:
  pushl $0
80106a1c:	6a 00                	push   $0x0
  pushl $16
80106a1e:	6a 10                	push   $0x10
  jmp alltraps
80106a20:	e9 eb f8 ff ff       	jmp    80106310 <alltraps>

80106a25 <vector17>:
.globl vector17
vector17:
  pushl $17
80106a25:	6a 11                	push   $0x11
  jmp alltraps
80106a27:	e9 e4 f8 ff ff       	jmp    80106310 <alltraps>

80106a2c <vector18>:
.globl vector18
vector18:
  pushl $0
80106a2c:	6a 00                	push   $0x0
  pushl $18
80106a2e:	6a 12                	push   $0x12
  jmp alltraps
80106a30:	e9 db f8 ff ff       	jmp    80106310 <alltraps>

80106a35 <vector19>:
.globl vector19
vector19:
  pushl $0
80106a35:	6a 00                	push   $0x0
  pushl $19
80106a37:	6a 13                	push   $0x13
  jmp alltraps
80106a39:	e9 d2 f8 ff ff       	jmp    80106310 <alltraps>

80106a3e <vector20>:
.globl vector20
vector20:
  pushl $0
80106a3e:	6a 00                	push   $0x0
  pushl $20
80106a40:	6a 14                	push   $0x14
  jmp alltraps
80106a42:	e9 c9 f8 ff ff       	jmp    80106310 <alltraps>

80106a47 <vector21>:
.globl vector21
vector21:
  pushl $0
80106a47:	6a 00                	push   $0x0
  pushl $21
80106a49:	6a 15                	push   $0x15
  jmp alltraps
80106a4b:	e9 c0 f8 ff ff       	jmp    80106310 <alltraps>

80106a50 <vector22>:
.globl vector22
vector22:
  pushl $0
80106a50:	6a 00                	push   $0x0
  pushl $22
80106a52:	6a 16                	push   $0x16
  jmp alltraps
80106a54:	e9 b7 f8 ff ff       	jmp    80106310 <alltraps>

80106a59 <vector23>:
.globl vector23
vector23:
  pushl $0
80106a59:	6a 00                	push   $0x0
  pushl $23
80106a5b:	6a 17                	push   $0x17
  jmp alltraps
80106a5d:	e9 ae f8 ff ff       	jmp    80106310 <alltraps>

80106a62 <vector24>:
.globl vector24
vector24:
  pushl $0
80106a62:	6a 00                	push   $0x0
  pushl $24
80106a64:	6a 18                	push   $0x18
  jmp alltraps
80106a66:	e9 a5 f8 ff ff       	jmp    80106310 <alltraps>

80106a6b <vector25>:
.globl vector25
vector25:
  pushl $0
80106a6b:	6a 00                	push   $0x0
  pushl $25
80106a6d:	6a 19                	push   $0x19
  jmp alltraps
80106a6f:	e9 9c f8 ff ff       	jmp    80106310 <alltraps>

80106a74 <vector26>:
.globl vector26
vector26:
  pushl $0
80106a74:	6a 00                	push   $0x0
  pushl $26
80106a76:	6a 1a                	push   $0x1a
  jmp alltraps
80106a78:	e9 93 f8 ff ff       	jmp    80106310 <alltraps>

80106a7d <vector27>:
.globl vector27
vector27:
  pushl $0
80106a7d:	6a 00                	push   $0x0
  pushl $27
80106a7f:	6a 1b                	push   $0x1b
  jmp alltraps
80106a81:	e9 8a f8 ff ff       	jmp    80106310 <alltraps>

80106a86 <vector28>:
.globl vector28
vector28:
  pushl $0
80106a86:	6a 00                	push   $0x0
  pushl $28
80106a88:	6a 1c                	push   $0x1c
  jmp alltraps
80106a8a:	e9 81 f8 ff ff       	jmp    80106310 <alltraps>

80106a8f <vector29>:
.globl vector29
vector29:
  pushl $0
80106a8f:	6a 00                	push   $0x0
  pushl $29
80106a91:	6a 1d                	push   $0x1d
  jmp alltraps
80106a93:	e9 78 f8 ff ff       	jmp    80106310 <alltraps>

80106a98 <vector30>:
.globl vector30
vector30:
  pushl $0
80106a98:	6a 00                	push   $0x0
  pushl $30
80106a9a:	6a 1e                	push   $0x1e
  jmp alltraps
80106a9c:	e9 6f f8 ff ff       	jmp    80106310 <alltraps>

80106aa1 <vector31>:
.globl vector31
vector31:
  pushl $0
80106aa1:	6a 00                	push   $0x0
  pushl $31
80106aa3:	6a 1f                	push   $0x1f
  jmp alltraps
80106aa5:	e9 66 f8 ff ff       	jmp    80106310 <alltraps>

80106aaa <vector32>:
.globl vector32
vector32:
  pushl $0
80106aaa:	6a 00                	push   $0x0
  pushl $32
80106aac:	6a 20                	push   $0x20
  jmp alltraps
80106aae:	e9 5d f8 ff ff       	jmp    80106310 <alltraps>

80106ab3 <vector33>:
.globl vector33
vector33:
  pushl $0
80106ab3:	6a 00                	push   $0x0
  pushl $33
80106ab5:	6a 21                	push   $0x21
  jmp alltraps
80106ab7:	e9 54 f8 ff ff       	jmp    80106310 <alltraps>

80106abc <vector34>:
.globl vector34
vector34:
  pushl $0
80106abc:	6a 00                	push   $0x0
  pushl $34
80106abe:	6a 22                	push   $0x22
  jmp alltraps
80106ac0:	e9 4b f8 ff ff       	jmp    80106310 <alltraps>

80106ac5 <vector35>:
.globl vector35
vector35:
  pushl $0
80106ac5:	6a 00                	push   $0x0
  pushl $35
80106ac7:	6a 23                	push   $0x23
  jmp alltraps
80106ac9:	e9 42 f8 ff ff       	jmp    80106310 <alltraps>

80106ace <vector36>:
.globl vector36
vector36:
  pushl $0
80106ace:	6a 00                	push   $0x0
  pushl $36
80106ad0:	6a 24                	push   $0x24
  jmp alltraps
80106ad2:	e9 39 f8 ff ff       	jmp    80106310 <alltraps>

80106ad7 <vector37>:
.globl vector37
vector37:
  pushl $0
80106ad7:	6a 00                	push   $0x0
  pushl $37
80106ad9:	6a 25                	push   $0x25
  jmp alltraps
80106adb:	e9 30 f8 ff ff       	jmp    80106310 <alltraps>

80106ae0 <vector38>:
.globl vector38
vector38:
  pushl $0
80106ae0:	6a 00                	push   $0x0
  pushl $38
80106ae2:	6a 26                	push   $0x26
  jmp alltraps
80106ae4:	e9 27 f8 ff ff       	jmp    80106310 <alltraps>

80106ae9 <vector39>:
.globl vector39
vector39:
  pushl $0
80106ae9:	6a 00                	push   $0x0
  pushl $39
80106aeb:	6a 27                	push   $0x27
  jmp alltraps
80106aed:	e9 1e f8 ff ff       	jmp    80106310 <alltraps>

80106af2 <vector40>:
.globl vector40
vector40:
  pushl $0
80106af2:	6a 00                	push   $0x0
  pushl $40
80106af4:	6a 28                	push   $0x28
  jmp alltraps
80106af6:	e9 15 f8 ff ff       	jmp    80106310 <alltraps>

80106afb <vector41>:
.globl vector41
vector41:
  pushl $0
80106afb:	6a 00                	push   $0x0
  pushl $41
80106afd:	6a 29                	push   $0x29
  jmp alltraps
80106aff:	e9 0c f8 ff ff       	jmp    80106310 <alltraps>

80106b04 <vector42>:
.globl vector42
vector42:
  pushl $0
80106b04:	6a 00                	push   $0x0
  pushl $42
80106b06:	6a 2a                	push   $0x2a
  jmp alltraps
80106b08:	e9 03 f8 ff ff       	jmp    80106310 <alltraps>

80106b0d <vector43>:
.globl vector43
vector43:
  pushl $0
80106b0d:	6a 00                	push   $0x0
  pushl $43
80106b0f:	6a 2b                	push   $0x2b
  jmp alltraps
80106b11:	e9 fa f7 ff ff       	jmp    80106310 <alltraps>

80106b16 <vector44>:
.globl vector44
vector44:
  pushl $0
80106b16:	6a 00                	push   $0x0
  pushl $44
80106b18:	6a 2c                	push   $0x2c
  jmp alltraps
80106b1a:	e9 f1 f7 ff ff       	jmp    80106310 <alltraps>

80106b1f <vector45>:
.globl vector45
vector45:
  pushl $0
80106b1f:	6a 00                	push   $0x0
  pushl $45
80106b21:	6a 2d                	push   $0x2d
  jmp alltraps
80106b23:	e9 e8 f7 ff ff       	jmp    80106310 <alltraps>

80106b28 <vector46>:
.globl vector46
vector46:
  pushl $0
80106b28:	6a 00                	push   $0x0
  pushl $46
80106b2a:	6a 2e                	push   $0x2e
  jmp alltraps
80106b2c:	e9 df f7 ff ff       	jmp    80106310 <alltraps>

80106b31 <vector47>:
.globl vector47
vector47:
  pushl $0
80106b31:	6a 00                	push   $0x0
  pushl $47
80106b33:	6a 2f                	push   $0x2f
  jmp alltraps
80106b35:	e9 d6 f7 ff ff       	jmp    80106310 <alltraps>

80106b3a <vector48>:
.globl vector48
vector48:
  pushl $0
80106b3a:	6a 00                	push   $0x0
  pushl $48
80106b3c:	6a 30                	push   $0x30
  jmp alltraps
80106b3e:	e9 cd f7 ff ff       	jmp    80106310 <alltraps>

80106b43 <vector49>:
.globl vector49
vector49:
  pushl $0
80106b43:	6a 00                	push   $0x0
  pushl $49
80106b45:	6a 31                	push   $0x31
  jmp alltraps
80106b47:	e9 c4 f7 ff ff       	jmp    80106310 <alltraps>

80106b4c <vector50>:
.globl vector50
vector50:
  pushl $0
80106b4c:	6a 00                	push   $0x0
  pushl $50
80106b4e:	6a 32                	push   $0x32
  jmp alltraps
80106b50:	e9 bb f7 ff ff       	jmp    80106310 <alltraps>

80106b55 <vector51>:
.globl vector51
vector51:
  pushl $0
80106b55:	6a 00                	push   $0x0
  pushl $51
80106b57:	6a 33                	push   $0x33
  jmp alltraps
80106b59:	e9 b2 f7 ff ff       	jmp    80106310 <alltraps>

80106b5e <vector52>:
.globl vector52
vector52:
  pushl $0
80106b5e:	6a 00                	push   $0x0
  pushl $52
80106b60:	6a 34                	push   $0x34
  jmp alltraps
80106b62:	e9 a9 f7 ff ff       	jmp    80106310 <alltraps>

80106b67 <vector53>:
.globl vector53
vector53:
  pushl $0
80106b67:	6a 00                	push   $0x0
  pushl $53
80106b69:	6a 35                	push   $0x35
  jmp alltraps
80106b6b:	e9 a0 f7 ff ff       	jmp    80106310 <alltraps>

80106b70 <vector54>:
.globl vector54
vector54:
  pushl $0
80106b70:	6a 00                	push   $0x0
  pushl $54
80106b72:	6a 36                	push   $0x36
  jmp alltraps
80106b74:	e9 97 f7 ff ff       	jmp    80106310 <alltraps>

80106b79 <vector55>:
.globl vector55
vector55:
  pushl $0
80106b79:	6a 00                	push   $0x0
  pushl $55
80106b7b:	6a 37                	push   $0x37
  jmp alltraps
80106b7d:	e9 8e f7 ff ff       	jmp    80106310 <alltraps>

80106b82 <vector56>:
.globl vector56
vector56:
  pushl $0
80106b82:	6a 00                	push   $0x0
  pushl $56
80106b84:	6a 38                	push   $0x38
  jmp alltraps
80106b86:	e9 85 f7 ff ff       	jmp    80106310 <alltraps>

80106b8b <vector57>:
.globl vector57
vector57:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $57
80106b8d:	6a 39                	push   $0x39
  jmp alltraps
80106b8f:	e9 7c f7 ff ff       	jmp    80106310 <alltraps>

80106b94 <vector58>:
.globl vector58
vector58:
  pushl $0
80106b94:	6a 00                	push   $0x0
  pushl $58
80106b96:	6a 3a                	push   $0x3a
  jmp alltraps
80106b98:	e9 73 f7 ff ff       	jmp    80106310 <alltraps>

80106b9d <vector59>:
.globl vector59
vector59:
  pushl $0
80106b9d:	6a 00                	push   $0x0
  pushl $59
80106b9f:	6a 3b                	push   $0x3b
  jmp alltraps
80106ba1:	e9 6a f7 ff ff       	jmp    80106310 <alltraps>

80106ba6 <vector60>:
.globl vector60
vector60:
  pushl $0
80106ba6:	6a 00                	push   $0x0
  pushl $60
80106ba8:	6a 3c                	push   $0x3c
  jmp alltraps
80106baa:	e9 61 f7 ff ff       	jmp    80106310 <alltraps>

80106baf <vector61>:
.globl vector61
vector61:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $61
80106bb1:	6a 3d                	push   $0x3d
  jmp alltraps
80106bb3:	e9 58 f7 ff ff       	jmp    80106310 <alltraps>

80106bb8 <vector62>:
.globl vector62
vector62:
  pushl $0
80106bb8:	6a 00                	push   $0x0
  pushl $62
80106bba:	6a 3e                	push   $0x3e
  jmp alltraps
80106bbc:	e9 4f f7 ff ff       	jmp    80106310 <alltraps>

80106bc1 <vector63>:
.globl vector63
vector63:
  pushl $0
80106bc1:	6a 00                	push   $0x0
  pushl $63
80106bc3:	6a 3f                	push   $0x3f
  jmp alltraps
80106bc5:	e9 46 f7 ff ff       	jmp    80106310 <alltraps>

80106bca <vector64>:
.globl vector64
vector64:
  pushl $0
80106bca:	6a 00                	push   $0x0
  pushl $64
80106bcc:	6a 40                	push   $0x40
  jmp alltraps
80106bce:	e9 3d f7 ff ff       	jmp    80106310 <alltraps>

80106bd3 <vector65>:
.globl vector65
vector65:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $65
80106bd5:	6a 41                	push   $0x41
  jmp alltraps
80106bd7:	e9 34 f7 ff ff       	jmp    80106310 <alltraps>

80106bdc <vector66>:
.globl vector66
vector66:
  pushl $0
80106bdc:	6a 00                	push   $0x0
  pushl $66
80106bde:	6a 42                	push   $0x42
  jmp alltraps
80106be0:	e9 2b f7 ff ff       	jmp    80106310 <alltraps>

80106be5 <vector67>:
.globl vector67
vector67:
  pushl $0
80106be5:	6a 00                	push   $0x0
  pushl $67
80106be7:	6a 43                	push   $0x43
  jmp alltraps
80106be9:	e9 22 f7 ff ff       	jmp    80106310 <alltraps>

80106bee <vector68>:
.globl vector68
vector68:
  pushl $0
80106bee:	6a 00                	push   $0x0
  pushl $68
80106bf0:	6a 44                	push   $0x44
  jmp alltraps
80106bf2:	e9 19 f7 ff ff       	jmp    80106310 <alltraps>

80106bf7 <vector69>:
.globl vector69
vector69:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $69
80106bf9:	6a 45                	push   $0x45
  jmp alltraps
80106bfb:	e9 10 f7 ff ff       	jmp    80106310 <alltraps>

80106c00 <vector70>:
.globl vector70
vector70:
  pushl $0
80106c00:	6a 00                	push   $0x0
  pushl $70
80106c02:	6a 46                	push   $0x46
  jmp alltraps
80106c04:	e9 07 f7 ff ff       	jmp    80106310 <alltraps>

80106c09 <vector71>:
.globl vector71
vector71:
  pushl $0
80106c09:	6a 00                	push   $0x0
  pushl $71
80106c0b:	6a 47                	push   $0x47
  jmp alltraps
80106c0d:	e9 fe f6 ff ff       	jmp    80106310 <alltraps>

80106c12 <vector72>:
.globl vector72
vector72:
  pushl $0
80106c12:	6a 00                	push   $0x0
  pushl $72
80106c14:	6a 48                	push   $0x48
  jmp alltraps
80106c16:	e9 f5 f6 ff ff       	jmp    80106310 <alltraps>

80106c1b <vector73>:
.globl vector73
vector73:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $73
80106c1d:	6a 49                	push   $0x49
  jmp alltraps
80106c1f:	e9 ec f6 ff ff       	jmp    80106310 <alltraps>

80106c24 <vector74>:
.globl vector74
vector74:
  pushl $0
80106c24:	6a 00                	push   $0x0
  pushl $74
80106c26:	6a 4a                	push   $0x4a
  jmp alltraps
80106c28:	e9 e3 f6 ff ff       	jmp    80106310 <alltraps>

80106c2d <vector75>:
.globl vector75
vector75:
  pushl $0
80106c2d:	6a 00                	push   $0x0
  pushl $75
80106c2f:	6a 4b                	push   $0x4b
  jmp alltraps
80106c31:	e9 da f6 ff ff       	jmp    80106310 <alltraps>

80106c36 <vector76>:
.globl vector76
vector76:
  pushl $0
80106c36:	6a 00                	push   $0x0
  pushl $76
80106c38:	6a 4c                	push   $0x4c
  jmp alltraps
80106c3a:	e9 d1 f6 ff ff       	jmp    80106310 <alltraps>

80106c3f <vector77>:
.globl vector77
vector77:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $77
80106c41:	6a 4d                	push   $0x4d
  jmp alltraps
80106c43:	e9 c8 f6 ff ff       	jmp    80106310 <alltraps>

80106c48 <vector78>:
.globl vector78
vector78:
  pushl $0
80106c48:	6a 00                	push   $0x0
  pushl $78
80106c4a:	6a 4e                	push   $0x4e
  jmp alltraps
80106c4c:	e9 bf f6 ff ff       	jmp    80106310 <alltraps>

80106c51 <vector79>:
.globl vector79
vector79:
  pushl $0
80106c51:	6a 00                	push   $0x0
  pushl $79
80106c53:	6a 4f                	push   $0x4f
  jmp alltraps
80106c55:	e9 b6 f6 ff ff       	jmp    80106310 <alltraps>

80106c5a <vector80>:
.globl vector80
vector80:
  pushl $0
80106c5a:	6a 00                	push   $0x0
  pushl $80
80106c5c:	6a 50                	push   $0x50
  jmp alltraps
80106c5e:	e9 ad f6 ff ff       	jmp    80106310 <alltraps>

80106c63 <vector81>:
.globl vector81
vector81:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $81
80106c65:	6a 51                	push   $0x51
  jmp alltraps
80106c67:	e9 a4 f6 ff ff       	jmp    80106310 <alltraps>

80106c6c <vector82>:
.globl vector82
vector82:
  pushl $0
80106c6c:	6a 00                	push   $0x0
  pushl $82
80106c6e:	6a 52                	push   $0x52
  jmp alltraps
80106c70:	e9 9b f6 ff ff       	jmp    80106310 <alltraps>

80106c75 <vector83>:
.globl vector83
vector83:
  pushl $0
80106c75:	6a 00                	push   $0x0
  pushl $83
80106c77:	6a 53                	push   $0x53
  jmp alltraps
80106c79:	e9 92 f6 ff ff       	jmp    80106310 <alltraps>

80106c7e <vector84>:
.globl vector84
vector84:
  pushl $0
80106c7e:	6a 00                	push   $0x0
  pushl $84
80106c80:	6a 54                	push   $0x54
  jmp alltraps
80106c82:	e9 89 f6 ff ff       	jmp    80106310 <alltraps>

80106c87 <vector85>:
.globl vector85
vector85:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $85
80106c89:	6a 55                	push   $0x55
  jmp alltraps
80106c8b:	e9 80 f6 ff ff       	jmp    80106310 <alltraps>

80106c90 <vector86>:
.globl vector86
vector86:
  pushl $0
80106c90:	6a 00                	push   $0x0
  pushl $86
80106c92:	6a 56                	push   $0x56
  jmp alltraps
80106c94:	e9 77 f6 ff ff       	jmp    80106310 <alltraps>

80106c99 <vector87>:
.globl vector87
vector87:
  pushl $0
80106c99:	6a 00                	push   $0x0
  pushl $87
80106c9b:	6a 57                	push   $0x57
  jmp alltraps
80106c9d:	e9 6e f6 ff ff       	jmp    80106310 <alltraps>

80106ca2 <vector88>:
.globl vector88
vector88:
  pushl $0
80106ca2:	6a 00                	push   $0x0
  pushl $88
80106ca4:	6a 58                	push   $0x58
  jmp alltraps
80106ca6:	e9 65 f6 ff ff       	jmp    80106310 <alltraps>

80106cab <vector89>:
.globl vector89
vector89:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $89
80106cad:	6a 59                	push   $0x59
  jmp alltraps
80106caf:	e9 5c f6 ff ff       	jmp    80106310 <alltraps>

80106cb4 <vector90>:
.globl vector90
vector90:
  pushl $0
80106cb4:	6a 00                	push   $0x0
  pushl $90
80106cb6:	6a 5a                	push   $0x5a
  jmp alltraps
80106cb8:	e9 53 f6 ff ff       	jmp    80106310 <alltraps>

80106cbd <vector91>:
.globl vector91
vector91:
  pushl $0
80106cbd:	6a 00                	push   $0x0
  pushl $91
80106cbf:	6a 5b                	push   $0x5b
  jmp alltraps
80106cc1:	e9 4a f6 ff ff       	jmp    80106310 <alltraps>

80106cc6 <vector92>:
.globl vector92
vector92:
  pushl $0
80106cc6:	6a 00                	push   $0x0
  pushl $92
80106cc8:	6a 5c                	push   $0x5c
  jmp alltraps
80106cca:	e9 41 f6 ff ff       	jmp    80106310 <alltraps>

80106ccf <vector93>:
.globl vector93
vector93:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $93
80106cd1:	6a 5d                	push   $0x5d
  jmp alltraps
80106cd3:	e9 38 f6 ff ff       	jmp    80106310 <alltraps>

80106cd8 <vector94>:
.globl vector94
vector94:
  pushl $0
80106cd8:	6a 00                	push   $0x0
  pushl $94
80106cda:	6a 5e                	push   $0x5e
  jmp alltraps
80106cdc:	e9 2f f6 ff ff       	jmp    80106310 <alltraps>

80106ce1 <vector95>:
.globl vector95
vector95:
  pushl $0
80106ce1:	6a 00                	push   $0x0
  pushl $95
80106ce3:	6a 5f                	push   $0x5f
  jmp alltraps
80106ce5:	e9 26 f6 ff ff       	jmp    80106310 <alltraps>

80106cea <vector96>:
.globl vector96
vector96:
  pushl $0
80106cea:	6a 00                	push   $0x0
  pushl $96
80106cec:	6a 60                	push   $0x60
  jmp alltraps
80106cee:	e9 1d f6 ff ff       	jmp    80106310 <alltraps>

80106cf3 <vector97>:
.globl vector97
vector97:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $97
80106cf5:	6a 61                	push   $0x61
  jmp alltraps
80106cf7:	e9 14 f6 ff ff       	jmp    80106310 <alltraps>

80106cfc <vector98>:
.globl vector98
vector98:
  pushl $0
80106cfc:	6a 00                	push   $0x0
  pushl $98
80106cfe:	6a 62                	push   $0x62
  jmp alltraps
80106d00:	e9 0b f6 ff ff       	jmp    80106310 <alltraps>

80106d05 <vector99>:
.globl vector99
vector99:
  pushl $0
80106d05:	6a 00                	push   $0x0
  pushl $99
80106d07:	6a 63                	push   $0x63
  jmp alltraps
80106d09:	e9 02 f6 ff ff       	jmp    80106310 <alltraps>

80106d0e <vector100>:
.globl vector100
vector100:
  pushl $0
80106d0e:	6a 00                	push   $0x0
  pushl $100
80106d10:	6a 64                	push   $0x64
  jmp alltraps
80106d12:	e9 f9 f5 ff ff       	jmp    80106310 <alltraps>

80106d17 <vector101>:
.globl vector101
vector101:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $101
80106d19:	6a 65                	push   $0x65
  jmp alltraps
80106d1b:	e9 f0 f5 ff ff       	jmp    80106310 <alltraps>

80106d20 <vector102>:
.globl vector102
vector102:
  pushl $0
80106d20:	6a 00                	push   $0x0
  pushl $102
80106d22:	6a 66                	push   $0x66
  jmp alltraps
80106d24:	e9 e7 f5 ff ff       	jmp    80106310 <alltraps>

80106d29 <vector103>:
.globl vector103
vector103:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $103
80106d2b:	6a 67                	push   $0x67
  jmp alltraps
80106d2d:	e9 de f5 ff ff       	jmp    80106310 <alltraps>

80106d32 <vector104>:
.globl vector104
vector104:
  pushl $0
80106d32:	6a 00                	push   $0x0
  pushl $104
80106d34:	6a 68                	push   $0x68
  jmp alltraps
80106d36:	e9 d5 f5 ff ff       	jmp    80106310 <alltraps>

80106d3b <vector105>:
.globl vector105
vector105:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $105
80106d3d:	6a 69                	push   $0x69
  jmp alltraps
80106d3f:	e9 cc f5 ff ff       	jmp    80106310 <alltraps>

80106d44 <vector106>:
.globl vector106
vector106:
  pushl $0
80106d44:	6a 00                	push   $0x0
  pushl $106
80106d46:	6a 6a                	push   $0x6a
  jmp alltraps
80106d48:	e9 c3 f5 ff ff       	jmp    80106310 <alltraps>

80106d4d <vector107>:
.globl vector107
vector107:
  pushl $0
80106d4d:	6a 00                	push   $0x0
  pushl $107
80106d4f:	6a 6b                	push   $0x6b
  jmp alltraps
80106d51:	e9 ba f5 ff ff       	jmp    80106310 <alltraps>

80106d56 <vector108>:
.globl vector108
vector108:
  pushl $0
80106d56:	6a 00                	push   $0x0
  pushl $108
80106d58:	6a 6c                	push   $0x6c
  jmp alltraps
80106d5a:	e9 b1 f5 ff ff       	jmp    80106310 <alltraps>

80106d5f <vector109>:
.globl vector109
vector109:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $109
80106d61:	6a 6d                	push   $0x6d
  jmp alltraps
80106d63:	e9 a8 f5 ff ff       	jmp    80106310 <alltraps>

80106d68 <vector110>:
.globl vector110
vector110:
  pushl $0
80106d68:	6a 00                	push   $0x0
  pushl $110
80106d6a:	6a 6e                	push   $0x6e
  jmp alltraps
80106d6c:	e9 9f f5 ff ff       	jmp    80106310 <alltraps>

80106d71 <vector111>:
.globl vector111
vector111:
  pushl $0
80106d71:	6a 00                	push   $0x0
  pushl $111
80106d73:	6a 6f                	push   $0x6f
  jmp alltraps
80106d75:	e9 96 f5 ff ff       	jmp    80106310 <alltraps>

80106d7a <vector112>:
.globl vector112
vector112:
  pushl $0
80106d7a:	6a 00                	push   $0x0
  pushl $112
80106d7c:	6a 70                	push   $0x70
  jmp alltraps
80106d7e:	e9 8d f5 ff ff       	jmp    80106310 <alltraps>

80106d83 <vector113>:
.globl vector113
vector113:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $113
80106d85:	6a 71                	push   $0x71
  jmp alltraps
80106d87:	e9 84 f5 ff ff       	jmp    80106310 <alltraps>

80106d8c <vector114>:
.globl vector114
vector114:
  pushl $0
80106d8c:	6a 00                	push   $0x0
  pushl $114
80106d8e:	6a 72                	push   $0x72
  jmp alltraps
80106d90:	e9 7b f5 ff ff       	jmp    80106310 <alltraps>

80106d95 <vector115>:
.globl vector115
vector115:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $115
80106d97:	6a 73                	push   $0x73
  jmp alltraps
80106d99:	e9 72 f5 ff ff       	jmp    80106310 <alltraps>

80106d9e <vector116>:
.globl vector116
vector116:
  pushl $0
80106d9e:	6a 00                	push   $0x0
  pushl $116
80106da0:	6a 74                	push   $0x74
  jmp alltraps
80106da2:	e9 69 f5 ff ff       	jmp    80106310 <alltraps>

80106da7 <vector117>:
.globl vector117
vector117:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $117
80106da9:	6a 75                	push   $0x75
  jmp alltraps
80106dab:	e9 60 f5 ff ff       	jmp    80106310 <alltraps>

80106db0 <vector118>:
.globl vector118
vector118:
  pushl $0
80106db0:	6a 00                	push   $0x0
  pushl $118
80106db2:	6a 76                	push   $0x76
  jmp alltraps
80106db4:	e9 57 f5 ff ff       	jmp    80106310 <alltraps>

80106db9 <vector119>:
.globl vector119
vector119:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $119
80106dbb:	6a 77                	push   $0x77
  jmp alltraps
80106dbd:	e9 4e f5 ff ff       	jmp    80106310 <alltraps>

80106dc2 <vector120>:
.globl vector120
vector120:
  pushl $0
80106dc2:	6a 00                	push   $0x0
  pushl $120
80106dc4:	6a 78                	push   $0x78
  jmp alltraps
80106dc6:	e9 45 f5 ff ff       	jmp    80106310 <alltraps>

80106dcb <vector121>:
.globl vector121
vector121:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $121
80106dcd:	6a 79                	push   $0x79
  jmp alltraps
80106dcf:	e9 3c f5 ff ff       	jmp    80106310 <alltraps>

80106dd4 <vector122>:
.globl vector122
vector122:
  pushl $0
80106dd4:	6a 00                	push   $0x0
  pushl $122
80106dd6:	6a 7a                	push   $0x7a
  jmp alltraps
80106dd8:	e9 33 f5 ff ff       	jmp    80106310 <alltraps>

80106ddd <vector123>:
.globl vector123
vector123:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $123
80106ddf:	6a 7b                	push   $0x7b
  jmp alltraps
80106de1:	e9 2a f5 ff ff       	jmp    80106310 <alltraps>

80106de6 <vector124>:
.globl vector124
vector124:
  pushl $0
80106de6:	6a 00                	push   $0x0
  pushl $124
80106de8:	6a 7c                	push   $0x7c
  jmp alltraps
80106dea:	e9 21 f5 ff ff       	jmp    80106310 <alltraps>

80106def <vector125>:
.globl vector125
vector125:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $125
80106df1:	6a 7d                	push   $0x7d
  jmp alltraps
80106df3:	e9 18 f5 ff ff       	jmp    80106310 <alltraps>

80106df8 <vector126>:
.globl vector126
vector126:
  pushl $0
80106df8:	6a 00                	push   $0x0
  pushl $126
80106dfa:	6a 7e                	push   $0x7e
  jmp alltraps
80106dfc:	e9 0f f5 ff ff       	jmp    80106310 <alltraps>

80106e01 <vector127>:
.globl vector127
vector127:
  pushl $0
80106e01:	6a 00                	push   $0x0
  pushl $127
80106e03:	6a 7f                	push   $0x7f
  jmp alltraps
80106e05:	e9 06 f5 ff ff       	jmp    80106310 <alltraps>

80106e0a <vector128>:
.globl vector128
vector128:
  pushl $0
80106e0a:	6a 00                	push   $0x0
  pushl $128
80106e0c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106e11:	e9 fa f4 ff ff       	jmp    80106310 <alltraps>

80106e16 <vector129>:
.globl vector129
vector129:
  pushl $0
80106e16:	6a 00                	push   $0x0
  pushl $129
80106e18:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106e1d:	e9 ee f4 ff ff       	jmp    80106310 <alltraps>

80106e22 <vector130>:
.globl vector130
vector130:
  pushl $0
80106e22:	6a 00                	push   $0x0
  pushl $130
80106e24:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106e29:	e9 e2 f4 ff ff       	jmp    80106310 <alltraps>

80106e2e <vector131>:
.globl vector131
vector131:
  pushl $0
80106e2e:	6a 00                	push   $0x0
  pushl $131
80106e30:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106e35:	e9 d6 f4 ff ff       	jmp    80106310 <alltraps>

80106e3a <vector132>:
.globl vector132
vector132:
  pushl $0
80106e3a:	6a 00                	push   $0x0
  pushl $132
80106e3c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106e41:	e9 ca f4 ff ff       	jmp    80106310 <alltraps>

80106e46 <vector133>:
.globl vector133
vector133:
  pushl $0
80106e46:	6a 00                	push   $0x0
  pushl $133
80106e48:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106e4d:	e9 be f4 ff ff       	jmp    80106310 <alltraps>

80106e52 <vector134>:
.globl vector134
vector134:
  pushl $0
80106e52:	6a 00                	push   $0x0
  pushl $134
80106e54:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106e59:	e9 b2 f4 ff ff       	jmp    80106310 <alltraps>

80106e5e <vector135>:
.globl vector135
vector135:
  pushl $0
80106e5e:	6a 00                	push   $0x0
  pushl $135
80106e60:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106e65:	e9 a6 f4 ff ff       	jmp    80106310 <alltraps>

80106e6a <vector136>:
.globl vector136
vector136:
  pushl $0
80106e6a:	6a 00                	push   $0x0
  pushl $136
80106e6c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106e71:	e9 9a f4 ff ff       	jmp    80106310 <alltraps>

80106e76 <vector137>:
.globl vector137
vector137:
  pushl $0
80106e76:	6a 00                	push   $0x0
  pushl $137
80106e78:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106e7d:	e9 8e f4 ff ff       	jmp    80106310 <alltraps>

80106e82 <vector138>:
.globl vector138
vector138:
  pushl $0
80106e82:	6a 00                	push   $0x0
  pushl $138
80106e84:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106e89:	e9 82 f4 ff ff       	jmp    80106310 <alltraps>

80106e8e <vector139>:
.globl vector139
vector139:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $139
80106e90:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106e95:	e9 76 f4 ff ff       	jmp    80106310 <alltraps>

80106e9a <vector140>:
.globl vector140
vector140:
  pushl $0
80106e9a:	6a 00                	push   $0x0
  pushl $140
80106e9c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106ea1:	e9 6a f4 ff ff       	jmp    80106310 <alltraps>

80106ea6 <vector141>:
.globl vector141
vector141:
  pushl $0
80106ea6:	6a 00                	push   $0x0
  pushl $141
80106ea8:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106ead:	e9 5e f4 ff ff       	jmp    80106310 <alltraps>

80106eb2 <vector142>:
.globl vector142
vector142:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $142
80106eb4:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106eb9:	e9 52 f4 ff ff       	jmp    80106310 <alltraps>

80106ebe <vector143>:
.globl vector143
vector143:
  pushl $0
80106ebe:	6a 00                	push   $0x0
  pushl $143
80106ec0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106ec5:	e9 46 f4 ff ff       	jmp    80106310 <alltraps>

80106eca <vector144>:
.globl vector144
vector144:
  pushl $0
80106eca:	6a 00                	push   $0x0
  pushl $144
80106ecc:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106ed1:	e9 3a f4 ff ff       	jmp    80106310 <alltraps>

80106ed6 <vector145>:
.globl vector145
vector145:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $145
80106ed8:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106edd:	e9 2e f4 ff ff       	jmp    80106310 <alltraps>

80106ee2 <vector146>:
.globl vector146
vector146:
  pushl $0
80106ee2:	6a 00                	push   $0x0
  pushl $146
80106ee4:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106ee9:	e9 22 f4 ff ff       	jmp    80106310 <alltraps>

80106eee <vector147>:
.globl vector147
vector147:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $147
80106ef0:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106ef5:	e9 16 f4 ff ff       	jmp    80106310 <alltraps>

80106efa <vector148>:
.globl vector148
vector148:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $148
80106efc:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106f01:	e9 0a f4 ff ff       	jmp    80106310 <alltraps>

80106f06 <vector149>:
.globl vector149
vector149:
  pushl $0
80106f06:	6a 00                	push   $0x0
  pushl $149
80106f08:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106f0d:	e9 fe f3 ff ff       	jmp    80106310 <alltraps>

80106f12 <vector150>:
.globl vector150
vector150:
  pushl $0
80106f12:	6a 00                	push   $0x0
  pushl $150
80106f14:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106f19:	e9 f2 f3 ff ff       	jmp    80106310 <alltraps>

80106f1e <vector151>:
.globl vector151
vector151:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $151
80106f20:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106f25:	e9 e6 f3 ff ff       	jmp    80106310 <alltraps>

80106f2a <vector152>:
.globl vector152
vector152:
  pushl $0
80106f2a:	6a 00                	push   $0x0
  pushl $152
80106f2c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106f31:	e9 da f3 ff ff       	jmp    80106310 <alltraps>

80106f36 <vector153>:
.globl vector153
vector153:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $153
80106f38:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106f3d:	e9 ce f3 ff ff       	jmp    80106310 <alltraps>

80106f42 <vector154>:
.globl vector154
vector154:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $154
80106f44:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106f49:	e9 c2 f3 ff ff       	jmp    80106310 <alltraps>

80106f4e <vector155>:
.globl vector155
vector155:
  pushl $0
80106f4e:	6a 00                	push   $0x0
  pushl $155
80106f50:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106f55:	e9 b6 f3 ff ff       	jmp    80106310 <alltraps>

80106f5a <vector156>:
.globl vector156
vector156:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $156
80106f5c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106f61:	e9 aa f3 ff ff       	jmp    80106310 <alltraps>

80106f66 <vector157>:
.globl vector157
vector157:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $157
80106f68:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106f6d:	e9 9e f3 ff ff       	jmp    80106310 <alltraps>

80106f72 <vector158>:
.globl vector158
vector158:
  pushl $0
80106f72:	6a 00                	push   $0x0
  pushl $158
80106f74:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106f79:	e9 92 f3 ff ff       	jmp    80106310 <alltraps>

80106f7e <vector159>:
.globl vector159
vector159:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $159
80106f80:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106f85:	e9 86 f3 ff ff       	jmp    80106310 <alltraps>

80106f8a <vector160>:
.globl vector160
vector160:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $160
80106f8c:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106f91:	e9 7a f3 ff ff       	jmp    80106310 <alltraps>

80106f96 <vector161>:
.globl vector161
vector161:
  pushl $0
80106f96:	6a 00                	push   $0x0
  pushl $161
80106f98:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106f9d:	e9 6e f3 ff ff       	jmp    80106310 <alltraps>

80106fa2 <vector162>:
.globl vector162
vector162:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $162
80106fa4:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106fa9:	e9 62 f3 ff ff       	jmp    80106310 <alltraps>

80106fae <vector163>:
.globl vector163
vector163:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $163
80106fb0:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106fb5:	e9 56 f3 ff ff       	jmp    80106310 <alltraps>

80106fba <vector164>:
.globl vector164
vector164:
  pushl $0
80106fba:	6a 00                	push   $0x0
  pushl $164
80106fbc:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106fc1:	e9 4a f3 ff ff       	jmp    80106310 <alltraps>

80106fc6 <vector165>:
.globl vector165
vector165:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $165
80106fc8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106fcd:	e9 3e f3 ff ff       	jmp    80106310 <alltraps>

80106fd2 <vector166>:
.globl vector166
vector166:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $166
80106fd4:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106fd9:	e9 32 f3 ff ff       	jmp    80106310 <alltraps>

80106fde <vector167>:
.globl vector167
vector167:
  pushl $0
80106fde:	6a 00                	push   $0x0
  pushl $167
80106fe0:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106fe5:	e9 26 f3 ff ff       	jmp    80106310 <alltraps>

80106fea <vector168>:
.globl vector168
vector168:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $168
80106fec:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106ff1:	e9 1a f3 ff ff       	jmp    80106310 <alltraps>

80106ff6 <vector169>:
.globl vector169
vector169:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $169
80106ff8:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106ffd:	e9 0e f3 ff ff       	jmp    80106310 <alltraps>

80107002 <vector170>:
.globl vector170
vector170:
  pushl $0
80107002:	6a 00                	push   $0x0
  pushl $170
80107004:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107009:	e9 02 f3 ff ff       	jmp    80106310 <alltraps>

8010700e <vector171>:
.globl vector171
vector171:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $171
80107010:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107015:	e9 f6 f2 ff ff       	jmp    80106310 <alltraps>

8010701a <vector172>:
.globl vector172
vector172:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $172
8010701c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107021:	e9 ea f2 ff ff       	jmp    80106310 <alltraps>

80107026 <vector173>:
.globl vector173
vector173:
  pushl $0
80107026:	6a 00                	push   $0x0
  pushl $173
80107028:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010702d:	e9 de f2 ff ff       	jmp    80106310 <alltraps>

80107032 <vector174>:
.globl vector174
vector174:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $174
80107034:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107039:	e9 d2 f2 ff ff       	jmp    80106310 <alltraps>

8010703e <vector175>:
.globl vector175
vector175:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $175
80107040:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107045:	e9 c6 f2 ff ff       	jmp    80106310 <alltraps>

8010704a <vector176>:
.globl vector176
vector176:
  pushl $0
8010704a:	6a 00                	push   $0x0
  pushl $176
8010704c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107051:	e9 ba f2 ff ff       	jmp    80106310 <alltraps>

80107056 <vector177>:
.globl vector177
vector177:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $177
80107058:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010705d:	e9 ae f2 ff ff       	jmp    80106310 <alltraps>

80107062 <vector178>:
.globl vector178
vector178:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $178
80107064:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107069:	e9 a2 f2 ff ff       	jmp    80106310 <alltraps>

8010706e <vector179>:
.globl vector179
vector179:
  pushl $0
8010706e:	6a 00                	push   $0x0
  pushl $179
80107070:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107075:	e9 96 f2 ff ff       	jmp    80106310 <alltraps>

8010707a <vector180>:
.globl vector180
vector180:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $180
8010707c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107081:	e9 8a f2 ff ff       	jmp    80106310 <alltraps>

80107086 <vector181>:
.globl vector181
vector181:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $181
80107088:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010708d:	e9 7e f2 ff ff       	jmp    80106310 <alltraps>

80107092 <vector182>:
.globl vector182
vector182:
  pushl $0
80107092:	6a 00                	push   $0x0
  pushl $182
80107094:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107099:	e9 72 f2 ff ff       	jmp    80106310 <alltraps>

8010709e <vector183>:
.globl vector183
vector183:
  pushl $0
8010709e:	6a 00                	push   $0x0
  pushl $183
801070a0:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801070a5:	e9 66 f2 ff ff       	jmp    80106310 <alltraps>

801070aa <vector184>:
.globl vector184
vector184:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $184
801070ac:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801070b1:	e9 5a f2 ff ff       	jmp    80106310 <alltraps>

801070b6 <vector185>:
.globl vector185
vector185:
  pushl $0
801070b6:	6a 00                	push   $0x0
  pushl $185
801070b8:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801070bd:	e9 4e f2 ff ff       	jmp    80106310 <alltraps>

801070c2 <vector186>:
.globl vector186
vector186:
  pushl $0
801070c2:	6a 00                	push   $0x0
  pushl $186
801070c4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801070c9:	e9 42 f2 ff ff       	jmp    80106310 <alltraps>

801070ce <vector187>:
.globl vector187
vector187:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $187
801070d0:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801070d5:	e9 36 f2 ff ff       	jmp    80106310 <alltraps>

801070da <vector188>:
.globl vector188
vector188:
  pushl $0
801070da:	6a 00                	push   $0x0
  pushl $188
801070dc:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801070e1:	e9 2a f2 ff ff       	jmp    80106310 <alltraps>

801070e6 <vector189>:
.globl vector189
vector189:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $189
801070e8:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801070ed:	e9 1e f2 ff ff       	jmp    80106310 <alltraps>

801070f2 <vector190>:
.globl vector190
vector190:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $190
801070f4:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801070f9:	e9 12 f2 ff ff       	jmp    80106310 <alltraps>

801070fe <vector191>:
.globl vector191
vector191:
  pushl $0
801070fe:	6a 00                	push   $0x0
  pushl $191
80107100:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107105:	e9 06 f2 ff ff       	jmp    80106310 <alltraps>

8010710a <vector192>:
.globl vector192
vector192:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $192
8010710c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107111:	e9 fa f1 ff ff       	jmp    80106310 <alltraps>

80107116 <vector193>:
.globl vector193
vector193:
  pushl $0
80107116:	6a 00                	push   $0x0
  pushl $193
80107118:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010711d:	e9 ee f1 ff ff       	jmp    80106310 <alltraps>

80107122 <vector194>:
.globl vector194
vector194:
  pushl $0
80107122:	6a 00                	push   $0x0
  pushl $194
80107124:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107129:	e9 e2 f1 ff ff       	jmp    80106310 <alltraps>

8010712e <vector195>:
.globl vector195
vector195:
  pushl $0
8010712e:	6a 00                	push   $0x0
  pushl $195
80107130:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107135:	e9 d6 f1 ff ff       	jmp    80106310 <alltraps>

8010713a <vector196>:
.globl vector196
vector196:
  pushl $0
8010713a:	6a 00                	push   $0x0
  pushl $196
8010713c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107141:	e9 ca f1 ff ff       	jmp    80106310 <alltraps>

80107146 <vector197>:
.globl vector197
vector197:
  pushl $0
80107146:	6a 00                	push   $0x0
  pushl $197
80107148:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010714d:	e9 be f1 ff ff       	jmp    80106310 <alltraps>

80107152 <vector198>:
.globl vector198
vector198:
  pushl $0
80107152:	6a 00                	push   $0x0
  pushl $198
80107154:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107159:	e9 b2 f1 ff ff       	jmp    80106310 <alltraps>

8010715e <vector199>:
.globl vector199
vector199:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $199
80107160:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107165:	e9 a6 f1 ff ff       	jmp    80106310 <alltraps>

8010716a <vector200>:
.globl vector200
vector200:
  pushl $0
8010716a:	6a 00                	push   $0x0
  pushl $200
8010716c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107171:	e9 9a f1 ff ff       	jmp    80106310 <alltraps>

80107176 <vector201>:
.globl vector201
vector201:
  pushl $0
80107176:	6a 00                	push   $0x0
  pushl $201
80107178:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010717d:	e9 8e f1 ff ff       	jmp    80106310 <alltraps>

80107182 <vector202>:
.globl vector202
vector202:
  pushl $0
80107182:	6a 00                	push   $0x0
  pushl $202
80107184:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107189:	e9 82 f1 ff ff       	jmp    80106310 <alltraps>

8010718e <vector203>:
.globl vector203
vector203:
  pushl $0
8010718e:	6a 00                	push   $0x0
  pushl $203
80107190:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107195:	e9 76 f1 ff ff       	jmp    80106310 <alltraps>

8010719a <vector204>:
.globl vector204
vector204:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $204
8010719c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801071a1:	e9 6a f1 ff ff       	jmp    80106310 <alltraps>

801071a6 <vector205>:
.globl vector205
vector205:
  pushl $0
801071a6:	6a 00                	push   $0x0
  pushl $205
801071a8:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801071ad:	e9 5e f1 ff ff       	jmp    80106310 <alltraps>

801071b2 <vector206>:
.globl vector206
vector206:
  pushl $0
801071b2:	6a 00                	push   $0x0
  pushl $206
801071b4:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801071b9:	e9 52 f1 ff ff       	jmp    80106310 <alltraps>

801071be <vector207>:
.globl vector207
vector207:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $207
801071c0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801071c5:	e9 46 f1 ff ff       	jmp    80106310 <alltraps>

801071ca <vector208>:
.globl vector208
vector208:
  pushl $0
801071ca:	6a 00                	push   $0x0
  pushl $208
801071cc:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801071d1:	e9 3a f1 ff ff       	jmp    80106310 <alltraps>

801071d6 <vector209>:
.globl vector209
vector209:
  pushl $0
801071d6:	6a 00                	push   $0x0
  pushl $209
801071d8:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801071dd:	e9 2e f1 ff ff       	jmp    80106310 <alltraps>

801071e2 <vector210>:
.globl vector210
vector210:
  pushl $0
801071e2:	6a 00                	push   $0x0
  pushl $210
801071e4:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801071e9:	e9 22 f1 ff ff       	jmp    80106310 <alltraps>

801071ee <vector211>:
.globl vector211
vector211:
  pushl $0
801071ee:	6a 00                	push   $0x0
  pushl $211
801071f0:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801071f5:	e9 16 f1 ff ff       	jmp    80106310 <alltraps>

801071fa <vector212>:
.globl vector212
vector212:
  pushl $0
801071fa:	6a 00                	push   $0x0
  pushl $212
801071fc:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107201:	e9 0a f1 ff ff       	jmp    80106310 <alltraps>

80107206 <vector213>:
.globl vector213
vector213:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $213
80107208:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010720d:	e9 fe f0 ff ff       	jmp    80106310 <alltraps>

80107212 <vector214>:
.globl vector214
vector214:
  pushl $0
80107212:	6a 00                	push   $0x0
  pushl $214
80107214:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107219:	e9 f2 f0 ff ff       	jmp    80106310 <alltraps>

8010721e <vector215>:
.globl vector215
vector215:
  pushl $0
8010721e:	6a 00                	push   $0x0
  pushl $215
80107220:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107225:	e9 e6 f0 ff ff       	jmp    80106310 <alltraps>

8010722a <vector216>:
.globl vector216
vector216:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $216
8010722c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107231:	e9 da f0 ff ff       	jmp    80106310 <alltraps>

80107236 <vector217>:
.globl vector217
vector217:
  pushl $0
80107236:	6a 00                	push   $0x0
  pushl $217
80107238:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010723d:	e9 ce f0 ff ff       	jmp    80106310 <alltraps>

80107242 <vector218>:
.globl vector218
vector218:
  pushl $0
80107242:	6a 00                	push   $0x0
  pushl $218
80107244:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107249:	e9 c2 f0 ff ff       	jmp    80106310 <alltraps>

8010724e <vector219>:
.globl vector219
vector219:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $219
80107250:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107255:	e9 b6 f0 ff ff       	jmp    80106310 <alltraps>

8010725a <vector220>:
.globl vector220
vector220:
  pushl $0
8010725a:	6a 00                	push   $0x0
  pushl $220
8010725c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107261:	e9 aa f0 ff ff       	jmp    80106310 <alltraps>

80107266 <vector221>:
.globl vector221
vector221:
  pushl $0
80107266:	6a 00                	push   $0x0
  pushl $221
80107268:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010726d:	e9 9e f0 ff ff       	jmp    80106310 <alltraps>

80107272 <vector222>:
.globl vector222
vector222:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $222
80107274:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107279:	e9 92 f0 ff ff       	jmp    80106310 <alltraps>

8010727e <vector223>:
.globl vector223
vector223:
  pushl $0
8010727e:	6a 00                	push   $0x0
  pushl $223
80107280:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107285:	e9 86 f0 ff ff       	jmp    80106310 <alltraps>

8010728a <vector224>:
.globl vector224
vector224:
  pushl $0
8010728a:	6a 00                	push   $0x0
  pushl $224
8010728c:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107291:	e9 7a f0 ff ff       	jmp    80106310 <alltraps>

80107296 <vector225>:
.globl vector225
vector225:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $225
80107298:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010729d:	e9 6e f0 ff ff       	jmp    80106310 <alltraps>

801072a2 <vector226>:
.globl vector226
vector226:
  pushl $0
801072a2:	6a 00                	push   $0x0
  pushl $226
801072a4:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801072a9:	e9 62 f0 ff ff       	jmp    80106310 <alltraps>

801072ae <vector227>:
.globl vector227
vector227:
  pushl $0
801072ae:	6a 00                	push   $0x0
  pushl $227
801072b0:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801072b5:	e9 56 f0 ff ff       	jmp    80106310 <alltraps>

801072ba <vector228>:
.globl vector228
vector228:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $228
801072bc:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801072c1:	e9 4a f0 ff ff       	jmp    80106310 <alltraps>

801072c6 <vector229>:
.globl vector229
vector229:
  pushl $0
801072c6:	6a 00                	push   $0x0
  pushl $229
801072c8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801072cd:	e9 3e f0 ff ff       	jmp    80106310 <alltraps>

801072d2 <vector230>:
.globl vector230
vector230:
  pushl $0
801072d2:	6a 00                	push   $0x0
  pushl $230
801072d4:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801072d9:	e9 32 f0 ff ff       	jmp    80106310 <alltraps>

801072de <vector231>:
.globl vector231
vector231:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $231
801072e0:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801072e5:	e9 26 f0 ff ff       	jmp    80106310 <alltraps>

801072ea <vector232>:
.globl vector232
vector232:
  pushl $0
801072ea:	6a 00                	push   $0x0
  pushl $232
801072ec:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801072f1:	e9 1a f0 ff ff       	jmp    80106310 <alltraps>

801072f6 <vector233>:
.globl vector233
vector233:
  pushl $0
801072f6:	6a 00                	push   $0x0
  pushl $233
801072f8:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801072fd:	e9 0e f0 ff ff       	jmp    80106310 <alltraps>

80107302 <vector234>:
.globl vector234
vector234:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $234
80107304:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107309:	e9 02 f0 ff ff       	jmp    80106310 <alltraps>

8010730e <vector235>:
.globl vector235
vector235:
  pushl $0
8010730e:	6a 00                	push   $0x0
  pushl $235
80107310:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107315:	e9 f6 ef ff ff       	jmp    80106310 <alltraps>

8010731a <vector236>:
.globl vector236
vector236:
  pushl $0
8010731a:	6a 00                	push   $0x0
  pushl $236
8010731c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107321:	e9 ea ef ff ff       	jmp    80106310 <alltraps>

80107326 <vector237>:
.globl vector237
vector237:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $237
80107328:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010732d:	e9 de ef ff ff       	jmp    80106310 <alltraps>

80107332 <vector238>:
.globl vector238
vector238:
  pushl $0
80107332:	6a 00                	push   $0x0
  pushl $238
80107334:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107339:	e9 d2 ef ff ff       	jmp    80106310 <alltraps>

8010733e <vector239>:
.globl vector239
vector239:
  pushl $0
8010733e:	6a 00                	push   $0x0
  pushl $239
80107340:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107345:	e9 c6 ef ff ff       	jmp    80106310 <alltraps>

8010734a <vector240>:
.globl vector240
vector240:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $240
8010734c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107351:	e9 ba ef ff ff       	jmp    80106310 <alltraps>

80107356 <vector241>:
.globl vector241
vector241:
  pushl $0
80107356:	6a 00                	push   $0x0
  pushl $241
80107358:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010735d:	e9 ae ef ff ff       	jmp    80106310 <alltraps>

80107362 <vector242>:
.globl vector242
vector242:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $242
80107364:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107369:	e9 a2 ef ff ff       	jmp    80106310 <alltraps>

8010736e <vector243>:
.globl vector243
vector243:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $243
80107370:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107375:	e9 96 ef ff ff       	jmp    80106310 <alltraps>

8010737a <vector244>:
.globl vector244
vector244:
  pushl $0
8010737a:	6a 00                	push   $0x0
  pushl $244
8010737c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107381:	e9 8a ef ff ff       	jmp    80106310 <alltraps>

80107386 <vector245>:
.globl vector245
vector245:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $245
80107388:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010738d:	e9 7e ef ff ff       	jmp    80106310 <alltraps>

80107392 <vector246>:
.globl vector246
vector246:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $246
80107394:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107399:	e9 72 ef ff ff       	jmp    80106310 <alltraps>

8010739e <vector247>:
.globl vector247
vector247:
  pushl $0
8010739e:	6a 00                	push   $0x0
  pushl $247
801073a0:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801073a5:	e9 66 ef ff ff       	jmp    80106310 <alltraps>

801073aa <vector248>:
.globl vector248
vector248:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $248
801073ac:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801073b1:	e9 5a ef ff ff       	jmp    80106310 <alltraps>

801073b6 <vector249>:
.globl vector249
vector249:
  pushl $0
801073b6:	6a 00                	push   $0x0
  pushl $249
801073b8:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801073bd:	e9 4e ef ff ff       	jmp    80106310 <alltraps>

801073c2 <vector250>:
.globl vector250
vector250:
  pushl $0
801073c2:	6a 00                	push   $0x0
  pushl $250
801073c4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801073c9:	e9 42 ef ff ff       	jmp    80106310 <alltraps>

801073ce <vector251>:
.globl vector251
vector251:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $251
801073d0:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801073d5:	e9 36 ef ff ff       	jmp    80106310 <alltraps>

801073da <vector252>:
.globl vector252
vector252:
  pushl $0
801073da:	6a 00                	push   $0x0
  pushl $252
801073dc:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801073e1:	e9 2a ef ff ff       	jmp    80106310 <alltraps>

801073e6 <vector253>:
.globl vector253
vector253:
  pushl $0
801073e6:	6a 00                	push   $0x0
  pushl $253
801073e8:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801073ed:	e9 1e ef ff ff       	jmp    80106310 <alltraps>

801073f2 <vector254>:
.globl vector254
vector254:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $254
801073f4:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801073f9:	e9 12 ef ff ff       	jmp    80106310 <alltraps>

801073fe <vector255>:
.globl vector255
vector255:
  pushl $0
801073fe:	6a 00                	push   $0x0
  pushl $255
80107400:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107405:	e9 06 ef ff ff       	jmp    80106310 <alltraps>

8010740a <lgdt>:
{
8010740a:	55                   	push   %ebp
8010740b:	89 e5                	mov    %esp,%ebp
8010740d:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107410:	8b 45 0c             	mov    0xc(%ebp),%eax
80107413:	83 e8 01             	sub    $0x1,%eax
80107416:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010741a:	8b 45 08             	mov    0x8(%ebp),%eax
8010741d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107421:	8b 45 08             	mov    0x8(%ebp),%eax
80107424:	c1 e8 10             	shr    $0x10,%eax
80107427:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010742b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010742e:	0f 01 10             	lgdtl  (%eax)
}
80107431:	90                   	nop
80107432:	c9                   	leave  
80107433:	c3                   	ret    

80107434 <ltr>:
{
80107434:	55                   	push   %ebp
80107435:	89 e5                	mov    %esp,%ebp
80107437:	83 ec 04             	sub    $0x4,%esp
8010743a:	8b 45 08             	mov    0x8(%ebp),%eax
8010743d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107441:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107445:	0f 00 d8             	ltr    %ax
}
80107448:	90                   	nop
80107449:	c9                   	leave  
8010744a:	c3                   	ret    

8010744b <lcr3>:

static inline void
lcr3(uint val)
{
8010744b:	55                   	push   %ebp
8010744c:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010744e:	8b 45 08             	mov    0x8(%ebp),%eax
80107451:	0f 22 d8             	mov    %eax,%cr3
}
80107454:	90                   	nop
80107455:	5d                   	pop    %ebp
80107456:	c3                   	ret    

80107457 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107457:	55                   	push   %ebp
80107458:	89 e5                	mov    %esp,%ebp
8010745a:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010745d:	e8 3b c5 ff ff       	call   8010399d <cpuid>
80107462:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107468:	05 80 74 19 80       	add    $0x80197480,%eax
8010746d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107473:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747c:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107482:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107485:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107490:	83 e2 f0             	and    $0xfffffff0,%edx
80107493:	83 ca 0a             	or     $0xa,%edx
80107496:	88 50 7d             	mov    %dl,0x7d(%eax)
80107499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010749c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801074a0:	83 ca 10             	or     $0x10,%edx
801074a3:	88 50 7d             	mov    %dl,0x7d(%eax)
801074a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801074ad:	83 e2 9f             	and    $0xffffff9f,%edx
801074b0:	88 50 7d             	mov    %dl,0x7d(%eax)
801074b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b6:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801074ba:	83 ca 80             	or     $0xffffff80,%edx
801074bd:	88 50 7d             	mov    %dl,0x7d(%eax)
801074c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801074c7:	83 ca 0f             	or     $0xf,%edx
801074ca:	88 50 7e             	mov    %dl,0x7e(%eax)
801074cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801074d4:	83 e2 ef             	and    $0xffffffef,%edx
801074d7:	88 50 7e             	mov    %dl,0x7e(%eax)
801074da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074dd:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801074e1:	83 e2 df             	and    $0xffffffdf,%edx
801074e4:	88 50 7e             	mov    %dl,0x7e(%eax)
801074e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ea:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801074ee:	83 ca 40             	or     $0x40,%edx
801074f1:	88 50 7e             	mov    %dl,0x7e(%eax)
801074f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801074fb:	83 ca 80             	or     $0xffffff80,%edx
801074fe:	88 50 7e             	mov    %dl,0x7e(%eax)
80107501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107504:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010750b:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107512:	ff ff 
80107514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107517:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010751e:	00 00 
80107520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107523:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010752a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107534:	83 e2 f0             	and    $0xfffffff0,%edx
80107537:	83 ca 02             	or     $0x2,%edx
8010753a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107543:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010754a:	83 ca 10             	or     $0x10,%edx
8010754d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107556:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010755d:	83 e2 9f             	and    $0xffffff9f,%edx
80107560:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107569:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107570:	83 ca 80             	or     $0xffffff80,%edx
80107573:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107583:	83 ca 0f             	or     $0xf,%edx
80107586:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010758c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107596:	83 e2 ef             	and    $0xffffffef,%edx
80107599:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010759f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801075a9:	83 e2 df             	and    $0xffffffdf,%edx
801075ac:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801075b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801075bc:	83 ca 40             	or     $0x40,%edx
801075bf:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801075c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801075cf:	83 ca 80             	or     $0xffffff80,%edx
801075d2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801075d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075db:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801075e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e5:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801075ec:	ff ff 
801075ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f1:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801075f8:	00 00 
801075fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075fd:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107607:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010760e:	83 e2 f0             	and    $0xfffffff0,%edx
80107611:	83 ca 0a             	or     $0xa,%edx
80107614:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010761a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107624:	83 ca 10             	or     $0x10,%edx
80107627:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010762d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107630:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107637:	83 ca 60             	or     $0x60,%edx
8010763a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107643:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010764a:	83 ca 80             	or     $0xffffff80,%edx
8010764d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107656:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010765d:	83 ca 0f             	or     $0xf,%edx
80107660:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107669:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107670:	83 e2 ef             	and    $0xffffffef,%edx
80107673:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107683:	83 e2 df             	and    $0xffffffdf,%edx
80107686:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010768c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107696:	83 ca 40             	or     $0x40,%edx
80107699:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010769f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076a9:	83 ca 80             	or     $0xffffff80,%edx
801076ac:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b5:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801076bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076bf:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801076c6:	ff ff 
801076c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cb:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801076d2:	00 00 
801076d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d7:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801076de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e1:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801076e8:	83 e2 f0             	and    $0xfffffff0,%edx
801076eb:	83 ca 02             	or     $0x2,%edx
801076ee:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801076f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801076fe:	83 ca 10             	or     $0x10,%edx
80107701:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010770a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107711:	83 ca 60             	or     $0x60,%edx
80107714:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010771a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107724:	83 ca 80             	or     $0xffffff80,%edx
80107727:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010772d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107730:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107737:	83 ca 0f             	or     $0xf,%edx
8010773a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107743:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010774a:	83 e2 ef             	and    $0xffffffef,%edx
8010774d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107756:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010775d:	83 e2 df             	and    $0xffffffdf,%edx
80107760:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107769:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107770:	83 ca 40             	or     $0x40,%edx
80107773:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107783:	83 ca 80             	or     $0xffffff80,%edx
80107786:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010778c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778f:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107799:	83 c0 70             	add    $0x70,%eax
8010779c:	83 ec 08             	sub    $0x8,%esp
8010779f:	6a 30                	push   $0x30
801077a1:	50                   	push   %eax
801077a2:	e8 63 fc ff ff       	call   8010740a <lgdt>
801077a7:	83 c4 10             	add    $0x10,%esp
}
801077aa:	90                   	nop
801077ab:	c9                   	leave  
801077ac:	c3                   	ret    

801077ad <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801077ad:	55                   	push   %ebp
801077ae:	89 e5                	mov    %esp,%ebp
801077b0:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801077b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801077b6:	c1 e8 16             	shr    $0x16,%eax
801077b9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801077c0:	8b 45 08             	mov    0x8(%ebp),%eax
801077c3:	01 d0                	add    %edx,%eax
801077c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801077c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801077cb:	8b 00                	mov    (%eax),%eax
801077cd:	83 e0 01             	and    $0x1,%eax
801077d0:	85 c0                	test   %eax,%eax
801077d2:	74 14                	je     801077e8 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801077d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801077d7:	8b 00                	mov    (%eax),%eax
801077d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077de:	05 00 00 00 80       	add    $0x80000000,%eax
801077e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801077e6:	eb 42                	jmp    8010782a <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801077e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801077ec:	74 0e                	je     801077fc <walkpgdir+0x4f>
801077ee:	e8 ad af ff ff       	call   801027a0 <kalloc>
801077f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801077f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801077fa:	75 07                	jne    80107803 <walkpgdir+0x56>
      return 0;
801077fc:	b8 00 00 00 00       	mov    $0x0,%eax
80107801:	eb 3e                	jmp    80107841 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107803:	83 ec 04             	sub    $0x4,%esp
80107806:	68 00 10 00 00       	push   $0x1000
8010780b:	6a 00                	push   $0x0
8010780d:	ff 75 f4             	push   -0xc(%ebp)
80107810:	e8 50 d5 ff ff       	call   80104d65 <memset>
80107815:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781b:	05 00 00 00 80       	add    $0x80000000,%eax
80107820:	83 c8 07             	or     $0x7,%eax
80107823:	89 c2                	mov    %eax,%edx
80107825:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107828:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010782a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010782d:	c1 e8 0c             	shr    $0xc,%eax
80107830:	25 ff 03 00 00       	and    $0x3ff,%eax
80107835:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010783c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783f:	01 d0                	add    %edx,%eax
}
80107841:	c9                   	leave  
80107842:	c3                   	ret    

80107843 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107843:	55                   	push   %ebp
80107844:	89 e5                	mov    %esp,%ebp
80107846:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107849:	8b 45 0c             	mov    0xc(%ebp),%eax
8010784c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107851:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107854:	8b 55 0c             	mov    0xc(%ebp),%edx
80107857:	8b 45 10             	mov    0x10(%ebp),%eax
8010785a:	01 d0                	add    %edx,%eax
8010785c:	83 e8 01             	sub    $0x1,%eax
8010785f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107864:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107867:	83 ec 04             	sub    $0x4,%esp
8010786a:	6a 01                	push   $0x1
8010786c:	ff 75 f4             	push   -0xc(%ebp)
8010786f:	ff 75 08             	push   0x8(%ebp)
80107872:	e8 36 ff ff ff       	call   801077ad <walkpgdir>
80107877:	83 c4 10             	add    $0x10,%esp
8010787a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010787d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107881:	75 07                	jne    8010788a <mappages+0x47>
      return -1;
80107883:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107888:	eb 47                	jmp    801078d1 <mappages+0x8e>
    if(*pte & PTE_P)
8010788a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010788d:	8b 00                	mov    (%eax),%eax
8010788f:	83 e0 01             	and    $0x1,%eax
80107892:	85 c0                	test   %eax,%eax
80107894:	74 0d                	je     801078a3 <mappages+0x60>
      panic("remap");
80107896:	83 ec 0c             	sub    $0xc,%esp
80107899:	68 84 ab 10 80       	push   $0x8010ab84
8010789e:	e8 06 8d ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
801078a3:	8b 45 18             	mov    0x18(%ebp),%eax
801078a6:	0b 45 14             	or     0x14(%ebp),%eax
801078a9:	83 c8 01             	or     $0x1,%eax
801078ac:	89 c2                	mov    %eax,%edx
801078ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801078b1:	89 10                	mov    %edx,(%eax)
    if(a == last)
801078b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801078b9:	74 10                	je     801078cb <mappages+0x88>
      break;
    a += PGSIZE;
801078bb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801078c2:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801078c9:	eb 9c                	jmp    80107867 <mappages+0x24>
      break;
801078cb:	90                   	nop
  }
  return 0;
801078cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801078d1:	c9                   	leave  
801078d2:	c3                   	ret    

801078d3 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801078d3:	55                   	push   %ebp
801078d4:	89 e5                	mov    %esp,%ebp
801078d6:	53                   	push   %ebx
801078d7:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801078da:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801078e1:	8b 15 60 77 19 80    	mov    0x80197760,%edx
801078e7:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801078ec:	29 d0                	sub    %edx,%eax
801078ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
801078f1:	a1 58 77 19 80       	mov    0x80197758,%eax
801078f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801078f9:	8b 15 58 77 19 80    	mov    0x80197758,%edx
801078ff:	a1 60 77 19 80       	mov    0x80197760,%eax
80107904:	01 d0                	add    %edx,%eax
80107906:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107909:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107913:	83 c0 30             	add    $0x30,%eax
80107916:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107919:	89 10                	mov    %edx,(%eax)
8010791b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010791e:	89 50 04             	mov    %edx,0x4(%eax)
80107921:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107924:	89 50 08             	mov    %edx,0x8(%eax)
80107927:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010792a:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
8010792d:	e8 6e ae ff ff       	call   801027a0 <kalloc>
80107932:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107935:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107939:	75 07                	jne    80107942 <setupkvm+0x6f>
    return 0;
8010793b:	b8 00 00 00 00       	mov    $0x0,%eax
80107940:	eb 78                	jmp    801079ba <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107942:	83 ec 04             	sub    $0x4,%esp
80107945:	68 00 10 00 00       	push   $0x1000
8010794a:	6a 00                	push   $0x0
8010794c:	ff 75 f0             	push   -0x10(%ebp)
8010794f:	e8 11 d4 ff ff       	call   80104d65 <memset>
80107954:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107957:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
8010795e:	eb 4e                	jmp    801079ae <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107963:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107969:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010796c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796f:	8b 58 08             	mov    0x8(%eax),%ebx
80107972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107975:	8b 40 04             	mov    0x4(%eax),%eax
80107978:	29 c3                	sub    %eax,%ebx
8010797a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797d:	8b 00                	mov    (%eax),%eax
8010797f:	83 ec 0c             	sub    $0xc,%esp
80107982:	51                   	push   %ecx
80107983:	52                   	push   %edx
80107984:	53                   	push   %ebx
80107985:	50                   	push   %eax
80107986:	ff 75 f0             	push   -0x10(%ebp)
80107989:	e8 b5 fe ff ff       	call   80107843 <mappages>
8010798e:	83 c4 20             	add    $0x20,%esp
80107991:	85 c0                	test   %eax,%eax
80107993:	79 15                	jns    801079aa <setupkvm+0xd7>
      freevm(pgdir);
80107995:	83 ec 0c             	sub    $0xc,%esp
80107998:	ff 75 f0             	push   -0x10(%ebp)
8010799b:	e8 f5 04 00 00       	call   80107e95 <freevm>
801079a0:	83 c4 10             	add    $0x10,%esp
      return 0;
801079a3:	b8 00 00 00 00       	mov    $0x0,%eax
801079a8:	eb 10                	jmp    801079ba <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801079aa:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801079ae:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
801079b5:	72 a9                	jb     80107960 <setupkvm+0x8d>
    }
  return pgdir;
801079b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801079ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801079bd:	c9                   	leave  
801079be:	c3                   	ret    

801079bf <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801079bf:	55                   	push   %ebp
801079c0:	89 e5                	mov    %esp,%ebp
801079c2:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801079c5:	e8 09 ff ff ff       	call   801078d3 <setupkvm>
801079ca:	a3 7c 74 19 80       	mov    %eax,0x8019747c
  switchkvm();
801079cf:	e8 03 00 00 00       	call   801079d7 <switchkvm>
}
801079d4:	90                   	nop
801079d5:	c9                   	leave  
801079d6:	c3                   	ret    

801079d7 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801079d7:	55                   	push   %ebp
801079d8:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801079da:	a1 7c 74 19 80       	mov    0x8019747c,%eax
801079df:	05 00 00 00 80       	add    $0x80000000,%eax
801079e4:	50                   	push   %eax
801079e5:	e8 61 fa ff ff       	call   8010744b <lcr3>
801079ea:	83 c4 04             	add    $0x4,%esp
}
801079ed:	90                   	nop
801079ee:	c9                   	leave  
801079ef:	c3                   	ret    

801079f0 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801079f0:	55                   	push   %ebp
801079f1:	89 e5                	mov    %esp,%ebp
801079f3:	56                   	push   %esi
801079f4:	53                   	push   %ebx
801079f5:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801079f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801079fc:	75 0d                	jne    80107a0b <switchuvm+0x1b>
    panic("switchuvm: no process");
801079fe:	83 ec 0c             	sub    $0xc,%esp
80107a01:	68 8a ab 10 80       	push   $0x8010ab8a
80107a06:	e8 9e 8b ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107a0b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a0e:	8b 40 08             	mov    0x8(%eax),%eax
80107a11:	85 c0                	test   %eax,%eax
80107a13:	75 0d                	jne    80107a22 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107a15:	83 ec 0c             	sub    $0xc,%esp
80107a18:	68 a0 ab 10 80       	push   $0x8010aba0
80107a1d:	e8 87 8b ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107a22:	8b 45 08             	mov    0x8(%ebp),%eax
80107a25:	8b 40 04             	mov    0x4(%eax),%eax
80107a28:	85 c0                	test   %eax,%eax
80107a2a:	75 0d                	jne    80107a39 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107a2c:	83 ec 0c             	sub    $0xc,%esp
80107a2f:	68 b5 ab 10 80       	push   $0x8010abb5
80107a34:	e8 70 8b ff ff       	call   801005a9 <panic>

  pushcli();
80107a39:	e8 1c d2 ff ff       	call   80104c5a <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107a3e:	e8 75 bf ff ff       	call   801039b8 <mycpu>
80107a43:	89 c3                	mov    %eax,%ebx
80107a45:	e8 6e bf ff ff       	call   801039b8 <mycpu>
80107a4a:	83 c0 08             	add    $0x8,%eax
80107a4d:	89 c6                	mov    %eax,%esi
80107a4f:	e8 64 bf ff ff       	call   801039b8 <mycpu>
80107a54:	83 c0 08             	add    $0x8,%eax
80107a57:	c1 e8 10             	shr    $0x10,%eax
80107a5a:	88 45 f7             	mov    %al,-0x9(%ebp)
80107a5d:	e8 56 bf ff ff       	call   801039b8 <mycpu>
80107a62:	83 c0 08             	add    $0x8,%eax
80107a65:	c1 e8 18             	shr    $0x18,%eax
80107a68:	89 c2                	mov    %eax,%edx
80107a6a:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107a71:	67 00 
80107a73:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107a7a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107a7e:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107a84:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107a8b:	83 e0 f0             	and    $0xfffffff0,%eax
80107a8e:	83 c8 09             	or     $0x9,%eax
80107a91:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107a97:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107a9e:	83 c8 10             	or     $0x10,%eax
80107aa1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107aa7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107aae:	83 e0 9f             	and    $0xffffff9f,%eax
80107ab1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ab7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107abe:	83 c8 80             	or     $0xffffff80,%eax
80107ac1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ac7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ace:	83 e0 f0             	and    $0xfffffff0,%eax
80107ad1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ad7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ade:	83 e0 ef             	and    $0xffffffef,%eax
80107ae1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ae7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107aee:	83 e0 df             	and    $0xffffffdf,%eax
80107af1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107af7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107afe:	83 c8 40             	or     $0x40,%eax
80107b01:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b07:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b0e:	83 e0 7f             	and    $0x7f,%eax
80107b11:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b17:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107b1d:	e8 96 be ff ff       	call   801039b8 <mycpu>
80107b22:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b29:	83 e2 ef             	and    $0xffffffef,%edx
80107b2c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107b32:	e8 81 be ff ff       	call   801039b8 <mycpu>
80107b37:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80107b40:	8b 40 08             	mov    0x8(%eax),%eax
80107b43:	89 c3                	mov    %eax,%ebx
80107b45:	e8 6e be ff ff       	call   801039b8 <mycpu>
80107b4a:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107b50:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107b53:	e8 60 be ff ff       	call   801039b8 <mycpu>
80107b58:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107b5e:	83 ec 0c             	sub    $0xc,%esp
80107b61:	6a 28                	push   $0x28
80107b63:	e8 cc f8 ff ff       	call   80107434 <ltr>
80107b68:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80107b6e:	8b 40 04             	mov    0x4(%eax),%eax
80107b71:	05 00 00 00 80       	add    $0x80000000,%eax
80107b76:	83 ec 0c             	sub    $0xc,%esp
80107b79:	50                   	push   %eax
80107b7a:	e8 cc f8 ff ff       	call   8010744b <lcr3>
80107b7f:	83 c4 10             	add    $0x10,%esp
  popcli();
80107b82:	e8 20 d1 ff ff       	call   80104ca7 <popcli>
}
80107b87:	90                   	nop
80107b88:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107b8b:	5b                   	pop    %ebx
80107b8c:	5e                   	pop    %esi
80107b8d:	5d                   	pop    %ebp
80107b8e:	c3                   	ret    

80107b8f <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107b8f:	55                   	push   %ebp
80107b90:	89 e5                	mov    %esp,%ebp
80107b92:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107b95:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107b9c:	76 0d                	jbe    80107bab <inituvm+0x1c>
    panic("inituvm: more than a page");
80107b9e:	83 ec 0c             	sub    $0xc,%esp
80107ba1:	68 c9 ab 10 80       	push   $0x8010abc9
80107ba6:	e8 fe 89 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107bab:	e8 f0 ab ff ff       	call   801027a0 <kalloc>
80107bb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107bb3:	83 ec 04             	sub    $0x4,%esp
80107bb6:	68 00 10 00 00       	push   $0x1000
80107bbb:	6a 00                	push   $0x0
80107bbd:	ff 75 f4             	push   -0xc(%ebp)
80107bc0:	e8 a0 d1 ff ff       	call   80104d65 <memset>
80107bc5:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcb:	05 00 00 00 80       	add    $0x80000000,%eax
80107bd0:	83 ec 0c             	sub    $0xc,%esp
80107bd3:	6a 06                	push   $0x6
80107bd5:	50                   	push   %eax
80107bd6:	68 00 10 00 00       	push   $0x1000
80107bdb:	6a 00                	push   $0x0
80107bdd:	ff 75 08             	push   0x8(%ebp)
80107be0:	e8 5e fc ff ff       	call   80107843 <mappages>
80107be5:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107be8:	83 ec 04             	sub    $0x4,%esp
80107beb:	ff 75 10             	push   0x10(%ebp)
80107bee:	ff 75 0c             	push   0xc(%ebp)
80107bf1:	ff 75 f4             	push   -0xc(%ebp)
80107bf4:	e8 2b d2 ff ff       	call   80104e24 <memmove>
80107bf9:	83 c4 10             	add    $0x10,%esp
}
80107bfc:	90                   	nop
80107bfd:	c9                   	leave  
80107bfe:	c3                   	ret    

80107bff <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107bff:	55                   	push   %ebp
80107c00:	89 e5                	mov    %esp,%ebp
80107c02:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107c05:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c08:	25 ff 0f 00 00       	and    $0xfff,%eax
80107c0d:	85 c0                	test   %eax,%eax
80107c0f:	74 0d                	je     80107c1e <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107c11:	83 ec 0c             	sub    $0xc,%esp
80107c14:	68 e4 ab 10 80       	push   $0x8010abe4
80107c19:	e8 8b 89 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107c1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c25:	e9 8f 00 00 00       	jmp    80107cb9 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107c2a:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c30:	01 d0                	add    %edx,%eax
80107c32:	83 ec 04             	sub    $0x4,%esp
80107c35:	6a 00                	push   $0x0
80107c37:	50                   	push   %eax
80107c38:	ff 75 08             	push   0x8(%ebp)
80107c3b:	e8 6d fb ff ff       	call   801077ad <walkpgdir>
80107c40:	83 c4 10             	add    $0x10,%esp
80107c43:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c46:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c4a:	75 0d                	jne    80107c59 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107c4c:	83 ec 0c             	sub    $0xc,%esp
80107c4f:	68 07 ac 10 80       	push   $0x8010ac07
80107c54:	e8 50 89 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107c59:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c5c:	8b 00                	mov    (%eax),%eax
80107c5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c63:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107c66:	8b 45 18             	mov    0x18(%ebp),%eax
80107c69:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107c6c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107c71:	77 0b                	ja     80107c7e <loaduvm+0x7f>
      n = sz - i;
80107c73:	8b 45 18             	mov    0x18(%ebp),%eax
80107c76:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107c79:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c7c:	eb 07                	jmp    80107c85 <loaduvm+0x86>
    else
      n = PGSIZE;
80107c7e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107c85:	8b 55 14             	mov    0x14(%ebp),%edx
80107c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8b:	01 d0                	add    %edx,%eax
80107c8d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107c90:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107c96:	ff 75 f0             	push   -0x10(%ebp)
80107c99:	50                   	push   %eax
80107c9a:	52                   	push   %edx
80107c9b:	ff 75 10             	push   0x10(%ebp)
80107c9e:	e8 33 a2 ff ff       	call   80101ed6 <readi>
80107ca3:	83 c4 10             	add    $0x10,%esp
80107ca6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107ca9:	74 07                	je     80107cb2 <loaduvm+0xb3>
      return -1;
80107cab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107cb0:	eb 18                	jmp    80107cca <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107cb2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbc:	3b 45 18             	cmp    0x18(%ebp),%eax
80107cbf:	0f 82 65 ff ff ff    	jb     80107c2a <loaduvm+0x2b>
  }
  return 0;
80107cc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107cca:	c9                   	leave  
80107ccb:	c3                   	ret    

80107ccc <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107ccc:	55                   	push   %ebp
80107ccd:	89 e5                	mov    %esp,%ebp
80107ccf:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107cd2:	8b 45 10             	mov    0x10(%ebp),%eax
80107cd5:	85 c0                	test   %eax,%eax
80107cd7:	79 0a                	jns    80107ce3 <allocuvm+0x17>
    return 0;
80107cd9:	b8 00 00 00 00       	mov    $0x0,%eax
80107cde:	e9 ec 00 00 00       	jmp    80107dcf <allocuvm+0x103>
  if(newsz < oldsz)
80107ce3:	8b 45 10             	mov    0x10(%ebp),%eax
80107ce6:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ce9:	73 08                	jae    80107cf3 <allocuvm+0x27>
    return oldsz;
80107ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cee:	e9 dc 00 00 00       	jmp    80107dcf <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cf6:	05 ff 0f 00 00       	add    $0xfff,%eax
80107cfb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d00:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107d03:	e9 b8 00 00 00       	jmp    80107dc0 <allocuvm+0xf4>
    mem = kalloc();
80107d08:	e8 93 aa ff ff       	call   801027a0 <kalloc>
80107d0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107d10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d14:	75 2e                	jne    80107d44 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107d16:	83 ec 0c             	sub    $0xc,%esp
80107d19:	68 25 ac 10 80       	push   $0x8010ac25
80107d1e:	e8 d1 86 ff ff       	call   801003f4 <cprintf>
80107d23:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107d26:	83 ec 04             	sub    $0x4,%esp
80107d29:	ff 75 0c             	push   0xc(%ebp)
80107d2c:	ff 75 10             	push   0x10(%ebp)
80107d2f:	ff 75 08             	push   0x8(%ebp)
80107d32:	e8 9a 00 00 00       	call   80107dd1 <deallocuvm>
80107d37:	83 c4 10             	add    $0x10,%esp
      return 0;
80107d3a:	b8 00 00 00 00       	mov    $0x0,%eax
80107d3f:	e9 8b 00 00 00       	jmp    80107dcf <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107d44:	83 ec 04             	sub    $0x4,%esp
80107d47:	68 00 10 00 00       	push   $0x1000
80107d4c:	6a 00                	push   $0x0
80107d4e:	ff 75 f0             	push   -0x10(%ebp)
80107d51:	e8 0f d0 ff ff       	call   80104d65 <memset>
80107d56:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d5c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d65:	83 ec 0c             	sub    $0xc,%esp
80107d68:	6a 06                	push   $0x6
80107d6a:	52                   	push   %edx
80107d6b:	68 00 10 00 00       	push   $0x1000
80107d70:	50                   	push   %eax
80107d71:	ff 75 08             	push   0x8(%ebp)
80107d74:	e8 ca fa ff ff       	call   80107843 <mappages>
80107d79:	83 c4 20             	add    $0x20,%esp
80107d7c:	85 c0                	test   %eax,%eax
80107d7e:	79 39                	jns    80107db9 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107d80:	83 ec 0c             	sub    $0xc,%esp
80107d83:	68 3d ac 10 80       	push   $0x8010ac3d
80107d88:	e8 67 86 ff ff       	call   801003f4 <cprintf>
80107d8d:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107d90:	83 ec 04             	sub    $0x4,%esp
80107d93:	ff 75 0c             	push   0xc(%ebp)
80107d96:	ff 75 10             	push   0x10(%ebp)
80107d99:	ff 75 08             	push   0x8(%ebp)
80107d9c:	e8 30 00 00 00       	call   80107dd1 <deallocuvm>
80107da1:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107da4:	83 ec 0c             	sub    $0xc,%esp
80107da7:	ff 75 f0             	push   -0x10(%ebp)
80107daa:	e8 57 a9 ff ff       	call   80102706 <kfree>
80107daf:	83 c4 10             	add    $0x10,%esp
      return 0;
80107db2:	b8 00 00 00 00       	mov    $0x0,%eax
80107db7:	eb 16                	jmp    80107dcf <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107db9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc3:	3b 45 10             	cmp    0x10(%ebp),%eax
80107dc6:	0f 82 3c ff ff ff    	jb     80107d08 <allocuvm+0x3c>
    }
  }
  return newsz;
80107dcc:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107dcf:	c9                   	leave  
80107dd0:	c3                   	ret    

80107dd1 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107dd1:	55                   	push   %ebp
80107dd2:	89 e5                	mov    %esp,%ebp
80107dd4:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107dd7:	8b 45 10             	mov    0x10(%ebp),%eax
80107dda:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ddd:	72 08                	jb     80107de7 <deallocuvm+0x16>
    return oldsz;
80107ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107de2:	e9 ac 00 00 00       	jmp    80107e93 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107de7:	8b 45 10             	mov    0x10(%ebp),%eax
80107dea:	05 ff 0f 00 00       	add    $0xfff,%eax
80107def:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107df4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107df7:	e9 88 00 00 00       	jmp    80107e84 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dff:	83 ec 04             	sub    $0x4,%esp
80107e02:	6a 00                	push   $0x0
80107e04:	50                   	push   %eax
80107e05:	ff 75 08             	push   0x8(%ebp)
80107e08:	e8 a0 f9 ff ff       	call   801077ad <walkpgdir>
80107e0d:	83 c4 10             	add    $0x10,%esp
80107e10:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107e13:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e17:	75 16                	jne    80107e2f <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1c:	c1 e8 16             	shr    $0x16,%eax
80107e1f:	83 c0 01             	add    $0x1,%eax
80107e22:	c1 e0 16             	shl    $0x16,%eax
80107e25:	2d 00 10 00 00       	sub    $0x1000,%eax
80107e2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e2d:	eb 4e                	jmp    80107e7d <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e32:	8b 00                	mov    (%eax),%eax
80107e34:	83 e0 01             	and    $0x1,%eax
80107e37:	85 c0                	test   %eax,%eax
80107e39:	74 42                	je     80107e7d <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107e3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e3e:	8b 00                	mov    (%eax),%eax
80107e40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e45:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107e48:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e4c:	75 0d                	jne    80107e5b <deallocuvm+0x8a>
        panic("kfree");
80107e4e:	83 ec 0c             	sub    $0xc,%esp
80107e51:	68 59 ac 10 80       	push   $0x8010ac59
80107e56:	e8 4e 87 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107e5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e5e:	05 00 00 00 80       	add    $0x80000000,%eax
80107e63:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107e66:	83 ec 0c             	sub    $0xc,%esp
80107e69:	ff 75 e8             	push   -0x18(%ebp)
80107e6c:	e8 95 a8 ff ff       	call   80102706 <kfree>
80107e71:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107e74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e77:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107e7d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e87:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e8a:	0f 82 6c ff ff ff    	jb     80107dfc <deallocuvm+0x2b>
    }
  }
  return newsz;
80107e90:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107e93:	c9                   	leave  
80107e94:	c3                   	ret    

80107e95 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107e95:	55                   	push   %ebp
80107e96:	89 e5                	mov    %esp,%ebp
80107e98:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107e9b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107e9f:	75 0d                	jne    80107eae <freevm+0x19>
    panic("freevm: no pgdir");
80107ea1:	83 ec 0c             	sub    $0xc,%esp
80107ea4:	68 5f ac 10 80       	push   $0x8010ac5f
80107ea9:	e8 fb 86 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107eae:	83 ec 04             	sub    $0x4,%esp
80107eb1:	6a 00                	push   $0x0
80107eb3:	68 00 00 00 80       	push   $0x80000000
80107eb8:	ff 75 08             	push   0x8(%ebp)
80107ebb:	e8 11 ff ff ff       	call   80107dd1 <deallocuvm>
80107ec0:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107ec3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107eca:	eb 48                	jmp    80107f14 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ed6:	8b 45 08             	mov    0x8(%ebp),%eax
80107ed9:	01 d0                	add    %edx,%eax
80107edb:	8b 00                	mov    (%eax),%eax
80107edd:	83 e0 01             	and    $0x1,%eax
80107ee0:	85 c0                	test   %eax,%eax
80107ee2:	74 2c                	je     80107f10 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107eee:	8b 45 08             	mov    0x8(%ebp),%eax
80107ef1:	01 d0                	add    %edx,%eax
80107ef3:	8b 00                	mov    (%eax),%eax
80107ef5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107efa:	05 00 00 00 80       	add    $0x80000000,%eax
80107eff:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107f02:	83 ec 0c             	sub    $0xc,%esp
80107f05:	ff 75 f0             	push   -0x10(%ebp)
80107f08:	e8 f9 a7 ff ff       	call   80102706 <kfree>
80107f0d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107f10:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107f14:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107f1b:	76 af                	jbe    80107ecc <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107f1d:	83 ec 0c             	sub    $0xc,%esp
80107f20:	ff 75 08             	push   0x8(%ebp)
80107f23:	e8 de a7 ff ff       	call   80102706 <kfree>
80107f28:	83 c4 10             	add    $0x10,%esp
}
80107f2b:	90                   	nop
80107f2c:	c9                   	leave  
80107f2d:	c3                   	ret    

80107f2e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107f2e:	55                   	push   %ebp
80107f2f:	89 e5                	mov    %esp,%ebp
80107f31:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107f34:	83 ec 04             	sub    $0x4,%esp
80107f37:	6a 00                	push   $0x0
80107f39:	ff 75 0c             	push   0xc(%ebp)
80107f3c:	ff 75 08             	push   0x8(%ebp)
80107f3f:	e8 69 f8 ff ff       	call   801077ad <walkpgdir>
80107f44:	83 c4 10             	add    $0x10,%esp
80107f47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107f4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f4e:	75 0d                	jne    80107f5d <clearpteu+0x2f>
    panic("clearpteu");
80107f50:	83 ec 0c             	sub    $0xc,%esp
80107f53:	68 70 ac 10 80       	push   $0x8010ac70
80107f58:	e8 4c 86 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f60:	8b 00                	mov    (%eax),%eax
80107f62:	83 e0 fb             	and    $0xfffffffb,%eax
80107f65:	89 c2                	mov    %eax,%edx
80107f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6a:	89 10                	mov    %edx,(%eax)
}
80107f6c:	90                   	nop
80107f6d:	c9                   	leave  
80107f6e:	c3                   	ret    

80107f6f <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107f6f:	55                   	push   %ebp
80107f70:	89 e5                	mov    %esp,%ebp
80107f72:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107f75:	e8 59 f9 ff ff       	call   801078d3 <setupkvm>
80107f7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f7d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f81:	75 0a                	jne    80107f8d <copyuvm+0x1e>
    return 0;
80107f83:	b8 00 00 00 00       	mov    $0x0,%eax
80107f88:	e9 eb 00 00 00       	jmp    80108078 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107f8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f94:	e9 b7 00 00 00       	jmp    80108050 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9c:	83 ec 04             	sub    $0x4,%esp
80107f9f:	6a 00                	push   $0x0
80107fa1:	50                   	push   %eax
80107fa2:	ff 75 08             	push   0x8(%ebp)
80107fa5:	e8 03 f8 ff ff       	call   801077ad <walkpgdir>
80107faa:	83 c4 10             	add    $0x10,%esp
80107fad:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107fb0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fb4:	75 0d                	jne    80107fc3 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107fb6:	83 ec 0c             	sub    $0xc,%esp
80107fb9:	68 7a ac 10 80       	push   $0x8010ac7a
80107fbe:	e8 e6 85 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107fc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fc6:	8b 00                	mov    (%eax),%eax
80107fc8:	83 e0 01             	and    $0x1,%eax
80107fcb:	85 c0                	test   %eax,%eax
80107fcd:	75 0d                	jne    80107fdc <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107fcf:	83 ec 0c             	sub    $0xc,%esp
80107fd2:	68 94 ac 10 80       	push   $0x8010ac94
80107fd7:	e8 cd 85 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107fdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fdf:	8b 00                	mov    (%eax),%eax
80107fe1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fe6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107fe9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fec:	8b 00                	mov    (%eax),%eax
80107fee:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ff3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107ff6:	e8 a5 a7 ff ff       	call   801027a0 <kalloc>
80107ffb:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107ffe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108002:	74 5d                	je     80108061 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108004:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108007:	05 00 00 00 80       	add    $0x80000000,%eax
8010800c:	83 ec 04             	sub    $0x4,%esp
8010800f:	68 00 10 00 00       	push   $0x1000
80108014:	50                   	push   %eax
80108015:	ff 75 e0             	push   -0x20(%ebp)
80108018:	e8 07 ce ff ff       	call   80104e24 <memmove>
8010801d:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108020:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108023:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108026:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010802c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802f:	83 ec 0c             	sub    $0xc,%esp
80108032:	52                   	push   %edx
80108033:	51                   	push   %ecx
80108034:	68 00 10 00 00       	push   $0x1000
80108039:	50                   	push   %eax
8010803a:	ff 75 f0             	push   -0x10(%ebp)
8010803d:	e8 01 f8 ff ff       	call   80107843 <mappages>
80108042:	83 c4 20             	add    $0x20,%esp
80108045:	85 c0                	test   %eax,%eax
80108047:	78 1b                	js     80108064 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80108049:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108053:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108056:	0f 82 3d ff ff ff    	jb     80107f99 <copyuvm+0x2a>
      goto bad;
  }
  return d;
8010805c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010805f:	eb 17                	jmp    80108078 <copyuvm+0x109>
      goto bad;
80108061:	90                   	nop
80108062:	eb 01                	jmp    80108065 <copyuvm+0xf6>
      goto bad;
80108064:	90                   	nop

bad:
  freevm(d);
80108065:	83 ec 0c             	sub    $0xc,%esp
80108068:	ff 75 f0             	push   -0x10(%ebp)
8010806b:	e8 25 fe ff ff       	call   80107e95 <freevm>
80108070:	83 c4 10             	add    $0x10,%esp
  return 0;
80108073:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108078:	c9                   	leave  
80108079:	c3                   	ret    

8010807a <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010807a:	55                   	push   %ebp
8010807b:	89 e5                	mov    %esp,%ebp
8010807d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108080:	83 ec 04             	sub    $0x4,%esp
80108083:	6a 00                	push   $0x0
80108085:	ff 75 0c             	push   0xc(%ebp)
80108088:	ff 75 08             	push   0x8(%ebp)
8010808b:	e8 1d f7 ff ff       	call   801077ad <walkpgdir>
80108090:	83 c4 10             	add    $0x10,%esp
80108093:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108099:	8b 00                	mov    (%eax),%eax
8010809b:	83 e0 01             	and    $0x1,%eax
8010809e:	85 c0                	test   %eax,%eax
801080a0:	75 07                	jne    801080a9 <uva2ka+0x2f>
    return 0;
801080a2:	b8 00 00 00 00       	mov    $0x0,%eax
801080a7:	eb 22                	jmp    801080cb <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
801080a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ac:	8b 00                	mov    (%eax),%eax
801080ae:	83 e0 04             	and    $0x4,%eax
801080b1:	85 c0                	test   %eax,%eax
801080b3:	75 07                	jne    801080bc <uva2ka+0x42>
    return 0;
801080b5:	b8 00 00 00 00       	mov    $0x0,%eax
801080ba:	eb 0f                	jmp    801080cb <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
801080bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080bf:	8b 00                	mov    (%eax),%eax
801080c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080c6:	05 00 00 00 80       	add    $0x80000000,%eax
}
801080cb:	c9                   	leave  
801080cc:	c3                   	ret    

801080cd <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801080cd:	55                   	push   %ebp
801080ce:	89 e5                	mov    %esp,%ebp
801080d0:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801080d3:	8b 45 10             	mov    0x10(%ebp),%eax
801080d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801080d9:	eb 7f                	jmp    8010815a <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801080db:	8b 45 0c             	mov    0xc(%ebp),%eax
801080de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801080e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080e9:	83 ec 08             	sub    $0x8,%esp
801080ec:	50                   	push   %eax
801080ed:	ff 75 08             	push   0x8(%ebp)
801080f0:	e8 85 ff ff ff       	call   8010807a <uva2ka>
801080f5:	83 c4 10             	add    $0x10,%esp
801080f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801080fb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801080ff:	75 07                	jne    80108108 <copyout+0x3b>
      return -1;
80108101:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108106:	eb 61                	jmp    80108169 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108108:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010810b:	2b 45 0c             	sub    0xc(%ebp),%eax
8010810e:	05 00 10 00 00       	add    $0x1000,%eax
80108113:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108116:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108119:	3b 45 14             	cmp    0x14(%ebp),%eax
8010811c:	76 06                	jbe    80108124 <copyout+0x57>
      n = len;
8010811e:	8b 45 14             	mov    0x14(%ebp),%eax
80108121:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108124:	8b 45 0c             	mov    0xc(%ebp),%eax
80108127:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010812a:	89 c2                	mov    %eax,%edx
8010812c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010812f:	01 d0                	add    %edx,%eax
80108131:	83 ec 04             	sub    $0x4,%esp
80108134:	ff 75 f0             	push   -0x10(%ebp)
80108137:	ff 75 f4             	push   -0xc(%ebp)
8010813a:	50                   	push   %eax
8010813b:	e8 e4 cc ff ff       	call   80104e24 <memmove>
80108140:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108143:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108146:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108149:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010814c:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010814f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108152:	05 00 10 00 00       	add    $0x1000,%eax
80108157:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010815a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010815e:	0f 85 77 ff ff ff    	jne    801080db <copyout+0xe>
  }
  return 0;
80108164:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108169:	c9                   	leave  
8010816a:	c3                   	ret    

8010816b <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
8010816b:	55                   	push   %ebp
8010816c:	89 e5                	mov    %esp,%ebp
8010816e:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108171:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108178:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010817b:	8b 40 08             	mov    0x8(%eax),%eax
8010817e:	05 00 00 00 80       	add    $0x80000000,%eax
80108183:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108186:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
8010818d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108190:	8b 40 24             	mov    0x24(%eax),%eax
80108193:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80108198:	c7 05 50 77 19 80 00 	movl   $0x0,0x80197750
8010819f:	00 00 00 

  while(i<madt->len){
801081a2:	90                   	nop
801081a3:	e9 bd 00 00 00       	jmp    80108265 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
801081a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801081ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081ae:	01 d0                	add    %edx,%eax
801081b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801081b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081b6:	0f b6 00             	movzbl (%eax),%eax
801081b9:	0f b6 c0             	movzbl %al,%eax
801081bc:	83 f8 05             	cmp    $0x5,%eax
801081bf:	0f 87 a0 00 00 00    	ja     80108265 <mpinit_uefi+0xfa>
801081c5:	8b 04 85 b0 ac 10 80 	mov    -0x7fef5350(,%eax,4),%eax
801081cc:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801081ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801081d4:	a1 50 77 19 80       	mov    0x80197750,%eax
801081d9:	83 f8 03             	cmp    $0x3,%eax
801081dc:	7f 28                	jg     80108206 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801081de:	8b 15 50 77 19 80    	mov    0x80197750,%edx
801081e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801081e7:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801081eb:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
801081f1:	81 c2 80 74 19 80    	add    $0x80197480,%edx
801081f7:	88 02                	mov    %al,(%edx)
          ncpu++;
801081f9:	a1 50 77 19 80       	mov    0x80197750,%eax
801081fe:	83 c0 01             	add    $0x1,%eax
80108201:	a3 50 77 19 80       	mov    %eax,0x80197750
        }
        i += lapic_entry->record_len;
80108206:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108209:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010820d:	0f b6 c0             	movzbl %al,%eax
80108210:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108213:	eb 50                	jmp    80108265 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108215:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108218:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010821b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010821e:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108222:	a2 54 77 19 80       	mov    %al,0x80197754
        i += ioapic->record_len;
80108227:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010822a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010822e:	0f b6 c0             	movzbl %al,%eax
80108231:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108234:	eb 2f                	jmp    80108265 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108236:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108239:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
8010823c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010823f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108243:	0f b6 c0             	movzbl %al,%eax
80108246:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108249:	eb 1a                	jmp    80108265 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
8010824b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010824e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108251:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108254:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108258:	0f b6 c0             	movzbl %al,%eax
8010825b:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010825e:	eb 05                	jmp    80108265 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80108260:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108264:	90                   	nop
  while(i<madt->len){
80108265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108268:	8b 40 04             	mov    0x4(%eax),%eax
8010826b:	39 45 fc             	cmp    %eax,-0x4(%ebp)
8010826e:	0f 82 34 ff ff ff    	jb     801081a8 <mpinit_uefi+0x3d>
    }
  }

}
80108274:	90                   	nop
80108275:	90                   	nop
80108276:	c9                   	leave  
80108277:	c3                   	ret    

80108278 <inb>:
{
80108278:	55                   	push   %ebp
80108279:	89 e5                	mov    %esp,%ebp
8010827b:	83 ec 14             	sub    $0x14,%esp
8010827e:	8b 45 08             	mov    0x8(%ebp),%eax
80108281:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108285:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108289:	89 c2                	mov    %eax,%edx
8010828b:	ec                   	in     (%dx),%al
8010828c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010828f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108293:	c9                   	leave  
80108294:	c3                   	ret    

80108295 <outb>:
{
80108295:	55                   	push   %ebp
80108296:	89 e5                	mov    %esp,%ebp
80108298:	83 ec 08             	sub    $0x8,%esp
8010829b:	8b 45 08             	mov    0x8(%ebp),%eax
8010829e:	8b 55 0c             	mov    0xc(%ebp),%edx
801082a1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801082a5:	89 d0                	mov    %edx,%eax
801082a7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801082aa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801082ae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801082b2:	ee                   	out    %al,(%dx)
}
801082b3:	90                   	nop
801082b4:	c9                   	leave  
801082b5:	c3                   	ret    

801082b6 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801082b6:	55                   	push   %ebp
801082b7:	89 e5                	mov    %esp,%ebp
801082b9:	83 ec 28             	sub    $0x28,%esp
801082bc:	8b 45 08             	mov    0x8(%ebp),%eax
801082bf:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801082c2:	6a 00                	push   $0x0
801082c4:	68 fa 03 00 00       	push   $0x3fa
801082c9:	e8 c7 ff ff ff       	call   80108295 <outb>
801082ce:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801082d1:	68 80 00 00 00       	push   $0x80
801082d6:	68 fb 03 00 00       	push   $0x3fb
801082db:	e8 b5 ff ff ff       	call   80108295 <outb>
801082e0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801082e3:	6a 0c                	push   $0xc
801082e5:	68 f8 03 00 00       	push   $0x3f8
801082ea:	e8 a6 ff ff ff       	call   80108295 <outb>
801082ef:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801082f2:	6a 00                	push   $0x0
801082f4:	68 f9 03 00 00       	push   $0x3f9
801082f9:	e8 97 ff ff ff       	call   80108295 <outb>
801082fe:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108301:	6a 03                	push   $0x3
80108303:	68 fb 03 00 00       	push   $0x3fb
80108308:	e8 88 ff ff ff       	call   80108295 <outb>
8010830d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108310:	6a 00                	push   $0x0
80108312:	68 fc 03 00 00       	push   $0x3fc
80108317:	e8 79 ff ff ff       	call   80108295 <outb>
8010831c:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010831f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108326:	eb 11                	jmp    80108339 <uart_debug+0x83>
80108328:	83 ec 0c             	sub    $0xc,%esp
8010832b:	6a 0a                	push   $0xa
8010832d:	e8 05 a8 ff ff       	call   80102b37 <microdelay>
80108332:	83 c4 10             	add    $0x10,%esp
80108335:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108339:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010833d:	7f 1a                	jg     80108359 <uart_debug+0xa3>
8010833f:	83 ec 0c             	sub    $0xc,%esp
80108342:	68 fd 03 00 00       	push   $0x3fd
80108347:	e8 2c ff ff ff       	call   80108278 <inb>
8010834c:	83 c4 10             	add    $0x10,%esp
8010834f:	0f b6 c0             	movzbl %al,%eax
80108352:	83 e0 20             	and    $0x20,%eax
80108355:	85 c0                	test   %eax,%eax
80108357:	74 cf                	je     80108328 <uart_debug+0x72>
  outb(COM1+0, p);
80108359:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010835d:	0f b6 c0             	movzbl %al,%eax
80108360:	83 ec 08             	sub    $0x8,%esp
80108363:	50                   	push   %eax
80108364:	68 f8 03 00 00       	push   $0x3f8
80108369:	e8 27 ff ff ff       	call   80108295 <outb>
8010836e:	83 c4 10             	add    $0x10,%esp
}
80108371:	90                   	nop
80108372:	c9                   	leave  
80108373:	c3                   	ret    

80108374 <uart_debugs>:

void uart_debugs(char *p){
80108374:	55                   	push   %ebp
80108375:	89 e5                	mov    %esp,%ebp
80108377:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010837a:	eb 1b                	jmp    80108397 <uart_debugs+0x23>
    uart_debug(*p++);
8010837c:	8b 45 08             	mov    0x8(%ebp),%eax
8010837f:	8d 50 01             	lea    0x1(%eax),%edx
80108382:	89 55 08             	mov    %edx,0x8(%ebp)
80108385:	0f b6 00             	movzbl (%eax),%eax
80108388:	0f be c0             	movsbl %al,%eax
8010838b:	83 ec 0c             	sub    $0xc,%esp
8010838e:	50                   	push   %eax
8010838f:	e8 22 ff ff ff       	call   801082b6 <uart_debug>
80108394:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108397:	8b 45 08             	mov    0x8(%ebp),%eax
8010839a:	0f b6 00             	movzbl (%eax),%eax
8010839d:	84 c0                	test   %al,%al
8010839f:	75 db                	jne    8010837c <uart_debugs+0x8>
  }
}
801083a1:	90                   	nop
801083a2:	90                   	nop
801083a3:	c9                   	leave  
801083a4:	c3                   	ret    

801083a5 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801083a5:	55                   	push   %ebp
801083a6:	89 e5                	mov    %esp,%ebp
801083a8:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801083ab:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801083b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083b5:	8b 50 14             	mov    0x14(%eax),%edx
801083b8:	8b 40 10             	mov    0x10(%eax),%eax
801083bb:	a3 58 77 19 80       	mov    %eax,0x80197758
  gpu.vram_size = boot_param->graphic_config.frame_size;
801083c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083c3:	8b 50 1c             	mov    0x1c(%eax),%edx
801083c6:	8b 40 18             	mov    0x18(%eax),%eax
801083c9:	a3 60 77 19 80       	mov    %eax,0x80197760
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801083ce:	8b 15 60 77 19 80    	mov    0x80197760,%edx
801083d4:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801083d9:	29 d0                	sub    %edx,%eax
801083db:	a3 5c 77 19 80       	mov    %eax,0x8019775c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801083e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083e3:	8b 50 24             	mov    0x24(%eax),%edx
801083e6:	8b 40 20             	mov    0x20(%eax),%eax
801083e9:	a3 64 77 19 80       	mov    %eax,0x80197764
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801083ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083f1:	8b 50 2c             	mov    0x2c(%eax),%edx
801083f4:	8b 40 28             	mov    0x28(%eax),%eax
801083f7:	a3 68 77 19 80       	mov    %eax,0x80197768
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801083fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083ff:	8b 50 34             	mov    0x34(%eax),%edx
80108402:	8b 40 30             	mov    0x30(%eax),%eax
80108405:	a3 6c 77 19 80       	mov    %eax,0x8019776c
}
8010840a:	90                   	nop
8010840b:	c9                   	leave  
8010840c:	c3                   	ret    

8010840d <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010840d:	55                   	push   %ebp
8010840e:	89 e5                	mov    %esp,%ebp
80108410:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108413:	8b 15 6c 77 19 80    	mov    0x8019776c,%edx
80108419:	8b 45 0c             	mov    0xc(%ebp),%eax
8010841c:	0f af d0             	imul   %eax,%edx
8010841f:	8b 45 08             	mov    0x8(%ebp),%eax
80108422:	01 d0                	add    %edx,%eax
80108424:	c1 e0 02             	shl    $0x2,%eax
80108427:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
8010842a:	8b 15 5c 77 19 80    	mov    0x8019775c,%edx
80108430:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108433:	01 d0                	add    %edx,%eax
80108435:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108438:	8b 45 10             	mov    0x10(%ebp),%eax
8010843b:	0f b6 10             	movzbl (%eax),%edx
8010843e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108441:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108443:	8b 45 10             	mov    0x10(%ebp),%eax
80108446:	0f b6 50 01          	movzbl 0x1(%eax),%edx
8010844a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010844d:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108450:	8b 45 10             	mov    0x10(%ebp),%eax
80108453:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108457:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010845a:	88 50 02             	mov    %dl,0x2(%eax)
}
8010845d:	90                   	nop
8010845e:	c9                   	leave  
8010845f:	c3                   	ret    

80108460 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108460:	55                   	push   %ebp
80108461:	89 e5                	mov    %esp,%ebp
80108463:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108466:	8b 15 6c 77 19 80    	mov    0x8019776c,%edx
8010846c:	8b 45 08             	mov    0x8(%ebp),%eax
8010846f:	0f af c2             	imul   %edx,%eax
80108472:	c1 e0 02             	shl    $0x2,%eax
80108475:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108478:	a1 60 77 19 80       	mov    0x80197760,%eax
8010847d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108480:	29 d0                	sub    %edx,%eax
80108482:	8b 0d 5c 77 19 80    	mov    0x8019775c,%ecx
80108488:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010848b:	01 ca                	add    %ecx,%edx
8010848d:	89 d1                	mov    %edx,%ecx
8010848f:	8b 15 5c 77 19 80    	mov    0x8019775c,%edx
80108495:	83 ec 04             	sub    $0x4,%esp
80108498:	50                   	push   %eax
80108499:	51                   	push   %ecx
8010849a:	52                   	push   %edx
8010849b:	e8 84 c9 ff ff       	call   80104e24 <memmove>
801084a0:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801084a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a6:	8b 0d 5c 77 19 80    	mov    0x8019775c,%ecx
801084ac:	8b 15 60 77 19 80    	mov    0x80197760,%edx
801084b2:	01 ca                	add    %ecx,%edx
801084b4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801084b7:	29 ca                	sub    %ecx,%edx
801084b9:	83 ec 04             	sub    $0x4,%esp
801084bc:	50                   	push   %eax
801084bd:	6a 00                	push   $0x0
801084bf:	52                   	push   %edx
801084c0:	e8 a0 c8 ff ff       	call   80104d65 <memset>
801084c5:	83 c4 10             	add    $0x10,%esp
}
801084c8:	90                   	nop
801084c9:	c9                   	leave  
801084ca:	c3                   	ret    

801084cb <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801084cb:	55                   	push   %ebp
801084cc:	89 e5                	mov    %esp,%ebp
801084ce:	53                   	push   %ebx
801084cf:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801084d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084d9:	e9 b1 00 00 00       	jmp    8010858f <font_render+0xc4>
    for(int j=14;j>-1;j--){
801084de:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801084e5:	e9 97 00 00 00       	jmp    80108581 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
801084ea:	8b 45 10             	mov    0x10(%ebp),%eax
801084ed:	83 e8 20             	sub    $0x20,%eax
801084f0:	6b d0 1e             	imul   $0x1e,%eax,%edx
801084f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f6:	01 d0                	add    %edx,%eax
801084f8:	0f b7 84 00 e0 ac 10 	movzwl -0x7fef5320(%eax,%eax,1),%eax
801084ff:	80 
80108500:	0f b7 d0             	movzwl %ax,%edx
80108503:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108506:	bb 01 00 00 00       	mov    $0x1,%ebx
8010850b:	89 c1                	mov    %eax,%ecx
8010850d:	d3 e3                	shl    %cl,%ebx
8010850f:	89 d8                	mov    %ebx,%eax
80108511:	21 d0                	and    %edx,%eax
80108513:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108516:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108519:	ba 01 00 00 00       	mov    $0x1,%edx
8010851e:	89 c1                	mov    %eax,%ecx
80108520:	d3 e2                	shl    %cl,%edx
80108522:	89 d0                	mov    %edx,%eax
80108524:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108527:	75 2b                	jne    80108554 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108529:	8b 55 0c             	mov    0xc(%ebp),%edx
8010852c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852f:	01 c2                	add    %eax,%edx
80108531:	b8 0e 00 00 00       	mov    $0xe,%eax
80108536:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108539:	89 c1                	mov    %eax,%ecx
8010853b:	8b 45 08             	mov    0x8(%ebp),%eax
8010853e:	01 c8                	add    %ecx,%eax
80108540:	83 ec 04             	sub    $0x4,%esp
80108543:	68 00 f5 10 80       	push   $0x8010f500
80108548:	52                   	push   %edx
80108549:	50                   	push   %eax
8010854a:	e8 be fe ff ff       	call   8010840d <graphic_draw_pixel>
8010854f:	83 c4 10             	add    $0x10,%esp
80108552:	eb 29                	jmp    8010857d <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108554:	8b 55 0c             	mov    0xc(%ebp),%edx
80108557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855a:	01 c2                	add    %eax,%edx
8010855c:	b8 0e 00 00 00       	mov    $0xe,%eax
80108561:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108564:	89 c1                	mov    %eax,%ecx
80108566:	8b 45 08             	mov    0x8(%ebp),%eax
80108569:	01 c8                	add    %ecx,%eax
8010856b:	83 ec 04             	sub    $0x4,%esp
8010856e:	68 70 77 19 80       	push   $0x80197770
80108573:	52                   	push   %edx
80108574:	50                   	push   %eax
80108575:	e8 93 fe ff ff       	call   8010840d <graphic_draw_pixel>
8010857a:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
8010857d:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108581:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108585:	0f 89 5f ff ff ff    	jns    801084ea <font_render+0x1f>
  for(int i=0;i<30;i++){
8010858b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010858f:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108593:	0f 8e 45 ff ff ff    	jle    801084de <font_render+0x13>
      }
    }
  }
}
80108599:	90                   	nop
8010859a:	90                   	nop
8010859b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010859e:	c9                   	leave  
8010859f:	c3                   	ret    

801085a0 <font_render_string>:

void font_render_string(char *string,int row){
801085a0:	55                   	push   %ebp
801085a1:	89 e5                	mov    %esp,%ebp
801085a3:	53                   	push   %ebx
801085a4:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801085a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801085ae:	eb 33                	jmp    801085e3 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801085b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085b3:	8b 45 08             	mov    0x8(%ebp),%eax
801085b6:	01 d0                	add    %edx,%eax
801085b8:	0f b6 00             	movzbl (%eax),%eax
801085bb:	0f be c8             	movsbl %al,%ecx
801085be:	8b 45 0c             	mov    0xc(%ebp),%eax
801085c1:	6b d0 1e             	imul   $0x1e,%eax,%edx
801085c4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801085c7:	89 d8                	mov    %ebx,%eax
801085c9:	c1 e0 04             	shl    $0x4,%eax
801085cc:	29 d8                	sub    %ebx,%eax
801085ce:	83 c0 02             	add    $0x2,%eax
801085d1:	83 ec 04             	sub    $0x4,%esp
801085d4:	51                   	push   %ecx
801085d5:	52                   	push   %edx
801085d6:	50                   	push   %eax
801085d7:	e8 ef fe ff ff       	call   801084cb <font_render>
801085dc:	83 c4 10             	add    $0x10,%esp
    i++;
801085df:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801085e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085e6:	8b 45 08             	mov    0x8(%ebp),%eax
801085e9:	01 d0                	add    %edx,%eax
801085eb:	0f b6 00             	movzbl (%eax),%eax
801085ee:	84 c0                	test   %al,%al
801085f0:	74 06                	je     801085f8 <font_render_string+0x58>
801085f2:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801085f6:	7e b8                	jle    801085b0 <font_render_string+0x10>
  }
}
801085f8:	90                   	nop
801085f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801085fc:	c9                   	leave  
801085fd:	c3                   	ret    

801085fe <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801085fe:	55                   	push   %ebp
801085ff:	89 e5                	mov    %esp,%ebp
80108601:	53                   	push   %ebx
80108602:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108605:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010860c:	eb 6b                	jmp    80108679 <pci_init+0x7b>
    for(int j=0;j<32;j++){
8010860e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108615:	eb 58                	jmp    8010866f <pci_init+0x71>
      for(int k=0;k<8;k++){
80108617:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010861e:	eb 45                	jmp    80108665 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108620:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108623:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108626:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108629:	83 ec 0c             	sub    $0xc,%esp
8010862c:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010862f:	53                   	push   %ebx
80108630:	6a 00                	push   $0x0
80108632:	51                   	push   %ecx
80108633:	52                   	push   %edx
80108634:	50                   	push   %eax
80108635:	e8 b0 00 00 00       	call   801086ea <pci_access_config>
8010863a:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010863d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108640:	0f b7 c0             	movzwl %ax,%eax
80108643:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108648:	74 17                	je     80108661 <pci_init+0x63>
        pci_init_device(i,j,k);
8010864a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010864d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108653:	83 ec 04             	sub    $0x4,%esp
80108656:	51                   	push   %ecx
80108657:	52                   	push   %edx
80108658:	50                   	push   %eax
80108659:	e8 37 01 00 00       	call   80108795 <pci_init_device>
8010865e:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108661:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108665:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108669:	7e b5                	jle    80108620 <pci_init+0x22>
    for(int j=0;j<32;j++){
8010866b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010866f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108673:	7e a2                	jle    80108617 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108675:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108679:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108680:	7e 8c                	jle    8010860e <pci_init+0x10>
      }
      }
    }
  }
}
80108682:	90                   	nop
80108683:	90                   	nop
80108684:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108687:	c9                   	leave  
80108688:	c3                   	ret    

80108689 <pci_write_config>:

void pci_write_config(uint config){
80108689:	55                   	push   %ebp
8010868a:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010868c:	8b 45 08             	mov    0x8(%ebp),%eax
8010868f:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108694:	89 c0                	mov    %eax,%eax
80108696:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108697:	90                   	nop
80108698:	5d                   	pop    %ebp
80108699:	c3                   	ret    

8010869a <pci_write_data>:

void pci_write_data(uint config){
8010869a:	55                   	push   %ebp
8010869b:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
8010869d:	8b 45 08             	mov    0x8(%ebp),%eax
801086a0:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801086a5:	89 c0                	mov    %eax,%eax
801086a7:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801086a8:	90                   	nop
801086a9:	5d                   	pop    %ebp
801086aa:	c3                   	ret    

801086ab <pci_read_config>:
uint pci_read_config(){
801086ab:	55                   	push   %ebp
801086ac:	89 e5                	mov    %esp,%ebp
801086ae:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801086b1:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801086b6:	ed                   	in     (%dx),%eax
801086b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801086ba:	83 ec 0c             	sub    $0xc,%esp
801086bd:	68 c8 00 00 00       	push   $0xc8
801086c2:	e8 70 a4 ff ff       	call   80102b37 <microdelay>
801086c7:	83 c4 10             	add    $0x10,%esp
  return data;
801086ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801086cd:	c9                   	leave  
801086ce:	c3                   	ret    

801086cf <pci_test>:


void pci_test(){
801086cf:	55                   	push   %ebp
801086d0:	89 e5                	mov    %esp,%ebp
801086d2:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801086d5:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801086dc:	ff 75 fc             	push   -0x4(%ebp)
801086df:	e8 a5 ff ff ff       	call   80108689 <pci_write_config>
801086e4:	83 c4 04             	add    $0x4,%esp
}
801086e7:	90                   	nop
801086e8:	c9                   	leave  
801086e9:	c3                   	ret    

801086ea <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801086ea:	55                   	push   %ebp
801086eb:	89 e5                	mov    %esp,%ebp
801086ed:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801086f0:	8b 45 08             	mov    0x8(%ebp),%eax
801086f3:	c1 e0 10             	shl    $0x10,%eax
801086f6:	25 00 00 ff 00       	and    $0xff0000,%eax
801086fb:	89 c2                	mov    %eax,%edx
801086fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108700:	c1 e0 0b             	shl    $0xb,%eax
80108703:	0f b7 c0             	movzwl %ax,%eax
80108706:	09 c2                	or     %eax,%edx
80108708:	8b 45 10             	mov    0x10(%ebp),%eax
8010870b:	c1 e0 08             	shl    $0x8,%eax
8010870e:	25 00 07 00 00       	and    $0x700,%eax
80108713:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108715:	8b 45 14             	mov    0x14(%ebp),%eax
80108718:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010871d:	09 d0                	or     %edx,%eax
8010871f:	0d 00 00 00 80       	or     $0x80000000,%eax
80108724:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108727:	ff 75 f4             	push   -0xc(%ebp)
8010872a:	e8 5a ff ff ff       	call   80108689 <pci_write_config>
8010872f:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108732:	e8 74 ff ff ff       	call   801086ab <pci_read_config>
80108737:	8b 55 18             	mov    0x18(%ebp),%edx
8010873a:	89 02                	mov    %eax,(%edx)
}
8010873c:	90                   	nop
8010873d:	c9                   	leave  
8010873e:	c3                   	ret    

8010873f <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
8010873f:	55                   	push   %ebp
80108740:	89 e5                	mov    %esp,%ebp
80108742:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108745:	8b 45 08             	mov    0x8(%ebp),%eax
80108748:	c1 e0 10             	shl    $0x10,%eax
8010874b:	25 00 00 ff 00       	and    $0xff0000,%eax
80108750:	89 c2                	mov    %eax,%edx
80108752:	8b 45 0c             	mov    0xc(%ebp),%eax
80108755:	c1 e0 0b             	shl    $0xb,%eax
80108758:	0f b7 c0             	movzwl %ax,%eax
8010875b:	09 c2                	or     %eax,%edx
8010875d:	8b 45 10             	mov    0x10(%ebp),%eax
80108760:	c1 e0 08             	shl    $0x8,%eax
80108763:	25 00 07 00 00       	and    $0x700,%eax
80108768:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010876a:	8b 45 14             	mov    0x14(%ebp),%eax
8010876d:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108772:	09 d0                	or     %edx,%eax
80108774:	0d 00 00 00 80       	or     $0x80000000,%eax
80108779:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010877c:	ff 75 fc             	push   -0x4(%ebp)
8010877f:	e8 05 ff ff ff       	call   80108689 <pci_write_config>
80108784:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108787:	ff 75 18             	push   0x18(%ebp)
8010878a:	e8 0b ff ff ff       	call   8010869a <pci_write_data>
8010878f:	83 c4 04             	add    $0x4,%esp
}
80108792:	90                   	nop
80108793:	c9                   	leave  
80108794:	c3                   	ret    

80108795 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108795:	55                   	push   %ebp
80108796:	89 e5                	mov    %esp,%ebp
80108798:	53                   	push   %ebx
80108799:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
8010879c:	8b 45 08             	mov    0x8(%ebp),%eax
8010879f:	a2 74 77 19 80       	mov    %al,0x80197774
  dev.device_num = device_num;
801087a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801087a7:	a2 75 77 19 80       	mov    %al,0x80197775
  dev.function_num = function_num;
801087ac:	8b 45 10             	mov    0x10(%ebp),%eax
801087af:	a2 76 77 19 80       	mov    %al,0x80197776
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801087b4:	ff 75 10             	push   0x10(%ebp)
801087b7:	ff 75 0c             	push   0xc(%ebp)
801087ba:	ff 75 08             	push   0x8(%ebp)
801087bd:	68 24 c3 10 80       	push   $0x8010c324
801087c2:	e8 2d 7c ff ff       	call   801003f4 <cprintf>
801087c7:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801087ca:	83 ec 0c             	sub    $0xc,%esp
801087cd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087d0:	50                   	push   %eax
801087d1:	6a 00                	push   $0x0
801087d3:	ff 75 10             	push   0x10(%ebp)
801087d6:	ff 75 0c             	push   0xc(%ebp)
801087d9:	ff 75 08             	push   0x8(%ebp)
801087dc:	e8 09 ff ff ff       	call   801086ea <pci_access_config>
801087e1:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801087e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087e7:	c1 e8 10             	shr    $0x10,%eax
801087ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801087ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087f0:	25 ff ff 00 00       	and    $0xffff,%eax
801087f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801087f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087fb:	a3 78 77 19 80       	mov    %eax,0x80197778
  dev.vendor_id = vendor_id;
80108800:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108803:	a3 7c 77 19 80       	mov    %eax,0x8019777c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108808:	83 ec 04             	sub    $0x4,%esp
8010880b:	ff 75 f0             	push   -0x10(%ebp)
8010880e:	ff 75 f4             	push   -0xc(%ebp)
80108811:	68 58 c3 10 80       	push   $0x8010c358
80108816:	e8 d9 7b ff ff       	call   801003f4 <cprintf>
8010881b:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010881e:	83 ec 0c             	sub    $0xc,%esp
80108821:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108824:	50                   	push   %eax
80108825:	6a 08                	push   $0x8
80108827:	ff 75 10             	push   0x10(%ebp)
8010882a:	ff 75 0c             	push   0xc(%ebp)
8010882d:	ff 75 08             	push   0x8(%ebp)
80108830:	e8 b5 fe ff ff       	call   801086ea <pci_access_config>
80108835:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108838:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010883b:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010883e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108841:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108844:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108847:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010884a:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010884d:	0f b6 c0             	movzbl %al,%eax
80108850:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108853:	c1 eb 18             	shr    $0x18,%ebx
80108856:	83 ec 0c             	sub    $0xc,%esp
80108859:	51                   	push   %ecx
8010885a:	52                   	push   %edx
8010885b:	50                   	push   %eax
8010885c:	53                   	push   %ebx
8010885d:	68 7c c3 10 80       	push   $0x8010c37c
80108862:	e8 8d 7b ff ff       	call   801003f4 <cprintf>
80108867:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
8010886a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010886d:	c1 e8 18             	shr    $0x18,%eax
80108870:	a2 80 77 19 80       	mov    %al,0x80197780
  dev.sub_class = (data>>16)&0xFF;
80108875:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108878:	c1 e8 10             	shr    $0x10,%eax
8010887b:	a2 81 77 19 80       	mov    %al,0x80197781
  dev.interface = (data>>8)&0xFF;
80108880:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108883:	c1 e8 08             	shr    $0x8,%eax
80108886:	a2 82 77 19 80       	mov    %al,0x80197782
  dev.revision_id = data&0xFF;
8010888b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010888e:	a2 83 77 19 80       	mov    %al,0x80197783
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108893:	83 ec 0c             	sub    $0xc,%esp
80108896:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108899:	50                   	push   %eax
8010889a:	6a 10                	push   $0x10
8010889c:	ff 75 10             	push   0x10(%ebp)
8010889f:	ff 75 0c             	push   0xc(%ebp)
801088a2:	ff 75 08             	push   0x8(%ebp)
801088a5:	e8 40 fe ff ff       	call   801086ea <pci_access_config>
801088aa:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801088ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088b0:	a3 84 77 19 80       	mov    %eax,0x80197784
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801088b5:	83 ec 0c             	sub    $0xc,%esp
801088b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801088bb:	50                   	push   %eax
801088bc:	6a 14                	push   $0x14
801088be:	ff 75 10             	push   0x10(%ebp)
801088c1:	ff 75 0c             	push   0xc(%ebp)
801088c4:	ff 75 08             	push   0x8(%ebp)
801088c7:	e8 1e fe ff ff       	call   801086ea <pci_access_config>
801088cc:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801088cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088d2:	a3 88 77 19 80       	mov    %eax,0x80197788
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801088d7:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801088de:	75 5a                	jne    8010893a <pci_init_device+0x1a5>
801088e0:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801088e7:	75 51                	jne    8010893a <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801088e9:	83 ec 0c             	sub    $0xc,%esp
801088ec:	68 c1 c3 10 80       	push   $0x8010c3c1
801088f1:	e8 fe 7a ff ff       	call   801003f4 <cprintf>
801088f6:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801088f9:	83 ec 0c             	sub    $0xc,%esp
801088fc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801088ff:	50                   	push   %eax
80108900:	68 f0 00 00 00       	push   $0xf0
80108905:	ff 75 10             	push   0x10(%ebp)
80108908:	ff 75 0c             	push   0xc(%ebp)
8010890b:	ff 75 08             	push   0x8(%ebp)
8010890e:	e8 d7 fd ff ff       	call   801086ea <pci_access_config>
80108913:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108916:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108919:	83 ec 08             	sub    $0x8,%esp
8010891c:	50                   	push   %eax
8010891d:	68 db c3 10 80       	push   $0x8010c3db
80108922:	e8 cd 7a ff ff       	call   801003f4 <cprintf>
80108927:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
8010892a:	83 ec 0c             	sub    $0xc,%esp
8010892d:	68 74 77 19 80       	push   $0x80197774
80108932:	e8 09 00 00 00       	call   80108940 <i8254_init>
80108937:	83 c4 10             	add    $0x10,%esp
  }
}
8010893a:	90                   	nop
8010893b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010893e:	c9                   	leave  
8010893f:	c3                   	ret    

80108940 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108940:	55                   	push   %ebp
80108941:	89 e5                	mov    %esp,%ebp
80108943:	53                   	push   %ebx
80108944:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108947:	8b 45 08             	mov    0x8(%ebp),%eax
8010894a:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010894e:	0f b6 c8             	movzbl %al,%ecx
80108951:	8b 45 08             	mov    0x8(%ebp),%eax
80108954:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108958:	0f b6 d0             	movzbl %al,%edx
8010895b:	8b 45 08             	mov    0x8(%ebp),%eax
8010895e:	0f b6 00             	movzbl (%eax),%eax
80108961:	0f b6 c0             	movzbl %al,%eax
80108964:	83 ec 0c             	sub    $0xc,%esp
80108967:	8d 5d ec             	lea    -0x14(%ebp),%ebx
8010896a:	53                   	push   %ebx
8010896b:	6a 04                	push   $0x4
8010896d:	51                   	push   %ecx
8010896e:	52                   	push   %edx
8010896f:	50                   	push   %eax
80108970:	e8 75 fd ff ff       	call   801086ea <pci_access_config>
80108975:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108978:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010897b:	83 c8 04             	or     $0x4,%eax
8010897e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108981:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108984:	8b 45 08             	mov    0x8(%ebp),%eax
80108987:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010898b:	0f b6 c8             	movzbl %al,%ecx
8010898e:	8b 45 08             	mov    0x8(%ebp),%eax
80108991:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108995:	0f b6 d0             	movzbl %al,%edx
80108998:	8b 45 08             	mov    0x8(%ebp),%eax
8010899b:	0f b6 00             	movzbl (%eax),%eax
8010899e:	0f b6 c0             	movzbl %al,%eax
801089a1:	83 ec 0c             	sub    $0xc,%esp
801089a4:	53                   	push   %ebx
801089a5:	6a 04                	push   $0x4
801089a7:	51                   	push   %ecx
801089a8:	52                   	push   %edx
801089a9:	50                   	push   %eax
801089aa:	e8 90 fd ff ff       	call   8010873f <pci_write_config_register>
801089af:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801089b2:	8b 45 08             	mov    0x8(%ebp),%eax
801089b5:	8b 40 10             	mov    0x10(%eax),%eax
801089b8:	05 00 00 00 40       	add    $0x40000000,%eax
801089bd:	a3 8c 77 19 80       	mov    %eax,0x8019778c
  uint *ctrl = (uint *)base_addr;
801089c2:	a1 8c 77 19 80       	mov    0x8019778c,%eax
801089c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801089ca:	a1 8c 77 19 80       	mov    0x8019778c,%eax
801089cf:	05 d8 00 00 00       	add    $0xd8,%eax
801089d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801089d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089da:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801089e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e3:	8b 00                	mov    (%eax),%eax
801089e5:	0d 00 00 00 04       	or     $0x4000000,%eax
801089ea:	89 c2                	mov    %eax,%edx
801089ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ef:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801089f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089f4:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801089fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089fd:	8b 00                	mov    (%eax),%eax
801089ff:	83 c8 40             	or     $0x40,%eax
80108a02:	89 c2                	mov    %eax,%edx
80108a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a07:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a0c:	8b 10                	mov    (%eax),%edx
80108a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a11:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108a13:	83 ec 0c             	sub    $0xc,%esp
80108a16:	68 f0 c3 10 80       	push   $0x8010c3f0
80108a1b:	e8 d4 79 ff ff       	call   801003f4 <cprintf>
80108a20:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108a23:	e8 78 9d ff ff       	call   801027a0 <kalloc>
80108a28:	a3 98 77 19 80       	mov    %eax,0x80197798
  *intr_addr = 0;
80108a2d:	a1 98 77 19 80       	mov    0x80197798,%eax
80108a32:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108a38:	a1 98 77 19 80       	mov    0x80197798,%eax
80108a3d:	83 ec 08             	sub    $0x8,%esp
80108a40:	50                   	push   %eax
80108a41:	68 12 c4 10 80       	push   $0x8010c412
80108a46:	e8 a9 79 ff ff       	call   801003f4 <cprintf>
80108a4b:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108a4e:	e8 50 00 00 00       	call   80108aa3 <i8254_init_recv>
  i8254_init_send();
80108a53:	e8 69 03 00 00       	call   80108dc1 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108a58:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a5f:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108a62:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a69:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108a6c:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a73:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108a76:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a7d:	0f b6 c0             	movzbl %al,%eax
80108a80:	83 ec 0c             	sub    $0xc,%esp
80108a83:	53                   	push   %ebx
80108a84:	51                   	push   %ecx
80108a85:	52                   	push   %edx
80108a86:	50                   	push   %eax
80108a87:	68 20 c4 10 80       	push   $0x8010c420
80108a8c:	e8 63 79 ff ff       	call   801003f4 <cprintf>
80108a91:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a97:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108a9d:	90                   	nop
80108a9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108aa1:	c9                   	leave  
80108aa2:	c3                   	ret    

80108aa3 <i8254_init_recv>:

void i8254_init_recv(){
80108aa3:	55                   	push   %ebp
80108aa4:	89 e5                	mov    %esp,%ebp
80108aa6:	57                   	push   %edi
80108aa7:	56                   	push   %esi
80108aa8:	53                   	push   %ebx
80108aa9:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108aac:	83 ec 0c             	sub    $0xc,%esp
80108aaf:	6a 00                	push   $0x0
80108ab1:	e8 e8 04 00 00       	call   80108f9e <i8254_read_eeprom>
80108ab6:	83 c4 10             	add    $0x10,%esp
80108ab9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108abc:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108abf:	a2 90 77 19 80       	mov    %al,0x80197790
  mac_addr[1] = data_l>>8;
80108ac4:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108ac7:	c1 e8 08             	shr    $0x8,%eax
80108aca:	a2 91 77 19 80       	mov    %al,0x80197791
  uint data_m = i8254_read_eeprom(0x1);
80108acf:	83 ec 0c             	sub    $0xc,%esp
80108ad2:	6a 01                	push   $0x1
80108ad4:	e8 c5 04 00 00       	call   80108f9e <i8254_read_eeprom>
80108ad9:	83 c4 10             	add    $0x10,%esp
80108adc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108adf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ae2:	a2 92 77 19 80       	mov    %al,0x80197792
  mac_addr[3] = data_m>>8;
80108ae7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108aea:	c1 e8 08             	shr    $0x8,%eax
80108aed:	a2 93 77 19 80       	mov    %al,0x80197793
  uint data_h = i8254_read_eeprom(0x2);
80108af2:	83 ec 0c             	sub    $0xc,%esp
80108af5:	6a 02                	push   $0x2
80108af7:	e8 a2 04 00 00       	call   80108f9e <i8254_read_eeprom>
80108afc:	83 c4 10             	add    $0x10,%esp
80108aff:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108b02:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b05:	a2 94 77 19 80       	mov    %al,0x80197794
  mac_addr[5] = data_h>>8;
80108b0a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b0d:	c1 e8 08             	shr    $0x8,%eax
80108b10:	a2 95 77 19 80       	mov    %al,0x80197795
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108b15:	0f b6 05 95 77 19 80 	movzbl 0x80197795,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b1c:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108b1f:	0f b6 05 94 77 19 80 	movzbl 0x80197794,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b26:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108b29:	0f b6 05 93 77 19 80 	movzbl 0x80197793,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b30:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108b33:	0f b6 05 92 77 19 80 	movzbl 0x80197792,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b3a:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108b3d:	0f b6 05 91 77 19 80 	movzbl 0x80197791,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b44:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108b47:	0f b6 05 90 77 19 80 	movzbl 0x80197790,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b4e:	0f b6 c0             	movzbl %al,%eax
80108b51:	83 ec 04             	sub    $0x4,%esp
80108b54:	57                   	push   %edi
80108b55:	56                   	push   %esi
80108b56:	53                   	push   %ebx
80108b57:	51                   	push   %ecx
80108b58:	52                   	push   %edx
80108b59:	50                   	push   %eax
80108b5a:	68 38 c4 10 80       	push   $0x8010c438
80108b5f:	e8 90 78 ff ff       	call   801003f4 <cprintf>
80108b64:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108b67:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b6c:	05 00 54 00 00       	add    $0x5400,%eax
80108b71:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108b74:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b79:	05 04 54 00 00       	add    $0x5404,%eax
80108b7e:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108b81:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b84:	c1 e0 10             	shl    $0x10,%eax
80108b87:	0b 45 d8             	or     -0x28(%ebp),%eax
80108b8a:	89 c2                	mov    %eax,%edx
80108b8c:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108b8f:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108b91:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b94:	0d 00 00 00 80       	or     $0x80000000,%eax
80108b99:	89 c2                	mov    %eax,%edx
80108b9b:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108b9e:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108ba0:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108ba5:	05 00 52 00 00       	add    $0x5200,%eax
80108baa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108bad:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108bb4:	eb 19                	jmp    80108bcf <i8254_init_recv+0x12c>
    mta[i] = 0;
80108bb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108bb9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108bc0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108bc3:	01 d0                	add    %edx,%eax
80108bc5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108bcb:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108bcf:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108bd3:	7e e1                	jle    80108bb6 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108bd5:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108bda:	05 d0 00 00 00       	add    $0xd0,%eax
80108bdf:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108be2:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108be5:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108beb:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108bf0:	05 c8 00 00 00       	add    $0xc8,%eax
80108bf5:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108bf8:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108bfb:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108c01:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108c06:	05 28 28 00 00       	add    $0x2828,%eax
80108c0b:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108c0e:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108c11:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108c17:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108c1c:	05 00 01 00 00       	add    $0x100,%eax
80108c21:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108c24:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108c27:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108c2d:	e8 6e 9b ff ff       	call   801027a0 <kalloc>
80108c32:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108c35:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108c3a:	05 00 28 00 00       	add    $0x2800,%eax
80108c3f:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108c42:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108c47:	05 04 28 00 00       	add    $0x2804,%eax
80108c4c:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108c4f:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108c54:	05 08 28 00 00       	add    $0x2808,%eax
80108c59:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108c5c:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108c61:	05 10 28 00 00       	add    $0x2810,%eax
80108c66:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108c69:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108c6e:	05 18 28 00 00       	add    $0x2818,%eax
80108c73:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108c76:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108c79:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108c7f:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108c82:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108c84:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108c87:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108c8d:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108c90:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108c96:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108c99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108c9f:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108ca2:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108ca8:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108cab:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108cae:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108cb5:	eb 73                	jmp    80108d2a <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108cb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cba:	c1 e0 04             	shl    $0x4,%eax
80108cbd:	89 c2                	mov    %eax,%edx
80108cbf:	8b 45 98             	mov    -0x68(%ebp),%eax
80108cc2:	01 d0                	add    %edx,%eax
80108cc4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108ccb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cce:	c1 e0 04             	shl    $0x4,%eax
80108cd1:	89 c2                	mov    %eax,%edx
80108cd3:	8b 45 98             	mov    -0x68(%ebp),%eax
80108cd6:	01 d0                	add    %edx,%eax
80108cd8:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108cde:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ce1:	c1 e0 04             	shl    $0x4,%eax
80108ce4:	89 c2                	mov    %eax,%edx
80108ce6:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ce9:	01 d0                	add    %edx,%eax
80108ceb:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108cf1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cf4:	c1 e0 04             	shl    $0x4,%eax
80108cf7:	89 c2                	mov    %eax,%edx
80108cf9:	8b 45 98             	mov    -0x68(%ebp),%eax
80108cfc:	01 d0                	add    %edx,%eax
80108cfe:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108d02:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d05:	c1 e0 04             	shl    $0x4,%eax
80108d08:	89 c2                	mov    %eax,%edx
80108d0a:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d0d:	01 d0                	add    %edx,%eax
80108d0f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108d13:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d16:	c1 e0 04             	shl    $0x4,%eax
80108d19:	89 c2                	mov    %eax,%edx
80108d1b:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d1e:	01 d0                	add    %edx,%eax
80108d20:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108d26:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108d2a:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108d31:	7e 84                	jle    80108cb7 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108d33:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108d3a:	eb 57                	jmp    80108d93 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108d3c:	e8 5f 9a ff ff       	call   801027a0 <kalloc>
80108d41:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108d44:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108d48:	75 12                	jne    80108d5c <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108d4a:	83 ec 0c             	sub    $0xc,%esp
80108d4d:	68 58 c4 10 80       	push   $0x8010c458
80108d52:	e8 9d 76 ff ff       	call   801003f4 <cprintf>
80108d57:	83 c4 10             	add    $0x10,%esp
      break;
80108d5a:	eb 3d                	jmp    80108d99 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108d5c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108d5f:	c1 e0 04             	shl    $0x4,%eax
80108d62:	89 c2                	mov    %eax,%edx
80108d64:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d67:	01 d0                	add    %edx,%eax
80108d69:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108d6c:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108d72:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108d74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108d77:	83 c0 01             	add    $0x1,%eax
80108d7a:	c1 e0 04             	shl    $0x4,%eax
80108d7d:	89 c2                	mov    %eax,%edx
80108d7f:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d82:	01 d0                	add    %edx,%eax
80108d84:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108d87:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108d8d:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108d8f:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108d93:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108d97:	7e a3                	jle    80108d3c <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108d99:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d9c:	8b 00                	mov    (%eax),%eax
80108d9e:	83 c8 02             	or     $0x2,%eax
80108da1:	89 c2                	mov    %eax,%edx
80108da3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108da6:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108da8:	83 ec 0c             	sub    $0xc,%esp
80108dab:	68 78 c4 10 80       	push   $0x8010c478
80108db0:	e8 3f 76 ff ff       	call   801003f4 <cprintf>
80108db5:	83 c4 10             	add    $0x10,%esp
}
80108db8:	90                   	nop
80108db9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108dbc:	5b                   	pop    %ebx
80108dbd:	5e                   	pop    %esi
80108dbe:	5f                   	pop    %edi
80108dbf:	5d                   	pop    %ebp
80108dc0:	c3                   	ret    

80108dc1 <i8254_init_send>:

void i8254_init_send(){
80108dc1:	55                   	push   %ebp
80108dc2:	89 e5                	mov    %esp,%ebp
80108dc4:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108dc7:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108dcc:	05 28 38 00 00       	add    $0x3828,%eax
80108dd1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108dd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dd7:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108ddd:	e8 be 99 ff ff       	call   801027a0 <kalloc>
80108de2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108de5:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108dea:	05 00 38 00 00       	add    $0x3800,%eax
80108def:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108df2:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108df7:	05 04 38 00 00       	add    $0x3804,%eax
80108dfc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108dff:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108e04:	05 08 38 00 00       	add    $0x3808,%eax
80108e09:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108e0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e0f:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108e15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e18:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108e1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e1d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108e23:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e26:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108e2c:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108e31:	05 10 38 00 00       	add    $0x3810,%eax
80108e36:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108e39:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108e3e:	05 18 38 00 00       	add    $0x3818,%eax
80108e43:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108e46:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108e49:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108e4f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e52:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108e58:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e5b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108e5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e65:	e9 82 00 00 00       	jmp    80108eec <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e6d:	c1 e0 04             	shl    $0x4,%eax
80108e70:	89 c2                	mov    %eax,%edx
80108e72:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e75:	01 d0                	add    %edx,%eax
80108e77:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e81:	c1 e0 04             	shl    $0x4,%eax
80108e84:	89 c2                	mov    %eax,%edx
80108e86:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e89:	01 d0                	add    %edx,%eax
80108e8b:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e94:	c1 e0 04             	shl    $0x4,%eax
80108e97:	89 c2                	mov    %eax,%edx
80108e99:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e9c:	01 d0                	add    %edx,%eax
80108e9e:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ea5:	c1 e0 04             	shl    $0x4,%eax
80108ea8:	89 c2                	mov    %eax,%edx
80108eaa:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ead:	01 d0                	add    %edx,%eax
80108eaf:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eb6:	c1 e0 04             	shl    $0x4,%eax
80108eb9:	89 c2                	mov    %eax,%edx
80108ebb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ebe:	01 d0                	add    %edx,%eax
80108ec0:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ec7:	c1 e0 04             	shl    $0x4,%eax
80108eca:	89 c2                	mov    %eax,%edx
80108ecc:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ecf:	01 d0                	add    %edx,%eax
80108ed1:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ed8:	c1 e0 04             	shl    $0x4,%eax
80108edb:	89 c2                	mov    %eax,%edx
80108edd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ee0:	01 d0                	add    %edx,%eax
80108ee2:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108ee8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108eec:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108ef3:	0f 8e 71 ff ff ff    	jle    80108e6a <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108ef9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108f00:	eb 57                	jmp    80108f59 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108f02:	e8 99 98 ff ff       	call   801027a0 <kalloc>
80108f07:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108f0a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108f0e:	75 12                	jne    80108f22 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108f10:	83 ec 0c             	sub    $0xc,%esp
80108f13:	68 58 c4 10 80       	push   $0x8010c458
80108f18:	e8 d7 74 ff ff       	call   801003f4 <cprintf>
80108f1d:	83 c4 10             	add    $0x10,%esp
      break;
80108f20:	eb 3d                	jmp    80108f5f <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108f22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f25:	c1 e0 04             	shl    $0x4,%eax
80108f28:	89 c2                	mov    %eax,%edx
80108f2a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f2d:	01 d0                	add    %edx,%eax
80108f2f:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108f32:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108f38:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108f3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f3d:	83 c0 01             	add    $0x1,%eax
80108f40:	c1 e0 04             	shl    $0x4,%eax
80108f43:	89 c2                	mov    %eax,%edx
80108f45:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f48:	01 d0                	add    %edx,%eax
80108f4a:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108f4d:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108f53:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108f55:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108f59:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108f5d:	7e a3                	jle    80108f02 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108f5f:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108f64:	05 00 04 00 00       	add    $0x400,%eax
80108f69:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108f6c:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108f6f:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108f75:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108f7a:	05 10 04 00 00       	add    $0x410,%eax
80108f7f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108f82:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108f85:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108f8b:	83 ec 0c             	sub    $0xc,%esp
80108f8e:	68 98 c4 10 80       	push   $0x8010c498
80108f93:	e8 5c 74 ff ff       	call   801003f4 <cprintf>
80108f98:	83 c4 10             	add    $0x10,%esp

}
80108f9b:	90                   	nop
80108f9c:	c9                   	leave  
80108f9d:	c3                   	ret    

80108f9e <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108f9e:	55                   	push   %ebp
80108f9f:	89 e5                	mov    %esp,%ebp
80108fa1:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108fa4:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108fa9:	83 c0 14             	add    $0x14,%eax
80108fac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108faf:	8b 45 08             	mov    0x8(%ebp),%eax
80108fb2:	c1 e0 08             	shl    $0x8,%eax
80108fb5:	0f b7 c0             	movzwl %ax,%eax
80108fb8:	83 c8 01             	or     $0x1,%eax
80108fbb:	89 c2                	mov    %eax,%edx
80108fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc0:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108fc2:	83 ec 0c             	sub    $0xc,%esp
80108fc5:	68 b8 c4 10 80       	push   $0x8010c4b8
80108fca:	e8 25 74 ff ff       	call   801003f4 <cprintf>
80108fcf:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fd5:	8b 00                	mov    (%eax),%eax
80108fd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108fda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fdd:	83 e0 10             	and    $0x10,%eax
80108fe0:	85 c0                	test   %eax,%eax
80108fe2:	75 02                	jne    80108fe6 <i8254_read_eeprom+0x48>
  while(1){
80108fe4:	eb dc                	jmp    80108fc2 <i8254_read_eeprom+0x24>
      break;
80108fe6:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fea:	8b 00                	mov    (%eax),%eax
80108fec:	c1 e8 10             	shr    $0x10,%eax
}
80108fef:	c9                   	leave  
80108ff0:	c3                   	ret    

80108ff1 <i8254_recv>:
void i8254_recv(){
80108ff1:	55                   	push   %ebp
80108ff2:	89 e5                	mov    %esp,%ebp
80108ff4:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108ff7:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108ffc:	05 10 28 00 00       	add    $0x2810,%eax
80109001:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109004:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80109009:	05 18 28 00 00       	add    $0x2818,%eax
8010900e:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109011:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80109016:	05 00 28 00 00       	add    $0x2800,%eax
8010901b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
8010901e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109021:	8b 00                	mov    (%eax),%eax
80109023:	05 00 00 00 80       	add    $0x80000000,%eax
80109028:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
8010902b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010902e:	8b 10                	mov    (%eax),%edx
80109030:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109033:	8b 08                	mov    (%eax),%ecx
80109035:	89 d0                	mov    %edx,%eax
80109037:	29 c8                	sub    %ecx,%eax
80109039:	25 ff 00 00 00       	and    $0xff,%eax
8010903e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109041:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109045:	7e 37                	jle    8010907e <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109047:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010904a:	8b 00                	mov    (%eax),%eax
8010904c:	c1 e0 04             	shl    $0x4,%eax
8010904f:	89 c2                	mov    %eax,%edx
80109051:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109054:	01 d0                	add    %edx,%eax
80109056:	8b 00                	mov    (%eax),%eax
80109058:	05 00 00 00 80       	add    $0x80000000,%eax
8010905d:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109060:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109063:	8b 00                	mov    (%eax),%eax
80109065:	83 c0 01             	add    $0x1,%eax
80109068:	0f b6 d0             	movzbl %al,%edx
8010906b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010906e:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109070:	83 ec 0c             	sub    $0xc,%esp
80109073:	ff 75 e0             	push   -0x20(%ebp)
80109076:	e8 15 09 00 00       	call   80109990 <eth_proc>
8010907b:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
8010907e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109081:	8b 10                	mov    (%eax),%edx
80109083:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109086:	8b 00                	mov    (%eax),%eax
80109088:	39 c2                	cmp    %eax,%edx
8010908a:	75 9f                	jne    8010902b <i8254_recv+0x3a>
      (*rdt)--;
8010908c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010908f:	8b 00                	mov    (%eax),%eax
80109091:	8d 50 ff             	lea    -0x1(%eax),%edx
80109094:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109097:	89 10                	mov    %edx,(%eax)
  while(1){
80109099:	eb 90                	jmp    8010902b <i8254_recv+0x3a>

8010909b <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010909b:	55                   	push   %ebp
8010909c:	89 e5                	mov    %esp,%ebp
8010909e:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
801090a1:	a1 8c 77 19 80       	mov    0x8019778c,%eax
801090a6:	05 10 38 00 00       	add    $0x3810,%eax
801090ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801090ae:	a1 8c 77 19 80       	mov    0x8019778c,%eax
801090b3:	05 18 38 00 00       	add    $0x3818,%eax
801090b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801090bb:	a1 8c 77 19 80       	mov    0x8019778c,%eax
801090c0:	05 00 38 00 00       	add    $0x3800,%eax
801090c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801090c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090cb:	8b 00                	mov    (%eax),%eax
801090cd:	05 00 00 00 80       	add    $0x80000000,%eax
801090d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801090d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090d8:	8b 10                	mov    (%eax),%edx
801090da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090dd:	8b 08                	mov    (%eax),%ecx
801090df:	89 d0                	mov    %edx,%eax
801090e1:	29 c8                	sub    %ecx,%eax
801090e3:	0f b6 d0             	movzbl %al,%edx
801090e6:	b8 00 01 00 00       	mov    $0x100,%eax
801090eb:	29 d0                	sub    %edx,%eax
801090ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801090f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090f3:	8b 00                	mov    (%eax),%eax
801090f5:	25 ff 00 00 00       	and    $0xff,%eax
801090fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801090fd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109101:	0f 8e a8 00 00 00    	jle    801091af <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109107:	8b 45 08             	mov    0x8(%ebp),%eax
8010910a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010910d:	89 d1                	mov    %edx,%ecx
8010910f:	c1 e1 04             	shl    $0x4,%ecx
80109112:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109115:	01 ca                	add    %ecx,%edx
80109117:	8b 12                	mov    (%edx),%edx
80109119:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010911f:	83 ec 04             	sub    $0x4,%esp
80109122:	ff 75 0c             	push   0xc(%ebp)
80109125:	50                   	push   %eax
80109126:	52                   	push   %edx
80109127:	e8 f8 bc ff ff       	call   80104e24 <memmove>
8010912c:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
8010912f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109132:	c1 e0 04             	shl    $0x4,%eax
80109135:	89 c2                	mov    %eax,%edx
80109137:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010913a:	01 d0                	add    %edx,%eax
8010913c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010913f:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109143:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109146:	c1 e0 04             	shl    $0x4,%eax
80109149:	89 c2                	mov    %eax,%edx
8010914b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010914e:	01 d0                	add    %edx,%eax
80109150:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109154:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109157:	c1 e0 04             	shl    $0x4,%eax
8010915a:	89 c2                	mov    %eax,%edx
8010915c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010915f:	01 d0                	add    %edx,%eax
80109161:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109165:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109168:	c1 e0 04             	shl    $0x4,%eax
8010916b:	89 c2                	mov    %eax,%edx
8010916d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109170:	01 d0                	add    %edx,%eax
80109172:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109176:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109179:	c1 e0 04             	shl    $0x4,%eax
8010917c:	89 c2                	mov    %eax,%edx
8010917e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109181:	01 d0                	add    %edx,%eax
80109183:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109189:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010918c:	c1 e0 04             	shl    $0x4,%eax
8010918f:	89 c2                	mov    %eax,%edx
80109191:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109194:	01 d0                	add    %edx,%eax
80109196:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
8010919a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010919d:	8b 00                	mov    (%eax),%eax
8010919f:	83 c0 01             	add    $0x1,%eax
801091a2:	0f b6 d0             	movzbl %al,%edx
801091a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091a8:	89 10                	mov    %edx,(%eax)
    return len;
801091aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801091ad:	eb 05                	jmp    801091b4 <i8254_send+0x119>
  }else{
    return -1;
801091af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801091b4:	c9                   	leave  
801091b5:	c3                   	ret    

801091b6 <i8254_intr>:

void i8254_intr(){
801091b6:	55                   	push   %ebp
801091b7:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801091b9:	a1 98 77 19 80       	mov    0x80197798,%eax
801091be:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801091c4:	90                   	nop
801091c5:	5d                   	pop    %ebp
801091c6:	c3                   	ret    

801091c7 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801091c7:	55                   	push   %ebp
801091c8:	89 e5                	mov    %esp,%ebp
801091ca:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801091cd:	8b 45 08             	mov    0x8(%ebp),%eax
801091d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801091d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d6:	0f b7 00             	movzwl (%eax),%eax
801091d9:	66 3d 00 01          	cmp    $0x100,%ax
801091dd:	74 0a                	je     801091e9 <arp_proc+0x22>
801091df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091e4:	e9 4f 01 00 00       	jmp    80109338 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801091e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ec:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801091f0:	66 83 f8 08          	cmp    $0x8,%ax
801091f4:	74 0a                	je     80109200 <arp_proc+0x39>
801091f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091fb:	e9 38 01 00 00       	jmp    80109338 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80109200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109203:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109207:	3c 06                	cmp    $0x6,%al
80109209:	74 0a                	je     80109215 <arp_proc+0x4e>
8010920b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109210:	e9 23 01 00 00       	jmp    80109338 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109218:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010921c:	3c 04                	cmp    $0x4,%al
8010921e:	74 0a                	je     8010922a <arp_proc+0x63>
80109220:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109225:	e9 0e 01 00 00       	jmp    80109338 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
8010922a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010922d:	83 c0 18             	add    $0x18,%eax
80109230:	83 ec 04             	sub    $0x4,%esp
80109233:	6a 04                	push   $0x4
80109235:	50                   	push   %eax
80109236:	68 04 f5 10 80       	push   $0x8010f504
8010923b:	e8 8c bb ff ff       	call   80104dcc <memcmp>
80109240:	83 c4 10             	add    $0x10,%esp
80109243:	85 c0                	test   %eax,%eax
80109245:	74 27                	je     8010926e <arp_proc+0xa7>
80109247:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010924a:	83 c0 0e             	add    $0xe,%eax
8010924d:	83 ec 04             	sub    $0x4,%esp
80109250:	6a 04                	push   $0x4
80109252:	50                   	push   %eax
80109253:	68 04 f5 10 80       	push   $0x8010f504
80109258:	e8 6f bb ff ff       	call   80104dcc <memcmp>
8010925d:	83 c4 10             	add    $0x10,%esp
80109260:	85 c0                	test   %eax,%eax
80109262:	74 0a                	je     8010926e <arp_proc+0xa7>
80109264:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109269:	e9 ca 00 00 00       	jmp    80109338 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010926e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109271:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109275:	66 3d 00 01          	cmp    $0x100,%ax
80109279:	75 69                	jne    801092e4 <arp_proc+0x11d>
8010927b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010927e:	83 c0 18             	add    $0x18,%eax
80109281:	83 ec 04             	sub    $0x4,%esp
80109284:	6a 04                	push   $0x4
80109286:	50                   	push   %eax
80109287:	68 04 f5 10 80       	push   $0x8010f504
8010928c:	e8 3b bb ff ff       	call   80104dcc <memcmp>
80109291:	83 c4 10             	add    $0x10,%esp
80109294:	85 c0                	test   %eax,%eax
80109296:	75 4c                	jne    801092e4 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109298:	e8 03 95 ff ff       	call   801027a0 <kalloc>
8010929d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801092a0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801092a7:	83 ec 04             	sub    $0x4,%esp
801092aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
801092ad:	50                   	push   %eax
801092ae:	ff 75 f0             	push   -0x10(%ebp)
801092b1:	ff 75 f4             	push   -0xc(%ebp)
801092b4:	e8 1f 04 00 00       	call   801096d8 <arp_reply_pkt_create>
801092b9:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801092bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092bf:	83 ec 08             	sub    $0x8,%esp
801092c2:	50                   	push   %eax
801092c3:	ff 75 f0             	push   -0x10(%ebp)
801092c6:	e8 d0 fd ff ff       	call   8010909b <i8254_send>
801092cb:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801092ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092d1:	83 ec 0c             	sub    $0xc,%esp
801092d4:	50                   	push   %eax
801092d5:	e8 2c 94 ff ff       	call   80102706 <kfree>
801092da:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801092dd:	b8 02 00 00 00       	mov    $0x2,%eax
801092e2:	eb 54                	jmp    80109338 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801092e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092e7:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801092eb:	66 3d 00 02          	cmp    $0x200,%ax
801092ef:	75 42                	jne    80109333 <arp_proc+0x16c>
801092f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f4:	83 c0 18             	add    $0x18,%eax
801092f7:	83 ec 04             	sub    $0x4,%esp
801092fa:	6a 04                	push   $0x4
801092fc:	50                   	push   %eax
801092fd:	68 04 f5 10 80       	push   $0x8010f504
80109302:	e8 c5 ba ff ff       	call   80104dcc <memcmp>
80109307:	83 c4 10             	add    $0x10,%esp
8010930a:	85 c0                	test   %eax,%eax
8010930c:	75 25                	jne    80109333 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
8010930e:	83 ec 0c             	sub    $0xc,%esp
80109311:	68 bc c4 10 80       	push   $0x8010c4bc
80109316:	e8 d9 70 ff ff       	call   801003f4 <cprintf>
8010931b:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010931e:	83 ec 0c             	sub    $0xc,%esp
80109321:	ff 75 f4             	push   -0xc(%ebp)
80109324:	e8 af 01 00 00       	call   801094d8 <arp_table_update>
80109329:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
8010932c:	b8 01 00 00 00       	mov    $0x1,%eax
80109331:	eb 05                	jmp    80109338 <arp_proc+0x171>
  }else{
    return -1;
80109333:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109338:	c9                   	leave  
80109339:	c3                   	ret    

8010933a <arp_scan>:

void arp_scan(){
8010933a:	55                   	push   %ebp
8010933b:	89 e5                	mov    %esp,%ebp
8010933d:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109340:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109347:	eb 6f                	jmp    801093b8 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109349:	e8 52 94 ff ff       	call   801027a0 <kalloc>
8010934e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109351:	83 ec 04             	sub    $0x4,%esp
80109354:	ff 75 f4             	push   -0xc(%ebp)
80109357:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010935a:	50                   	push   %eax
8010935b:	ff 75 ec             	push   -0x14(%ebp)
8010935e:	e8 62 00 00 00       	call   801093c5 <arp_broadcast>
80109363:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109366:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109369:	83 ec 08             	sub    $0x8,%esp
8010936c:	50                   	push   %eax
8010936d:	ff 75 ec             	push   -0x14(%ebp)
80109370:	e8 26 fd ff ff       	call   8010909b <i8254_send>
80109375:	83 c4 10             	add    $0x10,%esp
80109378:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010937b:	eb 22                	jmp    8010939f <arp_scan+0x65>
      microdelay(1);
8010937d:	83 ec 0c             	sub    $0xc,%esp
80109380:	6a 01                	push   $0x1
80109382:	e8 b0 97 ff ff       	call   80102b37 <microdelay>
80109387:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010938a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010938d:	83 ec 08             	sub    $0x8,%esp
80109390:	50                   	push   %eax
80109391:	ff 75 ec             	push   -0x14(%ebp)
80109394:	e8 02 fd ff ff       	call   8010909b <i8254_send>
80109399:	83 c4 10             	add    $0x10,%esp
8010939c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010939f:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801093a3:	74 d8                	je     8010937d <arp_scan+0x43>
    }
    kfree((char *)send);
801093a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093a8:	83 ec 0c             	sub    $0xc,%esp
801093ab:	50                   	push   %eax
801093ac:	e8 55 93 ff ff       	call   80102706 <kfree>
801093b1:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801093b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801093b8:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801093bf:	7e 88                	jle    80109349 <arp_scan+0xf>
  }
}
801093c1:	90                   	nop
801093c2:	90                   	nop
801093c3:	c9                   	leave  
801093c4:	c3                   	ret    

801093c5 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801093c5:	55                   	push   %ebp
801093c6:	89 e5                	mov    %esp,%ebp
801093c8:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801093cb:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801093cf:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801093d3:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801093d7:	8b 45 10             	mov    0x10(%ebp),%eax
801093da:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801093dd:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801093e4:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801093ea:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801093f1:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801093f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801093fa:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109400:	8b 45 08             	mov    0x8(%ebp),%eax
80109403:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109406:	8b 45 08             	mov    0x8(%ebp),%eax
80109409:	83 c0 0e             	add    $0xe,%eax
8010940c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010940f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109412:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109416:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109419:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
8010941d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109420:	83 ec 04             	sub    $0x4,%esp
80109423:	6a 06                	push   $0x6
80109425:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109428:	52                   	push   %edx
80109429:	50                   	push   %eax
8010942a:	e8 f5 b9 ff ff       	call   80104e24 <memmove>
8010942f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109432:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109435:	83 c0 06             	add    $0x6,%eax
80109438:	83 ec 04             	sub    $0x4,%esp
8010943b:	6a 06                	push   $0x6
8010943d:	68 90 77 19 80       	push   $0x80197790
80109442:	50                   	push   %eax
80109443:	e8 dc b9 ff ff       	call   80104e24 <memmove>
80109448:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010944b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010944e:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109453:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109456:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010945c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010945f:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109463:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109466:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
8010946a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010946d:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109473:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109476:	8d 50 12             	lea    0x12(%eax),%edx
80109479:	83 ec 04             	sub    $0x4,%esp
8010947c:	6a 06                	push   $0x6
8010947e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109481:	50                   	push   %eax
80109482:	52                   	push   %edx
80109483:	e8 9c b9 ff ff       	call   80104e24 <memmove>
80109488:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
8010948b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010948e:	8d 50 18             	lea    0x18(%eax),%edx
80109491:	83 ec 04             	sub    $0x4,%esp
80109494:	6a 04                	push   $0x4
80109496:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109499:	50                   	push   %eax
8010949a:	52                   	push   %edx
8010949b:	e8 84 b9 ff ff       	call   80104e24 <memmove>
801094a0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801094a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094a6:	83 c0 08             	add    $0x8,%eax
801094a9:	83 ec 04             	sub    $0x4,%esp
801094ac:	6a 06                	push   $0x6
801094ae:	68 90 77 19 80       	push   $0x80197790
801094b3:	50                   	push   %eax
801094b4:	e8 6b b9 ff ff       	call   80104e24 <memmove>
801094b9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801094bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094bf:	83 c0 0e             	add    $0xe,%eax
801094c2:	83 ec 04             	sub    $0x4,%esp
801094c5:	6a 04                	push   $0x4
801094c7:	68 04 f5 10 80       	push   $0x8010f504
801094cc:	50                   	push   %eax
801094cd:	e8 52 b9 ff ff       	call   80104e24 <memmove>
801094d2:	83 c4 10             	add    $0x10,%esp
}
801094d5:	90                   	nop
801094d6:	c9                   	leave  
801094d7:	c3                   	ret    

801094d8 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801094d8:	55                   	push   %ebp
801094d9:	89 e5                	mov    %esp,%ebp
801094db:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801094de:	8b 45 08             	mov    0x8(%ebp),%eax
801094e1:	83 c0 0e             	add    $0xe,%eax
801094e4:	83 ec 0c             	sub    $0xc,%esp
801094e7:	50                   	push   %eax
801094e8:	e8 bc 00 00 00       	call   801095a9 <arp_table_search>
801094ed:	83 c4 10             	add    $0x10,%esp
801094f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801094f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801094f7:	78 2d                	js     80109526 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801094f9:	8b 45 08             	mov    0x8(%ebp),%eax
801094fc:	8d 48 08             	lea    0x8(%eax),%ecx
801094ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109502:	89 d0                	mov    %edx,%eax
80109504:	c1 e0 02             	shl    $0x2,%eax
80109507:	01 d0                	add    %edx,%eax
80109509:	01 c0                	add    %eax,%eax
8010950b:	01 d0                	add    %edx,%eax
8010950d:	05 a0 77 19 80       	add    $0x801977a0,%eax
80109512:	83 c0 04             	add    $0x4,%eax
80109515:	83 ec 04             	sub    $0x4,%esp
80109518:	6a 06                	push   $0x6
8010951a:	51                   	push   %ecx
8010951b:	50                   	push   %eax
8010951c:	e8 03 b9 ff ff       	call   80104e24 <memmove>
80109521:	83 c4 10             	add    $0x10,%esp
80109524:	eb 70                	jmp    80109596 <arp_table_update+0xbe>
  }else{
    index += 1;
80109526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
8010952a:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010952d:	8b 45 08             	mov    0x8(%ebp),%eax
80109530:	8d 48 08             	lea    0x8(%eax),%ecx
80109533:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109536:	89 d0                	mov    %edx,%eax
80109538:	c1 e0 02             	shl    $0x2,%eax
8010953b:	01 d0                	add    %edx,%eax
8010953d:	01 c0                	add    %eax,%eax
8010953f:	01 d0                	add    %edx,%eax
80109541:	05 a0 77 19 80       	add    $0x801977a0,%eax
80109546:	83 c0 04             	add    $0x4,%eax
80109549:	83 ec 04             	sub    $0x4,%esp
8010954c:	6a 06                	push   $0x6
8010954e:	51                   	push   %ecx
8010954f:	50                   	push   %eax
80109550:	e8 cf b8 ff ff       	call   80104e24 <memmove>
80109555:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109558:	8b 45 08             	mov    0x8(%ebp),%eax
8010955b:	8d 48 0e             	lea    0xe(%eax),%ecx
8010955e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109561:	89 d0                	mov    %edx,%eax
80109563:	c1 e0 02             	shl    $0x2,%eax
80109566:	01 d0                	add    %edx,%eax
80109568:	01 c0                	add    %eax,%eax
8010956a:	01 d0                	add    %edx,%eax
8010956c:	05 a0 77 19 80       	add    $0x801977a0,%eax
80109571:	83 ec 04             	sub    $0x4,%esp
80109574:	6a 04                	push   $0x4
80109576:	51                   	push   %ecx
80109577:	50                   	push   %eax
80109578:	e8 a7 b8 ff ff       	call   80104e24 <memmove>
8010957d:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109580:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109583:	89 d0                	mov    %edx,%eax
80109585:	c1 e0 02             	shl    $0x2,%eax
80109588:	01 d0                	add    %edx,%eax
8010958a:	01 c0                	add    %eax,%eax
8010958c:	01 d0                	add    %edx,%eax
8010958e:	05 aa 77 19 80       	add    $0x801977aa,%eax
80109593:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109596:	83 ec 0c             	sub    $0xc,%esp
80109599:	68 a0 77 19 80       	push   $0x801977a0
8010959e:	e8 83 00 00 00       	call   80109626 <print_arp_table>
801095a3:	83 c4 10             	add    $0x10,%esp
}
801095a6:	90                   	nop
801095a7:	c9                   	leave  
801095a8:	c3                   	ret    

801095a9 <arp_table_search>:

int arp_table_search(uchar *ip){
801095a9:	55                   	push   %ebp
801095aa:	89 e5                	mov    %esp,%ebp
801095ac:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801095af:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801095b6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801095bd:	eb 59                	jmp    80109618 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801095bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095c2:	89 d0                	mov    %edx,%eax
801095c4:	c1 e0 02             	shl    $0x2,%eax
801095c7:	01 d0                	add    %edx,%eax
801095c9:	01 c0                	add    %eax,%eax
801095cb:	01 d0                	add    %edx,%eax
801095cd:	05 a0 77 19 80       	add    $0x801977a0,%eax
801095d2:	83 ec 04             	sub    $0x4,%esp
801095d5:	6a 04                	push   $0x4
801095d7:	ff 75 08             	push   0x8(%ebp)
801095da:	50                   	push   %eax
801095db:	e8 ec b7 ff ff       	call   80104dcc <memcmp>
801095e0:	83 c4 10             	add    $0x10,%esp
801095e3:	85 c0                	test   %eax,%eax
801095e5:	75 05                	jne    801095ec <arp_table_search+0x43>
      return i;
801095e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095ea:	eb 38                	jmp    80109624 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801095ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095ef:	89 d0                	mov    %edx,%eax
801095f1:	c1 e0 02             	shl    $0x2,%eax
801095f4:	01 d0                	add    %edx,%eax
801095f6:	01 c0                	add    %eax,%eax
801095f8:	01 d0                	add    %edx,%eax
801095fa:	05 aa 77 19 80       	add    $0x801977aa,%eax
801095ff:	0f b6 00             	movzbl (%eax),%eax
80109602:	84 c0                	test   %al,%al
80109604:	75 0e                	jne    80109614 <arp_table_search+0x6b>
80109606:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010960a:	75 08                	jne    80109614 <arp_table_search+0x6b>
      empty = -i;
8010960c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010960f:	f7 d8                	neg    %eax
80109611:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109614:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109618:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010961c:	7e a1                	jle    801095bf <arp_table_search+0x16>
    }
  }
  return empty-1;
8010961e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109621:	83 e8 01             	sub    $0x1,%eax
}
80109624:	c9                   	leave  
80109625:	c3                   	ret    

80109626 <print_arp_table>:

void print_arp_table(){
80109626:	55                   	push   %ebp
80109627:	89 e5                	mov    %esp,%ebp
80109629:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010962c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109633:	e9 92 00 00 00       	jmp    801096ca <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109638:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010963b:	89 d0                	mov    %edx,%eax
8010963d:	c1 e0 02             	shl    $0x2,%eax
80109640:	01 d0                	add    %edx,%eax
80109642:	01 c0                	add    %eax,%eax
80109644:	01 d0                	add    %edx,%eax
80109646:	05 aa 77 19 80       	add    $0x801977aa,%eax
8010964b:	0f b6 00             	movzbl (%eax),%eax
8010964e:	84 c0                	test   %al,%al
80109650:	74 74                	je     801096c6 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109652:	83 ec 08             	sub    $0x8,%esp
80109655:	ff 75 f4             	push   -0xc(%ebp)
80109658:	68 cf c4 10 80       	push   $0x8010c4cf
8010965d:	e8 92 6d ff ff       	call   801003f4 <cprintf>
80109662:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109665:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109668:	89 d0                	mov    %edx,%eax
8010966a:	c1 e0 02             	shl    $0x2,%eax
8010966d:	01 d0                	add    %edx,%eax
8010966f:	01 c0                	add    %eax,%eax
80109671:	01 d0                	add    %edx,%eax
80109673:	05 a0 77 19 80       	add    $0x801977a0,%eax
80109678:	83 ec 0c             	sub    $0xc,%esp
8010967b:	50                   	push   %eax
8010967c:	e8 54 02 00 00       	call   801098d5 <print_ipv4>
80109681:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109684:	83 ec 0c             	sub    $0xc,%esp
80109687:	68 de c4 10 80       	push   $0x8010c4de
8010968c:	e8 63 6d ff ff       	call   801003f4 <cprintf>
80109691:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109694:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109697:	89 d0                	mov    %edx,%eax
80109699:	c1 e0 02             	shl    $0x2,%eax
8010969c:	01 d0                	add    %edx,%eax
8010969e:	01 c0                	add    %eax,%eax
801096a0:	01 d0                	add    %edx,%eax
801096a2:	05 a0 77 19 80       	add    $0x801977a0,%eax
801096a7:	83 c0 04             	add    $0x4,%eax
801096aa:	83 ec 0c             	sub    $0xc,%esp
801096ad:	50                   	push   %eax
801096ae:	e8 70 02 00 00       	call   80109923 <print_mac>
801096b3:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801096b6:	83 ec 0c             	sub    $0xc,%esp
801096b9:	68 e0 c4 10 80       	push   $0x8010c4e0
801096be:	e8 31 6d ff ff       	call   801003f4 <cprintf>
801096c3:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801096c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801096ca:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801096ce:	0f 8e 64 ff ff ff    	jle    80109638 <print_arp_table+0x12>
    }
  }
}
801096d4:	90                   	nop
801096d5:	90                   	nop
801096d6:	c9                   	leave  
801096d7:	c3                   	ret    

801096d8 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801096d8:	55                   	push   %ebp
801096d9:	89 e5                	mov    %esp,%ebp
801096db:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801096de:	8b 45 10             	mov    0x10(%ebp),%eax
801096e1:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801096e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801096ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801096ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801096f0:	83 c0 0e             	add    $0xe,%eax
801096f3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801096f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096f9:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801096fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109700:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109704:	8b 45 08             	mov    0x8(%ebp),%eax
80109707:	8d 50 08             	lea    0x8(%eax),%edx
8010970a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010970d:	83 ec 04             	sub    $0x4,%esp
80109710:	6a 06                	push   $0x6
80109712:	52                   	push   %edx
80109713:	50                   	push   %eax
80109714:	e8 0b b7 ff ff       	call   80104e24 <memmove>
80109719:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010971c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010971f:	83 c0 06             	add    $0x6,%eax
80109722:	83 ec 04             	sub    $0x4,%esp
80109725:	6a 06                	push   $0x6
80109727:	68 90 77 19 80       	push   $0x80197790
8010972c:	50                   	push   %eax
8010972d:	e8 f2 b6 ff ff       	call   80104e24 <memmove>
80109732:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109735:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109738:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010973d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109740:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109746:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109749:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010974d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109750:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109754:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109757:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010975d:	8b 45 08             	mov    0x8(%ebp),%eax
80109760:	8d 50 08             	lea    0x8(%eax),%edx
80109763:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109766:	83 c0 12             	add    $0x12,%eax
80109769:	83 ec 04             	sub    $0x4,%esp
8010976c:	6a 06                	push   $0x6
8010976e:	52                   	push   %edx
8010976f:	50                   	push   %eax
80109770:	e8 af b6 ff ff       	call   80104e24 <memmove>
80109775:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109778:	8b 45 08             	mov    0x8(%ebp),%eax
8010977b:	8d 50 0e             	lea    0xe(%eax),%edx
8010977e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109781:	83 c0 18             	add    $0x18,%eax
80109784:	83 ec 04             	sub    $0x4,%esp
80109787:	6a 04                	push   $0x4
80109789:	52                   	push   %edx
8010978a:	50                   	push   %eax
8010978b:	e8 94 b6 ff ff       	call   80104e24 <memmove>
80109790:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109793:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109796:	83 c0 08             	add    $0x8,%eax
80109799:	83 ec 04             	sub    $0x4,%esp
8010979c:	6a 06                	push   $0x6
8010979e:	68 90 77 19 80       	push   $0x80197790
801097a3:	50                   	push   %eax
801097a4:	e8 7b b6 ff ff       	call   80104e24 <memmove>
801097a9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801097ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097af:	83 c0 0e             	add    $0xe,%eax
801097b2:	83 ec 04             	sub    $0x4,%esp
801097b5:	6a 04                	push   $0x4
801097b7:	68 04 f5 10 80       	push   $0x8010f504
801097bc:	50                   	push   %eax
801097bd:	e8 62 b6 ff ff       	call   80104e24 <memmove>
801097c2:	83 c4 10             	add    $0x10,%esp
}
801097c5:	90                   	nop
801097c6:	c9                   	leave  
801097c7:	c3                   	ret    

801097c8 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801097c8:	55                   	push   %ebp
801097c9:	89 e5                	mov    %esp,%ebp
801097cb:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801097ce:	83 ec 0c             	sub    $0xc,%esp
801097d1:	68 e2 c4 10 80       	push   $0x8010c4e2
801097d6:	e8 19 6c ff ff       	call   801003f4 <cprintf>
801097db:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801097de:	8b 45 08             	mov    0x8(%ebp),%eax
801097e1:	83 c0 0e             	add    $0xe,%eax
801097e4:	83 ec 0c             	sub    $0xc,%esp
801097e7:	50                   	push   %eax
801097e8:	e8 e8 00 00 00       	call   801098d5 <print_ipv4>
801097ed:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801097f0:	83 ec 0c             	sub    $0xc,%esp
801097f3:	68 e0 c4 10 80       	push   $0x8010c4e0
801097f8:	e8 f7 6b ff ff       	call   801003f4 <cprintf>
801097fd:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109800:	8b 45 08             	mov    0x8(%ebp),%eax
80109803:	83 c0 08             	add    $0x8,%eax
80109806:	83 ec 0c             	sub    $0xc,%esp
80109809:	50                   	push   %eax
8010980a:	e8 14 01 00 00       	call   80109923 <print_mac>
8010980f:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109812:	83 ec 0c             	sub    $0xc,%esp
80109815:	68 e0 c4 10 80       	push   $0x8010c4e0
8010981a:	e8 d5 6b ff ff       	call   801003f4 <cprintf>
8010981f:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109822:	83 ec 0c             	sub    $0xc,%esp
80109825:	68 f9 c4 10 80       	push   $0x8010c4f9
8010982a:	e8 c5 6b ff ff       	call   801003f4 <cprintf>
8010982f:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109832:	8b 45 08             	mov    0x8(%ebp),%eax
80109835:	83 c0 18             	add    $0x18,%eax
80109838:	83 ec 0c             	sub    $0xc,%esp
8010983b:	50                   	push   %eax
8010983c:	e8 94 00 00 00       	call   801098d5 <print_ipv4>
80109841:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109844:	83 ec 0c             	sub    $0xc,%esp
80109847:	68 e0 c4 10 80       	push   $0x8010c4e0
8010984c:	e8 a3 6b ff ff       	call   801003f4 <cprintf>
80109851:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109854:	8b 45 08             	mov    0x8(%ebp),%eax
80109857:	83 c0 12             	add    $0x12,%eax
8010985a:	83 ec 0c             	sub    $0xc,%esp
8010985d:	50                   	push   %eax
8010985e:	e8 c0 00 00 00       	call   80109923 <print_mac>
80109863:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109866:	83 ec 0c             	sub    $0xc,%esp
80109869:	68 e0 c4 10 80       	push   $0x8010c4e0
8010986e:	e8 81 6b ff ff       	call   801003f4 <cprintf>
80109873:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109876:	83 ec 0c             	sub    $0xc,%esp
80109879:	68 10 c5 10 80       	push   $0x8010c510
8010987e:	e8 71 6b ff ff       	call   801003f4 <cprintf>
80109883:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109886:	8b 45 08             	mov    0x8(%ebp),%eax
80109889:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010988d:	66 3d 00 01          	cmp    $0x100,%ax
80109891:	75 12                	jne    801098a5 <print_arp_info+0xdd>
80109893:	83 ec 0c             	sub    $0xc,%esp
80109896:	68 1c c5 10 80       	push   $0x8010c51c
8010989b:	e8 54 6b ff ff       	call   801003f4 <cprintf>
801098a0:	83 c4 10             	add    $0x10,%esp
801098a3:	eb 1d                	jmp    801098c2 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801098a5:	8b 45 08             	mov    0x8(%ebp),%eax
801098a8:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801098ac:	66 3d 00 02          	cmp    $0x200,%ax
801098b0:	75 10                	jne    801098c2 <print_arp_info+0xfa>
    cprintf("Reply\n");
801098b2:	83 ec 0c             	sub    $0xc,%esp
801098b5:	68 25 c5 10 80       	push   $0x8010c525
801098ba:	e8 35 6b ff ff       	call   801003f4 <cprintf>
801098bf:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801098c2:	83 ec 0c             	sub    $0xc,%esp
801098c5:	68 e0 c4 10 80       	push   $0x8010c4e0
801098ca:	e8 25 6b ff ff       	call   801003f4 <cprintf>
801098cf:	83 c4 10             	add    $0x10,%esp
}
801098d2:	90                   	nop
801098d3:	c9                   	leave  
801098d4:	c3                   	ret    

801098d5 <print_ipv4>:

void print_ipv4(uchar *ip){
801098d5:	55                   	push   %ebp
801098d6:	89 e5                	mov    %esp,%ebp
801098d8:	53                   	push   %ebx
801098d9:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801098dc:	8b 45 08             	mov    0x8(%ebp),%eax
801098df:	83 c0 03             	add    $0x3,%eax
801098e2:	0f b6 00             	movzbl (%eax),%eax
801098e5:	0f b6 d8             	movzbl %al,%ebx
801098e8:	8b 45 08             	mov    0x8(%ebp),%eax
801098eb:	83 c0 02             	add    $0x2,%eax
801098ee:	0f b6 00             	movzbl (%eax),%eax
801098f1:	0f b6 c8             	movzbl %al,%ecx
801098f4:	8b 45 08             	mov    0x8(%ebp),%eax
801098f7:	83 c0 01             	add    $0x1,%eax
801098fa:	0f b6 00             	movzbl (%eax),%eax
801098fd:	0f b6 d0             	movzbl %al,%edx
80109900:	8b 45 08             	mov    0x8(%ebp),%eax
80109903:	0f b6 00             	movzbl (%eax),%eax
80109906:	0f b6 c0             	movzbl %al,%eax
80109909:	83 ec 0c             	sub    $0xc,%esp
8010990c:	53                   	push   %ebx
8010990d:	51                   	push   %ecx
8010990e:	52                   	push   %edx
8010990f:	50                   	push   %eax
80109910:	68 2c c5 10 80       	push   $0x8010c52c
80109915:	e8 da 6a ff ff       	call   801003f4 <cprintf>
8010991a:	83 c4 20             	add    $0x20,%esp
}
8010991d:	90                   	nop
8010991e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109921:	c9                   	leave  
80109922:	c3                   	ret    

80109923 <print_mac>:

void print_mac(uchar *mac){
80109923:	55                   	push   %ebp
80109924:	89 e5                	mov    %esp,%ebp
80109926:	57                   	push   %edi
80109927:	56                   	push   %esi
80109928:	53                   	push   %ebx
80109929:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010992c:	8b 45 08             	mov    0x8(%ebp),%eax
8010992f:	83 c0 05             	add    $0x5,%eax
80109932:	0f b6 00             	movzbl (%eax),%eax
80109935:	0f b6 f8             	movzbl %al,%edi
80109938:	8b 45 08             	mov    0x8(%ebp),%eax
8010993b:	83 c0 04             	add    $0x4,%eax
8010993e:	0f b6 00             	movzbl (%eax),%eax
80109941:	0f b6 f0             	movzbl %al,%esi
80109944:	8b 45 08             	mov    0x8(%ebp),%eax
80109947:	83 c0 03             	add    $0x3,%eax
8010994a:	0f b6 00             	movzbl (%eax),%eax
8010994d:	0f b6 d8             	movzbl %al,%ebx
80109950:	8b 45 08             	mov    0x8(%ebp),%eax
80109953:	83 c0 02             	add    $0x2,%eax
80109956:	0f b6 00             	movzbl (%eax),%eax
80109959:	0f b6 c8             	movzbl %al,%ecx
8010995c:	8b 45 08             	mov    0x8(%ebp),%eax
8010995f:	83 c0 01             	add    $0x1,%eax
80109962:	0f b6 00             	movzbl (%eax),%eax
80109965:	0f b6 d0             	movzbl %al,%edx
80109968:	8b 45 08             	mov    0x8(%ebp),%eax
8010996b:	0f b6 00             	movzbl (%eax),%eax
8010996e:	0f b6 c0             	movzbl %al,%eax
80109971:	83 ec 04             	sub    $0x4,%esp
80109974:	57                   	push   %edi
80109975:	56                   	push   %esi
80109976:	53                   	push   %ebx
80109977:	51                   	push   %ecx
80109978:	52                   	push   %edx
80109979:	50                   	push   %eax
8010997a:	68 44 c5 10 80       	push   $0x8010c544
8010997f:	e8 70 6a ff ff       	call   801003f4 <cprintf>
80109984:	83 c4 20             	add    $0x20,%esp
}
80109987:	90                   	nop
80109988:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010998b:	5b                   	pop    %ebx
8010998c:	5e                   	pop    %esi
8010998d:	5f                   	pop    %edi
8010998e:	5d                   	pop    %ebp
8010998f:	c3                   	ret    

80109990 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109990:	55                   	push   %ebp
80109991:	89 e5                	mov    %esp,%ebp
80109993:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109996:	8b 45 08             	mov    0x8(%ebp),%eax
80109999:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
8010999c:	8b 45 08             	mov    0x8(%ebp),%eax
8010999f:	83 c0 0e             	add    $0xe,%eax
801099a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801099a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099a8:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801099ac:	3c 08                	cmp    $0x8,%al
801099ae:	75 1b                	jne    801099cb <eth_proc+0x3b>
801099b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099b3:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801099b7:	3c 06                	cmp    $0x6,%al
801099b9:	75 10                	jne    801099cb <eth_proc+0x3b>
    arp_proc(pkt_addr);
801099bb:	83 ec 0c             	sub    $0xc,%esp
801099be:	ff 75 f0             	push   -0x10(%ebp)
801099c1:	e8 01 f8 ff ff       	call   801091c7 <arp_proc>
801099c6:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801099c9:	eb 24                	jmp    801099ef <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801099cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099ce:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801099d2:	3c 08                	cmp    $0x8,%al
801099d4:	75 19                	jne    801099ef <eth_proc+0x5f>
801099d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d9:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801099dd:	84 c0                	test   %al,%al
801099df:	75 0e                	jne    801099ef <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801099e1:	83 ec 0c             	sub    $0xc,%esp
801099e4:	ff 75 08             	push   0x8(%ebp)
801099e7:	e8 a3 00 00 00       	call   80109a8f <ipv4_proc>
801099ec:	83 c4 10             	add    $0x10,%esp
}
801099ef:	90                   	nop
801099f0:	c9                   	leave  
801099f1:	c3                   	ret    

801099f2 <N2H_ushort>:

ushort N2H_ushort(ushort value){
801099f2:	55                   	push   %ebp
801099f3:	89 e5                	mov    %esp,%ebp
801099f5:	83 ec 04             	sub    $0x4,%esp
801099f8:	8b 45 08             	mov    0x8(%ebp),%eax
801099fb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801099ff:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a03:	c1 e0 08             	shl    $0x8,%eax
80109a06:	89 c2                	mov    %eax,%edx
80109a08:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a0c:	66 c1 e8 08          	shr    $0x8,%ax
80109a10:	01 d0                	add    %edx,%eax
}
80109a12:	c9                   	leave  
80109a13:	c3                   	ret    

80109a14 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109a14:	55                   	push   %ebp
80109a15:	89 e5                	mov    %esp,%ebp
80109a17:	83 ec 04             	sub    $0x4,%esp
80109a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80109a1d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109a21:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a25:	c1 e0 08             	shl    $0x8,%eax
80109a28:	89 c2                	mov    %eax,%edx
80109a2a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a2e:	66 c1 e8 08          	shr    $0x8,%ax
80109a32:	01 d0                	add    %edx,%eax
}
80109a34:	c9                   	leave  
80109a35:	c3                   	ret    

80109a36 <H2N_uint>:

uint H2N_uint(uint value){
80109a36:	55                   	push   %ebp
80109a37:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109a39:	8b 45 08             	mov    0x8(%ebp),%eax
80109a3c:	c1 e0 18             	shl    $0x18,%eax
80109a3f:	25 00 00 00 0f       	and    $0xf000000,%eax
80109a44:	89 c2                	mov    %eax,%edx
80109a46:	8b 45 08             	mov    0x8(%ebp),%eax
80109a49:	c1 e0 08             	shl    $0x8,%eax
80109a4c:	25 00 f0 00 00       	and    $0xf000,%eax
80109a51:	09 c2                	or     %eax,%edx
80109a53:	8b 45 08             	mov    0x8(%ebp),%eax
80109a56:	c1 e8 08             	shr    $0x8,%eax
80109a59:	83 e0 0f             	and    $0xf,%eax
80109a5c:	01 d0                	add    %edx,%eax
}
80109a5e:	5d                   	pop    %ebp
80109a5f:	c3                   	ret    

80109a60 <N2H_uint>:

uint N2H_uint(uint value){
80109a60:	55                   	push   %ebp
80109a61:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109a63:	8b 45 08             	mov    0x8(%ebp),%eax
80109a66:	c1 e0 18             	shl    $0x18,%eax
80109a69:	89 c2                	mov    %eax,%edx
80109a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80109a6e:	c1 e0 08             	shl    $0x8,%eax
80109a71:	25 00 00 ff 00       	and    $0xff0000,%eax
80109a76:	01 c2                	add    %eax,%edx
80109a78:	8b 45 08             	mov    0x8(%ebp),%eax
80109a7b:	c1 e8 08             	shr    $0x8,%eax
80109a7e:	25 00 ff 00 00       	and    $0xff00,%eax
80109a83:	01 c2                	add    %eax,%edx
80109a85:	8b 45 08             	mov    0x8(%ebp),%eax
80109a88:	c1 e8 18             	shr    $0x18,%eax
80109a8b:	01 d0                	add    %edx,%eax
}
80109a8d:	5d                   	pop    %ebp
80109a8e:	c3                   	ret    

80109a8f <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109a8f:	55                   	push   %ebp
80109a90:	89 e5                	mov    %esp,%ebp
80109a92:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109a95:	8b 45 08             	mov    0x8(%ebp),%eax
80109a98:	83 c0 0e             	add    $0xe,%eax
80109a9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aa1:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109aa5:	0f b7 d0             	movzwl %ax,%edx
80109aa8:	a1 08 f5 10 80       	mov    0x8010f508,%eax
80109aad:	39 c2                	cmp    %eax,%edx
80109aaf:	74 60                	je     80109b11 <ipv4_proc+0x82>
80109ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ab4:	83 c0 0c             	add    $0xc,%eax
80109ab7:	83 ec 04             	sub    $0x4,%esp
80109aba:	6a 04                	push   $0x4
80109abc:	50                   	push   %eax
80109abd:	68 04 f5 10 80       	push   $0x8010f504
80109ac2:	e8 05 b3 ff ff       	call   80104dcc <memcmp>
80109ac7:	83 c4 10             	add    $0x10,%esp
80109aca:	85 c0                	test   %eax,%eax
80109acc:	74 43                	je     80109b11 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ad1:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109ad5:	0f b7 c0             	movzwl %ax,%eax
80109ad8:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ae0:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109ae4:	3c 01                	cmp    $0x1,%al
80109ae6:	75 10                	jne    80109af8 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109ae8:	83 ec 0c             	sub    $0xc,%esp
80109aeb:	ff 75 08             	push   0x8(%ebp)
80109aee:	e8 a3 00 00 00       	call   80109b96 <icmp_proc>
80109af3:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109af6:	eb 19                	jmp    80109b11 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109afb:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109aff:	3c 06                	cmp    $0x6,%al
80109b01:	75 0e                	jne    80109b11 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109b03:	83 ec 0c             	sub    $0xc,%esp
80109b06:	ff 75 08             	push   0x8(%ebp)
80109b09:	e8 b3 03 00 00       	call   80109ec1 <tcp_proc>
80109b0e:	83 c4 10             	add    $0x10,%esp
}
80109b11:	90                   	nop
80109b12:	c9                   	leave  
80109b13:	c3                   	ret    

80109b14 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109b14:	55                   	push   %ebp
80109b15:	89 e5                	mov    %esp,%ebp
80109b17:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80109b1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b23:	0f b6 00             	movzbl (%eax),%eax
80109b26:	83 e0 0f             	and    $0xf,%eax
80109b29:	01 c0                	add    %eax,%eax
80109b2b:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109b2e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109b35:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109b3c:	eb 48                	jmp    80109b86 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109b3e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b41:	01 c0                	add    %eax,%eax
80109b43:	89 c2                	mov    %eax,%edx
80109b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b48:	01 d0                	add    %edx,%eax
80109b4a:	0f b6 00             	movzbl (%eax),%eax
80109b4d:	0f b6 c0             	movzbl %al,%eax
80109b50:	c1 e0 08             	shl    $0x8,%eax
80109b53:	89 c2                	mov    %eax,%edx
80109b55:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b58:	01 c0                	add    %eax,%eax
80109b5a:	8d 48 01             	lea    0x1(%eax),%ecx
80109b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b60:	01 c8                	add    %ecx,%eax
80109b62:	0f b6 00             	movzbl (%eax),%eax
80109b65:	0f b6 c0             	movzbl %al,%eax
80109b68:	01 d0                	add    %edx,%eax
80109b6a:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109b6d:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109b74:	76 0c                	jbe    80109b82 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109b76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b79:	0f b7 c0             	movzwl %ax,%eax
80109b7c:	83 c0 01             	add    $0x1,%eax
80109b7f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109b82:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109b86:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109b8a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109b8d:	7c af                	jl     80109b3e <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109b8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b92:	f7 d0                	not    %eax
}
80109b94:	c9                   	leave  
80109b95:	c3                   	ret    

80109b96 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109b96:	55                   	push   %ebp
80109b97:	89 e5                	mov    %esp,%ebp
80109b99:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80109b9f:	83 c0 0e             	add    $0xe,%eax
80109ba2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ba8:	0f b6 00             	movzbl (%eax),%eax
80109bab:	0f b6 c0             	movzbl %al,%eax
80109bae:	83 e0 0f             	and    $0xf,%eax
80109bb1:	c1 e0 02             	shl    $0x2,%eax
80109bb4:	89 c2                	mov    %eax,%edx
80109bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bb9:	01 d0                	add    %edx,%eax
80109bbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109bbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bc1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109bc5:	84 c0                	test   %al,%al
80109bc7:	75 4f                	jne    80109c18 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bcc:	0f b6 00             	movzbl (%eax),%eax
80109bcf:	3c 08                	cmp    $0x8,%al
80109bd1:	75 45                	jne    80109c18 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109bd3:	e8 c8 8b ff ff       	call   801027a0 <kalloc>
80109bd8:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109bdb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109be2:	83 ec 04             	sub    $0x4,%esp
80109be5:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109be8:	50                   	push   %eax
80109be9:	ff 75 ec             	push   -0x14(%ebp)
80109bec:	ff 75 08             	push   0x8(%ebp)
80109bef:	e8 78 00 00 00       	call   80109c6c <icmp_reply_pkt_create>
80109bf4:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109bf7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bfa:	83 ec 08             	sub    $0x8,%esp
80109bfd:	50                   	push   %eax
80109bfe:	ff 75 ec             	push   -0x14(%ebp)
80109c01:	e8 95 f4 ff ff       	call   8010909b <i8254_send>
80109c06:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109c09:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c0c:	83 ec 0c             	sub    $0xc,%esp
80109c0f:	50                   	push   %eax
80109c10:	e8 f1 8a ff ff       	call   80102706 <kfree>
80109c15:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109c18:	90                   	nop
80109c19:	c9                   	leave  
80109c1a:	c3                   	ret    

80109c1b <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109c1b:	55                   	push   %ebp
80109c1c:	89 e5                	mov    %esp,%ebp
80109c1e:	53                   	push   %ebx
80109c1f:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109c22:	8b 45 08             	mov    0x8(%ebp),%eax
80109c25:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109c29:	0f b7 c0             	movzwl %ax,%eax
80109c2c:	83 ec 0c             	sub    $0xc,%esp
80109c2f:	50                   	push   %eax
80109c30:	e8 bd fd ff ff       	call   801099f2 <N2H_ushort>
80109c35:	83 c4 10             	add    $0x10,%esp
80109c38:	0f b7 d8             	movzwl %ax,%ebx
80109c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c3e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c42:	0f b7 c0             	movzwl %ax,%eax
80109c45:	83 ec 0c             	sub    $0xc,%esp
80109c48:	50                   	push   %eax
80109c49:	e8 a4 fd ff ff       	call   801099f2 <N2H_ushort>
80109c4e:	83 c4 10             	add    $0x10,%esp
80109c51:	0f b7 c0             	movzwl %ax,%eax
80109c54:	83 ec 04             	sub    $0x4,%esp
80109c57:	53                   	push   %ebx
80109c58:	50                   	push   %eax
80109c59:	68 63 c5 10 80       	push   $0x8010c563
80109c5e:	e8 91 67 ff ff       	call   801003f4 <cprintf>
80109c63:	83 c4 10             	add    $0x10,%esp
}
80109c66:	90                   	nop
80109c67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c6a:	c9                   	leave  
80109c6b:	c3                   	ret    

80109c6c <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109c6c:	55                   	push   %ebp
80109c6d:	89 e5                	mov    %esp,%ebp
80109c6f:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109c72:	8b 45 08             	mov    0x8(%ebp),%eax
80109c75:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109c78:	8b 45 08             	mov    0x8(%ebp),%eax
80109c7b:	83 c0 0e             	add    $0xe,%eax
80109c7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c84:	0f b6 00             	movzbl (%eax),%eax
80109c87:	0f b6 c0             	movzbl %al,%eax
80109c8a:	83 e0 0f             	and    $0xf,%eax
80109c8d:	c1 e0 02             	shl    $0x2,%eax
80109c90:	89 c2                	mov    %eax,%edx
80109c92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c95:	01 d0                	add    %edx,%eax
80109c97:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c9d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109ca0:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ca3:	83 c0 0e             	add    $0xe,%eax
80109ca6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109ca9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cac:	83 c0 14             	add    $0x14,%eax
80109caf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109cb2:	8b 45 10             	mov    0x10(%ebp),%eax
80109cb5:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cbe:	8d 50 06             	lea    0x6(%eax),%edx
80109cc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cc4:	83 ec 04             	sub    $0x4,%esp
80109cc7:	6a 06                	push   $0x6
80109cc9:	52                   	push   %edx
80109cca:	50                   	push   %eax
80109ccb:	e8 54 b1 ff ff       	call   80104e24 <memmove>
80109cd0:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109cd3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cd6:	83 c0 06             	add    $0x6,%eax
80109cd9:	83 ec 04             	sub    $0x4,%esp
80109cdc:	6a 06                	push   $0x6
80109cde:	68 90 77 19 80       	push   $0x80197790
80109ce3:	50                   	push   %eax
80109ce4:	e8 3b b1 ff ff       	call   80104e24 <memmove>
80109ce9:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109cec:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cef:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109cf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cf6:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109cfa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cfd:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109d00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d03:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109d07:	83 ec 0c             	sub    $0xc,%esp
80109d0a:	6a 54                	push   $0x54
80109d0c:	e8 03 fd ff ff       	call   80109a14 <H2N_ushort>
80109d11:	83 c4 10             	add    $0x10,%esp
80109d14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d17:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109d1b:	0f b7 15 60 7a 19 80 	movzwl 0x80197a60,%edx
80109d22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d25:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109d29:	0f b7 05 60 7a 19 80 	movzwl 0x80197a60,%eax
80109d30:	83 c0 01             	add    $0x1,%eax
80109d33:	66 a3 60 7a 19 80    	mov    %ax,0x80197a60
  ipv4_send->fragment = H2N_ushort(0x4000);
80109d39:	83 ec 0c             	sub    $0xc,%esp
80109d3c:	68 00 40 00 00       	push   $0x4000
80109d41:	e8 ce fc ff ff       	call   80109a14 <H2N_ushort>
80109d46:	83 c4 10             	add    $0x10,%esp
80109d49:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d4c:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109d50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d53:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109d57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d5a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109d5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d61:	83 c0 0c             	add    $0xc,%eax
80109d64:	83 ec 04             	sub    $0x4,%esp
80109d67:	6a 04                	push   $0x4
80109d69:	68 04 f5 10 80       	push   $0x8010f504
80109d6e:	50                   	push   %eax
80109d6f:	e8 b0 b0 ff ff       	call   80104e24 <memmove>
80109d74:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109d77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d7a:	8d 50 0c             	lea    0xc(%eax),%edx
80109d7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d80:	83 c0 10             	add    $0x10,%eax
80109d83:	83 ec 04             	sub    $0x4,%esp
80109d86:	6a 04                	push   $0x4
80109d88:	52                   	push   %edx
80109d89:	50                   	push   %eax
80109d8a:	e8 95 b0 ff ff       	call   80104e24 <memmove>
80109d8f:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109d92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d95:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109d9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d9e:	83 ec 0c             	sub    $0xc,%esp
80109da1:	50                   	push   %eax
80109da2:	e8 6d fd ff ff       	call   80109b14 <ipv4_chksum>
80109da7:	83 c4 10             	add    $0x10,%esp
80109daa:	0f b7 c0             	movzwl %ax,%eax
80109dad:	83 ec 0c             	sub    $0xc,%esp
80109db0:	50                   	push   %eax
80109db1:	e8 5e fc ff ff       	call   80109a14 <H2N_ushort>
80109db6:	83 c4 10             	add    $0x10,%esp
80109db9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109dbc:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109dc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dc3:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109dc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dc9:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109dcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dd0:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109dd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dd7:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109ddb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dde:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109de2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109de5:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dec:	8d 50 08             	lea    0x8(%eax),%edx
80109def:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109df2:	83 c0 08             	add    $0x8,%eax
80109df5:	83 ec 04             	sub    $0x4,%esp
80109df8:	6a 08                	push   $0x8
80109dfa:	52                   	push   %edx
80109dfb:	50                   	push   %eax
80109dfc:	e8 23 b0 ff ff       	call   80104e24 <memmove>
80109e01:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109e04:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e07:	8d 50 10             	lea    0x10(%eax),%edx
80109e0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e0d:	83 c0 10             	add    $0x10,%eax
80109e10:	83 ec 04             	sub    $0x4,%esp
80109e13:	6a 30                	push   $0x30
80109e15:	52                   	push   %edx
80109e16:	50                   	push   %eax
80109e17:	e8 08 b0 ff ff       	call   80104e24 <memmove>
80109e1c:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109e1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e22:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109e28:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e2b:	83 ec 0c             	sub    $0xc,%esp
80109e2e:	50                   	push   %eax
80109e2f:	e8 1c 00 00 00       	call   80109e50 <icmp_chksum>
80109e34:	83 c4 10             	add    $0x10,%esp
80109e37:	0f b7 c0             	movzwl %ax,%eax
80109e3a:	83 ec 0c             	sub    $0xc,%esp
80109e3d:	50                   	push   %eax
80109e3e:	e8 d1 fb ff ff       	call   80109a14 <H2N_ushort>
80109e43:	83 c4 10             	add    $0x10,%esp
80109e46:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109e49:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109e4d:	90                   	nop
80109e4e:	c9                   	leave  
80109e4f:	c3                   	ret    

80109e50 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109e50:	55                   	push   %ebp
80109e51:	89 e5                	mov    %esp,%ebp
80109e53:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109e56:	8b 45 08             	mov    0x8(%ebp),%eax
80109e59:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109e5c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109e63:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109e6a:	eb 48                	jmp    80109eb4 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e6f:	01 c0                	add    %eax,%eax
80109e71:	89 c2                	mov    %eax,%edx
80109e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e76:	01 d0                	add    %edx,%eax
80109e78:	0f b6 00             	movzbl (%eax),%eax
80109e7b:	0f b6 c0             	movzbl %al,%eax
80109e7e:	c1 e0 08             	shl    $0x8,%eax
80109e81:	89 c2                	mov    %eax,%edx
80109e83:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e86:	01 c0                	add    %eax,%eax
80109e88:	8d 48 01             	lea    0x1(%eax),%ecx
80109e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e8e:	01 c8                	add    %ecx,%eax
80109e90:	0f b6 00             	movzbl (%eax),%eax
80109e93:	0f b6 c0             	movzbl %al,%eax
80109e96:	01 d0                	add    %edx,%eax
80109e98:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109e9b:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109ea2:	76 0c                	jbe    80109eb0 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109ea4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ea7:	0f b7 c0             	movzwl %ax,%eax
80109eaa:	83 c0 01             	add    $0x1,%eax
80109ead:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109eb0:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109eb4:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109eb8:	7e b2                	jle    80109e6c <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109eba:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ebd:	f7 d0                	not    %eax
}
80109ebf:	c9                   	leave  
80109ec0:	c3                   	ret    

80109ec1 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109ec1:	55                   	push   %ebp
80109ec2:	89 e5                	mov    %esp,%ebp
80109ec4:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80109eca:	83 c0 0e             	add    $0xe,%eax
80109ecd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ed3:	0f b6 00             	movzbl (%eax),%eax
80109ed6:	0f b6 c0             	movzbl %al,%eax
80109ed9:	83 e0 0f             	and    $0xf,%eax
80109edc:	c1 e0 02             	shl    $0x2,%eax
80109edf:	89 c2                	mov    %eax,%edx
80109ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ee4:	01 d0                	add    %edx,%eax
80109ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109eec:	83 c0 14             	add    $0x14,%eax
80109eef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109ef2:	e8 a9 88 ff ff       	call   801027a0 <kalloc>
80109ef7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109efa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f04:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f08:	0f b6 c0             	movzbl %al,%eax
80109f0b:	83 e0 02             	and    $0x2,%eax
80109f0e:	85 c0                	test   %eax,%eax
80109f10:	74 3d                	je     80109f4f <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109f12:	83 ec 0c             	sub    $0xc,%esp
80109f15:	6a 00                	push   $0x0
80109f17:	6a 12                	push   $0x12
80109f19:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f1c:	50                   	push   %eax
80109f1d:	ff 75 e8             	push   -0x18(%ebp)
80109f20:	ff 75 08             	push   0x8(%ebp)
80109f23:	e8 a2 01 00 00       	call   8010a0ca <tcp_pkt_create>
80109f28:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109f2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f2e:	83 ec 08             	sub    $0x8,%esp
80109f31:	50                   	push   %eax
80109f32:	ff 75 e8             	push   -0x18(%ebp)
80109f35:	e8 61 f1 ff ff       	call   8010909b <i8254_send>
80109f3a:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109f3d:	a1 64 7a 19 80       	mov    0x80197a64,%eax
80109f42:	83 c0 01             	add    $0x1,%eax
80109f45:	a3 64 7a 19 80       	mov    %eax,0x80197a64
80109f4a:	e9 69 01 00 00       	jmp    8010a0b8 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f52:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f56:	3c 18                	cmp    $0x18,%al
80109f58:	0f 85 10 01 00 00    	jne    8010a06e <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109f5e:	83 ec 04             	sub    $0x4,%esp
80109f61:	6a 03                	push   $0x3
80109f63:	68 7e c5 10 80       	push   $0x8010c57e
80109f68:	ff 75 ec             	push   -0x14(%ebp)
80109f6b:	e8 5c ae ff ff       	call   80104dcc <memcmp>
80109f70:	83 c4 10             	add    $0x10,%esp
80109f73:	85 c0                	test   %eax,%eax
80109f75:	74 74                	je     80109feb <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109f77:	83 ec 0c             	sub    $0xc,%esp
80109f7a:	68 82 c5 10 80       	push   $0x8010c582
80109f7f:	e8 70 64 ff ff       	call   801003f4 <cprintf>
80109f84:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109f87:	83 ec 0c             	sub    $0xc,%esp
80109f8a:	6a 00                	push   $0x0
80109f8c:	6a 10                	push   $0x10
80109f8e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f91:	50                   	push   %eax
80109f92:	ff 75 e8             	push   -0x18(%ebp)
80109f95:	ff 75 08             	push   0x8(%ebp)
80109f98:	e8 2d 01 00 00       	call   8010a0ca <tcp_pkt_create>
80109f9d:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109fa0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109fa3:	83 ec 08             	sub    $0x8,%esp
80109fa6:	50                   	push   %eax
80109fa7:	ff 75 e8             	push   -0x18(%ebp)
80109faa:	e8 ec f0 ff ff       	call   8010909b <i8254_send>
80109faf:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109fb2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fb5:	83 c0 36             	add    $0x36,%eax
80109fb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109fbb:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109fbe:	50                   	push   %eax
80109fbf:	ff 75 e0             	push   -0x20(%ebp)
80109fc2:	6a 00                	push   $0x0
80109fc4:	6a 00                	push   $0x0
80109fc6:	e8 5a 04 00 00       	call   8010a425 <http_proc>
80109fcb:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109fce:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109fd1:	83 ec 0c             	sub    $0xc,%esp
80109fd4:	50                   	push   %eax
80109fd5:	6a 18                	push   $0x18
80109fd7:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109fda:	50                   	push   %eax
80109fdb:	ff 75 e8             	push   -0x18(%ebp)
80109fde:	ff 75 08             	push   0x8(%ebp)
80109fe1:	e8 e4 00 00 00       	call   8010a0ca <tcp_pkt_create>
80109fe6:	83 c4 20             	add    $0x20,%esp
80109fe9:	eb 62                	jmp    8010a04d <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109feb:	83 ec 0c             	sub    $0xc,%esp
80109fee:	6a 00                	push   $0x0
80109ff0:	6a 10                	push   $0x10
80109ff2:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ff5:	50                   	push   %eax
80109ff6:	ff 75 e8             	push   -0x18(%ebp)
80109ff9:	ff 75 08             	push   0x8(%ebp)
80109ffc:	e8 c9 00 00 00       	call   8010a0ca <tcp_pkt_create>
8010a001:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a004:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a007:	83 ec 08             	sub    $0x8,%esp
8010a00a:	50                   	push   %eax
8010a00b:	ff 75 e8             	push   -0x18(%ebp)
8010a00e:	e8 88 f0 ff ff       	call   8010909b <i8254_send>
8010a013:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a016:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a019:	83 c0 36             	add    $0x36,%eax
8010a01c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a01f:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a022:	50                   	push   %eax
8010a023:	ff 75 e4             	push   -0x1c(%ebp)
8010a026:	6a 00                	push   $0x0
8010a028:	6a 00                	push   $0x0
8010a02a:	e8 f6 03 00 00       	call   8010a425 <http_proc>
8010a02f:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a032:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a035:	83 ec 0c             	sub    $0xc,%esp
8010a038:	50                   	push   %eax
8010a039:	6a 18                	push   $0x18
8010a03b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a03e:	50                   	push   %eax
8010a03f:	ff 75 e8             	push   -0x18(%ebp)
8010a042:	ff 75 08             	push   0x8(%ebp)
8010a045:	e8 80 00 00 00       	call   8010a0ca <tcp_pkt_create>
8010a04a:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a04d:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a050:	83 ec 08             	sub    $0x8,%esp
8010a053:	50                   	push   %eax
8010a054:	ff 75 e8             	push   -0x18(%ebp)
8010a057:	e8 3f f0 ff ff       	call   8010909b <i8254_send>
8010a05c:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a05f:	a1 64 7a 19 80       	mov    0x80197a64,%eax
8010a064:	83 c0 01             	add    $0x1,%eax
8010a067:	a3 64 7a 19 80       	mov    %eax,0x80197a64
8010a06c:	eb 4a                	jmp    8010a0b8 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a06e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a071:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a075:	3c 10                	cmp    $0x10,%al
8010a077:	75 3f                	jne    8010a0b8 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a079:	a1 68 7a 19 80       	mov    0x80197a68,%eax
8010a07e:	83 f8 01             	cmp    $0x1,%eax
8010a081:	75 35                	jne    8010a0b8 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a083:	83 ec 0c             	sub    $0xc,%esp
8010a086:	6a 00                	push   $0x0
8010a088:	6a 01                	push   $0x1
8010a08a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a08d:	50                   	push   %eax
8010a08e:	ff 75 e8             	push   -0x18(%ebp)
8010a091:	ff 75 08             	push   0x8(%ebp)
8010a094:	e8 31 00 00 00       	call   8010a0ca <tcp_pkt_create>
8010a099:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a09c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a09f:	83 ec 08             	sub    $0x8,%esp
8010a0a2:	50                   	push   %eax
8010a0a3:	ff 75 e8             	push   -0x18(%ebp)
8010a0a6:	e8 f0 ef ff ff       	call   8010909b <i8254_send>
8010a0ab:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a0ae:	c7 05 68 7a 19 80 00 	movl   $0x0,0x80197a68
8010a0b5:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a0b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0bb:	83 ec 0c             	sub    $0xc,%esp
8010a0be:	50                   	push   %eax
8010a0bf:	e8 42 86 ff ff       	call   80102706 <kfree>
8010a0c4:	83 c4 10             	add    $0x10,%esp
}
8010a0c7:	90                   	nop
8010a0c8:	c9                   	leave  
8010a0c9:	c3                   	ret    

8010a0ca <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a0ca:	55                   	push   %ebp
8010a0cb:	89 e5                	mov    %esp,%ebp
8010a0cd:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a0d0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a0d6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0d9:	83 c0 0e             	add    $0xe,%eax
8010a0dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a0df:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0e2:	0f b6 00             	movzbl (%eax),%eax
8010a0e5:	0f b6 c0             	movzbl %al,%eax
8010a0e8:	83 e0 0f             	and    $0xf,%eax
8010a0eb:	c1 e0 02             	shl    $0x2,%eax
8010a0ee:	89 c2                	mov    %eax,%edx
8010a0f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0f3:	01 d0                	add    %edx,%eax
8010a0f5:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a0f8:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a0fb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a0fe:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a101:	83 c0 0e             	add    $0xe,%eax
8010a104:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a107:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a10a:	83 c0 14             	add    $0x14,%eax
8010a10d:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a110:	8b 45 18             	mov    0x18(%ebp),%eax
8010a113:	8d 50 36             	lea    0x36(%eax),%edx
8010a116:	8b 45 10             	mov    0x10(%ebp),%eax
8010a119:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a11b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a11e:	8d 50 06             	lea    0x6(%eax),%edx
8010a121:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a124:	83 ec 04             	sub    $0x4,%esp
8010a127:	6a 06                	push   $0x6
8010a129:	52                   	push   %edx
8010a12a:	50                   	push   %eax
8010a12b:	e8 f4 ac ff ff       	call   80104e24 <memmove>
8010a130:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a133:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a136:	83 c0 06             	add    $0x6,%eax
8010a139:	83 ec 04             	sub    $0x4,%esp
8010a13c:	6a 06                	push   $0x6
8010a13e:	68 90 77 19 80       	push   $0x80197790
8010a143:	50                   	push   %eax
8010a144:	e8 db ac ff ff       	call   80104e24 <memmove>
8010a149:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a14c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a14f:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a153:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a156:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a15a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a15d:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a160:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a163:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a167:	8b 45 18             	mov    0x18(%ebp),%eax
8010a16a:	83 c0 28             	add    $0x28,%eax
8010a16d:	0f b7 c0             	movzwl %ax,%eax
8010a170:	83 ec 0c             	sub    $0xc,%esp
8010a173:	50                   	push   %eax
8010a174:	e8 9b f8 ff ff       	call   80109a14 <H2N_ushort>
8010a179:	83 c4 10             	add    $0x10,%esp
8010a17c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a17f:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a183:	0f b7 15 60 7a 19 80 	movzwl 0x80197a60,%edx
8010a18a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a18d:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a191:	0f b7 05 60 7a 19 80 	movzwl 0x80197a60,%eax
8010a198:	83 c0 01             	add    $0x1,%eax
8010a19b:	66 a3 60 7a 19 80    	mov    %ax,0x80197a60
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a1a1:	83 ec 0c             	sub    $0xc,%esp
8010a1a4:	6a 00                	push   $0x0
8010a1a6:	e8 69 f8 ff ff       	call   80109a14 <H2N_ushort>
8010a1ab:	83 c4 10             	add    $0x10,%esp
8010a1ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a1b1:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a1b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1b8:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a1bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1bf:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a1c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1c6:	83 c0 0c             	add    $0xc,%eax
8010a1c9:	83 ec 04             	sub    $0x4,%esp
8010a1cc:	6a 04                	push   $0x4
8010a1ce:	68 04 f5 10 80       	push   $0x8010f504
8010a1d3:	50                   	push   %eax
8010a1d4:	e8 4b ac ff ff       	call   80104e24 <memmove>
8010a1d9:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a1dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1df:	8d 50 0c             	lea    0xc(%eax),%edx
8010a1e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1e5:	83 c0 10             	add    $0x10,%eax
8010a1e8:	83 ec 04             	sub    $0x4,%esp
8010a1eb:	6a 04                	push   $0x4
8010a1ed:	52                   	push   %edx
8010a1ee:	50                   	push   %eax
8010a1ef:	e8 30 ac ff ff       	call   80104e24 <memmove>
8010a1f4:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a1f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1fa:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a200:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a203:	83 ec 0c             	sub    $0xc,%esp
8010a206:	50                   	push   %eax
8010a207:	e8 08 f9 ff ff       	call   80109b14 <ipv4_chksum>
8010a20c:	83 c4 10             	add    $0x10,%esp
8010a20f:	0f b7 c0             	movzwl %ax,%eax
8010a212:	83 ec 0c             	sub    $0xc,%esp
8010a215:	50                   	push   %eax
8010a216:	e8 f9 f7 ff ff       	call   80109a14 <H2N_ushort>
8010a21b:	83 c4 10             	add    $0x10,%esp
8010a21e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a221:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a225:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a228:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a22c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a22f:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a232:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a235:	0f b7 10             	movzwl (%eax),%edx
8010a238:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a23b:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a23f:	a1 64 7a 19 80       	mov    0x80197a64,%eax
8010a244:	83 ec 0c             	sub    $0xc,%esp
8010a247:	50                   	push   %eax
8010a248:	e8 e9 f7 ff ff       	call   80109a36 <H2N_uint>
8010a24d:	83 c4 10             	add    $0x10,%esp
8010a250:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a253:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a256:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a259:	8b 40 04             	mov    0x4(%eax),%eax
8010a25c:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a262:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a265:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a268:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a26b:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a26f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a272:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a276:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a279:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a27d:	8b 45 14             	mov    0x14(%ebp),%eax
8010a280:	89 c2                	mov    %eax,%edx
8010a282:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a285:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a288:	83 ec 0c             	sub    $0xc,%esp
8010a28b:	68 90 38 00 00       	push   $0x3890
8010a290:	e8 7f f7 ff ff       	call   80109a14 <H2N_ushort>
8010a295:	83 c4 10             	add    $0x10,%esp
8010a298:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a29b:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a29f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2a2:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a2a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2ab:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a2b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2b4:	83 ec 0c             	sub    $0xc,%esp
8010a2b7:	50                   	push   %eax
8010a2b8:	e8 1f 00 00 00       	call   8010a2dc <tcp_chksum>
8010a2bd:	83 c4 10             	add    $0x10,%esp
8010a2c0:	83 c0 08             	add    $0x8,%eax
8010a2c3:	0f b7 c0             	movzwl %ax,%eax
8010a2c6:	83 ec 0c             	sub    $0xc,%esp
8010a2c9:	50                   	push   %eax
8010a2ca:	e8 45 f7 ff ff       	call   80109a14 <H2N_ushort>
8010a2cf:	83 c4 10             	add    $0x10,%esp
8010a2d2:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a2d5:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a2d9:	90                   	nop
8010a2da:	c9                   	leave  
8010a2db:	c3                   	ret    

8010a2dc <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a2dc:	55                   	push   %ebp
8010a2dd:	89 e5                	mov    %esp,%ebp
8010a2df:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a2e2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2e5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a2e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2eb:	83 c0 14             	add    $0x14,%eax
8010a2ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a2f1:	83 ec 04             	sub    $0x4,%esp
8010a2f4:	6a 04                	push   $0x4
8010a2f6:	68 04 f5 10 80       	push   $0x8010f504
8010a2fb:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a2fe:	50                   	push   %eax
8010a2ff:	e8 20 ab ff ff       	call   80104e24 <memmove>
8010a304:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a307:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a30a:	83 c0 0c             	add    $0xc,%eax
8010a30d:	83 ec 04             	sub    $0x4,%esp
8010a310:	6a 04                	push   $0x4
8010a312:	50                   	push   %eax
8010a313:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a316:	83 c0 04             	add    $0x4,%eax
8010a319:	50                   	push   %eax
8010a31a:	e8 05 ab ff ff       	call   80104e24 <memmove>
8010a31f:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a322:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a326:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a32a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a32d:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a331:	0f b7 c0             	movzwl %ax,%eax
8010a334:	83 ec 0c             	sub    $0xc,%esp
8010a337:	50                   	push   %eax
8010a338:	e8 b5 f6 ff ff       	call   801099f2 <N2H_ushort>
8010a33d:	83 c4 10             	add    $0x10,%esp
8010a340:	83 e8 14             	sub    $0x14,%eax
8010a343:	0f b7 c0             	movzwl %ax,%eax
8010a346:	83 ec 0c             	sub    $0xc,%esp
8010a349:	50                   	push   %eax
8010a34a:	e8 c5 f6 ff ff       	call   80109a14 <H2N_ushort>
8010a34f:	83 c4 10             	add    $0x10,%esp
8010a352:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a356:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a35d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a360:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a363:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a36a:	eb 33                	jmp    8010a39f <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a36c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a36f:	01 c0                	add    %eax,%eax
8010a371:	89 c2                	mov    %eax,%edx
8010a373:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a376:	01 d0                	add    %edx,%eax
8010a378:	0f b6 00             	movzbl (%eax),%eax
8010a37b:	0f b6 c0             	movzbl %al,%eax
8010a37e:	c1 e0 08             	shl    $0x8,%eax
8010a381:	89 c2                	mov    %eax,%edx
8010a383:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a386:	01 c0                	add    %eax,%eax
8010a388:	8d 48 01             	lea    0x1(%eax),%ecx
8010a38b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a38e:	01 c8                	add    %ecx,%eax
8010a390:	0f b6 00             	movzbl (%eax),%eax
8010a393:	0f b6 c0             	movzbl %al,%eax
8010a396:	01 d0                	add    %edx,%eax
8010a398:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a39b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a39f:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a3a3:	7e c7                	jle    8010a36c <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a3a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a3ab:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a3b2:	eb 33                	jmp    8010a3e7 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a3b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3b7:	01 c0                	add    %eax,%eax
8010a3b9:	89 c2                	mov    %eax,%edx
8010a3bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3be:	01 d0                	add    %edx,%eax
8010a3c0:	0f b6 00             	movzbl (%eax),%eax
8010a3c3:	0f b6 c0             	movzbl %al,%eax
8010a3c6:	c1 e0 08             	shl    $0x8,%eax
8010a3c9:	89 c2                	mov    %eax,%edx
8010a3cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3ce:	01 c0                	add    %eax,%eax
8010a3d0:	8d 48 01             	lea    0x1(%eax),%ecx
8010a3d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3d6:	01 c8                	add    %ecx,%eax
8010a3d8:	0f b6 00             	movzbl (%eax),%eax
8010a3db:	0f b6 c0             	movzbl %al,%eax
8010a3de:	01 d0                	add    %edx,%eax
8010a3e0:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a3e3:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a3e7:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a3eb:	0f b7 c0             	movzwl %ax,%eax
8010a3ee:	83 ec 0c             	sub    $0xc,%esp
8010a3f1:	50                   	push   %eax
8010a3f2:	e8 fb f5 ff ff       	call   801099f2 <N2H_ushort>
8010a3f7:	83 c4 10             	add    $0x10,%esp
8010a3fa:	66 d1 e8             	shr    %ax
8010a3fd:	0f b7 c0             	movzwl %ax,%eax
8010a400:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a403:	7c af                	jl     8010a3b4 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a405:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a408:	c1 e8 10             	shr    $0x10,%eax
8010a40b:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a40e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a411:	f7 d0                	not    %eax
}
8010a413:	c9                   	leave  
8010a414:	c3                   	ret    

8010a415 <tcp_fin>:

void tcp_fin(){
8010a415:	55                   	push   %ebp
8010a416:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a418:	c7 05 68 7a 19 80 01 	movl   $0x1,0x80197a68
8010a41f:	00 00 00 
}
8010a422:	90                   	nop
8010a423:	5d                   	pop    %ebp
8010a424:	c3                   	ret    

8010a425 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a425:	55                   	push   %ebp
8010a426:	89 e5                	mov    %esp,%ebp
8010a428:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a42b:	8b 45 10             	mov    0x10(%ebp),%eax
8010a42e:	83 ec 04             	sub    $0x4,%esp
8010a431:	6a 00                	push   $0x0
8010a433:	68 8b c5 10 80       	push   $0x8010c58b
8010a438:	50                   	push   %eax
8010a439:	e8 65 00 00 00       	call   8010a4a3 <http_strcpy>
8010a43e:	83 c4 10             	add    $0x10,%esp
8010a441:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a444:	8b 45 10             	mov    0x10(%ebp),%eax
8010a447:	83 ec 04             	sub    $0x4,%esp
8010a44a:	ff 75 f4             	push   -0xc(%ebp)
8010a44d:	68 9e c5 10 80       	push   $0x8010c59e
8010a452:	50                   	push   %eax
8010a453:	e8 4b 00 00 00       	call   8010a4a3 <http_strcpy>
8010a458:	83 c4 10             	add    $0x10,%esp
8010a45b:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a45e:	8b 45 10             	mov    0x10(%ebp),%eax
8010a461:	83 ec 04             	sub    $0x4,%esp
8010a464:	ff 75 f4             	push   -0xc(%ebp)
8010a467:	68 b9 c5 10 80       	push   $0x8010c5b9
8010a46c:	50                   	push   %eax
8010a46d:	e8 31 00 00 00       	call   8010a4a3 <http_strcpy>
8010a472:	83 c4 10             	add    $0x10,%esp
8010a475:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a47b:	83 e0 01             	and    $0x1,%eax
8010a47e:	85 c0                	test   %eax,%eax
8010a480:	74 11                	je     8010a493 <http_proc+0x6e>
    char *payload = (char *)send;
8010a482:	8b 45 10             	mov    0x10(%ebp),%eax
8010a485:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a488:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a48b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a48e:	01 d0                	add    %edx,%eax
8010a490:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a493:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a496:	8b 45 14             	mov    0x14(%ebp),%eax
8010a499:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a49b:	e8 75 ff ff ff       	call   8010a415 <tcp_fin>
}
8010a4a0:	90                   	nop
8010a4a1:	c9                   	leave  
8010a4a2:	c3                   	ret    

8010a4a3 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a4a3:	55                   	push   %ebp
8010a4a4:	89 e5                	mov    %esp,%ebp
8010a4a6:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a4a9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a4b0:	eb 20                	jmp    8010a4d2 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a4b2:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a4b5:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a4b8:	01 d0                	add    %edx,%eax
8010a4ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a4bd:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a4c0:	01 ca                	add    %ecx,%edx
8010a4c2:	89 d1                	mov    %edx,%ecx
8010a4c4:	8b 55 08             	mov    0x8(%ebp),%edx
8010a4c7:	01 ca                	add    %ecx,%edx
8010a4c9:	0f b6 00             	movzbl (%eax),%eax
8010a4cc:	88 02                	mov    %al,(%edx)
    i++;
8010a4ce:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a4d2:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a4d5:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a4d8:	01 d0                	add    %edx,%eax
8010a4da:	0f b6 00             	movzbl (%eax),%eax
8010a4dd:	84 c0                	test   %al,%al
8010a4df:	75 d1                	jne    8010a4b2 <http_strcpy+0xf>
  }
  return i;
8010a4e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a4e4:	c9                   	leave  
8010a4e5:	c3                   	ret    

8010a4e6 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a4e6:	55                   	push   %ebp
8010a4e7:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a4e9:	c7 05 70 7a 19 80 c2 	movl   $0x8010f5c2,0x80197a70
8010a4f0:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a4f3:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a4f8:	c1 e8 09             	shr    $0x9,%eax
8010a4fb:	a3 6c 7a 19 80       	mov    %eax,0x80197a6c
}
8010a500:	90                   	nop
8010a501:	5d                   	pop    %ebp
8010a502:	c3                   	ret    

8010a503 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a503:	55                   	push   %ebp
8010a504:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a506:	90                   	nop
8010a507:	5d                   	pop    %ebp
8010a508:	c3                   	ret    

8010a509 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a509:	55                   	push   %ebp
8010a50a:	89 e5                	mov    %esp,%ebp
8010a50c:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a50f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a512:	83 c0 0c             	add    $0xc,%eax
8010a515:	83 ec 0c             	sub    $0xc,%esp
8010a518:	50                   	push   %eax
8010a519:	e8 40 a5 ff ff       	call   80104a5e <holdingsleep>
8010a51e:	83 c4 10             	add    $0x10,%esp
8010a521:	85 c0                	test   %eax,%eax
8010a523:	75 0d                	jne    8010a532 <iderw+0x29>
    panic("iderw: buf not locked");
8010a525:	83 ec 0c             	sub    $0xc,%esp
8010a528:	68 ca c5 10 80       	push   $0x8010c5ca
8010a52d:	e8 77 60 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a532:	8b 45 08             	mov    0x8(%ebp),%eax
8010a535:	8b 00                	mov    (%eax),%eax
8010a537:	83 e0 06             	and    $0x6,%eax
8010a53a:	83 f8 02             	cmp    $0x2,%eax
8010a53d:	75 0d                	jne    8010a54c <iderw+0x43>
    panic("iderw: nothing to do");
8010a53f:	83 ec 0c             	sub    $0xc,%esp
8010a542:	68 e0 c5 10 80       	push   $0x8010c5e0
8010a547:	e8 5d 60 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a54c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a54f:	8b 40 04             	mov    0x4(%eax),%eax
8010a552:	83 f8 01             	cmp    $0x1,%eax
8010a555:	74 0d                	je     8010a564 <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a557:	83 ec 0c             	sub    $0xc,%esp
8010a55a:	68 f5 c5 10 80       	push   $0x8010c5f5
8010a55f:	e8 45 60 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a564:	8b 45 08             	mov    0x8(%ebp),%eax
8010a567:	8b 40 08             	mov    0x8(%eax),%eax
8010a56a:	8b 15 6c 7a 19 80    	mov    0x80197a6c,%edx
8010a570:	39 d0                	cmp    %edx,%eax
8010a572:	72 0d                	jb     8010a581 <iderw+0x78>
    panic("iderw: block out of range");
8010a574:	83 ec 0c             	sub    $0xc,%esp
8010a577:	68 13 c6 10 80       	push   $0x8010c613
8010a57c:	e8 28 60 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a581:	8b 15 70 7a 19 80    	mov    0x80197a70,%edx
8010a587:	8b 45 08             	mov    0x8(%ebp),%eax
8010a58a:	8b 40 08             	mov    0x8(%eax),%eax
8010a58d:	c1 e0 09             	shl    $0x9,%eax
8010a590:	01 d0                	add    %edx,%eax
8010a592:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a595:	8b 45 08             	mov    0x8(%ebp),%eax
8010a598:	8b 00                	mov    (%eax),%eax
8010a59a:	83 e0 04             	and    $0x4,%eax
8010a59d:	85 c0                	test   %eax,%eax
8010a59f:	74 2b                	je     8010a5cc <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a5a1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5a4:	8b 00                	mov    (%eax),%eax
8010a5a6:	83 e0 fb             	and    $0xfffffffb,%eax
8010a5a9:	89 c2                	mov    %eax,%edx
8010a5ab:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5ae:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a5b0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5b3:	83 c0 5c             	add    $0x5c,%eax
8010a5b6:	83 ec 04             	sub    $0x4,%esp
8010a5b9:	68 00 02 00 00       	push   $0x200
8010a5be:	50                   	push   %eax
8010a5bf:	ff 75 f4             	push   -0xc(%ebp)
8010a5c2:	e8 5d a8 ff ff       	call   80104e24 <memmove>
8010a5c7:	83 c4 10             	add    $0x10,%esp
8010a5ca:	eb 1a                	jmp    8010a5e6 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a5cc:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5cf:	83 c0 5c             	add    $0x5c,%eax
8010a5d2:	83 ec 04             	sub    $0x4,%esp
8010a5d5:	68 00 02 00 00       	push   $0x200
8010a5da:	ff 75 f4             	push   -0xc(%ebp)
8010a5dd:	50                   	push   %eax
8010a5de:	e8 41 a8 ff ff       	call   80104e24 <memmove>
8010a5e3:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a5e6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5e9:	8b 00                	mov    (%eax),%eax
8010a5eb:	83 c8 02             	or     $0x2,%eax
8010a5ee:	89 c2                	mov    %eax,%edx
8010a5f0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5f3:	89 10                	mov    %edx,(%eax)
}
8010a5f5:	90                   	nop
8010a5f6:	c9                   	leave  
8010a5f7:	c3                   	ret    
