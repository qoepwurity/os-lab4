
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
8010005a:	bc 80 fa 30 80       	mov    $0x8030fa80,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 4d 33 10 80       	mov    $0x8010334d,%edx
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
8010006f:	68 e0 a8 10 80       	push   $0x8010a8e0
80100074:	68 00 40 30 80       	push   $0x80304000
80100079:	e8 e7 4a 00 00       	call   80104b65 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 87 30 80 fc 	movl   $0x803086fc,0x8030874c
80100088:	86 30 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 87 30 80 fc 	movl   $0x803086fc,0x80308750
80100092:	86 30 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 40 30 80 	movl   $0x80304034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 87 30 80    	mov    0x80308750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 86 30 80 	movl   $0x803086fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 e7 a8 10 80       	push   $0x8010a8e7
801000c2:	50                   	push   %eax
801000c3:	e8 40 49 00 00       	call   80104a08 <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 87 30 80       	mov    0x80308750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 87 30 80       	mov    %eax,0x80308750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 86 30 80       	mov    $0x803086fc,%eax
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
801000fc:	68 00 40 30 80       	push   $0x80304000
80100101:	e8 81 4a 00 00       	call   80104b87 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 87 30 80       	mov    0x80308750,%eax
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
8010013b:	68 00 40 30 80       	push   $0x80304000
80100140:	e8 b0 4a 00 00       	call   80104bf5 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 ed 48 00 00       	call   80104a44 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 86 30 80 	cmpl   $0x803086fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 87 30 80       	mov    0x8030874c,%eax
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
801001bc:	68 00 40 30 80       	push   $0x80304000
801001c1:	e8 2f 4a 00 00       	call   80104bf5 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 6c 48 00 00       	call   80104a44 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 86 30 80 	cmpl   $0x803086fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 ee a8 10 80       	push   $0x8010a8ee
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
8010022d:	e8 af a5 00 00       	call   8010a7e1 <iderw>
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
8010024a:	e8 a7 48 00 00       	call   80104af6 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 ff a8 10 80       	push   $0x8010a8ff
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
80100278:	e8 64 a5 00 00       	call   8010a7e1 <iderw>
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
80100293:	e8 5e 48 00 00       	call   80104af6 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 06 a9 10 80       	push   $0x8010a906
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 ed 47 00 00       	call   80104aa8 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 40 30 80       	push   $0x80304000
801002c6:	e8 bc 48 00 00       	call   80104b87 <acquire>
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
80100305:	8b 15 50 87 30 80    	mov    0x80308750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 86 30 80 	movl   $0x803086fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 87 30 80       	mov    0x80308750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 87 30 80       	mov    %eax,0x80308750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 40 30 80       	push   $0x80304000
80100336:	e8 ba 48 00 00       	call   80104bf5 <release>
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
801003fa:	a1 34 8a 30 80       	mov    0x80308a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 8a 30 80       	push   $0x80308a00
80100410:	e8 72 47 00 00       	call   80104b87 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 0d a9 10 80       	push   $0x8010a90d
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
80100510:	c7 45 ec 16 a9 10 80 	movl   $0x8010a916,-0x14(%ebp)
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
80100599:	68 00 8a 30 80       	push   $0x80308a00
8010059e:	e8 52 46 00 00       	call   80104bf5 <release>
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
801005b4:	c7 05 34 8a 30 80 00 	movl   $0x0,0x80308a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 1f 25 00 00       	call   80102ae2 <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 1d a9 10 80       	push   $0x8010a91d
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
801005e6:	68 31 a9 10 80       	push   $0x8010a931
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 44 46 00 00       	call   80104c47 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 33 a9 10 80       	push   $0x8010a933
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 89 30 80 01 	movl   $0x1,0x803089ec
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
801006a0:	e8 93 80 00 00       	call   80108738 <graphic_scroll_up>
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
801006f3:	e8 40 80 00 00       	call   80108738 <graphic_scroll_up>
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
80100757:	e8 47 80 00 00       	call   801087a3 <font_render>
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
80100775:	a1 ec 89 30 80       	mov    0x803089ec,%eax
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
80100793:	e8 2c 64 00 00       	call   80106bc4 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 1f 64 00 00       	call   80106bc4 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 12 64 00 00       	call   80106bc4 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 02 64 00 00       	call   80106bc4 <uartputc>
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
801007e6:	68 00 8a 30 80       	push   $0x80308a00
801007eb:	e8 97 43 00 00       	call   80104b87 <acquire>
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
80100838:	a1 e8 89 30 80       	mov    0x803089e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 89 30 80       	mov    %eax,0x803089e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 89 30 80    	mov    0x803089e8,%edx
8010085b:	a1 e4 89 30 80       	mov    0x803089e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 89 30 80       	mov    0x803089e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 89 30 80 	movzbl -0x7fcf76a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 89 30 80    	mov    0x803089e8,%edx
80100889:	a1 e4 89 30 80       	mov    0x803089e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 89 30 80       	mov    0x803089e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 89 30 80       	mov    %eax,0x803089e8
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
801008c2:	a1 e8 89 30 80       	mov    0x803089e8,%eax
801008c7:	8b 15 e0 89 30 80    	mov    0x803089e0,%edx
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
801008e7:	a1 e8 89 30 80       	mov    0x803089e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 89 30 80    	mov    %edx,0x803089e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 89 30 80    	mov    %dl,-0x7fcf76a0(%eax)
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
8010091b:	a1 e8 89 30 80       	mov    0x803089e8,%eax
80100920:	8b 15 e0 89 30 80    	mov    0x803089e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 89 30 80       	mov    0x803089e8,%eax
80100932:	a3 e4 89 30 80       	mov    %eax,0x803089e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 89 30 80       	push   $0x803089e0
8010093f:	e8 d3 3e 00 00       	call   80104817 <wakeup>
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
8010095d:	68 00 8a 30 80       	push   $0x80308a00
80100962:	e8 8e 42 00 00       	call   80104bf5 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 60 3f 00 00       	call   801048d5 <procdump>
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
80100984:	e8 5c 11 00 00       	call   80101ae5 <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 8a 30 80       	push   $0x80308a00
8010099a:	e8 e8 41 00 00       	call   80104b87 <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 6c 30 00 00       	call   80103a18 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 8a 30 80       	push   $0x80308a00
801009bb:	e8 35 42 00 00       	call   80104bf5 <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 04 10 00 00       	call   801019d2 <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 8a 30 80       	push   $0x80308a00
801009e3:	68 e0 89 30 80       	push   $0x803089e0
801009e8:	e8 40 3d 00 00       	call   8010472d <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 89 30 80    	mov    0x803089e0,%edx
801009f6:	a1 e4 89 30 80       	mov    0x803089e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 89 30 80       	mov    0x803089e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 89 30 80    	mov    %edx,0x803089e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 89 30 80 	movzbl -0x7fcf76a0(%eax),%eax
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
80100a2b:	a1 e0 89 30 80       	mov    0x803089e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 89 30 80       	mov    %eax,0x803089e0
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
80100a61:	68 00 8a 30 80       	push   $0x80308a00
80100a66:	e8 8a 41 00 00       	call   80104bf5 <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 59 0f 00 00       	call   801019d2 <ilock>
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
80100a92:	e8 4e 10 00 00       	call   80101ae5 <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 8a 30 80       	push   $0x80308a00
80100aa2:	e8 e0 40 00 00       	call   80104b87 <acquire>
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
80100adf:	68 00 8a 30 80       	push   $0x80308a00
80100ae4:	e8 0c 41 00 00       	call   80104bf5 <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 db 0e 00 00       	call   801019d2 <ilock>
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
80100b05:	c7 05 ec 89 30 80 00 	movl   $0x0,0x803089ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 37 a9 10 80       	push   $0x8010a937
80100b17:	68 00 8a 30 80       	push   $0x80308a00
80100b1c:	e8 44 40 00 00       	call   80104b65 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 8a 30 80 86 	movl   $0x80100a86,0x80308a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 8a 30 80 78 	movl   $0x80100978,0x80308a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 3f a9 10 80 	movl   $0x8010a93f,-0xc(%ebp)
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
80100b64:	c7 05 34 8a 30 80 01 	movl   $0x1,0x80308a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 9c 1a 00 00       	call   80102616 <ioapicenable>
80100b7a:	83 c4 10             	add    $0x10,%esp
}
80100b7d:	90                   	nop
80100b7e:	c9                   	leave  
80100b7f:	c3                   	ret    

80100b80 <exec>:
#define GUARD_SIZE (8*PGSIZE)
#define USERSTACKTOP (KERNBASE - GUARD_SIZE)

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
80100b89:	e8 8a 2e 00 00       	call   80103a18 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 8e 24 00 00       	call   80103024 <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 64 19 00 00       	call   80102505 <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 fe 24 00 00       	call   801030b0 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 55 a9 10 80       	push   $0x8010a955
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 d9 03 00 00       	jmp    80100fa5 <exec+0x425>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 fb 0d 00 00       	call   801019d2 <ilock>
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
80100bef:	e8 ca 12 00 00       	call   80101ebe <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 4e 03 00 00    	jne    80100f4e <exec+0x3ce>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 40 03 00 00    	jne    80100f51 <exec+0x3d1>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 aa 6f 00 00       	call   80107bc0 <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 31 03 00 00    	je     80100f54 <exec+0x3d4>
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
80100c4f:	e8 6a 12 00 00       	call   80101ebe <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 f7 02 00 00    	jne    80100f57 <exec+0x3d7>
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
80100c7d:	0f 82 d7 02 00 00    	jb     80100f5a <exec+0x3da>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 be 02 00 00    	jb     80100f5d <exec+0x3dd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 fd 72 00 00       	call   80107fb9 <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 94 02 00 00    	je     80100f60 <exec+0x3e0>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 84 02 00 00    	jne    80100f63 <exec+0x3e3>
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
80100cfd:	e8 ea 71 00 00       	call   80107eec <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 59 02 00 00    	js     80100f66 <exec+0x3e6>
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
80100d36:	e8 c8 0e 00 00       	call   80101c03 <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 6d 23 00 00       	call   801030b0 <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  //   goto bad;
  // sp = USERSTACKTOP;
  // if (allocuvm(pgdir, sp - PGSIZE, sp) == 0)
  //   goto bad;

  sz = KERNBASE - 1;
80100d4a:	c7 45 e0 ff ff ff 7f 	movl   $0x7fffffff,-0x20(%ebp)
  if((sz=allocuvm(pgdir, sz - PGSIZE, sz)) == 0)
80100d51:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d54:	2d 00 10 00 00       	sub    $0x1000,%eax
80100d59:	83 ec 04             	sub    $0x4,%esp
80100d5c:	ff 75 e0             	push   -0x20(%ebp)
80100d5f:	50                   	push   %eax
80100d60:	ff 75 d4             	push   -0x2c(%ebp)
80100d63:	e8 51 72 00 00       	call   80107fb9 <allocuvm>
80100d68:	83 c4 10             	add    $0x10,%esp
80100d6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d6e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d72:	0f 84 f1 01 00 00    	je     80100f69 <exec+0x3e9>
    goto bad;
  sz = PGROUNDDOWN(0x3000);
80100d78:	c7 45 e0 00 30 00 00 	movl   $0x3000,-0x20(%ebp)
  sp = KERNBASE - 1;
80100d7f:	c7 45 dc ff ff ff 7f 	movl   $0x7fffffff,-0x24(%ebp)
  
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d86:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d8d:	e9 96 00 00 00       	jmp    80100e28 <exec+0x2a8>
    if(argc >= MAXARG)
80100d92:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d96:	0f 87 d0 01 00 00    	ja     80100f6c <exec+0x3ec>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d9f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100da6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100da9:	01 d0                	add    %edx,%eax
80100dab:	8b 00                	mov    (%eax),%eax
80100dad:	83 ec 0c             	sub    $0xc,%esp
80100db0:	50                   	push   %eax
80100db1:	e8 95 42 00 00       	call   8010504b <strlen>
80100db6:	83 c4 10             	add    $0x10,%esp
80100db9:	89 c2                	mov    %eax,%edx
80100dbb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dbe:	29 d0                	sub    %edx,%eax
80100dc0:	83 e8 01             	sub    $0x1,%eax
80100dc3:	83 e0 fc             	and    $0xfffffffc,%eax
80100dc6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100dc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dd6:	01 d0                	add    %edx,%eax
80100dd8:	8b 00                	mov    (%eax),%eax
80100dda:	83 ec 0c             	sub    $0xc,%esp
80100ddd:	50                   	push   %eax
80100dde:	e8 68 42 00 00       	call   8010504b <strlen>
80100de3:	83 c4 10             	add    $0x10,%esp
80100de6:	83 c0 01             	add    $0x1,%eax
80100de9:	89 c2                	mov    %eax,%edx
80100deb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dee:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100df5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df8:	01 c8                	add    %ecx,%eax
80100dfa:	8b 00                	mov    (%eax),%eax
80100dfc:	52                   	push   %edx
80100dfd:	50                   	push   %eax
80100dfe:	ff 75 dc             	push   -0x24(%ebp)
80100e01:	ff 75 d4             	push   -0x2c(%ebp)
80100e04:	e8 9c 75 00 00       	call   801083a5 <copyout>
80100e09:	83 c4 10             	add    $0x10,%esp
80100e0c:	85 c0                	test   %eax,%eax
80100e0e:	0f 88 5b 01 00 00    	js     80100f6f <exec+0x3ef>
      goto bad;
    ustack[3+argc] = sp;
80100e14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e17:	8d 50 03             	lea    0x3(%eax),%edx
80100e1a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e1d:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e24:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e32:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e35:	01 d0                	add    %edx,%eax
80100e37:	8b 00                	mov    (%eax),%eax
80100e39:	85 c0                	test   %eax,%eax
80100e3b:	0f 85 51 ff ff ff    	jne    80100d92 <exec+0x212>
  }
  ustack[3+argc] = 0;
80100e41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e44:	83 c0 03             	add    $0x3,%eax
80100e47:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e4e:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e52:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e59:	ff ff ff 
  ustack[1] = argc;
80100e5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5f:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e68:	83 c0 01             	add    $0x1,%eax
80100e6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e72:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e75:	29 d0                	sub    %edx,%eax
80100e77:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	83 c0 04             	add    $0x4,%eax
80100e83:	c1 e0 02             	shl    $0x2,%eax
80100e86:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8c:	83 c0 04             	add    $0x4,%eax
80100e8f:	c1 e0 02             	shl    $0x2,%eax
80100e92:	50                   	push   %eax
80100e93:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100e99:	50                   	push   %eax
80100e9a:	ff 75 dc             	push   -0x24(%ebp)
80100e9d:	ff 75 d4             	push   -0x2c(%ebp)
80100ea0:	e8 00 75 00 00       	call   801083a5 <copyout>
80100ea5:	83 c4 10             	add    $0x10,%esp
80100ea8:	85 c0                	test   %eax,%eax
80100eaa:	0f 88 c2 00 00 00    	js     80100f72 <exec+0x3f2>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80100eb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ebc:	eb 17                	jmp    80100ed5 <exec+0x355>
    if(*s == '/')
80100ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ec1:	0f b6 00             	movzbl (%eax),%eax
80100ec4:	3c 2f                	cmp    $0x2f,%al
80100ec6:	75 09                	jne    80100ed1 <exec+0x351>
      last = s+1;
80100ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ecb:	83 c0 01             	add    $0x1,%eax
80100ece:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ed1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed8:	0f b6 00             	movzbl (%eax),%eax
80100edb:	84 c0                	test   %al,%al
80100edd:	75 df                	jne    80100ebe <exec+0x33e>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100edf:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ee2:	83 c0 6c             	add    $0x6c,%eax
80100ee5:	83 ec 04             	sub    $0x4,%esp
80100ee8:	6a 10                	push   $0x10
80100eea:	ff 75 f0             	push   -0x10(%ebp)
80100eed:	50                   	push   %eax
80100eee:	e8 0d 41 00 00       	call   80105000 <safestrcpy>
80100ef3:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100ef6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ef9:	8b 40 04             	mov    0x4(%eax),%eax
80100efc:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100eff:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f02:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f05:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f08:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f0b:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f0e:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f10:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f13:	8b 40 18             	mov    0x18(%eax),%eax
80100f16:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f1c:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f1f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f22:	8b 40 18             	mov    0x18(%eax),%eax
80100f25:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f28:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f2b:	83 ec 0c             	sub    $0xc,%esp
80100f2e:	ff 75 d0             	push   -0x30(%ebp)
80100f31:	e8 a7 6d 00 00       	call   80107cdd <switchuvm>
80100f36:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f39:	83 ec 0c             	sub    $0xc,%esp
80100f3c:	ff 75 cc             	push   -0x34(%ebp)
80100f3f:	e8 3e 72 00 00       	call   80108182 <freevm>
80100f44:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f47:	b8 00 00 00 00       	mov    $0x0,%eax
80100f4c:	eb 57                	jmp    80100fa5 <exec+0x425>
    goto bad;
80100f4e:	90                   	nop
80100f4f:	eb 22                	jmp    80100f73 <exec+0x3f3>
    goto bad;
80100f51:	90                   	nop
80100f52:	eb 1f                	jmp    80100f73 <exec+0x3f3>
    goto bad;
80100f54:	90                   	nop
80100f55:	eb 1c                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f57:	90                   	nop
80100f58:	eb 19                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f5a:	90                   	nop
80100f5b:	eb 16                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f5d:	90                   	nop
80100f5e:	eb 13                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f60:	90                   	nop
80100f61:	eb 10                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f63:	90                   	nop
80100f64:	eb 0d                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f66:	90                   	nop
80100f67:	eb 0a                	jmp    80100f73 <exec+0x3f3>
    goto bad;
80100f69:	90                   	nop
80100f6a:	eb 07                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f6c:	90                   	nop
80100f6d:	eb 04                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f6f:	90                   	nop
80100f70:	eb 01                	jmp    80100f73 <exec+0x3f3>
    goto bad;
80100f72:	90                   	nop

 bad:
  if(pgdir)
80100f73:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f77:	74 0e                	je     80100f87 <exec+0x407>
    freevm(pgdir);
80100f79:	83 ec 0c             	sub    $0xc,%esp
80100f7c:	ff 75 d4             	push   -0x2c(%ebp)
80100f7f:	e8 fe 71 00 00       	call   80108182 <freevm>
80100f84:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f87:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f8b:	74 13                	je     80100fa0 <exec+0x420>
    iunlockput(ip);
80100f8d:	83 ec 0c             	sub    $0xc,%esp
80100f90:	ff 75 d8             	push   -0x28(%ebp)
80100f93:	e8 6b 0c 00 00       	call   80101c03 <iunlockput>
80100f98:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f9b:	e8 10 21 00 00       	call   801030b0 <end_op>
  }
  return -1;
80100fa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fa5:	c9                   	leave  
80100fa6:	c3                   	ret    

80100fa7 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fa7:	55                   	push   %ebp
80100fa8:	89 e5                	mov    %esp,%ebp
80100faa:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fad:	83 ec 08             	sub    $0x8,%esp
80100fb0:	68 61 a9 10 80       	push   $0x8010a961
80100fb5:	68 a0 8a 30 80       	push   $0x80308aa0
80100fba:	e8 a6 3b 00 00       	call   80104b65 <initlock>
80100fbf:	83 c4 10             	add    $0x10,%esp
}
80100fc2:	90                   	nop
80100fc3:	c9                   	leave  
80100fc4:	c3                   	ret    

80100fc5 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fc5:	55                   	push   %ebp
80100fc6:	89 e5                	mov    %esp,%ebp
80100fc8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fcb:	83 ec 0c             	sub    $0xc,%esp
80100fce:	68 a0 8a 30 80       	push   $0x80308aa0
80100fd3:	e8 af 3b 00 00       	call   80104b87 <acquire>
80100fd8:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fdb:	c7 45 f4 d4 8a 30 80 	movl   $0x80308ad4,-0xc(%ebp)
80100fe2:	eb 2d                	jmp    80101011 <filealloc+0x4c>
    if(f->ref == 0){
80100fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fe7:	8b 40 04             	mov    0x4(%eax),%eax
80100fea:	85 c0                	test   %eax,%eax
80100fec:	75 1f                	jne    8010100d <filealloc+0x48>
      f->ref = 1;
80100fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ff1:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100ff8:	83 ec 0c             	sub    $0xc,%esp
80100ffb:	68 a0 8a 30 80       	push   $0x80308aa0
80101000:	e8 f0 3b 00 00       	call   80104bf5 <release>
80101005:	83 c4 10             	add    $0x10,%esp
      return f;
80101008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010100b:	eb 23                	jmp    80101030 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010100d:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101011:	b8 34 94 30 80       	mov    $0x80309434,%eax
80101016:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101019:	72 c9                	jb     80100fe4 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010101b:	83 ec 0c             	sub    $0xc,%esp
8010101e:	68 a0 8a 30 80       	push   $0x80308aa0
80101023:	e8 cd 3b 00 00       	call   80104bf5 <release>
80101028:	83 c4 10             	add    $0x10,%esp
  return 0;
8010102b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101030:	c9                   	leave  
80101031:	c3                   	ret    

80101032 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101032:	55                   	push   %ebp
80101033:	89 e5                	mov    %esp,%ebp
80101035:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101038:	83 ec 0c             	sub    $0xc,%esp
8010103b:	68 a0 8a 30 80       	push   $0x80308aa0
80101040:	e8 42 3b 00 00       	call   80104b87 <acquire>
80101045:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101048:	8b 45 08             	mov    0x8(%ebp),%eax
8010104b:	8b 40 04             	mov    0x4(%eax),%eax
8010104e:	85 c0                	test   %eax,%eax
80101050:	7f 0d                	jg     8010105f <filedup+0x2d>
    panic("filedup");
80101052:	83 ec 0c             	sub    $0xc,%esp
80101055:	68 68 a9 10 80       	push   $0x8010a968
8010105a:	e8 4a f5 ff ff       	call   801005a9 <panic>
  f->ref++;
8010105f:	8b 45 08             	mov    0x8(%ebp),%eax
80101062:	8b 40 04             	mov    0x4(%eax),%eax
80101065:	8d 50 01             	lea    0x1(%eax),%edx
80101068:	8b 45 08             	mov    0x8(%ebp),%eax
8010106b:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010106e:	83 ec 0c             	sub    $0xc,%esp
80101071:	68 a0 8a 30 80       	push   $0x80308aa0
80101076:	e8 7a 3b 00 00       	call   80104bf5 <release>
8010107b:	83 c4 10             	add    $0x10,%esp
  return f;
8010107e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101081:	c9                   	leave  
80101082:	c3                   	ret    

80101083 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101083:	55                   	push   %ebp
80101084:	89 e5                	mov    %esp,%ebp
80101086:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101089:	83 ec 0c             	sub    $0xc,%esp
8010108c:	68 a0 8a 30 80       	push   $0x80308aa0
80101091:	e8 f1 3a 00 00       	call   80104b87 <acquire>
80101096:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101099:	8b 45 08             	mov    0x8(%ebp),%eax
8010109c:	8b 40 04             	mov    0x4(%eax),%eax
8010109f:	85 c0                	test   %eax,%eax
801010a1:	7f 0d                	jg     801010b0 <fileclose+0x2d>
    panic("fileclose");
801010a3:	83 ec 0c             	sub    $0xc,%esp
801010a6:	68 70 a9 10 80       	push   $0x8010a970
801010ab:	e8 f9 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010b0:	8b 45 08             	mov    0x8(%ebp),%eax
801010b3:	8b 40 04             	mov    0x4(%eax),%eax
801010b6:	8d 50 ff             	lea    -0x1(%eax),%edx
801010b9:	8b 45 08             	mov    0x8(%ebp),%eax
801010bc:	89 50 04             	mov    %edx,0x4(%eax)
801010bf:	8b 45 08             	mov    0x8(%ebp),%eax
801010c2:	8b 40 04             	mov    0x4(%eax),%eax
801010c5:	85 c0                	test   %eax,%eax
801010c7:	7e 15                	jle    801010de <fileclose+0x5b>
    release(&ftable.lock);
801010c9:	83 ec 0c             	sub    $0xc,%esp
801010cc:	68 a0 8a 30 80       	push   $0x80308aa0
801010d1:	e8 1f 3b 00 00       	call   80104bf5 <release>
801010d6:	83 c4 10             	add    $0x10,%esp
801010d9:	e9 8b 00 00 00       	jmp    80101169 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010de:	8b 45 08             	mov    0x8(%ebp),%eax
801010e1:	8b 10                	mov    (%eax),%edx
801010e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010e6:	8b 50 04             	mov    0x4(%eax),%edx
801010e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010ec:	8b 50 08             	mov    0x8(%eax),%edx
801010ef:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010f2:	8b 50 0c             	mov    0xc(%eax),%edx
801010f5:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010f8:	8b 50 10             	mov    0x10(%eax),%edx
801010fb:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010fe:	8b 40 14             	mov    0x14(%eax),%eax
80101101:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101104:	8b 45 08             	mov    0x8(%ebp),%eax
80101107:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010110e:	8b 45 08             	mov    0x8(%ebp),%eax
80101111:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101117:	83 ec 0c             	sub    $0xc,%esp
8010111a:	68 a0 8a 30 80       	push   $0x80308aa0
8010111f:	e8 d1 3a 00 00       	call   80104bf5 <release>
80101124:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101127:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010112a:	83 f8 01             	cmp    $0x1,%eax
8010112d:	75 19                	jne    80101148 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010112f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101133:	0f be d0             	movsbl %al,%edx
80101136:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101139:	83 ec 08             	sub    $0x8,%esp
8010113c:	52                   	push   %edx
8010113d:	50                   	push   %eax
8010113e:	e8 64 25 00 00       	call   801036a7 <pipeclose>
80101143:	83 c4 10             	add    $0x10,%esp
80101146:	eb 21                	jmp    80101169 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101148:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010114b:	83 f8 02             	cmp    $0x2,%eax
8010114e:	75 19                	jne    80101169 <fileclose+0xe6>
    begin_op();
80101150:	e8 cf 1e 00 00       	call   80103024 <begin_op>
    iput(ff.ip);
80101155:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101158:	83 ec 0c             	sub    $0xc,%esp
8010115b:	50                   	push   %eax
8010115c:	e8 d2 09 00 00       	call   80101b33 <iput>
80101161:	83 c4 10             	add    $0x10,%esp
    end_op();
80101164:	e8 47 1f 00 00       	call   801030b0 <end_op>
  }
}
80101169:	c9                   	leave  
8010116a:	c3                   	ret    

8010116b <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010116b:	55                   	push   %ebp
8010116c:	89 e5                	mov    %esp,%ebp
8010116e:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101171:	8b 45 08             	mov    0x8(%ebp),%eax
80101174:	8b 00                	mov    (%eax),%eax
80101176:	83 f8 02             	cmp    $0x2,%eax
80101179:	75 40                	jne    801011bb <filestat+0x50>
    ilock(f->ip);
8010117b:	8b 45 08             	mov    0x8(%ebp),%eax
8010117e:	8b 40 10             	mov    0x10(%eax),%eax
80101181:	83 ec 0c             	sub    $0xc,%esp
80101184:	50                   	push   %eax
80101185:	e8 48 08 00 00       	call   801019d2 <ilock>
8010118a:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010118d:	8b 45 08             	mov    0x8(%ebp),%eax
80101190:	8b 40 10             	mov    0x10(%eax),%eax
80101193:	83 ec 08             	sub    $0x8,%esp
80101196:	ff 75 0c             	push   0xc(%ebp)
80101199:	50                   	push   %eax
8010119a:	e8 d9 0c 00 00       	call   80101e78 <stati>
8010119f:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011a2:	8b 45 08             	mov    0x8(%ebp),%eax
801011a5:	8b 40 10             	mov    0x10(%eax),%eax
801011a8:	83 ec 0c             	sub    $0xc,%esp
801011ab:	50                   	push   %eax
801011ac:	e8 34 09 00 00       	call   80101ae5 <iunlock>
801011b1:	83 c4 10             	add    $0x10,%esp
    return 0;
801011b4:	b8 00 00 00 00       	mov    $0x0,%eax
801011b9:	eb 05                	jmp    801011c0 <filestat+0x55>
  }
  return -1;
801011bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011c0:	c9                   	leave  
801011c1:	c3                   	ret    

801011c2 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011c2:	55                   	push   %ebp
801011c3:	89 e5                	mov    %esp,%ebp
801011c5:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011c8:	8b 45 08             	mov    0x8(%ebp),%eax
801011cb:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011cf:	84 c0                	test   %al,%al
801011d1:	75 0a                	jne    801011dd <fileread+0x1b>
    return -1;
801011d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011d8:	e9 9b 00 00 00       	jmp    80101278 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011dd:	8b 45 08             	mov    0x8(%ebp),%eax
801011e0:	8b 00                	mov    (%eax),%eax
801011e2:	83 f8 01             	cmp    $0x1,%eax
801011e5:	75 1a                	jne    80101201 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011e7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ea:	8b 40 0c             	mov    0xc(%eax),%eax
801011ed:	83 ec 04             	sub    $0x4,%esp
801011f0:	ff 75 10             	push   0x10(%ebp)
801011f3:	ff 75 0c             	push   0xc(%ebp)
801011f6:	50                   	push   %eax
801011f7:	e8 58 26 00 00       	call   80103854 <piperead>
801011fc:	83 c4 10             	add    $0x10,%esp
801011ff:	eb 77                	jmp    80101278 <fileread+0xb6>
  if(f->type == FD_INODE){
80101201:	8b 45 08             	mov    0x8(%ebp),%eax
80101204:	8b 00                	mov    (%eax),%eax
80101206:	83 f8 02             	cmp    $0x2,%eax
80101209:	75 60                	jne    8010126b <fileread+0xa9>
    ilock(f->ip);
8010120b:	8b 45 08             	mov    0x8(%ebp),%eax
8010120e:	8b 40 10             	mov    0x10(%eax),%eax
80101211:	83 ec 0c             	sub    $0xc,%esp
80101214:	50                   	push   %eax
80101215:	e8 b8 07 00 00       	call   801019d2 <ilock>
8010121a:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010121d:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101220:	8b 45 08             	mov    0x8(%ebp),%eax
80101223:	8b 50 14             	mov    0x14(%eax),%edx
80101226:	8b 45 08             	mov    0x8(%ebp),%eax
80101229:	8b 40 10             	mov    0x10(%eax),%eax
8010122c:	51                   	push   %ecx
8010122d:	52                   	push   %edx
8010122e:	ff 75 0c             	push   0xc(%ebp)
80101231:	50                   	push   %eax
80101232:	e8 87 0c 00 00       	call   80101ebe <readi>
80101237:	83 c4 10             	add    $0x10,%esp
8010123a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010123d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101241:	7e 11                	jle    80101254 <fileread+0x92>
      f->off += r;
80101243:	8b 45 08             	mov    0x8(%ebp),%eax
80101246:	8b 50 14             	mov    0x14(%eax),%edx
80101249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010124c:	01 c2                	add    %eax,%edx
8010124e:	8b 45 08             	mov    0x8(%ebp),%eax
80101251:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101254:	8b 45 08             	mov    0x8(%ebp),%eax
80101257:	8b 40 10             	mov    0x10(%eax),%eax
8010125a:	83 ec 0c             	sub    $0xc,%esp
8010125d:	50                   	push   %eax
8010125e:	e8 82 08 00 00       	call   80101ae5 <iunlock>
80101263:	83 c4 10             	add    $0x10,%esp
    return r;
80101266:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101269:	eb 0d                	jmp    80101278 <fileread+0xb6>
  }
  panic("fileread");
8010126b:	83 ec 0c             	sub    $0xc,%esp
8010126e:	68 7a a9 10 80       	push   $0x8010a97a
80101273:	e8 31 f3 ff ff       	call   801005a9 <panic>
}
80101278:	c9                   	leave  
80101279:	c3                   	ret    

8010127a <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010127a:	55                   	push   %ebp
8010127b:	89 e5                	mov    %esp,%ebp
8010127d:	53                   	push   %ebx
8010127e:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101281:	8b 45 08             	mov    0x8(%ebp),%eax
80101284:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101288:	84 c0                	test   %al,%al
8010128a:	75 0a                	jne    80101296 <filewrite+0x1c>
    return -1;
8010128c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101291:	e9 1b 01 00 00       	jmp    801013b1 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101296:	8b 45 08             	mov    0x8(%ebp),%eax
80101299:	8b 00                	mov    (%eax),%eax
8010129b:	83 f8 01             	cmp    $0x1,%eax
8010129e:	75 1d                	jne    801012bd <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012a0:	8b 45 08             	mov    0x8(%ebp),%eax
801012a3:	8b 40 0c             	mov    0xc(%eax),%eax
801012a6:	83 ec 04             	sub    $0x4,%esp
801012a9:	ff 75 10             	push   0x10(%ebp)
801012ac:	ff 75 0c             	push   0xc(%ebp)
801012af:	50                   	push   %eax
801012b0:	e8 9d 24 00 00       	call   80103752 <pipewrite>
801012b5:	83 c4 10             	add    $0x10,%esp
801012b8:	e9 f4 00 00 00       	jmp    801013b1 <filewrite+0x137>
  if(f->type == FD_INODE){
801012bd:	8b 45 08             	mov    0x8(%ebp),%eax
801012c0:	8b 00                	mov    (%eax),%eax
801012c2:	83 f8 02             	cmp    $0x2,%eax
801012c5:	0f 85 d9 00 00 00    	jne    801013a4 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012cb:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012d9:	e9 a3 00 00 00       	jmp    80101381 <filewrite+0x107>
      int n1 = n - i;
801012de:	8b 45 10             	mov    0x10(%ebp),%eax
801012e1:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012ea:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012ed:	7e 06                	jle    801012f5 <filewrite+0x7b>
        n1 = max;
801012ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012f2:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012f5:	e8 2a 1d 00 00       	call   80103024 <begin_op>
      ilock(f->ip);
801012fa:	8b 45 08             	mov    0x8(%ebp),%eax
801012fd:	8b 40 10             	mov    0x10(%eax),%eax
80101300:	83 ec 0c             	sub    $0xc,%esp
80101303:	50                   	push   %eax
80101304:	e8 c9 06 00 00       	call   801019d2 <ilock>
80101309:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010130c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010130f:	8b 45 08             	mov    0x8(%ebp),%eax
80101312:	8b 50 14             	mov    0x14(%eax),%edx
80101315:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101318:	8b 45 0c             	mov    0xc(%ebp),%eax
8010131b:	01 c3                	add    %eax,%ebx
8010131d:	8b 45 08             	mov    0x8(%ebp),%eax
80101320:	8b 40 10             	mov    0x10(%eax),%eax
80101323:	51                   	push   %ecx
80101324:	52                   	push   %edx
80101325:	53                   	push   %ebx
80101326:	50                   	push   %eax
80101327:	e8 e7 0c 00 00       	call   80102013 <writei>
8010132c:	83 c4 10             	add    $0x10,%esp
8010132f:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101332:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101336:	7e 11                	jle    80101349 <filewrite+0xcf>
        f->off += r;
80101338:	8b 45 08             	mov    0x8(%ebp),%eax
8010133b:	8b 50 14             	mov    0x14(%eax),%edx
8010133e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101341:	01 c2                	add    %eax,%edx
80101343:	8b 45 08             	mov    0x8(%ebp),%eax
80101346:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101349:	8b 45 08             	mov    0x8(%ebp),%eax
8010134c:	8b 40 10             	mov    0x10(%eax),%eax
8010134f:	83 ec 0c             	sub    $0xc,%esp
80101352:	50                   	push   %eax
80101353:	e8 8d 07 00 00       	call   80101ae5 <iunlock>
80101358:	83 c4 10             	add    $0x10,%esp
      end_op();
8010135b:	e8 50 1d 00 00       	call   801030b0 <end_op>

      if(r < 0)
80101360:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101364:	78 29                	js     8010138f <filewrite+0x115>
        break;
      if(r != n1)
80101366:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101369:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010136c:	74 0d                	je     8010137b <filewrite+0x101>
        panic("short filewrite");
8010136e:	83 ec 0c             	sub    $0xc,%esp
80101371:	68 83 a9 10 80       	push   $0x8010a983
80101376:	e8 2e f2 ff ff       	call   801005a9 <panic>
      i += r;
8010137b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010137e:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101384:	3b 45 10             	cmp    0x10(%ebp),%eax
80101387:	0f 8c 51 ff ff ff    	jl     801012de <filewrite+0x64>
8010138d:	eb 01                	jmp    80101390 <filewrite+0x116>
        break;
8010138f:	90                   	nop
    }
    return i == n ? n : -1;
80101390:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101393:	3b 45 10             	cmp    0x10(%ebp),%eax
80101396:	75 05                	jne    8010139d <filewrite+0x123>
80101398:	8b 45 10             	mov    0x10(%ebp),%eax
8010139b:	eb 14                	jmp    801013b1 <filewrite+0x137>
8010139d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013a2:	eb 0d                	jmp    801013b1 <filewrite+0x137>
  }
  panic("filewrite");
801013a4:	83 ec 0c             	sub    $0xc,%esp
801013a7:	68 93 a9 10 80       	push   $0x8010a993
801013ac:	e8 f8 f1 ff ff       	call   801005a9 <panic>
}
801013b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013b4:	c9                   	leave  
801013b5:	c3                   	ret    

801013b6 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013b6:	55                   	push   %ebp
801013b7:	89 e5                	mov    %esp,%ebp
801013b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013bc:	8b 45 08             	mov    0x8(%ebp),%eax
801013bf:	83 ec 08             	sub    $0x8,%esp
801013c2:	6a 01                	push   $0x1
801013c4:	50                   	push   %eax
801013c5:	e8 37 ee ff ff       	call   80100201 <bread>
801013ca:	83 c4 10             	add    $0x10,%esp
801013cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d3:	83 c0 5c             	add    $0x5c,%eax
801013d6:	83 ec 04             	sub    $0x4,%esp
801013d9:	6a 1c                	push   $0x1c
801013db:	50                   	push   %eax
801013dc:	ff 75 0c             	push   0xc(%ebp)
801013df:	e8 d8 3a 00 00       	call   80104ebc <memmove>
801013e4:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013e7:	83 ec 0c             	sub    $0xc,%esp
801013ea:	ff 75 f4             	push   -0xc(%ebp)
801013ed:	e8 91 ee ff ff       	call   80100283 <brelse>
801013f2:	83 c4 10             	add    $0x10,%esp
}
801013f5:	90                   	nop
801013f6:	c9                   	leave  
801013f7:	c3                   	ret    

801013f8 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013f8:	55                   	push   %ebp
801013f9:	89 e5                	mov    %esp,%ebp
801013fb:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
801013fe:	8b 55 0c             	mov    0xc(%ebp),%edx
80101401:	8b 45 08             	mov    0x8(%ebp),%eax
80101404:	83 ec 08             	sub    $0x8,%esp
80101407:	52                   	push   %edx
80101408:	50                   	push   %eax
80101409:	e8 f3 ed ff ff       	call   80100201 <bread>
8010140e:	83 c4 10             	add    $0x10,%esp
80101411:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101417:	83 c0 5c             	add    $0x5c,%eax
8010141a:	83 ec 04             	sub    $0x4,%esp
8010141d:	68 00 02 00 00       	push   $0x200
80101422:	6a 00                	push   $0x0
80101424:	50                   	push   %eax
80101425:	e8 d3 39 00 00       	call   80104dfd <memset>
8010142a:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010142d:	83 ec 0c             	sub    $0xc,%esp
80101430:	ff 75 f4             	push   -0xc(%ebp)
80101433:	e8 25 1e 00 00       	call   8010325d <log_write>
80101438:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010143b:	83 ec 0c             	sub    $0xc,%esp
8010143e:	ff 75 f4             	push   -0xc(%ebp)
80101441:	e8 3d ee ff ff       	call   80100283 <brelse>
80101446:	83 c4 10             	add    $0x10,%esp
}
80101449:	90                   	nop
8010144a:	c9                   	leave  
8010144b:	c3                   	ret    

8010144c <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010144c:	55                   	push   %ebp
8010144d:	89 e5                	mov    %esp,%ebp
8010144f:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101452:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101459:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101460:	e9 0b 01 00 00       	jmp    80101570 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101468:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010146e:	85 c0                	test   %eax,%eax
80101470:	0f 48 c2             	cmovs  %edx,%eax
80101473:	c1 f8 0c             	sar    $0xc,%eax
80101476:	89 c2                	mov    %eax,%edx
80101478:	a1 58 94 30 80       	mov    0x80309458,%eax
8010147d:	01 d0                	add    %edx,%eax
8010147f:	83 ec 08             	sub    $0x8,%esp
80101482:	50                   	push   %eax
80101483:	ff 75 08             	push   0x8(%ebp)
80101486:	e8 76 ed ff ff       	call   80100201 <bread>
8010148b:	83 c4 10             	add    $0x10,%esp
8010148e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101491:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101498:	e9 9e 00 00 00       	jmp    8010153b <balloc+0xef>
      m = 1 << (bi % 8);
8010149d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a0:	83 e0 07             	and    $0x7,%eax
801014a3:	ba 01 00 00 00       	mov    $0x1,%edx
801014a8:	89 c1                	mov    %eax,%ecx
801014aa:	d3 e2                	shl    %cl,%edx
801014ac:	89 d0                	mov    %edx,%eax
801014ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b4:	8d 50 07             	lea    0x7(%eax),%edx
801014b7:	85 c0                	test   %eax,%eax
801014b9:	0f 48 c2             	cmovs  %edx,%eax
801014bc:	c1 f8 03             	sar    $0x3,%eax
801014bf:	89 c2                	mov    %eax,%edx
801014c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014c4:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014c9:	0f b6 c0             	movzbl %al,%eax
801014cc:	23 45 e8             	and    -0x18(%ebp),%eax
801014cf:	85 c0                	test   %eax,%eax
801014d1:	75 64                	jne    80101537 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d6:	8d 50 07             	lea    0x7(%eax),%edx
801014d9:	85 c0                	test   %eax,%eax
801014db:	0f 48 c2             	cmovs  %edx,%eax
801014de:	c1 f8 03             	sar    $0x3,%eax
801014e1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014e4:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801014e9:	89 d1                	mov    %edx,%ecx
801014eb:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014ee:	09 ca                	or     %ecx,%edx
801014f0:	89 d1                	mov    %edx,%ecx
801014f2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014f5:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
801014f9:	83 ec 0c             	sub    $0xc,%esp
801014fc:	ff 75 ec             	push   -0x14(%ebp)
801014ff:	e8 59 1d 00 00       	call   8010325d <log_write>
80101504:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101507:	83 ec 0c             	sub    $0xc,%esp
8010150a:	ff 75 ec             	push   -0x14(%ebp)
8010150d:	e8 71 ed ff ff       	call   80100283 <brelse>
80101512:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101515:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010151b:	01 c2                	add    %eax,%edx
8010151d:	8b 45 08             	mov    0x8(%ebp),%eax
80101520:	83 ec 08             	sub    $0x8,%esp
80101523:	52                   	push   %edx
80101524:	50                   	push   %eax
80101525:	e8 ce fe ff ff       	call   801013f8 <bzero>
8010152a:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010152d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101533:	01 d0                	add    %edx,%eax
80101535:	eb 57                	jmp    8010158e <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101537:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010153b:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101542:	7f 17                	jg     8010155b <balloc+0x10f>
80101544:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101547:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154a:	01 d0                	add    %edx,%eax
8010154c:	89 c2                	mov    %eax,%edx
8010154e:	a1 40 94 30 80       	mov    0x80309440,%eax
80101553:	39 c2                	cmp    %eax,%edx
80101555:	0f 82 42 ff ff ff    	jb     8010149d <balloc+0x51>
      }
    }
    brelse(bp);
8010155b:	83 ec 0c             	sub    $0xc,%esp
8010155e:	ff 75 ec             	push   -0x14(%ebp)
80101561:	e8 1d ed ff ff       	call   80100283 <brelse>
80101566:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101569:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101570:	8b 15 40 94 30 80    	mov    0x80309440,%edx
80101576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101579:	39 c2                	cmp    %eax,%edx
8010157b:	0f 87 e4 fe ff ff    	ja     80101465 <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101581:	83 ec 0c             	sub    $0xc,%esp
80101584:	68 a0 a9 10 80       	push   $0x8010a9a0
80101589:	e8 1b f0 ff ff       	call   801005a9 <panic>
}
8010158e:	c9                   	leave  
8010158f:	c3                   	ret    

80101590 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101590:	55                   	push   %ebp
80101591:	89 e5                	mov    %esp,%ebp
80101593:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101596:	83 ec 08             	sub    $0x8,%esp
80101599:	68 40 94 30 80       	push   $0x80309440
8010159e:	ff 75 08             	push   0x8(%ebp)
801015a1:	e8 10 fe ff ff       	call   801013b6 <readsb>
801015a6:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801015ac:	c1 e8 0c             	shr    $0xc,%eax
801015af:	89 c2                	mov    %eax,%edx
801015b1:	a1 58 94 30 80       	mov    0x80309458,%eax
801015b6:	01 c2                	add    %eax,%edx
801015b8:	8b 45 08             	mov    0x8(%ebp),%eax
801015bb:	83 ec 08             	sub    $0x8,%esp
801015be:	52                   	push   %edx
801015bf:	50                   	push   %eax
801015c0:	e8 3c ec ff ff       	call   80100201 <bread>
801015c5:	83 c4 10             	add    $0x10,%esp
801015c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801015ce:	25 ff 0f 00 00       	and    $0xfff,%eax
801015d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d9:	83 e0 07             	and    $0x7,%eax
801015dc:	ba 01 00 00 00       	mov    $0x1,%edx
801015e1:	89 c1                	mov    %eax,%ecx
801015e3:	d3 e2                	shl    %cl,%edx
801015e5:	89 d0                	mov    %edx,%eax
801015e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ed:	8d 50 07             	lea    0x7(%eax),%edx
801015f0:	85 c0                	test   %eax,%eax
801015f2:	0f 48 c2             	cmovs  %edx,%eax
801015f5:	c1 f8 03             	sar    $0x3,%eax
801015f8:	89 c2                	mov    %eax,%edx
801015fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015fd:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101602:	0f b6 c0             	movzbl %al,%eax
80101605:	23 45 ec             	and    -0x14(%ebp),%eax
80101608:	85 c0                	test   %eax,%eax
8010160a:	75 0d                	jne    80101619 <bfree+0x89>
    panic("freeing free block");
8010160c:	83 ec 0c             	sub    $0xc,%esp
8010160f:	68 b6 a9 10 80       	push   $0x8010a9b6
80101614:	e8 90 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101619:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010161c:	8d 50 07             	lea    0x7(%eax),%edx
8010161f:	85 c0                	test   %eax,%eax
80101621:	0f 48 c2             	cmovs  %edx,%eax
80101624:	c1 f8 03             	sar    $0x3,%eax
80101627:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010162a:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010162f:	89 d1                	mov    %edx,%ecx
80101631:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101634:	f7 d2                	not    %edx
80101636:	21 ca                	and    %ecx,%edx
80101638:	89 d1                	mov    %edx,%ecx
8010163a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163d:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101641:	83 ec 0c             	sub    $0xc,%esp
80101644:	ff 75 f4             	push   -0xc(%ebp)
80101647:	e8 11 1c 00 00       	call   8010325d <log_write>
8010164c:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010164f:	83 ec 0c             	sub    $0xc,%esp
80101652:	ff 75 f4             	push   -0xc(%ebp)
80101655:	e8 29 ec ff ff       	call   80100283 <brelse>
8010165a:	83 c4 10             	add    $0x10,%esp
}
8010165d:	90                   	nop
8010165e:	c9                   	leave  
8010165f:	c3                   	ret    

80101660 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101660:	55                   	push   %ebp
80101661:	89 e5                	mov    %esp,%ebp
80101663:	57                   	push   %edi
80101664:	56                   	push   %esi
80101665:	53                   	push   %ebx
80101666:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101669:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101670:	83 ec 08             	sub    $0x8,%esp
80101673:	68 c9 a9 10 80       	push   $0x8010a9c9
80101678:	68 60 94 30 80       	push   $0x80309460
8010167d:	e8 e3 34 00 00       	call   80104b65 <initlock>
80101682:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101685:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010168c:	eb 2d                	jmp    801016bb <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
8010168e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101691:	89 d0                	mov    %edx,%eax
80101693:	c1 e0 03             	shl    $0x3,%eax
80101696:	01 d0                	add    %edx,%eax
80101698:	c1 e0 04             	shl    $0x4,%eax
8010169b:	83 c0 30             	add    $0x30,%eax
8010169e:	05 60 94 30 80       	add    $0x80309460,%eax
801016a3:	83 c0 10             	add    $0x10,%eax
801016a6:	83 ec 08             	sub    $0x8,%esp
801016a9:	68 d0 a9 10 80       	push   $0x8010a9d0
801016ae:	50                   	push   %eax
801016af:	e8 54 33 00 00       	call   80104a08 <initsleeplock>
801016b4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016b7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016bb:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016bf:	7e cd                	jle    8010168e <iinit+0x2e>
  }

  readsb(dev, &sb);
801016c1:	83 ec 08             	sub    $0x8,%esp
801016c4:	68 40 94 30 80       	push   $0x80309440
801016c9:	ff 75 08             	push   0x8(%ebp)
801016cc:	e8 e5 fc ff ff       	call   801013b6 <readsb>
801016d1:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016d4:	a1 58 94 30 80       	mov    0x80309458,%eax
801016d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016dc:	8b 3d 54 94 30 80    	mov    0x80309454,%edi
801016e2:	8b 35 50 94 30 80    	mov    0x80309450,%esi
801016e8:	8b 1d 4c 94 30 80    	mov    0x8030944c,%ebx
801016ee:	8b 0d 48 94 30 80    	mov    0x80309448,%ecx
801016f4:	8b 15 44 94 30 80    	mov    0x80309444,%edx
801016fa:	a1 40 94 30 80       	mov    0x80309440,%eax
801016ff:	ff 75 d4             	push   -0x2c(%ebp)
80101702:	57                   	push   %edi
80101703:	56                   	push   %esi
80101704:	53                   	push   %ebx
80101705:	51                   	push   %ecx
80101706:	52                   	push   %edx
80101707:	50                   	push   %eax
80101708:	68 d8 a9 10 80       	push   $0x8010a9d8
8010170d:	e8 e2 ec ff ff       	call   801003f4 <cprintf>
80101712:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101715:	90                   	nop
80101716:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101719:	5b                   	pop    %ebx
8010171a:	5e                   	pop    %esi
8010171b:	5f                   	pop    %edi
8010171c:	5d                   	pop    %ebp
8010171d:	c3                   	ret    

8010171e <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010171e:	55                   	push   %ebp
8010171f:	89 e5                	mov    %esp,%ebp
80101721:	83 ec 28             	sub    $0x28,%esp
80101724:	8b 45 0c             	mov    0xc(%ebp),%eax
80101727:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010172b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101732:	e9 9e 00 00 00       	jmp    801017d5 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010173a:	c1 e8 03             	shr    $0x3,%eax
8010173d:	89 c2                	mov    %eax,%edx
8010173f:	a1 54 94 30 80       	mov    0x80309454,%eax
80101744:	01 d0                	add    %edx,%eax
80101746:	83 ec 08             	sub    $0x8,%esp
80101749:	50                   	push   %eax
8010174a:	ff 75 08             	push   0x8(%ebp)
8010174d:	e8 af ea ff ff       	call   80100201 <bread>
80101752:	83 c4 10             	add    $0x10,%esp
80101755:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101758:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010175e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101761:	83 e0 07             	and    $0x7,%eax
80101764:	c1 e0 06             	shl    $0x6,%eax
80101767:	01 d0                	add    %edx,%eax
80101769:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010176c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010176f:	0f b7 00             	movzwl (%eax),%eax
80101772:	66 85 c0             	test   %ax,%ax
80101775:	75 4c                	jne    801017c3 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101777:	83 ec 04             	sub    $0x4,%esp
8010177a:	6a 40                	push   $0x40
8010177c:	6a 00                	push   $0x0
8010177e:	ff 75 ec             	push   -0x14(%ebp)
80101781:	e8 77 36 00 00       	call   80104dfd <memset>
80101786:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101789:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010178c:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101790:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101793:	83 ec 0c             	sub    $0xc,%esp
80101796:	ff 75 f0             	push   -0x10(%ebp)
80101799:	e8 bf 1a 00 00       	call   8010325d <log_write>
8010179e:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017a1:	83 ec 0c             	sub    $0xc,%esp
801017a4:	ff 75 f0             	push   -0x10(%ebp)
801017a7:	e8 d7 ea ff ff       	call   80100283 <brelse>
801017ac:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b2:	83 ec 08             	sub    $0x8,%esp
801017b5:	50                   	push   %eax
801017b6:	ff 75 08             	push   0x8(%ebp)
801017b9:	e8 f8 00 00 00       	call   801018b6 <iget>
801017be:	83 c4 10             	add    $0x10,%esp
801017c1:	eb 30                	jmp    801017f3 <ialloc+0xd5>
    }
    brelse(bp);
801017c3:	83 ec 0c             	sub    $0xc,%esp
801017c6:	ff 75 f0             	push   -0x10(%ebp)
801017c9:	e8 b5 ea ff ff       	call   80100283 <brelse>
801017ce:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017d5:	8b 15 48 94 30 80    	mov    0x80309448,%edx
801017db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017de:	39 c2                	cmp    %eax,%edx
801017e0:	0f 87 51 ff ff ff    	ja     80101737 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017e6:	83 ec 0c             	sub    $0xc,%esp
801017e9:	68 2b aa 10 80       	push   $0x8010aa2b
801017ee:	e8 b6 ed ff ff       	call   801005a9 <panic>
}
801017f3:	c9                   	leave  
801017f4:	c3                   	ret    

801017f5 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801017f5:	55                   	push   %ebp
801017f6:	89 e5                	mov    %esp,%ebp
801017f8:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017fb:	8b 45 08             	mov    0x8(%ebp),%eax
801017fe:	8b 40 04             	mov    0x4(%eax),%eax
80101801:	c1 e8 03             	shr    $0x3,%eax
80101804:	89 c2                	mov    %eax,%edx
80101806:	a1 54 94 30 80       	mov    0x80309454,%eax
8010180b:	01 c2                	add    %eax,%edx
8010180d:	8b 45 08             	mov    0x8(%ebp),%eax
80101810:	8b 00                	mov    (%eax),%eax
80101812:	83 ec 08             	sub    $0x8,%esp
80101815:	52                   	push   %edx
80101816:	50                   	push   %eax
80101817:	e8 e5 e9 ff ff       	call   80100201 <bread>
8010181c:	83 c4 10             	add    $0x10,%esp
8010181f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101825:	8d 50 5c             	lea    0x5c(%eax),%edx
80101828:	8b 45 08             	mov    0x8(%ebp),%eax
8010182b:	8b 40 04             	mov    0x4(%eax),%eax
8010182e:	83 e0 07             	and    $0x7,%eax
80101831:	c1 e0 06             	shl    $0x6,%eax
80101834:	01 d0                	add    %edx,%eax
80101836:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101839:	8b 45 08             	mov    0x8(%ebp),%eax
8010183c:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101840:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101843:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101846:	8b 45 08             	mov    0x8(%ebp),%eax
80101849:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010184d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101850:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101854:	8b 45 08             	mov    0x8(%ebp),%eax
80101857:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010185b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101862:	8b 45 08             	mov    0x8(%ebp),%eax
80101865:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101869:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010186c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101870:	8b 45 08             	mov    0x8(%ebp),%eax
80101873:	8b 50 58             	mov    0x58(%eax),%edx
80101876:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101879:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010187c:	8b 45 08             	mov    0x8(%ebp),%eax
8010187f:	8d 50 5c             	lea    0x5c(%eax),%edx
80101882:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101885:	83 c0 0c             	add    $0xc,%eax
80101888:	83 ec 04             	sub    $0x4,%esp
8010188b:	6a 34                	push   $0x34
8010188d:	52                   	push   %edx
8010188e:	50                   	push   %eax
8010188f:	e8 28 36 00 00       	call   80104ebc <memmove>
80101894:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101897:	83 ec 0c             	sub    $0xc,%esp
8010189a:	ff 75 f4             	push   -0xc(%ebp)
8010189d:	e8 bb 19 00 00       	call   8010325d <log_write>
801018a2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018a5:	83 ec 0c             	sub    $0xc,%esp
801018a8:	ff 75 f4             	push   -0xc(%ebp)
801018ab:	e8 d3 e9 ff ff       	call   80100283 <brelse>
801018b0:	83 c4 10             	add    $0x10,%esp
}
801018b3:	90                   	nop
801018b4:	c9                   	leave  
801018b5:	c3                   	ret    

801018b6 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018b6:	55                   	push   %ebp
801018b7:	89 e5                	mov    %esp,%ebp
801018b9:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018bc:	83 ec 0c             	sub    $0xc,%esp
801018bf:	68 60 94 30 80       	push   $0x80309460
801018c4:	e8 be 32 00 00       	call   80104b87 <acquire>
801018c9:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018cc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018d3:	c7 45 f4 94 94 30 80 	movl   $0x80309494,-0xc(%ebp)
801018da:	eb 60                	jmp    8010193c <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018df:	8b 40 08             	mov    0x8(%eax),%eax
801018e2:	85 c0                	test   %eax,%eax
801018e4:	7e 39                	jle    8010191f <iget+0x69>
801018e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e9:	8b 00                	mov    (%eax),%eax
801018eb:	39 45 08             	cmp    %eax,0x8(%ebp)
801018ee:	75 2f                	jne    8010191f <iget+0x69>
801018f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f3:	8b 40 04             	mov    0x4(%eax),%eax
801018f6:	39 45 0c             	cmp    %eax,0xc(%ebp)
801018f9:	75 24                	jne    8010191f <iget+0x69>
      ip->ref++;
801018fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fe:	8b 40 08             	mov    0x8(%eax),%eax
80101901:	8d 50 01             	lea    0x1(%eax),%edx
80101904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101907:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010190a:	83 ec 0c             	sub    $0xc,%esp
8010190d:	68 60 94 30 80       	push   $0x80309460
80101912:	e8 de 32 00 00       	call   80104bf5 <release>
80101917:	83 c4 10             	add    $0x10,%esp
      return ip;
8010191a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191d:	eb 77                	jmp    80101996 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010191f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101923:	75 10                	jne    80101935 <iget+0x7f>
80101925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101928:	8b 40 08             	mov    0x8(%eax),%eax
8010192b:	85 c0                	test   %eax,%eax
8010192d:	75 06                	jne    80101935 <iget+0x7f>
      empty = ip;
8010192f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101932:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101935:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010193c:	81 7d f4 b4 b0 30 80 	cmpl   $0x8030b0b4,-0xc(%ebp)
80101943:	72 97                	jb     801018dc <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101945:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101949:	75 0d                	jne    80101958 <iget+0xa2>
    panic("iget: no inodes");
8010194b:	83 ec 0c             	sub    $0xc,%esp
8010194e:	68 3d aa 10 80       	push   $0x8010aa3d
80101953:	e8 51 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101958:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010195b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010195e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101961:	8b 55 08             	mov    0x8(%ebp),%edx
80101964:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101969:	8b 55 0c             	mov    0xc(%ebp),%edx
8010196c:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010196f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101972:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197c:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101983:	83 ec 0c             	sub    $0xc,%esp
80101986:	68 60 94 30 80       	push   $0x80309460
8010198b:	e8 65 32 00 00       	call   80104bf5 <release>
80101990:	83 c4 10             	add    $0x10,%esp

  return ip;
80101993:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101996:	c9                   	leave  
80101997:	c3                   	ret    

80101998 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101998:	55                   	push   %ebp
80101999:	89 e5                	mov    %esp,%ebp
8010199b:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
8010199e:	83 ec 0c             	sub    $0xc,%esp
801019a1:	68 60 94 30 80       	push   $0x80309460
801019a6:	e8 dc 31 00 00       	call   80104b87 <acquire>
801019ab:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019ae:	8b 45 08             	mov    0x8(%ebp),%eax
801019b1:	8b 40 08             	mov    0x8(%eax),%eax
801019b4:	8d 50 01             	lea    0x1(%eax),%edx
801019b7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ba:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019bd:	83 ec 0c             	sub    $0xc,%esp
801019c0:	68 60 94 30 80       	push   $0x80309460
801019c5:	e8 2b 32 00 00       	call   80104bf5 <release>
801019ca:	83 c4 10             	add    $0x10,%esp
  return ip;
801019cd:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019d0:	c9                   	leave  
801019d1:	c3                   	ret    

801019d2 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019d2:	55                   	push   %ebp
801019d3:	89 e5                	mov    %esp,%ebp
801019d5:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019d8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019dc:	74 0a                	je     801019e8 <ilock+0x16>
801019de:	8b 45 08             	mov    0x8(%ebp),%eax
801019e1:	8b 40 08             	mov    0x8(%eax),%eax
801019e4:	85 c0                	test   %eax,%eax
801019e6:	7f 0d                	jg     801019f5 <ilock+0x23>
    panic("ilock");
801019e8:	83 ec 0c             	sub    $0xc,%esp
801019eb:	68 4d aa 10 80       	push   $0x8010aa4d
801019f0:	e8 b4 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
801019f5:	8b 45 08             	mov    0x8(%ebp),%eax
801019f8:	83 c0 0c             	add    $0xc,%eax
801019fb:	83 ec 0c             	sub    $0xc,%esp
801019fe:	50                   	push   %eax
801019ff:	e8 40 30 00 00       	call   80104a44 <acquiresleep>
80101a04:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a07:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a0d:	85 c0                	test   %eax,%eax
80101a0f:	0f 85 cd 00 00 00    	jne    80101ae2 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	8b 40 04             	mov    0x4(%eax),%eax
80101a1b:	c1 e8 03             	shr    $0x3,%eax
80101a1e:	89 c2                	mov    %eax,%edx
80101a20:	a1 54 94 30 80       	mov    0x80309454,%eax
80101a25:	01 c2                	add    %eax,%edx
80101a27:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2a:	8b 00                	mov    (%eax),%eax
80101a2c:	83 ec 08             	sub    $0x8,%esp
80101a2f:	52                   	push   %edx
80101a30:	50                   	push   %eax
80101a31:	e8 cb e7 ff ff       	call   80100201 <bread>
80101a36:	83 c4 10             	add    $0x10,%esp
80101a39:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3f:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a42:	8b 45 08             	mov    0x8(%ebp),%eax
80101a45:	8b 40 04             	mov    0x4(%eax),%eax
80101a48:	83 e0 07             	and    $0x7,%eax
80101a4b:	c1 e0 06             	shl    $0x6,%eax
80101a4e:	01 d0                	add    %edx,%eax
80101a50:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a56:	0f b7 10             	movzwl (%eax),%edx
80101a59:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5c:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a63:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a67:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6a:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a71:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a75:	8b 45 08             	mov    0x8(%ebp),%eax
80101a78:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7f:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a83:	8b 45 08             	mov    0x8(%ebp),%eax
80101a86:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a8d:	8b 50 08             	mov    0x8(%eax),%edx
80101a90:	8b 45 08             	mov    0x8(%ebp),%eax
80101a93:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a99:	8d 50 0c             	lea    0xc(%eax),%edx
80101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9f:	83 c0 5c             	add    $0x5c,%eax
80101aa2:	83 ec 04             	sub    $0x4,%esp
80101aa5:	6a 34                	push   $0x34
80101aa7:	52                   	push   %edx
80101aa8:	50                   	push   %eax
80101aa9:	e8 0e 34 00 00       	call   80104ebc <memmove>
80101aae:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ab1:	83 ec 0c             	sub    $0xc,%esp
80101ab4:	ff 75 f4             	push   -0xc(%ebp)
80101ab7:	e8 c7 e7 ff ff       	call   80100283 <brelse>
80101abc:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101abf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80101acc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ad0:	66 85 c0             	test   %ax,%ax
80101ad3:	75 0d                	jne    80101ae2 <ilock+0x110>
      panic("ilock: no type");
80101ad5:	83 ec 0c             	sub    $0xc,%esp
80101ad8:	68 53 aa 10 80       	push   $0x8010aa53
80101add:	e8 c7 ea ff ff       	call   801005a9 <panic>
  }
}
80101ae2:	90                   	nop
80101ae3:	c9                   	leave  
80101ae4:	c3                   	ret    

80101ae5 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ae5:	55                   	push   %ebp
80101ae6:	89 e5                	mov    %esp,%ebp
80101ae8:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101aeb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101aef:	74 20                	je     80101b11 <iunlock+0x2c>
80101af1:	8b 45 08             	mov    0x8(%ebp),%eax
80101af4:	83 c0 0c             	add    $0xc,%eax
80101af7:	83 ec 0c             	sub    $0xc,%esp
80101afa:	50                   	push   %eax
80101afb:	e8 f6 2f 00 00       	call   80104af6 <holdingsleep>
80101b00:	83 c4 10             	add    $0x10,%esp
80101b03:	85 c0                	test   %eax,%eax
80101b05:	74 0a                	je     80101b11 <iunlock+0x2c>
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	8b 40 08             	mov    0x8(%eax),%eax
80101b0d:	85 c0                	test   %eax,%eax
80101b0f:	7f 0d                	jg     80101b1e <iunlock+0x39>
    panic("iunlock");
80101b11:	83 ec 0c             	sub    $0xc,%esp
80101b14:	68 62 aa 10 80       	push   $0x8010aa62
80101b19:	e8 8b ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b21:	83 c0 0c             	add    $0xc,%eax
80101b24:	83 ec 0c             	sub    $0xc,%esp
80101b27:	50                   	push   %eax
80101b28:	e8 7b 2f 00 00       	call   80104aa8 <releasesleep>
80101b2d:	83 c4 10             	add    $0x10,%esp
}
80101b30:	90                   	nop
80101b31:	c9                   	leave  
80101b32:	c3                   	ret    

80101b33 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b33:	55                   	push   %ebp
80101b34:	89 e5                	mov    %esp,%ebp
80101b36:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b39:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3c:	83 c0 0c             	add    $0xc,%eax
80101b3f:	83 ec 0c             	sub    $0xc,%esp
80101b42:	50                   	push   %eax
80101b43:	e8 fc 2e 00 00       	call   80104a44 <acquiresleep>
80101b48:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b51:	85 c0                	test   %eax,%eax
80101b53:	74 6a                	je     80101bbf <iput+0x8c>
80101b55:	8b 45 08             	mov    0x8(%ebp),%eax
80101b58:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b5c:	66 85 c0             	test   %ax,%ax
80101b5f:	75 5e                	jne    80101bbf <iput+0x8c>
    acquire(&icache.lock);
80101b61:	83 ec 0c             	sub    $0xc,%esp
80101b64:	68 60 94 30 80       	push   $0x80309460
80101b69:	e8 19 30 00 00       	call   80104b87 <acquire>
80101b6e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b71:	8b 45 08             	mov    0x8(%ebp),%eax
80101b74:	8b 40 08             	mov    0x8(%eax),%eax
80101b77:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b7a:	83 ec 0c             	sub    $0xc,%esp
80101b7d:	68 60 94 30 80       	push   $0x80309460
80101b82:	e8 6e 30 00 00       	call   80104bf5 <release>
80101b87:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101b8a:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101b8e:	75 2f                	jne    80101bbf <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101b90:	83 ec 0c             	sub    $0xc,%esp
80101b93:	ff 75 08             	push   0x8(%ebp)
80101b96:	e8 ad 01 00 00       	call   80101d48 <itrunc>
80101b9b:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101b9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba1:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101ba7:	83 ec 0c             	sub    $0xc,%esp
80101baa:	ff 75 08             	push   0x8(%ebp)
80101bad:	e8 43 fc ff ff       	call   801017f5 <iupdate>
80101bb2:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc2:	83 c0 0c             	add    $0xc,%eax
80101bc5:	83 ec 0c             	sub    $0xc,%esp
80101bc8:	50                   	push   %eax
80101bc9:	e8 da 2e 00 00       	call   80104aa8 <releasesleep>
80101bce:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bd1:	83 ec 0c             	sub    $0xc,%esp
80101bd4:	68 60 94 30 80       	push   $0x80309460
80101bd9:	e8 a9 2f 00 00       	call   80104b87 <acquire>
80101bde:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101be1:	8b 45 08             	mov    0x8(%ebp),%eax
80101be4:	8b 40 08             	mov    0x8(%eax),%eax
80101be7:	8d 50 ff             	lea    -0x1(%eax),%edx
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bf0:	83 ec 0c             	sub    $0xc,%esp
80101bf3:	68 60 94 30 80       	push   $0x80309460
80101bf8:	e8 f8 2f 00 00       	call   80104bf5 <release>
80101bfd:	83 c4 10             	add    $0x10,%esp
}
80101c00:	90                   	nop
80101c01:	c9                   	leave  
80101c02:	c3                   	ret    

80101c03 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c03:	55                   	push   %ebp
80101c04:	89 e5                	mov    %esp,%ebp
80101c06:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c09:	83 ec 0c             	sub    $0xc,%esp
80101c0c:	ff 75 08             	push   0x8(%ebp)
80101c0f:	e8 d1 fe ff ff       	call   80101ae5 <iunlock>
80101c14:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c17:	83 ec 0c             	sub    $0xc,%esp
80101c1a:	ff 75 08             	push   0x8(%ebp)
80101c1d:	e8 11 ff ff ff       	call   80101b33 <iput>
80101c22:	83 c4 10             	add    $0x10,%esp
}
80101c25:	90                   	nop
80101c26:	c9                   	leave  
80101c27:	c3                   	ret    

80101c28 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c28:	55                   	push   %ebp
80101c29:	89 e5                	mov    %esp,%ebp
80101c2b:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c2e:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c32:	77 42                	ja     80101c76 <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c34:	8b 45 08             	mov    0x8(%ebp),%eax
80101c37:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c3a:	83 c2 14             	add    $0x14,%edx
80101c3d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c48:	75 24                	jne    80101c6e <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4d:	8b 00                	mov    (%eax),%eax
80101c4f:	83 ec 0c             	sub    $0xc,%esp
80101c52:	50                   	push   %eax
80101c53:	e8 f4 f7 ff ff       	call   8010144c <balloc>
80101c58:	83 c4 10             	add    $0x10,%esp
80101c5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c61:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c64:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c6a:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c71:	e9 d0 00 00 00       	jmp    80101d46 <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c76:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c7a:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c7e:	0f 87 b5 00 00 00    	ja     80101d39 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c84:	8b 45 08             	mov    0x8(%ebp),%eax
80101c87:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101c8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c94:	75 20                	jne    80101cb6 <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c96:	8b 45 08             	mov    0x8(%ebp),%eax
80101c99:	8b 00                	mov    (%eax),%eax
80101c9b:	83 ec 0c             	sub    $0xc,%esp
80101c9e:	50                   	push   %eax
80101c9f:	e8 a8 f7 ff ff       	call   8010144c <balloc>
80101ca4:	83 c4 10             	add    $0x10,%esp
80101ca7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101caa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb0:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb9:	8b 00                	mov    (%eax),%eax
80101cbb:	83 ec 08             	sub    $0x8,%esp
80101cbe:	ff 75 f4             	push   -0xc(%ebp)
80101cc1:	50                   	push   %eax
80101cc2:	e8 3a e5 ff ff       	call   80100201 <bread>
80101cc7:	83 c4 10             	add    $0x10,%esp
80101cca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ccd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cd0:	83 c0 5c             	add    $0x5c,%eax
80101cd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cd9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ce0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ce3:	01 d0                	add    %edx,%eax
80101ce5:	8b 00                	mov    (%eax),%eax
80101ce7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cee:	75 36                	jne    80101d26 <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf3:	8b 00                	mov    (%eax),%eax
80101cf5:	83 ec 0c             	sub    $0xc,%esp
80101cf8:	50                   	push   %eax
80101cf9:	e8 4e f7 ff ff       	call   8010144c <balloc>
80101cfe:	83 c4 10             	add    $0x10,%esp
80101d01:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d04:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d07:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d11:	01 c2                	add    %eax,%edx
80101d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d16:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d18:	83 ec 0c             	sub    $0xc,%esp
80101d1b:	ff 75 f0             	push   -0x10(%ebp)
80101d1e:	e8 3a 15 00 00       	call   8010325d <log_write>
80101d23:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d26:	83 ec 0c             	sub    $0xc,%esp
80101d29:	ff 75 f0             	push   -0x10(%ebp)
80101d2c:	e8 52 e5 ff ff       	call   80100283 <brelse>
80101d31:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d37:	eb 0d                	jmp    80101d46 <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d39:	83 ec 0c             	sub    $0xc,%esp
80101d3c:	68 6a aa 10 80       	push   $0x8010aa6a
80101d41:	e8 63 e8 ff ff       	call   801005a9 <panic>
}
80101d46:	c9                   	leave  
80101d47:	c3                   	ret    

80101d48 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d48:	55                   	push   %ebp
80101d49:	89 e5                	mov    %esp,%ebp
80101d4b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d4e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d55:	eb 45                	jmp    80101d9c <itrunc+0x54>
    if(ip->addrs[i]){
80101d57:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d5d:	83 c2 14             	add    $0x14,%edx
80101d60:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d64:	85 c0                	test   %eax,%eax
80101d66:	74 30                	je     80101d98 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d68:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6e:	83 c2 14             	add    $0x14,%edx
80101d71:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d75:	8b 55 08             	mov    0x8(%ebp),%edx
80101d78:	8b 12                	mov    (%edx),%edx
80101d7a:	83 ec 08             	sub    $0x8,%esp
80101d7d:	50                   	push   %eax
80101d7e:	52                   	push   %edx
80101d7f:	e8 0c f8 ff ff       	call   80101590 <bfree>
80101d84:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d87:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d8d:	83 c2 14             	add    $0x14,%edx
80101d90:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d97:	00 
  for(i = 0; i < NDIRECT; i++){
80101d98:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d9c:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101da0:	7e b5                	jle    80101d57 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101da2:	8b 45 08             	mov    0x8(%ebp),%eax
80101da5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dab:	85 c0                	test   %eax,%eax
80101dad:	0f 84 aa 00 00 00    	je     80101e5d <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101db3:	8b 45 08             	mov    0x8(%ebp),%eax
80101db6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbf:	8b 00                	mov    (%eax),%eax
80101dc1:	83 ec 08             	sub    $0x8,%esp
80101dc4:	52                   	push   %edx
80101dc5:	50                   	push   %eax
80101dc6:	e8 36 e4 ff ff       	call   80100201 <bread>
80101dcb:	83 c4 10             	add    $0x10,%esp
80101dce:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101dd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dd4:	83 c0 5c             	add    $0x5c,%eax
80101dd7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101dda:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101de1:	eb 3c                	jmp    80101e1f <itrunc+0xd7>
      if(a[j])
80101de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101de6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ded:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101df0:	01 d0                	add    %edx,%eax
80101df2:	8b 00                	mov    (%eax),%eax
80101df4:	85 c0                	test   %eax,%eax
80101df6:	74 23                	je     80101e1b <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e02:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e05:	01 d0                	add    %edx,%eax
80101e07:	8b 00                	mov    (%eax),%eax
80101e09:	8b 55 08             	mov    0x8(%ebp),%edx
80101e0c:	8b 12                	mov    (%edx),%edx
80101e0e:	83 ec 08             	sub    $0x8,%esp
80101e11:	50                   	push   %eax
80101e12:	52                   	push   %edx
80101e13:	e8 78 f7 ff ff       	call   80101590 <bfree>
80101e18:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e1b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e22:	83 f8 7f             	cmp    $0x7f,%eax
80101e25:	76 bc                	jbe    80101de3 <itrunc+0x9b>
    }
    brelse(bp);
80101e27:	83 ec 0c             	sub    $0xc,%esp
80101e2a:	ff 75 ec             	push   -0x14(%ebp)
80101e2d:	e8 51 e4 ff ff       	call   80100283 <brelse>
80101e32:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e35:	8b 45 08             	mov    0x8(%ebp),%eax
80101e38:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e3e:	8b 55 08             	mov    0x8(%ebp),%edx
80101e41:	8b 12                	mov    (%edx),%edx
80101e43:	83 ec 08             	sub    $0x8,%esp
80101e46:	50                   	push   %eax
80101e47:	52                   	push   %edx
80101e48:	e8 43 f7 ff ff       	call   80101590 <bfree>
80101e4d:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e50:	8b 45 08             	mov    0x8(%ebp),%eax
80101e53:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e5a:	00 00 00 
  }

  ip->size = 0;
80101e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e60:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e67:	83 ec 0c             	sub    $0xc,%esp
80101e6a:	ff 75 08             	push   0x8(%ebp)
80101e6d:	e8 83 f9 ff ff       	call   801017f5 <iupdate>
80101e72:	83 c4 10             	add    $0x10,%esp
}
80101e75:	90                   	nop
80101e76:	c9                   	leave  
80101e77:	c3                   	ret    

80101e78 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e78:	55                   	push   %ebp
80101e79:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7e:	8b 00                	mov    (%eax),%eax
80101e80:	89 c2                	mov    %eax,%edx
80101e82:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e85:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e88:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8b:	8b 50 04             	mov    0x4(%eax),%edx
80101e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e91:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e94:	8b 45 08             	mov    0x8(%ebp),%eax
80101e97:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9e:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea4:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eab:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb2:	8b 50 58             	mov    0x58(%eax),%edx
80101eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb8:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ebb:	90                   	nop
80101ebc:	5d                   	pop    %ebp
80101ebd:	c3                   	ret    

80101ebe <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ebe:	55                   	push   %ebp
80101ebf:	89 e5                	mov    %esp,%ebp
80101ec1:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ecb:	66 83 f8 03          	cmp    $0x3,%ax
80101ecf:	75 5c                	jne    80101f2d <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ed8:	66 85 c0             	test   %ax,%ax
80101edb:	78 20                	js     80101efd <readi+0x3f>
80101edd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee0:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ee4:	66 83 f8 09          	cmp    $0x9,%ax
80101ee8:	7f 13                	jg     80101efd <readi+0x3f>
80101eea:	8b 45 08             	mov    0x8(%ebp),%eax
80101eed:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef1:	98                   	cwtl   
80101ef2:	8b 04 c5 40 8a 30 80 	mov    -0x7fcf75c0(,%eax,8),%eax
80101ef9:	85 c0                	test   %eax,%eax
80101efb:	75 0a                	jne    80101f07 <readi+0x49>
      return -1;
80101efd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f02:	e9 0a 01 00 00       	jmp    80102011 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f07:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f0e:	98                   	cwtl   
80101f0f:	8b 04 c5 40 8a 30 80 	mov    -0x7fcf75c0(,%eax,8),%eax
80101f16:	8b 55 14             	mov    0x14(%ebp),%edx
80101f19:	83 ec 04             	sub    $0x4,%esp
80101f1c:	52                   	push   %edx
80101f1d:	ff 75 0c             	push   0xc(%ebp)
80101f20:	ff 75 08             	push   0x8(%ebp)
80101f23:	ff d0                	call   *%eax
80101f25:	83 c4 10             	add    $0x10,%esp
80101f28:	e9 e4 00 00 00       	jmp    80102011 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f30:	8b 40 58             	mov    0x58(%eax),%eax
80101f33:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f36:	77 0d                	ja     80101f45 <readi+0x87>
80101f38:	8b 55 10             	mov    0x10(%ebp),%edx
80101f3b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f3e:	01 d0                	add    %edx,%eax
80101f40:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f43:	76 0a                	jbe    80101f4f <readi+0x91>
    return -1;
80101f45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f4a:	e9 c2 00 00 00       	jmp    80102011 <readi+0x153>
  if(off + n > ip->size)
80101f4f:	8b 55 10             	mov    0x10(%ebp),%edx
80101f52:	8b 45 14             	mov    0x14(%ebp),%eax
80101f55:	01 c2                	add    %eax,%edx
80101f57:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5a:	8b 40 58             	mov    0x58(%eax),%eax
80101f5d:	39 c2                	cmp    %eax,%edx
80101f5f:	76 0c                	jbe    80101f6d <readi+0xaf>
    n = ip->size - off;
80101f61:	8b 45 08             	mov    0x8(%ebp),%eax
80101f64:	8b 40 58             	mov    0x58(%eax),%eax
80101f67:	2b 45 10             	sub    0x10(%ebp),%eax
80101f6a:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f6d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f74:	e9 89 00 00 00       	jmp    80102002 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f79:	8b 45 10             	mov    0x10(%ebp),%eax
80101f7c:	c1 e8 09             	shr    $0x9,%eax
80101f7f:	83 ec 08             	sub    $0x8,%esp
80101f82:	50                   	push   %eax
80101f83:	ff 75 08             	push   0x8(%ebp)
80101f86:	e8 9d fc ff ff       	call   80101c28 <bmap>
80101f8b:	83 c4 10             	add    $0x10,%esp
80101f8e:	8b 55 08             	mov    0x8(%ebp),%edx
80101f91:	8b 12                	mov    (%edx),%edx
80101f93:	83 ec 08             	sub    $0x8,%esp
80101f96:	50                   	push   %eax
80101f97:	52                   	push   %edx
80101f98:	e8 64 e2 ff ff       	call   80100201 <bread>
80101f9d:	83 c4 10             	add    $0x10,%esp
80101fa0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fa3:	8b 45 10             	mov    0x10(%ebp),%eax
80101fa6:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fab:	ba 00 02 00 00       	mov    $0x200,%edx
80101fb0:	29 c2                	sub    %eax,%edx
80101fb2:	8b 45 14             	mov    0x14(%ebp),%eax
80101fb5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fb8:	39 c2                	cmp    %eax,%edx
80101fba:	0f 46 c2             	cmovbe %edx,%eax
80101fbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fc3:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fc6:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc9:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fce:	01 d0                	add    %edx,%eax
80101fd0:	83 ec 04             	sub    $0x4,%esp
80101fd3:	ff 75 ec             	push   -0x14(%ebp)
80101fd6:	50                   	push   %eax
80101fd7:	ff 75 0c             	push   0xc(%ebp)
80101fda:	e8 dd 2e 00 00       	call   80104ebc <memmove>
80101fdf:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101fe2:	83 ec 0c             	sub    $0xc,%esp
80101fe5:	ff 75 f0             	push   -0x10(%ebp)
80101fe8:	e8 96 e2 ff ff       	call   80100283 <brelse>
80101fed:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ff0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ff3:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ff6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ff9:	01 45 10             	add    %eax,0x10(%ebp)
80101ffc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fff:	01 45 0c             	add    %eax,0xc(%ebp)
80102002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102005:	3b 45 14             	cmp    0x14(%ebp),%eax
80102008:	0f 82 6b ff ff ff    	jb     80101f79 <readi+0xbb>
  }
  return n;
8010200e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102011:	c9                   	leave  
80102012:	c3                   	ret    

80102013 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102013:	55                   	push   %ebp
80102014:	89 e5                	mov    %esp,%ebp
80102016:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102019:	8b 45 08             	mov    0x8(%ebp),%eax
8010201c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102020:	66 83 f8 03          	cmp    $0x3,%ax
80102024:	75 5c                	jne    80102082 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102026:	8b 45 08             	mov    0x8(%ebp),%eax
80102029:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010202d:	66 85 c0             	test   %ax,%ax
80102030:	78 20                	js     80102052 <writei+0x3f>
80102032:	8b 45 08             	mov    0x8(%ebp),%eax
80102035:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102039:	66 83 f8 09          	cmp    $0x9,%ax
8010203d:	7f 13                	jg     80102052 <writei+0x3f>
8010203f:	8b 45 08             	mov    0x8(%ebp),%eax
80102042:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102046:	98                   	cwtl   
80102047:	8b 04 c5 44 8a 30 80 	mov    -0x7fcf75bc(,%eax,8),%eax
8010204e:	85 c0                	test   %eax,%eax
80102050:	75 0a                	jne    8010205c <writei+0x49>
      return -1;
80102052:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102057:	e9 3b 01 00 00       	jmp    80102197 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010205c:	8b 45 08             	mov    0x8(%ebp),%eax
8010205f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102063:	98                   	cwtl   
80102064:	8b 04 c5 44 8a 30 80 	mov    -0x7fcf75bc(,%eax,8),%eax
8010206b:	8b 55 14             	mov    0x14(%ebp),%edx
8010206e:	83 ec 04             	sub    $0x4,%esp
80102071:	52                   	push   %edx
80102072:	ff 75 0c             	push   0xc(%ebp)
80102075:	ff 75 08             	push   0x8(%ebp)
80102078:	ff d0                	call   *%eax
8010207a:	83 c4 10             	add    $0x10,%esp
8010207d:	e9 15 01 00 00       	jmp    80102197 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
80102082:	8b 45 08             	mov    0x8(%ebp),%eax
80102085:	8b 40 58             	mov    0x58(%eax),%eax
80102088:	39 45 10             	cmp    %eax,0x10(%ebp)
8010208b:	77 0d                	ja     8010209a <writei+0x87>
8010208d:	8b 55 10             	mov    0x10(%ebp),%edx
80102090:	8b 45 14             	mov    0x14(%ebp),%eax
80102093:	01 d0                	add    %edx,%eax
80102095:	39 45 10             	cmp    %eax,0x10(%ebp)
80102098:	76 0a                	jbe    801020a4 <writei+0x91>
    return -1;
8010209a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010209f:	e9 f3 00 00 00       	jmp    80102197 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020a4:	8b 55 10             	mov    0x10(%ebp),%edx
801020a7:	8b 45 14             	mov    0x14(%ebp),%eax
801020aa:	01 d0                	add    %edx,%eax
801020ac:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020b1:	76 0a                	jbe    801020bd <writei+0xaa>
    return -1;
801020b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b8:	e9 da 00 00 00       	jmp    80102197 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020c4:	e9 97 00 00 00       	jmp    80102160 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020c9:	8b 45 10             	mov    0x10(%ebp),%eax
801020cc:	c1 e8 09             	shr    $0x9,%eax
801020cf:	83 ec 08             	sub    $0x8,%esp
801020d2:	50                   	push   %eax
801020d3:	ff 75 08             	push   0x8(%ebp)
801020d6:	e8 4d fb ff ff       	call   80101c28 <bmap>
801020db:	83 c4 10             	add    $0x10,%esp
801020de:	8b 55 08             	mov    0x8(%ebp),%edx
801020e1:	8b 12                	mov    (%edx),%edx
801020e3:	83 ec 08             	sub    $0x8,%esp
801020e6:	50                   	push   %eax
801020e7:	52                   	push   %edx
801020e8:	e8 14 e1 ff ff       	call   80100201 <bread>
801020ed:	83 c4 10             	add    $0x10,%esp
801020f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020f3:	8b 45 10             	mov    0x10(%ebp),%eax
801020f6:	25 ff 01 00 00       	and    $0x1ff,%eax
801020fb:	ba 00 02 00 00       	mov    $0x200,%edx
80102100:	29 c2                	sub    %eax,%edx
80102102:	8b 45 14             	mov    0x14(%ebp),%eax
80102105:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102108:	39 c2                	cmp    %eax,%edx
8010210a:	0f 46 c2             	cmovbe %edx,%eax
8010210d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102110:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102113:	8d 50 5c             	lea    0x5c(%eax),%edx
80102116:	8b 45 10             	mov    0x10(%ebp),%eax
80102119:	25 ff 01 00 00       	and    $0x1ff,%eax
8010211e:	01 d0                	add    %edx,%eax
80102120:	83 ec 04             	sub    $0x4,%esp
80102123:	ff 75 ec             	push   -0x14(%ebp)
80102126:	ff 75 0c             	push   0xc(%ebp)
80102129:	50                   	push   %eax
8010212a:	e8 8d 2d 00 00       	call   80104ebc <memmove>
8010212f:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102132:	83 ec 0c             	sub    $0xc,%esp
80102135:	ff 75 f0             	push   -0x10(%ebp)
80102138:	e8 20 11 00 00       	call   8010325d <log_write>
8010213d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102140:	83 ec 0c             	sub    $0xc,%esp
80102143:	ff 75 f0             	push   -0x10(%ebp)
80102146:	e8 38 e1 ff ff       	call   80100283 <brelse>
8010214b:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010214e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102151:	01 45 f4             	add    %eax,-0xc(%ebp)
80102154:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102157:	01 45 10             	add    %eax,0x10(%ebp)
8010215a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010215d:	01 45 0c             	add    %eax,0xc(%ebp)
80102160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102163:	3b 45 14             	cmp    0x14(%ebp),%eax
80102166:	0f 82 5d ff ff ff    	jb     801020c9 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
8010216c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102170:	74 22                	je     80102194 <writei+0x181>
80102172:	8b 45 08             	mov    0x8(%ebp),%eax
80102175:	8b 40 58             	mov    0x58(%eax),%eax
80102178:	39 45 10             	cmp    %eax,0x10(%ebp)
8010217b:	76 17                	jbe    80102194 <writei+0x181>
    ip->size = off;
8010217d:	8b 45 08             	mov    0x8(%ebp),%eax
80102180:	8b 55 10             	mov    0x10(%ebp),%edx
80102183:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102186:	83 ec 0c             	sub    $0xc,%esp
80102189:	ff 75 08             	push   0x8(%ebp)
8010218c:	e8 64 f6 ff ff       	call   801017f5 <iupdate>
80102191:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102194:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102197:	c9                   	leave  
80102198:	c3                   	ret    

80102199 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102199:	55                   	push   %ebp
8010219a:	89 e5                	mov    %esp,%ebp
8010219c:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
8010219f:	83 ec 04             	sub    $0x4,%esp
801021a2:	6a 0e                	push   $0xe
801021a4:	ff 75 0c             	push   0xc(%ebp)
801021a7:	ff 75 08             	push   0x8(%ebp)
801021aa:	e8 a3 2d 00 00       	call   80104f52 <strncmp>
801021af:	83 c4 10             	add    $0x10,%esp
}
801021b2:	c9                   	leave  
801021b3:	c3                   	ret    

801021b4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021b4:	55                   	push   %ebp
801021b5:	89 e5                	mov    %esp,%ebp
801021b7:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021ba:	8b 45 08             	mov    0x8(%ebp),%eax
801021bd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021c1:	66 83 f8 01          	cmp    $0x1,%ax
801021c5:	74 0d                	je     801021d4 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021c7:	83 ec 0c             	sub    $0xc,%esp
801021ca:	68 7d aa 10 80       	push   $0x8010aa7d
801021cf:	e8 d5 e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021db:	eb 7b                	jmp    80102258 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021dd:	6a 10                	push   $0x10
801021df:	ff 75 f4             	push   -0xc(%ebp)
801021e2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021e5:	50                   	push   %eax
801021e6:	ff 75 08             	push   0x8(%ebp)
801021e9:	e8 d0 fc ff ff       	call   80101ebe <readi>
801021ee:	83 c4 10             	add    $0x10,%esp
801021f1:	83 f8 10             	cmp    $0x10,%eax
801021f4:	74 0d                	je     80102203 <dirlookup+0x4f>
      panic("dirlookup read");
801021f6:	83 ec 0c             	sub    $0xc,%esp
801021f9:	68 8f aa 10 80       	push   $0x8010aa8f
801021fe:	e8 a6 e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
80102203:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102207:	66 85 c0             	test   %ax,%ax
8010220a:	74 47                	je     80102253 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010220c:	83 ec 08             	sub    $0x8,%esp
8010220f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102212:	83 c0 02             	add    $0x2,%eax
80102215:	50                   	push   %eax
80102216:	ff 75 0c             	push   0xc(%ebp)
80102219:	e8 7b ff ff ff       	call   80102199 <namecmp>
8010221e:	83 c4 10             	add    $0x10,%esp
80102221:	85 c0                	test   %eax,%eax
80102223:	75 2f                	jne    80102254 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102225:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102229:	74 08                	je     80102233 <dirlookup+0x7f>
        *poff = off;
8010222b:	8b 45 10             	mov    0x10(%ebp),%eax
8010222e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102231:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102233:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102237:	0f b7 c0             	movzwl %ax,%eax
8010223a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010223d:	8b 45 08             	mov    0x8(%ebp),%eax
80102240:	8b 00                	mov    (%eax),%eax
80102242:	83 ec 08             	sub    $0x8,%esp
80102245:	ff 75 f0             	push   -0x10(%ebp)
80102248:	50                   	push   %eax
80102249:	e8 68 f6 ff ff       	call   801018b6 <iget>
8010224e:	83 c4 10             	add    $0x10,%esp
80102251:	eb 19                	jmp    8010226c <dirlookup+0xb8>
      continue;
80102253:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102254:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102258:	8b 45 08             	mov    0x8(%ebp),%eax
8010225b:	8b 40 58             	mov    0x58(%eax),%eax
8010225e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102261:	0f 82 76 ff ff ff    	jb     801021dd <dirlookup+0x29>
    }
  }

  return 0;
80102267:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010226c:	c9                   	leave  
8010226d:	c3                   	ret    

8010226e <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010226e:	55                   	push   %ebp
8010226f:	89 e5                	mov    %esp,%ebp
80102271:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102274:	83 ec 04             	sub    $0x4,%esp
80102277:	6a 00                	push   $0x0
80102279:	ff 75 0c             	push   0xc(%ebp)
8010227c:	ff 75 08             	push   0x8(%ebp)
8010227f:	e8 30 ff ff ff       	call   801021b4 <dirlookup>
80102284:	83 c4 10             	add    $0x10,%esp
80102287:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010228a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010228e:	74 18                	je     801022a8 <dirlink+0x3a>
    iput(ip);
80102290:	83 ec 0c             	sub    $0xc,%esp
80102293:	ff 75 f0             	push   -0x10(%ebp)
80102296:	e8 98 f8 ff ff       	call   80101b33 <iput>
8010229b:	83 c4 10             	add    $0x10,%esp
    return -1;
8010229e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022a3:	e9 9c 00 00 00       	jmp    80102344 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022af:	eb 39                	jmp    801022ea <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022b4:	6a 10                	push   $0x10
801022b6:	50                   	push   %eax
801022b7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022ba:	50                   	push   %eax
801022bb:	ff 75 08             	push   0x8(%ebp)
801022be:	e8 fb fb ff ff       	call   80101ebe <readi>
801022c3:	83 c4 10             	add    $0x10,%esp
801022c6:	83 f8 10             	cmp    $0x10,%eax
801022c9:	74 0d                	je     801022d8 <dirlink+0x6a>
      panic("dirlink read");
801022cb:	83 ec 0c             	sub    $0xc,%esp
801022ce:	68 9e aa 10 80       	push   $0x8010aa9e
801022d3:	e8 d1 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022d8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022dc:	66 85 c0             	test   %ax,%ax
801022df:	74 18                	je     801022f9 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e4:	83 c0 10             	add    $0x10,%eax
801022e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022ea:	8b 45 08             	mov    0x8(%ebp),%eax
801022ed:	8b 50 58             	mov    0x58(%eax),%edx
801022f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f3:	39 c2                	cmp    %eax,%edx
801022f5:	77 ba                	ja     801022b1 <dirlink+0x43>
801022f7:	eb 01                	jmp    801022fa <dirlink+0x8c>
      break;
801022f9:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801022fa:	83 ec 04             	sub    $0x4,%esp
801022fd:	6a 0e                	push   $0xe
801022ff:	ff 75 0c             	push   0xc(%ebp)
80102302:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102305:	83 c0 02             	add    $0x2,%eax
80102308:	50                   	push   %eax
80102309:	e8 9a 2c 00 00       	call   80104fa8 <strncpy>
8010230e:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102311:	8b 45 10             	mov    0x10(%ebp),%eax
80102314:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010231b:	6a 10                	push   $0x10
8010231d:	50                   	push   %eax
8010231e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102321:	50                   	push   %eax
80102322:	ff 75 08             	push   0x8(%ebp)
80102325:	e8 e9 fc ff ff       	call   80102013 <writei>
8010232a:	83 c4 10             	add    $0x10,%esp
8010232d:	83 f8 10             	cmp    $0x10,%eax
80102330:	74 0d                	je     8010233f <dirlink+0xd1>
    panic("dirlink");
80102332:	83 ec 0c             	sub    $0xc,%esp
80102335:	68 ab aa 10 80       	push   $0x8010aaab
8010233a:	e8 6a e2 ff ff       	call   801005a9 <panic>

  return 0;
8010233f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102344:	c9                   	leave  
80102345:	c3                   	ret    

80102346 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102346:	55                   	push   %ebp
80102347:	89 e5                	mov    %esp,%ebp
80102349:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010234c:	eb 04                	jmp    80102352 <skipelem+0xc>
    path++;
8010234e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102352:	8b 45 08             	mov    0x8(%ebp),%eax
80102355:	0f b6 00             	movzbl (%eax),%eax
80102358:	3c 2f                	cmp    $0x2f,%al
8010235a:	74 f2                	je     8010234e <skipelem+0x8>
  if(*path == 0)
8010235c:	8b 45 08             	mov    0x8(%ebp),%eax
8010235f:	0f b6 00             	movzbl (%eax),%eax
80102362:	84 c0                	test   %al,%al
80102364:	75 07                	jne    8010236d <skipelem+0x27>
    return 0;
80102366:	b8 00 00 00 00       	mov    $0x0,%eax
8010236b:	eb 77                	jmp    801023e4 <skipelem+0x9e>
  s = path;
8010236d:	8b 45 08             	mov    0x8(%ebp),%eax
80102370:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102373:	eb 04                	jmp    80102379 <skipelem+0x33>
    path++;
80102375:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102379:	8b 45 08             	mov    0x8(%ebp),%eax
8010237c:	0f b6 00             	movzbl (%eax),%eax
8010237f:	3c 2f                	cmp    $0x2f,%al
80102381:	74 0a                	je     8010238d <skipelem+0x47>
80102383:	8b 45 08             	mov    0x8(%ebp),%eax
80102386:	0f b6 00             	movzbl (%eax),%eax
80102389:	84 c0                	test   %al,%al
8010238b:	75 e8                	jne    80102375 <skipelem+0x2f>
  len = path - s;
8010238d:	8b 45 08             	mov    0x8(%ebp),%eax
80102390:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102393:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102396:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010239a:	7e 15                	jle    801023b1 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
8010239c:	83 ec 04             	sub    $0x4,%esp
8010239f:	6a 0e                	push   $0xe
801023a1:	ff 75 f4             	push   -0xc(%ebp)
801023a4:	ff 75 0c             	push   0xc(%ebp)
801023a7:	e8 10 2b 00 00       	call   80104ebc <memmove>
801023ac:	83 c4 10             	add    $0x10,%esp
801023af:	eb 26                	jmp    801023d7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023b4:	83 ec 04             	sub    $0x4,%esp
801023b7:	50                   	push   %eax
801023b8:	ff 75 f4             	push   -0xc(%ebp)
801023bb:	ff 75 0c             	push   0xc(%ebp)
801023be:	e8 f9 2a 00 00       	call   80104ebc <memmove>
801023c3:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801023cc:	01 d0                	add    %edx,%eax
801023ce:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023d1:	eb 04                	jmp    801023d7 <skipelem+0x91>
    path++;
801023d3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023d7:	8b 45 08             	mov    0x8(%ebp),%eax
801023da:	0f b6 00             	movzbl (%eax),%eax
801023dd:	3c 2f                	cmp    $0x2f,%al
801023df:	74 f2                	je     801023d3 <skipelem+0x8d>
  return path;
801023e1:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023e4:	c9                   	leave  
801023e5:	c3                   	ret    

801023e6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023e6:	55                   	push   %ebp
801023e7:	89 e5                	mov    %esp,%ebp
801023e9:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801023ec:	8b 45 08             	mov    0x8(%ebp),%eax
801023ef:	0f b6 00             	movzbl (%eax),%eax
801023f2:	3c 2f                	cmp    $0x2f,%al
801023f4:	75 17                	jne    8010240d <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801023f6:	83 ec 08             	sub    $0x8,%esp
801023f9:	6a 01                	push   $0x1
801023fb:	6a 01                	push   $0x1
801023fd:	e8 b4 f4 ff ff       	call   801018b6 <iget>
80102402:	83 c4 10             	add    $0x10,%esp
80102405:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102408:	e9 ba 00 00 00       	jmp    801024c7 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
8010240d:	e8 06 16 00 00       	call   80103a18 <myproc>
80102412:	8b 40 68             	mov    0x68(%eax),%eax
80102415:	83 ec 0c             	sub    $0xc,%esp
80102418:	50                   	push   %eax
80102419:	e8 7a f5 ff ff       	call   80101998 <idup>
8010241e:	83 c4 10             	add    $0x10,%esp
80102421:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102424:	e9 9e 00 00 00       	jmp    801024c7 <namex+0xe1>
    ilock(ip);
80102429:	83 ec 0c             	sub    $0xc,%esp
8010242c:	ff 75 f4             	push   -0xc(%ebp)
8010242f:	e8 9e f5 ff ff       	call   801019d2 <ilock>
80102434:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010243a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010243e:	66 83 f8 01          	cmp    $0x1,%ax
80102442:	74 18                	je     8010245c <namex+0x76>
      iunlockput(ip);
80102444:	83 ec 0c             	sub    $0xc,%esp
80102447:	ff 75 f4             	push   -0xc(%ebp)
8010244a:	e8 b4 f7 ff ff       	call   80101c03 <iunlockput>
8010244f:	83 c4 10             	add    $0x10,%esp
      return 0;
80102452:	b8 00 00 00 00       	mov    $0x0,%eax
80102457:	e9 a7 00 00 00       	jmp    80102503 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
8010245c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102460:	74 20                	je     80102482 <namex+0x9c>
80102462:	8b 45 08             	mov    0x8(%ebp),%eax
80102465:	0f b6 00             	movzbl (%eax),%eax
80102468:	84 c0                	test   %al,%al
8010246a:	75 16                	jne    80102482 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
8010246c:	83 ec 0c             	sub    $0xc,%esp
8010246f:	ff 75 f4             	push   -0xc(%ebp)
80102472:	e8 6e f6 ff ff       	call   80101ae5 <iunlock>
80102477:	83 c4 10             	add    $0x10,%esp
      return ip;
8010247a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010247d:	e9 81 00 00 00       	jmp    80102503 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102482:	83 ec 04             	sub    $0x4,%esp
80102485:	6a 00                	push   $0x0
80102487:	ff 75 10             	push   0x10(%ebp)
8010248a:	ff 75 f4             	push   -0xc(%ebp)
8010248d:	e8 22 fd ff ff       	call   801021b4 <dirlookup>
80102492:	83 c4 10             	add    $0x10,%esp
80102495:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102498:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010249c:	75 15                	jne    801024b3 <namex+0xcd>
      iunlockput(ip);
8010249e:	83 ec 0c             	sub    $0xc,%esp
801024a1:	ff 75 f4             	push   -0xc(%ebp)
801024a4:	e8 5a f7 ff ff       	call   80101c03 <iunlockput>
801024a9:	83 c4 10             	add    $0x10,%esp
      return 0;
801024ac:	b8 00 00 00 00       	mov    $0x0,%eax
801024b1:	eb 50                	jmp    80102503 <namex+0x11d>
    }
    iunlockput(ip);
801024b3:	83 ec 0c             	sub    $0xc,%esp
801024b6:	ff 75 f4             	push   -0xc(%ebp)
801024b9:	e8 45 f7 ff ff       	call   80101c03 <iunlockput>
801024be:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024c7:	83 ec 08             	sub    $0x8,%esp
801024ca:	ff 75 10             	push   0x10(%ebp)
801024cd:	ff 75 08             	push   0x8(%ebp)
801024d0:	e8 71 fe ff ff       	call   80102346 <skipelem>
801024d5:	83 c4 10             	add    $0x10,%esp
801024d8:	89 45 08             	mov    %eax,0x8(%ebp)
801024db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024df:	0f 85 44 ff ff ff    	jne    80102429 <namex+0x43>
  }
  if(nameiparent){
801024e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024e9:	74 15                	je     80102500 <namex+0x11a>
    iput(ip);
801024eb:	83 ec 0c             	sub    $0xc,%esp
801024ee:	ff 75 f4             	push   -0xc(%ebp)
801024f1:	e8 3d f6 ff ff       	call   80101b33 <iput>
801024f6:	83 c4 10             	add    $0x10,%esp
    return 0;
801024f9:	b8 00 00 00 00       	mov    $0x0,%eax
801024fe:	eb 03                	jmp    80102503 <namex+0x11d>
  }
  return ip;
80102500:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102503:	c9                   	leave  
80102504:	c3                   	ret    

80102505 <namei>:

struct inode*
namei(char *path)
{
80102505:	55                   	push   %ebp
80102506:	89 e5                	mov    %esp,%ebp
80102508:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010250b:	83 ec 04             	sub    $0x4,%esp
8010250e:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102511:	50                   	push   %eax
80102512:	6a 00                	push   $0x0
80102514:	ff 75 08             	push   0x8(%ebp)
80102517:	e8 ca fe ff ff       	call   801023e6 <namex>
8010251c:	83 c4 10             	add    $0x10,%esp
}
8010251f:	c9                   	leave  
80102520:	c3                   	ret    

80102521 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102521:	55                   	push   %ebp
80102522:	89 e5                	mov    %esp,%ebp
80102524:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102527:	83 ec 04             	sub    $0x4,%esp
8010252a:	ff 75 0c             	push   0xc(%ebp)
8010252d:	6a 01                	push   $0x1
8010252f:	ff 75 08             	push   0x8(%ebp)
80102532:	e8 af fe ff ff       	call   801023e6 <namex>
80102537:	83 c4 10             	add    $0x10,%esp
}
8010253a:	c9                   	leave  
8010253b:	c3                   	ret    

8010253c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010253c:	55                   	push   %ebp
8010253d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010253f:	a1 b4 b0 30 80       	mov    0x8030b0b4,%eax
80102544:	8b 55 08             	mov    0x8(%ebp),%edx
80102547:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102549:	a1 b4 b0 30 80       	mov    0x8030b0b4,%eax
8010254e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102551:	5d                   	pop    %ebp
80102552:	c3                   	ret    

80102553 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102553:	55                   	push   %ebp
80102554:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102556:	a1 b4 b0 30 80       	mov    0x8030b0b4,%eax
8010255b:	8b 55 08             	mov    0x8(%ebp),%edx
8010255e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102560:	a1 b4 b0 30 80       	mov    0x8030b0b4,%eax
80102565:	8b 55 0c             	mov    0xc(%ebp),%edx
80102568:	89 50 10             	mov    %edx,0x10(%eax)
}
8010256b:	90                   	nop
8010256c:	5d                   	pop    %ebp
8010256d:	c3                   	ret    

8010256e <ioapicinit>:

void
ioapicinit(void)
{
8010256e:	55                   	push   %ebp
8010256f:	89 e5                	mov    %esp,%ebp
80102571:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102574:	c7 05 b4 b0 30 80 00 	movl   $0xfec00000,0x8030b0b4
8010257b:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010257e:	6a 01                	push   $0x1
80102580:	e8 b7 ff ff ff       	call   8010253c <ioapicread>
80102585:	83 c4 04             	add    $0x4,%esp
80102588:	c1 e8 10             	shr    $0x10,%eax
8010258b:	25 ff 00 00 00       	and    $0xff,%eax
80102590:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102593:	6a 00                	push   $0x0
80102595:	e8 a2 ff ff ff       	call   8010253c <ioapicread>
8010259a:	83 c4 04             	add    $0x4,%esp
8010259d:	c1 e8 18             	shr    $0x18,%eax
801025a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025a3:	0f b6 05 54 e7 30 80 	movzbl 0x8030e754,%eax
801025aa:	0f b6 c0             	movzbl %al,%eax
801025ad:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025b0:	74 10                	je     801025c2 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025b2:	83 ec 0c             	sub    $0xc,%esp
801025b5:	68 b4 aa 10 80       	push   $0x8010aab4
801025ba:	e8 35 de ff ff       	call   801003f4 <cprintf>
801025bf:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025c9:	eb 3f                	jmp    8010260a <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ce:	83 c0 20             	add    $0x20,%eax
801025d1:	0d 00 00 01 00       	or     $0x10000,%eax
801025d6:	89 c2                	mov    %eax,%edx
801025d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025db:	83 c0 08             	add    $0x8,%eax
801025de:	01 c0                	add    %eax,%eax
801025e0:	83 ec 08             	sub    $0x8,%esp
801025e3:	52                   	push   %edx
801025e4:	50                   	push   %eax
801025e5:	e8 69 ff ff ff       	call   80102553 <ioapicwrite>
801025ea:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801025ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f0:	83 c0 08             	add    $0x8,%eax
801025f3:	01 c0                	add    %eax,%eax
801025f5:	83 c0 01             	add    $0x1,%eax
801025f8:	83 ec 08             	sub    $0x8,%esp
801025fb:	6a 00                	push   $0x0
801025fd:	50                   	push   %eax
801025fe:	e8 50 ff ff ff       	call   80102553 <ioapicwrite>
80102603:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102606:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010260a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010260d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102610:	7e b9                	jle    801025cb <ioapicinit+0x5d>
  }
}
80102612:	90                   	nop
80102613:	90                   	nop
80102614:	c9                   	leave  
80102615:	c3                   	ret    

80102616 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102616:	55                   	push   %ebp
80102617:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102619:	8b 45 08             	mov    0x8(%ebp),%eax
8010261c:	83 c0 20             	add    $0x20,%eax
8010261f:	89 c2                	mov    %eax,%edx
80102621:	8b 45 08             	mov    0x8(%ebp),%eax
80102624:	83 c0 08             	add    $0x8,%eax
80102627:	01 c0                	add    %eax,%eax
80102629:	52                   	push   %edx
8010262a:	50                   	push   %eax
8010262b:	e8 23 ff ff ff       	call   80102553 <ioapicwrite>
80102630:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102633:	8b 45 0c             	mov    0xc(%ebp),%eax
80102636:	c1 e0 18             	shl    $0x18,%eax
80102639:	89 c2                	mov    %eax,%edx
8010263b:	8b 45 08             	mov    0x8(%ebp),%eax
8010263e:	83 c0 08             	add    $0x8,%eax
80102641:	01 c0                	add    %eax,%eax
80102643:	83 c0 01             	add    $0x1,%eax
80102646:	52                   	push   %edx
80102647:	50                   	push   %eax
80102648:	e8 06 ff ff ff       	call   80102553 <ioapicwrite>
8010264d:	83 c4 08             	add    $0x8,%esp
}
80102650:	90                   	nop
80102651:	c9                   	leave  
80102652:	c3                   	ret    

80102653 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102653:	55                   	push   %ebp
80102654:	89 e5                	mov    %esp,%ebp
80102656:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102659:	83 ec 08             	sub    $0x8,%esp
8010265c:	68 e6 aa 10 80       	push   $0x8010aae6
80102661:	68 c0 b0 30 80       	push   $0x8030b0c0
80102666:	e8 fa 24 00 00       	call   80104b65 <initlock>
8010266b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010266e:	c7 05 f4 b0 30 80 00 	movl   $0x0,0x8030b0f4
80102675:	00 00 00 
  freerange(vstart, vend);
80102678:	83 ec 08             	sub    $0x8,%esp
8010267b:	ff 75 0c             	push   0xc(%ebp)
8010267e:	ff 75 08             	push   0x8(%ebp)
80102681:	e8 2a 00 00 00       	call   801026b0 <freerange>
80102686:	83 c4 10             	add    $0x10,%esp
}
80102689:	90                   	nop
8010268a:	c9                   	leave  
8010268b:	c3                   	ret    

8010268c <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010268c:	55                   	push   %ebp
8010268d:	89 e5                	mov    %esp,%ebp
8010268f:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102692:	83 ec 08             	sub    $0x8,%esp
80102695:	ff 75 0c             	push   0xc(%ebp)
80102698:	ff 75 08             	push   0x8(%ebp)
8010269b:	e8 10 00 00 00       	call   801026b0 <freerange>
801026a0:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026a3:	c7 05 f4 b0 30 80 01 	movl   $0x1,0x8030b0f4
801026aa:	00 00 00 
}
801026ad:	90                   	nop
801026ae:	c9                   	leave  
801026af:	c3                   	ret    

801026b0 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026b0:	55                   	push   %ebp
801026b1:	89 e5                	mov    %esp,%ebp
801026b3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026b6:	8b 45 08             	mov    0x8(%ebp),%eax
801026b9:	05 ff 0f 00 00       	add    $0xfff,%eax
801026be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026c6:	eb 15                	jmp    801026dd <freerange+0x2d>
    kfree(p);
801026c8:	83 ec 0c             	sub    $0xc,%esp
801026cb:	ff 75 f4             	push   -0xc(%ebp)
801026ce:	e8 1b 00 00 00       	call   801026ee <kfree>
801026d3:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026d6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e0:	05 00 10 00 00       	add    $0x1000,%eax
801026e5:	39 45 0c             	cmp    %eax,0xc(%ebp)
801026e8:	73 de                	jae    801026c8 <freerange+0x18>
}
801026ea:	90                   	nop
801026eb:	90                   	nop
801026ec:	c9                   	leave  
801026ed:	c3                   	ret    

801026ee <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801026ee:	55                   	push   %ebp
801026ef:	89 e5                	mov    %esp,%ebp
801026f1:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801026f4:	8b 45 08             	mov    0x8(%ebp),%eax
801026f7:	25 ff 0f 00 00       	and    $0xfff,%eax
801026fc:	85 c0                	test   %eax,%eax
801026fe:	75 18                	jne    80102718 <kfree+0x2a>
80102700:	81 7d 08 00 00 31 80 	cmpl   $0x80310000,0x8(%ebp)
80102707:	72 0f                	jb     80102718 <kfree+0x2a>
80102709:	8b 45 08             	mov    0x8(%ebp),%eax
8010270c:	05 00 00 00 80       	add    $0x80000000,%eax
80102711:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102716:	76 0d                	jbe    80102725 <kfree+0x37>
    panic("kfree");
80102718:	83 ec 0c             	sub    $0xc,%esp
8010271b:	68 eb aa 10 80       	push   $0x8010aaeb
80102720:	e8 84 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102725:	83 ec 04             	sub    $0x4,%esp
80102728:	68 00 10 00 00       	push   $0x1000
8010272d:	6a 01                	push   $0x1
8010272f:	ff 75 08             	push   0x8(%ebp)
80102732:	e8 c6 26 00 00       	call   80104dfd <memset>
80102737:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010273a:	a1 f4 b0 30 80       	mov    0x8030b0f4,%eax
8010273f:	85 c0                	test   %eax,%eax
80102741:	74 10                	je     80102753 <kfree+0x65>
    acquire(&kmem.lock);
80102743:	83 ec 0c             	sub    $0xc,%esp
80102746:	68 c0 b0 30 80       	push   $0x8030b0c0
8010274b:	e8 37 24 00 00       	call   80104b87 <acquire>
80102750:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102753:	8b 45 08             	mov    0x8(%ebp),%eax
80102756:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102759:	8b 15 f8 b0 30 80    	mov    0x8030b0f8,%edx
8010275f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102762:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102767:	a3 f8 b0 30 80       	mov    %eax,0x8030b0f8
  if(kmem.use_lock)
8010276c:	a1 f4 b0 30 80       	mov    0x8030b0f4,%eax
80102771:	85 c0                	test   %eax,%eax
80102773:	74 10                	je     80102785 <kfree+0x97>
    release(&kmem.lock);
80102775:	83 ec 0c             	sub    $0xc,%esp
80102778:	68 c0 b0 30 80       	push   $0x8030b0c0
8010277d:	e8 73 24 00 00       	call   80104bf5 <release>
80102782:	83 c4 10             	add    $0x10,%esp
}
80102785:	90                   	nop
80102786:	c9                   	leave  
80102787:	c3                   	ret    

80102788 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102788:	55                   	push   %ebp
80102789:	89 e5                	mov    %esp,%ebp
8010278b:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
8010278e:	a1 f4 b0 30 80       	mov    0x8030b0f4,%eax
80102793:	85 c0                	test   %eax,%eax
80102795:	74 10                	je     801027a7 <kalloc+0x1f>
    acquire(&kmem.lock);
80102797:	83 ec 0c             	sub    $0xc,%esp
8010279a:	68 c0 b0 30 80       	push   $0x8030b0c0
8010279f:	e8 e3 23 00 00       	call   80104b87 <acquire>
801027a4:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027a7:	a1 f8 b0 30 80       	mov    0x8030b0f8,%eax
801027ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027b3:	74 0a                	je     801027bf <kalloc+0x37>
    kmem.freelist = r->next;
801027b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027b8:	8b 00                	mov    (%eax),%eax
801027ba:	a3 f8 b0 30 80       	mov    %eax,0x8030b0f8
  if(kmem.use_lock)
801027bf:	a1 f4 b0 30 80       	mov    0x8030b0f4,%eax
801027c4:	85 c0                	test   %eax,%eax
801027c6:	74 10                	je     801027d8 <kalloc+0x50>
    release(&kmem.lock);
801027c8:	83 ec 0c             	sub    $0xc,%esp
801027cb:	68 c0 b0 30 80       	push   $0x8030b0c0
801027d0:	e8 20 24 00 00       	call   80104bf5 <release>
801027d5:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027db:	c9                   	leave  
801027dc:	c3                   	ret    

801027dd <inb>:
{
801027dd:	55                   	push   %ebp
801027de:	89 e5                	mov    %esp,%ebp
801027e0:	83 ec 14             	sub    $0x14,%esp
801027e3:	8b 45 08             	mov    0x8(%ebp),%eax
801027e6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027ea:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801027ee:	89 c2                	mov    %eax,%edx
801027f0:	ec                   	in     (%dx),%al
801027f1:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801027f4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801027f8:	c9                   	leave  
801027f9:	c3                   	ret    

801027fa <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801027fa:	55                   	push   %ebp
801027fb:	89 e5                	mov    %esp,%ebp
801027fd:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102800:	6a 64                	push   $0x64
80102802:	e8 d6 ff ff ff       	call   801027dd <inb>
80102807:	83 c4 04             	add    $0x4,%esp
8010280a:	0f b6 c0             	movzbl %al,%eax
8010280d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102813:	83 e0 01             	and    $0x1,%eax
80102816:	85 c0                	test   %eax,%eax
80102818:	75 0a                	jne    80102824 <kbdgetc+0x2a>
    return -1;
8010281a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010281f:	e9 23 01 00 00       	jmp    80102947 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102824:	6a 60                	push   $0x60
80102826:	e8 b2 ff ff ff       	call   801027dd <inb>
8010282b:	83 c4 04             	add    $0x4,%esp
8010282e:	0f b6 c0             	movzbl %al,%eax
80102831:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102834:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010283b:	75 17                	jne    80102854 <kbdgetc+0x5a>
    shift |= E0ESC;
8010283d:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
80102842:	83 c8 40             	or     $0x40,%eax
80102845:	a3 fc b0 30 80       	mov    %eax,0x8030b0fc
    return 0;
8010284a:	b8 00 00 00 00       	mov    $0x0,%eax
8010284f:	e9 f3 00 00 00       	jmp    80102947 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102854:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102857:	25 80 00 00 00       	and    $0x80,%eax
8010285c:	85 c0                	test   %eax,%eax
8010285e:	74 45                	je     801028a5 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102860:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
80102865:	83 e0 40             	and    $0x40,%eax
80102868:	85 c0                	test   %eax,%eax
8010286a:	75 08                	jne    80102874 <kbdgetc+0x7a>
8010286c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010286f:	83 e0 7f             	and    $0x7f,%eax
80102872:	eb 03                	jmp    80102877 <kbdgetc+0x7d>
80102874:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102877:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010287a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010287d:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102882:	0f b6 00             	movzbl (%eax),%eax
80102885:	83 c8 40             	or     $0x40,%eax
80102888:	0f b6 c0             	movzbl %al,%eax
8010288b:	f7 d0                	not    %eax
8010288d:	89 c2                	mov    %eax,%edx
8010288f:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
80102894:	21 d0                	and    %edx,%eax
80102896:	a3 fc b0 30 80       	mov    %eax,0x8030b0fc
    return 0;
8010289b:	b8 00 00 00 00       	mov    $0x0,%eax
801028a0:	e9 a2 00 00 00       	jmp    80102947 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028a5:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
801028aa:	83 e0 40             	and    $0x40,%eax
801028ad:	85 c0                	test   %eax,%eax
801028af:	74 14                	je     801028c5 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028b1:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028b8:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
801028bd:	83 e0 bf             	and    $0xffffffbf,%eax
801028c0:	a3 fc b0 30 80       	mov    %eax,0x8030b0fc
  }

  shift |= shiftcode[data];
801028c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028c8:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028cd:	0f b6 00             	movzbl (%eax),%eax
801028d0:	0f b6 d0             	movzbl %al,%edx
801028d3:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
801028d8:	09 d0                	or     %edx,%eax
801028da:	a3 fc b0 30 80       	mov    %eax,0x8030b0fc
  shift ^= togglecode[data];
801028df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e2:	05 20 d1 10 80       	add    $0x8010d120,%eax
801028e7:	0f b6 00             	movzbl (%eax),%eax
801028ea:	0f b6 d0             	movzbl %al,%edx
801028ed:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
801028f2:	31 d0                	xor    %edx,%eax
801028f4:	a3 fc b0 30 80       	mov    %eax,0x8030b0fc
  c = charcode[shift & (CTL | SHIFT)][data];
801028f9:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
801028fe:	83 e0 03             	and    $0x3,%eax
80102901:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102908:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010290b:	01 d0                	add    %edx,%eax
8010290d:	0f b6 00             	movzbl (%eax),%eax
80102910:	0f b6 c0             	movzbl %al,%eax
80102913:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102916:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
8010291b:	83 e0 08             	and    $0x8,%eax
8010291e:	85 c0                	test   %eax,%eax
80102920:	74 22                	je     80102944 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102922:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102926:	76 0c                	jbe    80102934 <kbdgetc+0x13a>
80102928:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010292c:	77 06                	ja     80102934 <kbdgetc+0x13a>
      c += 'A' - 'a';
8010292e:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102932:	eb 10                	jmp    80102944 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102934:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102938:	76 0a                	jbe    80102944 <kbdgetc+0x14a>
8010293a:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010293e:	77 04                	ja     80102944 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102940:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102944:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102947:	c9                   	leave  
80102948:	c3                   	ret    

80102949 <kbdintr>:

void
kbdintr(void)
{
80102949:	55                   	push   %ebp
8010294a:	89 e5                	mov    %esp,%ebp
8010294c:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
8010294f:	83 ec 0c             	sub    $0xc,%esp
80102952:	68 fa 27 10 80       	push   $0x801027fa
80102957:	e8 7a de ff ff       	call   801007d6 <consoleintr>
8010295c:	83 c4 10             	add    $0x10,%esp
}
8010295f:	90                   	nop
80102960:	c9                   	leave  
80102961:	c3                   	ret    

80102962 <inb>:
{
80102962:	55                   	push   %ebp
80102963:	89 e5                	mov    %esp,%ebp
80102965:	83 ec 14             	sub    $0x14,%esp
80102968:	8b 45 08             	mov    0x8(%ebp),%eax
8010296b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010296f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102973:	89 c2                	mov    %eax,%edx
80102975:	ec                   	in     (%dx),%al
80102976:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102979:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010297d:	c9                   	leave  
8010297e:	c3                   	ret    

8010297f <outb>:
{
8010297f:	55                   	push   %ebp
80102980:	89 e5                	mov    %esp,%ebp
80102982:	83 ec 08             	sub    $0x8,%esp
80102985:	8b 45 08             	mov    0x8(%ebp),%eax
80102988:	8b 55 0c             	mov    0xc(%ebp),%edx
8010298b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010298f:	89 d0                	mov    %edx,%eax
80102991:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102994:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102998:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010299c:	ee                   	out    %al,(%dx)
}
8010299d:	90                   	nop
8010299e:	c9                   	leave  
8010299f:	c3                   	ret    

801029a0 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029a0:	55                   	push   %ebp
801029a1:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029a3:	8b 15 00 b1 30 80    	mov    0x8030b100,%edx
801029a9:	8b 45 08             	mov    0x8(%ebp),%eax
801029ac:	c1 e0 02             	shl    $0x2,%eax
801029af:	01 c2                	add    %eax,%edx
801029b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801029b4:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029b6:	a1 00 b1 30 80       	mov    0x8030b100,%eax
801029bb:	83 c0 20             	add    $0x20,%eax
801029be:	8b 00                	mov    (%eax),%eax
}
801029c0:	90                   	nop
801029c1:	5d                   	pop    %ebp
801029c2:	c3                   	ret    

801029c3 <lapicinit>:

void
lapicinit(void)
{
801029c3:	55                   	push   %ebp
801029c4:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029c6:	a1 00 b1 30 80       	mov    0x8030b100,%eax
801029cb:	85 c0                	test   %eax,%eax
801029cd:	0f 84 0c 01 00 00    	je     80102adf <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029d3:	68 3f 01 00 00       	push   $0x13f
801029d8:	6a 3c                	push   $0x3c
801029da:	e8 c1 ff ff ff       	call   801029a0 <lapicw>
801029df:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029e2:	6a 0b                	push   $0xb
801029e4:	68 f8 00 00 00       	push   $0xf8
801029e9:	e8 b2 ff ff ff       	call   801029a0 <lapicw>
801029ee:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801029f1:	68 20 00 02 00       	push   $0x20020
801029f6:	68 c8 00 00 00       	push   $0xc8
801029fb:	e8 a0 ff ff ff       	call   801029a0 <lapicw>
80102a00:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a03:	68 80 96 98 00       	push   $0x989680
80102a08:	68 e0 00 00 00       	push   $0xe0
80102a0d:	e8 8e ff ff ff       	call   801029a0 <lapicw>
80102a12:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a15:	68 00 00 01 00       	push   $0x10000
80102a1a:	68 d4 00 00 00       	push   $0xd4
80102a1f:	e8 7c ff ff ff       	call   801029a0 <lapicw>
80102a24:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a27:	68 00 00 01 00       	push   $0x10000
80102a2c:	68 d8 00 00 00       	push   $0xd8
80102a31:	e8 6a ff ff ff       	call   801029a0 <lapicw>
80102a36:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a39:	a1 00 b1 30 80       	mov    0x8030b100,%eax
80102a3e:	83 c0 30             	add    $0x30,%eax
80102a41:	8b 00                	mov    (%eax),%eax
80102a43:	c1 e8 10             	shr    $0x10,%eax
80102a46:	25 fc 00 00 00       	and    $0xfc,%eax
80102a4b:	85 c0                	test   %eax,%eax
80102a4d:	74 12                	je     80102a61 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a4f:	68 00 00 01 00       	push   $0x10000
80102a54:	68 d0 00 00 00       	push   $0xd0
80102a59:	e8 42 ff ff ff       	call   801029a0 <lapicw>
80102a5e:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a61:	6a 33                	push   $0x33
80102a63:	68 dc 00 00 00       	push   $0xdc
80102a68:	e8 33 ff ff ff       	call   801029a0 <lapicw>
80102a6d:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a70:	6a 00                	push   $0x0
80102a72:	68 a0 00 00 00       	push   $0xa0
80102a77:	e8 24 ff ff ff       	call   801029a0 <lapicw>
80102a7c:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a7f:	6a 00                	push   $0x0
80102a81:	68 a0 00 00 00       	push   $0xa0
80102a86:	e8 15 ff ff ff       	call   801029a0 <lapicw>
80102a8b:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102a8e:	6a 00                	push   $0x0
80102a90:	6a 2c                	push   $0x2c
80102a92:	e8 09 ff ff ff       	call   801029a0 <lapicw>
80102a97:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102a9a:	6a 00                	push   $0x0
80102a9c:	68 c4 00 00 00       	push   $0xc4
80102aa1:	e8 fa fe ff ff       	call   801029a0 <lapicw>
80102aa6:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102aa9:	68 00 85 08 00       	push   $0x88500
80102aae:	68 c0 00 00 00       	push   $0xc0
80102ab3:	e8 e8 fe ff ff       	call   801029a0 <lapicw>
80102ab8:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102abb:	90                   	nop
80102abc:	a1 00 b1 30 80       	mov    0x8030b100,%eax
80102ac1:	05 00 03 00 00       	add    $0x300,%eax
80102ac6:	8b 00                	mov    (%eax),%eax
80102ac8:	25 00 10 00 00       	and    $0x1000,%eax
80102acd:	85 c0                	test   %eax,%eax
80102acf:	75 eb                	jne    80102abc <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ad1:	6a 00                	push   $0x0
80102ad3:	6a 20                	push   $0x20
80102ad5:	e8 c6 fe ff ff       	call   801029a0 <lapicw>
80102ada:	83 c4 08             	add    $0x8,%esp
80102add:	eb 01                	jmp    80102ae0 <lapicinit+0x11d>
    return;
80102adf:	90                   	nop
}
80102ae0:	c9                   	leave  
80102ae1:	c3                   	ret    

80102ae2 <lapicid>:

int
lapicid(void)
{
80102ae2:	55                   	push   %ebp
80102ae3:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102ae5:	a1 00 b1 30 80       	mov    0x8030b100,%eax
80102aea:	85 c0                	test   %eax,%eax
80102aec:	75 07                	jne    80102af5 <lapicid+0x13>
    return 0;
80102aee:	b8 00 00 00 00       	mov    $0x0,%eax
80102af3:	eb 0d                	jmp    80102b02 <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102af5:	a1 00 b1 30 80       	mov    0x8030b100,%eax
80102afa:	83 c0 20             	add    $0x20,%eax
80102afd:	8b 00                	mov    (%eax),%eax
80102aff:	c1 e8 18             	shr    $0x18,%eax
}
80102b02:	5d                   	pop    %ebp
80102b03:	c3                   	ret    

80102b04 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b04:	55                   	push   %ebp
80102b05:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b07:	a1 00 b1 30 80       	mov    0x8030b100,%eax
80102b0c:	85 c0                	test   %eax,%eax
80102b0e:	74 0c                	je     80102b1c <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b10:	6a 00                	push   $0x0
80102b12:	6a 2c                	push   $0x2c
80102b14:	e8 87 fe ff ff       	call   801029a0 <lapicw>
80102b19:	83 c4 08             	add    $0x8,%esp
}
80102b1c:	90                   	nop
80102b1d:	c9                   	leave  
80102b1e:	c3                   	ret    

80102b1f <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b1f:	55                   	push   %ebp
80102b20:	89 e5                	mov    %esp,%ebp
}
80102b22:	90                   	nop
80102b23:	5d                   	pop    %ebp
80102b24:	c3                   	ret    

80102b25 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b25:	55                   	push   %ebp
80102b26:	89 e5                	mov    %esp,%ebp
80102b28:	83 ec 14             	sub    $0x14,%esp
80102b2b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2e:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b31:	6a 0f                	push   $0xf
80102b33:	6a 70                	push   $0x70
80102b35:	e8 45 fe ff ff       	call   8010297f <outb>
80102b3a:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b3d:	6a 0a                	push   $0xa
80102b3f:	6a 71                	push   $0x71
80102b41:	e8 39 fe ff ff       	call   8010297f <outb>
80102b46:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b49:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b50:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b53:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b58:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b5b:	c1 e8 04             	shr    $0x4,%eax
80102b5e:	89 c2                	mov    %eax,%edx
80102b60:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b63:	83 c0 02             	add    $0x2,%eax
80102b66:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b69:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b6d:	c1 e0 18             	shl    $0x18,%eax
80102b70:	50                   	push   %eax
80102b71:	68 c4 00 00 00       	push   $0xc4
80102b76:	e8 25 fe ff ff       	call   801029a0 <lapicw>
80102b7b:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b7e:	68 00 c5 00 00       	push   $0xc500
80102b83:	68 c0 00 00 00       	push   $0xc0
80102b88:	e8 13 fe ff ff       	call   801029a0 <lapicw>
80102b8d:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102b90:	68 c8 00 00 00       	push   $0xc8
80102b95:	e8 85 ff ff ff       	call   80102b1f <microdelay>
80102b9a:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102b9d:	68 00 85 00 00       	push   $0x8500
80102ba2:	68 c0 00 00 00       	push   $0xc0
80102ba7:	e8 f4 fd ff ff       	call   801029a0 <lapicw>
80102bac:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102baf:	6a 64                	push   $0x64
80102bb1:	e8 69 ff ff ff       	call   80102b1f <microdelay>
80102bb6:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bb9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bc0:	eb 3d                	jmp    80102bff <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bc2:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bc6:	c1 e0 18             	shl    $0x18,%eax
80102bc9:	50                   	push   %eax
80102bca:	68 c4 00 00 00       	push   $0xc4
80102bcf:	e8 cc fd ff ff       	call   801029a0 <lapicw>
80102bd4:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bda:	c1 e8 0c             	shr    $0xc,%eax
80102bdd:	80 cc 06             	or     $0x6,%ah
80102be0:	50                   	push   %eax
80102be1:	68 c0 00 00 00       	push   $0xc0
80102be6:	e8 b5 fd ff ff       	call   801029a0 <lapicw>
80102beb:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102bee:	68 c8 00 00 00       	push   $0xc8
80102bf3:	e8 27 ff ff ff       	call   80102b1f <microdelay>
80102bf8:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102bfb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102bff:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c03:	7e bd                	jle    80102bc2 <lapicstartap+0x9d>
  }
}
80102c05:	90                   	nop
80102c06:	90                   	nop
80102c07:	c9                   	leave  
80102c08:	c3                   	ret    

80102c09 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c09:	55                   	push   %ebp
80102c0a:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80102c0f:	0f b6 c0             	movzbl %al,%eax
80102c12:	50                   	push   %eax
80102c13:	6a 70                	push   $0x70
80102c15:	e8 65 fd ff ff       	call   8010297f <outb>
80102c1a:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c1d:	68 c8 00 00 00       	push   $0xc8
80102c22:	e8 f8 fe ff ff       	call   80102b1f <microdelay>
80102c27:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c2a:	6a 71                	push   $0x71
80102c2c:	e8 31 fd ff ff       	call   80102962 <inb>
80102c31:	83 c4 04             	add    $0x4,%esp
80102c34:	0f b6 c0             	movzbl %al,%eax
}
80102c37:	c9                   	leave  
80102c38:	c3                   	ret    

80102c39 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c39:	55                   	push   %ebp
80102c3a:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c3c:	6a 00                	push   $0x0
80102c3e:	e8 c6 ff ff ff       	call   80102c09 <cmos_read>
80102c43:	83 c4 04             	add    $0x4,%esp
80102c46:	8b 55 08             	mov    0x8(%ebp),%edx
80102c49:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c4b:	6a 02                	push   $0x2
80102c4d:	e8 b7 ff ff ff       	call   80102c09 <cmos_read>
80102c52:	83 c4 04             	add    $0x4,%esp
80102c55:	8b 55 08             	mov    0x8(%ebp),%edx
80102c58:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c5b:	6a 04                	push   $0x4
80102c5d:	e8 a7 ff ff ff       	call   80102c09 <cmos_read>
80102c62:	83 c4 04             	add    $0x4,%esp
80102c65:	8b 55 08             	mov    0x8(%ebp),%edx
80102c68:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c6b:	6a 07                	push   $0x7
80102c6d:	e8 97 ff ff ff       	call   80102c09 <cmos_read>
80102c72:	83 c4 04             	add    $0x4,%esp
80102c75:	8b 55 08             	mov    0x8(%ebp),%edx
80102c78:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c7b:	6a 08                	push   $0x8
80102c7d:	e8 87 ff ff ff       	call   80102c09 <cmos_read>
80102c82:	83 c4 04             	add    $0x4,%esp
80102c85:	8b 55 08             	mov    0x8(%ebp),%edx
80102c88:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102c8b:	6a 09                	push   $0x9
80102c8d:	e8 77 ff ff ff       	call   80102c09 <cmos_read>
80102c92:	83 c4 04             	add    $0x4,%esp
80102c95:	8b 55 08             	mov    0x8(%ebp),%edx
80102c98:	89 42 14             	mov    %eax,0x14(%edx)
}
80102c9b:	90                   	nop
80102c9c:	c9                   	leave  
80102c9d:	c3                   	ret    

80102c9e <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102c9e:	55                   	push   %ebp
80102c9f:	89 e5                	mov    %esp,%ebp
80102ca1:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102ca4:	6a 0b                	push   $0xb
80102ca6:	e8 5e ff ff ff       	call   80102c09 <cmos_read>
80102cab:	83 c4 04             	add    $0x4,%esp
80102cae:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb4:	83 e0 04             	and    $0x4,%eax
80102cb7:	85 c0                	test   %eax,%eax
80102cb9:	0f 94 c0             	sete   %al
80102cbc:	0f b6 c0             	movzbl %al,%eax
80102cbf:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cc2:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cc5:	50                   	push   %eax
80102cc6:	e8 6e ff ff ff       	call   80102c39 <fill_rtcdate>
80102ccb:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102cce:	6a 0a                	push   $0xa
80102cd0:	e8 34 ff ff ff       	call   80102c09 <cmos_read>
80102cd5:	83 c4 04             	add    $0x4,%esp
80102cd8:	25 80 00 00 00       	and    $0x80,%eax
80102cdd:	85 c0                	test   %eax,%eax
80102cdf:	75 27                	jne    80102d08 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102ce1:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102ce4:	50                   	push   %eax
80102ce5:	e8 4f ff ff ff       	call   80102c39 <fill_rtcdate>
80102cea:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102ced:	83 ec 04             	sub    $0x4,%esp
80102cf0:	6a 18                	push   $0x18
80102cf2:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cf5:	50                   	push   %eax
80102cf6:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cf9:	50                   	push   %eax
80102cfa:	e8 65 21 00 00       	call   80104e64 <memcmp>
80102cff:	83 c4 10             	add    $0x10,%esp
80102d02:	85 c0                	test   %eax,%eax
80102d04:	74 05                	je     80102d0b <cmostime+0x6d>
80102d06:	eb ba                	jmp    80102cc2 <cmostime+0x24>
        continue;
80102d08:	90                   	nop
    fill_rtcdate(&t1);
80102d09:	eb b7                	jmp    80102cc2 <cmostime+0x24>
      break;
80102d0b:	90                   	nop
  }

  // convert
  if(bcd) {
80102d0c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d10:	0f 84 b4 00 00 00    	je     80102dca <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d16:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d19:	c1 e8 04             	shr    $0x4,%eax
80102d1c:	89 c2                	mov    %eax,%edx
80102d1e:	89 d0                	mov    %edx,%eax
80102d20:	c1 e0 02             	shl    $0x2,%eax
80102d23:	01 d0                	add    %edx,%eax
80102d25:	01 c0                	add    %eax,%eax
80102d27:	89 c2                	mov    %eax,%edx
80102d29:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d2c:	83 e0 0f             	and    $0xf,%eax
80102d2f:	01 d0                	add    %edx,%eax
80102d31:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d34:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d37:	c1 e8 04             	shr    $0x4,%eax
80102d3a:	89 c2                	mov    %eax,%edx
80102d3c:	89 d0                	mov    %edx,%eax
80102d3e:	c1 e0 02             	shl    $0x2,%eax
80102d41:	01 d0                	add    %edx,%eax
80102d43:	01 c0                	add    %eax,%eax
80102d45:	89 c2                	mov    %eax,%edx
80102d47:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d4a:	83 e0 0f             	and    $0xf,%eax
80102d4d:	01 d0                	add    %edx,%eax
80102d4f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d52:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d55:	c1 e8 04             	shr    $0x4,%eax
80102d58:	89 c2                	mov    %eax,%edx
80102d5a:	89 d0                	mov    %edx,%eax
80102d5c:	c1 e0 02             	shl    $0x2,%eax
80102d5f:	01 d0                	add    %edx,%eax
80102d61:	01 c0                	add    %eax,%eax
80102d63:	89 c2                	mov    %eax,%edx
80102d65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d68:	83 e0 0f             	and    $0xf,%eax
80102d6b:	01 d0                	add    %edx,%eax
80102d6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d73:	c1 e8 04             	shr    $0x4,%eax
80102d76:	89 c2                	mov    %eax,%edx
80102d78:	89 d0                	mov    %edx,%eax
80102d7a:	c1 e0 02             	shl    $0x2,%eax
80102d7d:	01 d0                	add    %edx,%eax
80102d7f:	01 c0                	add    %eax,%eax
80102d81:	89 c2                	mov    %eax,%edx
80102d83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d86:	83 e0 0f             	and    $0xf,%eax
80102d89:	01 d0                	add    %edx,%eax
80102d8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102d8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102d91:	c1 e8 04             	shr    $0x4,%eax
80102d94:	89 c2                	mov    %eax,%edx
80102d96:	89 d0                	mov    %edx,%eax
80102d98:	c1 e0 02             	shl    $0x2,%eax
80102d9b:	01 d0                	add    %edx,%eax
80102d9d:	01 c0                	add    %eax,%eax
80102d9f:	89 c2                	mov    %eax,%edx
80102da1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102da4:	83 e0 0f             	and    $0xf,%eax
80102da7:	01 d0                	add    %edx,%eax
80102da9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102daf:	c1 e8 04             	shr    $0x4,%eax
80102db2:	89 c2                	mov    %eax,%edx
80102db4:	89 d0                	mov    %edx,%eax
80102db6:	c1 e0 02             	shl    $0x2,%eax
80102db9:	01 d0                	add    %edx,%eax
80102dbb:	01 c0                	add    %eax,%eax
80102dbd:	89 c2                	mov    %eax,%edx
80102dbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc2:	83 e0 0f             	and    $0xf,%eax
80102dc5:	01 d0                	add    %edx,%eax
80102dc7:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102dca:	8b 45 08             	mov    0x8(%ebp),%eax
80102dcd:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102dd0:	89 10                	mov    %edx,(%eax)
80102dd2:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102dd5:	89 50 04             	mov    %edx,0x4(%eax)
80102dd8:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102ddb:	89 50 08             	mov    %edx,0x8(%eax)
80102dde:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102de1:	89 50 0c             	mov    %edx,0xc(%eax)
80102de4:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102de7:	89 50 10             	mov    %edx,0x10(%eax)
80102dea:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102ded:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102df0:	8b 45 08             	mov    0x8(%ebp),%eax
80102df3:	8b 40 14             	mov    0x14(%eax),%eax
80102df6:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102dfc:	8b 45 08             	mov    0x8(%ebp),%eax
80102dff:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e02:	90                   	nop
80102e03:	c9                   	leave  
80102e04:	c3                   	ret    

80102e05 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e05:	55                   	push   %ebp
80102e06:	89 e5                	mov    %esp,%ebp
80102e08:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e0b:	83 ec 08             	sub    $0x8,%esp
80102e0e:	68 f1 aa 10 80       	push   $0x8010aaf1
80102e13:	68 20 b1 30 80       	push   $0x8030b120
80102e18:	e8 48 1d 00 00       	call   80104b65 <initlock>
80102e1d:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e20:	83 ec 08             	sub    $0x8,%esp
80102e23:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e26:	50                   	push   %eax
80102e27:	ff 75 08             	push   0x8(%ebp)
80102e2a:	e8 87 e5 ff ff       	call   801013b6 <readsb>
80102e2f:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e35:	a3 54 b1 30 80       	mov    %eax,0x8030b154
  log.size = sb.nlog;
80102e3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e3d:	a3 58 b1 30 80       	mov    %eax,0x8030b158
  log.dev = dev;
80102e42:	8b 45 08             	mov    0x8(%ebp),%eax
80102e45:	a3 64 b1 30 80       	mov    %eax,0x8030b164
  recover_from_log();
80102e4a:	e8 b3 01 00 00       	call   80103002 <recover_from_log>
}
80102e4f:	90                   	nop
80102e50:	c9                   	leave  
80102e51:	c3                   	ret    

80102e52 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e52:	55                   	push   %ebp
80102e53:	89 e5                	mov    %esp,%ebp
80102e55:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e5f:	e9 95 00 00 00       	jmp    80102ef9 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e64:	8b 15 54 b1 30 80    	mov    0x8030b154,%edx
80102e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e6d:	01 d0                	add    %edx,%eax
80102e6f:	83 c0 01             	add    $0x1,%eax
80102e72:	89 c2                	mov    %eax,%edx
80102e74:	a1 64 b1 30 80       	mov    0x8030b164,%eax
80102e79:	83 ec 08             	sub    $0x8,%esp
80102e7c:	52                   	push   %edx
80102e7d:	50                   	push   %eax
80102e7e:	e8 7e d3 ff ff       	call   80100201 <bread>
80102e83:	83 c4 10             	add    $0x10,%esp
80102e86:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e8c:	83 c0 10             	add    $0x10,%eax
80102e8f:	8b 04 85 2c b1 30 80 	mov    -0x7fcf4ed4(,%eax,4),%eax
80102e96:	89 c2                	mov    %eax,%edx
80102e98:	a1 64 b1 30 80       	mov    0x8030b164,%eax
80102e9d:	83 ec 08             	sub    $0x8,%esp
80102ea0:	52                   	push   %edx
80102ea1:	50                   	push   %eax
80102ea2:	e8 5a d3 ff ff       	call   80100201 <bread>
80102ea7:	83 c4 10             	add    $0x10,%esp
80102eaa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102eb0:	8d 50 5c             	lea    0x5c(%eax),%edx
80102eb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102eb6:	83 c0 5c             	add    $0x5c,%eax
80102eb9:	83 ec 04             	sub    $0x4,%esp
80102ebc:	68 00 02 00 00       	push   $0x200
80102ec1:	52                   	push   %edx
80102ec2:	50                   	push   %eax
80102ec3:	e8 f4 1f 00 00       	call   80104ebc <memmove>
80102ec8:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ecb:	83 ec 0c             	sub    $0xc,%esp
80102ece:	ff 75 ec             	push   -0x14(%ebp)
80102ed1:	e8 64 d3 ff ff       	call   8010023a <bwrite>
80102ed6:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ed9:	83 ec 0c             	sub    $0xc,%esp
80102edc:	ff 75 f0             	push   -0x10(%ebp)
80102edf:	e8 9f d3 ff ff       	call   80100283 <brelse>
80102ee4:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102ee7:	83 ec 0c             	sub    $0xc,%esp
80102eea:	ff 75 ec             	push   -0x14(%ebp)
80102eed:	e8 91 d3 ff ff       	call   80100283 <brelse>
80102ef2:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102ef5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ef9:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80102efe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f01:	0f 8c 5d ff ff ff    	jl     80102e64 <install_trans+0x12>
  }
}
80102f07:	90                   	nop
80102f08:	90                   	nop
80102f09:	c9                   	leave  
80102f0a:	c3                   	ret    

80102f0b <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f0b:	55                   	push   %ebp
80102f0c:	89 e5                	mov    %esp,%ebp
80102f0e:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f11:	a1 54 b1 30 80       	mov    0x8030b154,%eax
80102f16:	89 c2                	mov    %eax,%edx
80102f18:	a1 64 b1 30 80       	mov    0x8030b164,%eax
80102f1d:	83 ec 08             	sub    $0x8,%esp
80102f20:	52                   	push   %edx
80102f21:	50                   	push   %eax
80102f22:	e8 da d2 ff ff       	call   80100201 <bread>
80102f27:	83 c4 10             	add    $0x10,%esp
80102f2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f30:	83 c0 5c             	add    $0x5c,%eax
80102f33:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f39:	8b 00                	mov    (%eax),%eax
80102f3b:	a3 68 b1 30 80       	mov    %eax,0x8030b168
  for (i = 0; i < log.lh.n; i++) {
80102f40:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f47:	eb 1b                	jmp    80102f64 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f4f:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f53:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f56:	83 c2 10             	add    $0x10,%edx
80102f59:	89 04 95 2c b1 30 80 	mov    %eax,-0x7fcf4ed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f60:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f64:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80102f69:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f6c:	7c db                	jl     80102f49 <read_head+0x3e>
  }
  brelse(buf);
80102f6e:	83 ec 0c             	sub    $0xc,%esp
80102f71:	ff 75 f0             	push   -0x10(%ebp)
80102f74:	e8 0a d3 ff ff       	call   80100283 <brelse>
80102f79:	83 c4 10             	add    $0x10,%esp
}
80102f7c:	90                   	nop
80102f7d:	c9                   	leave  
80102f7e:	c3                   	ret    

80102f7f <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f7f:	55                   	push   %ebp
80102f80:	89 e5                	mov    %esp,%ebp
80102f82:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f85:	a1 54 b1 30 80       	mov    0x8030b154,%eax
80102f8a:	89 c2                	mov    %eax,%edx
80102f8c:	a1 64 b1 30 80       	mov    0x8030b164,%eax
80102f91:	83 ec 08             	sub    $0x8,%esp
80102f94:	52                   	push   %edx
80102f95:	50                   	push   %eax
80102f96:	e8 66 d2 ff ff       	call   80100201 <bread>
80102f9b:	83 c4 10             	add    $0x10,%esp
80102f9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fa4:	83 c0 5c             	add    $0x5c,%eax
80102fa7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102faa:	8b 15 68 b1 30 80    	mov    0x8030b168,%edx
80102fb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fb3:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fb5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fbc:	eb 1b                	jmp    80102fd9 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fc1:	83 c0 10             	add    $0x10,%eax
80102fc4:	8b 0c 85 2c b1 30 80 	mov    -0x7fcf4ed4(,%eax,4),%ecx
80102fcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fce:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fd1:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fd5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102fd9:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80102fde:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102fe1:	7c db                	jl     80102fbe <write_head+0x3f>
  }
  bwrite(buf);
80102fe3:	83 ec 0c             	sub    $0xc,%esp
80102fe6:	ff 75 f0             	push   -0x10(%ebp)
80102fe9:	e8 4c d2 ff ff       	call   8010023a <bwrite>
80102fee:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80102ff1:	83 ec 0c             	sub    $0xc,%esp
80102ff4:	ff 75 f0             	push   -0x10(%ebp)
80102ff7:	e8 87 d2 ff ff       	call   80100283 <brelse>
80102ffc:	83 c4 10             	add    $0x10,%esp
}
80102fff:	90                   	nop
80103000:	c9                   	leave  
80103001:	c3                   	ret    

80103002 <recover_from_log>:

static void
recover_from_log(void)
{
80103002:	55                   	push   %ebp
80103003:	89 e5                	mov    %esp,%ebp
80103005:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103008:	e8 fe fe ff ff       	call   80102f0b <read_head>
  install_trans(); // if committed, copy from log to disk
8010300d:	e8 40 fe ff ff       	call   80102e52 <install_trans>
  log.lh.n = 0;
80103012:	c7 05 68 b1 30 80 00 	movl   $0x0,0x8030b168
80103019:	00 00 00 
  write_head(); // clear the log
8010301c:	e8 5e ff ff ff       	call   80102f7f <write_head>
}
80103021:	90                   	nop
80103022:	c9                   	leave  
80103023:	c3                   	ret    

80103024 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103024:	55                   	push   %ebp
80103025:	89 e5                	mov    %esp,%ebp
80103027:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010302a:	83 ec 0c             	sub    $0xc,%esp
8010302d:	68 20 b1 30 80       	push   $0x8030b120
80103032:	e8 50 1b 00 00       	call   80104b87 <acquire>
80103037:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010303a:	a1 60 b1 30 80       	mov    0x8030b160,%eax
8010303f:	85 c0                	test   %eax,%eax
80103041:	74 17                	je     8010305a <begin_op+0x36>
      sleep(&log, &log.lock);
80103043:	83 ec 08             	sub    $0x8,%esp
80103046:	68 20 b1 30 80       	push   $0x8030b120
8010304b:	68 20 b1 30 80       	push   $0x8030b120
80103050:	e8 d8 16 00 00       	call   8010472d <sleep>
80103055:	83 c4 10             	add    $0x10,%esp
80103058:	eb e0                	jmp    8010303a <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010305a:	8b 0d 68 b1 30 80    	mov    0x8030b168,%ecx
80103060:	a1 5c b1 30 80       	mov    0x8030b15c,%eax
80103065:	8d 50 01             	lea    0x1(%eax),%edx
80103068:	89 d0                	mov    %edx,%eax
8010306a:	c1 e0 02             	shl    $0x2,%eax
8010306d:	01 d0                	add    %edx,%eax
8010306f:	01 c0                	add    %eax,%eax
80103071:	01 c8                	add    %ecx,%eax
80103073:	83 f8 1e             	cmp    $0x1e,%eax
80103076:	7e 17                	jle    8010308f <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103078:	83 ec 08             	sub    $0x8,%esp
8010307b:	68 20 b1 30 80       	push   $0x8030b120
80103080:	68 20 b1 30 80       	push   $0x8030b120
80103085:	e8 a3 16 00 00       	call   8010472d <sleep>
8010308a:	83 c4 10             	add    $0x10,%esp
8010308d:	eb ab                	jmp    8010303a <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010308f:	a1 5c b1 30 80       	mov    0x8030b15c,%eax
80103094:	83 c0 01             	add    $0x1,%eax
80103097:	a3 5c b1 30 80       	mov    %eax,0x8030b15c
      release(&log.lock);
8010309c:	83 ec 0c             	sub    $0xc,%esp
8010309f:	68 20 b1 30 80       	push   $0x8030b120
801030a4:	e8 4c 1b 00 00       	call   80104bf5 <release>
801030a9:	83 c4 10             	add    $0x10,%esp
      break;
801030ac:	90                   	nop
    }
  }
}
801030ad:	90                   	nop
801030ae:	c9                   	leave  
801030af:	c3                   	ret    

801030b0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030b0:	55                   	push   %ebp
801030b1:	89 e5                	mov    %esp,%ebp
801030b3:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030bd:	83 ec 0c             	sub    $0xc,%esp
801030c0:	68 20 b1 30 80       	push   $0x8030b120
801030c5:	e8 bd 1a 00 00       	call   80104b87 <acquire>
801030ca:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030cd:	a1 5c b1 30 80       	mov    0x8030b15c,%eax
801030d2:	83 e8 01             	sub    $0x1,%eax
801030d5:	a3 5c b1 30 80       	mov    %eax,0x8030b15c
  if(log.committing)
801030da:	a1 60 b1 30 80       	mov    0x8030b160,%eax
801030df:	85 c0                	test   %eax,%eax
801030e1:	74 0d                	je     801030f0 <end_op+0x40>
    panic("log.committing");
801030e3:	83 ec 0c             	sub    $0xc,%esp
801030e6:	68 f5 aa 10 80       	push   $0x8010aaf5
801030eb:	e8 b9 d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
801030f0:	a1 5c b1 30 80       	mov    0x8030b15c,%eax
801030f5:	85 c0                	test   %eax,%eax
801030f7:	75 13                	jne    8010310c <end_op+0x5c>
    do_commit = 1;
801030f9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103100:	c7 05 60 b1 30 80 01 	movl   $0x1,0x8030b160
80103107:	00 00 00 
8010310a:	eb 10                	jmp    8010311c <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010310c:	83 ec 0c             	sub    $0xc,%esp
8010310f:	68 20 b1 30 80       	push   $0x8030b120
80103114:	e8 fe 16 00 00       	call   80104817 <wakeup>
80103119:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010311c:	83 ec 0c             	sub    $0xc,%esp
8010311f:	68 20 b1 30 80       	push   $0x8030b120
80103124:	e8 cc 1a 00 00       	call   80104bf5 <release>
80103129:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010312c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103130:	74 3f                	je     80103171 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103132:	e8 f6 00 00 00       	call   8010322d <commit>
    acquire(&log.lock);
80103137:	83 ec 0c             	sub    $0xc,%esp
8010313a:	68 20 b1 30 80       	push   $0x8030b120
8010313f:	e8 43 1a 00 00       	call   80104b87 <acquire>
80103144:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103147:	c7 05 60 b1 30 80 00 	movl   $0x0,0x8030b160
8010314e:	00 00 00 
    wakeup(&log);
80103151:	83 ec 0c             	sub    $0xc,%esp
80103154:	68 20 b1 30 80       	push   $0x8030b120
80103159:	e8 b9 16 00 00       	call   80104817 <wakeup>
8010315e:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103161:	83 ec 0c             	sub    $0xc,%esp
80103164:	68 20 b1 30 80       	push   $0x8030b120
80103169:	e8 87 1a 00 00       	call   80104bf5 <release>
8010316e:	83 c4 10             	add    $0x10,%esp
  }
}
80103171:	90                   	nop
80103172:	c9                   	leave  
80103173:	c3                   	ret    

80103174 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103174:	55                   	push   %ebp
80103175:	89 e5                	mov    %esp,%ebp
80103177:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010317a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103181:	e9 95 00 00 00       	jmp    8010321b <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103186:	8b 15 54 b1 30 80    	mov    0x8030b154,%edx
8010318c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010318f:	01 d0                	add    %edx,%eax
80103191:	83 c0 01             	add    $0x1,%eax
80103194:	89 c2                	mov    %eax,%edx
80103196:	a1 64 b1 30 80       	mov    0x8030b164,%eax
8010319b:	83 ec 08             	sub    $0x8,%esp
8010319e:	52                   	push   %edx
8010319f:	50                   	push   %eax
801031a0:	e8 5c d0 ff ff       	call   80100201 <bread>
801031a5:	83 c4 10             	add    $0x10,%esp
801031a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031ae:	83 c0 10             	add    $0x10,%eax
801031b1:	8b 04 85 2c b1 30 80 	mov    -0x7fcf4ed4(,%eax,4),%eax
801031b8:	89 c2                	mov    %eax,%edx
801031ba:	a1 64 b1 30 80       	mov    0x8030b164,%eax
801031bf:	83 ec 08             	sub    $0x8,%esp
801031c2:	52                   	push   %edx
801031c3:	50                   	push   %eax
801031c4:	e8 38 d0 ff ff       	call   80100201 <bread>
801031c9:	83 c4 10             	add    $0x10,%esp
801031cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031d2:	8d 50 5c             	lea    0x5c(%eax),%edx
801031d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031d8:	83 c0 5c             	add    $0x5c,%eax
801031db:	83 ec 04             	sub    $0x4,%esp
801031de:	68 00 02 00 00       	push   $0x200
801031e3:	52                   	push   %edx
801031e4:	50                   	push   %eax
801031e5:	e8 d2 1c 00 00       	call   80104ebc <memmove>
801031ea:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801031ed:	83 ec 0c             	sub    $0xc,%esp
801031f0:	ff 75 f0             	push   -0x10(%ebp)
801031f3:	e8 42 d0 ff ff       	call   8010023a <bwrite>
801031f8:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801031fb:	83 ec 0c             	sub    $0xc,%esp
801031fe:	ff 75 ec             	push   -0x14(%ebp)
80103201:	e8 7d d0 ff ff       	call   80100283 <brelse>
80103206:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103209:	83 ec 0c             	sub    $0xc,%esp
8010320c:	ff 75 f0             	push   -0x10(%ebp)
8010320f:	e8 6f d0 ff ff       	call   80100283 <brelse>
80103214:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103217:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010321b:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80103220:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103223:	0f 8c 5d ff ff ff    	jl     80103186 <write_log+0x12>
  }
}
80103229:	90                   	nop
8010322a:	90                   	nop
8010322b:	c9                   	leave  
8010322c:	c3                   	ret    

8010322d <commit>:

static void
commit()
{
8010322d:	55                   	push   %ebp
8010322e:	89 e5                	mov    %esp,%ebp
80103230:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103233:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80103238:	85 c0                	test   %eax,%eax
8010323a:	7e 1e                	jle    8010325a <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010323c:	e8 33 ff ff ff       	call   80103174 <write_log>
    write_head();    // Write header to disk -- the real commit
80103241:	e8 39 fd ff ff       	call   80102f7f <write_head>
    install_trans(); // Now install writes to home locations
80103246:	e8 07 fc ff ff       	call   80102e52 <install_trans>
    log.lh.n = 0;
8010324b:	c7 05 68 b1 30 80 00 	movl   $0x0,0x8030b168
80103252:	00 00 00 
    write_head();    // Erase the transaction from the log
80103255:	e8 25 fd ff ff       	call   80102f7f <write_head>
  }
}
8010325a:	90                   	nop
8010325b:	c9                   	leave  
8010325c:	c3                   	ret    

8010325d <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010325d:	55                   	push   %ebp
8010325e:	89 e5                	mov    %esp,%ebp
80103260:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103263:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80103268:	83 f8 1d             	cmp    $0x1d,%eax
8010326b:	7f 12                	jg     8010327f <log_write+0x22>
8010326d:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80103272:	8b 15 58 b1 30 80    	mov    0x8030b158,%edx
80103278:	83 ea 01             	sub    $0x1,%edx
8010327b:	39 d0                	cmp    %edx,%eax
8010327d:	7c 0d                	jl     8010328c <log_write+0x2f>
    panic("too big a transaction");
8010327f:	83 ec 0c             	sub    $0xc,%esp
80103282:	68 04 ab 10 80       	push   $0x8010ab04
80103287:	e8 1d d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
8010328c:	a1 5c b1 30 80       	mov    0x8030b15c,%eax
80103291:	85 c0                	test   %eax,%eax
80103293:	7f 0d                	jg     801032a2 <log_write+0x45>
    panic("log_write outside of trans");
80103295:	83 ec 0c             	sub    $0xc,%esp
80103298:	68 1a ab 10 80       	push   $0x8010ab1a
8010329d:	e8 07 d3 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032a2:	83 ec 0c             	sub    $0xc,%esp
801032a5:	68 20 b1 30 80       	push   $0x8030b120
801032aa:	e8 d8 18 00 00       	call   80104b87 <acquire>
801032af:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032b9:	eb 1d                	jmp    801032d8 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032be:	83 c0 10             	add    $0x10,%eax
801032c1:	8b 04 85 2c b1 30 80 	mov    -0x7fcf4ed4(,%eax,4),%eax
801032c8:	89 c2                	mov    %eax,%edx
801032ca:	8b 45 08             	mov    0x8(%ebp),%eax
801032cd:	8b 40 08             	mov    0x8(%eax),%eax
801032d0:	39 c2                	cmp    %eax,%edx
801032d2:	74 10                	je     801032e4 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032d4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032d8:	a1 68 b1 30 80       	mov    0x8030b168,%eax
801032dd:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032e0:	7c d9                	jl     801032bb <log_write+0x5e>
801032e2:	eb 01                	jmp    801032e5 <log_write+0x88>
      break;
801032e4:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032e5:	8b 45 08             	mov    0x8(%ebp),%eax
801032e8:	8b 40 08             	mov    0x8(%eax),%eax
801032eb:	89 c2                	mov    %eax,%edx
801032ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032f0:	83 c0 10             	add    $0x10,%eax
801032f3:	89 14 85 2c b1 30 80 	mov    %edx,-0x7fcf4ed4(,%eax,4)
  if (i == log.lh.n)
801032fa:	a1 68 b1 30 80       	mov    0x8030b168,%eax
801032ff:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103302:	75 0d                	jne    80103311 <log_write+0xb4>
    log.lh.n++;
80103304:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80103309:	83 c0 01             	add    $0x1,%eax
8010330c:	a3 68 b1 30 80       	mov    %eax,0x8030b168
  b->flags |= B_DIRTY; // prevent eviction
80103311:	8b 45 08             	mov    0x8(%ebp),%eax
80103314:	8b 00                	mov    (%eax),%eax
80103316:	83 c8 04             	or     $0x4,%eax
80103319:	89 c2                	mov    %eax,%edx
8010331b:	8b 45 08             	mov    0x8(%ebp),%eax
8010331e:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103320:	83 ec 0c             	sub    $0xc,%esp
80103323:	68 20 b1 30 80       	push   $0x8030b120
80103328:	e8 c8 18 00 00       	call   80104bf5 <release>
8010332d:	83 c4 10             	add    $0x10,%esp
}
80103330:	90                   	nop
80103331:	c9                   	leave  
80103332:	c3                   	ret    

80103333 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103333:	55                   	push   %ebp
80103334:	89 e5                	mov    %esp,%ebp
80103336:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103339:	8b 55 08             	mov    0x8(%ebp),%edx
8010333c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010333f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103342:	f0 87 02             	lock xchg %eax,(%edx)
80103345:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103348:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010334b:	c9                   	leave  
8010334c:	c3                   	ret    

8010334d <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010334d:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103351:	83 e4 f0             	and    $0xfffffff0,%esp
80103354:	ff 71 fc             	push   -0x4(%ecx)
80103357:	55                   	push   %ebp
80103358:	89 e5                	mov    %esp,%ebp
8010335a:	51                   	push   %ecx
8010335b:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
8010335e:	e8 1a 53 00 00       	call   8010867d <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103363:	83 ec 08             	sub    $0x8,%esp
80103366:	68 00 00 40 80       	push   $0x80400000
8010336b:	68 00 00 31 80       	push   $0x80310000
80103370:	e8 de f2 ff ff       	call   80102653 <kinit1>
80103375:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103378:	e8 2f 49 00 00       	call   80107cac <kvmalloc>
  mpinit_uefi();
8010337d:	e8 c1 50 00 00       	call   80108443 <mpinit_uefi>
  lapicinit();     // interrupt controller
80103382:	e8 3c f6 ff ff       	call   801029c3 <lapicinit>
  seginit();       // segment descriptors
80103387:	e8 b8 43 00 00       	call   80107744 <seginit>
  picinit();    // disable pic
8010338c:	e8 9d 01 00 00       	call   8010352e <picinit>
  ioapicinit();    // another interrupt controller
80103391:	e8 d8 f1 ff ff       	call   8010256e <ioapicinit>
  consoleinit();   // console hardware
80103396:	e8 64 d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
8010339b:	e8 3d 37 00 00       	call   80106add <uartinit>
  pinit();         // process table
801033a0:	e8 c2 05 00 00       	call   80103967 <pinit>
  tvinit();        // trap vectors
801033a5:	e8 8a 31 00 00       	call   80106534 <tvinit>
  binit();         // buffer cache
801033aa:	e8 b7 cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033af:	e8 f3 db ff ff       	call   80100fa7 <fileinit>
  ideinit();       // disk 
801033b4:	e8 05 74 00 00       	call   8010a7be <ideinit>
  startothers();   // start other processors
801033b9:	e8 8a 00 00 00       	call   80103448 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033be:	83 ec 08             	sub    $0x8,%esp
801033c1:	68 00 00 00 a0       	push   $0xa0000000
801033c6:	68 00 00 40 80       	push   $0x80400000
801033cb:	e8 bc f2 ff ff       	call   8010268c <kinit2>
801033d0:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033d3:	e8 fe 54 00 00       	call   801088d6 <pci_init>
  arp_scan();
801033d8:	e8 35 62 00 00       	call   80109612 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033dd:	e8 be 07 00 00       	call   80103ba0 <userinit>

  mpmain();        // finish this processor's setup
801033e2:	e8 1a 00 00 00       	call   80103401 <mpmain>

801033e7 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801033e7:	55                   	push   %ebp
801033e8:	89 e5                	mov    %esp,%ebp
801033ea:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801033ed:	e8 d2 48 00 00       	call   80107cc4 <switchkvm>
  seginit();
801033f2:	e8 4d 43 00 00       	call   80107744 <seginit>
  lapicinit();
801033f7:	e8 c7 f5 ff ff       	call   801029c3 <lapicinit>
  mpmain();
801033fc:	e8 00 00 00 00       	call   80103401 <mpmain>

80103401 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103401:	55                   	push   %ebp
80103402:	89 e5                	mov    %esp,%ebp
80103404:	53                   	push   %ebx
80103405:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103408:	e8 78 05 00 00       	call   80103985 <cpuid>
8010340d:	89 c3                	mov    %eax,%ebx
8010340f:	e8 71 05 00 00       	call   80103985 <cpuid>
80103414:	83 ec 04             	sub    $0x4,%esp
80103417:	53                   	push   %ebx
80103418:	50                   	push   %eax
80103419:	68 35 ab 10 80       	push   $0x8010ab35
8010341e:	e8 d1 cf ff ff       	call   801003f4 <cprintf>
80103423:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103426:	e8 7f 32 00 00       	call   801066aa <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
8010342b:	e8 70 05 00 00       	call   801039a0 <mycpu>
80103430:	05 a0 00 00 00       	add    $0xa0,%eax
80103435:	83 ec 08             	sub    $0x8,%esp
80103438:	6a 01                	push   $0x1
8010343a:	50                   	push   %eax
8010343b:	e8 f3 fe ff ff       	call   80103333 <xchg>
80103440:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103443:	e8 a4 0d 00 00       	call   801041ec <scheduler>

80103448 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103448:	55                   	push   %ebp
80103449:	89 e5                	mov    %esp,%ebp
8010344b:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010344e:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103455:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010345a:	83 ec 04             	sub    $0x4,%esp
8010345d:	50                   	push   %eax
8010345e:	68 38 f5 10 80       	push   $0x8010f538
80103463:	ff 75 f0             	push   -0x10(%ebp)
80103466:	e8 51 1a 00 00       	call   80104ebc <memmove>
8010346b:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010346e:	c7 45 f4 80 e4 30 80 	movl   $0x8030e480,-0xc(%ebp)
80103475:	eb 79                	jmp    801034f0 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103477:	e8 24 05 00 00       	call   801039a0 <mycpu>
8010347c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010347f:	74 67                	je     801034e8 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103481:	e8 02 f3 ff ff       	call   80102788 <kalloc>
80103486:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103489:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010348c:	83 e8 04             	sub    $0x4,%eax
8010348f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103492:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103498:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010349a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010349d:	83 e8 08             	sub    $0x8,%eax
801034a0:	c7 00 e7 33 10 80    	movl   $0x801033e7,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034a6:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034ab:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b4:	83 e8 0c             	sub    $0xc,%eax
801034b7:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034bc:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034c5:	0f b6 00             	movzbl (%eax),%eax
801034c8:	0f b6 c0             	movzbl %al,%eax
801034cb:	83 ec 08             	sub    $0x8,%esp
801034ce:	52                   	push   %edx
801034cf:	50                   	push   %eax
801034d0:	e8 50 f6 ff ff       	call   80102b25 <lapicstartap>
801034d5:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034d8:	90                   	nop
801034d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034dc:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034e2:	85 c0                	test   %eax,%eax
801034e4:	74 f3                	je     801034d9 <startothers+0x91>
801034e6:	eb 01                	jmp    801034e9 <startothers+0xa1>
      continue;
801034e8:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801034e9:	81 45 f4 b4 00 00 00 	addl   $0xb4,-0xc(%ebp)
801034f0:	a1 50 e7 30 80       	mov    0x8030e750,%eax
801034f5:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801034fb:	05 80 e4 30 80       	add    $0x8030e480,%eax
80103500:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103503:	0f 82 6e ff ff ff    	jb     80103477 <startothers+0x2f>
      ;
  }
}
80103509:	90                   	nop
8010350a:	90                   	nop
8010350b:	c9                   	leave  
8010350c:	c3                   	ret    

8010350d <outb>:
{
8010350d:	55                   	push   %ebp
8010350e:	89 e5                	mov    %esp,%ebp
80103510:	83 ec 08             	sub    $0x8,%esp
80103513:	8b 45 08             	mov    0x8(%ebp),%eax
80103516:	8b 55 0c             	mov    0xc(%ebp),%edx
80103519:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010351d:	89 d0                	mov    %edx,%eax
8010351f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103522:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103526:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010352a:	ee                   	out    %al,(%dx)
}
8010352b:	90                   	nop
8010352c:	c9                   	leave  
8010352d:	c3                   	ret    

8010352e <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
8010352e:	55                   	push   %ebp
8010352f:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103531:	68 ff 00 00 00       	push   $0xff
80103536:	6a 21                	push   $0x21
80103538:	e8 d0 ff ff ff       	call   8010350d <outb>
8010353d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103540:	68 ff 00 00 00       	push   $0xff
80103545:	68 a1 00 00 00       	push   $0xa1
8010354a:	e8 be ff ff ff       	call   8010350d <outb>
8010354f:	83 c4 08             	add    $0x8,%esp
}
80103552:	90                   	nop
80103553:	c9                   	leave  
80103554:	c3                   	ret    

80103555 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103555:	55                   	push   %ebp
80103556:	89 e5                	mov    %esp,%ebp
80103558:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010355b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103562:	8b 45 0c             	mov    0xc(%ebp),%eax
80103565:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010356b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010356e:	8b 10                	mov    (%eax),%edx
80103570:	8b 45 08             	mov    0x8(%ebp),%eax
80103573:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103575:	e8 4b da ff ff       	call   80100fc5 <filealloc>
8010357a:	8b 55 08             	mov    0x8(%ebp),%edx
8010357d:	89 02                	mov    %eax,(%edx)
8010357f:	8b 45 08             	mov    0x8(%ebp),%eax
80103582:	8b 00                	mov    (%eax),%eax
80103584:	85 c0                	test   %eax,%eax
80103586:	0f 84 c8 00 00 00    	je     80103654 <pipealloc+0xff>
8010358c:	e8 34 da ff ff       	call   80100fc5 <filealloc>
80103591:	8b 55 0c             	mov    0xc(%ebp),%edx
80103594:	89 02                	mov    %eax,(%edx)
80103596:	8b 45 0c             	mov    0xc(%ebp),%eax
80103599:	8b 00                	mov    (%eax),%eax
8010359b:	85 c0                	test   %eax,%eax
8010359d:	0f 84 b1 00 00 00    	je     80103654 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035a3:	e8 e0 f1 ff ff       	call   80102788 <kalloc>
801035a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035af:	0f 84 a2 00 00 00    	je     80103657 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035b8:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035bf:	00 00 00 
  p->writeopen = 1;
801035c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035c5:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035cc:	00 00 00 
  p->nwrite = 0;
801035cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d2:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035d9:	00 00 00 
  p->nread = 0;
801035dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035df:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035e6:	00 00 00 
  initlock(&p->lock, "pipe");
801035e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ec:	83 ec 08             	sub    $0x8,%esp
801035ef:	68 49 ab 10 80       	push   $0x8010ab49
801035f4:	50                   	push   %eax
801035f5:	e8 6b 15 00 00       	call   80104b65 <initlock>
801035fa:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801035fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103600:	8b 00                	mov    (%eax),%eax
80103602:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103608:	8b 45 08             	mov    0x8(%ebp),%eax
8010360b:	8b 00                	mov    (%eax),%eax
8010360d:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103611:	8b 45 08             	mov    0x8(%ebp),%eax
80103614:	8b 00                	mov    (%eax),%eax
80103616:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010361a:	8b 45 08             	mov    0x8(%ebp),%eax
8010361d:	8b 00                	mov    (%eax),%eax
8010361f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103622:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103625:	8b 45 0c             	mov    0xc(%ebp),%eax
80103628:	8b 00                	mov    (%eax),%eax
8010362a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103630:	8b 45 0c             	mov    0xc(%ebp),%eax
80103633:	8b 00                	mov    (%eax),%eax
80103635:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103639:	8b 45 0c             	mov    0xc(%ebp),%eax
8010363c:	8b 00                	mov    (%eax),%eax
8010363e:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103642:	8b 45 0c             	mov    0xc(%ebp),%eax
80103645:	8b 00                	mov    (%eax),%eax
80103647:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010364a:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010364d:	b8 00 00 00 00       	mov    $0x0,%eax
80103652:	eb 51                	jmp    801036a5 <pipealloc+0x150>
    goto bad;
80103654:	90                   	nop
80103655:	eb 01                	jmp    80103658 <pipealloc+0x103>
    goto bad;
80103657:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103658:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010365c:	74 0e                	je     8010366c <pipealloc+0x117>
    kfree((char*)p);
8010365e:	83 ec 0c             	sub    $0xc,%esp
80103661:	ff 75 f4             	push   -0xc(%ebp)
80103664:	e8 85 f0 ff ff       	call   801026ee <kfree>
80103669:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010366c:	8b 45 08             	mov    0x8(%ebp),%eax
8010366f:	8b 00                	mov    (%eax),%eax
80103671:	85 c0                	test   %eax,%eax
80103673:	74 11                	je     80103686 <pipealloc+0x131>
    fileclose(*f0);
80103675:	8b 45 08             	mov    0x8(%ebp),%eax
80103678:	8b 00                	mov    (%eax),%eax
8010367a:	83 ec 0c             	sub    $0xc,%esp
8010367d:	50                   	push   %eax
8010367e:	e8 00 da ff ff       	call   80101083 <fileclose>
80103683:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103686:	8b 45 0c             	mov    0xc(%ebp),%eax
80103689:	8b 00                	mov    (%eax),%eax
8010368b:	85 c0                	test   %eax,%eax
8010368d:	74 11                	je     801036a0 <pipealloc+0x14b>
    fileclose(*f1);
8010368f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103692:	8b 00                	mov    (%eax),%eax
80103694:	83 ec 0c             	sub    $0xc,%esp
80103697:	50                   	push   %eax
80103698:	e8 e6 d9 ff ff       	call   80101083 <fileclose>
8010369d:	83 c4 10             	add    $0x10,%esp
  return -1;
801036a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036a5:	c9                   	leave  
801036a6:	c3                   	ret    

801036a7 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036a7:	55                   	push   %ebp
801036a8:	89 e5                	mov    %esp,%ebp
801036aa:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036ad:	8b 45 08             	mov    0x8(%ebp),%eax
801036b0:	83 ec 0c             	sub    $0xc,%esp
801036b3:	50                   	push   %eax
801036b4:	e8 ce 14 00 00       	call   80104b87 <acquire>
801036b9:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036bc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036c0:	74 23                	je     801036e5 <pipeclose+0x3e>
    p->writeopen = 0;
801036c2:	8b 45 08             	mov    0x8(%ebp),%eax
801036c5:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036cc:	00 00 00 
    wakeup(&p->nread);
801036cf:	8b 45 08             	mov    0x8(%ebp),%eax
801036d2:	05 34 02 00 00       	add    $0x234,%eax
801036d7:	83 ec 0c             	sub    $0xc,%esp
801036da:	50                   	push   %eax
801036db:	e8 37 11 00 00       	call   80104817 <wakeup>
801036e0:	83 c4 10             	add    $0x10,%esp
801036e3:	eb 21                	jmp    80103706 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036e5:	8b 45 08             	mov    0x8(%ebp),%eax
801036e8:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801036ef:	00 00 00 
    wakeup(&p->nwrite);
801036f2:	8b 45 08             	mov    0x8(%ebp),%eax
801036f5:	05 38 02 00 00       	add    $0x238,%eax
801036fa:	83 ec 0c             	sub    $0xc,%esp
801036fd:	50                   	push   %eax
801036fe:	e8 14 11 00 00       	call   80104817 <wakeup>
80103703:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103706:	8b 45 08             	mov    0x8(%ebp),%eax
80103709:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010370f:	85 c0                	test   %eax,%eax
80103711:	75 2c                	jne    8010373f <pipeclose+0x98>
80103713:	8b 45 08             	mov    0x8(%ebp),%eax
80103716:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010371c:	85 c0                	test   %eax,%eax
8010371e:	75 1f                	jne    8010373f <pipeclose+0x98>
    release(&p->lock);
80103720:	8b 45 08             	mov    0x8(%ebp),%eax
80103723:	83 ec 0c             	sub    $0xc,%esp
80103726:	50                   	push   %eax
80103727:	e8 c9 14 00 00       	call   80104bf5 <release>
8010372c:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010372f:	83 ec 0c             	sub    $0xc,%esp
80103732:	ff 75 08             	push   0x8(%ebp)
80103735:	e8 b4 ef ff ff       	call   801026ee <kfree>
8010373a:	83 c4 10             	add    $0x10,%esp
8010373d:	eb 10                	jmp    8010374f <pipeclose+0xa8>
  } else
    release(&p->lock);
8010373f:	8b 45 08             	mov    0x8(%ebp),%eax
80103742:	83 ec 0c             	sub    $0xc,%esp
80103745:	50                   	push   %eax
80103746:	e8 aa 14 00 00       	call   80104bf5 <release>
8010374b:	83 c4 10             	add    $0x10,%esp
}
8010374e:	90                   	nop
8010374f:	90                   	nop
80103750:	c9                   	leave  
80103751:	c3                   	ret    

80103752 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103752:	55                   	push   %ebp
80103753:	89 e5                	mov    %esp,%ebp
80103755:	53                   	push   %ebx
80103756:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103759:	8b 45 08             	mov    0x8(%ebp),%eax
8010375c:	83 ec 0c             	sub    $0xc,%esp
8010375f:	50                   	push   %eax
80103760:	e8 22 14 00 00       	call   80104b87 <acquire>
80103765:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103768:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010376f:	e9 ad 00 00 00       	jmp    80103821 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103774:	8b 45 08             	mov    0x8(%ebp),%eax
80103777:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010377d:	85 c0                	test   %eax,%eax
8010377f:	74 0c                	je     8010378d <pipewrite+0x3b>
80103781:	e8 92 02 00 00       	call   80103a18 <myproc>
80103786:	8b 40 24             	mov    0x24(%eax),%eax
80103789:	85 c0                	test   %eax,%eax
8010378b:	74 19                	je     801037a6 <pipewrite+0x54>
        release(&p->lock);
8010378d:	8b 45 08             	mov    0x8(%ebp),%eax
80103790:	83 ec 0c             	sub    $0xc,%esp
80103793:	50                   	push   %eax
80103794:	e8 5c 14 00 00       	call   80104bf5 <release>
80103799:	83 c4 10             	add    $0x10,%esp
        return -1;
8010379c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037a1:	e9 a9 00 00 00       	jmp    8010384f <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037a6:	8b 45 08             	mov    0x8(%ebp),%eax
801037a9:	05 34 02 00 00       	add    $0x234,%eax
801037ae:	83 ec 0c             	sub    $0xc,%esp
801037b1:	50                   	push   %eax
801037b2:	e8 60 10 00 00       	call   80104817 <wakeup>
801037b7:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037ba:	8b 45 08             	mov    0x8(%ebp),%eax
801037bd:	8b 55 08             	mov    0x8(%ebp),%edx
801037c0:	81 c2 38 02 00 00    	add    $0x238,%edx
801037c6:	83 ec 08             	sub    $0x8,%esp
801037c9:	50                   	push   %eax
801037ca:	52                   	push   %edx
801037cb:	e8 5d 0f 00 00       	call   8010472d <sleep>
801037d0:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037d3:	8b 45 08             	mov    0x8(%ebp),%eax
801037d6:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037dc:	8b 45 08             	mov    0x8(%ebp),%eax
801037df:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037e5:	05 00 02 00 00       	add    $0x200,%eax
801037ea:	39 c2                	cmp    %eax,%edx
801037ec:	74 86                	je     80103774 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801037ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801037f4:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801037f7:	8b 45 08             	mov    0x8(%ebp),%eax
801037fa:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103800:	8d 48 01             	lea    0x1(%eax),%ecx
80103803:	8b 55 08             	mov    0x8(%ebp),%edx
80103806:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010380c:	25 ff 01 00 00       	and    $0x1ff,%eax
80103811:	89 c1                	mov    %eax,%ecx
80103813:	0f b6 13             	movzbl (%ebx),%edx
80103816:	8b 45 08             	mov    0x8(%ebp),%eax
80103819:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010381d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103824:	3b 45 10             	cmp    0x10(%ebp),%eax
80103827:	7c aa                	jl     801037d3 <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103829:	8b 45 08             	mov    0x8(%ebp),%eax
8010382c:	05 34 02 00 00       	add    $0x234,%eax
80103831:	83 ec 0c             	sub    $0xc,%esp
80103834:	50                   	push   %eax
80103835:	e8 dd 0f 00 00       	call   80104817 <wakeup>
8010383a:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010383d:	8b 45 08             	mov    0x8(%ebp),%eax
80103840:	83 ec 0c             	sub    $0xc,%esp
80103843:	50                   	push   %eax
80103844:	e8 ac 13 00 00       	call   80104bf5 <release>
80103849:	83 c4 10             	add    $0x10,%esp
  return n;
8010384c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010384f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103852:	c9                   	leave  
80103853:	c3                   	ret    

80103854 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103854:	55                   	push   %ebp
80103855:	89 e5                	mov    %esp,%ebp
80103857:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
8010385a:	8b 45 08             	mov    0x8(%ebp),%eax
8010385d:	83 ec 0c             	sub    $0xc,%esp
80103860:	50                   	push   %eax
80103861:	e8 21 13 00 00       	call   80104b87 <acquire>
80103866:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103869:	eb 3e                	jmp    801038a9 <piperead+0x55>
    if(myproc()->killed){
8010386b:	e8 a8 01 00 00       	call   80103a18 <myproc>
80103870:	8b 40 24             	mov    0x24(%eax),%eax
80103873:	85 c0                	test   %eax,%eax
80103875:	74 19                	je     80103890 <piperead+0x3c>
      release(&p->lock);
80103877:	8b 45 08             	mov    0x8(%ebp),%eax
8010387a:	83 ec 0c             	sub    $0xc,%esp
8010387d:	50                   	push   %eax
8010387e:	e8 72 13 00 00       	call   80104bf5 <release>
80103883:	83 c4 10             	add    $0x10,%esp
      return -1;
80103886:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010388b:	e9 be 00 00 00       	jmp    8010394e <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103890:	8b 45 08             	mov    0x8(%ebp),%eax
80103893:	8b 55 08             	mov    0x8(%ebp),%edx
80103896:	81 c2 34 02 00 00    	add    $0x234,%edx
8010389c:	83 ec 08             	sub    $0x8,%esp
8010389f:	50                   	push   %eax
801038a0:	52                   	push   %edx
801038a1:	e8 87 0e 00 00       	call   8010472d <sleep>
801038a6:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038a9:	8b 45 08             	mov    0x8(%ebp),%eax
801038ac:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038b2:	8b 45 08             	mov    0x8(%ebp),%eax
801038b5:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038bb:	39 c2                	cmp    %eax,%edx
801038bd:	75 0d                	jne    801038cc <piperead+0x78>
801038bf:	8b 45 08             	mov    0x8(%ebp),%eax
801038c2:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038c8:	85 c0                	test   %eax,%eax
801038ca:	75 9f                	jne    8010386b <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038d3:	eb 48                	jmp    8010391d <piperead+0xc9>
    if(p->nread == p->nwrite)
801038d5:	8b 45 08             	mov    0x8(%ebp),%eax
801038d8:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038de:	8b 45 08             	mov    0x8(%ebp),%eax
801038e1:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038e7:	39 c2                	cmp    %eax,%edx
801038e9:	74 3c                	je     80103927 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801038eb:	8b 45 08             	mov    0x8(%ebp),%eax
801038ee:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801038f4:	8d 48 01             	lea    0x1(%eax),%ecx
801038f7:	8b 55 08             	mov    0x8(%ebp),%edx
801038fa:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103900:	25 ff 01 00 00       	and    $0x1ff,%eax
80103905:	89 c1                	mov    %eax,%ecx
80103907:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010390a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010390d:	01 c2                	add    %eax,%edx
8010390f:	8b 45 08             	mov    0x8(%ebp),%eax
80103912:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103917:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103919:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010391d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103920:	3b 45 10             	cmp    0x10(%ebp),%eax
80103923:	7c b0                	jl     801038d5 <piperead+0x81>
80103925:	eb 01                	jmp    80103928 <piperead+0xd4>
      break;
80103927:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103928:	8b 45 08             	mov    0x8(%ebp),%eax
8010392b:	05 38 02 00 00       	add    $0x238,%eax
80103930:	83 ec 0c             	sub    $0xc,%esp
80103933:	50                   	push   %eax
80103934:	e8 de 0e 00 00       	call   80104817 <wakeup>
80103939:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010393c:	8b 45 08             	mov    0x8(%ebp),%eax
8010393f:	83 ec 0c             	sub    $0xc,%esp
80103942:	50                   	push   %eax
80103943:	e8 ad 12 00 00       	call   80104bf5 <release>
80103948:	83 c4 10             	add    $0x10,%esp
  return i;
8010394b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010394e:	c9                   	leave  
8010394f:	c3                   	ret    

80103950 <readeflags>:
{
80103950:	55                   	push   %ebp
80103951:	89 e5                	mov    %esp,%ebp
80103953:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103956:	9c                   	pushf  
80103957:	58                   	pop    %eax
80103958:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010395b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010395e:	c9                   	leave  
8010395f:	c3                   	ret    

80103960 <sti>:
{
80103960:	55                   	push   %ebp
80103961:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103963:	fb                   	sti    
}
80103964:	90                   	nop
80103965:	5d                   	pop    %ebp
80103966:	c3                   	ret    

80103967 <pinit>:
extern void trapret(void);

static void wakeup1(void *chan);

void pinit(void)
{
80103967:	55                   	push   %ebp
80103968:	89 e5                	mov    %esp,%ebp
8010396a:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010396d:	83 ec 08             	sub    $0x8,%esp
80103970:	68 50 ab 10 80       	push   $0x8010ab50
80103975:	68 00 bb 30 80       	push   $0x8030bb00
8010397a:	e8 e6 11 00 00       	call   80104b65 <initlock>
8010397f:	83 c4 10             	add    $0x10,%esp
}
80103982:	90                   	nop
80103983:	c9                   	leave  
80103984:	c3                   	ret    

80103985 <cpuid>:

// Must be called with interrupts disabled
int cpuid()
{
80103985:	55                   	push   %ebp
80103986:	89 e5                	mov    %esp,%ebp
80103988:	83 ec 08             	sub    $0x8,%esp
  return mycpu() - cpus;
8010398b:	e8 10 00 00 00       	call   801039a0 <mycpu>
80103990:	2d 80 e4 30 80       	sub    $0x8030e480,%eax
80103995:	c1 f8 02             	sar    $0x2,%eax
80103998:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
}
8010399e:	c9                   	leave  
8010399f:	c3                   	ret    

801039a0 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu *
mycpu(void)
{
801039a0:	55                   	push   %ebp
801039a1:	89 e5                	mov    %esp,%ebp
801039a3:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;

  if (readeflags() & FL_IF)
801039a6:	e8 a5 ff ff ff       	call   80103950 <readeflags>
801039ab:	25 00 02 00 00       	and    $0x200,%eax
801039b0:	85 c0                	test   %eax,%eax
801039b2:	74 0d                	je     801039c1 <mycpu+0x21>
  {
    panic("mycpu called with interrupts enabled\n");
801039b4:	83 ec 0c             	sub    $0xc,%esp
801039b7:	68 58 ab 10 80       	push   $0x8010ab58
801039bc:	e8 e8 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039c1:	e8 1c f1 ff ff       	call   80102ae2 <lapicid>
801039c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i)
801039c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039d0:	eb 2d                	jmp    801039ff <mycpu+0x5f>
  {
    if (cpus[i].apicid == apicid)
801039d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d5:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801039db:	05 80 e4 30 80       	add    $0x8030e480,%eax
801039e0:	0f b6 00             	movzbl (%eax),%eax
801039e3:	0f b6 c0             	movzbl %al,%eax
801039e6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801039e9:	75 10                	jne    801039fb <mycpu+0x5b>
    {
      return &cpus[i];
801039eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ee:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801039f4:	05 80 e4 30 80       	add    $0x8030e480,%eax
801039f9:	eb 1b                	jmp    80103a16 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i)
801039fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039ff:	a1 50 e7 30 80       	mov    0x8030e750,%eax
80103a04:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a07:	7c c9                	jl     801039d2 <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a09:	83 ec 0c             	sub    $0xc,%esp
80103a0c:	68 7e ab 10 80       	push   $0x8010ab7e
80103a11:	e8 93 cb ff ff       	call   801005a9 <panic>
}
80103a16:	c9                   	leave  
80103a17:	c3                   	ret    

80103a18 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc *
myproc(void)
{
80103a18:	55                   	push   %ebp
80103a19:	89 e5                	mov    %esp,%ebp
80103a1b:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a1e:	e8 cf 12 00 00       	call   80104cf2 <pushcli>
  c = mycpu();
80103a23:	e8 78 ff ff ff       	call   801039a0 <mycpu>
80103a28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a2e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a37:	e8 03 13 00 00       	call   80104d3f <popcli>
  return p;
80103a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a3f:	c9                   	leave  
80103a40:	c3                   	ret    

80103a41 <allocproc>:
//  If found, change state to EMBRYO and initialize
//  state required to run in the kernel.
//  Otherwise return 0.
static struct proc *
allocproc(void)
{
80103a41:	55                   	push   %ebp
80103a42:	89 e5                	mov    %esp,%ebp
80103a44:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a47:	83 ec 0c             	sub    $0xc,%esp
80103a4a:	68 00 bb 30 80       	push   $0x8030bb00
80103a4f:	e8 33 11 00 00       	call   80104b87 <acquire>
80103a54:	83 c4 10             	add    $0x10,%esp

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a57:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
80103a5e:	eb 11                	jmp    80103a71 <allocproc+0x30>
    if (p->state == UNUSED)
80103a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a63:	8b 40 0c             	mov    0xc(%eax),%eax
80103a66:	85 c0                	test   %eax,%eax
80103a68:	74 2a                	je     80103a94 <allocproc+0x53>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6a:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80103a71:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
80103a78:	72 e6                	jb     80103a60 <allocproc+0x1f>
    {
      goto found;
    }

  release(&ptable.lock);
80103a7a:	83 ec 0c             	sub    $0xc,%esp
80103a7d:	68 00 bb 30 80       	push   $0x8030bb00
80103a82:	e8 6e 11 00 00       	call   80104bf5 <release>
80103a87:	83 c4 10             	add    $0x10,%esp
  return 0;
80103a8a:	b8 00 00 00 00       	mov    $0x0,%eax
80103a8f:	e9 0a 01 00 00       	jmp    80103b9e <allocproc+0x15d>
      goto found;
80103a94:	90                   	nop

found:
  p->state = EMBRYO;
80103a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a98:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103a9f:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103aa4:	8d 50 01             	lea    0x1(%eax),%edx
80103aa7:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103aad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ab0:	89 42 10             	mov    %eax,0x10(%edx)

  int idx = p - ptable.proc; // 해당 프로세스의 인덱스 계산
80103ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab6:	2d 34 bb 30 80       	sub    $0x8030bb34,%eax
80103abb:	c1 f8 02             	sar    $0x2,%eax
80103abe:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
80103ac4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // MLFQ 전역 배열 초기화
  proc_priority[idx] = 3; // Q3가 가장 높은 우선순위
80103ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aca:	c7 04 85 00 b2 30 80 	movl   $0x3,-0x7fcf4e00(,%eax,4)
80103ad1:	03 00 00 00 
  memset(proc_ticks[idx], 0, sizeof(proc_ticks[idx]));
80103ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ad8:	c1 e0 04             	shl    $0x4,%eax
80103adb:	05 00 b3 30 80       	add    $0x8030b300,%eax
80103ae0:	83 ec 04             	sub    $0x4,%esp
80103ae3:	6a 10                	push   $0x10
80103ae5:	6a 00                	push   $0x0
80103ae7:	50                   	push   %eax
80103ae8:	e8 10 13 00 00       	call   80104dfd <memset>
80103aed:	83 c4 10             	add    $0x10,%esp
  memset(proc_wait_ticks[idx], 0, sizeof(proc_wait_ticks[idx]));
80103af0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103af3:	c1 e0 04             	shl    $0x4,%eax
80103af6:	05 00 b7 30 80       	add    $0x8030b700,%eax
80103afb:	83 ec 04             	sub    $0x4,%esp
80103afe:	6a 10                	push   $0x10
80103b00:	6a 00                	push   $0x0
80103b02:	50                   	push   %eax
80103b03:	e8 f5 12 00 00       	call   80104dfd <memset>
80103b08:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103b0b:	83 ec 0c             	sub    $0xc,%esp
80103b0e:	68 00 bb 30 80       	push   $0x8030bb00
80103b13:	e8 dd 10 00 00       	call   80104bf5 <release>
80103b18:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if ((p->kstack = kalloc()) == 0)
80103b1b:	e8 68 ec ff ff       	call   80102788 <kalloc>
80103b20:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b23:	89 42 08             	mov    %eax,0x8(%edx)
80103b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b29:	8b 40 08             	mov    0x8(%eax),%eax
80103b2c:	85 c0                	test   %eax,%eax
80103b2e:	75 11                	jne    80103b41 <allocproc+0x100>
  {
    p->state = UNUSED;
80103b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b33:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103b3a:	b8 00 00 00 00       	mov    $0x0,%eax
80103b3f:	eb 5d                	jmp    80103b9e <allocproc+0x15d>
  }
  sp = p->kstack + KSTACKSIZE;
80103b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b44:	8b 40 08             	mov    0x8(%eax),%eax
80103b47:	05 00 10 00 00       	add    $0x1000,%eax
80103b4c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b4f:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe *)sp;
80103b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b56:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b59:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b5c:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint *)sp = (uint)trapret;
80103b60:	ba e2 64 10 80       	mov    $0x801064e2,%edx
80103b65:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b68:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b6a:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context *)sp;
80103b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b71:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b74:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7a:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b7d:	83 ec 04             	sub    $0x4,%esp
80103b80:	6a 14                	push   $0x14
80103b82:	6a 00                	push   $0x0
80103b84:	50                   	push   %eax
80103b85:	e8 73 12 00 00       	call   80104dfd <memset>
80103b8a:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b90:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b93:	ba e7 46 10 80       	mov    $0x801046e7,%edx
80103b98:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b9e:	c9                   	leave  
80103b9f:	c3                   	ret    

80103ba0 <userinit>:

// PAGEBREAK: 32
//  Set up first user process.
void userinit(void)
{
80103ba0:	55                   	push   %ebp
80103ba1:	89 e5                	mov    %esp,%ebp
80103ba3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103ba6:	e8 96 fe ff ff       	call   80103a41 <allocproc>
80103bab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  initproc = p;
80103bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb1:	a3 34 dc 30 80       	mov    %eax,0x8030dc34
  if ((p->pgdir = setupkvm()) == 0)
80103bb6:	e8 05 40 00 00       	call   80107bc0 <setupkvm>
80103bbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bbe:	89 42 04             	mov    %eax,0x4(%edx)
80103bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc4:	8b 40 04             	mov    0x4(%eax),%eax
80103bc7:	85 c0                	test   %eax,%eax
80103bc9:	75 0d                	jne    80103bd8 <userinit+0x38>
  {
    panic("userinit: out of memory?");
80103bcb:	83 ec 0c             	sub    $0xc,%esp
80103bce:	68 8e ab 10 80       	push   $0x8010ab8e
80103bd3:	e8 d1 c9 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103bd8:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be0:	8b 40 04             	mov    0x4(%eax),%eax
80103be3:	83 ec 04             	sub    $0x4,%esp
80103be6:	52                   	push   %edx
80103be7:	68 0c f5 10 80       	push   $0x8010f50c
80103bec:	50                   	push   %eax
80103bed:	e8 8a 42 00 00       	call   80107e7c <inituvm>
80103bf2:	83 c4 10             	add    $0x10,%esp

  p->sz = PGSIZE;
80103bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf8:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  if (p->sz > USERSTACKTOP - PGSIZE)
80103bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c01:	8b 00                	mov    (%eax),%eax
80103c03:	3d 00 70 ff 7f       	cmp    $0x7fff7000,%eax
80103c08:	76 0d                	jbe    80103c17 <userinit+0x77>
    panic("userinit: stack/heap overlap");
80103c0a:	83 ec 0c             	sub    $0xc,%esp
80103c0d:	68 a7 ab 10 80       	push   $0x8010aba7
80103c12:	e8 92 c9 ff ff       	call   801005a9 <panic>

  cprintf("sz: %x, USERSTACKTOP-PGSIZE: %x, USERSTACKTOP: %x\n", p->sz, USERSTACKTOP-PGSIZE, USERSTACKTOP);
80103c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1a:	8b 00                	mov    (%eax),%eax
80103c1c:	68 00 80 ff 7f       	push   $0x7fff8000
80103c21:	68 00 70 ff 7f       	push   $0x7fff7000
80103c26:	50                   	push   %eax
80103c27:	68 c4 ab 10 80       	push   $0x8010abc4
80103c2c:	e8 c3 c7 ff ff       	call   801003f4 <cprintf>
80103c31:	83 c4 10             	add    $0x10,%esp


  if(allocuvm(p->pgdir, USERSTACKTOP - 2*PGSIZE, USERSTACKTOP) == 0)
80103c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c37:	8b 40 04             	mov    0x4(%eax),%eax
80103c3a:	83 ec 04             	sub    $0x4,%esp
80103c3d:	68 00 80 ff 7f       	push   $0x7fff8000
80103c42:	68 00 60 ff 7f       	push   $0x7fff6000
80103c47:	50                   	push   %eax
80103c48:	e8 6c 43 00 00       	call   80107fb9 <allocuvm>
80103c4d:	83 c4 10             	add    $0x10,%esp
80103c50:	85 c0                	test   %eax,%eax
80103c52:	75 0d                	jne    80103c61 <userinit+0xc1>
    panic("userinit: allocuvm fail");
80103c54:	83 ec 0c             	sub    $0xc,%esp
80103c57:	68 f7 ab 10 80       	push   $0x8010abf7
80103c5c:	e8 48 c9 ff ff       	call   801005a9 <panic>
  
  memset(p->tf, 0, sizeof(*p->tf));
80103c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c64:	8b 40 18             	mov    0x18(%eax),%eax
80103c67:	83 ec 04             	sub    $0x4,%esp
80103c6a:	6a 4c                	push   $0x4c
80103c6c:	6a 00                	push   $0x0
80103c6e:	50                   	push   %eax
80103c6f:	e8 89 11 00 00       	call   80104dfd <memset>
80103c74:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7a:	8b 40 18             	mov    0x18(%eax),%eax
80103c7d:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c86:	8b 40 18             	mov    0x18(%eax),%eax
80103c89:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c92:	8b 50 18             	mov    0x18(%eax),%edx
80103c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c98:	8b 40 18             	mov    0x18(%eax),%eax
80103c9b:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c9f:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca6:	8b 50 18             	mov    0x18(%eax),%edx
80103ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cac:	8b 40 18             	mov    0x18(%eax),%eax
80103caf:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103cb3:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cba:	8b 40 18             	mov    0x18(%eax),%eax
80103cbd:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = USERSTACKTOP - 4;
80103cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc7:	8b 40 18             	mov    0x18(%eax),%eax
80103cca:	c7 40 44 fc 7f ff 7f 	movl   $0x7fff7ffc,0x44(%eax)
  //p->tf->esp = PGSIZE;

  p->tf->eip = 0; // beginning of initcode.S
80103cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd4:	8b 40 18             	mov    0x18(%eax),%eax
80103cd7:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  cprintf("initcode size: %d\n", (int)_binary_initcode_size);
80103cde:	b8 2c 00 00 00       	mov    $0x2c,%eax
80103ce3:	83 ec 08             	sub    $0x8,%esp
80103ce6:	50                   	push   %eax
80103ce7:	68 0f ac 10 80       	push   $0x8010ac0f
80103cec:	e8 03 c7 ff ff       	call   801003f4 <cprintf>
80103cf1:	83 c4 10             	add    $0x10,%esp

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf7:	83 c0 6c             	add    $0x6c,%eax
80103cfa:	83 ec 04             	sub    $0x4,%esp
80103cfd:	6a 10                	push   $0x10
80103cff:	68 22 ac 10 80       	push   $0x8010ac22
80103d04:	50                   	push   %eax
80103d05:	e8 f6 12 00 00       	call   80105000 <safestrcpy>
80103d0a:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103d0d:	83 ec 0c             	sub    $0xc,%esp
80103d10:	68 2b ac 10 80       	push   $0x8010ac2b
80103d15:	e8 eb e7 ff ff       	call   80102505 <namei>
80103d1a:	83 c4 10             	add    $0x10,%esp
80103d1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d20:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103d23:	83 ec 0c             	sub    $0xc,%esp
80103d26:	68 00 bb 30 80       	push   $0x8030bb00
80103d2b:	e8 57 0e 00 00       	call   80104b87 <acquire>
80103d30:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d36:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103d3d:	83 ec 0c             	sub    $0xc,%esp
80103d40:	68 00 bb 30 80       	push   $0x8030bb00
80103d45:	e8 ab 0e 00 00       	call   80104bf5 <release>
80103d4a:	83 c4 10             	add    $0x10,%esp

  cprintf("userinit: eip=%x esp=%x sz=%x\n", p->tf->eip, p->tf->esp, p->sz);
80103d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d50:	8b 08                	mov    (%eax),%ecx
80103d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d55:	8b 40 18             	mov    0x18(%eax),%eax
80103d58:	8b 50 44             	mov    0x44(%eax),%edx
80103d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d5e:	8b 40 18             	mov    0x18(%eax),%eax
80103d61:	8b 40 38             	mov    0x38(%eax),%eax
80103d64:	51                   	push   %ecx
80103d65:	52                   	push   %edx
80103d66:	50                   	push   %eax
80103d67:	68 30 ac 10 80       	push   $0x8010ac30
80103d6c:	e8 83 c6 ff ff       	call   801003f4 <cprintf>
80103d71:	83 c4 10             	add    $0x10,%esp

}
80103d74:	90                   	nop
80103d75:	c9                   	leave  
80103d76:	c3                   	ret    

80103d77 <growproc>:
//   return 0;
// }

int
growproc(int n)
{
80103d77:	55                   	push   %ebp
80103d78:	89 e5                	mov    %esp,%ebp
80103d7a:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103d7d:	e8 96 fc ff ff       	call   80103a18 <myproc>
80103d82:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103d85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d88:	8b 00                	mov    (%eax),%eax
80103d8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (n > 0) {
80103d8d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d91:	7e 08                	jle    80103d9b <growproc+0x24>
    sz = sz + n;    // sz만 증가
80103d93:	8b 45 08             	mov    0x8(%ebp),%eax
80103d96:	01 45 f4             	add    %eax,-0xc(%ebp)
80103d99:	eb 34                	jmp    80103dcf <growproc+0x58>
  } else if (n < 0) {
80103d9b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d9f:	79 2e                	jns    80103dcf <growproc+0x58>
    sz = deallocuvm(curproc->pgdir, sz, sz + n);
80103da1:	8b 55 08             	mov    0x8(%ebp),%edx
80103da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da7:	01 c2                	add    %eax,%edx
80103da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dac:	8b 40 04             	mov    0x4(%eax),%eax
80103daf:	83 ec 04             	sub    $0x4,%esp
80103db2:	52                   	push   %edx
80103db3:	ff 75 f4             	push   -0xc(%ebp)
80103db6:	50                   	push   %eax
80103db7:	e8 02 43 00 00       	call   801080be <deallocuvm>
80103dbc:	83 c4 10             	add    $0x10,%esp
80103dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (sz == 0)
80103dc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103dc6:	75 07                	jne    80103dcf <growproc+0x58>
      return -1;
80103dc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dcd:	eb 1b                	jmp    80103dea <growproc+0x73>
  }
  curproc->sz = sz;
80103dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103dd5:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103dd7:	83 ec 0c             	sub    $0xc,%esp
80103dda:	ff 75 f0             	push   -0x10(%ebp)
80103ddd:	e8 fb 3e 00 00       	call   80107cdd <switchuvm>
80103de2:	83 c4 10             	add    $0x10,%esp
  return 0;
80103de5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103dea:	c9                   	leave  
80103deb:	c3                   	ret    

80103dec <fork>:

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int fork(void)
{
80103dec:	55                   	push   %ebp
80103ded:	89 e5                	mov    %esp,%ebp
80103def:	57                   	push   %edi
80103df0:	56                   	push   %esi
80103df1:	53                   	push   %ebx
80103df2:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103df5:	e8 1e fc ff ff       	call   80103a18 <myproc>
80103dfa:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if ((np = allocproc()) == 0)
80103dfd:	e8 3f fc ff ff       	call   80103a41 <allocproc>
80103e02:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103e05:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103e09:	75 0a                	jne    80103e15 <fork+0x29>
  {
    return -1;
80103e0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e10:	e9 48 01 00 00       	jmp    80103f5d <fork+0x171>
  }

  // Copy process state from proc.
  if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0)
80103e15:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e18:	8b 10                	mov    (%eax),%edx
80103e1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e1d:	8b 40 04             	mov    0x4(%eax),%eax
80103e20:	83 ec 08             	sub    $0x8,%esp
80103e23:	52                   	push   %edx
80103e24:	50                   	push   %eax
80103e25:	e8 32 44 00 00       	call   8010825c <copyuvm>
80103e2a:	83 c4 10             	add    $0x10,%esp
80103e2d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e30:	89 42 04             	mov    %eax,0x4(%edx)
80103e33:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e36:	8b 40 04             	mov    0x4(%eax),%eax
80103e39:	85 c0                	test   %eax,%eax
80103e3b:	75 30                	jne    80103e6d <fork+0x81>
  {
    kfree(np->kstack);
80103e3d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e40:	8b 40 08             	mov    0x8(%eax),%eax
80103e43:	83 ec 0c             	sub    $0xc,%esp
80103e46:	50                   	push   %eax
80103e47:	e8 a2 e8 ff ff       	call   801026ee <kfree>
80103e4c:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103e4f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e52:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103e59:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e5c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103e63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e68:	e9 f0 00 00 00       	jmp    80103f5d <fork+0x171>
  }
  np->sz = curproc->sz;
80103e6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e70:	8b 10                	mov    (%eax),%edx
80103e72:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e75:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103e77:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e7a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103e7d:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103e80:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e83:	8b 48 18             	mov    0x18(%eax),%ecx
80103e86:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e89:	8b 40 18             	mov    0x18(%eax),%eax
80103e8c:	89 c2                	mov    %eax,%edx
80103e8e:	89 cb                	mov    %ecx,%ebx
80103e90:	b8 13 00 00 00       	mov    $0x13,%eax
80103e95:	89 d7                	mov    %edx,%edi
80103e97:	89 de                	mov    %ebx,%esi
80103e99:	89 c1                	mov    %eax,%ecx
80103e9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103e9d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ea0:	8b 40 18             	mov    0x18(%eax),%eax
80103ea3:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for (i = 0; i < NOFILE; i++)
80103eaa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103eb1:	eb 3b                	jmp    80103eee <fork+0x102>
    if (curproc->ofile[i])
80103eb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103eb6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103eb9:	83 c2 08             	add    $0x8,%edx
80103ebc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ec0:	85 c0                	test   %eax,%eax
80103ec2:	74 26                	je     80103eea <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103ec4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ec7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103eca:	83 c2 08             	add    $0x8,%edx
80103ecd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ed1:	83 ec 0c             	sub    $0xc,%esp
80103ed4:	50                   	push   %eax
80103ed5:	e8 58 d1 ff ff       	call   80101032 <filedup>
80103eda:	83 c4 10             	add    $0x10,%esp
80103edd:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103ee0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103ee3:	83 c1 08             	add    $0x8,%ecx
80103ee6:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for (i = 0; i < NOFILE; i++)
80103eea:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103eee:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103ef2:	7e bf                	jle    80103eb3 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103ef4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ef7:	8b 40 68             	mov    0x68(%eax),%eax
80103efa:	83 ec 0c             	sub    $0xc,%esp
80103efd:	50                   	push   %eax
80103efe:	e8 95 da ff ff       	call   80101998 <idup>
80103f03:	83 c4 10             	add    $0x10,%esp
80103f06:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f09:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103f0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f0f:	8d 50 6c             	lea    0x6c(%eax),%edx
80103f12:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f15:	83 c0 6c             	add    $0x6c,%eax
80103f18:	83 ec 04             	sub    $0x4,%esp
80103f1b:	6a 10                	push   $0x10
80103f1d:	52                   	push   %edx
80103f1e:	50                   	push   %eax
80103f1f:	e8 dc 10 00 00       	call   80105000 <safestrcpy>
80103f24:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103f27:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f2a:	8b 40 10             	mov    0x10(%eax),%eax
80103f2d:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103f30:	83 ec 0c             	sub    $0xc,%esp
80103f33:	68 00 bb 30 80       	push   $0x8030bb00
80103f38:	e8 4a 0c 00 00       	call   80104b87 <acquire>
80103f3d:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103f40:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f43:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103f4a:	83 ec 0c             	sub    $0xc,%esp
80103f4d:	68 00 bb 30 80       	push   $0x8030bb00
80103f52:	e8 9e 0c 00 00       	call   80104bf5 <release>
80103f57:	83 c4 10             	add    $0x10,%esp

  return pid;
80103f5a:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103f5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103f60:	5b                   	pop    %ebx
80103f61:	5e                   	pop    %esi
80103f62:	5f                   	pop    %edi
80103f63:	5d                   	pop    %ebp
80103f64:	c3                   	ret    

80103f65 <exit>:
//이거이거 살짝
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void exit(void)
{
80103f65:	55                   	push   %ebp
80103f66:	89 e5                	mov    %esp,%ebp
80103f68:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103f6b:	e8 a8 fa ff ff       	call   80103a18 <myproc>
80103f70:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if (curproc == initproc)
80103f73:	a1 34 dc 30 80       	mov    0x8030dc34,%eax
80103f78:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f7b:	75 0d                	jne    80103f8a <exit+0x25>
    panic("init exiting");
80103f7d:	83 ec 0c             	sub    $0xc,%esp
80103f80:	68 4f ac 10 80       	push   $0x8010ac4f
80103f85:	e8 1f c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for (fd = 0; fd < NOFILE; fd++)
80103f8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103f91:	eb 3f                	jmp    80103fd2 <exit+0x6d>
  {
    if (curproc->ofile[fd])
80103f93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f96:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f99:	83 c2 08             	add    $0x8,%edx
80103f9c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fa0:	85 c0                	test   %eax,%eax
80103fa2:	74 2a                	je     80103fce <exit+0x69>
    {
      fileclose(curproc->ofile[fd]);
80103fa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fa7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103faa:	83 c2 08             	add    $0x8,%edx
80103fad:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fb1:	83 ec 0c             	sub    $0xc,%esp
80103fb4:	50                   	push   %eax
80103fb5:	e8 c9 d0 ff ff       	call   80101083 <fileclose>
80103fba:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103fbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fc0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103fc3:	83 c2 08             	add    $0x8,%edx
80103fc6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103fcd:	00 
  for (fd = 0; fd < NOFILE; fd++)
80103fce:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103fd2:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103fd6:	7e bb                	jle    80103f93 <exit+0x2e>
    }
  }

  begin_op();
80103fd8:	e8 47 f0 ff ff       	call   80103024 <begin_op>
  iput(curproc->cwd);
80103fdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fe0:	8b 40 68             	mov    0x68(%eax),%eax
80103fe3:	83 ec 0c             	sub    $0xc,%esp
80103fe6:	50                   	push   %eax
80103fe7:	e8 47 db ff ff       	call   80101b33 <iput>
80103fec:	83 c4 10             	add    $0x10,%esp
  end_op();
80103fef:	e8 bc f0 ff ff       	call   801030b0 <end_op>
  curproc->cwd = 0;
80103ff4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ff7:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103ffe:	83 ec 0c             	sub    $0xc,%esp
80104001:	68 00 bb 30 80       	push   $0x8030bb00
80104006:	e8 7c 0b 00 00       	call   80104b87 <acquire>
8010400b:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010400e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104011:	8b 40 14             	mov    0x14(%eax),%eax
80104014:	83 ec 0c             	sub    $0xc,%esp
80104017:	50                   	push   %eax
80104018:	e8 b7 07 00 00       	call   801047d4 <wakeup1>
8010401d:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104020:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
80104027:	eb 3a                	jmp    80104063 <exit+0xfe>
  {
    if (p->parent == curproc)
80104029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402c:	8b 40 14             	mov    0x14(%eax),%eax
8010402f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104032:	75 28                	jne    8010405c <exit+0xf7>
    {
      p->parent = initproc;
80104034:	8b 15 34 dc 30 80    	mov    0x8030dc34,%edx
8010403a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403d:	89 50 14             	mov    %edx,0x14(%eax)
      if (p->state == ZOMBIE)
80104040:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104043:	8b 40 0c             	mov    0xc(%eax),%eax
80104046:	83 f8 05             	cmp    $0x5,%eax
80104049:	75 11                	jne    8010405c <exit+0xf7>
        wakeup1(initproc);
8010404b:	a1 34 dc 30 80       	mov    0x8030dc34,%eax
80104050:	83 ec 0c             	sub    $0xc,%esp
80104053:	50                   	push   %eax
80104054:	e8 7b 07 00 00       	call   801047d4 <wakeup1>
80104059:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010405c:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104063:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
8010406a:	72 bd                	jb     80104029 <exit+0xc4>
    }
  }

  int idx = myproc() - ptable.proc;
8010406c:	e8 a7 f9 ff ff       	call   80103a18 <myproc>
80104071:	2d 34 bb 30 80       	sub    $0x8030bb34,%eax
80104076:	c1 f8 02             	sar    $0x2,%eax
80104079:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
8010407f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  proc_ticks[idx][proc_priority[idx]]++;
80104082:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104085:	8b 0c 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%ecx
8010408c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010408f:	c1 e0 02             	shl    $0x2,%eax
80104092:	01 c8                	add    %ecx,%eax
80104094:	8b 04 85 00 b3 30 80 	mov    -0x7fcf4d00(,%eax,4),%eax
8010409b:	8d 50 01             	lea    0x1(%eax),%edx
8010409e:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040a1:	c1 e0 02             	shl    $0x2,%eax
801040a4:	01 c8                	add    %ecx,%eax
801040a6:	89 14 85 00 b3 30 80 	mov    %edx,-0x7fcf4d00(,%eax,4)

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801040ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040b0:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801040b7:	e8 f7 04 00 00       	call   801045b3 <sched>
  panic("zombie exit");
801040bc:	83 ec 0c             	sub    $0xc,%esp
801040bf:	68 5c ac 10 80       	push   $0x8010ac5c
801040c4:	e8 e0 c4 ff ff       	call   801005a9 <panic>

801040c9 <wait>:
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int wait(void)
{
801040c9:	55                   	push   %ebp
801040ca:	89 e5                	mov    %esp,%ebp
801040cc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801040cf:	e8 44 f9 ff ff       	call   80103a18 <myproc>
801040d4:	89 45 ec             	mov    %eax,-0x14(%ebp)

  acquire(&ptable.lock);
801040d7:	83 ec 0c             	sub    $0xc,%esp
801040da:	68 00 bb 30 80       	push   $0x8030bb00
801040df:	e8 a3 0a 00 00       	call   80104b87 <acquire>
801040e4:	83 c4 10             	add    $0x10,%esp
  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
801040e7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801040ee:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
801040f5:	e9 a4 00 00 00       	jmp    8010419e <wait+0xd5>
    {
      if (p->parent != curproc)
801040fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040fd:	8b 40 14             	mov    0x14(%eax),%eax
80104100:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104103:	0f 85 8d 00 00 00    	jne    80104196 <wait+0xcd>
        continue;
      havekids = 1;
80104109:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if (p->state == ZOMBIE)
80104110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104113:	8b 40 0c             	mov    0xc(%eax),%eax
80104116:	83 f8 05             	cmp    $0x5,%eax
80104119:	75 7c                	jne    80104197 <wait+0xce>
      {
        // Found one.
        pid = p->pid;
8010411b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411e:	8b 40 10             	mov    0x10(%eax),%eax
80104121:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104124:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104127:	8b 40 08             	mov    0x8(%eax),%eax
8010412a:	83 ec 0c             	sub    $0xc,%esp
8010412d:	50                   	push   %eax
8010412e:	e8 bb e5 ff ff       	call   801026ee <kfree>
80104133:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104139:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104143:	8b 40 04             	mov    0x4(%eax),%eax
80104146:	83 ec 0c             	sub    $0xc,%esp
80104149:	50                   	push   %eax
8010414a:	e8 33 40 00 00       	call   80108182 <freevm>
8010414f:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104155:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010415c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104166:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104169:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010416d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104170:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104181:	83 ec 0c             	sub    $0xc,%esp
80104184:	68 00 bb 30 80       	push   $0x8030bb00
80104189:	e8 67 0a 00 00       	call   80104bf5 <release>
8010418e:	83 c4 10             	add    $0x10,%esp
        return pid;
80104191:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104194:	eb 54                	jmp    801041ea <wait+0x121>
        continue;
80104196:	90                   	nop
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104197:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010419e:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
801041a5:	0f 82 4f ff ff ff    	jb     801040fa <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if (!havekids || curproc->killed)
801041ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801041af:	74 0a                	je     801041bb <wait+0xf2>
801041b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041b4:	8b 40 24             	mov    0x24(%eax),%eax
801041b7:	85 c0                	test   %eax,%eax
801041b9:	74 17                	je     801041d2 <wait+0x109>
    {
      release(&ptable.lock);
801041bb:	83 ec 0c             	sub    $0xc,%esp
801041be:	68 00 bb 30 80       	push   $0x8030bb00
801041c3:	e8 2d 0a 00 00       	call   80104bf5 <release>
801041c8:	83 c4 10             	add    $0x10,%esp
      return -1;
801041cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041d0:	eb 18                	jmp    801041ea <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock); // DOC: wait-sleep
801041d2:	83 ec 08             	sub    $0x8,%esp
801041d5:	68 00 bb 30 80       	push   $0x8030bb00
801041da:	ff 75 ec             	push   -0x14(%ebp)
801041dd:	e8 4b 05 00 00       	call   8010472d <sleep>
801041e2:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801041e5:	e9 fd fe ff ff       	jmp    801040e7 <wait+0x1e>
  }
}
801041ea:	c9                   	leave  
801041eb:	c3                   	ret    

801041ec <scheduler>:
//   - choose a process to run
//   - swtch to start running that process
//   - eventually that process transfers control
//       via swtch back to the scheduler.
void scheduler(void)
{
801041ec:	55                   	push   %ebp
801041ed:	89 e5                	mov    %esp,%ebp
801041ef:	83 ec 58             	sub    $0x58,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801041f2:	e8 a9 f7 ff ff       	call   801039a0 <mycpu>
801041f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  c->proc = 0;
801041fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041fd:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104204:	00 00 00 

  for (;;) {
    sti(); // Enable interrupts
80104207:	e8 54 f7 ff ff       	call   80103960 <sti>
    
    acquire(&ptable.lock);
8010420c:	83 ec 0c             	sub    $0xc,%esp
8010420f:	68 00 bb 30 80       	push   $0x8030bb00
80104214:	e8 6e 09 00 00       	call   80104b87 <acquire>
80104219:	83 c4 10             	add    $0x10,%esp

    int policy = c->sched_policy;
8010421c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010421f:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104225:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    struct proc *chosen = 0;
80104228:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

    if (policy == 0) {
8010422f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104233:	75 7b                	jne    801042b0 <scheduler+0xc4>
      // Round-robin scheduling
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104235:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
8010423c:	eb 64                	jmp    801042a2 <scheduler+0xb6>
        if (p->state != RUNNABLE)
8010423e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104241:	8b 40 0c             	mov    0xc(%eax),%eax
80104244:	83 f8 03             	cmp    $0x3,%eax
80104247:	75 51                	jne    8010429a <scheduler+0xae>
          continue;

        c->proc = p;
80104249:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010424c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010424f:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
80104255:	83 ec 0c             	sub    $0xc,%esp
80104258:	ff 75 f4             	push   -0xc(%ebp)
8010425b:	e8 7d 3a 00 00       	call   80107cdd <switchuvm>
80104260:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
80104263:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104266:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
8010426d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104270:	8b 40 1c             	mov    0x1c(%eax),%eax
80104273:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104276:	83 c2 04             	add    $0x4,%edx
80104279:	83 ec 08             	sub    $0x8,%esp
8010427c:	50                   	push   %eax
8010427d:	52                   	push   %edx
8010427e:	e8 ef 0d 00 00       	call   80105072 <swtch>
80104283:	83 c4 10             	add    $0x10,%esp
        switchkvm();
80104286:	e8 39 3a 00 00       	call   80107cc4 <switchkvm>

        c->proc = 0;
8010428b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010428e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104295:	00 00 00 
80104298:	eb 01                	jmp    8010429b <scheduler+0xaf>
          continue;
8010429a:	90                   	nop
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010429b:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801042a2:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
801042a9:	72 93                	jb     8010423e <scheduler+0x52>
801042ab:	e9 ee 02 00 00       	jmp    8010459e <scheduler+0x3b2>
      }
    } else {
      // MLFQ scheduling
      int level;
      for (level = 3; level >= 0; level--) {
801042b0:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)
801042b7:	eb 53                	jmp    8010430c <scheduler+0x120>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801042b9:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
801042c0:	eb 3d                	jmp    801042ff <scheduler+0x113>
          int idx = p - ptable.proc;
801042c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c5:	2d 34 bb 30 80       	sub    $0x8030bb34,%eax
801042ca:	c1 f8 02             	sar    $0x2,%eax
801042cd:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
801042d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
          if (p->state == RUNNABLE && proc_priority[idx] == level) {
801042d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d9:	8b 40 0c             	mov    0xc(%eax),%eax
801042dc:	83 f8 03             	cmp    $0x3,%eax
801042df:	75 17                	jne    801042f8 <scheduler+0x10c>
801042e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042e4:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
801042eb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801042ee:	75 08                	jne    801042f8 <scheduler+0x10c>
            chosen = p;
801042f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
            goto found;
801042f6:	eb 1b                	jmp    80104313 <scheduler+0x127>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801042f8:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801042ff:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
80104306:	72 ba                	jb     801042c2 <scheduler+0xd6>
      for (level = 3; level >= 0; level--) {
80104308:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
8010430c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104310:	79 a7                	jns    801042b9 <scheduler+0xcd>
          }
        }
      }

    found:
80104312:	90                   	nop
      if (chosen) {
80104313:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104317:	0f 84 15 01 00 00    	je     80104432 <scheduler+0x246>
        int cidx = chosen - ptable.proc;
8010431d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104320:	2d 34 bb 30 80       	sub    $0x8030bb34,%eax
80104325:	c1 f8 02             	sar    $0x2,%eax
80104328:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
8010432e:	89 45 dc             	mov    %eax,-0x24(%ebp)
        c->proc = chosen;
80104331:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104334:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104337:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(chosen);
8010433d:	83 ec 0c             	sub    $0xc,%esp
80104340:	ff 75 f0             	push   -0x10(%ebp)
80104343:	e8 95 39 00 00       	call   80107cdd <switchuvm>
80104348:	83 c4 10             	add    $0x10,%esp
        chosen->state = RUNNING;
8010434b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010434e:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&c->scheduler, chosen->context);
80104355:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104358:	8b 40 1c             	mov    0x1c(%eax),%eax
8010435b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010435e:	83 c2 04             	add    $0x4,%edx
80104361:	83 ec 08             	sub    $0x8,%esp
80104364:	50                   	push   %eax
80104365:	52                   	push   %edx
80104366:	e8 07 0d 00 00       	call   80105072 <swtch>
8010436b:	83 c4 10             	add    $0x10,%esp
        switchkvm();
8010436e:	e8 51 39 00 00       	call   80107cc4 <switchkvm>

        proc_ticks[cidx][proc_priority[cidx]]++;
80104373:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104376:	8b 0c 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%ecx
8010437d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104380:	c1 e0 02             	shl    $0x2,%eax
80104383:	01 c8                	add    %ecx,%eax
80104385:	8b 04 85 00 b3 30 80 	mov    -0x7fcf4d00(,%eax,4),%eax
8010438c:	8d 50 01             	lea    0x1(%eax),%edx
8010438f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104392:	c1 e0 02             	shl    $0x2,%eax
80104395:	01 c8                	add    %ecx,%eax
80104397:	89 14 85 00 b3 30 80 	mov    %edx,-0x7fcf4d00(,%eax,4)

        if (proc_ticks[cidx][proc_priority[cidx]] >= (int[]){0,32,16,8}[proc_priority[cidx]]
8010439e:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043a1:	8b 14 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%edx
801043a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043ab:	c1 e0 02             	shl    $0x2,%eax
801043ae:	01 d0                	add    %edx,%eax
801043b0:	8b 14 85 00 b3 30 80 	mov    -0x7fcf4d00(,%eax,4),%edx
801043b7:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%ebp)
801043be:	c7 45 c0 20 00 00 00 	movl   $0x20,-0x40(%ebp)
801043c5:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
801043cc:	c7 45 c8 08 00 00 00 	movl   $0x8,-0x38(%ebp)
801043d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043d6:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
801043dd:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
801043e1:	39 c2                	cmp    %eax,%edx
801043e3:	7c 40                	jl     80104425 <scheduler+0x239>
            && proc_priority[cidx] > 0) {
801043e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043e8:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
801043ef:	85 c0                	test   %eax,%eax
801043f1:	7e 32                	jle    80104425 <scheduler+0x239>
          proc_priority[cidx]--;
801043f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043f6:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
801043fd:	8d 50 ff             	lea    -0x1(%eax),%edx
80104400:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104403:	89 14 85 00 b2 30 80 	mov    %edx,-0x7fcf4e00(,%eax,4)
          memset(proc_wait_ticks[cidx], 0, sizeof(proc_wait_ticks[cidx]));
8010440a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010440d:	c1 e0 04             	shl    $0x4,%eax
80104410:	05 00 b7 30 80       	add    $0x8030b700,%eax
80104415:	83 ec 04             	sub    $0x4,%esp
80104418:	6a 10                	push   $0x10
8010441a:	6a 00                	push   $0x0
8010441c:	50                   	push   %eax
8010441d:	e8 db 09 00 00       	call   80104dfd <memset>
80104422:	83 c4 10             	add    $0x10,%esp
        }

        c->proc = 0;
80104425:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104428:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010442f:	00 00 00 
      }

      // wait_ticks 증가
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104432:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
80104439:	eb 59                	jmp    80104494 <scheduler+0x2a8>
        int idx = p - ptable.proc;
8010443b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443e:	2d 34 bb 30 80       	sub    $0x8030bb34,%eax
80104443:	c1 f8 02             	sar    $0x2,%eax
80104446:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
8010444c:	89 45 cc             	mov    %eax,-0x34(%ebp)
        if (p->state == RUNNABLE && p != chosen) {
8010444f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104452:	8b 40 0c             	mov    0xc(%eax),%eax
80104455:	83 f8 03             	cmp    $0x3,%eax
80104458:	75 33                	jne    8010448d <scheduler+0x2a1>
8010445a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104460:	74 2b                	je     8010448d <scheduler+0x2a1>
          proc_wait_ticks[idx][proc_priority[idx]]++;
80104462:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104465:	8b 0c 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%ecx
8010446c:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010446f:	c1 e0 02             	shl    $0x2,%eax
80104472:	01 c8                	add    %ecx,%eax
80104474:	8b 04 85 00 b7 30 80 	mov    -0x7fcf4900(,%eax,4),%eax
8010447b:	8d 50 01             	lea    0x1(%eax),%edx
8010447e:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104481:	c1 e0 02             	shl    $0x2,%eax
80104484:	01 c8                	add    %ecx,%eax
80104486:	89 14 85 00 b7 30 80 	mov    %edx,-0x7fcf4900(,%eax,4)
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010448d:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104494:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
8010449b:	72 9e                	jb     8010443b <scheduler+0x24f>
        }
      }

      // Boosting (policy 1, 2만)
      if (policy != 3) {
8010449d:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
801044a1:	0f 84 f7 00 00 00    	je     8010459e <scheduler+0x3b2>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801044a7:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
801044ae:	e9 de 00 00 00       	jmp    80104591 <scheduler+0x3a5>
          int idx = p - ptable.proc;
801044b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b6:	2d 34 bb 30 80       	sub    $0x8030bb34,%eax
801044bb:	c1 f8 02             	sar    $0x2,%eax
801044be:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
801044c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
          if (p->state == RUNNABLE && proc_priority[idx] < 3) {
801044c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ca:	8b 40 0c             	mov    0xc(%eax),%eax
801044cd:	83 f8 03             	cmp    $0x3,%eax
801044d0:	0f 85 b4 00 00 00    	jne    8010458a <scheduler+0x39e>
801044d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801044d9:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
801044e0:	83 f8 02             	cmp    $0x2,%eax
801044e3:	0f 8f a1 00 00 00    	jg     8010458a <scheduler+0x39e>
            int waited = proc_wait_ticks[idx][proc_priority[idx]];
801044e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801044ec:	8b 14 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%edx
801044f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801044f6:	c1 e0 02             	shl    $0x2,%eax
801044f9:	01 d0                	add    %edx,%eax
801044fb:	8b 04 85 00 b7 30 80 	mov    -0x7fcf4900(,%eax,4),%eax
80104502:	89 45 d4             	mov    %eax,-0x2c(%ebp)
            int required = (proc_priority[idx] == 0) ? 500 : 10 * (int[]){0,32,16,8}[proc_priority[idx]];
80104505:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104508:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
8010450f:	85 c0                	test   %eax,%eax
80104511:	74 35                	je     80104548 <scheduler+0x35c>
80104513:	c7 45 ac 00 00 00 00 	movl   $0x0,-0x54(%ebp)
8010451a:	c7 45 b0 20 00 00 00 	movl   $0x20,-0x50(%ebp)
80104521:	c7 45 b4 10 00 00 00 	movl   $0x10,-0x4c(%ebp)
80104528:	c7 45 b8 08 00 00 00 	movl   $0x8,-0x48(%ebp)
8010452f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104532:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
80104539:	8b 54 85 ac          	mov    -0x54(%ebp,%eax,4),%edx
8010453d:	89 d0                	mov    %edx,%eax
8010453f:	c1 e0 02             	shl    $0x2,%eax
80104542:	01 d0                	add    %edx,%eax
80104544:	01 c0                	add    %eax,%eax
80104546:	eb 05                	jmp    8010454d <scheduler+0x361>
80104548:	b8 f4 01 00 00       	mov    $0x1f4,%eax
8010454d:	89 45 d0             	mov    %eax,-0x30(%ebp)

            if (waited >= required) {
80104550:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80104553:	3b 45 d0             	cmp    -0x30(%ebp),%eax
80104556:	7c 32                	jl     8010458a <scheduler+0x39e>
              proc_priority[idx]++;
80104558:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010455b:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
80104562:	8d 50 01             	lea    0x1(%eax),%edx
80104565:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104568:	89 14 85 00 b2 30 80 	mov    %edx,-0x7fcf4e00(,%eax,4)
              memset(proc_wait_ticks[idx], 0, sizeof(proc_wait_ticks[idx]));
8010456f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104572:	c1 e0 04             	shl    $0x4,%eax
80104575:	05 00 b7 30 80       	add    $0x8030b700,%eax
8010457a:	83 ec 04             	sub    $0x4,%esp
8010457d:	6a 10                	push   $0x10
8010457f:	6a 00                	push   $0x0
80104581:	50                   	push   %eax
80104582:	e8 76 08 00 00       	call   80104dfd <memset>
80104587:	83 c4 10             	add    $0x10,%esp
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010458a:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104591:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
80104598:	0f 82 15 ff ff ff    	jb     801044b3 <scheduler+0x2c7>
          }
        }
      }
    }

    release(&ptable.lock);
8010459e:	83 ec 0c             	sub    $0xc,%esp
801045a1:	68 00 bb 30 80       	push   $0x8030bb00
801045a6:	e8 4a 06 00 00       	call   80104bf5 <release>
801045ab:	83 c4 10             	add    $0x10,%esp
  for (;;) {
801045ae:	e9 54 fc ff ff       	jmp    80104207 <scheduler+0x1b>

801045b3 <sched>:
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void sched(void)
{
801045b3:	55                   	push   %ebp
801045b4:	89 e5                	mov    %esp,%ebp
801045b6:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801045b9:	e8 5a f4 ff ff       	call   80103a18 <myproc>
801045be:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if (!holding(&ptable.lock))
801045c1:	83 ec 0c             	sub    $0xc,%esp
801045c4:	68 00 bb 30 80       	push   $0x8030bb00
801045c9:	e8 f4 06 00 00       	call   80104cc2 <holding>
801045ce:	83 c4 10             	add    $0x10,%esp
801045d1:	85 c0                	test   %eax,%eax
801045d3:	75 0d                	jne    801045e2 <sched+0x2f>
    panic("sched ptable.lock");
801045d5:	83 ec 0c             	sub    $0xc,%esp
801045d8:	68 68 ac 10 80       	push   $0x8010ac68
801045dd:	e8 c7 bf ff ff       	call   801005a9 <panic>
  if (mycpu()->ncli != 1)
801045e2:	e8 b9 f3 ff ff       	call   801039a0 <mycpu>
801045e7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801045ed:	83 f8 01             	cmp    $0x1,%eax
801045f0:	74 0d                	je     801045ff <sched+0x4c>
    panic("sched locks");
801045f2:	83 ec 0c             	sub    $0xc,%esp
801045f5:	68 7a ac 10 80       	push   $0x8010ac7a
801045fa:	e8 aa bf ff ff       	call   801005a9 <panic>
  if (p->state == RUNNING)
801045ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104602:	8b 40 0c             	mov    0xc(%eax),%eax
80104605:	83 f8 04             	cmp    $0x4,%eax
80104608:	75 0d                	jne    80104617 <sched+0x64>
    panic("sched running");
8010460a:	83 ec 0c             	sub    $0xc,%esp
8010460d:	68 86 ac 10 80       	push   $0x8010ac86
80104612:	e8 92 bf ff ff       	call   801005a9 <panic>
  if (readeflags() & FL_IF)
80104617:	e8 34 f3 ff ff       	call   80103950 <readeflags>
8010461c:	25 00 02 00 00       	and    $0x200,%eax
80104621:	85 c0                	test   %eax,%eax
80104623:	74 0d                	je     80104632 <sched+0x7f>
    panic("sched interruptible");
80104625:	83 ec 0c             	sub    $0xc,%esp
80104628:	68 94 ac 10 80       	push   $0x8010ac94
8010462d:	e8 77 bf ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104632:	e8 69 f3 ff ff       	call   801039a0 <mycpu>
80104637:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010463d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104640:	e8 5b f3 ff ff       	call   801039a0 <mycpu>
80104645:	8b 40 04             	mov    0x4(%eax),%eax
80104648:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010464b:	83 c2 1c             	add    $0x1c,%edx
8010464e:	83 ec 08             	sub    $0x8,%esp
80104651:	50                   	push   %eax
80104652:	52                   	push   %edx
80104653:	e8 1a 0a 00 00       	call   80105072 <swtch>
80104658:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010465b:	e8 40 f3 ff ff       	call   801039a0 <mycpu>
80104660:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104663:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104669:	90                   	nop
8010466a:	c9                   	leave  
8010466b:	c3                   	ret    

8010466c <yield>:

// 이거이거거
// Give up the CPU for one scheduling round.
void yield(void)
{
8010466c:	55                   	push   %ebp
8010466d:	89 e5                	mov    %esp,%ebp
8010466f:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock); // DOC: yieldlock
80104672:	83 ec 0c             	sub    $0xc,%esp
80104675:	68 00 bb 30 80       	push   $0x8030bb00
8010467a:	e8 08 05 00 00       	call   80104b87 <acquire>
8010467f:	83 c4 10             	add    $0x10,%esp

  int idx = myproc() - ptable.proc;
80104682:	e8 91 f3 ff ff       	call   80103a18 <myproc>
80104687:	2d 34 bb 30 80       	sub    $0x8030bb34,%eax
8010468c:	c1 f8 02             	sar    $0x2,%eax
8010468f:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
80104695:	89 45 f4             	mov    %eax,-0xc(%ebp)
  proc_ticks[idx][proc_priority[idx]]++;
80104698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469b:	8b 0c 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%ecx
801046a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a5:	c1 e0 02             	shl    $0x2,%eax
801046a8:	01 c8                	add    %ecx,%eax
801046aa:	8b 04 85 00 b3 30 80 	mov    -0x7fcf4d00(,%eax,4),%eax
801046b1:	8d 50 01             	lea    0x1(%eax),%edx
801046b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b7:	c1 e0 02             	shl    $0x2,%eax
801046ba:	01 c8                	add    %ecx,%eax
801046bc:	89 14 85 00 b3 30 80 	mov    %edx,-0x7fcf4d00(,%eax,4)

  myproc()->state = RUNNABLE;
801046c3:	e8 50 f3 ff ff       	call   80103a18 <myproc>
801046c8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801046cf:	e8 df fe ff ff       	call   801045b3 <sched>
  release(&ptable.lock);
801046d4:	83 ec 0c             	sub    $0xc,%esp
801046d7:	68 00 bb 30 80       	push   $0x8030bb00
801046dc:	e8 14 05 00 00       	call   80104bf5 <release>
801046e1:	83 c4 10             	add    $0x10,%esp
}
801046e4:	90                   	nop
801046e5:	c9                   	leave  
801046e6:	c3                   	ret    

801046e7 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void forkret(void)
{
801046e7:	55                   	push   %ebp
801046e8:	89 e5                	mov    %esp,%ebp
801046ea:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801046ed:	83 ec 0c             	sub    $0xc,%esp
801046f0:	68 00 bb 30 80       	push   $0x8030bb00
801046f5:	e8 fb 04 00 00       	call   80104bf5 <release>
801046fa:	83 c4 10             	add    $0x10,%esp

  if (first)
801046fd:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104702:	85 c0                	test   %eax,%eax
80104704:	74 24                	je     8010472a <forkret+0x43>
  {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104706:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
8010470d:	00 00 00 
    iinit(ROOTDEV);
80104710:	83 ec 0c             	sub    $0xc,%esp
80104713:	6a 01                	push   $0x1
80104715:	e8 46 cf ff ff       	call   80101660 <iinit>
8010471a:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010471d:	83 ec 0c             	sub    $0xc,%esp
80104720:	6a 01                	push   $0x1
80104722:	e8 de e6 ff ff       	call   80102e05 <initlog>
80104727:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010472a:	90                   	nop
8010472b:	c9                   	leave  
8010472c:	c3                   	ret    

8010472d <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
8010472d:	55                   	push   %ebp
8010472e:	89 e5                	mov    %esp,%ebp
80104730:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104733:	e8 e0 f2 ff ff       	call   80103a18 <myproc>
80104738:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if (p == 0)
8010473b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010473f:	75 0d                	jne    8010474e <sleep+0x21>
    panic("sleep");
80104741:	83 ec 0c             	sub    $0xc,%esp
80104744:	68 a8 ac 10 80       	push   $0x8010aca8
80104749:	e8 5b be ff ff       	call   801005a9 <panic>

  if (lk == 0)
8010474e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104752:	75 0d                	jne    80104761 <sleep+0x34>
    panic("sleep without lk");
80104754:	83 ec 0c             	sub    $0xc,%esp
80104757:	68 ae ac 10 80       	push   $0x8010acae
8010475c:	e8 48 be ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if (lk != &ptable.lock)
80104761:	81 7d 0c 00 bb 30 80 	cmpl   $0x8030bb00,0xc(%ebp)
80104768:	74 1e                	je     80104788 <sleep+0x5b>
  {                        // DOC: sleeplock0
    acquire(&ptable.lock); // DOC: sleeplock1
8010476a:	83 ec 0c             	sub    $0xc,%esp
8010476d:	68 00 bb 30 80       	push   $0x8030bb00
80104772:	e8 10 04 00 00       	call   80104b87 <acquire>
80104777:	83 c4 10             	add    $0x10,%esp
    release(lk);
8010477a:	83 ec 0c             	sub    $0xc,%esp
8010477d:	ff 75 0c             	push   0xc(%ebp)
80104780:	e8 70 04 00 00       	call   80104bf5 <release>
80104785:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478b:	8b 55 08             	mov    0x8(%ebp),%edx
8010478e:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104794:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
8010479b:	e8 13 fe ff ff       	call   801045b3 <sched>

  // Tidy up.
  p->chan = 0;
801047a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a3:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if (lk != &ptable.lock)
801047aa:	81 7d 0c 00 bb 30 80 	cmpl   $0x8030bb00,0xc(%ebp)
801047b1:	74 1e                	je     801047d1 <sleep+0xa4>
  { // DOC: sleeplock2
    release(&ptable.lock);
801047b3:	83 ec 0c             	sub    $0xc,%esp
801047b6:	68 00 bb 30 80       	push   $0x8030bb00
801047bb:	e8 35 04 00 00       	call   80104bf5 <release>
801047c0:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801047c3:	83 ec 0c             	sub    $0xc,%esp
801047c6:	ff 75 0c             	push   0xc(%ebp)
801047c9:	e8 b9 03 00 00       	call   80104b87 <acquire>
801047ce:	83 c4 10             	add    $0x10,%esp
  }
}
801047d1:	90                   	nop
801047d2:	c9                   	leave  
801047d3:	c3                   	ret    

801047d4 <wakeup1>:
// PAGEBREAK!
//  Wake up all processes sleeping on chan.
//  The ptable lock must be held.
static void
wakeup1(void *chan)
{
801047d4:	55                   	push   %ebp
801047d5:	89 e5                	mov    %esp,%ebp
801047d7:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801047da:	c7 45 fc 34 bb 30 80 	movl   $0x8030bb34,-0x4(%ebp)
801047e1:	eb 27                	jmp    8010480a <wakeup1+0x36>
    if (p->state == SLEEPING && p->chan == chan)
801047e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801047e6:	8b 40 0c             	mov    0xc(%eax),%eax
801047e9:	83 f8 02             	cmp    $0x2,%eax
801047ec:	75 15                	jne    80104803 <wakeup1+0x2f>
801047ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801047f1:	8b 40 20             	mov    0x20(%eax),%eax
801047f4:	39 45 08             	cmp    %eax,0x8(%ebp)
801047f7:	75 0a                	jne    80104803 <wakeup1+0x2f>
      p->state = RUNNABLE;
801047f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801047fc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104803:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
8010480a:	81 7d fc 34 dc 30 80 	cmpl   $0x8030dc34,-0x4(%ebp)
80104811:	72 d0                	jb     801047e3 <wakeup1+0xf>
}
80104813:	90                   	nop
80104814:	90                   	nop
80104815:	c9                   	leave  
80104816:	c3                   	ret    

80104817 <wakeup>:

// Wake up all processes sleeping on chan.
void wakeup(void *chan)
{
80104817:	55                   	push   %ebp
80104818:	89 e5                	mov    %esp,%ebp
8010481a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010481d:	83 ec 0c             	sub    $0xc,%esp
80104820:	68 00 bb 30 80       	push   $0x8030bb00
80104825:	e8 5d 03 00 00       	call   80104b87 <acquire>
8010482a:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010482d:	83 ec 0c             	sub    $0xc,%esp
80104830:	ff 75 08             	push   0x8(%ebp)
80104833:	e8 9c ff ff ff       	call   801047d4 <wakeup1>
80104838:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010483b:	83 ec 0c             	sub    $0xc,%esp
8010483e:	68 00 bb 30 80       	push   $0x8030bb00
80104843:	e8 ad 03 00 00       	call   80104bf5 <release>
80104848:	83 c4 10             	add    $0x10,%esp
}
8010484b:	90                   	nop
8010484c:	c9                   	leave  
8010484d:	c3                   	ret    

8010484e <kill>:

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int kill(int pid)
{
8010484e:	55                   	push   %ebp
8010484f:	89 e5                	mov    %esp,%ebp
80104851:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104854:	83 ec 0c             	sub    $0xc,%esp
80104857:	68 00 bb 30 80       	push   $0x8030bb00
8010485c:	e8 26 03 00 00       	call   80104b87 <acquire>
80104861:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104864:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
8010486b:	eb 48                	jmp    801048b5 <kill+0x67>
  {
    if (p->pid == pid)
8010486d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104870:	8b 40 10             	mov    0x10(%eax),%eax
80104873:	39 45 08             	cmp    %eax,0x8(%ebp)
80104876:	75 36                	jne    801048ae <kill+0x60>
    {
      p->killed = 1;
80104878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if (p->state == SLEEPING)
80104882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104885:	8b 40 0c             	mov    0xc(%eax),%eax
80104888:	83 f8 02             	cmp    $0x2,%eax
8010488b:	75 0a                	jne    80104897 <kill+0x49>
        p->state = RUNNABLE;
8010488d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104890:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104897:	83 ec 0c             	sub    $0xc,%esp
8010489a:	68 00 bb 30 80       	push   $0x8030bb00
8010489f:	e8 51 03 00 00       	call   80104bf5 <release>
801048a4:	83 c4 10             	add    $0x10,%esp
      return 0;
801048a7:	b8 00 00 00 00       	mov    $0x0,%eax
801048ac:	eb 25                	jmp    801048d3 <kill+0x85>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048ae:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801048b5:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
801048bc:	72 af                	jb     8010486d <kill+0x1f>
    }
  }
  release(&ptable.lock);
801048be:	83 ec 0c             	sub    $0xc,%esp
801048c1:	68 00 bb 30 80       	push   $0x8030bb00
801048c6:	e8 2a 03 00 00       	call   80104bf5 <release>
801048cb:	83 c4 10             	add    $0x10,%esp
  return -1;
801048ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801048d3:	c9                   	leave  
801048d4:	c3                   	ret    

801048d5 <procdump>:
// PAGEBREAK: 36
//  Print a process listing to console.  For debugging.
//  Runs when user types ^P on console.
//  No lock to avoid wedging a stuck machine further.
void procdump(void)
{
801048d5:	55                   	push   %ebp
801048d6:	89 e5                	mov    %esp,%ebp
801048d8:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048db:	c7 45 f0 34 bb 30 80 	movl   $0x8030bb34,-0x10(%ebp)
801048e2:	e9 da 00 00 00       	jmp    801049c1 <procdump+0xec>
  {
    if (p->state == UNUSED)
801048e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048ea:	8b 40 0c             	mov    0xc(%eax),%eax
801048ed:	85 c0                	test   %eax,%eax
801048ef:	0f 84 c4 00 00 00    	je     801049b9 <procdump+0xe4>
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
801048f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048f8:	8b 40 0c             	mov    0xc(%eax),%eax
801048fb:	83 f8 05             	cmp    $0x5,%eax
801048fe:	77 23                	ja     80104923 <procdump+0x4e>
80104900:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104903:	8b 40 0c             	mov    0xc(%eax),%eax
80104906:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010490d:	85 c0                	test   %eax,%eax
8010490f:	74 12                	je     80104923 <procdump+0x4e>
      state = states[p->state];
80104911:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104914:	8b 40 0c             	mov    0xc(%eax),%eax
80104917:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010491e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104921:	eb 07                	jmp    8010492a <procdump+0x55>
    else
      state = "???";
80104923:	c7 45 ec bf ac 10 80 	movl   $0x8010acbf,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010492a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010492d:	8d 50 6c             	lea    0x6c(%eax),%edx
80104930:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104933:	8b 40 10             	mov    0x10(%eax),%eax
80104936:	52                   	push   %edx
80104937:	ff 75 ec             	push   -0x14(%ebp)
8010493a:	50                   	push   %eax
8010493b:	68 c3 ac 10 80       	push   $0x8010acc3
80104940:	e8 af ba ff ff       	call   801003f4 <cprintf>
80104945:	83 c4 10             	add    $0x10,%esp
    if (p->state == SLEEPING)
80104948:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010494b:	8b 40 0c             	mov    0xc(%eax),%eax
8010494e:	83 f8 02             	cmp    $0x2,%eax
80104951:	75 54                	jne    801049a7 <procdump+0xd2>
    {
      getcallerpcs((uint *)p->context->ebp + 2, pc);
80104953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104956:	8b 40 1c             	mov    0x1c(%eax),%eax
80104959:	8b 40 0c             	mov    0xc(%eax),%eax
8010495c:	83 c0 08             	add    $0x8,%eax
8010495f:	89 c2                	mov    %eax,%edx
80104961:	83 ec 08             	sub    $0x8,%esp
80104964:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104967:	50                   	push   %eax
80104968:	52                   	push   %edx
80104969:	e8 d9 02 00 00       	call   80104c47 <getcallerpcs>
8010496e:	83 c4 10             	add    $0x10,%esp
      for (i = 0; i < 10 && pc[i] != 0; i++)
80104971:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104978:	eb 1c                	jmp    80104996 <procdump+0xc1>
        cprintf(" %p", pc[i]);
8010497a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497d:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104981:	83 ec 08             	sub    $0x8,%esp
80104984:	50                   	push   %eax
80104985:	68 cc ac 10 80       	push   $0x8010accc
8010498a:	e8 65 ba ff ff       	call   801003f4 <cprintf>
8010498f:	83 c4 10             	add    $0x10,%esp
      for (i = 0; i < 10 && pc[i] != 0; i++)
80104992:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104996:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010499a:	7f 0b                	jg     801049a7 <procdump+0xd2>
8010499c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499f:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801049a3:	85 c0                	test   %eax,%eax
801049a5:	75 d3                	jne    8010497a <procdump+0xa5>
    }
    cprintf("\n");
801049a7:	83 ec 0c             	sub    $0xc,%esp
801049aa:	68 d0 ac 10 80       	push   $0x8010acd0
801049af:	e8 40 ba ff ff       	call   801003f4 <cprintf>
801049b4:	83 c4 10             	add    $0x10,%esp
801049b7:	eb 01                	jmp    801049ba <procdump+0xe5>
      continue;
801049b9:	90                   	nop
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801049ba:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
801049c1:	81 7d f0 34 dc 30 80 	cmpl   $0x8030dc34,-0x10(%ebp)
801049c8:	0f 82 19 ff ff ff    	jb     801048e7 <procdump+0x12>
  }
}
801049ce:	90                   	nop
801049cf:	90                   	nop
801049d0:	c9                   	leave  
801049d1:	c3                   	ret    

801049d2 <find_proc_by_pid>:

struct proc* find_proc_by_pid(int pid) {
801049d2:	55                   	push   %ebp
801049d3:	89 e5                	mov    %esp,%ebp
801049d5:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801049d8:	c7 45 fc 34 bb 30 80 	movl   $0x8030bb34,-0x4(%ebp)
801049df:	eb 17                	jmp    801049f8 <find_proc_by_pid+0x26>
    if(p->pid == pid)
801049e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049e4:	8b 40 10             	mov    0x10(%eax),%eax
801049e7:	39 45 08             	cmp    %eax,0x8(%ebp)
801049ea:	75 05                	jne    801049f1 <find_proc_by_pid+0x1f>
      return p;
801049ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049ef:	eb 15                	jmp    80104a06 <find_proc_by_pid+0x34>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801049f1:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
801049f8:	81 7d fc 34 dc 30 80 	cmpl   $0x8030dc34,-0x4(%ebp)
801049ff:	72 e0                	jb     801049e1 <find_proc_by_pid+0xf>
  }
  return 0;
80104a01:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a06:	c9                   	leave  
80104a07:	c3                   	ret    

80104a08 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104a08:	55                   	push   %ebp
80104a09:	89 e5                	mov    %esp,%ebp
80104a0b:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a11:	83 c0 04             	add    $0x4,%eax
80104a14:	83 ec 08             	sub    $0x8,%esp
80104a17:	68 fc ac 10 80       	push   $0x8010acfc
80104a1c:	50                   	push   %eax
80104a1d:	e8 43 01 00 00       	call   80104b65 <initlock>
80104a22:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104a25:	8b 45 08             	mov    0x8(%ebp),%eax
80104a28:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a2b:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a31:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104a37:	8b 45 08             	mov    0x8(%ebp),%eax
80104a3a:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104a41:	90                   	nop
80104a42:	c9                   	leave  
80104a43:	c3                   	ret    

80104a44 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104a44:	55                   	push   %ebp
80104a45:	89 e5                	mov    %esp,%ebp
80104a47:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4d:	83 c0 04             	add    $0x4,%eax
80104a50:	83 ec 0c             	sub    $0xc,%esp
80104a53:	50                   	push   %eax
80104a54:	e8 2e 01 00 00       	call   80104b87 <acquire>
80104a59:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104a5c:	eb 15                	jmp    80104a73 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a61:	83 c0 04             	add    $0x4,%eax
80104a64:	83 ec 08             	sub    $0x8,%esp
80104a67:	50                   	push   %eax
80104a68:	ff 75 08             	push   0x8(%ebp)
80104a6b:	e8 bd fc ff ff       	call   8010472d <sleep>
80104a70:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104a73:	8b 45 08             	mov    0x8(%ebp),%eax
80104a76:	8b 00                	mov    (%eax),%eax
80104a78:	85 c0                	test   %eax,%eax
80104a7a:	75 e2                	jne    80104a5e <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a7f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104a85:	e8 8e ef ff ff       	call   80103a18 <myproc>
80104a8a:	8b 50 10             	mov    0x10(%eax),%edx
80104a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a90:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104a93:	8b 45 08             	mov    0x8(%ebp),%eax
80104a96:	83 c0 04             	add    $0x4,%eax
80104a99:	83 ec 0c             	sub    $0xc,%esp
80104a9c:	50                   	push   %eax
80104a9d:	e8 53 01 00 00       	call   80104bf5 <release>
80104aa2:	83 c4 10             	add    $0x10,%esp
}
80104aa5:	90                   	nop
80104aa6:	c9                   	leave  
80104aa7:	c3                   	ret    

80104aa8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104aa8:	55                   	push   %ebp
80104aa9:	89 e5                	mov    %esp,%ebp
80104aab:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104aae:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab1:	83 c0 04             	add    $0x4,%eax
80104ab4:	83 ec 0c             	sub    $0xc,%esp
80104ab7:	50                   	push   %eax
80104ab8:	e8 ca 00 00 00       	call   80104b87 <acquire>
80104abd:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104ac0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80104acc:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104ad3:	83 ec 0c             	sub    $0xc,%esp
80104ad6:	ff 75 08             	push   0x8(%ebp)
80104ad9:	e8 39 fd ff ff       	call   80104817 <wakeup>
80104ade:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae4:	83 c0 04             	add    $0x4,%eax
80104ae7:	83 ec 0c             	sub    $0xc,%esp
80104aea:	50                   	push   %eax
80104aeb:	e8 05 01 00 00       	call   80104bf5 <release>
80104af0:	83 c4 10             	add    $0x10,%esp
}
80104af3:	90                   	nop
80104af4:	c9                   	leave  
80104af5:	c3                   	ret    

80104af6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104af6:	55                   	push   %ebp
80104af7:	89 e5                	mov    %esp,%ebp
80104af9:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104afc:	8b 45 08             	mov    0x8(%ebp),%eax
80104aff:	83 c0 04             	add    $0x4,%eax
80104b02:	83 ec 0c             	sub    $0xc,%esp
80104b05:	50                   	push   %eax
80104b06:	e8 7c 00 00 00       	call   80104b87 <acquire>
80104b0b:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b11:	8b 00                	mov    (%eax),%eax
80104b13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104b16:	8b 45 08             	mov    0x8(%ebp),%eax
80104b19:	83 c0 04             	add    $0x4,%eax
80104b1c:	83 ec 0c             	sub    $0xc,%esp
80104b1f:	50                   	push   %eax
80104b20:	e8 d0 00 00 00       	call   80104bf5 <release>
80104b25:	83 c4 10             	add    $0x10,%esp
  return r;
80104b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b2b:	c9                   	leave  
80104b2c:	c3                   	ret    

80104b2d <readeflags>:
{
80104b2d:	55                   	push   %ebp
80104b2e:	89 e5                	mov    %esp,%ebp
80104b30:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b33:	9c                   	pushf  
80104b34:	58                   	pop    %eax
80104b35:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b38:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b3b:	c9                   	leave  
80104b3c:	c3                   	ret    

80104b3d <cli>:
{
80104b3d:	55                   	push   %ebp
80104b3e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104b40:	fa                   	cli    
}
80104b41:	90                   	nop
80104b42:	5d                   	pop    %ebp
80104b43:	c3                   	ret    

80104b44 <sti>:
{
80104b44:	55                   	push   %ebp
80104b45:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104b47:	fb                   	sti    
}
80104b48:	90                   	nop
80104b49:	5d                   	pop    %ebp
80104b4a:	c3                   	ret    

80104b4b <xchg>:
{
80104b4b:	55                   	push   %ebp
80104b4c:	89 e5                	mov    %esp,%ebp
80104b4e:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104b51:	8b 55 08             	mov    0x8(%ebp),%edx
80104b54:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b57:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b5a:	f0 87 02             	lock xchg %eax,(%edx)
80104b5d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104b60:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b63:	c9                   	leave  
80104b64:	c3                   	ret    

80104b65 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104b65:	55                   	push   %ebp
80104b66:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104b68:	8b 45 08             	mov    0x8(%ebp),%eax
80104b6b:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b6e:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104b71:	8b 45 08             	mov    0x8(%ebp),%eax
80104b74:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104b7a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104b84:	90                   	nop
80104b85:	5d                   	pop    %ebp
80104b86:	c3                   	ret    

80104b87 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104b87:	55                   	push   %ebp
80104b88:	89 e5                	mov    %esp,%ebp
80104b8a:	53                   	push   %ebx
80104b8b:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104b8e:	e8 5f 01 00 00       	call   80104cf2 <pushcli>
  if(holding(lk)){
80104b93:	8b 45 08             	mov    0x8(%ebp),%eax
80104b96:	83 ec 0c             	sub    $0xc,%esp
80104b99:	50                   	push   %eax
80104b9a:	e8 23 01 00 00       	call   80104cc2 <holding>
80104b9f:	83 c4 10             	add    $0x10,%esp
80104ba2:	85 c0                	test   %eax,%eax
80104ba4:	74 0d                	je     80104bb3 <acquire+0x2c>
    panic("acquire");
80104ba6:	83 ec 0c             	sub    $0xc,%esp
80104ba9:	68 07 ad 10 80       	push   $0x8010ad07
80104bae:	e8 f6 b9 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104bb3:	90                   	nop
80104bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb7:	83 ec 08             	sub    $0x8,%esp
80104bba:	6a 01                	push   $0x1
80104bbc:	50                   	push   %eax
80104bbd:	e8 89 ff ff ff       	call   80104b4b <xchg>
80104bc2:	83 c4 10             	add    $0x10,%esp
80104bc5:	85 c0                	test   %eax,%eax
80104bc7:	75 eb                	jne    80104bb4 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104bc9:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104bce:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104bd1:	e8 ca ed ff ff       	call   801039a0 <mycpu>
80104bd6:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104bd9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bdc:	83 c0 0c             	add    $0xc,%eax
80104bdf:	83 ec 08             	sub    $0x8,%esp
80104be2:	50                   	push   %eax
80104be3:	8d 45 08             	lea    0x8(%ebp),%eax
80104be6:	50                   	push   %eax
80104be7:	e8 5b 00 00 00       	call   80104c47 <getcallerpcs>
80104bec:	83 c4 10             	add    $0x10,%esp
}
80104bef:	90                   	nop
80104bf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bf3:	c9                   	leave  
80104bf4:	c3                   	ret    

80104bf5 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104bf5:	55                   	push   %ebp
80104bf6:	89 e5                	mov    %esp,%ebp
80104bf8:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104bfb:	83 ec 0c             	sub    $0xc,%esp
80104bfe:	ff 75 08             	push   0x8(%ebp)
80104c01:	e8 bc 00 00 00       	call   80104cc2 <holding>
80104c06:	83 c4 10             	add    $0x10,%esp
80104c09:	85 c0                	test   %eax,%eax
80104c0b:	75 0d                	jne    80104c1a <release+0x25>
    panic("release");
80104c0d:	83 ec 0c             	sub    $0xc,%esp
80104c10:	68 0f ad 10 80       	push   $0x8010ad0f
80104c15:	e8 8f b9 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104c24:	8b 45 08             	mov    0x8(%ebp),%eax
80104c27:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104c2e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104c33:	8b 45 08             	mov    0x8(%ebp),%eax
80104c36:	8b 55 08             	mov    0x8(%ebp),%edx
80104c39:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104c3f:	e8 fb 00 00 00       	call   80104d3f <popcli>
}
80104c44:	90                   	nop
80104c45:	c9                   	leave  
80104c46:	c3                   	ret    

80104c47 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104c47:	55                   	push   %ebp
80104c48:	89 e5                	mov    %esp,%ebp
80104c4a:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104c4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c50:	83 e8 08             	sub    $0x8,%eax
80104c53:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104c56:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104c5d:	eb 38                	jmp    80104c97 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104c5f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104c63:	74 53                	je     80104cb8 <getcallerpcs+0x71>
80104c65:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104c6c:	76 4a                	jbe    80104cb8 <getcallerpcs+0x71>
80104c6e:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104c72:	74 44                	je     80104cb8 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104c74:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c77:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c81:	01 c2                	add    %eax,%edx
80104c83:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c86:	8b 40 04             	mov    0x4(%eax),%eax
80104c89:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104c8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c8e:	8b 00                	mov    (%eax),%eax
80104c90:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104c93:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c97:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c9b:	7e c2                	jle    80104c5f <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104c9d:	eb 19                	jmp    80104cb8 <getcallerpcs+0x71>
    pcs[i] = 0;
80104c9f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ca2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ca9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cac:	01 d0                	add    %edx,%eax
80104cae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104cb4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104cb8:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104cbc:	7e e1                	jle    80104c9f <getcallerpcs+0x58>
}
80104cbe:	90                   	nop
80104cbf:	90                   	nop
80104cc0:	c9                   	leave  
80104cc1:	c3                   	ret    

80104cc2 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104cc2:	55                   	push   %ebp
80104cc3:	89 e5                	mov    %esp,%ebp
80104cc5:	53                   	push   %ebx
80104cc6:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104cc9:	8b 45 08             	mov    0x8(%ebp),%eax
80104ccc:	8b 00                	mov    (%eax),%eax
80104cce:	85 c0                	test   %eax,%eax
80104cd0:	74 16                	je     80104ce8 <holding+0x26>
80104cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd5:	8b 58 08             	mov    0x8(%eax),%ebx
80104cd8:	e8 c3 ec ff ff       	call   801039a0 <mycpu>
80104cdd:	39 c3                	cmp    %eax,%ebx
80104cdf:	75 07                	jne    80104ce8 <holding+0x26>
80104ce1:	b8 01 00 00 00       	mov    $0x1,%eax
80104ce6:	eb 05                	jmp    80104ced <holding+0x2b>
80104ce8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ced:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104cf0:	c9                   	leave  
80104cf1:	c3                   	ret    

80104cf2 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104cf2:	55                   	push   %ebp
80104cf3:	89 e5                	mov    %esp,%ebp
80104cf5:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104cf8:	e8 30 fe ff ff       	call   80104b2d <readeflags>
80104cfd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104d00:	e8 38 fe ff ff       	call   80104b3d <cli>
  if(mycpu()->ncli == 0)
80104d05:	e8 96 ec ff ff       	call   801039a0 <mycpu>
80104d0a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d10:	85 c0                	test   %eax,%eax
80104d12:	75 14                	jne    80104d28 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104d14:	e8 87 ec ff ff       	call   801039a0 <mycpu>
80104d19:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d1c:	81 e2 00 02 00 00    	and    $0x200,%edx
80104d22:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104d28:	e8 73 ec ff ff       	call   801039a0 <mycpu>
80104d2d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d33:	83 c2 01             	add    $0x1,%edx
80104d36:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104d3c:	90                   	nop
80104d3d:	c9                   	leave  
80104d3e:	c3                   	ret    

80104d3f <popcli>:

void
popcli(void)
{
80104d3f:	55                   	push   %ebp
80104d40:	89 e5                	mov    %esp,%ebp
80104d42:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104d45:	e8 e3 fd ff ff       	call   80104b2d <readeflags>
80104d4a:	25 00 02 00 00       	and    $0x200,%eax
80104d4f:	85 c0                	test   %eax,%eax
80104d51:	74 0d                	je     80104d60 <popcli+0x21>
    panic("popcli - interruptible");
80104d53:	83 ec 0c             	sub    $0xc,%esp
80104d56:	68 17 ad 10 80       	push   $0x8010ad17
80104d5b:	e8 49 b8 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104d60:	e8 3b ec ff ff       	call   801039a0 <mycpu>
80104d65:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d6b:	83 ea 01             	sub    $0x1,%edx
80104d6e:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104d74:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d7a:	85 c0                	test   %eax,%eax
80104d7c:	79 0d                	jns    80104d8b <popcli+0x4c>
    panic("popcli");
80104d7e:	83 ec 0c             	sub    $0xc,%esp
80104d81:	68 2e ad 10 80       	push   $0x8010ad2e
80104d86:	e8 1e b8 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104d8b:	e8 10 ec ff ff       	call   801039a0 <mycpu>
80104d90:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d96:	85 c0                	test   %eax,%eax
80104d98:	75 14                	jne    80104dae <popcli+0x6f>
80104d9a:	e8 01 ec ff ff       	call   801039a0 <mycpu>
80104d9f:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104da5:	85 c0                	test   %eax,%eax
80104da7:	74 05                	je     80104dae <popcli+0x6f>
    sti();
80104da9:	e8 96 fd ff ff       	call   80104b44 <sti>
}
80104dae:	90                   	nop
80104daf:	c9                   	leave  
80104db0:	c3                   	ret    

80104db1 <stosb>:
{
80104db1:	55                   	push   %ebp
80104db2:	89 e5                	mov    %esp,%ebp
80104db4:	57                   	push   %edi
80104db5:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104db6:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104db9:	8b 55 10             	mov    0x10(%ebp),%edx
80104dbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dbf:	89 cb                	mov    %ecx,%ebx
80104dc1:	89 df                	mov    %ebx,%edi
80104dc3:	89 d1                	mov    %edx,%ecx
80104dc5:	fc                   	cld    
80104dc6:	f3 aa                	rep stos %al,%es:(%edi)
80104dc8:	89 ca                	mov    %ecx,%edx
80104dca:	89 fb                	mov    %edi,%ebx
80104dcc:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104dcf:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104dd2:	90                   	nop
80104dd3:	5b                   	pop    %ebx
80104dd4:	5f                   	pop    %edi
80104dd5:	5d                   	pop    %ebp
80104dd6:	c3                   	ret    

80104dd7 <stosl>:
{
80104dd7:	55                   	push   %ebp
80104dd8:	89 e5                	mov    %esp,%ebp
80104dda:	57                   	push   %edi
80104ddb:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104ddc:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ddf:	8b 55 10             	mov    0x10(%ebp),%edx
80104de2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104de5:	89 cb                	mov    %ecx,%ebx
80104de7:	89 df                	mov    %ebx,%edi
80104de9:	89 d1                	mov    %edx,%ecx
80104deb:	fc                   	cld    
80104dec:	f3 ab                	rep stos %eax,%es:(%edi)
80104dee:	89 ca                	mov    %ecx,%edx
80104df0:	89 fb                	mov    %edi,%ebx
80104df2:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104df5:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104df8:	90                   	nop
80104df9:	5b                   	pop    %ebx
80104dfa:	5f                   	pop    %edi
80104dfb:	5d                   	pop    %ebp
80104dfc:	c3                   	ret    

80104dfd <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104dfd:	55                   	push   %ebp
80104dfe:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104e00:	8b 45 08             	mov    0x8(%ebp),%eax
80104e03:	83 e0 03             	and    $0x3,%eax
80104e06:	85 c0                	test   %eax,%eax
80104e08:	75 43                	jne    80104e4d <memset+0x50>
80104e0a:	8b 45 10             	mov    0x10(%ebp),%eax
80104e0d:	83 e0 03             	and    $0x3,%eax
80104e10:	85 c0                	test   %eax,%eax
80104e12:	75 39                	jne    80104e4d <memset+0x50>
    c &= 0xFF;
80104e14:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104e1b:	8b 45 10             	mov    0x10(%ebp),%eax
80104e1e:	c1 e8 02             	shr    $0x2,%eax
80104e21:	89 c2                	mov    %eax,%edx
80104e23:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e26:	c1 e0 18             	shl    $0x18,%eax
80104e29:	89 c1                	mov    %eax,%ecx
80104e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e2e:	c1 e0 10             	shl    $0x10,%eax
80104e31:	09 c1                	or     %eax,%ecx
80104e33:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e36:	c1 e0 08             	shl    $0x8,%eax
80104e39:	09 c8                	or     %ecx,%eax
80104e3b:	0b 45 0c             	or     0xc(%ebp),%eax
80104e3e:	52                   	push   %edx
80104e3f:	50                   	push   %eax
80104e40:	ff 75 08             	push   0x8(%ebp)
80104e43:	e8 8f ff ff ff       	call   80104dd7 <stosl>
80104e48:	83 c4 0c             	add    $0xc,%esp
80104e4b:	eb 12                	jmp    80104e5f <memset+0x62>
  } else
    stosb(dst, c, n);
80104e4d:	8b 45 10             	mov    0x10(%ebp),%eax
80104e50:	50                   	push   %eax
80104e51:	ff 75 0c             	push   0xc(%ebp)
80104e54:	ff 75 08             	push   0x8(%ebp)
80104e57:	e8 55 ff ff ff       	call   80104db1 <stosb>
80104e5c:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104e5f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e62:	c9                   	leave  
80104e63:	c3                   	ret    

80104e64 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104e64:	55                   	push   %ebp
80104e65:	89 e5                	mov    %esp,%ebp
80104e67:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80104e6d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104e70:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e73:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104e76:	eb 30                	jmp    80104ea8 <memcmp+0x44>
    if(*s1 != *s2)
80104e78:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e7b:	0f b6 10             	movzbl (%eax),%edx
80104e7e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e81:	0f b6 00             	movzbl (%eax),%eax
80104e84:	38 c2                	cmp    %al,%dl
80104e86:	74 18                	je     80104ea0 <memcmp+0x3c>
      return *s1 - *s2;
80104e88:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e8b:	0f b6 00             	movzbl (%eax),%eax
80104e8e:	0f b6 d0             	movzbl %al,%edx
80104e91:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e94:	0f b6 00             	movzbl (%eax),%eax
80104e97:	0f b6 c8             	movzbl %al,%ecx
80104e9a:	89 d0                	mov    %edx,%eax
80104e9c:	29 c8                	sub    %ecx,%eax
80104e9e:	eb 1a                	jmp    80104eba <memcmp+0x56>
    s1++, s2++;
80104ea0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104ea4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104ea8:	8b 45 10             	mov    0x10(%ebp),%eax
80104eab:	8d 50 ff             	lea    -0x1(%eax),%edx
80104eae:	89 55 10             	mov    %edx,0x10(%ebp)
80104eb1:	85 c0                	test   %eax,%eax
80104eb3:	75 c3                	jne    80104e78 <memcmp+0x14>
  }

  return 0;
80104eb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104eba:	c9                   	leave  
80104ebb:	c3                   	ret    

80104ebc <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104ebc:	55                   	push   %ebp
80104ebd:	89 e5                	mov    %esp,%ebp
80104ebf:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ec5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80104ecb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104ece:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ed1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104ed4:	73 54                	jae    80104f2a <memmove+0x6e>
80104ed6:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ed9:	8b 45 10             	mov    0x10(%ebp),%eax
80104edc:	01 d0                	add    %edx,%eax
80104ede:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104ee1:	73 47                	jae    80104f2a <memmove+0x6e>
    s += n;
80104ee3:	8b 45 10             	mov    0x10(%ebp),%eax
80104ee6:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104ee9:	8b 45 10             	mov    0x10(%ebp),%eax
80104eec:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104eef:	eb 13                	jmp    80104f04 <memmove+0x48>
      *--d = *--s;
80104ef1:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104ef5:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104ef9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104efc:	0f b6 10             	movzbl (%eax),%edx
80104eff:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f02:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f04:	8b 45 10             	mov    0x10(%ebp),%eax
80104f07:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f0a:	89 55 10             	mov    %edx,0x10(%ebp)
80104f0d:	85 c0                	test   %eax,%eax
80104f0f:	75 e0                	jne    80104ef1 <memmove+0x35>
  if(s < d && s + n > d){
80104f11:	eb 24                	jmp    80104f37 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104f13:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f16:	8d 42 01             	lea    0x1(%edx),%eax
80104f19:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104f1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f1f:	8d 48 01             	lea    0x1(%eax),%ecx
80104f22:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104f25:	0f b6 12             	movzbl (%edx),%edx
80104f28:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f2a:	8b 45 10             	mov    0x10(%ebp),%eax
80104f2d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f30:	89 55 10             	mov    %edx,0x10(%ebp)
80104f33:	85 c0                	test   %eax,%eax
80104f35:	75 dc                	jne    80104f13 <memmove+0x57>

  return dst;
80104f37:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104f3a:	c9                   	leave  
80104f3b:	c3                   	ret    

80104f3c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104f3c:	55                   	push   %ebp
80104f3d:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104f3f:	ff 75 10             	push   0x10(%ebp)
80104f42:	ff 75 0c             	push   0xc(%ebp)
80104f45:	ff 75 08             	push   0x8(%ebp)
80104f48:	e8 6f ff ff ff       	call   80104ebc <memmove>
80104f4d:	83 c4 0c             	add    $0xc,%esp
}
80104f50:	c9                   	leave  
80104f51:	c3                   	ret    

80104f52 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104f52:	55                   	push   %ebp
80104f53:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104f55:	eb 0c                	jmp    80104f63 <strncmp+0x11>
    n--, p++, q++;
80104f57:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f5b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104f5f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104f63:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f67:	74 1a                	je     80104f83 <strncmp+0x31>
80104f69:	8b 45 08             	mov    0x8(%ebp),%eax
80104f6c:	0f b6 00             	movzbl (%eax),%eax
80104f6f:	84 c0                	test   %al,%al
80104f71:	74 10                	je     80104f83 <strncmp+0x31>
80104f73:	8b 45 08             	mov    0x8(%ebp),%eax
80104f76:	0f b6 10             	movzbl (%eax),%edx
80104f79:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f7c:	0f b6 00             	movzbl (%eax),%eax
80104f7f:	38 c2                	cmp    %al,%dl
80104f81:	74 d4                	je     80104f57 <strncmp+0x5>
  if(n == 0)
80104f83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f87:	75 07                	jne    80104f90 <strncmp+0x3e>
    return 0;
80104f89:	b8 00 00 00 00       	mov    $0x0,%eax
80104f8e:	eb 16                	jmp    80104fa6 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104f90:	8b 45 08             	mov    0x8(%ebp),%eax
80104f93:	0f b6 00             	movzbl (%eax),%eax
80104f96:	0f b6 d0             	movzbl %al,%edx
80104f99:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f9c:	0f b6 00             	movzbl (%eax),%eax
80104f9f:	0f b6 c8             	movzbl %al,%ecx
80104fa2:	89 d0                	mov    %edx,%eax
80104fa4:	29 c8                	sub    %ecx,%eax
}
80104fa6:	5d                   	pop    %ebp
80104fa7:	c3                   	ret    

80104fa8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104fa8:	55                   	push   %ebp
80104fa9:	89 e5                	mov    %esp,%ebp
80104fab:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104fae:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104fb4:	90                   	nop
80104fb5:	8b 45 10             	mov    0x10(%ebp),%eax
80104fb8:	8d 50 ff             	lea    -0x1(%eax),%edx
80104fbb:	89 55 10             	mov    %edx,0x10(%ebp)
80104fbe:	85 c0                	test   %eax,%eax
80104fc0:	7e 2c                	jle    80104fee <strncpy+0x46>
80104fc2:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fc5:	8d 42 01             	lea    0x1(%edx),%eax
80104fc8:	89 45 0c             	mov    %eax,0xc(%ebp)
80104fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80104fce:	8d 48 01             	lea    0x1(%eax),%ecx
80104fd1:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104fd4:	0f b6 12             	movzbl (%edx),%edx
80104fd7:	88 10                	mov    %dl,(%eax)
80104fd9:	0f b6 00             	movzbl (%eax),%eax
80104fdc:	84 c0                	test   %al,%al
80104fde:	75 d5                	jne    80104fb5 <strncpy+0xd>
    ;
  while(n-- > 0)
80104fe0:	eb 0c                	jmp    80104fee <strncpy+0x46>
    *s++ = 0;
80104fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe5:	8d 50 01             	lea    0x1(%eax),%edx
80104fe8:	89 55 08             	mov    %edx,0x8(%ebp)
80104feb:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104fee:	8b 45 10             	mov    0x10(%ebp),%eax
80104ff1:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ff4:	89 55 10             	mov    %edx,0x10(%ebp)
80104ff7:	85 c0                	test   %eax,%eax
80104ff9:	7f e7                	jg     80104fe2 <strncpy+0x3a>
  return os;
80104ffb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ffe:	c9                   	leave  
80104fff:	c3                   	ret    

80105000 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105000:	55                   	push   %ebp
80105001:	89 e5                	mov    %esp,%ebp
80105003:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105006:	8b 45 08             	mov    0x8(%ebp),%eax
80105009:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010500c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105010:	7f 05                	jg     80105017 <safestrcpy+0x17>
    return os;
80105012:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105015:	eb 32                	jmp    80105049 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80105017:	90                   	nop
80105018:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010501c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105020:	7e 1e                	jle    80105040 <safestrcpy+0x40>
80105022:	8b 55 0c             	mov    0xc(%ebp),%edx
80105025:	8d 42 01             	lea    0x1(%edx),%eax
80105028:	89 45 0c             	mov    %eax,0xc(%ebp)
8010502b:	8b 45 08             	mov    0x8(%ebp),%eax
8010502e:	8d 48 01             	lea    0x1(%eax),%ecx
80105031:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105034:	0f b6 12             	movzbl (%edx),%edx
80105037:	88 10                	mov    %dl,(%eax)
80105039:	0f b6 00             	movzbl (%eax),%eax
8010503c:	84 c0                	test   %al,%al
8010503e:	75 d8                	jne    80105018 <safestrcpy+0x18>
    ;
  *s = 0;
80105040:	8b 45 08             	mov    0x8(%ebp),%eax
80105043:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105046:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105049:	c9                   	leave  
8010504a:	c3                   	ret    

8010504b <strlen>:

int
strlen(const char *s)
{
8010504b:	55                   	push   %ebp
8010504c:	89 e5                	mov    %esp,%ebp
8010504e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105051:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105058:	eb 04                	jmp    8010505e <strlen+0x13>
8010505a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010505e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105061:	8b 45 08             	mov    0x8(%ebp),%eax
80105064:	01 d0                	add    %edx,%eax
80105066:	0f b6 00             	movzbl (%eax),%eax
80105069:	84 c0                	test   %al,%al
8010506b:	75 ed                	jne    8010505a <strlen+0xf>
    ;
  return n;
8010506d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105070:	c9                   	leave  
80105071:	c3                   	ret    

80105072 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105072:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105076:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010507a:	55                   	push   %ebp
  pushl %ebx
8010507b:	53                   	push   %ebx
  pushl %esi
8010507c:	56                   	push   %esi
  pushl %edi
8010507d:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010507e:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105080:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105082:	5f                   	pop    %edi
  popl %esi
80105083:	5e                   	pop    %esi
  popl %ebx
80105084:	5b                   	pop    %ebx
  popl %ebp
80105085:	5d                   	pop    %ebp
  ret
80105086:	c3                   	ret    

80105087 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105087:	55                   	push   %ebp
80105088:	89 e5                	mov    %esp,%ebp
  //struct proc *curproc = myproc();

  if(addr >= /*curproc->sz*/ KERNBASE || addr+4 > /*curproc->sz*/ KERNBASE)
8010508a:	8b 45 08             	mov    0x8(%ebp),%eax
8010508d:	85 c0                	test   %eax,%eax
8010508f:	78 0d                	js     8010509e <fetchint+0x17>
80105091:	8b 45 08             	mov    0x8(%ebp),%eax
80105094:	83 c0 04             	add    $0x4,%eax
80105097:	3d 00 00 00 80       	cmp    $0x80000000,%eax
8010509c:	76 07                	jbe    801050a5 <fetchint+0x1e>
    return -1;
8010509e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050a3:	eb 0f                	jmp    801050b4 <fetchint+0x2d>
  *ip = *(int*)(addr);
801050a5:	8b 45 08             	mov    0x8(%ebp),%eax
801050a8:	8b 10                	mov    (%eax),%edx
801050aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ad:	89 10                	mov    %edx,(%eax)
  return 0;
801050af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050b4:	5d                   	pop    %ebp
801050b5:	c3                   	ret    

801050b6 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801050b6:	55                   	push   %ebp
801050b7:	89 e5                	mov    %esp,%ebp
801050b9:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;
  //struct proc *curproc = myproc();

  if(addr >= /*curproc->sz*/ KERNBASE)
801050bc:	8b 45 08             	mov    0x8(%ebp),%eax
801050bf:	85 c0                	test   %eax,%eax
801050c1:	79 07                	jns    801050ca <fetchstr+0x14>
    return -1;
801050c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050c8:	eb 40                	jmp    8010510a <fetchstr+0x54>
  *pp = (char*)addr;
801050ca:	8b 55 08             	mov    0x8(%ebp),%edx
801050cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801050d0:	89 10                	mov    %edx,(%eax)
  ep = (char*)/*curproc->sz*/ KERNBASE;
801050d2:	c7 45 f8 00 00 00 80 	movl   $0x80000000,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
801050d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801050dc:	8b 00                	mov    (%eax),%eax
801050de:	89 45 fc             	mov    %eax,-0x4(%ebp)
801050e1:	eb 1a                	jmp    801050fd <fetchstr+0x47>
    if(*s == 0)
801050e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050e6:	0f b6 00             	movzbl (%eax),%eax
801050e9:	84 c0                	test   %al,%al
801050eb:	75 0c                	jne    801050f9 <fetchstr+0x43>
      return s - *pp;
801050ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801050f0:	8b 10                	mov    (%eax),%edx
801050f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050f5:	29 d0                	sub    %edx,%eax
801050f7:	eb 11                	jmp    8010510a <fetchstr+0x54>
  for(s = *pp; s < ep; s++){
801050f9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801050fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105100:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105103:	72 de                	jb     801050e3 <fetchstr+0x2d>
  }
  return -1;
80105105:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010510a:	c9                   	leave  
8010510b:	c3                   	ret    

8010510c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010510c:	55                   	push   %ebp
8010510d:	89 e5                	mov    %esp,%ebp
8010510f:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105112:	e8 01 e9 ff ff       	call   80103a18 <myproc>
80105117:	8b 40 18             	mov    0x18(%eax),%eax
8010511a:	8b 50 44             	mov    0x44(%eax),%edx
8010511d:	8b 45 08             	mov    0x8(%ebp),%eax
80105120:	c1 e0 02             	shl    $0x2,%eax
80105123:	01 d0                	add    %edx,%eax
80105125:	83 c0 04             	add    $0x4,%eax
80105128:	83 ec 08             	sub    $0x8,%esp
8010512b:	ff 75 0c             	push   0xc(%ebp)
8010512e:	50                   	push   %eax
8010512f:	e8 53 ff ff ff       	call   80105087 <fetchint>
80105134:	83 c4 10             	add    $0x10,%esp
}
80105137:	c9                   	leave  
80105138:	c3                   	ret    

80105139 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105139:	55                   	push   %ebp
8010513a:	89 e5                	mov    %esp,%ebp
8010513c:	83 ec 18             	sub    $0x18,%esp
  int i;
  //struct proc *curproc = myproc();
 
  if(argint(n, &i) < 0)
8010513f:	83 ec 08             	sub    $0x8,%esp
80105142:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105145:	50                   	push   %eax
80105146:	ff 75 08             	push   0x8(%ebp)
80105149:	e8 be ff ff ff       	call   8010510c <argint>
8010514e:	83 c4 10             	add    $0x10,%esp
80105151:	85 c0                	test   %eax,%eax
80105153:	79 07                	jns    8010515c <argptr+0x23>
    return -1;
80105155:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010515a:	eb 34                	jmp    80105190 <argptr+0x57>
  if(size < 0 || (uint)i >= /*curproc->sz*/ KERNBASE || (uint)i+size > /*curproc->sz*/ KERNBASE)
8010515c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105160:	78 18                	js     8010517a <argptr+0x41>
80105162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105165:	85 c0                	test   %eax,%eax
80105167:	78 11                	js     8010517a <argptr+0x41>
80105169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010516c:	89 c2                	mov    %eax,%edx
8010516e:	8b 45 10             	mov    0x10(%ebp),%eax
80105171:	01 d0                	add    %edx,%eax
80105173:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80105178:	76 07                	jbe    80105181 <argptr+0x48>
    return -1;
8010517a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010517f:	eb 0f                	jmp    80105190 <argptr+0x57>
  *pp = (char*)i;
80105181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105184:	89 c2                	mov    %eax,%edx
80105186:	8b 45 0c             	mov    0xc(%ebp),%eax
80105189:	89 10                	mov    %edx,(%eax)
  return 0;
8010518b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105190:	c9                   	leave  
80105191:	c3                   	ret    

80105192 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105192:	55                   	push   %ebp
80105193:	89 e5                	mov    %esp,%ebp
80105195:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105198:	83 ec 08             	sub    $0x8,%esp
8010519b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010519e:	50                   	push   %eax
8010519f:	ff 75 08             	push   0x8(%ebp)
801051a2:	e8 65 ff ff ff       	call   8010510c <argint>
801051a7:	83 c4 10             	add    $0x10,%esp
801051aa:	85 c0                	test   %eax,%eax
801051ac:	79 07                	jns    801051b5 <argstr+0x23>
    return -1;
801051ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051b3:	eb 12                	jmp    801051c7 <argstr+0x35>
  return fetchstr(addr, pp);
801051b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b8:	83 ec 08             	sub    $0x8,%esp
801051bb:	ff 75 0c             	push   0xc(%ebp)
801051be:	50                   	push   %eax
801051bf:	e8 f2 fe ff ff       	call   801050b6 <fetchstr>
801051c4:	83 c4 10             	add    $0x10,%esp
}
801051c7:	c9                   	leave  
801051c8:	c3                   	ret    

801051c9 <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
801051c9:	55                   	push   %ebp
801051ca:	89 e5                	mov    %esp,%ebp
801051cc:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801051cf:	e8 44 e8 ff ff       	call   80103a18 <myproc>
801051d4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801051d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051da:	8b 40 18             	mov    0x18(%eax),%eax
801051dd:	8b 40 1c             	mov    0x1c(%eax),%eax
801051e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801051e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801051e7:	7e 2f                	jle    80105218 <syscall+0x4f>
801051e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051ec:	83 f8 1b             	cmp    $0x1b,%eax
801051ef:	77 27                	ja     80105218 <syscall+0x4f>
801051f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f4:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801051fb:	85 c0                	test   %eax,%eax
801051fd:	74 19                	je     80105218 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
801051ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105202:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105209:	ff d0                	call   *%eax
8010520b:	89 c2                	mov    %eax,%edx
8010520d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105210:	8b 40 18             	mov    0x18(%eax),%eax
80105213:	89 50 1c             	mov    %edx,0x1c(%eax)
80105216:	eb 2c                	jmp    80105244 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010521b:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010521e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105221:	8b 40 10             	mov    0x10(%eax),%eax
80105224:	ff 75 f0             	push   -0x10(%ebp)
80105227:	52                   	push   %edx
80105228:	50                   	push   %eax
80105229:	68 35 ad 10 80       	push   $0x8010ad35
8010522e:	e8 c1 b1 ff ff       	call   801003f4 <cprintf>
80105233:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105239:	8b 40 18             	mov    0x18(%eax),%eax
8010523c:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105243:	90                   	nop
80105244:	90                   	nop
80105245:	c9                   	leave  
80105246:	c3                   	ret    

80105247 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105247:	55                   	push   %ebp
80105248:	89 e5                	mov    %esp,%ebp
8010524a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010524d:	83 ec 08             	sub    $0x8,%esp
80105250:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105253:	50                   	push   %eax
80105254:	ff 75 08             	push   0x8(%ebp)
80105257:	e8 b0 fe ff ff       	call   8010510c <argint>
8010525c:	83 c4 10             	add    $0x10,%esp
8010525f:	85 c0                	test   %eax,%eax
80105261:	79 07                	jns    8010526a <argfd+0x23>
    return -1;
80105263:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105268:	eb 4f                	jmp    801052b9 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010526a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010526d:	85 c0                	test   %eax,%eax
8010526f:	78 20                	js     80105291 <argfd+0x4a>
80105271:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105274:	83 f8 0f             	cmp    $0xf,%eax
80105277:	7f 18                	jg     80105291 <argfd+0x4a>
80105279:	e8 9a e7 ff ff       	call   80103a18 <myproc>
8010527e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105281:	83 c2 08             	add    $0x8,%edx
80105284:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105288:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010528b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010528f:	75 07                	jne    80105298 <argfd+0x51>
    return -1;
80105291:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105296:	eb 21                	jmp    801052b9 <argfd+0x72>
  if(pfd)
80105298:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010529c:	74 08                	je     801052a6 <argfd+0x5f>
    *pfd = fd;
8010529e:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a4:	89 10                	mov    %edx,(%eax)
  if(pf)
801052a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052aa:	74 08                	je     801052b4 <argfd+0x6d>
    *pf = f;
801052ac:	8b 45 10             	mov    0x10(%ebp),%eax
801052af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052b2:	89 10                	mov    %edx,(%eax)
  return 0;
801052b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052b9:	c9                   	leave  
801052ba:	c3                   	ret    

801052bb <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801052bb:	55                   	push   %ebp
801052bc:	89 e5                	mov    %esp,%ebp
801052be:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801052c1:	e8 52 e7 ff ff       	call   80103a18 <myproc>
801052c6:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801052c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801052d0:	eb 2a                	jmp    801052fc <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
801052d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052d8:	83 c2 08             	add    $0x8,%edx
801052db:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801052df:	85 c0                	test   %eax,%eax
801052e1:	75 15                	jne    801052f8 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801052e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052e9:	8d 4a 08             	lea    0x8(%edx),%ecx
801052ec:	8b 55 08             	mov    0x8(%ebp),%edx
801052ef:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801052f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052f6:	eb 0f                	jmp    80105307 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
801052f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801052fc:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105300:	7e d0                	jle    801052d2 <fdalloc+0x17>
    }
  }
  return -1;
80105302:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105307:	c9                   	leave  
80105308:	c3                   	ret    

80105309 <sys_dup>:

int
sys_dup(void)
{
80105309:	55                   	push   %ebp
8010530a:	89 e5                	mov    %esp,%ebp
8010530c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010530f:	83 ec 04             	sub    $0x4,%esp
80105312:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105315:	50                   	push   %eax
80105316:	6a 00                	push   $0x0
80105318:	6a 00                	push   $0x0
8010531a:	e8 28 ff ff ff       	call   80105247 <argfd>
8010531f:	83 c4 10             	add    $0x10,%esp
80105322:	85 c0                	test   %eax,%eax
80105324:	79 07                	jns    8010532d <sys_dup+0x24>
    return -1;
80105326:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010532b:	eb 31                	jmp    8010535e <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010532d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105330:	83 ec 0c             	sub    $0xc,%esp
80105333:	50                   	push   %eax
80105334:	e8 82 ff ff ff       	call   801052bb <fdalloc>
80105339:	83 c4 10             	add    $0x10,%esp
8010533c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010533f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105343:	79 07                	jns    8010534c <sys_dup+0x43>
    return -1;
80105345:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010534a:	eb 12                	jmp    8010535e <sys_dup+0x55>
  filedup(f);
8010534c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010534f:	83 ec 0c             	sub    $0xc,%esp
80105352:	50                   	push   %eax
80105353:	e8 da bc ff ff       	call   80101032 <filedup>
80105358:	83 c4 10             	add    $0x10,%esp
  return fd;
8010535b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010535e:	c9                   	leave  
8010535f:	c3                   	ret    

80105360 <sys_read>:

int
sys_read(void)
{
80105360:	55                   	push   %ebp
80105361:	89 e5                	mov    %esp,%ebp
80105363:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105366:	83 ec 04             	sub    $0x4,%esp
80105369:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010536c:	50                   	push   %eax
8010536d:	6a 00                	push   $0x0
8010536f:	6a 00                	push   $0x0
80105371:	e8 d1 fe ff ff       	call   80105247 <argfd>
80105376:	83 c4 10             	add    $0x10,%esp
80105379:	85 c0                	test   %eax,%eax
8010537b:	78 2e                	js     801053ab <sys_read+0x4b>
8010537d:	83 ec 08             	sub    $0x8,%esp
80105380:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105383:	50                   	push   %eax
80105384:	6a 02                	push   $0x2
80105386:	e8 81 fd ff ff       	call   8010510c <argint>
8010538b:	83 c4 10             	add    $0x10,%esp
8010538e:	85 c0                	test   %eax,%eax
80105390:	78 19                	js     801053ab <sys_read+0x4b>
80105392:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105395:	83 ec 04             	sub    $0x4,%esp
80105398:	50                   	push   %eax
80105399:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010539c:	50                   	push   %eax
8010539d:	6a 01                	push   $0x1
8010539f:	e8 95 fd ff ff       	call   80105139 <argptr>
801053a4:	83 c4 10             	add    $0x10,%esp
801053a7:	85 c0                	test   %eax,%eax
801053a9:	79 07                	jns    801053b2 <sys_read+0x52>
    return -1;
801053ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053b0:	eb 17                	jmp    801053c9 <sys_read+0x69>
  return fileread(f, p, n);
801053b2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053bb:	83 ec 04             	sub    $0x4,%esp
801053be:	51                   	push   %ecx
801053bf:	52                   	push   %edx
801053c0:	50                   	push   %eax
801053c1:	e8 fc bd ff ff       	call   801011c2 <fileread>
801053c6:	83 c4 10             	add    $0x10,%esp
}
801053c9:	c9                   	leave  
801053ca:	c3                   	ret    

801053cb <sys_write>:

int
sys_write(void)
{
801053cb:	55                   	push   %ebp
801053cc:	89 e5                	mov    %esp,%ebp
801053ce:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053d1:	83 ec 04             	sub    $0x4,%esp
801053d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053d7:	50                   	push   %eax
801053d8:	6a 00                	push   $0x0
801053da:	6a 00                	push   $0x0
801053dc:	e8 66 fe ff ff       	call   80105247 <argfd>
801053e1:	83 c4 10             	add    $0x10,%esp
801053e4:	85 c0                	test   %eax,%eax
801053e6:	78 2e                	js     80105416 <sys_write+0x4b>
801053e8:	83 ec 08             	sub    $0x8,%esp
801053eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053ee:	50                   	push   %eax
801053ef:	6a 02                	push   $0x2
801053f1:	e8 16 fd ff ff       	call   8010510c <argint>
801053f6:	83 c4 10             	add    $0x10,%esp
801053f9:	85 c0                	test   %eax,%eax
801053fb:	78 19                	js     80105416 <sys_write+0x4b>
801053fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105400:	83 ec 04             	sub    $0x4,%esp
80105403:	50                   	push   %eax
80105404:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105407:	50                   	push   %eax
80105408:	6a 01                	push   $0x1
8010540a:	e8 2a fd ff ff       	call   80105139 <argptr>
8010540f:	83 c4 10             	add    $0x10,%esp
80105412:	85 c0                	test   %eax,%eax
80105414:	79 07                	jns    8010541d <sys_write+0x52>
    return -1;
80105416:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010541b:	eb 17                	jmp    80105434 <sys_write+0x69>
  return filewrite(f, p, n);
8010541d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105420:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105423:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105426:	83 ec 04             	sub    $0x4,%esp
80105429:	51                   	push   %ecx
8010542a:	52                   	push   %edx
8010542b:	50                   	push   %eax
8010542c:	e8 49 be ff ff       	call   8010127a <filewrite>
80105431:	83 c4 10             	add    $0x10,%esp
}
80105434:	c9                   	leave  
80105435:	c3                   	ret    

80105436 <sys_close>:

int
sys_close(void)
{
80105436:	55                   	push   %ebp
80105437:	89 e5                	mov    %esp,%ebp
80105439:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010543c:	83 ec 04             	sub    $0x4,%esp
8010543f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105442:	50                   	push   %eax
80105443:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105446:	50                   	push   %eax
80105447:	6a 00                	push   $0x0
80105449:	e8 f9 fd ff ff       	call   80105247 <argfd>
8010544e:	83 c4 10             	add    $0x10,%esp
80105451:	85 c0                	test   %eax,%eax
80105453:	79 07                	jns    8010545c <sys_close+0x26>
    return -1;
80105455:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010545a:	eb 27                	jmp    80105483 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
8010545c:	e8 b7 e5 ff ff       	call   80103a18 <myproc>
80105461:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105464:	83 c2 08             	add    $0x8,%edx
80105467:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010546e:	00 
  fileclose(f);
8010546f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105472:	83 ec 0c             	sub    $0xc,%esp
80105475:	50                   	push   %eax
80105476:	e8 08 bc ff ff       	call   80101083 <fileclose>
8010547b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010547e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105483:	c9                   	leave  
80105484:	c3                   	ret    

80105485 <sys_fstat>:

int
sys_fstat(void)
{
80105485:	55                   	push   %ebp
80105486:	89 e5                	mov    %esp,%ebp
80105488:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010548b:	83 ec 04             	sub    $0x4,%esp
8010548e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105491:	50                   	push   %eax
80105492:	6a 00                	push   $0x0
80105494:	6a 00                	push   $0x0
80105496:	e8 ac fd ff ff       	call   80105247 <argfd>
8010549b:	83 c4 10             	add    $0x10,%esp
8010549e:	85 c0                	test   %eax,%eax
801054a0:	78 17                	js     801054b9 <sys_fstat+0x34>
801054a2:	83 ec 04             	sub    $0x4,%esp
801054a5:	6a 14                	push   $0x14
801054a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054aa:	50                   	push   %eax
801054ab:	6a 01                	push   $0x1
801054ad:	e8 87 fc ff ff       	call   80105139 <argptr>
801054b2:	83 c4 10             	add    $0x10,%esp
801054b5:	85 c0                	test   %eax,%eax
801054b7:	79 07                	jns    801054c0 <sys_fstat+0x3b>
    return -1;
801054b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054be:	eb 13                	jmp    801054d3 <sys_fstat+0x4e>
  return filestat(f, st);
801054c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c6:	83 ec 08             	sub    $0x8,%esp
801054c9:	52                   	push   %edx
801054ca:	50                   	push   %eax
801054cb:	e8 9b bc ff ff       	call   8010116b <filestat>
801054d0:	83 c4 10             	add    $0x10,%esp
}
801054d3:	c9                   	leave  
801054d4:	c3                   	ret    

801054d5 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801054d5:	55                   	push   %ebp
801054d6:	89 e5                	mov    %esp,%ebp
801054d8:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801054db:	83 ec 08             	sub    $0x8,%esp
801054de:	8d 45 d8             	lea    -0x28(%ebp),%eax
801054e1:	50                   	push   %eax
801054e2:	6a 00                	push   $0x0
801054e4:	e8 a9 fc ff ff       	call   80105192 <argstr>
801054e9:	83 c4 10             	add    $0x10,%esp
801054ec:	85 c0                	test   %eax,%eax
801054ee:	78 15                	js     80105505 <sys_link+0x30>
801054f0:	83 ec 08             	sub    $0x8,%esp
801054f3:	8d 45 dc             	lea    -0x24(%ebp),%eax
801054f6:	50                   	push   %eax
801054f7:	6a 01                	push   $0x1
801054f9:	e8 94 fc ff ff       	call   80105192 <argstr>
801054fe:	83 c4 10             	add    $0x10,%esp
80105501:	85 c0                	test   %eax,%eax
80105503:	79 0a                	jns    8010550f <sys_link+0x3a>
    return -1;
80105505:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010550a:	e9 68 01 00 00       	jmp    80105677 <sys_link+0x1a2>

  begin_op();
8010550f:	e8 10 db ff ff       	call   80103024 <begin_op>
  if((ip = namei(old)) == 0){
80105514:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105517:	83 ec 0c             	sub    $0xc,%esp
8010551a:	50                   	push   %eax
8010551b:	e8 e5 cf ff ff       	call   80102505 <namei>
80105520:	83 c4 10             	add    $0x10,%esp
80105523:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105526:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010552a:	75 0f                	jne    8010553b <sys_link+0x66>
    end_op();
8010552c:	e8 7f db ff ff       	call   801030b0 <end_op>
    return -1;
80105531:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105536:	e9 3c 01 00 00       	jmp    80105677 <sys_link+0x1a2>
  }

  ilock(ip);
8010553b:	83 ec 0c             	sub    $0xc,%esp
8010553e:	ff 75 f4             	push   -0xc(%ebp)
80105541:	e8 8c c4 ff ff       	call   801019d2 <ilock>
80105546:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010554c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105550:	66 83 f8 01          	cmp    $0x1,%ax
80105554:	75 1d                	jne    80105573 <sys_link+0x9e>
    iunlockput(ip);
80105556:	83 ec 0c             	sub    $0xc,%esp
80105559:	ff 75 f4             	push   -0xc(%ebp)
8010555c:	e8 a2 c6 ff ff       	call   80101c03 <iunlockput>
80105561:	83 c4 10             	add    $0x10,%esp
    end_op();
80105564:	e8 47 db ff ff       	call   801030b0 <end_op>
    return -1;
80105569:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010556e:	e9 04 01 00 00       	jmp    80105677 <sys_link+0x1a2>
  }

  ip->nlink++;
80105573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105576:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010557a:	83 c0 01             	add    $0x1,%eax
8010557d:	89 c2                	mov    %eax,%edx
8010557f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105582:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105586:	83 ec 0c             	sub    $0xc,%esp
80105589:	ff 75 f4             	push   -0xc(%ebp)
8010558c:	e8 64 c2 ff ff       	call   801017f5 <iupdate>
80105591:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105594:	83 ec 0c             	sub    $0xc,%esp
80105597:	ff 75 f4             	push   -0xc(%ebp)
8010559a:	e8 46 c5 ff ff       	call   80101ae5 <iunlock>
8010559f:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801055a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801055a5:	83 ec 08             	sub    $0x8,%esp
801055a8:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801055ab:	52                   	push   %edx
801055ac:	50                   	push   %eax
801055ad:	e8 6f cf ff ff       	call   80102521 <nameiparent>
801055b2:	83 c4 10             	add    $0x10,%esp
801055b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055bc:	74 71                	je     8010562f <sys_link+0x15a>
    goto bad;
  ilock(dp);
801055be:	83 ec 0c             	sub    $0xc,%esp
801055c1:	ff 75 f0             	push   -0x10(%ebp)
801055c4:	e8 09 c4 ff ff       	call   801019d2 <ilock>
801055c9:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801055cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055cf:	8b 10                	mov    (%eax),%edx
801055d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d4:	8b 00                	mov    (%eax),%eax
801055d6:	39 c2                	cmp    %eax,%edx
801055d8:	75 1d                	jne    801055f7 <sys_link+0x122>
801055da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055dd:	8b 40 04             	mov    0x4(%eax),%eax
801055e0:	83 ec 04             	sub    $0x4,%esp
801055e3:	50                   	push   %eax
801055e4:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801055e7:	50                   	push   %eax
801055e8:	ff 75 f0             	push   -0x10(%ebp)
801055eb:	e8 7e cc ff ff       	call   8010226e <dirlink>
801055f0:	83 c4 10             	add    $0x10,%esp
801055f3:	85 c0                	test   %eax,%eax
801055f5:	79 10                	jns    80105607 <sys_link+0x132>
    iunlockput(dp);
801055f7:	83 ec 0c             	sub    $0xc,%esp
801055fa:	ff 75 f0             	push   -0x10(%ebp)
801055fd:	e8 01 c6 ff ff       	call   80101c03 <iunlockput>
80105602:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105605:	eb 29                	jmp    80105630 <sys_link+0x15b>
  }
  iunlockput(dp);
80105607:	83 ec 0c             	sub    $0xc,%esp
8010560a:	ff 75 f0             	push   -0x10(%ebp)
8010560d:	e8 f1 c5 ff ff       	call   80101c03 <iunlockput>
80105612:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105615:	83 ec 0c             	sub    $0xc,%esp
80105618:	ff 75 f4             	push   -0xc(%ebp)
8010561b:	e8 13 c5 ff ff       	call   80101b33 <iput>
80105620:	83 c4 10             	add    $0x10,%esp

  end_op();
80105623:	e8 88 da ff ff       	call   801030b0 <end_op>

  return 0;
80105628:	b8 00 00 00 00       	mov    $0x0,%eax
8010562d:	eb 48                	jmp    80105677 <sys_link+0x1a2>
    goto bad;
8010562f:	90                   	nop

bad:
  ilock(ip);
80105630:	83 ec 0c             	sub    $0xc,%esp
80105633:	ff 75 f4             	push   -0xc(%ebp)
80105636:	e8 97 c3 ff ff       	call   801019d2 <ilock>
8010563b:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010563e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105641:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105645:	83 e8 01             	sub    $0x1,%eax
80105648:	89 c2                	mov    %eax,%edx
8010564a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010564d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105651:	83 ec 0c             	sub    $0xc,%esp
80105654:	ff 75 f4             	push   -0xc(%ebp)
80105657:	e8 99 c1 ff ff       	call   801017f5 <iupdate>
8010565c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010565f:	83 ec 0c             	sub    $0xc,%esp
80105662:	ff 75 f4             	push   -0xc(%ebp)
80105665:	e8 99 c5 ff ff       	call   80101c03 <iunlockput>
8010566a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010566d:	e8 3e da ff ff       	call   801030b0 <end_op>
  return -1;
80105672:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105677:	c9                   	leave  
80105678:	c3                   	ret    

80105679 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105679:	55                   	push   %ebp
8010567a:	89 e5                	mov    %esp,%ebp
8010567c:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010567f:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105686:	eb 40                	jmp    801056c8 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568b:	6a 10                	push   $0x10
8010568d:	50                   	push   %eax
8010568e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105691:	50                   	push   %eax
80105692:	ff 75 08             	push   0x8(%ebp)
80105695:	e8 24 c8 ff ff       	call   80101ebe <readi>
8010569a:	83 c4 10             	add    $0x10,%esp
8010569d:	83 f8 10             	cmp    $0x10,%eax
801056a0:	74 0d                	je     801056af <isdirempty+0x36>
      panic("isdirempty: readi");
801056a2:	83 ec 0c             	sub    $0xc,%esp
801056a5:	68 51 ad 10 80       	push   $0x8010ad51
801056aa:	e8 fa ae ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
801056af:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801056b3:	66 85 c0             	test   %ax,%ax
801056b6:	74 07                	je     801056bf <isdirempty+0x46>
      return 0;
801056b8:	b8 00 00 00 00       	mov    $0x0,%eax
801056bd:	eb 1b                	jmp    801056da <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c2:	83 c0 10             	add    $0x10,%eax
801056c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056c8:	8b 45 08             	mov    0x8(%ebp),%eax
801056cb:	8b 50 58             	mov    0x58(%eax),%edx
801056ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d1:	39 c2                	cmp    %eax,%edx
801056d3:	77 b3                	ja     80105688 <isdirempty+0xf>
  }
  return 1;
801056d5:	b8 01 00 00 00       	mov    $0x1,%eax
}
801056da:	c9                   	leave  
801056db:	c3                   	ret    

801056dc <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801056dc:	55                   	push   %ebp
801056dd:	89 e5                	mov    %esp,%ebp
801056df:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801056e2:	83 ec 08             	sub    $0x8,%esp
801056e5:	8d 45 cc             	lea    -0x34(%ebp),%eax
801056e8:	50                   	push   %eax
801056e9:	6a 00                	push   $0x0
801056eb:	e8 a2 fa ff ff       	call   80105192 <argstr>
801056f0:	83 c4 10             	add    $0x10,%esp
801056f3:	85 c0                	test   %eax,%eax
801056f5:	79 0a                	jns    80105701 <sys_unlink+0x25>
    return -1;
801056f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056fc:	e9 bf 01 00 00       	jmp    801058c0 <sys_unlink+0x1e4>

  begin_op();
80105701:	e8 1e d9 ff ff       	call   80103024 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105706:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105709:	83 ec 08             	sub    $0x8,%esp
8010570c:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010570f:	52                   	push   %edx
80105710:	50                   	push   %eax
80105711:	e8 0b ce ff ff       	call   80102521 <nameiparent>
80105716:	83 c4 10             	add    $0x10,%esp
80105719:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010571c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105720:	75 0f                	jne    80105731 <sys_unlink+0x55>
    end_op();
80105722:	e8 89 d9 ff ff       	call   801030b0 <end_op>
    return -1;
80105727:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010572c:	e9 8f 01 00 00       	jmp    801058c0 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105731:	83 ec 0c             	sub    $0xc,%esp
80105734:	ff 75 f4             	push   -0xc(%ebp)
80105737:	e8 96 c2 ff ff       	call   801019d2 <ilock>
8010573c:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010573f:	83 ec 08             	sub    $0x8,%esp
80105742:	68 63 ad 10 80       	push   $0x8010ad63
80105747:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010574a:	50                   	push   %eax
8010574b:	e8 49 ca ff ff       	call   80102199 <namecmp>
80105750:	83 c4 10             	add    $0x10,%esp
80105753:	85 c0                	test   %eax,%eax
80105755:	0f 84 49 01 00 00    	je     801058a4 <sys_unlink+0x1c8>
8010575b:	83 ec 08             	sub    $0x8,%esp
8010575e:	68 65 ad 10 80       	push   $0x8010ad65
80105763:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105766:	50                   	push   %eax
80105767:	e8 2d ca ff ff       	call   80102199 <namecmp>
8010576c:	83 c4 10             	add    $0x10,%esp
8010576f:	85 c0                	test   %eax,%eax
80105771:	0f 84 2d 01 00 00    	je     801058a4 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105777:	83 ec 04             	sub    $0x4,%esp
8010577a:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010577d:	50                   	push   %eax
8010577e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105781:	50                   	push   %eax
80105782:	ff 75 f4             	push   -0xc(%ebp)
80105785:	e8 2a ca ff ff       	call   801021b4 <dirlookup>
8010578a:	83 c4 10             	add    $0x10,%esp
8010578d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105790:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105794:	0f 84 0d 01 00 00    	je     801058a7 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
8010579a:	83 ec 0c             	sub    $0xc,%esp
8010579d:	ff 75 f0             	push   -0x10(%ebp)
801057a0:	e8 2d c2 ff ff       	call   801019d2 <ilock>
801057a5:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801057a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ab:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057af:	66 85 c0             	test   %ax,%ax
801057b2:	7f 0d                	jg     801057c1 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801057b4:	83 ec 0c             	sub    $0xc,%esp
801057b7:	68 68 ad 10 80       	push   $0x8010ad68
801057bc:	e8 e8 ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801057c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057c4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801057c8:	66 83 f8 01          	cmp    $0x1,%ax
801057cc:	75 25                	jne    801057f3 <sys_unlink+0x117>
801057ce:	83 ec 0c             	sub    $0xc,%esp
801057d1:	ff 75 f0             	push   -0x10(%ebp)
801057d4:	e8 a0 fe ff ff       	call   80105679 <isdirempty>
801057d9:	83 c4 10             	add    $0x10,%esp
801057dc:	85 c0                	test   %eax,%eax
801057de:	75 13                	jne    801057f3 <sys_unlink+0x117>
    iunlockput(ip);
801057e0:	83 ec 0c             	sub    $0xc,%esp
801057e3:	ff 75 f0             	push   -0x10(%ebp)
801057e6:	e8 18 c4 ff ff       	call   80101c03 <iunlockput>
801057eb:	83 c4 10             	add    $0x10,%esp
    goto bad;
801057ee:	e9 b5 00 00 00       	jmp    801058a8 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801057f3:	83 ec 04             	sub    $0x4,%esp
801057f6:	6a 10                	push   $0x10
801057f8:	6a 00                	push   $0x0
801057fa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057fd:	50                   	push   %eax
801057fe:	e8 fa f5 ff ff       	call   80104dfd <memset>
80105803:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105806:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105809:	6a 10                	push   $0x10
8010580b:	50                   	push   %eax
8010580c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010580f:	50                   	push   %eax
80105810:	ff 75 f4             	push   -0xc(%ebp)
80105813:	e8 fb c7 ff ff       	call   80102013 <writei>
80105818:	83 c4 10             	add    $0x10,%esp
8010581b:	83 f8 10             	cmp    $0x10,%eax
8010581e:	74 0d                	je     8010582d <sys_unlink+0x151>
    panic("unlink: writei");
80105820:	83 ec 0c             	sub    $0xc,%esp
80105823:	68 7a ad 10 80       	push   $0x8010ad7a
80105828:	e8 7c ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
8010582d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105830:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105834:	66 83 f8 01          	cmp    $0x1,%ax
80105838:	75 21                	jne    8010585b <sys_unlink+0x17f>
    dp->nlink--;
8010583a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010583d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105841:	83 e8 01             	sub    $0x1,%eax
80105844:	89 c2                	mov    %eax,%edx
80105846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105849:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010584d:	83 ec 0c             	sub    $0xc,%esp
80105850:	ff 75 f4             	push   -0xc(%ebp)
80105853:	e8 9d bf ff ff       	call   801017f5 <iupdate>
80105858:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010585b:	83 ec 0c             	sub    $0xc,%esp
8010585e:	ff 75 f4             	push   -0xc(%ebp)
80105861:	e8 9d c3 ff ff       	call   80101c03 <iunlockput>
80105866:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105869:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010586c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105870:	83 e8 01             	sub    $0x1,%eax
80105873:	89 c2                	mov    %eax,%edx
80105875:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105878:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010587c:	83 ec 0c             	sub    $0xc,%esp
8010587f:	ff 75 f0             	push   -0x10(%ebp)
80105882:	e8 6e bf ff ff       	call   801017f5 <iupdate>
80105887:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010588a:	83 ec 0c             	sub    $0xc,%esp
8010588d:	ff 75 f0             	push   -0x10(%ebp)
80105890:	e8 6e c3 ff ff       	call   80101c03 <iunlockput>
80105895:	83 c4 10             	add    $0x10,%esp

  end_op();
80105898:	e8 13 d8 ff ff       	call   801030b0 <end_op>

  return 0;
8010589d:	b8 00 00 00 00       	mov    $0x0,%eax
801058a2:	eb 1c                	jmp    801058c0 <sys_unlink+0x1e4>
    goto bad;
801058a4:	90                   	nop
801058a5:	eb 01                	jmp    801058a8 <sys_unlink+0x1cc>
    goto bad;
801058a7:	90                   	nop

bad:
  iunlockput(dp);
801058a8:	83 ec 0c             	sub    $0xc,%esp
801058ab:	ff 75 f4             	push   -0xc(%ebp)
801058ae:	e8 50 c3 ff ff       	call   80101c03 <iunlockput>
801058b3:	83 c4 10             	add    $0x10,%esp
  end_op();
801058b6:	e8 f5 d7 ff ff       	call   801030b0 <end_op>
  return -1;
801058bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058c0:	c9                   	leave  
801058c1:	c3                   	ret    

801058c2 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801058c2:	55                   	push   %ebp
801058c3:	89 e5                	mov    %esp,%ebp
801058c5:	83 ec 38             	sub    $0x38,%esp
801058c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801058cb:	8b 55 10             	mov    0x10(%ebp),%edx
801058ce:	8b 45 14             	mov    0x14(%ebp),%eax
801058d1:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801058d5:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801058d9:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801058dd:	83 ec 08             	sub    $0x8,%esp
801058e0:	8d 45 de             	lea    -0x22(%ebp),%eax
801058e3:	50                   	push   %eax
801058e4:	ff 75 08             	push   0x8(%ebp)
801058e7:	e8 35 cc ff ff       	call   80102521 <nameiparent>
801058ec:	83 c4 10             	add    $0x10,%esp
801058ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058f6:	75 0a                	jne    80105902 <create+0x40>
    return 0;
801058f8:	b8 00 00 00 00       	mov    $0x0,%eax
801058fd:	e9 90 01 00 00       	jmp    80105a92 <create+0x1d0>
  ilock(dp);
80105902:	83 ec 0c             	sub    $0xc,%esp
80105905:	ff 75 f4             	push   -0xc(%ebp)
80105908:	e8 c5 c0 ff ff       	call   801019d2 <ilock>
8010590d:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105910:	83 ec 04             	sub    $0x4,%esp
80105913:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105916:	50                   	push   %eax
80105917:	8d 45 de             	lea    -0x22(%ebp),%eax
8010591a:	50                   	push   %eax
8010591b:	ff 75 f4             	push   -0xc(%ebp)
8010591e:	e8 91 c8 ff ff       	call   801021b4 <dirlookup>
80105923:	83 c4 10             	add    $0x10,%esp
80105926:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105929:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010592d:	74 50                	je     8010597f <create+0xbd>
    iunlockput(dp);
8010592f:	83 ec 0c             	sub    $0xc,%esp
80105932:	ff 75 f4             	push   -0xc(%ebp)
80105935:	e8 c9 c2 ff ff       	call   80101c03 <iunlockput>
8010593a:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010593d:	83 ec 0c             	sub    $0xc,%esp
80105940:	ff 75 f0             	push   -0x10(%ebp)
80105943:	e8 8a c0 ff ff       	call   801019d2 <ilock>
80105948:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010594b:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105950:	75 15                	jne    80105967 <create+0xa5>
80105952:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105955:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105959:	66 83 f8 02          	cmp    $0x2,%ax
8010595d:	75 08                	jne    80105967 <create+0xa5>
      return ip;
8010595f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105962:	e9 2b 01 00 00       	jmp    80105a92 <create+0x1d0>
    iunlockput(ip);
80105967:	83 ec 0c             	sub    $0xc,%esp
8010596a:	ff 75 f0             	push   -0x10(%ebp)
8010596d:	e8 91 c2 ff ff       	call   80101c03 <iunlockput>
80105972:	83 c4 10             	add    $0x10,%esp
    return 0;
80105975:	b8 00 00 00 00       	mov    $0x0,%eax
8010597a:	e9 13 01 00 00       	jmp    80105a92 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010597f:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105986:	8b 00                	mov    (%eax),%eax
80105988:	83 ec 08             	sub    $0x8,%esp
8010598b:	52                   	push   %edx
8010598c:	50                   	push   %eax
8010598d:	e8 8c bd ff ff       	call   8010171e <ialloc>
80105992:	83 c4 10             	add    $0x10,%esp
80105995:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105998:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010599c:	75 0d                	jne    801059ab <create+0xe9>
    panic("create: ialloc");
8010599e:	83 ec 0c             	sub    $0xc,%esp
801059a1:	68 89 ad 10 80       	push   $0x8010ad89
801059a6:	e8 fe ab ff ff       	call   801005a9 <panic>

  ilock(ip);
801059ab:	83 ec 0c             	sub    $0xc,%esp
801059ae:	ff 75 f0             	push   -0x10(%ebp)
801059b1:	e8 1c c0 ff ff       	call   801019d2 <ilock>
801059b6:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801059b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059bc:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801059c0:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801059c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059c7:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801059cb:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801059cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d2:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801059d8:	83 ec 0c             	sub    $0xc,%esp
801059db:	ff 75 f0             	push   -0x10(%ebp)
801059de:	e8 12 be ff ff       	call   801017f5 <iupdate>
801059e3:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801059e6:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801059eb:	75 6a                	jne    80105a57 <create+0x195>
    dp->nlink++;  // for ".."
801059ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059f4:	83 c0 01             	add    $0x1,%eax
801059f7:	89 c2                	mov    %eax,%edx
801059f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059fc:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105a00:	83 ec 0c             	sub    $0xc,%esp
80105a03:	ff 75 f4             	push   -0xc(%ebp)
80105a06:	e8 ea bd ff ff       	call   801017f5 <iupdate>
80105a0b:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a11:	8b 40 04             	mov    0x4(%eax),%eax
80105a14:	83 ec 04             	sub    $0x4,%esp
80105a17:	50                   	push   %eax
80105a18:	68 63 ad 10 80       	push   $0x8010ad63
80105a1d:	ff 75 f0             	push   -0x10(%ebp)
80105a20:	e8 49 c8 ff ff       	call   8010226e <dirlink>
80105a25:	83 c4 10             	add    $0x10,%esp
80105a28:	85 c0                	test   %eax,%eax
80105a2a:	78 1e                	js     80105a4a <create+0x188>
80105a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a2f:	8b 40 04             	mov    0x4(%eax),%eax
80105a32:	83 ec 04             	sub    $0x4,%esp
80105a35:	50                   	push   %eax
80105a36:	68 65 ad 10 80       	push   $0x8010ad65
80105a3b:	ff 75 f0             	push   -0x10(%ebp)
80105a3e:	e8 2b c8 ff ff       	call   8010226e <dirlink>
80105a43:	83 c4 10             	add    $0x10,%esp
80105a46:	85 c0                	test   %eax,%eax
80105a48:	79 0d                	jns    80105a57 <create+0x195>
      panic("create dots");
80105a4a:	83 ec 0c             	sub    $0xc,%esp
80105a4d:	68 98 ad 10 80       	push   $0x8010ad98
80105a52:	e8 52 ab ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a5a:	8b 40 04             	mov    0x4(%eax),%eax
80105a5d:	83 ec 04             	sub    $0x4,%esp
80105a60:	50                   	push   %eax
80105a61:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a64:	50                   	push   %eax
80105a65:	ff 75 f4             	push   -0xc(%ebp)
80105a68:	e8 01 c8 ff ff       	call   8010226e <dirlink>
80105a6d:	83 c4 10             	add    $0x10,%esp
80105a70:	85 c0                	test   %eax,%eax
80105a72:	79 0d                	jns    80105a81 <create+0x1bf>
    panic("create: dirlink");
80105a74:	83 ec 0c             	sub    $0xc,%esp
80105a77:	68 a4 ad 10 80       	push   $0x8010ada4
80105a7c:	e8 28 ab ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105a81:	83 ec 0c             	sub    $0xc,%esp
80105a84:	ff 75 f4             	push   -0xc(%ebp)
80105a87:	e8 77 c1 ff ff       	call   80101c03 <iunlockput>
80105a8c:	83 c4 10             	add    $0x10,%esp

  return ip;
80105a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105a92:	c9                   	leave  
80105a93:	c3                   	ret    

80105a94 <sys_open>:

int
sys_open(void)
{
80105a94:	55                   	push   %ebp
80105a95:	89 e5                	mov    %esp,%ebp
80105a97:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105a9a:	83 ec 08             	sub    $0x8,%esp
80105a9d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105aa0:	50                   	push   %eax
80105aa1:	6a 00                	push   $0x0
80105aa3:	e8 ea f6 ff ff       	call   80105192 <argstr>
80105aa8:	83 c4 10             	add    $0x10,%esp
80105aab:	85 c0                	test   %eax,%eax
80105aad:	78 15                	js     80105ac4 <sys_open+0x30>
80105aaf:	83 ec 08             	sub    $0x8,%esp
80105ab2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ab5:	50                   	push   %eax
80105ab6:	6a 01                	push   $0x1
80105ab8:	e8 4f f6 ff ff       	call   8010510c <argint>
80105abd:	83 c4 10             	add    $0x10,%esp
80105ac0:	85 c0                	test   %eax,%eax
80105ac2:	79 0a                	jns    80105ace <sys_open+0x3a>
    return -1;
80105ac4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ac9:	e9 61 01 00 00       	jmp    80105c2f <sys_open+0x19b>

  begin_op();
80105ace:	e8 51 d5 ff ff       	call   80103024 <begin_op>

  if(omode & O_CREATE){
80105ad3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ad6:	25 00 02 00 00       	and    $0x200,%eax
80105adb:	85 c0                	test   %eax,%eax
80105add:	74 2a                	je     80105b09 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105adf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ae2:	6a 00                	push   $0x0
80105ae4:	6a 00                	push   $0x0
80105ae6:	6a 02                	push   $0x2
80105ae8:	50                   	push   %eax
80105ae9:	e8 d4 fd ff ff       	call   801058c2 <create>
80105aee:	83 c4 10             	add    $0x10,%esp
80105af1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105af4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105af8:	75 75                	jne    80105b6f <sys_open+0xdb>
      end_op();
80105afa:	e8 b1 d5 ff ff       	call   801030b0 <end_op>
      return -1;
80105aff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b04:	e9 26 01 00 00       	jmp    80105c2f <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105b09:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b0c:	83 ec 0c             	sub    $0xc,%esp
80105b0f:	50                   	push   %eax
80105b10:	e8 f0 c9 ff ff       	call   80102505 <namei>
80105b15:	83 c4 10             	add    $0x10,%esp
80105b18:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b1f:	75 0f                	jne    80105b30 <sys_open+0x9c>
      end_op();
80105b21:	e8 8a d5 ff ff       	call   801030b0 <end_op>
      return -1;
80105b26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b2b:	e9 ff 00 00 00       	jmp    80105c2f <sys_open+0x19b>
    }
    ilock(ip);
80105b30:	83 ec 0c             	sub    $0xc,%esp
80105b33:	ff 75 f4             	push   -0xc(%ebp)
80105b36:	e8 97 be ff ff       	call   801019d2 <ilock>
80105b3b:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b41:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b45:	66 83 f8 01          	cmp    $0x1,%ax
80105b49:	75 24                	jne    80105b6f <sys_open+0xdb>
80105b4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b4e:	85 c0                	test   %eax,%eax
80105b50:	74 1d                	je     80105b6f <sys_open+0xdb>
      iunlockput(ip);
80105b52:	83 ec 0c             	sub    $0xc,%esp
80105b55:	ff 75 f4             	push   -0xc(%ebp)
80105b58:	e8 a6 c0 ff ff       	call   80101c03 <iunlockput>
80105b5d:	83 c4 10             	add    $0x10,%esp
      end_op();
80105b60:	e8 4b d5 ff ff       	call   801030b0 <end_op>
      return -1;
80105b65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b6a:	e9 c0 00 00 00       	jmp    80105c2f <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105b6f:	e8 51 b4 ff ff       	call   80100fc5 <filealloc>
80105b74:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b7b:	74 17                	je     80105b94 <sys_open+0x100>
80105b7d:	83 ec 0c             	sub    $0xc,%esp
80105b80:	ff 75 f0             	push   -0x10(%ebp)
80105b83:	e8 33 f7 ff ff       	call   801052bb <fdalloc>
80105b88:	83 c4 10             	add    $0x10,%esp
80105b8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105b8e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105b92:	79 2e                	jns    80105bc2 <sys_open+0x12e>
    if(f)
80105b94:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b98:	74 0e                	je     80105ba8 <sys_open+0x114>
      fileclose(f);
80105b9a:	83 ec 0c             	sub    $0xc,%esp
80105b9d:	ff 75 f0             	push   -0x10(%ebp)
80105ba0:	e8 de b4 ff ff       	call   80101083 <fileclose>
80105ba5:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105ba8:	83 ec 0c             	sub    $0xc,%esp
80105bab:	ff 75 f4             	push   -0xc(%ebp)
80105bae:	e8 50 c0 ff ff       	call   80101c03 <iunlockput>
80105bb3:	83 c4 10             	add    $0x10,%esp
    end_op();
80105bb6:	e8 f5 d4 ff ff       	call   801030b0 <end_op>
    return -1;
80105bbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bc0:	eb 6d                	jmp    80105c2f <sys_open+0x19b>
  }
  iunlock(ip);
80105bc2:	83 ec 0c             	sub    $0xc,%esp
80105bc5:	ff 75 f4             	push   -0xc(%ebp)
80105bc8:	e8 18 bf ff ff       	call   80101ae5 <iunlock>
80105bcd:	83 c4 10             	add    $0x10,%esp
  end_op();
80105bd0:	e8 db d4 ff ff       	call   801030b0 <end_op>

  f->type = FD_INODE;
80105bd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd8:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105be1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105be4:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105be7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bea:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105bf1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bf4:	83 e0 01             	and    $0x1,%eax
80105bf7:	85 c0                	test   %eax,%eax
80105bf9:	0f 94 c0             	sete   %al
80105bfc:	89 c2                	mov    %eax,%edx
80105bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c01:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105c04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c07:	83 e0 01             	and    $0x1,%eax
80105c0a:	85 c0                	test   %eax,%eax
80105c0c:	75 0a                	jne    80105c18 <sys_open+0x184>
80105c0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c11:	83 e0 02             	and    $0x2,%eax
80105c14:	85 c0                	test   %eax,%eax
80105c16:	74 07                	je     80105c1f <sys_open+0x18b>
80105c18:	b8 01 00 00 00       	mov    $0x1,%eax
80105c1d:	eb 05                	jmp    80105c24 <sys_open+0x190>
80105c1f:	b8 00 00 00 00       	mov    $0x0,%eax
80105c24:	89 c2                	mov    %eax,%edx
80105c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c29:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105c2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105c2f:	c9                   	leave  
80105c30:	c3                   	ret    

80105c31 <sys_mkdir>:

int
sys_mkdir(void)
{
80105c31:	55                   	push   %ebp
80105c32:	89 e5                	mov    %esp,%ebp
80105c34:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105c37:	e8 e8 d3 ff ff       	call   80103024 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105c3c:	83 ec 08             	sub    $0x8,%esp
80105c3f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c42:	50                   	push   %eax
80105c43:	6a 00                	push   $0x0
80105c45:	e8 48 f5 ff ff       	call   80105192 <argstr>
80105c4a:	83 c4 10             	add    $0x10,%esp
80105c4d:	85 c0                	test   %eax,%eax
80105c4f:	78 1b                	js     80105c6c <sys_mkdir+0x3b>
80105c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c54:	6a 00                	push   $0x0
80105c56:	6a 00                	push   $0x0
80105c58:	6a 01                	push   $0x1
80105c5a:	50                   	push   %eax
80105c5b:	e8 62 fc ff ff       	call   801058c2 <create>
80105c60:	83 c4 10             	add    $0x10,%esp
80105c63:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c66:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c6a:	75 0c                	jne    80105c78 <sys_mkdir+0x47>
    end_op();
80105c6c:	e8 3f d4 ff ff       	call   801030b0 <end_op>
    return -1;
80105c71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c76:	eb 18                	jmp    80105c90 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105c78:	83 ec 0c             	sub    $0xc,%esp
80105c7b:	ff 75 f4             	push   -0xc(%ebp)
80105c7e:	e8 80 bf ff ff       	call   80101c03 <iunlockput>
80105c83:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c86:	e8 25 d4 ff ff       	call   801030b0 <end_op>
  return 0;
80105c8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c90:	c9                   	leave  
80105c91:	c3                   	ret    

80105c92 <sys_mknod>:

int
sys_mknod(void)
{
80105c92:	55                   	push   %ebp
80105c93:	89 e5                	mov    %esp,%ebp
80105c95:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105c98:	e8 87 d3 ff ff       	call   80103024 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105c9d:	83 ec 08             	sub    $0x8,%esp
80105ca0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ca3:	50                   	push   %eax
80105ca4:	6a 00                	push   $0x0
80105ca6:	e8 e7 f4 ff ff       	call   80105192 <argstr>
80105cab:	83 c4 10             	add    $0x10,%esp
80105cae:	85 c0                	test   %eax,%eax
80105cb0:	78 4f                	js     80105d01 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105cb2:	83 ec 08             	sub    $0x8,%esp
80105cb5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cb8:	50                   	push   %eax
80105cb9:	6a 01                	push   $0x1
80105cbb:	e8 4c f4 ff ff       	call   8010510c <argint>
80105cc0:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105cc3:	85 c0                	test   %eax,%eax
80105cc5:	78 3a                	js     80105d01 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105cc7:	83 ec 08             	sub    $0x8,%esp
80105cca:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ccd:	50                   	push   %eax
80105cce:	6a 02                	push   $0x2
80105cd0:	e8 37 f4 ff ff       	call   8010510c <argint>
80105cd5:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105cd8:	85 c0                	test   %eax,%eax
80105cda:	78 25                	js     80105d01 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105cdc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105cdf:	0f bf c8             	movswl %ax,%ecx
80105ce2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ce5:	0f bf d0             	movswl %ax,%edx
80105ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ceb:	51                   	push   %ecx
80105cec:	52                   	push   %edx
80105ced:	6a 03                	push   $0x3
80105cef:	50                   	push   %eax
80105cf0:	e8 cd fb ff ff       	call   801058c2 <create>
80105cf5:	83 c4 10             	add    $0x10,%esp
80105cf8:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105cfb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cff:	75 0c                	jne    80105d0d <sys_mknod+0x7b>
    end_op();
80105d01:	e8 aa d3 ff ff       	call   801030b0 <end_op>
    return -1;
80105d06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d0b:	eb 18                	jmp    80105d25 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105d0d:	83 ec 0c             	sub    $0xc,%esp
80105d10:	ff 75 f4             	push   -0xc(%ebp)
80105d13:	e8 eb be ff ff       	call   80101c03 <iunlockput>
80105d18:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d1b:	e8 90 d3 ff ff       	call   801030b0 <end_op>
  return 0;
80105d20:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d25:	c9                   	leave  
80105d26:	c3                   	ret    

80105d27 <sys_chdir>:

int
sys_chdir(void)
{
80105d27:	55                   	push   %ebp
80105d28:	89 e5                	mov    %esp,%ebp
80105d2a:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105d2d:	e8 e6 dc ff ff       	call   80103a18 <myproc>
80105d32:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105d35:	e8 ea d2 ff ff       	call   80103024 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105d3a:	83 ec 08             	sub    $0x8,%esp
80105d3d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d40:	50                   	push   %eax
80105d41:	6a 00                	push   $0x0
80105d43:	e8 4a f4 ff ff       	call   80105192 <argstr>
80105d48:	83 c4 10             	add    $0x10,%esp
80105d4b:	85 c0                	test   %eax,%eax
80105d4d:	78 18                	js     80105d67 <sys_chdir+0x40>
80105d4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d52:	83 ec 0c             	sub    $0xc,%esp
80105d55:	50                   	push   %eax
80105d56:	e8 aa c7 ff ff       	call   80102505 <namei>
80105d5b:	83 c4 10             	add    $0x10,%esp
80105d5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d65:	75 0c                	jne    80105d73 <sys_chdir+0x4c>
    end_op();
80105d67:	e8 44 d3 ff ff       	call   801030b0 <end_op>
    return -1;
80105d6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d71:	eb 68                	jmp    80105ddb <sys_chdir+0xb4>
  }
  ilock(ip);
80105d73:	83 ec 0c             	sub    $0xc,%esp
80105d76:	ff 75 f0             	push   -0x10(%ebp)
80105d79:	e8 54 bc ff ff       	call   801019d2 <ilock>
80105d7e:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105d81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d84:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d88:	66 83 f8 01          	cmp    $0x1,%ax
80105d8c:	74 1a                	je     80105da8 <sys_chdir+0x81>
    iunlockput(ip);
80105d8e:	83 ec 0c             	sub    $0xc,%esp
80105d91:	ff 75 f0             	push   -0x10(%ebp)
80105d94:	e8 6a be ff ff       	call   80101c03 <iunlockput>
80105d99:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d9c:	e8 0f d3 ff ff       	call   801030b0 <end_op>
    return -1;
80105da1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da6:	eb 33                	jmp    80105ddb <sys_chdir+0xb4>
  }
  iunlock(ip);
80105da8:	83 ec 0c             	sub    $0xc,%esp
80105dab:	ff 75 f0             	push   -0x10(%ebp)
80105dae:	e8 32 bd ff ff       	call   80101ae5 <iunlock>
80105db3:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db9:	8b 40 68             	mov    0x68(%eax),%eax
80105dbc:	83 ec 0c             	sub    $0xc,%esp
80105dbf:	50                   	push   %eax
80105dc0:	e8 6e bd ff ff       	call   80101b33 <iput>
80105dc5:	83 c4 10             	add    $0x10,%esp
  end_op();
80105dc8:	e8 e3 d2 ff ff       	call   801030b0 <end_op>
  curproc->cwd = ip;
80105dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105dd3:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105dd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ddb:	c9                   	leave  
80105ddc:	c3                   	ret    

80105ddd <sys_exec>:

int
sys_exec(void)
{
80105ddd:	55                   	push   %ebp
80105dde:	89 e5                	mov    %esp,%ebp
80105de0:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105de6:	83 ec 08             	sub    $0x8,%esp
80105de9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105dec:	50                   	push   %eax
80105ded:	6a 00                	push   $0x0
80105def:	e8 9e f3 ff ff       	call   80105192 <argstr>
80105df4:	83 c4 10             	add    $0x10,%esp
80105df7:	85 c0                	test   %eax,%eax
80105df9:	78 18                	js     80105e13 <sys_exec+0x36>
80105dfb:	83 ec 08             	sub    $0x8,%esp
80105dfe:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105e04:	50                   	push   %eax
80105e05:	6a 01                	push   $0x1
80105e07:	e8 00 f3 ff ff       	call   8010510c <argint>
80105e0c:	83 c4 10             	add    $0x10,%esp
80105e0f:	85 c0                	test   %eax,%eax
80105e11:	79 0a                	jns    80105e1d <sys_exec+0x40>
    return -1;
80105e13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e18:	e9 c6 00 00 00       	jmp    80105ee3 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105e1d:	83 ec 04             	sub    $0x4,%esp
80105e20:	68 80 00 00 00       	push   $0x80
80105e25:	6a 00                	push   $0x0
80105e27:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e2d:	50                   	push   %eax
80105e2e:	e8 ca ef ff ff       	call   80104dfd <memset>
80105e33:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105e36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e40:	83 f8 1f             	cmp    $0x1f,%eax
80105e43:	76 0a                	jbe    80105e4f <sys_exec+0x72>
      return -1;
80105e45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e4a:	e9 94 00 00 00       	jmp    80105ee3 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e52:	c1 e0 02             	shl    $0x2,%eax
80105e55:	89 c2                	mov    %eax,%edx
80105e57:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105e5d:	01 c2                	add    %eax,%edx
80105e5f:	83 ec 08             	sub    $0x8,%esp
80105e62:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105e68:	50                   	push   %eax
80105e69:	52                   	push   %edx
80105e6a:	e8 18 f2 ff ff       	call   80105087 <fetchint>
80105e6f:	83 c4 10             	add    $0x10,%esp
80105e72:	85 c0                	test   %eax,%eax
80105e74:	79 07                	jns    80105e7d <sys_exec+0xa0>
      return -1;
80105e76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e7b:	eb 66                	jmp    80105ee3 <sys_exec+0x106>
    if(uarg == 0){
80105e7d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e83:	85 c0                	test   %eax,%eax
80105e85:	75 27                	jne    80105eae <sys_exec+0xd1>
      argv[i] = 0;
80105e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8a:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105e91:	00 00 00 00 
      break;
80105e95:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105e96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e99:	83 ec 08             	sub    $0x8,%esp
80105e9c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105ea2:	52                   	push   %edx
80105ea3:	50                   	push   %eax
80105ea4:	e8 d7 ac ff ff       	call   80100b80 <exec>
80105ea9:	83 c4 10             	add    $0x10,%esp
80105eac:	eb 35                	jmp    80105ee3 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105eae:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb7:	c1 e0 02             	shl    $0x2,%eax
80105eba:	01 c2                	add    %eax,%edx
80105ebc:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105ec2:	83 ec 08             	sub    $0x8,%esp
80105ec5:	52                   	push   %edx
80105ec6:	50                   	push   %eax
80105ec7:	e8 ea f1 ff ff       	call   801050b6 <fetchstr>
80105ecc:	83 c4 10             	add    $0x10,%esp
80105ecf:	85 c0                	test   %eax,%eax
80105ed1:	79 07                	jns    80105eda <sys_exec+0xfd>
      return -1;
80105ed3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed8:	eb 09                	jmp    80105ee3 <sys_exec+0x106>
  for(i=0;; i++){
80105eda:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ede:	e9 5a ff ff ff       	jmp    80105e3d <sys_exec+0x60>
}
80105ee3:	c9                   	leave  
80105ee4:	c3                   	ret    

80105ee5 <sys_pipe>:

int
sys_pipe(void)
{
80105ee5:	55                   	push   %ebp
80105ee6:	89 e5                	mov    %esp,%ebp
80105ee8:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105eeb:	83 ec 04             	sub    $0x4,%esp
80105eee:	6a 08                	push   $0x8
80105ef0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ef3:	50                   	push   %eax
80105ef4:	6a 00                	push   $0x0
80105ef6:	e8 3e f2 ff ff       	call   80105139 <argptr>
80105efb:	83 c4 10             	add    $0x10,%esp
80105efe:	85 c0                	test   %eax,%eax
80105f00:	79 0a                	jns    80105f0c <sys_pipe+0x27>
    return -1;
80105f02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f07:	e9 ae 00 00 00       	jmp    80105fba <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105f0c:	83 ec 08             	sub    $0x8,%esp
80105f0f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f12:	50                   	push   %eax
80105f13:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f16:	50                   	push   %eax
80105f17:	e8 39 d6 ff ff       	call   80103555 <pipealloc>
80105f1c:	83 c4 10             	add    $0x10,%esp
80105f1f:	85 c0                	test   %eax,%eax
80105f21:	79 0a                	jns    80105f2d <sys_pipe+0x48>
    return -1;
80105f23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f28:	e9 8d 00 00 00       	jmp    80105fba <sys_pipe+0xd5>
  fd0 = -1;
80105f2d:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105f34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f37:	83 ec 0c             	sub    $0xc,%esp
80105f3a:	50                   	push   %eax
80105f3b:	e8 7b f3 ff ff       	call   801052bb <fdalloc>
80105f40:	83 c4 10             	add    $0x10,%esp
80105f43:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f46:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f4a:	78 18                	js     80105f64 <sys_pipe+0x7f>
80105f4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f4f:	83 ec 0c             	sub    $0xc,%esp
80105f52:	50                   	push   %eax
80105f53:	e8 63 f3 ff ff       	call   801052bb <fdalloc>
80105f58:	83 c4 10             	add    $0x10,%esp
80105f5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f5e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f62:	79 3e                	jns    80105fa2 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105f64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f68:	78 13                	js     80105f7d <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105f6a:	e8 a9 da ff ff       	call   80103a18 <myproc>
80105f6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f72:	83 c2 08             	add    $0x8,%edx
80105f75:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105f7c:	00 
    fileclose(rf);
80105f7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f80:	83 ec 0c             	sub    $0xc,%esp
80105f83:	50                   	push   %eax
80105f84:	e8 fa b0 ff ff       	call   80101083 <fileclose>
80105f89:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105f8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f8f:	83 ec 0c             	sub    $0xc,%esp
80105f92:	50                   	push   %eax
80105f93:	e8 eb b0 ff ff       	call   80101083 <fileclose>
80105f98:	83 c4 10             	add    $0x10,%esp
    return -1;
80105f9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa0:	eb 18                	jmp    80105fba <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105fa2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fa5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fa8:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105faa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fad:	8d 50 04             	lea    0x4(%eax),%edx
80105fb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb3:	89 02                	mov    %eax,(%edx)
  return 0;
80105fb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fba:	c9                   	leave  
80105fbb:	c3                   	ret    

80105fbc <sys_fork>:
  struct proc proc[NPROC];
} ptable;

int
sys_fork(void)
{
80105fbc:	55                   	push   %ebp
80105fbd:	89 e5                	mov    %esp,%ebp
80105fbf:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105fc2:	e8 25 de ff ff       	call   80103dec <fork>
}
80105fc7:	c9                   	leave  
80105fc8:	c3                   	ret    

80105fc9 <sys_exit>:

int
sys_exit(void)
{
80105fc9:	55                   	push   %ebp
80105fca:	89 e5                	mov    %esp,%ebp
80105fcc:	83 ec 08             	sub    $0x8,%esp
  exit();
80105fcf:	e8 91 df ff ff       	call   80103f65 <exit>
  return 0;  // not reached
80105fd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fd9:	c9                   	leave  
80105fda:	c3                   	ret    

80105fdb <sys_wait>:

int
sys_wait(void)
{
80105fdb:	55                   	push   %ebp
80105fdc:	89 e5                	mov    %esp,%ebp
80105fde:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105fe1:	e8 e3 e0 ff ff       	call   801040c9 <wait>
}
80105fe6:	c9                   	leave  
80105fe7:	c3                   	ret    

80105fe8 <sys_kill>:

int
sys_kill(void)
{
80105fe8:	55                   	push   %ebp
80105fe9:	89 e5                	mov    %esp,%ebp
80105feb:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105fee:	83 ec 08             	sub    $0x8,%esp
80105ff1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ff4:	50                   	push   %eax
80105ff5:	6a 00                	push   $0x0
80105ff7:	e8 10 f1 ff ff       	call   8010510c <argint>
80105ffc:	83 c4 10             	add    $0x10,%esp
80105fff:	85 c0                	test   %eax,%eax
80106001:	79 07                	jns    8010600a <sys_kill+0x22>
    return -1;
80106003:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106008:	eb 0f                	jmp    80106019 <sys_kill+0x31>
  return kill(pid);
8010600a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600d:	83 ec 0c             	sub    $0xc,%esp
80106010:	50                   	push   %eax
80106011:	e8 38 e8 ff ff       	call   8010484e <kill>
80106016:	83 c4 10             	add    $0x10,%esp
}
80106019:	c9                   	leave  
8010601a:	c3                   	ret    

8010601b <sys_getpid>:

int
sys_getpid(void)
{
8010601b:	55                   	push   %ebp
8010601c:	89 e5                	mov    %esp,%ebp
8010601e:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106021:	e8 f2 d9 ff ff       	call   80103a18 <myproc>
80106026:	8b 40 10             	mov    0x10(%eax),%eax
}
80106029:	c9                   	leave  
8010602a:	c3                   	ret    

8010602b <sys_sbrk>:

int
sys_sbrk(void)
{
8010602b:	55                   	push   %ebp
8010602c:	89 e5                	mov    %esp,%ebp
8010602e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106031:	83 ec 08             	sub    $0x8,%esp
80106034:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106037:	50                   	push   %eax
80106038:	6a 00                	push   $0x0
8010603a:	e8 cd f0 ff ff       	call   8010510c <argint>
8010603f:	83 c4 10             	add    $0x10,%esp
80106042:	85 c0                	test   %eax,%eax
80106044:	79 07                	jns    8010604d <sys_sbrk+0x22>
    return -1;
80106046:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010604b:	eb 27                	jmp    80106074 <sys_sbrk+0x49>
  addr = myproc()->sz;
8010604d:	e8 c6 d9 ff ff       	call   80103a18 <myproc>
80106052:	8b 00                	mov    (%eax),%eax
80106054:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106057:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605a:	83 ec 0c             	sub    $0xc,%esp
8010605d:	50                   	push   %eax
8010605e:	e8 14 dd ff ff       	call   80103d77 <growproc>
80106063:	83 c4 10             	add    $0x10,%esp
80106066:	85 c0                	test   %eax,%eax
80106068:	79 07                	jns    80106071 <sys_sbrk+0x46>
    return -1;
8010606a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010606f:	eb 03                	jmp    80106074 <sys_sbrk+0x49>
  return addr;
80106071:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106074:	c9                   	leave  
80106075:	c3                   	ret    

80106076 <sys_sleep>:

int
sys_sleep(void)
{
80106076:	55                   	push   %ebp
80106077:	89 e5                	mov    %esp,%ebp
80106079:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010607c:	83 ec 08             	sub    $0x8,%esp
8010607f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106082:	50                   	push   %eax
80106083:	6a 00                	push   $0x0
80106085:	e8 82 f0 ff ff       	call   8010510c <argint>
8010608a:	83 c4 10             	add    $0x10,%esp
8010608d:	85 c0                	test   %eax,%eax
8010608f:	79 07                	jns    80106098 <sys_sleep+0x22>
    return -1;
80106091:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106096:	eb 76                	jmp    8010610e <sys_sleep+0x98>
  acquire(&tickslock);
80106098:	83 ec 0c             	sub    $0xc,%esp
8010609b:	68 40 e4 30 80       	push   $0x8030e440
801060a0:	e8 e2 ea ff ff       	call   80104b87 <acquire>
801060a5:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801060a8:	a1 74 e4 30 80       	mov    0x8030e474,%eax
801060ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801060b0:	eb 38                	jmp    801060ea <sys_sleep+0x74>
    if(myproc()->killed){
801060b2:	e8 61 d9 ff ff       	call   80103a18 <myproc>
801060b7:	8b 40 24             	mov    0x24(%eax),%eax
801060ba:	85 c0                	test   %eax,%eax
801060bc:	74 17                	je     801060d5 <sys_sleep+0x5f>
      release(&tickslock);
801060be:	83 ec 0c             	sub    $0xc,%esp
801060c1:	68 40 e4 30 80       	push   $0x8030e440
801060c6:	e8 2a eb ff ff       	call   80104bf5 <release>
801060cb:	83 c4 10             	add    $0x10,%esp
      return -1;
801060ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d3:	eb 39                	jmp    8010610e <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
801060d5:	83 ec 08             	sub    $0x8,%esp
801060d8:	68 40 e4 30 80       	push   $0x8030e440
801060dd:	68 74 e4 30 80       	push   $0x8030e474
801060e2:	e8 46 e6 ff ff       	call   8010472d <sleep>
801060e7:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801060ea:	a1 74 e4 30 80       	mov    0x8030e474,%eax
801060ef:	2b 45 f4             	sub    -0xc(%ebp),%eax
801060f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060f5:	39 d0                	cmp    %edx,%eax
801060f7:	72 b9                	jb     801060b2 <sys_sleep+0x3c>
  }
  release(&tickslock);
801060f9:	83 ec 0c             	sub    $0xc,%esp
801060fc:	68 40 e4 30 80       	push   $0x8030e440
80106101:	e8 ef ea ff ff       	call   80104bf5 <release>
80106106:	83 c4 10             	add    $0x10,%esp
  return 0;
80106109:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010610e:	c9                   	leave  
8010610f:	c3                   	ret    

80106110 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106110:	55                   	push   %ebp
80106111:	89 e5                	mov    %esp,%ebp
80106113:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106116:	83 ec 0c             	sub    $0xc,%esp
80106119:	68 40 e4 30 80       	push   $0x8030e440
8010611e:	e8 64 ea ff ff       	call   80104b87 <acquire>
80106123:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106126:	a1 74 e4 30 80       	mov    0x8030e474,%eax
8010612b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010612e:	83 ec 0c             	sub    $0xc,%esp
80106131:	68 40 e4 30 80       	push   $0x8030e440
80106136:	e8 ba ea ff ff       	call   80104bf5 <release>
8010613b:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010613e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106141:	c9                   	leave  
80106142:	c3                   	ret    

80106143 <sys_uthread_init>:

// 이거 추가
int
sys_uthread_init(void)
{
80106143:	55                   	push   %ebp
80106144:	89 e5                	mov    %esp,%ebp
80106146:	53                   	push   %ebx
80106147:	83 ec 14             	sub    $0x14,%esp
  int addr;
  if (argint(0, &addr) < 0)
8010614a:	83 ec 08             	sub    $0x8,%esp
8010614d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106150:	50                   	push   %eax
80106151:	6a 00                	push   $0x0
80106153:	e8 b4 ef ff ff       	call   8010510c <argint>
80106158:	83 c4 10             	add    $0x10,%esp
8010615b:	85 c0                	test   %eax,%eax
8010615d:	79 07                	jns    80106166 <sys_uthread_init+0x23>
    return -1;
8010615f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106164:	eb 12                	jmp    80106178 <sys_uthread_init+0x35>
  myproc()->scheduler = addr;
80106166:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80106169:	e8 aa d8 ff ff       	call   80103a18 <myproc>
8010616e:	89 da                	mov    %ebx,%edx
80106170:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
80106173:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106178:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010617b:	c9                   	leave  
8010617c:	c3                   	ret    

8010617d <sys_check_thread>:



int
sys_check_thread(void) {
8010617d:	55                   	push   %ebp
8010617e:	89 e5                	mov    %esp,%ebp
80106180:	83 ec 18             	sub    $0x18,%esp
  int op;
  if (argint(0, &op) < 0)  // 사용자로부터 인자 하나 받음
80106183:	83 ec 08             	sub    $0x8,%esp
80106186:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106189:	50                   	push   %eax
8010618a:	6a 00                	push   $0x0
8010618c:	e8 7b ef ff ff       	call   8010510c <argint>
80106191:	83 c4 10             	add    $0x10,%esp
80106194:	85 c0                	test   %eax,%eax
80106196:	79 07                	jns    8010619f <sys_check_thread+0x22>
    return -1;
80106198:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010619d:	eb 24                	jmp    801061c3 <sys_check_thread+0x46>

  struct proc* p = myproc();
8010619f:	e8 74 d8 ff ff       	call   80103a18 <myproc>
801061a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p->check_thread += op;  // +1 또는 -1
801061a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061aa:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801061b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b3:	01 c2                	add    %eax,%edx
801061b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061b8:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  return 0;
801061be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061c3:	c9                   	leave  
801061c4:	c3                   	ret    

801061c5 <sys_getpinfo>:


int
sys_getpinfo(void) {
801061c5:	55                   	push   %ebp
801061c6:	89 e5                	mov    %esp,%ebp
801061c8:	53                   	push   %ebx
801061c9:	83 ec 14             	sub    $0x14,%esp
  struct pstat *ps;
  if (argptr(0, (void *)&ps, sizeof(*ps)) < 0)
801061cc:	83 ec 04             	sub    $0x4,%esp
801061cf:	68 00 0c 00 00       	push   $0xc00
801061d4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061d7:	50                   	push   %eax
801061d8:	6a 00                	push   $0x0
801061da:	e8 5a ef ff ff       	call   80105139 <argptr>
801061df:	83 c4 10             	add    $0x10,%esp
801061e2:	85 c0                	test   %eax,%eax
801061e4:	79 0a                	jns    801061f0 <sys_getpinfo+0x2b>
    return -1;
801061e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061eb:	e9 21 01 00 00       	jmp    80106311 <sys_getpinfo+0x14c>

  acquire(&ptable.lock);
801061f0:	83 ec 0c             	sub    $0xc,%esp
801061f3:	68 00 bb 30 80       	push   $0x8030bb00
801061f8:	e8 8a e9 ff ff       	call   80104b87 <acquire>
801061fd:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
80106200:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106207:	e9 e6 00 00 00       	jmp    801062f2 <sys_getpinfo+0x12d>
    struct proc *p = &ptable.proc[i];
8010620c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620f:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
80106215:	83 c0 30             	add    $0x30,%eax
80106218:	05 00 bb 30 80       	add    $0x8030bb00,%eax
8010621d:	83 c0 04             	add    $0x4,%eax
80106220:	89 45 ec             	mov    %eax,-0x14(%ebp)
    ps->inuse[i] = (p->state != UNUSED);
80106223:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106226:	8b 40 0c             	mov    0xc(%eax),%eax
80106229:	85 c0                	test   %eax,%eax
8010622b:	0f 95 c2             	setne  %dl
8010622e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106231:	0f b6 ca             	movzbl %dl,%ecx
80106234:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106237:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    ps->pid[i] = p->pid;
8010623a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010623d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106240:	8b 52 10             	mov    0x10(%edx),%edx
80106243:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80106246:	83 c1 40             	add    $0x40,%ecx
80106249:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->priority[i] = proc_priority[i];
8010624c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010624f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106252:	8b 14 95 00 b2 30 80 	mov    -0x7fcf4e00(,%edx,4),%edx
80106259:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010625c:	83 e9 80             	sub    $0xffffff80,%ecx
8010625f:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->state[i] = p->state;
80106262:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106265:	8b 50 0c             	mov    0xc(%eax),%edx
80106268:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010626b:	89 d1                	mov    %edx,%ecx
8010626d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106270:	81 c2 c0 00 00 00    	add    $0xc0,%edx
80106276:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    for (int j = 0; j < 4; j++) {
80106279:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106280:	eb 66                	jmp    801062e8 <sys_getpinfo+0x123>
      ps->ticks[i][j] = proc_ticks[i][j];
80106282:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106285:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106288:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
8010628f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106292:	01 ca                	add    %ecx,%edx
80106294:	8b 14 95 00 b3 30 80 	mov    -0x7fcf4d00(,%edx,4),%edx
8010629b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010629e:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
801062a5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801062a8:	01 d9                	add    %ebx,%ecx
801062aa:	81 c1 00 01 00 00    	add    $0x100,%ecx
801062b0:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = proc_wait_ticks[i][j];
801062b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062b9:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
801062c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062c3:	01 ca                	add    %ecx,%edx
801062c5:	8b 14 95 00 b7 30 80 	mov    -0x7fcf4900(,%edx,4),%edx
801062cc:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801062cf:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
801062d6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801062d9:	01 d9                	add    %ebx,%ecx
801062db:	81 c1 00 02 00 00    	add    $0x200,%ecx
801062e1:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
801062e4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801062e8:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
801062ec:	7e 94                	jle    80106282 <sys_getpinfo+0xbd>
  for (int i = 0; i < NPROC; i++) {
801062ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801062f2:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801062f6:	0f 8e 10 ff ff ff    	jle    8010620c <sys_getpinfo+0x47>
    }
  }
  release(&ptable.lock);
801062fc:	83 ec 0c             	sub    $0xc,%esp
801062ff:	68 00 bb 30 80       	push   $0x8030bb00
80106304:	e8 ec e8 ff ff       	call   80104bf5 <release>
80106309:	83 c4 10             	add    $0x10,%esp
  return 0;
8010630c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106311:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106314:	c9                   	leave  
80106315:	c3                   	ret    

80106316 <sys_setSchedPolicy>:


int
sys_setSchedPolicy(void) {
80106316:	55                   	push   %ebp
80106317:	89 e5                	mov    %esp,%ebp
80106319:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
8010631c:	83 ec 08             	sub    $0x8,%esp
8010631f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106322:	50                   	push   %eax
80106323:	6a 00                	push   $0x0
80106325:	e8 e2 ed ff ff       	call   8010510c <argint>
8010632a:	83 c4 10             	add    $0x10,%esp
8010632d:	85 c0                	test   %eax,%eax
8010632f:	79 07                	jns    80106338 <sys_setSchedPolicy+0x22>
    return -1;
80106331:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106336:	eb 31                	jmp    80106369 <sys_setSchedPolicy+0x53>
  
  pushcli();
80106338:	e8 b5 e9 ff ff       	call   80104cf2 <pushcli>
  mycpu()->sched_policy = policy;
8010633d:	e8 5e d6 ff ff       	call   801039a0 <mycpu>
80106342:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106345:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
8010634b:	e8 ef e9 ff ff       	call   80104d3f <popcli>

  cprintf("✅ sched_policy set to %d\n", policy);
80106350:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106353:	83 ec 08             	sub    $0x8,%esp
80106356:	50                   	push   %eax
80106357:	68 b4 ad 10 80       	push   $0x8010adb4
8010635c:	e8 93 a0 ff ff       	call   801003f4 <cprintf>
80106361:	83 c4 10             	add    $0x10,%esp
  return 0;
80106364:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106369:	c9                   	leave  
8010636a:	c3                   	ret    

8010636b <sys_yield>:

int
sys_yield(void)
{
8010636b:	55                   	push   %ebp
8010636c:	89 e5                	mov    %esp,%ebp
8010636e:	83 ec 08             	sub    $0x8,%esp
  yield();
80106371:	e8 f6 e2 ff ff       	call   8010466c <yield>
  return 0;
80106376:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010637b:	c9                   	leave  
8010637c:	c3                   	ret    

8010637d <print_user_page_table>:

void print_user_page_table(struct proc *p) {
8010637d:	55                   	push   %ebp
8010637e:	89 e5                	mov    %esp,%ebp
80106380:	83 ec 28             	sub    $0x28,%esp
  cprintf("START PAGE TABLE (pid %d)\n", p->pid);
80106383:	8b 45 08             	mov    0x8(%ebp),%eax
80106386:	8b 40 10             	mov    0x10(%eax),%eax
80106389:	83 ec 08             	sub    $0x8,%esp
8010638c:	50                   	push   %eax
8010638d:	68 d0 ad 10 80       	push   $0x8010add0
80106392:	e8 5d a0 ff ff       	call   801003f4 <cprintf>
80106397:	83 c4 10             	add    $0x10,%esp
  pde_t *pgdir = p->pgdir;
8010639a:	8b 45 08             	mov    0x8(%ebp),%eax
8010639d:	8b 40 04             	mov    0x4(%eax),%eax
801063a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(uint va = 0; va < KERNBASE; va += PGSIZE) {
801063a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801063aa:	e9 a7 00 00 00       	jmp    80106456 <print_user_page_table+0xd9>
    pte_t *pte = walkpgdir(pgdir, (void*)va, 0);
801063af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b2:	83 ec 04             	sub    $0x4,%esp
801063b5:	6a 00                	push   $0x0
801063b7:	50                   	push   %eax
801063b8:	ff 75 f0             	push   -0x10(%ebp)
801063bb:	e8 da 16 00 00       	call   80107a9a <walkpgdir>
801063c0:	83 c4 10             	add    $0x10,%esp
801063c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(!pte) continue;
801063c6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801063ca:	74 7f                	je     8010644b <print_user_page_table+0xce>
    if(!(*pte & PTE_P)) continue;
801063cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063cf:	8b 00                	mov    (%eax),%eax
801063d1:	83 e0 01             	and    $0x1,%eax
801063d4:	85 c0                	test   %eax,%eax
801063d6:	74 76                	je     8010644e <print_user_page_table+0xd1>
    uint vpn = va / PGSIZE;
801063d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063db:	c1 e8 0c             	shr    $0xc,%eax
801063de:	89 45 e8             	mov    %eax,-0x18(%ebp)
    char *uork = (*pte & PTE_U) ? "U" : "K";
801063e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063e4:	8b 00                	mov    (%eax),%eax
801063e6:	83 e0 04             	and    $0x4,%eax
801063e9:	85 c0                	test   %eax,%eax
801063eb:	74 07                	je     801063f4 <print_user_page_table+0x77>
801063ed:	b8 eb ad 10 80       	mov    $0x8010adeb,%eax
801063f2:	eb 05                	jmp    801063f9 <print_user_page_table+0x7c>
801063f4:	b8 ed ad 10 80       	mov    $0x8010aded,%eax
801063f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    char *w = (*pte & PTE_W) ? "W" : "-";
801063fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063ff:	8b 00                	mov    (%eax),%eax
80106401:	83 e0 02             	and    $0x2,%eax
80106404:	85 c0                	test   %eax,%eax
80106406:	74 07                	je     8010640f <print_user_page_table+0x92>
80106408:	b8 ef ad 10 80       	mov    $0x8010adef,%eax
8010640d:	eb 05                	jmp    80106414 <print_user_page_table+0x97>
8010640f:	b8 f1 ad 10 80       	mov    $0x8010adf1,%eax
80106414:	89 45 e0             	mov    %eax,-0x20(%ebp)
    uint pa = PTE_ADDR(*pte);
80106417:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010641a:	8b 00                	mov    (%eax),%eax
8010641c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106421:	89 45 dc             	mov    %eax,-0x24(%ebp)
    uint ppn = pa >> 12;
80106424:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106427:	c1 e8 0c             	shr    $0xc,%eax
8010642a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    cprintf("%x P %s %s %x\n", vpn, uork, w, ppn);
8010642d:	83 ec 0c             	sub    $0xc,%esp
80106430:	ff 75 d8             	push   -0x28(%ebp)
80106433:	ff 75 e0             	push   -0x20(%ebp)
80106436:	ff 75 e4             	push   -0x1c(%ebp)
80106439:	ff 75 e8             	push   -0x18(%ebp)
8010643c:	68 f3 ad 10 80       	push   $0x8010adf3
80106441:	e8 ae 9f ff ff       	call   801003f4 <cprintf>
80106446:	83 c4 20             	add    $0x20,%esp
80106449:	eb 04                	jmp    8010644f <print_user_page_table+0xd2>
    if(!pte) continue;
8010644b:	90                   	nop
8010644c:	eb 01                	jmp    8010644f <print_user_page_table+0xd2>
    if(!(*pte & PTE_P)) continue;
8010644e:	90                   	nop
  for(uint va = 0; va < KERNBASE; va += PGSIZE) {
8010644f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80106456:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106459:	85 c0                	test   %eax,%eax
8010645b:	0f 89 4e ff ff ff    	jns    801063af <print_user_page_table+0x32>
  }
  cprintf("END PAGE TABLE\n");
80106461:	83 ec 0c             	sub    $0xc,%esp
80106464:	68 02 ae 10 80       	push   $0x8010ae02
80106469:	e8 86 9f ff ff       	call   801003f4 <cprintf>
8010646e:	83 c4 10             	add    $0x10,%esp
}
80106471:	90                   	nop
80106472:	c9                   	leave  
80106473:	c3                   	ret    

80106474 <sys_printpt>:

int 
sys_printpt(void) {
80106474:	55                   	push   %ebp
80106475:	89 e5                	mov    %esp,%ebp
80106477:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if(argint(0, &pid) < 0)
8010647a:	83 ec 08             	sub    $0x8,%esp
8010647d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106480:	50                   	push   %eax
80106481:	6a 00                	push   $0x0
80106483:	e8 84 ec ff ff       	call   8010510c <argint>
80106488:	83 c4 10             	add    $0x10,%esp
8010648b:	85 c0                	test   %eax,%eax
8010648d:	79 07                	jns    80106496 <sys_printpt+0x22>
    return -1;
8010648f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106494:	eb 32                	jmp    801064c8 <sys_printpt+0x54>
  struct proc *p = find_proc_by_pid(pid);
80106496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106499:	83 ec 0c             	sub    $0xc,%esp
8010649c:	50                   	push   %eax
8010649d:	e8 30 e5 ff ff       	call   801049d2 <find_proc_by_pid>
801064a2:	83 c4 10             	add    $0x10,%esp
801064a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!p)
801064a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064ac:	75 07                	jne    801064b5 <sys_printpt+0x41>
    return -1;
801064ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064b3:	eb 13                	jmp    801064c8 <sys_printpt+0x54>
  print_user_page_table(p);
801064b5:	83 ec 0c             	sub    $0xc,%esp
801064b8:	ff 75 f4             	push   -0xc(%ebp)
801064bb:	e8 bd fe ff ff       	call   8010637d <print_user_page_table>
801064c0:	83 c4 10             	add    $0x10,%esp
  return 0;
801064c3:	b8 00 00 00 00       	mov    $0x0,%eax
801064c8:	c9                   	leave  
801064c9:	c3                   	ret    

801064ca <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801064ca:	1e                   	push   %ds
  pushl %es
801064cb:	06                   	push   %es
  pushl %fs
801064cc:	0f a0                	push   %fs
  pushl %gs
801064ce:	0f a8                	push   %gs
  pushal
801064d0:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801064d1:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801064d5:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801064d7:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801064d9:	54                   	push   %esp
  call trap
801064da:	e8 e3 01 00 00       	call   801066c2 <trap>
  addl $4, %esp
801064df:	83 c4 04             	add    $0x4,%esp

801064e2 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801064e2:	61                   	popa   
  popl %gs
801064e3:	0f a9                	pop    %gs
  popl %fs
801064e5:	0f a1                	pop    %fs
  popl %es
801064e7:	07                   	pop    %es
  popl %ds
801064e8:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801064e9:	83 c4 08             	add    $0x8,%esp
  iret
801064ec:	cf                   	iret   

801064ed <lidt>:
{
801064ed:	55                   	push   %ebp
801064ee:	89 e5                	mov    %esp,%ebp
801064f0:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801064f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801064f6:	83 e8 01             	sub    $0x1,%eax
801064f9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801064fd:	8b 45 08             	mov    0x8(%ebp),%eax
80106500:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106504:	8b 45 08             	mov    0x8(%ebp),%eax
80106507:	c1 e8 10             	shr    $0x10,%eax
8010650a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010650e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106511:	0f 01 18             	lidtl  (%eax)
}
80106514:	90                   	nop
80106515:	c9                   	leave  
80106516:	c3                   	ret    

80106517 <rcr2>:

static inline uint
rcr2(void)
{
80106517:	55                   	push   %ebp
80106518:	89 e5                	mov    %esp,%ebp
8010651a:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010651d:	0f 20 d0             	mov    %cr2,%eax
80106520:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106523:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106526:	c9                   	leave  
80106527:	c3                   	ret    

80106528 <lcr3>:

static inline void
lcr3(uint val)
{
80106528:	55                   	push   %ebp
80106529:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010652b:	8b 45 08             	mov    0x8(%ebp),%eax
8010652e:	0f 22 d8             	mov    %eax,%cr3
}
80106531:	90                   	nop
80106532:	5d                   	pop    %ebp
80106533:	c3                   	ret    

80106534 <tvinit>:

pte_t *walkpgdir(pde_t *pgdir, const void *va, int alloc);
int mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm);

void tvinit(void)
{
80106534:	55                   	push   %ebp
80106535:	89 e5                	mov    %esp,%ebp
80106537:	83 ec 18             	sub    $0x18,%esp
  int i;

  for (i = 0; i < 256; i++)
8010653a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106541:	e9 c3 00 00 00       	jmp    80106609 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
80106546:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106549:	8b 04 85 90 f0 10 80 	mov    -0x7fef0f70(,%eax,4),%eax
80106550:	89 c2                	mov    %eax,%edx
80106552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106555:	66 89 14 c5 40 dc 30 	mov    %dx,-0x7fcf23c0(,%eax,8)
8010655c:	80 
8010655d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106560:	66 c7 04 c5 42 dc 30 	movw   $0x8,-0x7fcf23be(,%eax,8)
80106567:	80 08 00 
8010656a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010656d:	0f b6 14 c5 44 dc 30 	movzbl -0x7fcf23bc(,%eax,8),%edx
80106574:	80 
80106575:	83 e2 e0             	and    $0xffffffe0,%edx
80106578:	88 14 c5 44 dc 30 80 	mov    %dl,-0x7fcf23bc(,%eax,8)
8010657f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106582:	0f b6 14 c5 44 dc 30 	movzbl -0x7fcf23bc(,%eax,8),%edx
80106589:	80 
8010658a:	83 e2 1f             	and    $0x1f,%edx
8010658d:	88 14 c5 44 dc 30 80 	mov    %dl,-0x7fcf23bc(,%eax,8)
80106594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106597:	0f b6 14 c5 45 dc 30 	movzbl -0x7fcf23bb(,%eax,8),%edx
8010659e:	80 
8010659f:	83 e2 f0             	and    $0xfffffff0,%edx
801065a2:	83 ca 0e             	or     $0xe,%edx
801065a5:	88 14 c5 45 dc 30 80 	mov    %dl,-0x7fcf23bb(,%eax,8)
801065ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065af:	0f b6 14 c5 45 dc 30 	movzbl -0x7fcf23bb(,%eax,8),%edx
801065b6:	80 
801065b7:	83 e2 ef             	and    $0xffffffef,%edx
801065ba:	88 14 c5 45 dc 30 80 	mov    %dl,-0x7fcf23bb(,%eax,8)
801065c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c4:	0f b6 14 c5 45 dc 30 	movzbl -0x7fcf23bb(,%eax,8),%edx
801065cb:	80 
801065cc:	83 e2 9f             	and    $0xffffff9f,%edx
801065cf:	88 14 c5 45 dc 30 80 	mov    %dl,-0x7fcf23bb(,%eax,8)
801065d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d9:	0f b6 14 c5 45 dc 30 	movzbl -0x7fcf23bb(,%eax,8),%edx
801065e0:	80 
801065e1:	83 ca 80             	or     $0xffffff80,%edx
801065e4:	88 14 c5 45 dc 30 80 	mov    %dl,-0x7fcf23bb(,%eax,8)
801065eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ee:	8b 04 85 90 f0 10 80 	mov    -0x7fef0f70(,%eax,4),%eax
801065f5:	c1 e8 10             	shr    $0x10,%eax
801065f8:	89 c2                	mov    %eax,%edx
801065fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065fd:	66 89 14 c5 46 dc 30 	mov    %dx,-0x7fcf23ba(,%eax,8)
80106604:	80 
  for (i = 0; i < 256; i++)
80106605:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106609:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106610:	0f 8e 30 ff ff ff    	jle    80106546 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE << 3, vectors[T_SYSCALL], DPL_USER);
80106616:	a1 90 f1 10 80       	mov    0x8010f190,%eax
8010661b:	66 a3 40 de 30 80    	mov    %ax,0x8030de40
80106621:	66 c7 05 42 de 30 80 	movw   $0x8,0x8030de42
80106628:	08 00 
8010662a:	0f b6 05 44 de 30 80 	movzbl 0x8030de44,%eax
80106631:	83 e0 e0             	and    $0xffffffe0,%eax
80106634:	a2 44 de 30 80       	mov    %al,0x8030de44
80106639:	0f b6 05 44 de 30 80 	movzbl 0x8030de44,%eax
80106640:	83 e0 1f             	and    $0x1f,%eax
80106643:	a2 44 de 30 80       	mov    %al,0x8030de44
80106648:	0f b6 05 45 de 30 80 	movzbl 0x8030de45,%eax
8010664f:	83 c8 0f             	or     $0xf,%eax
80106652:	a2 45 de 30 80       	mov    %al,0x8030de45
80106657:	0f b6 05 45 de 30 80 	movzbl 0x8030de45,%eax
8010665e:	83 e0 ef             	and    $0xffffffef,%eax
80106661:	a2 45 de 30 80       	mov    %al,0x8030de45
80106666:	0f b6 05 45 de 30 80 	movzbl 0x8030de45,%eax
8010666d:	83 c8 60             	or     $0x60,%eax
80106670:	a2 45 de 30 80       	mov    %al,0x8030de45
80106675:	0f b6 05 45 de 30 80 	movzbl 0x8030de45,%eax
8010667c:	83 c8 80             	or     $0xffffff80,%eax
8010667f:	a2 45 de 30 80       	mov    %al,0x8030de45
80106684:	a1 90 f1 10 80       	mov    0x8010f190,%eax
80106689:	c1 e8 10             	shr    $0x10,%eax
8010668c:	66 a3 46 de 30 80    	mov    %ax,0x8030de46

  initlock(&tickslock, "time");
80106692:	83 ec 08             	sub    $0x8,%esp
80106695:	68 14 ae 10 80       	push   $0x8010ae14
8010669a:	68 40 e4 30 80       	push   $0x8030e440
8010669f:	e8 c1 e4 ff ff       	call   80104b65 <initlock>
801066a4:	83 c4 10             	add    $0x10,%esp
}
801066a7:	90                   	nop
801066a8:	c9                   	leave  
801066a9:	c3                   	ret    

801066aa <idtinit>:

void idtinit(void)
{
801066aa:	55                   	push   %ebp
801066ab:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801066ad:	68 00 08 00 00       	push   $0x800
801066b2:	68 40 dc 30 80       	push   $0x8030dc40
801066b7:	e8 31 fe ff ff       	call   801064ed <lidt>
801066bc:	83 c4 08             	add    $0x8,%esp
}
801066bf:	90                   	nop
801066c0:	c9                   	leave  
801066c1:	c3                   	ret    

801066c2 <trap>:

// PAGEBREAK: 41
void trap(struct trapframe *tf)
{
801066c2:	55                   	push   %ebp
801066c3:	89 e5                	mov    %esp,%ebp
801066c5:	57                   	push   %edi
801066c6:	56                   	push   %esi
801066c7:	53                   	push   %ebx
801066c8:	83 ec 2c             	sub    $0x2c,%esp
  struct proc *p = myproc();
801066cb:	e8 48 d3 ff ff       	call   80103a18 <myproc>
801066d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (tf->trapno == T_SYSCALL)
801066d3:	8b 45 08             	mov    0x8(%ebp),%eax
801066d6:	8b 40 30             	mov    0x30(%eax),%eax
801066d9:	83 f8 40             	cmp    $0x40,%eax
801066dc:	75 3b                	jne    80106719 <trap+0x57>
  {
    if (myproc()->killed)
801066de:	e8 35 d3 ff ff       	call   80103a18 <myproc>
801066e3:	8b 40 24             	mov    0x24(%eax),%eax
801066e6:	85 c0                	test   %eax,%eax
801066e8:	74 05                	je     801066ef <trap+0x2d>
      exit();
801066ea:	e8 76 d8 ff ff       	call   80103f65 <exit>
    myproc()->tf = tf;
801066ef:	e8 24 d3 ff ff       	call   80103a18 <myproc>
801066f4:	8b 55 08             	mov    0x8(%ebp),%edx
801066f7:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801066fa:	e8 ca ea ff ff       	call   801051c9 <syscall>
    if (myproc()->killed)
801066ff:	e8 14 d3 ff ff       	call   80103a18 <myproc>
80106704:	8b 40 24             	mov    0x24(%eax),%eax
80106707:	85 c0                	test   %eax,%eax
80106709:	0f 84 87 03 00 00    	je     80106a96 <trap+0x3d4>
      exit();
8010670f:	e8 51 d8 ff ff       	call   80103f65 <exit>
    return;
80106714:	e9 7d 03 00 00       	jmp    80106a96 <trap+0x3d4>
  }

  switch (tf->trapno)
80106719:	8b 45 08             	mov    0x8(%ebp),%eax
8010671c:	8b 40 30             	mov    0x30(%eax),%eax
8010671f:	83 e8 0e             	sub    $0xe,%eax
80106722:	83 f8 31             	cmp    $0x31,%eax
80106725:	0f 87 33 02 00 00    	ja     8010695e <trap+0x29c>
8010672b:	8b 04 85 f0 ae 10 80 	mov    -0x7fef5110(,%eax,4),%eax
80106732:	ff e0                	jmp    *%eax
  {
  case T_IRQ0 + IRQ_TIMER:
    if (cpuid() == 0)
80106734:	e8 4c d2 ff ff       	call   80103985 <cpuid>
80106739:	85 c0                	test   %eax,%eax
8010673b:	75 3d                	jne    8010677a <trap+0xb8>
    {
      acquire(&tickslock);
8010673d:	83 ec 0c             	sub    $0xc,%esp
80106740:	68 40 e4 30 80       	push   $0x8030e440
80106745:	e8 3d e4 ff ff       	call   80104b87 <acquire>
8010674a:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010674d:	a1 74 e4 30 80       	mov    0x8030e474,%eax
80106752:	83 c0 01             	add    $0x1,%eax
80106755:	a3 74 e4 30 80       	mov    %eax,0x8030e474
      wakeup(&ticks);
8010675a:	83 ec 0c             	sub    $0xc,%esp
8010675d:	68 74 e4 30 80       	push   $0x8030e474
80106762:	e8 b0 e0 ff ff       	call   80104817 <wakeup>
80106767:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010676a:	83 ec 0c             	sub    $0xc,%esp
8010676d:	68 40 e4 30 80       	push   $0x8030e440
80106772:	e8 7e e4 ff ff       	call   80104bf5 <release>
80106777:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010677a:	e8 85 c3 ff ff       	call   80102b04 <lapiceoi>

    // 유저모드 + scheduler 설정된 경우만 실행
    if (p && p->state == RUNNING && p->scheduler)
8010677f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106783:	0f 84 8c 02 00 00    	je     80106a15 <trap+0x353>
80106789:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010678c:	8b 40 0c             	mov    0xc(%eax),%eax
8010678f:	83 f8 04             	cmp    $0x4,%eax
80106792:	0f 85 7d 02 00 00    	jne    80106a15 <trap+0x353>
80106798:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010679b:	8b 40 7c             	mov    0x7c(%eax),%eax
8010679e:	85 c0                	test   %eax,%eax
801067a0:	0f 84 6f 02 00 00    	je     80106a15 <trap+0x353>
    {
      if (p->check_thread >= 2)
801067a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067a9:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801067af:	83 f8 01             	cmp    $0x1,%eax
801067b2:	0f 8e 5d 02 00 00    	jle    80106a15 <trap+0x353>
      {
        p->tf->eip = p->scheduler;
801067b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067bb:	8b 40 18             	mov    0x18(%eax),%eax
801067be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801067c1:	8b 52 7c             	mov    0x7c(%edx),%edx
801067c4:	89 50 38             	mov    %edx,0x38(%eax)
      }
    }

    break;
801067c7:	e9 49 02 00 00       	jmp    80106a15 <trap+0x353>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801067cc:	e8 0a 40 00 00       	call   8010a7db <ideintr>
    lapiceoi();
801067d1:	e8 2e c3 ff ff       	call   80102b04 <lapiceoi>
    break;
801067d6:	e9 3b 02 00 00       	jmp    80106a16 <trap+0x354>
  case T_IRQ0 + IRQ_IDE + 1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801067db:	e8 69 c1 ff ff       	call   80102949 <kbdintr>
    lapiceoi();
801067e0:	e8 1f c3 ff ff       	call   80102b04 <lapiceoi>
    break;
801067e5:	e9 2c 02 00 00       	jmp    80106a16 <trap+0x354>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801067ea:	e8 7d 04 00 00       	call   80106c6c <uartintr>
    lapiceoi();
801067ef:	e8 10 c3 ff ff       	call   80102b04 <lapiceoi>
    break;
801067f4:	e9 1d 02 00 00       	jmp    80106a16 <trap+0x354>
  case T_IRQ0 + 0xB:
    i8254_intr();
801067f9:	e8 90 2c 00 00       	call   8010948e <i8254_intr>
    lapiceoi();
801067fe:	e8 01 c3 ff ff       	call   80102b04 <lapiceoi>
    break;
80106803:	e9 0e 02 00 00       	jmp    80106a16 <trap+0x354>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106808:	8b 45 08             	mov    0x8(%ebp),%eax
8010680b:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010680e:	8b 45 08             	mov    0x8(%ebp),%eax
80106811:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106815:	0f b7 d8             	movzwl %ax,%ebx
80106818:	e8 68 d1 ff ff       	call   80103985 <cpuid>
8010681d:	56                   	push   %esi
8010681e:	53                   	push   %ebx
8010681f:	50                   	push   %eax
80106820:	68 1c ae 10 80       	push   $0x8010ae1c
80106825:	e8 ca 9b ff ff       	call   801003f4 <cprintf>
8010682a:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010682d:	e8 d2 c2 ff ff       	call   80102b04 <lapiceoi>
    break;
80106832:	e9 df 01 00 00       	jmp    80106a16 <trap+0x354>
    //   walkpgdir(myproc()->pgdir, (char *)va, 0);
    //   lcr3(V2P(myproc()->pgdir));
    //   break;

  case T_PGFLT:
    uint va = PGROUNDDOWN(rcr2());
80106837:	e8 db fc ff ff       	call   80106517 <rcr2>
8010683c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106841:	89 45 e0             	mov    %eax,-0x20(%ebp)

    // [추가] 유효 주소 체크 (heap, stack 등만 허용)
    if (/*va >= p->sz ||*/ va >= KERNBASE || va < PGSIZE) {
80106844:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106847:	85 c0                	test   %eax,%eax
80106849:	78 09                	js     80106854 <trap+0x192>
8010684b:	81 7d e0 ff 0f 00 00 	cmpl   $0xfff,-0x20(%ebp)
80106852:	77 28                	ja     8010687c <trap+0x1ba>
      cprintf("trap: kill! va=%x sz=%x\n", va, p->sz);  
80106854:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106857:	8b 00                	mov    (%eax),%eax
80106859:	83 ec 04             	sub    $0x4,%esp
8010685c:	50                   	push   %eax
8010685d:	ff 75 e0             	push   -0x20(%ebp)
80106860:	68 40 ae 10 80       	push   $0x8010ae40
80106865:	e8 8a 9b ff ff       	call   801003f4 <cprintf>
8010686a:	83 c4 10             	add    $0x10,%esp
      p->killed = 1;
8010686d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106870:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      break;
80106877:	e9 9a 01 00 00       	jmp    80106a16 <trap+0x354>
    }

    pte_t *pte = walkpgdir(p->pgdir, (char *)va, 0);
8010687c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010687f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106882:	8b 40 04             	mov    0x4(%eax),%eax
80106885:	83 ec 04             	sub    $0x4,%esp
80106888:	6a 00                	push   $0x0
8010688a:	52                   	push   %edx
8010688b:	50                   	push   %eax
8010688c:	e8 09 12 00 00       	call   80107a9a <walkpgdir>
80106891:	83 c4 10             	add    $0x10,%esp
80106894:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (pte && (*pte & PTE_P)) {
80106897:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010689b:	74 1b                	je     801068b8 <trap+0x1f6>
8010689d:	8b 45 dc             	mov    -0x24(%ebp),%eax
801068a0:	8b 00                	mov    (%eax),%eax
801068a2:	83 e0 01             	and    $0x1,%eax
801068a5:	85 c0                	test   %eax,%eax
801068a7:	74 0f                	je     801068b8 <trap+0x1f6>
        p->killed = 1;
801068a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068ac:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
        break;
801068b3:	e9 5e 01 00 00       	jmp    80106a16 <trap+0x354>
    }

    char *mem = kalloc();
801068b8:	e8 cb be ff ff       	call   80102788 <kalloc>
801068bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if (mem == 0) {
801068c0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801068c4:	75 1f                	jne    801068e5 <trap+0x223>
        cprintf("allocuvm out of memory\n");
801068c6:	83 ec 0c             	sub    $0xc,%esp
801068c9:	68 59 ae 10 80       	push   $0x8010ae59
801068ce:	e8 21 9b ff ff       	call   801003f4 <cprintf>
801068d3:	83 c4 10             	add    $0x10,%esp
        p->killed = 1;
801068d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068d9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
        break;
801068e0:	e9 31 01 00 00       	jmp    80106a16 <trap+0x354>
    }
    memset(mem, 0, PGSIZE);
801068e5:	83 ec 04             	sub    $0x4,%esp
801068e8:	68 00 10 00 00       	push   $0x1000
801068ed:	6a 00                	push   $0x0
801068ef:	ff 75 d8             	push   -0x28(%ebp)
801068f2:	e8 06 e5 ff ff       	call   80104dfd <memset>
801068f7:	83 c4 10             	add    $0x10,%esp
    if (mappages(p->pgdir, (char *)va, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0) {
801068fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
801068fd:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80106903:	8b 55 e0             	mov    -0x20(%ebp),%edx
80106906:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106909:	8b 40 04             	mov    0x4(%eax),%eax
8010690c:	83 ec 0c             	sub    $0xc,%esp
8010690f:	6a 06                	push   $0x6
80106911:	51                   	push   %ecx
80106912:	68 00 10 00 00       	push   $0x1000
80106917:	52                   	push   %edx
80106918:	50                   	push   %eax
80106919:	e8 12 12 00 00       	call   80107b30 <mappages>
8010691e:	83 c4 20             	add    $0x20,%esp
80106921:	85 c0                	test   %eax,%eax
80106923:	79 1d                	jns    80106942 <trap+0x280>
        kfree(mem);
80106925:	83 ec 0c             	sub    $0xc,%esp
80106928:	ff 75 d8             	push   -0x28(%ebp)
8010692b:	e8 be bd ff ff       	call   801026ee <kfree>
80106930:	83 c4 10             	add    $0x10,%esp
        p->killed = 1;
80106933:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106936:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
        break;
8010693d:	e9 d4 00 00 00       	jmp    80106a16 <trap+0x354>
    }
    lcr3(V2P(p->pgdir)); // TLB flush
80106942:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106945:	8b 40 04             	mov    0x4(%eax),%eax
80106948:	05 00 00 00 80       	add    $0x80000000,%eax
8010694d:	83 ec 0c             	sub    $0xc,%esp
80106950:	50                   	push   %eax
80106951:	e8 d2 fb ff ff       	call   80106528 <lcr3>
80106956:	83 c4 10             	add    $0x10,%esp
    break;
80106959:	e9 b8 00 00 00       	jmp    80106a16 <trap+0x354>



  // PAGEBREAK: 13
  default:
    if (myproc() == 0 || (tf->cs & 3) == 0)
8010695e:	e8 b5 d0 ff ff       	call   80103a18 <myproc>
80106963:	85 c0                	test   %eax,%eax
80106965:	74 11                	je     80106978 <trap+0x2b6>
80106967:	8b 45 08             	mov    0x8(%ebp),%eax
8010696a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010696e:	0f b7 c0             	movzwl %ax,%eax
80106971:	83 e0 03             	and    $0x3,%eax
80106974:	85 c0                	test   %eax,%eax
80106976:	75 39                	jne    801069b1 <trap+0x2ef>
    {
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106978:	e8 9a fb ff ff       	call   80106517 <rcr2>
8010697d:	89 c3                	mov    %eax,%ebx
8010697f:	8b 45 08             	mov    0x8(%ebp),%eax
80106982:	8b 70 38             	mov    0x38(%eax),%esi
80106985:	e8 fb cf ff ff       	call   80103985 <cpuid>
8010698a:	8b 55 08             	mov    0x8(%ebp),%edx
8010698d:	8b 52 30             	mov    0x30(%edx),%edx
80106990:	83 ec 0c             	sub    $0xc,%esp
80106993:	53                   	push   %ebx
80106994:	56                   	push   %esi
80106995:	50                   	push   %eax
80106996:	52                   	push   %edx
80106997:	68 74 ae 10 80       	push   $0x8010ae74
8010699c:	e8 53 9a ff ff       	call   801003f4 <cprintf>
801069a1:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801069a4:	83 ec 0c             	sub    $0xc,%esp
801069a7:	68 a6 ae 10 80       	push   $0x8010aea6
801069ac:	e8 f8 9b ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069b1:	e8 61 fb ff ff       	call   80106517 <rcr2>
801069b6:	89 c6                	mov    %eax,%esi
801069b8:	8b 45 08             	mov    0x8(%ebp),%eax
801069bb:	8b 40 38             	mov    0x38(%eax),%eax
801069be:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801069c1:	e8 bf cf ff ff       	call   80103985 <cpuid>
801069c6:	89 c3                	mov    %eax,%ebx
801069c8:	8b 45 08             	mov    0x8(%ebp),%eax
801069cb:	8b 48 34             	mov    0x34(%eax),%ecx
801069ce:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801069d1:	8b 45 08             	mov    0x8(%ebp),%eax
801069d4:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801069d7:	e8 3c d0 ff ff       	call   80103a18 <myproc>
801069dc:	8d 50 6c             	lea    0x6c(%eax),%edx
801069df:	89 55 cc             	mov    %edx,-0x34(%ebp)
801069e2:	e8 31 d0 ff ff       	call   80103a18 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069e7:	8b 40 10             	mov    0x10(%eax),%eax
801069ea:	56                   	push   %esi
801069eb:	ff 75 d4             	push   -0x2c(%ebp)
801069ee:	53                   	push   %ebx
801069ef:	ff 75 d0             	push   -0x30(%ebp)
801069f2:	57                   	push   %edi
801069f3:	ff 75 cc             	push   -0x34(%ebp)
801069f6:	50                   	push   %eax
801069f7:	68 ac ae 10 80       	push   $0x8010aeac
801069fc:	e8 f3 99 ff ff       	call   801003f4 <cprintf>
80106a01:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106a04:	e8 0f d0 ff ff       	call   80103a18 <myproc>
80106a09:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106a10:	eb 04                	jmp    80106a16 <trap+0x354>
    break;
80106a12:	90                   	nop
80106a13:	eb 01                	jmp    80106a16 <trap+0x354>
    break;
80106a15:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
80106a16:	e8 fd cf ff ff       	call   80103a18 <myproc>
80106a1b:	85 c0                	test   %eax,%eax
80106a1d:	74 23                	je     80106a42 <trap+0x380>
80106a1f:	e8 f4 cf ff ff       	call   80103a18 <myproc>
80106a24:	8b 40 24             	mov    0x24(%eax),%eax
80106a27:	85 c0                	test   %eax,%eax
80106a29:	74 17                	je     80106a42 <trap+0x380>
80106a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a2e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a32:	0f b7 c0             	movzwl %ax,%eax
80106a35:	83 e0 03             	and    $0x3,%eax
80106a38:	83 f8 03             	cmp    $0x3,%eax
80106a3b:	75 05                	jne    80106a42 <trap+0x380>
    exit();
80106a3d:	e8 23 d5 ff ff       	call   80103f65 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if (myproc() && myproc()->state == RUNNING &&
80106a42:	e8 d1 cf ff ff       	call   80103a18 <myproc>
80106a47:	85 c0                	test   %eax,%eax
80106a49:	74 1d                	je     80106a68 <trap+0x3a6>
80106a4b:	e8 c8 cf ff ff       	call   80103a18 <myproc>
80106a50:	8b 40 0c             	mov    0xc(%eax),%eax
80106a53:	83 f8 04             	cmp    $0x4,%eax
80106a56:	75 10                	jne    80106a68 <trap+0x3a6>
      tf->trapno == T_IRQ0 + IRQ_TIMER)
80106a58:	8b 45 08             	mov    0x8(%ebp),%eax
80106a5b:	8b 40 30             	mov    0x30(%eax),%eax
  if (myproc() && myproc()->state == RUNNING &&
80106a5e:	83 f8 20             	cmp    $0x20,%eax
80106a61:	75 05                	jne    80106a68 <trap+0x3a6>
    yield();
80106a63:	e8 04 dc ff ff       	call   8010466c <yield>

  // Check if the process has been killed since we yielded
  if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
80106a68:	e8 ab cf ff ff       	call   80103a18 <myproc>
80106a6d:	85 c0                	test   %eax,%eax
80106a6f:	74 26                	je     80106a97 <trap+0x3d5>
80106a71:	e8 a2 cf ff ff       	call   80103a18 <myproc>
80106a76:	8b 40 24             	mov    0x24(%eax),%eax
80106a79:	85 c0                	test   %eax,%eax
80106a7b:	74 1a                	je     80106a97 <trap+0x3d5>
80106a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80106a80:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a84:	0f b7 c0             	movzwl %ax,%eax
80106a87:	83 e0 03             	and    $0x3,%eax
80106a8a:	83 f8 03             	cmp    $0x3,%eax
80106a8d:	75 08                	jne    80106a97 <trap+0x3d5>
    exit();
80106a8f:	e8 d1 d4 ff ff       	call   80103f65 <exit>
80106a94:	eb 01                	jmp    80106a97 <trap+0x3d5>
    return;
80106a96:	90                   	nop
}
80106a97:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106a9a:	5b                   	pop    %ebx
80106a9b:	5e                   	pop    %esi
80106a9c:	5f                   	pop    %edi
80106a9d:	5d                   	pop    %ebp
80106a9e:	c3                   	ret    

80106a9f <inb>:
{
80106a9f:	55                   	push   %ebp
80106aa0:	89 e5                	mov    %esp,%ebp
80106aa2:	83 ec 14             	sub    $0x14,%esp
80106aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106aac:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106ab0:	89 c2                	mov    %eax,%edx
80106ab2:	ec                   	in     (%dx),%al
80106ab3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106ab6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106aba:	c9                   	leave  
80106abb:	c3                   	ret    

80106abc <outb>:
{
80106abc:	55                   	push   %ebp
80106abd:	89 e5                	mov    %esp,%ebp
80106abf:	83 ec 08             	sub    $0x8,%esp
80106ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80106ac5:	8b 55 0c             	mov    0xc(%ebp),%edx
80106ac8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106acc:	89 d0                	mov    %edx,%eax
80106ace:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106ad1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106ad5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106ad9:	ee                   	out    %al,(%dx)
}
80106ada:	90                   	nop
80106adb:	c9                   	leave  
80106adc:	c3                   	ret    

80106add <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106add:	55                   	push   %ebp
80106ade:	89 e5                	mov    %esp,%ebp
80106ae0:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106ae3:	6a 00                	push   $0x0
80106ae5:	68 fa 03 00 00       	push   $0x3fa
80106aea:	e8 cd ff ff ff       	call   80106abc <outb>
80106aef:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106af2:	68 80 00 00 00       	push   $0x80
80106af7:	68 fb 03 00 00       	push   $0x3fb
80106afc:	e8 bb ff ff ff       	call   80106abc <outb>
80106b01:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106b04:	6a 0c                	push   $0xc
80106b06:	68 f8 03 00 00       	push   $0x3f8
80106b0b:	e8 ac ff ff ff       	call   80106abc <outb>
80106b10:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106b13:	6a 00                	push   $0x0
80106b15:	68 f9 03 00 00       	push   $0x3f9
80106b1a:	e8 9d ff ff ff       	call   80106abc <outb>
80106b1f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106b22:	6a 03                	push   $0x3
80106b24:	68 fb 03 00 00       	push   $0x3fb
80106b29:	e8 8e ff ff ff       	call   80106abc <outb>
80106b2e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106b31:	6a 00                	push   $0x0
80106b33:	68 fc 03 00 00       	push   $0x3fc
80106b38:	e8 7f ff ff ff       	call   80106abc <outb>
80106b3d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106b40:	6a 01                	push   $0x1
80106b42:	68 f9 03 00 00       	push   $0x3f9
80106b47:	e8 70 ff ff ff       	call   80106abc <outb>
80106b4c:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106b4f:	68 fd 03 00 00       	push   $0x3fd
80106b54:	e8 46 ff ff ff       	call   80106a9f <inb>
80106b59:	83 c4 04             	add    $0x4,%esp
80106b5c:	3c ff                	cmp    $0xff,%al
80106b5e:	74 61                	je     80106bc1 <uartinit+0xe4>
    return;
  uart = 1;
80106b60:	c7 05 78 e4 30 80 01 	movl   $0x1,0x8030e478
80106b67:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106b6a:	68 fa 03 00 00       	push   $0x3fa
80106b6f:	e8 2b ff ff ff       	call   80106a9f <inb>
80106b74:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106b77:	68 f8 03 00 00       	push   $0x3f8
80106b7c:	e8 1e ff ff ff       	call   80106a9f <inb>
80106b81:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106b84:	83 ec 08             	sub    $0x8,%esp
80106b87:	6a 00                	push   $0x0
80106b89:	6a 04                	push   $0x4
80106b8b:	e8 86 ba ff ff       	call   80102616 <ioapicenable>
80106b90:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106b93:	c7 45 f4 b8 af 10 80 	movl   $0x8010afb8,-0xc(%ebp)
80106b9a:	eb 19                	jmp    80106bb5 <uartinit+0xd8>
    uartputc(*p);
80106b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b9f:	0f b6 00             	movzbl (%eax),%eax
80106ba2:	0f be c0             	movsbl %al,%eax
80106ba5:	83 ec 0c             	sub    $0xc,%esp
80106ba8:	50                   	push   %eax
80106ba9:	e8 16 00 00 00       	call   80106bc4 <uartputc>
80106bae:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106bb1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb8:	0f b6 00             	movzbl (%eax),%eax
80106bbb:	84 c0                	test   %al,%al
80106bbd:	75 dd                	jne    80106b9c <uartinit+0xbf>
80106bbf:	eb 01                	jmp    80106bc2 <uartinit+0xe5>
    return;
80106bc1:	90                   	nop
}
80106bc2:	c9                   	leave  
80106bc3:	c3                   	ret    

80106bc4 <uartputc>:

void
uartputc(int c)
{
80106bc4:	55                   	push   %ebp
80106bc5:	89 e5                	mov    %esp,%ebp
80106bc7:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106bca:	a1 78 e4 30 80       	mov    0x8030e478,%eax
80106bcf:	85 c0                	test   %eax,%eax
80106bd1:	74 53                	je     80106c26 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106bd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106bda:	eb 11                	jmp    80106bed <uartputc+0x29>
    microdelay(10);
80106bdc:	83 ec 0c             	sub    $0xc,%esp
80106bdf:	6a 0a                	push   $0xa
80106be1:	e8 39 bf ff ff       	call   80102b1f <microdelay>
80106be6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106be9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106bed:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106bf1:	7f 1a                	jg     80106c0d <uartputc+0x49>
80106bf3:	83 ec 0c             	sub    $0xc,%esp
80106bf6:	68 fd 03 00 00       	push   $0x3fd
80106bfb:	e8 9f fe ff ff       	call   80106a9f <inb>
80106c00:	83 c4 10             	add    $0x10,%esp
80106c03:	0f b6 c0             	movzbl %al,%eax
80106c06:	83 e0 20             	and    $0x20,%eax
80106c09:	85 c0                	test   %eax,%eax
80106c0b:	74 cf                	je     80106bdc <uartputc+0x18>
  outb(COM1+0, c);
80106c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80106c10:	0f b6 c0             	movzbl %al,%eax
80106c13:	83 ec 08             	sub    $0x8,%esp
80106c16:	50                   	push   %eax
80106c17:	68 f8 03 00 00       	push   $0x3f8
80106c1c:	e8 9b fe ff ff       	call   80106abc <outb>
80106c21:	83 c4 10             	add    $0x10,%esp
80106c24:	eb 01                	jmp    80106c27 <uartputc+0x63>
    return;
80106c26:	90                   	nop
}
80106c27:	c9                   	leave  
80106c28:	c3                   	ret    

80106c29 <uartgetc>:

static int
uartgetc(void)
{
80106c29:	55                   	push   %ebp
80106c2a:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106c2c:	a1 78 e4 30 80       	mov    0x8030e478,%eax
80106c31:	85 c0                	test   %eax,%eax
80106c33:	75 07                	jne    80106c3c <uartgetc+0x13>
    return -1;
80106c35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c3a:	eb 2e                	jmp    80106c6a <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106c3c:	68 fd 03 00 00       	push   $0x3fd
80106c41:	e8 59 fe ff ff       	call   80106a9f <inb>
80106c46:	83 c4 04             	add    $0x4,%esp
80106c49:	0f b6 c0             	movzbl %al,%eax
80106c4c:	83 e0 01             	and    $0x1,%eax
80106c4f:	85 c0                	test   %eax,%eax
80106c51:	75 07                	jne    80106c5a <uartgetc+0x31>
    return -1;
80106c53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c58:	eb 10                	jmp    80106c6a <uartgetc+0x41>
  return inb(COM1+0);
80106c5a:	68 f8 03 00 00       	push   $0x3f8
80106c5f:	e8 3b fe ff ff       	call   80106a9f <inb>
80106c64:	83 c4 04             	add    $0x4,%esp
80106c67:	0f b6 c0             	movzbl %al,%eax
}
80106c6a:	c9                   	leave  
80106c6b:	c3                   	ret    

80106c6c <uartintr>:

void
uartintr(void)
{
80106c6c:	55                   	push   %ebp
80106c6d:	89 e5                	mov    %esp,%ebp
80106c6f:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106c72:	83 ec 0c             	sub    $0xc,%esp
80106c75:	68 29 6c 10 80       	push   $0x80106c29
80106c7a:	e8 57 9b ff ff       	call   801007d6 <consoleintr>
80106c7f:	83 c4 10             	add    $0x10,%esp
}
80106c82:	90                   	nop
80106c83:	c9                   	leave  
80106c84:	c3                   	ret    

80106c85 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106c85:	6a 00                	push   $0x0
  pushl $0
80106c87:	6a 00                	push   $0x0
  jmp alltraps
80106c89:	e9 3c f8 ff ff       	jmp    801064ca <alltraps>

80106c8e <vector1>:
.globl vector1
vector1:
  pushl $0
80106c8e:	6a 00                	push   $0x0
  pushl $1
80106c90:	6a 01                	push   $0x1
  jmp alltraps
80106c92:	e9 33 f8 ff ff       	jmp    801064ca <alltraps>

80106c97 <vector2>:
.globl vector2
vector2:
  pushl $0
80106c97:	6a 00                	push   $0x0
  pushl $2
80106c99:	6a 02                	push   $0x2
  jmp alltraps
80106c9b:	e9 2a f8 ff ff       	jmp    801064ca <alltraps>

80106ca0 <vector3>:
.globl vector3
vector3:
  pushl $0
80106ca0:	6a 00                	push   $0x0
  pushl $3
80106ca2:	6a 03                	push   $0x3
  jmp alltraps
80106ca4:	e9 21 f8 ff ff       	jmp    801064ca <alltraps>

80106ca9 <vector4>:
.globl vector4
vector4:
  pushl $0
80106ca9:	6a 00                	push   $0x0
  pushl $4
80106cab:	6a 04                	push   $0x4
  jmp alltraps
80106cad:	e9 18 f8 ff ff       	jmp    801064ca <alltraps>

80106cb2 <vector5>:
.globl vector5
vector5:
  pushl $0
80106cb2:	6a 00                	push   $0x0
  pushl $5
80106cb4:	6a 05                	push   $0x5
  jmp alltraps
80106cb6:	e9 0f f8 ff ff       	jmp    801064ca <alltraps>

80106cbb <vector6>:
.globl vector6
vector6:
  pushl $0
80106cbb:	6a 00                	push   $0x0
  pushl $6
80106cbd:	6a 06                	push   $0x6
  jmp alltraps
80106cbf:	e9 06 f8 ff ff       	jmp    801064ca <alltraps>

80106cc4 <vector7>:
.globl vector7
vector7:
  pushl $0
80106cc4:	6a 00                	push   $0x0
  pushl $7
80106cc6:	6a 07                	push   $0x7
  jmp alltraps
80106cc8:	e9 fd f7 ff ff       	jmp    801064ca <alltraps>

80106ccd <vector8>:
.globl vector8
vector8:
  pushl $8
80106ccd:	6a 08                	push   $0x8
  jmp alltraps
80106ccf:	e9 f6 f7 ff ff       	jmp    801064ca <alltraps>

80106cd4 <vector9>:
.globl vector9
vector9:
  pushl $0
80106cd4:	6a 00                	push   $0x0
  pushl $9
80106cd6:	6a 09                	push   $0x9
  jmp alltraps
80106cd8:	e9 ed f7 ff ff       	jmp    801064ca <alltraps>

80106cdd <vector10>:
.globl vector10
vector10:
  pushl $10
80106cdd:	6a 0a                	push   $0xa
  jmp alltraps
80106cdf:	e9 e6 f7 ff ff       	jmp    801064ca <alltraps>

80106ce4 <vector11>:
.globl vector11
vector11:
  pushl $11
80106ce4:	6a 0b                	push   $0xb
  jmp alltraps
80106ce6:	e9 df f7 ff ff       	jmp    801064ca <alltraps>

80106ceb <vector12>:
.globl vector12
vector12:
  pushl $12
80106ceb:	6a 0c                	push   $0xc
  jmp alltraps
80106ced:	e9 d8 f7 ff ff       	jmp    801064ca <alltraps>

80106cf2 <vector13>:
.globl vector13
vector13:
  pushl $13
80106cf2:	6a 0d                	push   $0xd
  jmp alltraps
80106cf4:	e9 d1 f7 ff ff       	jmp    801064ca <alltraps>

80106cf9 <vector14>:
.globl vector14
vector14:
  pushl $14
80106cf9:	6a 0e                	push   $0xe
  jmp alltraps
80106cfb:	e9 ca f7 ff ff       	jmp    801064ca <alltraps>

80106d00 <vector15>:
.globl vector15
vector15:
  pushl $0
80106d00:	6a 00                	push   $0x0
  pushl $15
80106d02:	6a 0f                	push   $0xf
  jmp alltraps
80106d04:	e9 c1 f7 ff ff       	jmp    801064ca <alltraps>

80106d09 <vector16>:
.globl vector16
vector16:
  pushl $0
80106d09:	6a 00                	push   $0x0
  pushl $16
80106d0b:	6a 10                	push   $0x10
  jmp alltraps
80106d0d:	e9 b8 f7 ff ff       	jmp    801064ca <alltraps>

80106d12 <vector17>:
.globl vector17
vector17:
  pushl $17
80106d12:	6a 11                	push   $0x11
  jmp alltraps
80106d14:	e9 b1 f7 ff ff       	jmp    801064ca <alltraps>

80106d19 <vector18>:
.globl vector18
vector18:
  pushl $0
80106d19:	6a 00                	push   $0x0
  pushl $18
80106d1b:	6a 12                	push   $0x12
  jmp alltraps
80106d1d:	e9 a8 f7 ff ff       	jmp    801064ca <alltraps>

80106d22 <vector19>:
.globl vector19
vector19:
  pushl $0
80106d22:	6a 00                	push   $0x0
  pushl $19
80106d24:	6a 13                	push   $0x13
  jmp alltraps
80106d26:	e9 9f f7 ff ff       	jmp    801064ca <alltraps>

80106d2b <vector20>:
.globl vector20
vector20:
  pushl $0
80106d2b:	6a 00                	push   $0x0
  pushl $20
80106d2d:	6a 14                	push   $0x14
  jmp alltraps
80106d2f:	e9 96 f7 ff ff       	jmp    801064ca <alltraps>

80106d34 <vector21>:
.globl vector21
vector21:
  pushl $0
80106d34:	6a 00                	push   $0x0
  pushl $21
80106d36:	6a 15                	push   $0x15
  jmp alltraps
80106d38:	e9 8d f7 ff ff       	jmp    801064ca <alltraps>

80106d3d <vector22>:
.globl vector22
vector22:
  pushl $0
80106d3d:	6a 00                	push   $0x0
  pushl $22
80106d3f:	6a 16                	push   $0x16
  jmp alltraps
80106d41:	e9 84 f7 ff ff       	jmp    801064ca <alltraps>

80106d46 <vector23>:
.globl vector23
vector23:
  pushl $0
80106d46:	6a 00                	push   $0x0
  pushl $23
80106d48:	6a 17                	push   $0x17
  jmp alltraps
80106d4a:	e9 7b f7 ff ff       	jmp    801064ca <alltraps>

80106d4f <vector24>:
.globl vector24
vector24:
  pushl $0
80106d4f:	6a 00                	push   $0x0
  pushl $24
80106d51:	6a 18                	push   $0x18
  jmp alltraps
80106d53:	e9 72 f7 ff ff       	jmp    801064ca <alltraps>

80106d58 <vector25>:
.globl vector25
vector25:
  pushl $0
80106d58:	6a 00                	push   $0x0
  pushl $25
80106d5a:	6a 19                	push   $0x19
  jmp alltraps
80106d5c:	e9 69 f7 ff ff       	jmp    801064ca <alltraps>

80106d61 <vector26>:
.globl vector26
vector26:
  pushl $0
80106d61:	6a 00                	push   $0x0
  pushl $26
80106d63:	6a 1a                	push   $0x1a
  jmp alltraps
80106d65:	e9 60 f7 ff ff       	jmp    801064ca <alltraps>

80106d6a <vector27>:
.globl vector27
vector27:
  pushl $0
80106d6a:	6a 00                	push   $0x0
  pushl $27
80106d6c:	6a 1b                	push   $0x1b
  jmp alltraps
80106d6e:	e9 57 f7 ff ff       	jmp    801064ca <alltraps>

80106d73 <vector28>:
.globl vector28
vector28:
  pushl $0
80106d73:	6a 00                	push   $0x0
  pushl $28
80106d75:	6a 1c                	push   $0x1c
  jmp alltraps
80106d77:	e9 4e f7 ff ff       	jmp    801064ca <alltraps>

80106d7c <vector29>:
.globl vector29
vector29:
  pushl $0
80106d7c:	6a 00                	push   $0x0
  pushl $29
80106d7e:	6a 1d                	push   $0x1d
  jmp alltraps
80106d80:	e9 45 f7 ff ff       	jmp    801064ca <alltraps>

80106d85 <vector30>:
.globl vector30
vector30:
  pushl $0
80106d85:	6a 00                	push   $0x0
  pushl $30
80106d87:	6a 1e                	push   $0x1e
  jmp alltraps
80106d89:	e9 3c f7 ff ff       	jmp    801064ca <alltraps>

80106d8e <vector31>:
.globl vector31
vector31:
  pushl $0
80106d8e:	6a 00                	push   $0x0
  pushl $31
80106d90:	6a 1f                	push   $0x1f
  jmp alltraps
80106d92:	e9 33 f7 ff ff       	jmp    801064ca <alltraps>

80106d97 <vector32>:
.globl vector32
vector32:
  pushl $0
80106d97:	6a 00                	push   $0x0
  pushl $32
80106d99:	6a 20                	push   $0x20
  jmp alltraps
80106d9b:	e9 2a f7 ff ff       	jmp    801064ca <alltraps>

80106da0 <vector33>:
.globl vector33
vector33:
  pushl $0
80106da0:	6a 00                	push   $0x0
  pushl $33
80106da2:	6a 21                	push   $0x21
  jmp alltraps
80106da4:	e9 21 f7 ff ff       	jmp    801064ca <alltraps>

80106da9 <vector34>:
.globl vector34
vector34:
  pushl $0
80106da9:	6a 00                	push   $0x0
  pushl $34
80106dab:	6a 22                	push   $0x22
  jmp alltraps
80106dad:	e9 18 f7 ff ff       	jmp    801064ca <alltraps>

80106db2 <vector35>:
.globl vector35
vector35:
  pushl $0
80106db2:	6a 00                	push   $0x0
  pushl $35
80106db4:	6a 23                	push   $0x23
  jmp alltraps
80106db6:	e9 0f f7 ff ff       	jmp    801064ca <alltraps>

80106dbb <vector36>:
.globl vector36
vector36:
  pushl $0
80106dbb:	6a 00                	push   $0x0
  pushl $36
80106dbd:	6a 24                	push   $0x24
  jmp alltraps
80106dbf:	e9 06 f7 ff ff       	jmp    801064ca <alltraps>

80106dc4 <vector37>:
.globl vector37
vector37:
  pushl $0
80106dc4:	6a 00                	push   $0x0
  pushl $37
80106dc6:	6a 25                	push   $0x25
  jmp alltraps
80106dc8:	e9 fd f6 ff ff       	jmp    801064ca <alltraps>

80106dcd <vector38>:
.globl vector38
vector38:
  pushl $0
80106dcd:	6a 00                	push   $0x0
  pushl $38
80106dcf:	6a 26                	push   $0x26
  jmp alltraps
80106dd1:	e9 f4 f6 ff ff       	jmp    801064ca <alltraps>

80106dd6 <vector39>:
.globl vector39
vector39:
  pushl $0
80106dd6:	6a 00                	push   $0x0
  pushl $39
80106dd8:	6a 27                	push   $0x27
  jmp alltraps
80106dda:	e9 eb f6 ff ff       	jmp    801064ca <alltraps>

80106ddf <vector40>:
.globl vector40
vector40:
  pushl $0
80106ddf:	6a 00                	push   $0x0
  pushl $40
80106de1:	6a 28                	push   $0x28
  jmp alltraps
80106de3:	e9 e2 f6 ff ff       	jmp    801064ca <alltraps>

80106de8 <vector41>:
.globl vector41
vector41:
  pushl $0
80106de8:	6a 00                	push   $0x0
  pushl $41
80106dea:	6a 29                	push   $0x29
  jmp alltraps
80106dec:	e9 d9 f6 ff ff       	jmp    801064ca <alltraps>

80106df1 <vector42>:
.globl vector42
vector42:
  pushl $0
80106df1:	6a 00                	push   $0x0
  pushl $42
80106df3:	6a 2a                	push   $0x2a
  jmp alltraps
80106df5:	e9 d0 f6 ff ff       	jmp    801064ca <alltraps>

80106dfa <vector43>:
.globl vector43
vector43:
  pushl $0
80106dfa:	6a 00                	push   $0x0
  pushl $43
80106dfc:	6a 2b                	push   $0x2b
  jmp alltraps
80106dfe:	e9 c7 f6 ff ff       	jmp    801064ca <alltraps>

80106e03 <vector44>:
.globl vector44
vector44:
  pushl $0
80106e03:	6a 00                	push   $0x0
  pushl $44
80106e05:	6a 2c                	push   $0x2c
  jmp alltraps
80106e07:	e9 be f6 ff ff       	jmp    801064ca <alltraps>

80106e0c <vector45>:
.globl vector45
vector45:
  pushl $0
80106e0c:	6a 00                	push   $0x0
  pushl $45
80106e0e:	6a 2d                	push   $0x2d
  jmp alltraps
80106e10:	e9 b5 f6 ff ff       	jmp    801064ca <alltraps>

80106e15 <vector46>:
.globl vector46
vector46:
  pushl $0
80106e15:	6a 00                	push   $0x0
  pushl $46
80106e17:	6a 2e                	push   $0x2e
  jmp alltraps
80106e19:	e9 ac f6 ff ff       	jmp    801064ca <alltraps>

80106e1e <vector47>:
.globl vector47
vector47:
  pushl $0
80106e1e:	6a 00                	push   $0x0
  pushl $47
80106e20:	6a 2f                	push   $0x2f
  jmp alltraps
80106e22:	e9 a3 f6 ff ff       	jmp    801064ca <alltraps>

80106e27 <vector48>:
.globl vector48
vector48:
  pushl $0
80106e27:	6a 00                	push   $0x0
  pushl $48
80106e29:	6a 30                	push   $0x30
  jmp alltraps
80106e2b:	e9 9a f6 ff ff       	jmp    801064ca <alltraps>

80106e30 <vector49>:
.globl vector49
vector49:
  pushl $0
80106e30:	6a 00                	push   $0x0
  pushl $49
80106e32:	6a 31                	push   $0x31
  jmp alltraps
80106e34:	e9 91 f6 ff ff       	jmp    801064ca <alltraps>

80106e39 <vector50>:
.globl vector50
vector50:
  pushl $0
80106e39:	6a 00                	push   $0x0
  pushl $50
80106e3b:	6a 32                	push   $0x32
  jmp alltraps
80106e3d:	e9 88 f6 ff ff       	jmp    801064ca <alltraps>

80106e42 <vector51>:
.globl vector51
vector51:
  pushl $0
80106e42:	6a 00                	push   $0x0
  pushl $51
80106e44:	6a 33                	push   $0x33
  jmp alltraps
80106e46:	e9 7f f6 ff ff       	jmp    801064ca <alltraps>

80106e4b <vector52>:
.globl vector52
vector52:
  pushl $0
80106e4b:	6a 00                	push   $0x0
  pushl $52
80106e4d:	6a 34                	push   $0x34
  jmp alltraps
80106e4f:	e9 76 f6 ff ff       	jmp    801064ca <alltraps>

80106e54 <vector53>:
.globl vector53
vector53:
  pushl $0
80106e54:	6a 00                	push   $0x0
  pushl $53
80106e56:	6a 35                	push   $0x35
  jmp alltraps
80106e58:	e9 6d f6 ff ff       	jmp    801064ca <alltraps>

80106e5d <vector54>:
.globl vector54
vector54:
  pushl $0
80106e5d:	6a 00                	push   $0x0
  pushl $54
80106e5f:	6a 36                	push   $0x36
  jmp alltraps
80106e61:	e9 64 f6 ff ff       	jmp    801064ca <alltraps>

80106e66 <vector55>:
.globl vector55
vector55:
  pushl $0
80106e66:	6a 00                	push   $0x0
  pushl $55
80106e68:	6a 37                	push   $0x37
  jmp alltraps
80106e6a:	e9 5b f6 ff ff       	jmp    801064ca <alltraps>

80106e6f <vector56>:
.globl vector56
vector56:
  pushl $0
80106e6f:	6a 00                	push   $0x0
  pushl $56
80106e71:	6a 38                	push   $0x38
  jmp alltraps
80106e73:	e9 52 f6 ff ff       	jmp    801064ca <alltraps>

80106e78 <vector57>:
.globl vector57
vector57:
  pushl $0
80106e78:	6a 00                	push   $0x0
  pushl $57
80106e7a:	6a 39                	push   $0x39
  jmp alltraps
80106e7c:	e9 49 f6 ff ff       	jmp    801064ca <alltraps>

80106e81 <vector58>:
.globl vector58
vector58:
  pushl $0
80106e81:	6a 00                	push   $0x0
  pushl $58
80106e83:	6a 3a                	push   $0x3a
  jmp alltraps
80106e85:	e9 40 f6 ff ff       	jmp    801064ca <alltraps>

80106e8a <vector59>:
.globl vector59
vector59:
  pushl $0
80106e8a:	6a 00                	push   $0x0
  pushl $59
80106e8c:	6a 3b                	push   $0x3b
  jmp alltraps
80106e8e:	e9 37 f6 ff ff       	jmp    801064ca <alltraps>

80106e93 <vector60>:
.globl vector60
vector60:
  pushl $0
80106e93:	6a 00                	push   $0x0
  pushl $60
80106e95:	6a 3c                	push   $0x3c
  jmp alltraps
80106e97:	e9 2e f6 ff ff       	jmp    801064ca <alltraps>

80106e9c <vector61>:
.globl vector61
vector61:
  pushl $0
80106e9c:	6a 00                	push   $0x0
  pushl $61
80106e9e:	6a 3d                	push   $0x3d
  jmp alltraps
80106ea0:	e9 25 f6 ff ff       	jmp    801064ca <alltraps>

80106ea5 <vector62>:
.globl vector62
vector62:
  pushl $0
80106ea5:	6a 00                	push   $0x0
  pushl $62
80106ea7:	6a 3e                	push   $0x3e
  jmp alltraps
80106ea9:	e9 1c f6 ff ff       	jmp    801064ca <alltraps>

80106eae <vector63>:
.globl vector63
vector63:
  pushl $0
80106eae:	6a 00                	push   $0x0
  pushl $63
80106eb0:	6a 3f                	push   $0x3f
  jmp alltraps
80106eb2:	e9 13 f6 ff ff       	jmp    801064ca <alltraps>

80106eb7 <vector64>:
.globl vector64
vector64:
  pushl $0
80106eb7:	6a 00                	push   $0x0
  pushl $64
80106eb9:	6a 40                	push   $0x40
  jmp alltraps
80106ebb:	e9 0a f6 ff ff       	jmp    801064ca <alltraps>

80106ec0 <vector65>:
.globl vector65
vector65:
  pushl $0
80106ec0:	6a 00                	push   $0x0
  pushl $65
80106ec2:	6a 41                	push   $0x41
  jmp alltraps
80106ec4:	e9 01 f6 ff ff       	jmp    801064ca <alltraps>

80106ec9 <vector66>:
.globl vector66
vector66:
  pushl $0
80106ec9:	6a 00                	push   $0x0
  pushl $66
80106ecb:	6a 42                	push   $0x42
  jmp alltraps
80106ecd:	e9 f8 f5 ff ff       	jmp    801064ca <alltraps>

80106ed2 <vector67>:
.globl vector67
vector67:
  pushl $0
80106ed2:	6a 00                	push   $0x0
  pushl $67
80106ed4:	6a 43                	push   $0x43
  jmp alltraps
80106ed6:	e9 ef f5 ff ff       	jmp    801064ca <alltraps>

80106edb <vector68>:
.globl vector68
vector68:
  pushl $0
80106edb:	6a 00                	push   $0x0
  pushl $68
80106edd:	6a 44                	push   $0x44
  jmp alltraps
80106edf:	e9 e6 f5 ff ff       	jmp    801064ca <alltraps>

80106ee4 <vector69>:
.globl vector69
vector69:
  pushl $0
80106ee4:	6a 00                	push   $0x0
  pushl $69
80106ee6:	6a 45                	push   $0x45
  jmp alltraps
80106ee8:	e9 dd f5 ff ff       	jmp    801064ca <alltraps>

80106eed <vector70>:
.globl vector70
vector70:
  pushl $0
80106eed:	6a 00                	push   $0x0
  pushl $70
80106eef:	6a 46                	push   $0x46
  jmp alltraps
80106ef1:	e9 d4 f5 ff ff       	jmp    801064ca <alltraps>

80106ef6 <vector71>:
.globl vector71
vector71:
  pushl $0
80106ef6:	6a 00                	push   $0x0
  pushl $71
80106ef8:	6a 47                	push   $0x47
  jmp alltraps
80106efa:	e9 cb f5 ff ff       	jmp    801064ca <alltraps>

80106eff <vector72>:
.globl vector72
vector72:
  pushl $0
80106eff:	6a 00                	push   $0x0
  pushl $72
80106f01:	6a 48                	push   $0x48
  jmp alltraps
80106f03:	e9 c2 f5 ff ff       	jmp    801064ca <alltraps>

80106f08 <vector73>:
.globl vector73
vector73:
  pushl $0
80106f08:	6a 00                	push   $0x0
  pushl $73
80106f0a:	6a 49                	push   $0x49
  jmp alltraps
80106f0c:	e9 b9 f5 ff ff       	jmp    801064ca <alltraps>

80106f11 <vector74>:
.globl vector74
vector74:
  pushl $0
80106f11:	6a 00                	push   $0x0
  pushl $74
80106f13:	6a 4a                	push   $0x4a
  jmp alltraps
80106f15:	e9 b0 f5 ff ff       	jmp    801064ca <alltraps>

80106f1a <vector75>:
.globl vector75
vector75:
  pushl $0
80106f1a:	6a 00                	push   $0x0
  pushl $75
80106f1c:	6a 4b                	push   $0x4b
  jmp alltraps
80106f1e:	e9 a7 f5 ff ff       	jmp    801064ca <alltraps>

80106f23 <vector76>:
.globl vector76
vector76:
  pushl $0
80106f23:	6a 00                	push   $0x0
  pushl $76
80106f25:	6a 4c                	push   $0x4c
  jmp alltraps
80106f27:	e9 9e f5 ff ff       	jmp    801064ca <alltraps>

80106f2c <vector77>:
.globl vector77
vector77:
  pushl $0
80106f2c:	6a 00                	push   $0x0
  pushl $77
80106f2e:	6a 4d                	push   $0x4d
  jmp alltraps
80106f30:	e9 95 f5 ff ff       	jmp    801064ca <alltraps>

80106f35 <vector78>:
.globl vector78
vector78:
  pushl $0
80106f35:	6a 00                	push   $0x0
  pushl $78
80106f37:	6a 4e                	push   $0x4e
  jmp alltraps
80106f39:	e9 8c f5 ff ff       	jmp    801064ca <alltraps>

80106f3e <vector79>:
.globl vector79
vector79:
  pushl $0
80106f3e:	6a 00                	push   $0x0
  pushl $79
80106f40:	6a 4f                	push   $0x4f
  jmp alltraps
80106f42:	e9 83 f5 ff ff       	jmp    801064ca <alltraps>

80106f47 <vector80>:
.globl vector80
vector80:
  pushl $0
80106f47:	6a 00                	push   $0x0
  pushl $80
80106f49:	6a 50                	push   $0x50
  jmp alltraps
80106f4b:	e9 7a f5 ff ff       	jmp    801064ca <alltraps>

80106f50 <vector81>:
.globl vector81
vector81:
  pushl $0
80106f50:	6a 00                	push   $0x0
  pushl $81
80106f52:	6a 51                	push   $0x51
  jmp alltraps
80106f54:	e9 71 f5 ff ff       	jmp    801064ca <alltraps>

80106f59 <vector82>:
.globl vector82
vector82:
  pushl $0
80106f59:	6a 00                	push   $0x0
  pushl $82
80106f5b:	6a 52                	push   $0x52
  jmp alltraps
80106f5d:	e9 68 f5 ff ff       	jmp    801064ca <alltraps>

80106f62 <vector83>:
.globl vector83
vector83:
  pushl $0
80106f62:	6a 00                	push   $0x0
  pushl $83
80106f64:	6a 53                	push   $0x53
  jmp alltraps
80106f66:	e9 5f f5 ff ff       	jmp    801064ca <alltraps>

80106f6b <vector84>:
.globl vector84
vector84:
  pushl $0
80106f6b:	6a 00                	push   $0x0
  pushl $84
80106f6d:	6a 54                	push   $0x54
  jmp alltraps
80106f6f:	e9 56 f5 ff ff       	jmp    801064ca <alltraps>

80106f74 <vector85>:
.globl vector85
vector85:
  pushl $0
80106f74:	6a 00                	push   $0x0
  pushl $85
80106f76:	6a 55                	push   $0x55
  jmp alltraps
80106f78:	e9 4d f5 ff ff       	jmp    801064ca <alltraps>

80106f7d <vector86>:
.globl vector86
vector86:
  pushl $0
80106f7d:	6a 00                	push   $0x0
  pushl $86
80106f7f:	6a 56                	push   $0x56
  jmp alltraps
80106f81:	e9 44 f5 ff ff       	jmp    801064ca <alltraps>

80106f86 <vector87>:
.globl vector87
vector87:
  pushl $0
80106f86:	6a 00                	push   $0x0
  pushl $87
80106f88:	6a 57                	push   $0x57
  jmp alltraps
80106f8a:	e9 3b f5 ff ff       	jmp    801064ca <alltraps>

80106f8f <vector88>:
.globl vector88
vector88:
  pushl $0
80106f8f:	6a 00                	push   $0x0
  pushl $88
80106f91:	6a 58                	push   $0x58
  jmp alltraps
80106f93:	e9 32 f5 ff ff       	jmp    801064ca <alltraps>

80106f98 <vector89>:
.globl vector89
vector89:
  pushl $0
80106f98:	6a 00                	push   $0x0
  pushl $89
80106f9a:	6a 59                	push   $0x59
  jmp alltraps
80106f9c:	e9 29 f5 ff ff       	jmp    801064ca <alltraps>

80106fa1 <vector90>:
.globl vector90
vector90:
  pushl $0
80106fa1:	6a 00                	push   $0x0
  pushl $90
80106fa3:	6a 5a                	push   $0x5a
  jmp alltraps
80106fa5:	e9 20 f5 ff ff       	jmp    801064ca <alltraps>

80106faa <vector91>:
.globl vector91
vector91:
  pushl $0
80106faa:	6a 00                	push   $0x0
  pushl $91
80106fac:	6a 5b                	push   $0x5b
  jmp alltraps
80106fae:	e9 17 f5 ff ff       	jmp    801064ca <alltraps>

80106fb3 <vector92>:
.globl vector92
vector92:
  pushl $0
80106fb3:	6a 00                	push   $0x0
  pushl $92
80106fb5:	6a 5c                	push   $0x5c
  jmp alltraps
80106fb7:	e9 0e f5 ff ff       	jmp    801064ca <alltraps>

80106fbc <vector93>:
.globl vector93
vector93:
  pushl $0
80106fbc:	6a 00                	push   $0x0
  pushl $93
80106fbe:	6a 5d                	push   $0x5d
  jmp alltraps
80106fc0:	e9 05 f5 ff ff       	jmp    801064ca <alltraps>

80106fc5 <vector94>:
.globl vector94
vector94:
  pushl $0
80106fc5:	6a 00                	push   $0x0
  pushl $94
80106fc7:	6a 5e                	push   $0x5e
  jmp alltraps
80106fc9:	e9 fc f4 ff ff       	jmp    801064ca <alltraps>

80106fce <vector95>:
.globl vector95
vector95:
  pushl $0
80106fce:	6a 00                	push   $0x0
  pushl $95
80106fd0:	6a 5f                	push   $0x5f
  jmp alltraps
80106fd2:	e9 f3 f4 ff ff       	jmp    801064ca <alltraps>

80106fd7 <vector96>:
.globl vector96
vector96:
  pushl $0
80106fd7:	6a 00                	push   $0x0
  pushl $96
80106fd9:	6a 60                	push   $0x60
  jmp alltraps
80106fdb:	e9 ea f4 ff ff       	jmp    801064ca <alltraps>

80106fe0 <vector97>:
.globl vector97
vector97:
  pushl $0
80106fe0:	6a 00                	push   $0x0
  pushl $97
80106fe2:	6a 61                	push   $0x61
  jmp alltraps
80106fe4:	e9 e1 f4 ff ff       	jmp    801064ca <alltraps>

80106fe9 <vector98>:
.globl vector98
vector98:
  pushl $0
80106fe9:	6a 00                	push   $0x0
  pushl $98
80106feb:	6a 62                	push   $0x62
  jmp alltraps
80106fed:	e9 d8 f4 ff ff       	jmp    801064ca <alltraps>

80106ff2 <vector99>:
.globl vector99
vector99:
  pushl $0
80106ff2:	6a 00                	push   $0x0
  pushl $99
80106ff4:	6a 63                	push   $0x63
  jmp alltraps
80106ff6:	e9 cf f4 ff ff       	jmp    801064ca <alltraps>

80106ffb <vector100>:
.globl vector100
vector100:
  pushl $0
80106ffb:	6a 00                	push   $0x0
  pushl $100
80106ffd:	6a 64                	push   $0x64
  jmp alltraps
80106fff:	e9 c6 f4 ff ff       	jmp    801064ca <alltraps>

80107004 <vector101>:
.globl vector101
vector101:
  pushl $0
80107004:	6a 00                	push   $0x0
  pushl $101
80107006:	6a 65                	push   $0x65
  jmp alltraps
80107008:	e9 bd f4 ff ff       	jmp    801064ca <alltraps>

8010700d <vector102>:
.globl vector102
vector102:
  pushl $0
8010700d:	6a 00                	push   $0x0
  pushl $102
8010700f:	6a 66                	push   $0x66
  jmp alltraps
80107011:	e9 b4 f4 ff ff       	jmp    801064ca <alltraps>

80107016 <vector103>:
.globl vector103
vector103:
  pushl $0
80107016:	6a 00                	push   $0x0
  pushl $103
80107018:	6a 67                	push   $0x67
  jmp alltraps
8010701a:	e9 ab f4 ff ff       	jmp    801064ca <alltraps>

8010701f <vector104>:
.globl vector104
vector104:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $104
80107021:	6a 68                	push   $0x68
  jmp alltraps
80107023:	e9 a2 f4 ff ff       	jmp    801064ca <alltraps>

80107028 <vector105>:
.globl vector105
vector105:
  pushl $0
80107028:	6a 00                	push   $0x0
  pushl $105
8010702a:	6a 69                	push   $0x69
  jmp alltraps
8010702c:	e9 99 f4 ff ff       	jmp    801064ca <alltraps>

80107031 <vector106>:
.globl vector106
vector106:
  pushl $0
80107031:	6a 00                	push   $0x0
  pushl $106
80107033:	6a 6a                	push   $0x6a
  jmp alltraps
80107035:	e9 90 f4 ff ff       	jmp    801064ca <alltraps>

8010703a <vector107>:
.globl vector107
vector107:
  pushl $0
8010703a:	6a 00                	push   $0x0
  pushl $107
8010703c:	6a 6b                	push   $0x6b
  jmp alltraps
8010703e:	e9 87 f4 ff ff       	jmp    801064ca <alltraps>

80107043 <vector108>:
.globl vector108
vector108:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $108
80107045:	6a 6c                	push   $0x6c
  jmp alltraps
80107047:	e9 7e f4 ff ff       	jmp    801064ca <alltraps>

8010704c <vector109>:
.globl vector109
vector109:
  pushl $0
8010704c:	6a 00                	push   $0x0
  pushl $109
8010704e:	6a 6d                	push   $0x6d
  jmp alltraps
80107050:	e9 75 f4 ff ff       	jmp    801064ca <alltraps>

80107055 <vector110>:
.globl vector110
vector110:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $110
80107057:	6a 6e                	push   $0x6e
  jmp alltraps
80107059:	e9 6c f4 ff ff       	jmp    801064ca <alltraps>

8010705e <vector111>:
.globl vector111
vector111:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $111
80107060:	6a 6f                	push   $0x6f
  jmp alltraps
80107062:	e9 63 f4 ff ff       	jmp    801064ca <alltraps>

80107067 <vector112>:
.globl vector112
vector112:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $112
80107069:	6a 70                	push   $0x70
  jmp alltraps
8010706b:	e9 5a f4 ff ff       	jmp    801064ca <alltraps>

80107070 <vector113>:
.globl vector113
vector113:
  pushl $0
80107070:	6a 00                	push   $0x0
  pushl $113
80107072:	6a 71                	push   $0x71
  jmp alltraps
80107074:	e9 51 f4 ff ff       	jmp    801064ca <alltraps>

80107079 <vector114>:
.globl vector114
vector114:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $114
8010707b:	6a 72                	push   $0x72
  jmp alltraps
8010707d:	e9 48 f4 ff ff       	jmp    801064ca <alltraps>

80107082 <vector115>:
.globl vector115
vector115:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $115
80107084:	6a 73                	push   $0x73
  jmp alltraps
80107086:	e9 3f f4 ff ff       	jmp    801064ca <alltraps>

8010708b <vector116>:
.globl vector116
vector116:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $116
8010708d:	6a 74                	push   $0x74
  jmp alltraps
8010708f:	e9 36 f4 ff ff       	jmp    801064ca <alltraps>

80107094 <vector117>:
.globl vector117
vector117:
  pushl $0
80107094:	6a 00                	push   $0x0
  pushl $117
80107096:	6a 75                	push   $0x75
  jmp alltraps
80107098:	e9 2d f4 ff ff       	jmp    801064ca <alltraps>

8010709d <vector118>:
.globl vector118
vector118:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $118
8010709f:	6a 76                	push   $0x76
  jmp alltraps
801070a1:	e9 24 f4 ff ff       	jmp    801064ca <alltraps>

801070a6 <vector119>:
.globl vector119
vector119:
  pushl $0
801070a6:	6a 00                	push   $0x0
  pushl $119
801070a8:	6a 77                	push   $0x77
  jmp alltraps
801070aa:	e9 1b f4 ff ff       	jmp    801064ca <alltraps>

801070af <vector120>:
.globl vector120
vector120:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $120
801070b1:	6a 78                	push   $0x78
  jmp alltraps
801070b3:	e9 12 f4 ff ff       	jmp    801064ca <alltraps>

801070b8 <vector121>:
.globl vector121
vector121:
  pushl $0
801070b8:	6a 00                	push   $0x0
  pushl $121
801070ba:	6a 79                	push   $0x79
  jmp alltraps
801070bc:	e9 09 f4 ff ff       	jmp    801064ca <alltraps>

801070c1 <vector122>:
.globl vector122
vector122:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $122
801070c3:	6a 7a                	push   $0x7a
  jmp alltraps
801070c5:	e9 00 f4 ff ff       	jmp    801064ca <alltraps>

801070ca <vector123>:
.globl vector123
vector123:
  pushl $0
801070ca:	6a 00                	push   $0x0
  pushl $123
801070cc:	6a 7b                	push   $0x7b
  jmp alltraps
801070ce:	e9 f7 f3 ff ff       	jmp    801064ca <alltraps>

801070d3 <vector124>:
.globl vector124
vector124:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $124
801070d5:	6a 7c                	push   $0x7c
  jmp alltraps
801070d7:	e9 ee f3 ff ff       	jmp    801064ca <alltraps>

801070dc <vector125>:
.globl vector125
vector125:
  pushl $0
801070dc:	6a 00                	push   $0x0
  pushl $125
801070de:	6a 7d                	push   $0x7d
  jmp alltraps
801070e0:	e9 e5 f3 ff ff       	jmp    801064ca <alltraps>

801070e5 <vector126>:
.globl vector126
vector126:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $126
801070e7:	6a 7e                	push   $0x7e
  jmp alltraps
801070e9:	e9 dc f3 ff ff       	jmp    801064ca <alltraps>

801070ee <vector127>:
.globl vector127
vector127:
  pushl $0
801070ee:	6a 00                	push   $0x0
  pushl $127
801070f0:	6a 7f                	push   $0x7f
  jmp alltraps
801070f2:	e9 d3 f3 ff ff       	jmp    801064ca <alltraps>

801070f7 <vector128>:
.globl vector128
vector128:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $128
801070f9:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801070fe:	e9 c7 f3 ff ff       	jmp    801064ca <alltraps>

80107103 <vector129>:
.globl vector129
vector129:
  pushl $0
80107103:	6a 00                	push   $0x0
  pushl $129
80107105:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010710a:	e9 bb f3 ff ff       	jmp    801064ca <alltraps>

8010710f <vector130>:
.globl vector130
vector130:
  pushl $0
8010710f:	6a 00                	push   $0x0
  pushl $130
80107111:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107116:	e9 af f3 ff ff       	jmp    801064ca <alltraps>

8010711b <vector131>:
.globl vector131
vector131:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $131
8010711d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107122:	e9 a3 f3 ff ff       	jmp    801064ca <alltraps>

80107127 <vector132>:
.globl vector132
vector132:
  pushl $0
80107127:	6a 00                	push   $0x0
  pushl $132
80107129:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010712e:	e9 97 f3 ff ff       	jmp    801064ca <alltraps>

80107133 <vector133>:
.globl vector133
vector133:
  pushl $0
80107133:	6a 00                	push   $0x0
  pushl $133
80107135:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010713a:	e9 8b f3 ff ff       	jmp    801064ca <alltraps>

8010713f <vector134>:
.globl vector134
vector134:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $134
80107141:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107146:	e9 7f f3 ff ff       	jmp    801064ca <alltraps>

8010714b <vector135>:
.globl vector135
vector135:
  pushl $0
8010714b:	6a 00                	push   $0x0
  pushl $135
8010714d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107152:	e9 73 f3 ff ff       	jmp    801064ca <alltraps>

80107157 <vector136>:
.globl vector136
vector136:
  pushl $0
80107157:	6a 00                	push   $0x0
  pushl $136
80107159:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010715e:	e9 67 f3 ff ff       	jmp    801064ca <alltraps>

80107163 <vector137>:
.globl vector137
vector137:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $137
80107165:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010716a:	e9 5b f3 ff ff       	jmp    801064ca <alltraps>

8010716f <vector138>:
.globl vector138
vector138:
  pushl $0
8010716f:	6a 00                	push   $0x0
  pushl $138
80107171:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107176:	e9 4f f3 ff ff       	jmp    801064ca <alltraps>

8010717b <vector139>:
.globl vector139
vector139:
  pushl $0
8010717b:	6a 00                	push   $0x0
  pushl $139
8010717d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107182:	e9 43 f3 ff ff       	jmp    801064ca <alltraps>

80107187 <vector140>:
.globl vector140
vector140:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $140
80107189:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010718e:	e9 37 f3 ff ff       	jmp    801064ca <alltraps>

80107193 <vector141>:
.globl vector141
vector141:
  pushl $0
80107193:	6a 00                	push   $0x0
  pushl $141
80107195:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010719a:	e9 2b f3 ff ff       	jmp    801064ca <alltraps>

8010719f <vector142>:
.globl vector142
vector142:
  pushl $0
8010719f:	6a 00                	push   $0x0
  pushl $142
801071a1:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801071a6:	e9 1f f3 ff ff       	jmp    801064ca <alltraps>

801071ab <vector143>:
.globl vector143
vector143:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $143
801071ad:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801071b2:	e9 13 f3 ff ff       	jmp    801064ca <alltraps>

801071b7 <vector144>:
.globl vector144
vector144:
  pushl $0
801071b7:	6a 00                	push   $0x0
  pushl $144
801071b9:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801071be:	e9 07 f3 ff ff       	jmp    801064ca <alltraps>

801071c3 <vector145>:
.globl vector145
vector145:
  pushl $0
801071c3:	6a 00                	push   $0x0
  pushl $145
801071c5:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801071ca:	e9 fb f2 ff ff       	jmp    801064ca <alltraps>

801071cf <vector146>:
.globl vector146
vector146:
  pushl $0
801071cf:	6a 00                	push   $0x0
  pushl $146
801071d1:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801071d6:	e9 ef f2 ff ff       	jmp    801064ca <alltraps>

801071db <vector147>:
.globl vector147
vector147:
  pushl $0
801071db:	6a 00                	push   $0x0
  pushl $147
801071dd:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801071e2:	e9 e3 f2 ff ff       	jmp    801064ca <alltraps>

801071e7 <vector148>:
.globl vector148
vector148:
  pushl $0
801071e7:	6a 00                	push   $0x0
  pushl $148
801071e9:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801071ee:	e9 d7 f2 ff ff       	jmp    801064ca <alltraps>

801071f3 <vector149>:
.globl vector149
vector149:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $149
801071f5:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801071fa:	e9 cb f2 ff ff       	jmp    801064ca <alltraps>

801071ff <vector150>:
.globl vector150
vector150:
  pushl $0
801071ff:	6a 00                	push   $0x0
  pushl $150
80107201:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107206:	e9 bf f2 ff ff       	jmp    801064ca <alltraps>

8010720b <vector151>:
.globl vector151
vector151:
  pushl $0
8010720b:	6a 00                	push   $0x0
  pushl $151
8010720d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107212:	e9 b3 f2 ff ff       	jmp    801064ca <alltraps>

80107217 <vector152>:
.globl vector152
vector152:
  pushl $0
80107217:	6a 00                	push   $0x0
  pushl $152
80107219:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010721e:	e9 a7 f2 ff ff       	jmp    801064ca <alltraps>

80107223 <vector153>:
.globl vector153
vector153:
  pushl $0
80107223:	6a 00                	push   $0x0
  pushl $153
80107225:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010722a:	e9 9b f2 ff ff       	jmp    801064ca <alltraps>

8010722f <vector154>:
.globl vector154
vector154:
  pushl $0
8010722f:	6a 00                	push   $0x0
  pushl $154
80107231:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107236:	e9 8f f2 ff ff       	jmp    801064ca <alltraps>

8010723b <vector155>:
.globl vector155
vector155:
  pushl $0
8010723b:	6a 00                	push   $0x0
  pushl $155
8010723d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107242:	e9 83 f2 ff ff       	jmp    801064ca <alltraps>

80107247 <vector156>:
.globl vector156
vector156:
  pushl $0
80107247:	6a 00                	push   $0x0
  pushl $156
80107249:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010724e:	e9 77 f2 ff ff       	jmp    801064ca <alltraps>

80107253 <vector157>:
.globl vector157
vector157:
  pushl $0
80107253:	6a 00                	push   $0x0
  pushl $157
80107255:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010725a:	e9 6b f2 ff ff       	jmp    801064ca <alltraps>

8010725f <vector158>:
.globl vector158
vector158:
  pushl $0
8010725f:	6a 00                	push   $0x0
  pushl $158
80107261:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107266:	e9 5f f2 ff ff       	jmp    801064ca <alltraps>

8010726b <vector159>:
.globl vector159
vector159:
  pushl $0
8010726b:	6a 00                	push   $0x0
  pushl $159
8010726d:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107272:	e9 53 f2 ff ff       	jmp    801064ca <alltraps>

80107277 <vector160>:
.globl vector160
vector160:
  pushl $0
80107277:	6a 00                	push   $0x0
  pushl $160
80107279:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010727e:	e9 47 f2 ff ff       	jmp    801064ca <alltraps>

80107283 <vector161>:
.globl vector161
vector161:
  pushl $0
80107283:	6a 00                	push   $0x0
  pushl $161
80107285:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010728a:	e9 3b f2 ff ff       	jmp    801064ca <alltraps>

8010728f <vector162>:
.globl vector162
vector162:
  pushl $0
8010728f:	6a 00                	push   $0x0
  pushl $162
80107291:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107296:	e9 2f f2 ff ff       	jmp    801064ca <alltraps>

8010729b <vector163>:
.globl vector163
vector163:
  pushl $0
8010729b:	6a 00                	push   $0x0
  pushl $163
8010729d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801072a2:	e9 23 f2 ff ff       	jmp    801064ca <alltraps>

801072a7 <vector164>:
.globl vector164
vector164:
  pushl $0
801072a7:	6a 00                	push   $0x0
  pushl $164
801072a9:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801072ae:	e9 17 f2 ff ff       	jmp    801064ca <alltraps>

801072b3 <vector165>:
.globl vector165
vector165:
  pushl $0
801072b3:	6a 00                	push   $0x0
  pushl $165
801072b5:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801072ba:	e9 0b f2 ff ff       	jmp    801064ca <alltraps>

801072bf <vector166>:
.globl vector166
vector166:
  pushl $0
801072bf:	6a 00                	push   $0x0
  pushl $166
801072c1:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801072c6:	e9 ff f1 ff ff       	jmp    801064ca <alltraps>

801072cb <vector167>:
.globl vector167
vector167:
  pushl $0
801072cb:	6a 00                	push   $0x0
  pushl $167
801072cd:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801072d2:	e9 f3 f1 ff ff       	jmp    801064ca <alltraps>

801072d7 <vector168>:
.globl vector168
vector168:
  pushl $0
801072d7:	6a 00                	push   $0x0
  pushl $168
801072d9:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801072de:	e9 e7 f1 ff ff       	jmp    801064ca <alltraps>

801072e3 <vector169>:
.globl vector169
vector169:
  pushl $0
801072e3:	6a 00                	push   $0x0
  pushl $169
801072e5:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801072ea:	e9 db f1 ff ff       	jmp    801064ca <alltraps>

801072ef <vector170>:
.globl vector170
vector170:
  pushl $0
801072ef:	6a 00                	push   $0x0
  pushl $170
801072f1:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801072f6:	e9 cf f1 ff ff       	jmp    801064ca <alltraps>

801072fb <vector171>:
.globl vector171
vector171:
  pushl $0
801072fb:	6a 00                	push   $0x0
  pushl $171
801072fd:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107302:	e9 c3 f1 ff ff       	jmp    801064ca <alltraps>

80107307 <vector172>:
.globl vector172
vector172:
  pushl $0
80107307:	6a 00                	push   $0x0
  pushl $172
80107309:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010730e:	e9 b7 f1 ff ff       	jmp    801064ca <alltraps>

80107313 <vector173>:
.globl vector173
vector173:
  pushl $0
80107313:	6a 00                	push   $0x0
  pushl $173
80107315:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010731a:	e9 ab f1 ff ff       	jmp    801064ca <alltraps>

8010731f <vector174>:
.globl vector174
vector174:
  pushl $0
8010731f:	6a 00                	push   $0x0
  pushl $174
80107321:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107326:	e9 9f f1 ff ff       	jmp    801064ca <alltraps>

8010732b <vector175>:
.globl vector175
vector175:
  pushl $0
8010732b:	6a 00                	push   $0x0
  pushl $175
8010732d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107332:	e9 93 f1 ff ff       	jmp    801064ca <alltraps>

80107337 <vector176>:
.globl vector176
vector176:
  pushl $0
80107337:	6a 00                	push   $0x0
  pushl $176
80107339:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010733e:	e9 87 f1 ff ff       	jmp    801064ca <alltraps>

80107343 <vector177>:
.globl vector177
vector177:
  pushl $0
80107343:	6a 00                	push   $0x0
  pushl $177
80107345:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010734a:	e9 7b f1 ff ff       	jmp    801064ca <alltraps>

8010734f <vector178>:
.globl vector178
vector178:
  pushl $0
8010734f:	6a 00                	push   $0x0
  pushl $178
80107351:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107356:	e9 6f f1 ff ff       	jmp    801064ca <alltraps>

8010735b <vector179>:
.globl vector179
vector179:
  pushl $0
8010735b:	6a 00                	push   $0x0
  pushl $179
8010735d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107362:	e9 63 f1 ff ff       	jmp    801064ca <alltraps>

80107367 <vector180>:
.globl vector180
vector180:
  pushl $0
80107367:	6a 00                	push   $0x0
  pushl $180
80107369:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010736e:	e9 57 f1 ff ff       	jmp    801064ca <alltraps>

80107373 <vector181>:
.globl vector181
vector181:
  pushl $0
80107373:	6a 00                	push   $0x0
  pushl $181
80107375:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010737a:	e9 4b f1 ff ff       	jmp    801064ca <alltraps>

8010737f <vector182>:
.globl vector182
vector182:
  pushl $0
8010737f:	6a 00                	push   $0x0
  pushl $182
80107381:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107386:	e9 3f f1 ff ff       	jmp    801064ca <alltraps>

8010738b <vector183>:
.globl vector183
vector183:
  pushl $0
8010738b:	6a 00                	push   $0x0
  pushl $183
8010738d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107392:	e9 33 f1 ff ff       	jmp    801064ca <alltraps>

80107397 <vector184>:
.globl vector184
vector184:
  pushl $0
80107397:	6a 00                	push   $0x0
  pushl $184
80107399:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010739e:	e9 27 f1 ff ff       	jmp    801064ca <alltraps>

801073a3 <vector185>:
.globl vector185
vector185:
  pushl $0
801073a3:	6a 00                	push   $0x0
  pushl $185
801073a5:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801073aa:	e9 1b f1 ff ff       	jmp    801064ca <alltraps>

801073af <vector186>:
.globl vector186
vector186:
  pushl $0
801073af:	6a 00                	push   $0x0
  pushl $186
801073b1:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801073b6:	e9 0f f1 ff ff       	jmp    801064ca <alltraps>

801073bb <vector187>:
.globl vector187
vector187:
  pushl $0
801073bb:	6a 00                	push   $0x0
  pushl $187
801073bd:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801073c2:	e9 03 f1 ff ff       	jmp    801064ca <alltraps>

801073c7 <vector188>:
.globl vector188
vector188:
  pushl $0
801073c7:	6a 00                	push   $0x0
  pushl $188
801073c9:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801073ce:	e9 f7 f0 ff ff       	jmp    801064ca <alltraps>

801073d3 <vector189>:
.globl vector189
vector189:
  pushl $0
801073d3:	6a 00                	push   $0x0
  pushl $189
801073d5:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801073da:	e9 eb f0 ff ff       	jmp    801064ca <alltraps>

801073df <vector190>:
.globl vector190
vector190:
  pushl $0
801073df:	6a 00                	push   $0x0
  pushl $190
801073e1:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801073e6:	e9 df f0 ff ff       	jmp    801064ca <alltraps>

801073eb <vector191>:
.globl vector191
vector191:
  pushl $0
801073eb:	6a 00                	push   $0x0
  pushl $191
801073ed:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801073f2:	e9 d3 f0 ff ff       	jmp    801064ca <alltraps>

801073f7 <vector192>:
.globl vector192
vector192:
  pushl $0
801073f7:	6a 00                	push   $0x0
  pushl $192
801073f9:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801073fe:	e9 c7 f0 ff ff       	jmp    801064ca <alltraps>

80107403 <vector193>:
.globl vector193
vector193:
  pushl $0
80107403:	6a 00                	push   $0x0
  pushl $193
80107405:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010740a:	e9 bb f0 ff ff       	jmp    801064ca <alltraps>

8010740f <vector194>:
.globl vector194
vector194:
  pushl $0
8010740f:	6a 00                	push   $0x0
  pushl $194
80107411:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107416:	e9 af f0 ff ff       	jmp    801064ca <alltraps>

8010741b <vector195>:
.globl vector195
vector195:
  pushl $0
8010741b:	6a 00                	push   $0x0
  pushl $195
8010741d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107422:	e9 a3 f0 ff ff       	jmp    801064ca <alltraps>

80107427 <vector196>:
.globl vector196
vector196:
  pushl $0
80107427:	6a 00                	push   $0x0
  pushl $196
80107429:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010742e:	e9 97 f0 ff ff       	jmp    801064ca <alltraps>

80107433 <vector197>:
.globl vector197
vector197:
  pushl $0
80107433:	6a 00                	push   $0x0
  pushl $197
80107435:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010743a:	e9 8b f0 ff ff       	jmp    801064ca <alltraps>

8010743f <vector198>:
.globl vector198
vector198:
  pushl $0
8010743f:	6a 00                	push   $0x0
  pushl $198
80107441:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107446:	e9 7f f0 ff ff       	jmp    801064ca <alltraps>

8010744b <vector199>:
.globl vector199
vector199:
  pushl $0
8010744b:	6a 00                	push   $0x0
  pushl $199
8010744d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107452:	e9 73 f0 ff ff       	jmp    801064ca <alltraps>

80107457 <vector200>:
.globl vector200
vector200:
  pushl $0
80107457:	6a 00                	push   $0x0
  pushl $200
80107459:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010745e:	e9 67 f0 ff ff       	jmp    801064ca <alltraps>

80107463 <vector201>:
.globl vector201
vector201:
  pushl $0
80107463:	6a 00                	push   $0x0
  pushl $201
80107465:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010746a:	e9 5b f0 ff ff       	jmp    801064ca <alltraps>

8010746f <vector202>:
.globl vector202
vector202:
  pushl $0
8010746f:	6a 00                	push   $0x0
  pushl $202
80107471:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107476:	e9 4f f0 ff ff       	jmp    801064ca <alltraps>

8010747b <vector203>:
.globl vector203
vector203:
  pushl $0
8010747b:	6a 00                	push   $0x0
  pushl $203
8010747d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107482:	e9 43 f0 ff ff       	jmp    801064ca <alltraps>

80107487 <vector204>:
.globl vector204
vector204:
  pushl $0
80107487:	6a 00                	push   $0x0
  pushl $204
80107489:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010748e:	e9 37 f0 ff ff       	jmp    801064ca <alltraps>

80107493 <vector205>:
.globl vector205
vector205:
  pushl $0
80107493:	6a 00                	push   $0x0
  pushl $205
80107495:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010749a:	e9 2b f0 ff ff       	jmp    801064ca <alltraps>

8010749f <vector206>:
.globl vector206
vector206:
  pushl $0
8010749f:	6a 00                	push   $0x0
  pushl $206
801074a1:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801074a6:	e9 1f f0 ff ff       	jmp    801064ca <alltraps>

801074ab <vector207>:
.globl vector207
vector207:
  pushl $0
801074ab:	6a 00                	push   $0x0
  pushl $207
801074ad:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801074b2:	e9 13 f0 ff ff       	jmp    801064ca <alltraps>

801074b7 <vector208>:
.globl vector208
vector208:
  pushl $0
801074b7:	6a 00                	push   $0x0
  pushl $208
801074b9:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801074be:	e9 07 f0 ff ff       	jmp    801064ca <alltraps>

801074c3 <vector209>:
.globl vector209
vector209:
  pushl $0
801074c3:	6a 00                	push   $0x0
  pushl $209
801074c5:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801074ca:	e9 fb ef ff ff       	jmp    801064ca <alltraps>

801074cf <vector210>:
.globl vector210
vector210:
  pushl $0
801074cf:	6a 00                	push   $0x0
  pushl $210
801074d1:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801074d6:	e9 ef ef ff ff       	jmp    801064ca <alltraps>

801074db <vector211>:
.globl vector211
vector211:
  pushl $0
801074db:	6a 00                	push   $0x0
  pushl $211
801074dd:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801074e2:	e9 e3 ef ff ff       	jmp    801064ca <alltraps>

801074e7 <vector212>:
.globl vector212
vector212:
  pushl $0
801074e7:	6a 00                	push   $0x0
  pushl $212
801074e9:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801074ee:	e9 d7 ef ff ff       	jmp    801064ca <alltraps>

801074f3 <vector213>:
.globl vector213
vector213:
  pushl $0
801074f3:	6a 00                	push   $0x0
  pushl $213
801074f5:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801074fa:	e9 cb ef ff ff       	jmp    801064ca <alltraps>

801074ff <vector214>:
.globl vector214
vector214:
  pushl $0
801074ff:	6a 00                	push   $0x0
  pushl $214
80107501:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107506:	e9 bf ef ff ff       	jmp    801064ca <alltraps>

8010750b <vector215>:
.globl vector215
vector215:
  pushl $0
8010750b:	6a 00                	push   $0x0
  pushl $215
8010750d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107512:	e9 b3 ef ff ff       	jmp    801064ca <alltraps>

80107517 <vector216>:
.globl vector216
vector216:
  pushl $0
80107517:	6a 00                	push   $0x0
  pushl $216
80107519:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010751e:	e9 a7 ef ff ff       	jmp    801064ca <alltraps>

80107523 <vector217>:
.globl vector217
vector217:
  pushl $0
80107523:	6a 00                	push   $0x0
  pushl $217
80107525:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010752a:	e9 9b ef ff ff       	jmp    801064ca <alltraps>

8010752f <vector218>:
.globl vector218
vector218:
  pushl $0
8010752f:	6a 00                	push   $0x0
  pushl $218
80107531:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107536:	e9 8f ef ff ff       	jmp    801064ca <alltraps>

8010753b <vector219>:
.globl vector219
vector219:
  pushl $0
8010753b:	6a 00                	push   $0x0
  pushl $219
8010753d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107542:	e9 83 ef ff ff       	jmp    801064ca <alltraps>

80107547 <vector220>:
.globl vector220
vector220:
  pushl $0
80107547:	6a 00                	push   $0x0
  pushl $220
80107549:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010754e:	e9 77 ef ff ff       	jmp    801064ca <alltraps>

80107553 <vector221>:
.globl vector221
vector221:
  pushl $0
80107553:	6a 00                	push   $0x0
  pushl $221
80107555:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010755a:	e9 6b ef ff ff       	jmp    801064ca <alltraps>

8010755f <vector222>:
.globl vector222
vector222:
  pushl $0
8010755f:	6a 00                	push   $0x0
  pushl $222
80107561:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107566:	e9 5f ef ff ff       	jmp    801064ca <alltraps>

8010756b <vector223>:
.globl vector223
vector223:
  pushl $0
8010756b:	6a 00                	push   $0x0
  pushl $223
8010756d:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107572:	e9 53 ef ff ff       	jmp    801064ca <alltraps>

80107577 <vector224>:
.globl vector224
vector224:
  pushl $0
80107577:	6a 00                	push   $0x0
  pushl $224
80107579:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010757e:	e9 47 ef ff ff       	jmp    801064ca <alltraps>

80107583 <vector225>:
.globl vector225
vector225:
  pushl $0
80107583:	6a 00                	push   $0x0
  pushl $225
80107585:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010758a:	e9 3b ef ff ff       	jmp    801064ca <alltraps>

8010758f <vector226>:
.globl vector226
vector226:
  pushl $0
8010758f:	6a 00                	push   $0x0
  pushl $226
80107591:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107596:	e9 2f ef ff ff       	jmp    801064ca <alltraps>

8010759b <vector227>:
.globl vector227
vector227:
  pushl $0
8010759b:	6a 00                	push   $0x0
  pushl $227
8010759d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801075a2:	e9 23 ef ff ff       	jmp    801064ca <alltraps>

801075a7 <vector228>:
.globl vector228
vector228:
  pushl $0
801075a7:	6a 00                	push   $0x0
  pushl $228
801075a9:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801075ae:	e9 17 ef ff ff       	jmp    801064ca <alltraps>

801075b3 <vector229>:
.globl vector229
vector229:
  pushl $0
801075b3:	6a 00                	push   $0x0
  pushl $229
801075b5:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801075ba:	e9 0b ef ff ff       	jmp    801064ca <alltraps>

801075bf <vector230>:
.globl vector230
vector230:
  pushl $0
801075bf:	6a 00                	push   $0x0
  pushl $230
801075c1:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801075c6:	e9 ff ee ff ff       	jmp    801064ca <alltraps>

801075cb <vector231>:
.globl vector231
vector231:
  pushl $0
801075cb:	6a 00                	push   $0x0
  pushl $231
801075cd:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801075d2:	e9 f3 ee ff ff       	jmp    801064ca <alltraps>

801075d7 <vector232>:
.globl vector232
vector232:
  pushl $0
801075d7:	6a 00                	push   $0x0
  pushl $232
801075d9:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801075de:	e9 e7 ee ff ff       	jmp    801064ca <alltraps>

801075e3 <vector233>:
.globl vector233
vector233:
  pushl $0
801075e3:	6a 00                	push   $0x0
  pushl $233
801075e5:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801075ea:	e9 db ee ff ff       	jmp    801064ca <alltraps>

801075ef <vector234>:
.globl vector234
vector234:
  pushl $0
801075ef:	6a 00                	push   $0x0
  pushl $234
801075f1:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801075f6:	e9 cf ee ff ff       	jmp    801064ca <alltraps>

801075fb <vector235>:
.globl vector235
vector235:
  pushl $0
801075fb:	6a 00                	push   $0x0
  pushl $235
801075fd:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107602:	e9 c3 ee ff ff       	jmp    801064ca <alltraps>

80107607 <vector236>:
.globl vector236
vector236:
  pushl $0
80107607:	6a 00                	push   $0x0
  pushl $236
80107609:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010760e:	e9 b7 ee ff ff       	jmp    801064ca <alltraps>

80107613 <vector237>:
.globl vector237
vector237:
  pushl $0
80107613:	6a 00                	push   $0x0
  pushl $237
80107615:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010761a:	e9 ab ee ff ff       	jmp    801064ca <alltraps>

8010761f <vector238>:
.globl vector238
vector238:
  pushl $0
8010761f:	6a 00                	push   $0x0
  pushl $238
80107621:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107626:	e9 9f ee ff ff       	jmp    801064ca <alltraps>

8010762b <vector239>:
.globl vector239
vector239:
  pushl $0
8010762b:	6a 00                	push   $0x0
  pushl $239
8010762d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107632:	e9 93 ee ff ff       	jmp    801064ca <alltraps>

80107637 <vector240>:
.globl vector240
vector240:
  pushl $0
80107637:	6a 00                	push   $0x0
  pushl $240
80107639:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010763e:	e9 87 ee ff ff       	jmp    801064ca <alltraps>

80107643 <vector241>:
.globl vector241
vector241:
  pushl $0
80107643:	6a 00                	push   $0x0
  pushl $241
80107645:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010764a:	e9 7b ee ff ff       	jmp    801064ca <alltraps>

8010764f <vector242>:
.globl vector242
vector242:
  pushl $0
8010764f:	6a 00                	push   $0x0
  pushl $242
80107651:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107656:	e9 6f ee ff ff       	jmp    801064ca <alltraps>

8010765b <vector243>:
.globl vector243
vector243:
  pushl $0
8010765b:	6a 00                	push   $0x0
  pushl $243
8010765d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107662:	e9 63 ee ff ff       	jmp    801064ca <alltraps>

80107667 <vector244>:
.globl vector244
vector244:
  pushl $0
80107667:	6a 00                	push   $0x0
  pushl $244
80107669:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010766e:	e9 57 ee ff ff       	jmp    801064ca <alltraps>

80107673 <vector245>:
.globl vector245
vector245:
  pushl $0
80107673:	6a 00                	push   $0x0
  pushl $245
80107675:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010767a:	e9 4b ee ff ff       	jmp    801064ca <alltraps>

8010767f <vector246>:
.globl vector246
vector246:
  pushl $0
8010767f:	6a 00                	push   $0x0
  pushl $246
80107681:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107686:	e9 3f ee ff ff       	jmp    801064ca <alltraps>

8010768b <vector247>:
.globl vector247
vector247:
  pushl $0
8010768b:	6a 00                	push   $0x0
  pushl $247
8010768d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107692:	e9 33 ee ff ff       	jmp    801064ca <alltraps>

80107697 <vector248>:
.globl vector248
vector248:
  pushl $0
80107697:	6a 00                	push   $0x0
  pushl $248
80107699:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010769e:	e9 27 ee ff ff       	jmp    801064ca <alltraps>

801076a3 <vector249>:
.globl vector249
vector249:
  pushl $0
801076a3:	6a 00                	push   $0x0
  pushl $249
801076a5:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801076aa:	e9 1b ee ff ff       	jmp    801064ca <alltraps>

801076af <vector250>:
.globl vector250
vector250:
  pushl $0
801076af:	6a 00                	push   $0x0
  pushl $250
801076b1:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801076b6:	e9 0f ee ff ff       	jmp    801064ca <alltraps>

801076bb <vector251>:
.globl vector251
vector251:
  pushl $0
801076bb:	6a 00                	push   $0x0
  pushl $251
801076bd:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801076c2:	e9 03 ee ff ff       	jmp    801064ca <alltraps>

801076c7 <vector252>:
.globl vector252
vector252:
  pushl $0
801076c7:	6a 00                	push   $0x0
  pushl $252
801076c9:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801076ce:	e9 f7 ed ff ff       	jmp    801064ca <alltraps>

801076d3 <vector253>:
.globl vector253
vector253:
  pushl $0
801076d3:	6a 00                	push   $0x0
  pushl $253
801076d5:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801076da:	e9 eb ed ff ff       	jmp    801064ca <alltraps>

801076df <vector254>:
.globl vector254
vector254:
  pushl $0
801076df:	6a 00                	push   $0x0
  pushl $254
801076e1:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801076e6:	e9 df ed ff ff       	jmp    801064ca <alltraps>

801076eb <vector255>:
.globl vector255
vector255:
  pushl $0
801076eb:	6a 00                	push   $0x0
  pushl $255
801076ed:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801076f2:	e9 d3 ed ff ff       	jmp    801064ca <alltraps>

801076f7 <lgdt>:
{
801076f7:	55                   	push   %ebp
801076f8:	89 e5                	mov    %esp,%ebp
801076fa:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801076fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107700:	83 e8 01             	sub    $0x1,%eax
80107703:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107707:	8b 45 08             	mov    0x8(%ebp),%eax
8010770a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010770e:	8b 45 08             	mov    0x8(%ebp),%eax
80107711:	c1 e8 10             	shr    $0x10,%eax
80107714:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107718:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010771b:	0f 01 10             	lgdtl  (%eax)
}
8010771e:	90                   	nop
8010771f:	c9                   	leave  
80107720:	c3                   	ret    

80107721 <ltr>:
{
80107721:	55                   	push   %ebp
80107722:	89 e5                	mov    %esp,%ebp
80107724:	83 ec 04             	sub    $0x4,%esp
80107727:	8b 45 08             	mov    0x8(%ebp),%eax
8010772a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010772e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107732:	0f 00 d8             	ltr    %ax
}
80107735:	90                   	nop
80107736:	c9                   	leave  
80107737:	c3                   	ret    

80107738 <lcr3>:
{
80107738:	55                   	push   %ebp
80107739:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010773b:	8b 45 08             	mov    0x8(%ebp),%eax
8010773e:	0f 22 d8             	mov    %eax,%cr3
}
80107741:	90                   	nop
80107742:	5d                   	pop    %ebp
80107743:	c3                   	ret    

80107744 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107744:	55                   	push   %ebp
80107745:	89 e5                	mov    %esp,%ebp
80107747:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010774a:	e8 36 c2 ff ff       	call   80103985 <cpuid>
8010774f:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107755:	05 80 e4 30 80       	add    $0x8030e480,%eax
8010775a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010775d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107760:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107769:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010776f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107772:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107779:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010777d:	83 e2 f0             	and    $0xfffffff0,%edx
80107780:	83 ca 0a             	or     $0xa,%edx
80107783:	88 50 7d             	mov    %dl,0x7d(%eax)
80107786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107789:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010778d:	83 ca 10             	or     $0x10,%edx
80107790:	88 50 7d             	mov    %dl,0x7d(%eax)
80107793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107796:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010779a:	83 e2 9f             	and    $0xffffff9f,%edx
8010779d:	88 50 7d             	mov    %dl,0x7d(%eax)
801077a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801077a7:	83 ca 80             	or     $0xffffff80,%edx
801077aa:	88 50 7d             	mov    %dl,0x7d(%eax)
801077ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077b4:	83 ca 0f             	or     $0xf,%edx
801077b7:	88 50 7e             	mov    %dl,0x7e(%eax)
801077ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077bd:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077c1:	83 e2 ef             	and    $0xffffffef,%edx
801077c4:	88 50 7e             	mov    %dl,0x7e(%eax)
801077c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ca:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077ce:	83 e2 df             	and    $0xffffffdf,%edx
801077d1:	88 50 7e             	mov    %dl,0x7e(%eax)
801077d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077db:	83 ca 40             	or     $0x40,%edx
801077de:	88 50 7e             	mov    %dl,0x7e(%eax)
801077e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077e8:	83 ca 80             	or     $0xffffff80,%edx
801077eb:	88 50 7e             	mov    %dl,0x7e(%eax)
801077ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f1:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801077f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f8:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801077ff:	ff ff 
80107801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107804:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010780b:	00 00 
8010780d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107810:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107821:	83 e2 f0             	and    $0xfffffff0,%edx
80107824:	83 ca 02             	or     $0x2,%edx
80107827:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010782d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107830:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107837:	83 ca 10             	or     $0x10,%edx
8010783a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107843:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010784a:	83 e2 9f             	and    $0xffffff9f,%edx
8010784d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107853:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107856:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010785d:	83 ca 80             	or     $0xffffff80,%edx
80107860:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107869:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107870:	83 ca 0f             	or     $0xf,%edx
80107873:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107883:	83 e2 ef             	and    $0xffffffef,%edx
80107886:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010788c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107896:	83 e2 df             	and    $0xffffffdf,%edx
80107899:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010789f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078a9:	83 ca 40             	or     $0x40,%edx
801078ac:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078bc:	83 ca 80             	or     $0xffffff80,%edx
801078bf:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c8:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801078cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d2:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801078d9:	ff ff 
801078db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078de:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801078e5:	00 00 
801078e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ea:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801078f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801078fb:	83 e2 f0             	and    $0xfffffff0,%edx
801078fe:	83 ca 0a             	or     $0xa,%edx
80107901:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107911:	83 ca 10             	or     $0x10,%edx
80107914:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010791a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107924:	83 ca 60             	or     $0x60,%edx
80107927:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010792d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107930:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107937:	83 ca 80             	or     $0xffffff80,%edx
8010793a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107943:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010794a:	83 ca 0f             	or     $0xf,%edx
8010794d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107956:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010795d:	83 e2 ef             	and    $0xffffffef,%edx
80107960:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107969:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107970:	83 e2 df             	and    $0xffffffdf,%edx
80107973:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107983:	83 ca 40             	or     $0x40,%edx
80107986:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010798c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107996:	83 ca 80             	or     $0xffffff80,%edx
80107999:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010799f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a2:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801079a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ac:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801079b3:	ff ff 
801079b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b8:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801079bf:	00 00 
801079c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c4:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801079cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ce:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079d5:	83 e2 f0             	and    $0xfffffff0,%edx
801079d8:	83 ca 02             	or     $0x2,%edx
801079db:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079eb:	83 ca 10             	or     $0x10,%edx
801079ee:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079fe:	83 ca 60             	or     $0x60,%edx
80107a01:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a11:	83 ca 80             	or     $0xffffff80,%edx
80107a14:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a24:	83 ca 0f             	or     $0xf,%edx
80107a27:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a30:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a37:	83 e2 ef             	and    $0xffffffef,%edx
80107a3a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a43:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a4a:	83 e2 df             	and    $0xffffffdf,%edx
80107a4d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a56:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a5d:	83 ca 40             	or     $0x40,%edx
80107a60:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a69:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a70:	83 ca 80             	or     $0xffffff80,%edx
80107a73:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7c:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a86:	83 c0 70             	add    $0x70,%eax
80107a89:	83 ec 08             	sub    $0x8,%esp
80107a8c:	6a 30                	push   $0x30
80107a8e:	50                   	push   %eax
80107a8f:	e8 63 fc ff ff       	call   801076f7 <lgdt>
80107a94:	83 c4 10             	add    $0x10,%esp
}
80107a97:	90                   	nop
80107a98:	c9                   	leave  
80107a99:	c3                   	ret    

80107a9a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107a9a:	55                   	push   %ebp
80107a9b:	89 e5                	mov    %esp,%ebp
80107a9d:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
80107aa3:	c1 e8 16             	shr    $0x16,%eax
80107aa6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107aad:	8b 45 08             	mov    0x8(%ebp),%eax
80107ab0:	01 d0                	add    %edx,%eax
80107ab2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ab8:	8b 00                	mov    (%eax),%eax
80107aba:	83 e0 01             	and    $0x1,%eax
80107abd:	85 c0                	test   %eax,%eax
80107abf:	74 14                	je     80107ad5 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107ac1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ac4:	8b 00                	mov    (%eax),%eax
80107ac6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107acb:	05 00 00 00 80       	add    $0x80000000,%eax
80107ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ad3:	eb 42                	jmp    80107b17 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ad5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ad9:	74 0e                	je     80107ae9 <walkpgdir+0x4f>
80107adb:	e8 a8 ac ff ff       	call   80102788 <kalloc>
80107ae0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ae3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ae7:	75 07                	jne    80107af0 <walkpgdir+0x56>
      return 0;
80107ae9:	b8 00 00 00 00       	mov    $0x0,%eax
80107aee:	eb 3e                	jmp    80107b2e <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107af0:	83 ec 04             	sub    $0x4,%esp
80107af3:	68 00 10 00 00       	push   $0x1000
80107af8:	6a 00                	push   $0x0
80107afa:	ff 75 f4             	push   -0xc(%ebp)
80107afd:	e8 fb d2 ff ff       	call   80104dfd <memset>
80107b02:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b08:	05 00 00 00 80       	add    $0x80000000,%eax
80107b0d:	83 c8 07             	or     $0x7,%eax
80107b10:	89 c2                	mov    %eax,%edx
80107b12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b15:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107b17:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b1a:	c1 e8 0c             	shr    $0xc,%eax
80107b1d:	25 ff 03 00 00       	and    $0x3ff,%eax
80107b22:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2c:	01 d0                	add    %edx,%eax
}
80107b2e:	c9                   	leave  
80107b2f:	c3                   	ret    

80107b30 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107b30:	55                   	push   %ebp
80107b31:	89 e5                	mov    %esp,%ebp
80107b33:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107b36:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b39:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107b41:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b44:	8b 45 10             	mov    0x10(%ebp),%eax
80107b47:	01 d0                	add    %edx,%eax
80107b49:	83 e8 01             	sub    $0x1,%eax
80107b4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b51:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107b54:	83 ec 04             	sub    $0x4,%esp
80107b57:	6a 01                	push   $0x1
80107b59:	ff 75 f4             	push   -0xc(%ebp)
80107b5c:	ff 75 08             	push   0x8(%ebp)
80107b5f:	e8 36 ff ff ff       	call   80107a9a <walkpgdir>
80107b64:	83 c4 10             	add    $0x10,%esp
80107b67:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b6a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b6e:	75 07                	jne    80107b77 <mappages+0x47>
      return -1;
80107b70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b75:	eb 47                	jmp    80107bbe <mappages+0x8e>
    if(*pte & PTE_P)
80107b77:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b7a:	8b 00                	mov    (%eax),%eax
80107b7c:	83 e0 01             	and    $0x1,%eax
80107b7f:	85 c0                	test   %eax,%eax
80107b81:	74 0d                	je     80107b90 <mappages+0x60>
      panic("remap");
80107b83:	83 ec 0c             	sub    $0xc,%esp
80107b86:	68 c0 af 10 80       	push   $0x8010afc0
80107b8b:	e8 19 8a ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107b90:	8b 45 18             	mov    0x18(%ebp),%eax
80107b93:	0b 45 14             	or     0x14(%ebp),%eax
80107b96:	83 c8 01             	or     $0x1,%eax
80107b99:	89 c2                	mov    %eax,%edx
80107b9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b9e:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107ba6:	74 10                	je     80107bb8 <mappages+0x88>
      break;
    a += PGSIZE;
80107ba8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107baf:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107bb6:	eb 9c                	jmp    80107b54 <mappages+0x24>
      break;
80107bb8:	90                   	nop
  }
  return 0;
80107bb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107bbe:	c9                   	leave  
80107bbf:	c3                   	ret    

80107bc0 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107bc0:	55                   	push   %ebp
80107bc1:	89 e5                	mov    %esp,%ebp
80107bc3:	53                   	push   %ebx
80107bc4:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107bc7:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107bce:	8b 15 60 e7 30 80    	mov    0x8030e760,%edx
80107bd4:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107bd9:	29 d0                	sub    %edx,%eax
80107bdb:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107bde:	a1 58 e7 30 80       	mov    0x8030e758,%eax
80107be3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107be6:	8b 15 58 e7 30 80    	mov    0x8030e758,%edx
80107bec:	a1 60 e7 30 80       	mov    0x8030e760,%eax
80107bf1:	01 d0                	add    %edx,%eax
80107bf3:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107bf6:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c00:	83 c0 30             	add    $0x30,%eax
80107c03:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107c06:	89 10                	mov    %edx,(%eax)
80107c08:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107c0b:	89 50 04             	mov    %edx,0x4(%eax)
80107c0e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107c11:	89 50 08             	mov    %edx,0x8(%eax)
80107c14:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107c17:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107c1a:	e8 69 ab ff ff       	call   80102788 <kalloc>
80107c1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c26:	75 07                	jne    80107c2f <setupkvm+0x6f>
    return 0;
80107c28:	b8 00 00 00 00       	mov    $0x0,%eax
80107c2d:	eb 78                	jmp    80107ca7 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107c2f:	83 ec 04             	sub    $0x4,%esp
80107c32:	68 00 10 00 00       	push   $0x1000
80107c37:	6a 00                	push   $0x0
80107c39:	ff 75 f0             	push   -0x10(%ebp)
80107c3c:	e8 bc d1 ff ff       	call   80104dfd <memset>
80107c41:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107c44:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107c4b:	eb 4e                	jmp    80107c9b <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c50:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c56:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5c:	8b 58 08             	mov    0x8(%eax),%ebx
80107c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c62:	8b 40 04             	mov    0x4(%eax),%eax
80107c65:	29 c3                	sub    %eax,%ebx
80107c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6a:	8b 00                	mov    (%eax),%eax
80107c6c:	83 ec 0c             	sub    $0xc,%esp
80107c6f:	51                   	push   %ecx
80107c70:	52                   	push   %edx
80107c71:	53                   	push   %ebx
80107c72:	50                   	push   %eax
80107c73:	ff 75 f0             	push   -0x10(%ebp)
80107c76:	e8 b5 fe ff ff       	call   80107b30 <mappages>
80107c7b:	83 c4 20             	add    $0x20,%esp
80107c7e:	85 c0                	test   %eax,%eax
80107c80:	79 15                	jns    80107c97 <setupkvm+0xd7>
      freevm(pgdir);
80107c82:	83 ec 0c             	sub    $0xc,%esp
80107c85:	ff 75 f0             	push   -0x10(%ebp)
80107c88:	e8 f5 04 00 00       	call   80108182 <freevm>
80107c8d:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c90:	b8 00 00 00 00       	mov    $0x0,%eax
80107c95:	eb 10                	jmp    80107ca7 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107c97:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107c9b:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107ca2:	72 a9                	jb     80107c4d <setupkvm+0x8d>
    }
  return pgdir;
80107ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107ca7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107caa:	c9                   	leave  
80107cab:	c3                   	ret    

80107cac <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107cac:	55                   	push   %ebp
80107cad:	89 e5                	mov    %esp,%ebp
80107caf:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107cb2:	e8 09 ff ff ff       	call   80107bc0 <setupkvm>
80107cb7:	a3 7c e4 30 80       	mov    %eax,0x8030e47c
  switchkvm();
80107cbc:	e8 03 00 00 00       	call   80107cc4 <switchkvm>
}
80107cc1:	90                   	nop
80107cc2:	c9                   	leave  
80107cc3:	c3                   	ret    

80107cc4 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107cc4:	55                   	push   %ebp
80107cc5:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107cc7:	a1 7c e4 30 80       	mov    0x8030e47c,%eax
80107ccc:	05 00 00 00 80       	add    $0x80000000,%eax
80107cd1:	50                   	push   %eax
80107cd2:	e8 61 fa ff ff       	call   80107738 <lcr3>
80107cd7:	83 c4 04             	add    $0x4,%esp
}
80107cda:	90                   	nop
80107cdb:	c9                   	leave  
80107cdc:	c3                   	ret    

80107cdd <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107cdd:	55                   	push   %ebp
80107cde:	89 e5                	mov    %esp,%ebp
80107ce0:	56                   	push   %esi
80107ce1:	53                   	push   %ebx
80107ce2:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107ce5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107ce9:	75 0d                	jne    80107cf8 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107ceb:	83 ec 0c             	sub    $0xc,%esp
80107cee:	68 c6 af 10 80       	push   $0x8010afc6
80107cf3:	e8 b1 88 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107cf8:	8b 45 08             	mov    0x8(%ebp),%eax
80107cfb:	8b 40 08             	mov    0x8(%eax),%eax
80107cfe:	85 c0                	test   %eax,%eax
80107d00:	75 0d                	jne    80107d0f <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107d02:	83 ec 0c             	sub    $0xc,%esp
80107d05:	68 dc af 10 80       	push   $0x8010afdc
80107d0a:	e8 9a 88 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107d0f:	8b 45 08             	mov    0x8(%ebp),%eax
80107d12:	8b 40 04             	mov    0x4(%eax),%eax
80107d15:	85 c0                	test   %eax,%eax
80107d17:	75 0d                	jne    80107d26 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107d19:	83 ec 0c             	sub    $0xc,%esp
80107d1c:	68 f1 af 10 80       	push   $0x8010aff1
80107d21:	e8 83 88 ff ff       	call   801005a9 <panic>

  pushcli();
80107d26:	e8 c7 cf ff ff       	call   80104cf2 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107d2b:	e8 70 bc ff ff       	call   801039a0 <mycpu>
80107d30:	89 c3                	mov    %eax,%ebx
80107d32:	e8 69 bc ff ff       	call   801039a0 <mycpu>
80107d37:	83 c0 08             	add    $0x8,%eax
80107d3a:	89 c6                	mov    %eax,%esi
80107d3c:	e8 5f bc ff ff       	call   801039a0 <mycpu>
80107d41:	83 c0 08             	add    $0x8,%eax
80107d44:	c1 e8 10             	shr    $0x10,%eax
80107d47:	88 45 f7             	mov    %al,-0x9(%ebp)
80107d4a:	e8 51 bc ff ff       	call   801039a0 <mycpu>
80107d4f:	83 c0 08             	add    $0x8,%eax
80107d52:	c1 e8 18             	shr    $0x18,%eax
80107d55:	89 c2                	mov    %eax,%edx
80107d57:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107d5e:	67 00 
80107d60:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107d67:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107d6b:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107d71:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107d78:	83 e0 f0             	and    $0xfffffff0,%eax
80107d7b:	83 c8 09             	or     $0x9,%eax
80107d7e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d84:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107d8b:	83 c8 10             	or     $0x10,%eax
80107d8e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d94:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107d9b:	83 e0 9f             	and    $0xffffff9f,%eax
80107d9e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107da4:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107dab:	83 c8 80             	or     $0xffffff80,%eax
80107dae:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107db4:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107dbb:	83 e0 f0             	and    $0xfffffff0,%eax
80107dbe:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107dc4:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107dcb:	83 e0 ef             	and    $0xffffffef,%eax
80107dce:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107dd4:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ddb:	83 e0 df             	and    $0xffffffdf,%eax
80107dde:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107de4:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107deb:	83 c8 40             	or     $0x40,%eax
80107dee:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107df4:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107dfb:	83 e0 7f             	and    $0x7f,%eax
80107dfe:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e04:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107e0a:	e8 91 bb ff ff       	call   801039a0 <mycpu>
80107e0f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107e16:	83 e2 ef             	and    $0xffffffef,%edx
80107e19:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107e1f:	e8 7c bb ff ff       	call   801039a0 <mycpu>
80107e24:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80107e2d:	8b 40 08             	mov    0x8(%eax),%eax
80107e30:	89 c3                	mov    %eax,%ebx
80107e32:	e8 69 bb ff ff       	call   801039a0 <mycpu>
80107e37:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107e3d:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107e40:	e8 5b bb ff ff       	call   801039a0 <mycpu>
80107e45:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107e4b:	83 ec 0c             	sub    $0xc,%esp
80107e4e:	6a 28                	push   $0x28
80107e50:	e8 cc f8 ff ff       	call   80107721 <ltr>
80107e55:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107e58:	8b 45 08             	mov    0x8(%ebp),%eax
80107e5b:	8b 40 04             	mov    0x4(%eax),%eax
80107e5e:	05 00 00 00 80       	add    $0x80000000,%eax
80107e63:	83 ec 0c             	sub    $0xc,%esp
80107e66:	50                   	push   %eax
80107e67:	e8 cc f8 ff ff       	call   80107738 <lcr3>
80107e6c:	83 c4 10             	add    $0x10,%esp
  popcli();
80107e6f:	e8 cb ce ff ff       	call   80104d3f <popcli>
}
80107e74:	90                   	nop
80107e75:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107e78:	5b                   	pop    %ebx
80107e79:	5e                   	pop    %esi
80107e7a:	5d                   	pop    %ebp
80107e7b:	c3                   	ret    

80107e7c <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107e7c:	55                   	push   %ebp
80107e7d:	89 e5                	mov    %esp,%ebp
80107e7f:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107e82:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107e89:	76 0d                	jbe    80107e98 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107e8b:	83 ec 0c             	sub    $0xc,%esp
80107e8e:	68 05 b0 10 80       	push   $0x8010b005
80107e93:	e8 11 87 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107e98:	e8 eb a8 ff ff       	call   80102788 <kalloc>
80107e9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107ea0:	83 ec 04             	sub    $0x4,%esp
80107ea3:	68 00 10 00 00       	push   $0x1000
80107ea8:	6a 00                	push   $0x0
80107eaa:	ff 75 f4             	push   -0xc(%ebp)
80107ead:	e8 4b cf ff ff       	call   80104dfd <memset>
80107eb2:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb8:	05 00 00 00 80       	add    $0x80000000,%eax
80107ebd:	83 ec 0c             	sub    $0xc,%esp
80107ec0:	6a 06                	push   $0x6
80107ec2:	50                   	push   %eax
80107ec3:	68 00 10 00 00       	push   $0x1000
80107ec8:	6a 00                	push   $0x0
80107eca:	ff 75 08             	push   0x8(%ebp)
80107ecd:	e8 5e fc ff ff       	call   80107b30 <mappages>
80107ed2:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107ed5:	83 ec 04             	sub    $0x4,%esp
80107ed8:	ff 75 10             	push   0x10(%ebp)
80107edb:	ff 75 0c             	push   0xc(%ebp)
80107ede:	ff 75 f4             	push   -0xc(%ebp)
80107ee1:	e8 d6 cf ff ff       	call   80104ebc <memmove>
80107ee6:	83 c4 10             	add    $0x10,%esp
}
80107ee9:	90                   	nop
80107eea:	c9                   	leave  
80107eeb:	c3                   	ret    

80107eec <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107eec:	55                   	push   %ebp
80107eed:	89 e5                	mov    %esp,%ebp
80107eef:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ef5:	25 ff 0f 00 00       	and    $0xfff,%eax
80107efa:	85 c0                	test   %eax,%eax
80107efc:	74 0d                	je     80107f0b <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107efe:	83 ec 0c             	sub    $0xc,%esp
80107f01:	68 20 b0 10 80       	push   $0x8010b020
80107f06:	e8 9e 86 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107f0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f12:	e9 8f 00 00 00       	jmp    80107fa6 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107f17:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1d:	01 d0                	add    %edx,%eax
80107f1f:	83 ec 04             	sub    $0x4,%esp
80107f22:	6a 00                	push   $0x0
80107f24:	50                   	push   %eax
80107f25:	ff 75 08             	push   0x8(%ebp)
80107f28:	e8 6d fb ff ff       	call   80107a9a <walkpgdir>
80107f2d:	83 c4 10             	add    $0x10,%esp
80107f30:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f33:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f37:	75 0d                	jne    80107f46 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107f39:	83 ec 0c             	sub    $0xc,%esp
80107f3c:	68 43 b0 10 80       	push   $0x8010b043
80107f41:	e8 63 86 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107f46:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f49:	8b 00                	mov    (%eax),%eax
80107f4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f50:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107f53:	8b 45 18             	mov    0x18(%ebp),%eax
80107f56:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107f59:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107f5e:	77 0b                	ja     80107f6b <loaduvm+0x7f>
      n = sz - i;
80107f60:	8b 45 18             	mov    0x18(%ebp),%eax
80107f63:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107f66:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f69:	eb 07                	jmp    80107f72 <loaduvm+0x86>
    else
      n = PGSIZE;
80107f6b:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107f72:	8b 55 14             	mov    0x14(%ebp),%edx
80107f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f78:	01 d0                	add    %edx,%eax
80107f7a:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107f7d:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107f83:	ff 75 f0             	push   -0x10(%ebp)
80107f86:	50                   	push   %eax
80107f87:	52                   	push   %edx
80107f88:	ff 75 10             	push   0x10(%ebp)
80107f8b:	e8 2e 9f ff ff       	call   80101ebe <readi>
80107f90:	83 c4 10             	add    $0x10,%esp
80107f93:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107f96:	74 07                	je     80107f9f <loaduvm+0xb3>
      return -1;
80107f98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f9d:	eb 18                	jmp    80107fb7 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107f9f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa9:	3b 45 18             	cmp    0x18(%ebp),%eax
80107fac:	0f 82 65 ff ff ff    	jb     80107f17 <loaduvm+0x2b>
  }
  return 0;
80107fb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107fb7:	c9                   	leave  
80107fb8:	c3                   	ret    

80107fb9 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107fb9:	55                   	push   %ebp
80107fba:	89 e5                	mov    %esp,%ebp
80107fbc:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107fbf:	8b 45 10             	mov    0x10(%ebp),%eax
80107fc2:	85 c0                	test   %eax,%eax
80107fc4:	79 0a                	jns    80107fd0 <allocuvm+0x17>
    return 0;
80107fc6:	b8 00 00 00 00       	mov    $0x0,%eax
80107fcb:	e9 ec 00 00 00       	jmp    801080bc <allocuvm+0x103>
  if(newsz < oldsz)
80107fd0:	8b 45 10             	mov    0x10(%ebp),%eax
80107fd3:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107fd6:	73 08                	jae    80107fe0 <allocuvm+0x27>
    return oldsz;
80107fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fdb:	e9 dc 00 00 00       	jmp    801080bc <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fe3:	05 ff 0f 00 00       	add    $0xfff,%eax
80107fe8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107ff0:	e9 b8 00 00 00       	jmp    801080ad <allocuvm+0xf4>
    mem = kalloc();
80107ff5:	e8 8e a7 ff ff       	call   80102788 <kalloc>
80107ffa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107ffd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108001:	75 2e                	jne    80108031 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80108003:	83 ec 0c             	sub    $0xc,%esp
80108006:	68 61 b0 10 80       	push   $0x8010b061
8010800b:	e8 e4 83 ff ff       	call   801003f4 <cprintf>
80108010:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108013:	83 ec 04             	sub    $0x4,%esp
80108016:	ff 75 0c             	push   0xc(%ebp)
80108019:	ff 75 10             	push   0x10(%ebp)
8010801c:	ff 75 08             	push   0x8(%ebp)
8010801f:	e8 9a 00 00 00       	call   801080be <deallocuvm>
80108024:	83 c4 10             	add    $0x10,%esp
      return 0;
80108027:	b8 00 00 00 00       	mov    $0x0,%eax
8010802c:	e9 8b 00 00 00       	jmp    801080bc <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80108031:	83 ec 04             	sub    $0x4,%esp
80108034:	68 00 10 00 00       	push   $0x1000
80108039:	6a 00                	push   $0x0
8010803b:	ff 75 f0             	push   -0x10(%ebp)
8010803e:	e8 ba cd ff ff       	call   80104dfd <memset>
80108043:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108046:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108049:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010804f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108052:	83 ec 0c             	sub    $0xc,%esp
80108055:	6a 06                	push   $0x6
80108057:	52                   	push   %edx
80108058:	68 00 10 00 00       	push   $0x1000
8010805d:	50                   	push   %eax
8010805e:	ff 75 08             	push   0x8(%ebp)
80108061:	e8 ca fa ff ff       	call   80107b30 <mappages>
80108066:	83 c4 20             	add    $0x20,%esp
80108069:	85 c0                	test   %eax,%eax
8010806b:	79 39                	jns    801080a6 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
8010806d:	83 ec 0c             	sub    $0xc,%esp
80108070:	68 79 b0 10 80       	push   $0x8010b079
80108075:	e8 7a 83 ff ff       	call   801003f4 <cprintf>
8010807a:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010807d:	83 ec 04             	sub    $0x4,%esp
80108080:	ff 75 0c             	push   0xc(%ebp)
80108083:	ff 75 10             	push   0x10(%ebp)
80108086:	ff 75 08             	push   0x8(%ebp)
80108089:	e8 30 00 00 00       	call   801080be <deallocuvm>
8010808e:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108091:	83 ec 0c             	sub    $0xc,%esp
80108094:	ff 75 f0             	push   -0x10(%ebp)
80108097:	e8 52 a6 ff ff       	call   801026ee <kfree>
8010809c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010809f:	b8 00 00 00 00       	mov    $0x0,%eax
801080a4:	eb 16                	jmp    801080bc <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801080a6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b0:	3b 45 10             	cmp    0x10(%ebp),%eax
801080b3:	0f 82 3c ff ff ff    	jb     80107ff5 <allocuvm+0x3c>
    }
  }
  return newsz;
801080b9:	8b 45 10             	mov    0x10(%ebp),%eax
}
801080bc:	c9                   	leave  
801080bd:	c3                   	ret    

801080be <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801080be:	55                   	push   %ebp
801080bf:	89 e5                	mov    %esp,%ebp
801080c1:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801080c4:	8b 45 10             	mov    0x10(%ebp),%eax
801080c7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801080ca:	72 08                	jb     801080d4 <deallocuvm+0x16>
    return oldsz;
801080cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801080cf:	e9 ac 00 00 00       	jmp    80108180 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801080d4:	8b 45 10             	mov    0x10(%ebp),%eax
801080d7:	05 ff 0f 00 00       	add    $0xfff,%eax
801080dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801080e4:	e9 88 00 00 00       	jmp    80108171 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801080e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ec:	83 ec 04             	sub    $0x4,%esp
801080ef:	6a 00                	push   $0x0
801080f1:	50                   	push   %eax
801080f2:	ff 75 08             	push   0x8(%ebp)
801080f5:	e8 a0 f9 ff ff       	call   80107a9a <walkpgdir>
801080fa:	83 c4 10             	add    $0x10,%esp
801080fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108100:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108104:	75 16                	jne    8010811c <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108106:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108109:	c1 e8 16             	shr    $0x16,%eax
8010810c:	83 c0 01             	add    $0x1,%eax
8010810f:	c1 e0 16             	shl    $0x16,%eax
80108112:	2d 00 10 00 00       	sub    $0x1000,%eax
80108117:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010811a:	eb 4e                	jmp    8010816a <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010811c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010811f:	8b 00                	mov    (%eax),%eax
80108121:	83 e0 01             	and    $0x1,%eax
80108124:	85 c0                	test   %eax,%eax
80108126:	74 42                	je     8010816a <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010812b:	8b 00                	mov    (%eax),%eax
8010812d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108132:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108135:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108139:	75 0d                	jne    80108148 <deallocuvm+0x8a>
        panic("kfree");
8010813b:	83 ec 0c             	sub    $0xc,%esp
8010813e:	68 95 b0 10 80       	push   $0x8010b095
80108143:	e8 61 84 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80108148:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010814b:	05 00 00 00 80       	add    $0x80000000,%eax
80108150:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108153:	83 ec 0c             	sub    $0xc,%esp
80108156:	ff 75 e8             	push   -0x18(%ebp)
80108159:	e8 90 a5 ff ff       	call   801026ee <kfree>
8010815e:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108161:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108164:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010816a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108171:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108174:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108177:	0f 82 6c ff ff ff    	jb     801080e9 <deallocuvm+0x2b>
    }
  }
  return newsz;
8010817d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108180:	c9                   	leave  
80108181:	c3                   	ret    

80108182 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108182:	55                   	push   %ebp
80108183:	89 e5                	mov    %esp,%ebp
80108185:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108188:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010818c:	75 0d                	jne    8010819b <freevm+0x19>
    panic("freevm: no pgdir");
8010818e:	83 ec 0c             	sub    $0xc,%esp
80108191:	68 9b b0 10 80       	push   $0x8010b09b
80108196:	e8 0e 84 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010819b:	83 ec 04             	sub    $0x4,%esp
8010819e:	6a 00                	push   $0x0
801081a0:	68 00 00 00 80       	push   $0x80000000
801081a5:	ff 75 08             	push   0x8(%ebp)
801081a8:	e8 11 ff ff ff       	call   801080be <deallocuvm>
801081ad:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801081b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081b7:	eb 48                	jmp    80108201 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801081b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081bc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801081c3:	8b 45 08             	mov    0x8(%ebp),%eax
801081c6:	01 d0                	add    %edx,%eax
801081c8:	8b 00                	mov    (%eax),%eax
801081ca:	83 e0 01             	and    $0x1,%eax
801081cd:	85 c0                	test   %eax,%eax
801081cf:	74 2c                	je     801081fd <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801081d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801081db:	8b 45 08             	mov    0x8(%ebp),%eax
801081de:	01 d0                	add    %edx,%eax
801081e0:	8b 00                	mov    (%eax),%eax
801081e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081e7:	05 00 00 00 80       	add    $0x80000000,%eax
801081ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801081ef:	83 ec 0c             	sub    $0xc,%esp
801081f2:	ff 75 f0             	push   -0x10(%ebp)
801081f5:	e8 f4 a4 ff ff       	call   801026ee <kfree>
801081fa:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801081fd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108201:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108208:	76 af                	jbe    801081b9 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010820a:	83 ec 0c             	sub    $0xc,%esp
8010820d:	ff 75 08             	push   0x8(%ebp)
80108210:	e8 d9 a4 ff ff       	call   801026ee <kfree>
80108215:	83 c4 10             	add    $0x10,%esp
}
80108218:	90                   	nop
80108219:	c9                   	leave  
8010821a:	c3                   	ret    

8010821b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010821b:	55                   	push   %ebp
8010821c:	89 e5                	mov    %esp,%ebp
8010821e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108221:	83 ec 04             	sub    $0x4,%esp
80108224:	6a 00                	push   $0x0
80108226:	ff 75 0c             	push   0xc(%ebp)
80108229:	ff 75 08             	push   0x8(%ebp)
8010822c:	e8 69 f8 ff ff       	call   80107a9a <walkpgdir>
80108231:	83 c4 10             	add    $0x10,%esp
80108234:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108237:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010823b:	75 0d                	jne    8010824a <clearpteu+0x2f>
    panic("clearpteu");
8010823d:	83 ec 0c             	sub    $0xc,%esp
80108240:	68 ac b0 10 80       	push   $0x8010b0ac
80108245:	e8 5f 83 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
8010824a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824d:	8b 00                	mov    (%eax),%eax
8010824f:	83 e0 fb             	and    $0xfffffffb,%eax
80108252:	89 c2                	mov    %eax,%edx
80108254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108257:	89 10                	mov    %edx,(%eax)
}
80108259:	90                   	nop
8010825a:	c9                   	leave  
8010825b:	c3                   	ret    

8010825c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010825c:	55                   	push   %ebp
8010825d:	89 e5                	mov    %esp,%ebp
8010825f:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108262:	e8 59 f9 ff ff       	call   80107bc0 <setupkvm>
80108267:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010826a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010826e:	75 0a                	jne    8010827a <copyuvm+0x1e>
    return 0;
80108270:	b8 00 00 00 00       	mov    $0x0,%eax
80108275:	e9 d6 00 00 00       	jmp    80108350 <copyuvm+0xf4>
  for(i = 0; i < /*sp*/KERNBASE; i += PGSIZE){
8010827a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108281:	e9 a3 00 00 00       	jmp    80108329 <copyuvm+0xcd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108289:	83 ec 04             	sub    $0x4,%esp
8010828c:	6a 00                	push   $0x0
8010828e:	50                   	push   %eax
8010828f:	ff 75 08             	push   0x8(%ebp)
80108292:	e8 03 f8 ff ff       	call   80107a9a <walkpgdir>
80108297:	83 c4 10             	add    $0x10,%esp
8010829a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010829d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082a1:	74 7b                	je     8010831e <copyuvm+0xc2>
      //panic("copyuvm: pte should exist");
      continue;
    if(!(*pte & PTE_P))
801082a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082a6:	8b 00                	mov    (%eax),%eax
801082a8:	83 e0 01             	and    $0x1,%eax
801082ab:	85 c0                	test   %eax,%eax
801082ad:	74 72                	je     80108321 <copyuvm+0xc5>
      //panic("copyuvm: page not present");
      continue;
    pa = PTE_ADDR(*pte);
801082af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082b2:	8b 00                	mov    (%eax),%eax
801082b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801082bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082bf:	8b 00                	mov    (%eax),%eax
801082c1:	25 ff 0f 00 00       	and    $0xfff,%eax
801082c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801082c9:	e8 ba a4 ff ff       	call   80102788 <kalloc>
801082ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
801082d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801082d5:	74 62                	je     80108339 <copyuvm+0xdd>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801082d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082da:	05 00 00 00 80       	add    $0x80000000,%eax
801082df:	83 ec 04             	sub    $0x4,%esp
801082e2:	68 00 10 00 00       	push   $0x1000
801082e7:	50                   	push   %eax
801082e8:	ff 75 e0             	push   -0x20(%ebp)
801082eb:	e8 cc cb ff ff       	call   80104ebc <memmove>
801082f0:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801082f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801082f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801082f9:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801082ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108302:	83 ec 0c             	sub    $0xc,%esp
80108305:	52                   	push   %edx
80108306:	51                   	push   %ecx
80108307:	68 00 10 00 00       	push   $0x1000
8010830c:	50                   	push   %eax
8010830d:	ff 75 f0             	push   -0x10(%ebp)
80108310:	e8 1b f8 ff ff       	call   80107b30 <mappages>
80108315:	83 c4 20             	add    $0x20,%esp
80108318:	85 c0                	test   %eax,%eax
8010831a:	78 20                	js     8010833c <copyuvm+0xe0>
8010831c:	eb 04                	jmp    80108322 <copyuvm+0xc6>
      continue;
8010831e:	90                   	nop
8010831f:	eb 01                	jmp    80108322 <copyuvm+0xc6>
      continue;
80108321:	90                   	nop
  for(i = 0; i < /*sp*/KERNBASE; i += PGSIZE){
80108322:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832c:	85 c0                	test   %eax,%eax
8010832e:	0f 89 52 ff ff ff    	jns    80108286 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80108334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108337:	eb 17                	jmp    80108350 <copyuvm+0xf4>
      goto bad;
80108339:	90                   	nop
8010833a:	eb 01                	jmp    8010833d <copyuvm+0xe1>
      goto bad;
8010833c:	90                   	nop

bad:
  freevm(d);
8010833d:	83 ec 0c             	sub    $0xc,%esp
80108340:	ff 75 f0             	push   -0x10(%ebp)
80108343:	e8 3a fe ff ff       	call   80108182 <freevm>
80108348:	83 c4 10             	add    $0x10,%esp
  return 0;
8010834b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108350:	c9                   	leave  
80108351:	c3                   	ret    

80108352 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108352:	55                   	push   %ebp
80108353:	89 e5                	mov    %esp,%ebp
80108355:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108358:	83 ec 04             	sub    $0x4,%esp
8010835b:	6a 00                	push   $0x0
8010835d:	ff 75 0c             	push   0xc(%ebp)
80108360:	ff 75 08             	push   0x8(%ebp)
80108363:	e8 32 f7 ff ff       	call   80107a9a <walkpgdir>
80108368:	83 c4 10             	add    $0x10,%esp
8010836b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010836e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108371:	8b 00                	mov    (%eax),%eax
80108373:	83 e0 01             	and    $0x1,%eax
80108376:	85 c0                	test   %eax,%eax
80108378:	75 07                	jne    80108381 <uva2ka+0x2f>
    return 0;
8010837a:	b8 00 00 00 00       	mov    $0x0,%eax
8010837f:	eb 22                	jmp    801083a3 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108384:	8b 00                	mov    (%eax),%eax
80108386:	83 e0 04             	and    $0x4,%eax
80108389:	85 c0                	test   %eax,%eax
8010838b:	75 07                	jne    80108394 <uva2ka+0x42>
    return 0;
8010838d:	b8 00 00 00 00       	mov    $0x0,%eax
80108392:	eb 0f                	jmp    801083a3 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80108394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108397:	8b 00                	mov    (%eax),%eax
80108399:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010839e:	05 00 00 00 80       	add    $0x80000000,%eax
}
801083a3:	c9                   	leave  
801083a4:	c3                   	ret    

801083a5 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801083a5:	55                   	push   %ebp
801083a6:	89 e5                	mov    %esp,%ebp
801083a8:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801083ab:	8b 45 10             	mov    0x10(%ebp),%eax
801083ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801083b1:	eb 7f                	jmp    80108432 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801083b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801083b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801083be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083c1:	83 ec 08             	sub    $0x8,%esp
801083c4:	50                   	push   %eax
801083c5:	ff 75 08             	push   0x8(%ebp)
801083c8:	e8 85 ff ff ff       	call   80108352 <uva2ka>
801083cd:	83 c4 10             	add    $0x10,%esp
801083d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801083d3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801083d7:	75 07                	jne    801083e0 <copyout+0x3b>
      return -1;
801083d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083de:	eb 61                	jmp    80108441 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801083e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083e3:	2b 45 0c             	sub    0xc(%ebp),%eax
801083e6:	05 00 10 00 00       	add    $0x1000,%eax
801083eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801083ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083f1:	3b 45 14             	cmp    0x14(%ebp),%eax
801083f4:	76 06                	jbe    801083fc <copyout+0x57>
      n = len;
801083f6:	8b 45 14             	mov    0x14(%ebp),%eax
801083f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801083fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801083ff:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108402:	89 c2                	mov    %eax,%edx
80108404:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108407:	01 d0                	add    %edx,%eax
80108409:	83 ec 04             	sub    $0x4,%esp
8010840c:	ff 75 f0             	push   -0x10(%ebp)
8010840f:	ff 75 f4             	push   -0xc(%ebp)
80108412:	50                   	push   %eax
80108413:	e8 a4 ca ff ff       	call   80104ebc <memmove>
80108418:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010841b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010841e:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108421:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108424:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108427:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010842a:	05 00 10 00 00       	add    $0x1000,%eax
8010842f:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108432:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108436:	0f 85 77 ff ff ff    	jne    801083b3 <copyout+0xe>
  }
  return 0;
8010843c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108441:	c9                   	leave  
80108442:	c3                   	ret    

80108443 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108443:	55                   	push   %ebp
80108444:	89 e5                	mov    %esp,%ebp
80108446:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108449:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108450:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108453:	8b 40 08             	mov    0x8(%eax),%eax
80108456:	05 00 00 00 80       	add    $0x80000000,%eax
8010845b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
8010845e:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108468:	8b 40 24             	mov    0x24(%eax),%eax
8010846b:	a3 00 b1 30 80       	mov    %eax,0x8030b100
  ncpu = 0;
80108470:	c7 05 50 e7 30 80 00 	movl   $0x0,0x8030e750
80108477:	00 00 00 

  while(i<madt->len){
8010847a:	90                   	nop
8010847b:	e9 bd 00 00 00       	jmp    8010853d <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80108480:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108483:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108486:	01 d0                	add    %edx,%eax
80108488:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
8010848b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010848e:	0f b6 00             	movzbl (%eax),%eax
80108491:	0f b6 c0             	movzbl %al,%eax
80108494:	83 f8 05             	cmp    $0x5,%eax
80108497:	0f 87 a0 00 00 00    	ja     8010853d <mpinit_uefi+0xfa>
8010849d:	8b 04 85 b8 b0 10 80 	mov    -0x7fef4f48(,%eax,4),%eax
801084a4:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801084a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801084ac:	a1 50 e7 30 80       	mov    0x8030e750,%eax
801084b1:	83 f8 03             	cmp    $0x3,%eax
801084b4:	7f 28                	jg     801084de <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801084b6:	8b 15 50 e7 30 80    	mov    0x8030e750,%edx
801084bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801084bf:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801084c3:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
801084c9:	81 c2 80 e4 30 80    	add    $0x8030e480,%edx
801084cf:	88 02                	mov    %al,(%edx)
          ncpu++;
801084d1:	a1 50 e7 30 80       	mov    0x8030e750,%eax
801084d6:	83 c0 01             	add    $0x1,%eax
801084d9:	a3 50 e7 30 80       	mov    %eax,0x8030e750
        }
        i += lapic_entry->record_len;
801084de:	8b 45 e0             	mov    -0x20(%ebp),%eax
801084e1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801084e5:	0f b6 c0             	movzbl %al,%eax
801084e8:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801084eb:	eb 50                	jmp    8010853d <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801084ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801084f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801084f6:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801084fa:	a2 54 e7 30 80       	mov    %al,0x8030e754
        i += ioapic->record_len;
801084ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108502:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108506:	0f b6 c0             	movzbl %al,%eax
80108509:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010850c:	eb 2f                	jmp    8010853d <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
8010850e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108511:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108514:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108517:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010851b:	0f b6 c0             	movzbl %al,%eax
8010851e:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108521:	eb 1a                	jmp    8010853d <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108523:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108526:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108529:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010852c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108530:	0f b6 c0             	movzbl %al,%eax
80108533:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108536:	eb 05                	jmp    8010853d <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80108538:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
8010853c:	90                   	nop
  while(i<madt->len){
8010853d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108540:	8b 40 04             	mov    0x4(%eax),%eax
80108543:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108546:	0f 82 34 ff ff ff    	jb     80108480 <mpinit_uefi+0x3d>
    }
  }

}
8010854c:	90                   	nop
8010854d:	90                   	nop
8010854e:	c9                   	leave  
8010854f:	c3                   	ret    

80108550 <inb>:
{
80108550:	55                   	push   %ebp
80108551:	89 e5                	mov    %esp,%ebp
80108553:	83 ec 14             	sub    $0x14,%esp
80108556:	8b 45 08             	mov    0x8(%ebp),%eax
80108559:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010855d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108561:	89 c2                	mov    %eax,%edx
80108563:	ec                   	in     (%dx),%al
80108564:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108567:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010856b:	c9                   	leave  
8010856c:	c3                   	ret    

8010856d <outb>:
{
8010856d:	55                   	push   %ebp
8010856e:	89 e5                	mov    %esp,%ebp
80108570:	83 ec 08             	sub    $0x8,%esp
80108573:	8b 45 08             	mov    0x8(%ebp),%eax
80108576:	8b 55 0c             	mov    0xc(%ebp),%edx
80108579:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010857d:	89 d0                	mov    %edx,%eax
8010857f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108582:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108586:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010858a:	ee                   	out    %al,(%dx)
}
8010858b:	90                   	nop
8010858c:	c9                   	leave  
8010858d:	c3                   	ret    

8010858e <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
8010858e:	55                   	push   %ebp
8010858f:	89 e5                	mov    %esp,%ebp
80108591:	83 ec 28             	sub    $0x28,%esp
80108594:	8b 45 08             	mov    0x8(%ebp),%eax
80108597:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
8010859a:	6a 00                	push   $0x0
8010859c:	68 fa 03 00 00       	push   $0x3fa
801085a1:	e8 c7 ff ff ff       	call   8010856d <outb>
801085a6:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801085a9:	68 80 00 00 00       	push   $0x80
801085ae:	68 fb 03 00 00       	push   $0x3fb
801085b3:	e8 b5 ff ff ff       	call   8010856d <outb>
801085b8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801085bb:	6a 0c                	push   $0xc
801085bd:	68 f8 03 00 00       	push   $0x3f8
801085c2:	e8 a6 ff ff ff       	call   8010856d <outb>
801085c7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801085ca:	6a 00                	push   $0x0
801085cc:	68 f9 03 00 00       	push   $0x3f9
801085d1:	e8 97 ff ff ff       	call   8010856d <outb>
801085d6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801085d9:	6a 03                	push   $0x3
801085db:	68 fb 03 00 00       	push   $0x3fb
801085e0:	e8 88 ff ff ff       	call   8010856d <outb>
801085e5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801085e8:	6a 00                	push   $0x0
801085ea:	68 fc 03 00 00       	push   $0x3fc
801085ef:	e8 79 ff ff ff       	call   8010856d <outb>
801085f4:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801085f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085fe:	eb 11                	jmp    80108611 <uart_debug+0x83>
80108600:	83 ec 0c             	sub    $0xc,%esp
80108603:	6a 0a                	push   $0xa
80108605:	e8 15 a5 ff ff       	call   80102b1f <microdelay>
8010860a:	83 c4 10             	add    $0x10,%esp
8010860d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108611:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108615:	7f 1a                	jg     80108631 <uart_debug+0xa3>
80108617:	83 ec 0c             	sub    $0xc,%esp
8010861a:	68 fd 03 00 00       	push   $0x3fd
8010861f:	e8 2c ff ff ff       	call   80108550 <inb>
80108624:	83 c4 10             	add    $0x10,%esp
80108627:	0f b6 c0             	movzbl %al,%eax
8010862a:	83 e0 20             	and    $0x20,%eax
8010862d:	85 c0                	test   %eax,%eax
8010862f:	74 cf                	je     80108600 <uart_debug+0x72>
  outb(COM1+0, p);
80108631:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108635:	0f b6 c0             	movzbl %al,%eax
80108638:	83 ec 08             	sub    $0x8,%esp
8010863b:	50                   	push   %eax
8010863c:	68 f8 03 00 00       	push   $0x3f8
80108641:	e8 27 ff ff ff       	call   8010856d <outb>
80108646:	83 c4 10             	add    $0x10,%esp
}
80108649:	90                   	nop
8010864a:	c9                   	leave  
8010864b:	c3                   	ret    

8010864c <uart_debugs>:

void uart_debugs(char *p){
8010864c:	55                   	push   %ebp
8010864d:	89 e5                	mov    %esp,%ebp
8010864f:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108652:	eb 1b                	jmp    8010866f <uart_debugs+0x23>
    uart_debug(*p++);
80108654:	8b 45 08             	mov    0x8(%ebp),%eax
80108657:	8d 50 01             	lea    0x1(%eax),%edx
8010865a:	89 55 08             	mov    %edx,0x8(%ebp)
8010865d:	0f b6 00             	movzbl (%eax),%eax
80108660:	0f be c0             	movsbl %al,%eax
80108663:	83 ec 0c             	sub    $0xc,%esp
80108666:	50                   	push   %eax
80108667:	e8 22 ff ff ff       	call   8010858e <uart_debug>
8010866c:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010866f:	8b 45 08             	mov    0x8(%ebp),%eax
80108672:	0f b6 00             	movzbl (%eax),%eax
80108675:	84 c0                	test   %al,%al
80108677:	75 db                	jne    80108654 <uart_debugs+0x8>
  }
}
80108679:	90                   	nop
8010867a:	90                   	nop
8010867b:	c9                   	leave  
8010867c:	c3                   	ret    

8010867d <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
8010867d:	55                   	push   %ebp
8010867e:	89 e5                	mov    %esp,%ebp
80108680:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108683:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010868a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010868d:	8b 50 14             	mov    0x14(%eax),%edx
80108690:	8b 40 10             	mov    0x10(%eax),%eax
80108693:	a3 58 e7 30 80       	mov    %eax,0x8030e758
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108698:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010869b:	8b 50 1c             	mov    0x1c(%eax),%edx
8010869e:	8b 40 18             	mov    0x18(%eax),%eax
801086a1:	a3 60 e7 30 80       	mov    %eax,0x8030e760
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801086a6:	8b 15 60 e7 30 80    	mov    0x8030e760,%edx
801086ac:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801086b1:	29 d0                	sub    %edx,%eax
801086b3:	a3 5c e7 30 80       	mov    %eax,0x8030e75c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801086b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086bb:	8b 50 24             	mov    0x24(%eax),%edx
801086be:	8b 40 20             	mov    0x20(%eax),%eax
801086c1:	a3 64 e7 30 80       	mov    %eax,0x8030e764
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801086c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086c9:	8b 50 2c             	mov    0x2c(%eax),%edx
801086cc:	8b 40 28             	mov    0x28(%eax),%eax
801086cf:	a3 68 e7 30 80       	mov    %eax,0x8030e768
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801086d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086d7:	8b 50 34             	mov    0x34(%eax),%edx
801086da:	8b 40 30             	mov    0x30(%eax),%eax
801086dd:	a3 6c e7 30 80       	mov    %eax,0x8030e76c
}
801086e2:	90                   	nop
801086e3:	c9                   	leave  
801086e4:	c3                   	ret    

801086e5 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801086e5:	55                   	push   %ebp
801086e6:	89 e5                	mov    %esp,%ebp
801086e8:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801086eb:	8b 15 6c e7 30 80    	mov    0x8030e76c,%edx
801086f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801086f4:	0f af d0             	imul   %eax,%edx
801086f7:	8b 45 08             	mov    0x8(%ebp),%eax
801086fa:	01 d0                	add    %edx,%eax
801086fc:	c1 e0 02             	shl    $0x2,%eax
801086ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108702:	8b 15 5c e7 30 80    	mov    0x8030e75c,%edx
80108708:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010870b:	01 d0                	add    %edx,%eax
8010870d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108710:	8b 45 10             	mov    0x10(%ebp),%eax
80108713:	0f b6 10             	movzbl (%eax),%edx
80108716:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108719:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
8010871b:	8b 45 10             	mov    0x10(%ebp),%eax
8010871e:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108722:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108725:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108728:	8b 45 10             	mov    0x10(%ebp),%eax
8010872b:	0f b6 50 02          	movzbl 0x2(%eax),%edx
8010872f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108732:	88 50 02             	mov    %dl,0x2(%eax)
}
80108735:	90                   	nop
80108736:	c9                   	leave  
80108737:	c3                   	ret    

80108738 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108738:	55                   	push   %ebp
80108739:	89 e5                	mov    %esp,%ebp
8010873b:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
8010873e:	8b 15 6c e7 30 80    	mov    0x8030e76c,%edx
80108744:	8b 45 08             	mov    0x8(%ebp),%eax
80108747:	0f af c2             	imul   %edx,%eax
8010874a:	c1 e0 02             	shl    $0x2,%eax
8010874d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108750:	a1 60 e7 30 80       	mov    0x8030e760,%eax
80108755:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108758:	29 d0                	sub    %edx,%eax
8010875a:	8b 0d 5c e7 30 80    	mov    0x8030e75c,%ecx
80108760:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108763:	01 ca                	add    %ecx,%edx
80108765:	89 d1                	mov    %edx,%ecx
80108767:	8b 15 5c e7 30 80    	mov    0x8030e75c,%edx
8010876d:	83 ec 04             	sub    $0x4,%esp
80108770:	50                   	push   %eax
80108771:	51                   	push   %ecx
80108772:	52                   	push   %edx
80108773:	e8 44 c7 ff ff       	call   80104ebc <memmove>
80108778:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
8010877b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877e:	8b 0d 5c e7 30 80    	mov    0x8030e75c,%ecx
80108784:	8b 15 60 e7 30 80    	mov    0x8030e760,%edx
8010878a:	01 ca                	add    %ecx,%edx
8010878c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010878f:	29 ca                	sub    %ecx,%edx
80108791:	83 ec 04             	sub    $0x4,%esp
80108794:	50                   	push   %eax
80108795:	6a 00                	push   $0x0
80108797:	52                   	push   %edx
80108798:	e8 60 c6 ff ff       	call   80104dfd <memset>
8010879d:	83 c4 10             	add    $0x10,%esp
}
801087a0:	90                   	nop
801087a1:	c9                   	leave  
801087a2:	c3                   	ret    

801087a3 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801087a3:	55                   	push   %ebp
801087a4:	89 e5                	mov    %esp,%ebp
801087a6:	53                   	push   %ebx
801087a7:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801087aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801087b1:	e9 b1 00 00 00       	jmp    80108867 <font_render+0xc4>
    for(int j=14;j>-1;j--){
801087b6:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801087bd:	e9 97 00 00 00       	jmp    80108859 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
801087c2:	8b 45 10             	mov    0x10(%ebp),%eax
801087c5:	83 e8 20             	sub    $0x20,%eax
801087c8:	6b d0 1e             	imul   $0x1e,%eax,%edx
801087cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ce:	01 d0                	add    %edx,%eax
801087d0:	0f b7 84 00 e0 b0 10 	movzwl -0x7fef4f20(%eax,%eax,1),%eax
801087d7:	80 
801087d8:	0f b7 d0             	movzwl %ax,%edx
801087db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087de:	bb 01 00 00 00       	mov    $0x1,%ebx
801087e3:	89 c1                	mov    %eax,%ecx
801087e5:	d3 e3                	shl    %cl,%ebx
801087e7:	89 d8                	mov    %ebx,%eax
801087e9:	21 d0                	and    %edx,%eax
801087eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801087ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087f1:	ba 01 00 00 00       	mov    $0x1,%edx
801087f6:	89 c1                	mov    %eax,%ecx
801087f8:	d3 e2                	shl    %cl,%edx
801087fa:	89 d0                	mov    %edx,%eax
801087fc:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801087ff:	75 2b                	jne    8010882c <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108801:	8b 55 0c             	mov    0xc(%ebp),%edx
80108804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108807:	01 c2                	add    %eax,%edx
80108809:	b8 0e 00 00 00       	mov    $0xe,%eax
8010880e:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108811:	89 c1                	mov    %eax,%ecx
80108813:	8b 45 08             	mov    0x8(%ebp),%eax
80108816:	01 c8                	add    %ecx,%eax
80108818:	83 ec 04             	sub    $0x4,%esp
8010881b:	68 00 f5 10 80       	push   $0x8010f500
80108820:	52                   	push   %edx
80108821:	50                   	push   %eax
80108822:	e8 be fe ff ff       	call   801086e5 <graphic_draw_pixel>
80108827:	83 c4 10             	add    $0x10,%esp
8010882a:	eb 29                	jmp    80108855 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010882c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010882f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108832:	01 c2                	add    %eax,%edx
80108834:	b8 0e 00 00 00       	mov    $0xe,%eax
80108839:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010883c:	89 c1                	mov    %eax,%ecx
8010883e:	8b 45 08             	mov    0x8(%ebp),%eax
80108841:	01 c8                	add    %ecx,%eax
80108843:	83 ec 04             	sub    $0x4,%esp
80108846:	68 70 e7 30 80       	push   $0x8030e770
8010884b:	52                   	push   %edx
8010884c:	50                   	push   %eax
8010884d:	e8 93 fe ff ff       	call   801086e5 <graphic_draw_pixel>
80108852:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108855:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108859:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010885d:	0f 89 5f ff ff ff    	jns    801087c2 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108863:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108867:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010886b:	0f 8e 45 ff ff ff    	jle    801087b6 <font_render+0x13>
      }
    }
  }
}
80108871:	90                   	nop
80108872:	90                   	nop
80108873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108876:	c9                   	leave  
80108877:	c3                   	ret    

80108878 <font_render_string>:

void font_render_string(char *string,int row){
80108878:	55                   	push   %ebp
80108879:	89 e5                	mov    %esp,%ebp
8010887b:	53                   	push   %ebx
8010887c:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
8010887f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108886:	eb 33                	jmp    801088bb <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108888:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010888b:	8b 45 08             	mov    0x8(%ebp),%eax
8010888e:	01 d0                	add    %edx,%eax
80108890:	0f b6 00             	movzbl (%eax),%eax
80108893:	0f be c8             	movsbl %al,%ecx
80108896:	8b 45 0c             	mov    0xc(%ebp),%eax
80108899:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010889c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010889f:	89 d8                	mov    %ebx,%eax
801088a1:	c1 e0 04             	shl    $0x4,%eax
801088a4:	29 d8                	sub    %ebx,%eax
801088a6:	83 c0 02             	add    $0x2,%eax
801088a9:	83 ec 04             	sub    $0x4,%esp
801088ac:	51                   	push   %ecx
801088ad:	52                   	push   %edx
801088ae:	50                   	push   %eax
801088af:	e8 ef fe ff ff       	call   801087a3 <font_render>
801088b4:	83 c4 10             	add    $0x10,%esp
    i++;
801088b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801088bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088be:	8b 45 08             	mov    0x8(%ebp),%eax
801088c1:	01 d0                	add    %edx,%eax
801088c3:	0f b6 00             	movzbl (%eax),%eax
801088c6:	84 c0                	test   %al,%al
801088c8:	74 06                	je     801088d0 <font_render_string+0x58>
801088ca:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801088ce:	7e b8                	jle    80108888 <font_render_string+0x10>
  }
}
801088d0:	90                   	nop
801088d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801088d4:	c9                   	leave  
801088d5:	c3                   	ret    

801088d6 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801088d6:	55                   	push   %ebp
801088d7:	89 e5                	mov    %esp,%ebp
801088d9:	53                   	push   %ebx
801088da:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801088dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801088e4:	eb 6b                	jmp    80108951 <pci_init+0x7b>
    for(int j=0;j<32;j++){
801088e6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801088ed:	eb 58                	jmp    80108947 <pci_init+0x71>
      for(int k=0;k<8;k++){
801088ef:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801088f6:	eb 45                	jmp    8010893d <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801088f8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801088fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801088fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108901:	83 ec 0c             	sub    $0xc,%esp
80108904:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108907:	53                   	push   %ebx
80108908:	6a 00                	push   $0x0
8010890a:	51                   	push   %ecx
8010890b:	52                   	push   %edx
8010890c:	50                   	push   %eax
8010890d:	e8 b0 00 00 00       	call   801089c2 <pci_access_config>
80108912:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108915:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108918:	0f b7 c0             	movzwl %ax,%eax
8010891b:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108920:	74 17                	je     80108939 <pci_init+0x63>
        pci_init_device(i,j,k);
80108922:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108925:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010892b:	83 ec 04             	sub    $0x4,%esp
8010892e:	51                   	push   %ecx
8010892f:	52                   	push   %edx
80108930:	50                   	push   %eax
80108931:	e8 37 01 00 00       	call   80108a6d <pci_init_device>
80108936:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108939:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010893d:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108941:	7e b5                	jle    801088f8 <pci_init+0x22>
    for(int j=0;j<32;j++){
80108943:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108947:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
8010894b:	7e a2                	jle    801088ef <pci_init+0x19>
  for(int i=0;i<256;i++){
8010894d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108951:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108958:	7e 8c                	jle    801088e6 <pci_init+0x10>
      }
      }
    }
  }
}
8010895a:	90                   	nop
8010895b:	90                   	nop
8010895c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010895f:	c9                   	leave  
80108960:	c3                   	ret    

80108961 <pci_write_config>:

void pci_write_config(uint config){
80108961:	55                   	push   %ebp
80108962:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108964:	8b 45 08             	mov    0x8(%ebp),%eax
80108967:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010896c:	89 c0                	mov    %eax,%eax
8010896e:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010896f:	90                   	nop
80108970:	5d                   	pop    %ebp
80108971:	c3                   	ret    

80108972 <pci_write_data>:

void pci_write_data(uint config){
80108972:	55                   	push   %ebp
80108973:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108975:	8b 45 08             	mov    0x8(%ebp),%eax
80108978:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010897d:	89 c0                	mov    %eax,%eax
8010897f:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108980:	90                   	nop
80108981:	5d                   	pop    %ebp
80108982:	c3                   	ret    

80108983 <pci_read_config>:
uint pci_read_config(){
80108983:	55                   	push   %ebp
80108984:	89 e5                	mov    %esp,%ebp
80108986:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108989:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010898e:	ed                   	in     (%dx),%eax
8010898f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108992:	83 ec 0c             	sub    $0xc,%esp
80108995:	68 c8 00 00 00       	push   $0xc8
8010899a:	e8 80 a1 ff ff       	call   80102b1f <microdelay>
8010899f:	83 c4 10             	add    $0x10,%esp
  return data;
801089a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801089a5:	c9                   	leave  
801089a6:	c3                   	ret    

801089a7 <pci_test>:


void pci_test(){
801089a7:	55                   	push   %ebp
801089a8:	89 e5                	mov    %esp,%ebp
801089aa:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801089ad:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801089b4:	ff 75 fc             	push   -0x4(%ebp)
801089b7:	e8 a5 ff ff ff       	call   80108961 <pci_write_config>
801089bc:	83 c4 04             	add    $0x4,%esp
}
801089bf:	90                   	nop
801089c0:	c9                   	leave  
801089c1:	c3                   	ret    

801089c2 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801089c2:	55                   	push   %ebp
801089c3:	89 e5                	mov    %esp,%ebp
801089c5:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801089c8:	8b 45 08             	mov    0x8(%ebp),%eax
801089cb:	c1 e0 10             	shl    $0x10,%eax
801089ce:	25 00 00 ff 00       	and    $0xff0000,%eax
801089d3:	89 c2                	mov    %eax,%edx
801089d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801089d8:	c1 e0 0b             	shl    $0xb,%eax
801089db:	0f b7 c0             	movzwl %ax,%eax
801089de:	09 c2                	or     %eax,%edx
801089e0:	8b 45 10             	mov    0x10(%ebp),%eax
801089e3:	c1 e0 08             	shl    $0x8,%eax
801089e6:	25 00 07 00 00       	and    $0x700,%eax
801089eb:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801089ed:	8b 45 14             	mov    0x14(%ebp),%eax
801089f0:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801089f5:	09 d0                	or     %edx,%eax
801089f7:	0d 00 00 00 80       	or     $0x80000000,%eax
801089fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801089ff:	ff 75 f4             	push   -0xc(%ebp)
80108a02:	e8 5a ff ff ff       	call   80108961 <pci_write_config>
80108a07:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108a0a:	e8 74 ff ff ff       	call   80108983 <pci_read_config>
80108a0f:	8b 55 18             	mov    0x18(%ebp),%edx
80108a12:	89 02                	mov    %eax,(%edx)
}
80108a14:	90                   	nop
80108a15:	c9                   	leave  
80108a16:	c3                   	ret    

80108a17 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108a17:	55                   	push   %ebp
80108a18:	89 e5                	mov    %esp,%ebp
80108a1a:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a1d:	8b 45 08             	mov    0x8(%ebp),%eax
80108a20:	c1 e0 10             	shl    $0x10,%eax
80108a23:	25 00 00 ff 00       	and    $0xff0000,%eax
80108a28:	89 c2                	mov    %eax,%edx
80108a2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a2d:	c1 e0 0b             	shl    $0xb,%eax
80108a30:	0f b7 c0             	movzwl %ax,%eax
80108a33:	09 c2                	or     %eax,%edx
80108a35:	8b 45 10             	mov    0x10(%ebp),%eax
80108a38:	c1 e0 08             	shl    $0x8,%eax
80108a3b:	25 00 07 00 00       	and    $0x700,%eax
80108a40:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108a42:	8b 45 14             	mov    0x14(%ebp),%eax
80108a45:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a4a:	09 d0                	or     %edx,%eax
80108a4c:	0d 00 00 00 80       	or     $0x80000000,%eax
80108a51:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108a54:	ff 75 fc             	push   -0x4(%ebp)
80108a57:	e8 05 ff ff ff       	call   80108961 <pci_write_config>
80108a5c:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108a5f:	ff 75 18             	push   0x18(%ebp)
80108a62:	e8 0b ff ff ff       	call   80108972 <pci_write_data>
80108a67:	83 c4 04             	add    $0x4,%esp
}
80108a6a:	90                   	nop
80108a6b:	c9                   	leave  
80108a6c:	c3                   	ret    

80108a6d <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108a6d:	55                   	push   %ebp
80108a6e:	89 e5                	mov    %esp,%ebp
80108a70:	53                   	push   %ebx
80108a71:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108a74:	8b 45 08             	mov    0x8(%ebp),%eax
80108a77:	a2 74 e7 30 80       	mov    %al,0x8030e774
  dev.device_num = device_num;
80108a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a7f:	a2 75 e7 30 80       	mov    %al,0x8030e775
  dev.function_num = function_num;
80108a84:	8b 45 10             	mov    0x10(%ebp),%eax
80108a87:	a2 76 e7 30 80       	mov    %al,0x8030e776
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108a8c:	ff 75 10             	push   0x10(%ebp)
80108a8f:	ff 75 0c             	push   0xc(%ebp)
80108a92:	ff 75 08             	push   0x8(%ebp)
80108a95:	68 24 c7 10 80       	push   $0x8010c724
80108a9a:	e8 55 79 ff ff       	call   801003f4 <cprintf>
80108a9f:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108aa2:	83 ec 0c             	sub    $0xc,%esp
80108aa5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108aa8:	50                   	push   %eax
80108aa9:	6a 00                	push   $0x0
80108aab:	ff 75 10             	push   0x10(%ebp)
80108aae:	ff 75 0c             	push   0xc(%ebp)
80108ab1:	ff 75 08             	push   0x8(%ebp)
80108ab4:	e8 09 ff ff ff       	call   801089c2 <pci_access_config>
80108ab9:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108abc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108abf:	c1 e8 10             	shr    $0x10,%eax
80108ac2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108ac5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ac8:	25 ff ff 00 00       	and    $0xffff,%eax
80108acd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad3:	a3 78 e7 30 80       	mov    %eax,0x8030e778
  dev.vendor_id = vendor_id;
80108ad8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108adb:	a3 7c e7 30 80       	mov    %eax,0x8030e77c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108ae0:	83 ec 04             	sub    $0x4,%esp
80108ae3:	ff 75 f0             	push   -0x10(%ebp)
80108ae6:	ff 75 f4             	push   -0xc(%ebp)
80108ae9:	68 58 c7 10 80       	push   $0x8010c758
80108aee:	e8 01 79 ff ff       	call   801003f4 <cprintf>
80108af3:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108af6:	83 ec 0c             	sub    $0xc,%esp
80108af9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108afc:	50                   	push   %eax
80108afd:	6a 08                	push   $0x8
80108aff:	ff 75 10             	push   0x10(%ebp)
80108b02:	ff 75 0c             	push   0xc(%ebp)
80108b05:	ff 75 08             	push   0x8(%ebp)
80108b08:	e8 b5 fe ff ff       	call   801089c2 <pci_access_config>
80108b0d:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b10:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b13:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108b16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b19:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b1c:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108b1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b22:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b25:	0f b6 c0             	movzbl %al,%eax
80108b28:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108b2b:	c1 eb 18             	shr    $0x18,%ebx
80108b2e:	83 ec 0c             	sub    $0xc,%esp
80108b31:	51                   	push   %ecx
80108b32:	52                   	push   %edx
80108b33:	50                   	push   %eax
80108b34:	53                   	push   %ebx
80108b35:	68 7c c7 10 80       	push   $0x8010c77c
80108b3a:	e8 b5 78 ff ff       	call   801003f4 <cprintf>
80108b3f:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108b42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b45:	c1 e8 18             	shr    $0x18,%eax
80108b48:	a2 80 e7 30 80       	mov    %al,0x8030e780
  dev.sub_class = (data>>16)&0xFF;
80108b4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b50:	c1 e8 10             	shr    $0x10,%eax
80108b53:	a2 81 e7 30 80       	mov    %al,0x8030e781
  dev.interface = (data>>8)&0xFF;
80108b58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b5b:	c1 e8 08             	shr    $0x8,%eax
80108b5e:	a2 82 e7 30 80       	mov    %al,0x8030e782
  dev.revision_id = data&0xFF;
80108b63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b66:	a2 83 e7 30 80       	mov    %al,0x8030e783
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108b6b:	83 ec 0c             	sub    $0xc,%esp
80108b6e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108b71:	50                   	push   %eax
80108b72:	6a 10                	push   $0x10
80108b74:	ff 75 10             	push   0x10(%ebp)
80108b77:	ff 75 0c             	push   0xc(%ebp)
80108b7a:	ff 75 08             	push   0x8(%ebp)
80108b7d:	e8 40 fe ff ff       	call   801089c2 <pci_access_config>
80108b82:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108b85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b88:	a3 84 e7 30 80       	mov    %eax,0x8030e784
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108b8d:	83 ec 0c             	sub    $0xc,%esp
80108b90:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108b93:	50                   	push   %eax
80108b94:	6a 14                	push   $0x14
80108b96:	ff 75 10             	push   0x10(%ebp)
80108b99:	ff 75 0c             	push   0xc(%ebp)
80108b9c:	ff 75 08             	push   0x8(%ebp)
80108b9f:	e8 1e fe ff ff       	call   801089c2 <pci_access_config>
80108ba4:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108ba7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108baa:	a3 88 e7 30 80       	mov    %eax,0x8030e788
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108baf:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108bb6:	75 5a                	jne    80108c12 <pci_init_device+0x1a5>
80108bb8:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108bbf:	75 51                	jne    80108c12 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108bc1:	83 ec 0c             	sub    $0xc,%esp
80108bc4:	68 c1 c7 10 80       	push   $0x8010c7c1
80108bc9:	e8 26 78 ff ff       	call   801003f4 <cprintf>
80108bce:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108bd1:	83 ec 0c             	sub    $0xc,%esp
80108bd4:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108bd7:	50                   	push   %eax
80108bd8:	68 f0 00 00 00       	push   $0xf0
80108bdd:	ff 75 10             	push   0x10(%ebp)
80108be0:	ff 75 0c             	push   0xc(%ebp)
80108be3:	ff 75 08             	push   0x8(%ebp)
80108be6:	e8 d7 fd ff ff       	call   801089c2 <pci_access_config>
80108beb:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108bee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bf1:	83 ec 08             	sub    $0x8,%esp
80108bf4:	50                   	push   %eax
80108bf5:	68 db c7 10 80       	push   $0x8010c7db
80108bfa:	e8 f5 77 ff ff       	call   801003f4 <cprintf>
80108bff:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108c02:	83 ec 0c             	sub    $0xc,%esp
80108c05:	68 74 e7 30 80       	push   $0x8030e774
80108c0a:	e8 09 00 00 00       	call   80108c18 <i8254_init>
80108c0f:	83 c4 10             	add    $0x10,%esp
  }
}
80108c12:	90                   	nop
80108c13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c16:	c9                   	leave  
80108c17:	c3                   	ret    

80108c18 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108c18:	55                   	push   %ebp
80108c19:	89 e5                	mov    %esp,%ebp
80108c1b:	53                   	push   %ebx
80108c1c:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108c1f:	8b 45 08             	mov    0x8(%ebp),%eax
80108c22:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108c26:	0f b6 c8             	movzbl %al,%ecx
80108c29:	8b 45 08             	mov    0x8(%ebp),%eax
80108c2c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108c30:	0f b6 d0             	movzbl %al,%edx
80108c33:	8b 45 08             	mov    0x8(%ebp),%eax
80108c36:	0f b6 00             	movzbl (%eax),%eax
80108c39:	0f b6 c0             	movzbl %al,%eax
80108c3c:	83 ec 0c             	sub    $0xc,%esp
80108c3f:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108c42:	53                   	push   %ebx
80108c43:	6a 04                	push   $0x4
80108c45:	51                   	push   %ecx
80108c46:	52                   	push   %edx
80108c47:	50                   	push   %eax
80108c48:	e8 75 fd ff ff       	call   801089c2 <pci_access_config>
80108c4d:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108c50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c53:	83 c8 04             	or     $0x4,%eax
80108c56:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108c59:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80108c5f:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108c63:	0f b6 c8             	movzbl %al,%ecx
80108c66:	8b 45 08             	mov    0x8(%ebp),%eax
80108c69:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108c6d:	0f b6 d0             	movzbl %al,%edx
80108c70:	8b 45 08             	mov    0x8(%ebp),%eax
80108c73:	0f b6 00             	movzbl (%eax),%eax
80108c76:	0f b6 c0             	movzbl %al,%eax
80108c79:	83 ec 0c             	sub    $0xc,%esp
80108c7c:	53                   	push   %ebx
80108c7d:	6a 04                	push   $0x4
80108c7f:	51                   	push   %ecx
80108c80:	52                   	push   %edx
80108c81:	50                   	push   %eax
80108c82:	e8 90 fd ff ff       	call   80108a17 <pci_write_config_register>
80108c87:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80108c8d:	8b 40 10             	mov    0x10(%eax),%eax
80108c90:	05 00 00 00 40       	add    $0x40000000,%eax
80108c95:	a3 8c e7 30 80       	mov    %eax,0x8030e78c
  uint *ctrl = (uint *)base_addr;
80108c9a:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108c9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108ca2:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108ca7:	05 d8 00 00 00       	add    $0xd8,%eax
80108cac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cb2:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cbb:	8b 00                	mov    (%eax),%eax
80108cbd:	0d 00 00 00 04       	or     $0x4000000,%eax
80108cc2:	89 c2                	mov    %eax,%edx
80108cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cc7:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108cc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ccc:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cd5:	8b 00                	mov    (%eax),%eax
80108cd7:	83 c8 40             	or     $0x40,%eax
80108cda:	89 c2                	mov    %eax,%edx
80108cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cdf:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce4:	8b 10                	mov    (%eax),%edx
80108ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce9:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108ceb:	83 ec 0c             	sub    $0xc,%esp
80108cee:	68 f0 c7 10 80       	push   $0x8010c7f0
80108cf3:	e8 fc 76 ff ff       	call   801003f4 <cprintf>
80108cf8:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108cfb:	e8 88 9a ff ff       	call   80102788 <kalloc>
80108d00:	a3 98 e7 30 80       	mov    %eax,0x8030e798
  *intr_addr = 0;
80108d05:	a1 98 e7 30 80       	mov    0x8030e798,%eax
80108d0a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108d10:	a1 98 e7 30 80       	mov    0x8030e798,%eax
80108d15:	83 ec 08             	sub    $0x8,%esp
80108d18:	50                   	push   %eax
80108d19:	68 12 c8 10 80       	push   $0x8010c812
80108d1e:	e8 d1 76 ff ff       	call   801003f4 <cprintf>
80108d23:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108d26:	e8 50 00 00 00       	call   80108d7b <i8254_init_recv>
  i8254_init_send();
80108d2b:	e8 69 03 00 00       	call   80109099 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108d30:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108d37:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108d3a:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108d41:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108d44:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108d4b:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108d4e:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108d55:	0f b6 c0             	movzbl %al,%eax
80108d58:	83 ec 0c             	sub    $0xc,%esp
80108d5b:	53                   	push   %ebx
80108d5c:	51                   	push   %ecx
80108d5d:	52                   	push   %edx
80108d5e:	50                   	push   %eax
80108d5f:	68 20 c8 10 80       	push   $0x8010c820
80108d64:	e8 8b 76 ff ff       	call   801003f4 <cprintf>
80108d69:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d6f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108d75:	90                   	nop
80108d76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108d79:	c9                   	leave  
80108d7a:	c3                   	ret    

80108d7b <i8254_init_recv>:

void i8254_init_recv(){
80108d7b:	55                   	push   %ebp
80108d7c:	89 e5                	mov    %esp,%ebp
80108d7e:	57                   	push   %edi
80108d7f:	56                   	push   %esi
80108d80:	53                   	push   %ebx
80108d81:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108d84:	83 ec 0c             	sub    $0xc,%esp
80108d87:	6a 00                	push   $0x0
80108d89:	e8 e8 04 00 00       	call   80109276 <i8254_read_eeprom>
80108d8e:	83 c4 10             	add    $0x10,%esp
80108d91:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108d94:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108d97:	a2 90 e7 30 80       	mov    %al,0x8030e790
  mac_addr[1] = data_l>>8;
80108d9c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108d9f:	c1 e8 08             	shr    $0x8,%eax
80108da2:	a2 91 e7 30 80       	mov    %al,0x8030e791
  uint data_m = i8254_read_eeprom(0x1);
80108da7:	83 ec 0c             	sub    $0xc,%esp
80108daa:	6a 01                	push   $0x1
80108dac:	e8 c5 04 00 00       	call   80109276 <i8254_read_eeprom>
80108db1:	83 c4 10             	add    $0x10,%esp
80108db4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108db7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108dba:	a2 92 e7 30 80       	mov    %al,0x8030e792
  mac_addr[3] = data_m>>8;
80108dbf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108dc2:	c1 e8 08             	shr    $0x8,%eax
80108dc5:	a2 93 e7 30 80       	mov    %al,0x8030e793
  uint data_h = i8254_read_eeprom(0x2);
80108dca:	83 ec 0c             	sub    $0xc,%esp
80108dcd:	6a 02                	push   $0x2
80108dcf:	e8 a2 04 00 00       	call   80109276 <i8254_read_eeprom>
80108dd4:	83 c4 10             	add    $0x10,%esp
80108dd7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108dda:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ddd:	a2 94 e7 30 80       	mov    %al,0x8030e794
  mac_addr[5] = data_h>>8;
80108de2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108de5:	c1 e8 08             	shr    $0x8,%eax
80108de8:	a2 95 e7 30 80       	mov    %al,0x8030e795
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108ded:	0f b6 05 95 e7 30 80 	movzbl 0x8030e795,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108df4:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108df7:	0f b6 05 94 e7 30 80 	movzbl 0x8030e794,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108dfe:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108e01:	0f b6 05 93 e7 30 80 	movzbl 0x8030e793,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e08:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108e0b:	0f b6 05 92 e7 30 80 	movzbl 0x8030e792,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e12:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108e15:	0f b6 05 91 e7 30 80 	movzbl 0x8030e791,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e1c:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108e1f:	0f b6 05 90 e7 30 80 	movzbl 0x8030e790,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e26:	0f b6 c0             	movzbl %al,%eax
80108e29:	83 ec 04             	sub    $0x4,%esp
80108e2c:	57                   	push   %edi
80108e2d:	56                   	push   %esi
80108e2e:	53                   	push   %ebx
80108e2f:	51                   	push   %ecx
80108e30:	52                   	push   %edx
80108e31:	50                   	push   %eax
80108e32:	68 38 c8 10 80       	push   $0x8010c838
80108e37:	e8 b8 75 ff ff       	call   801003f4 <cprintf>
80108e3c:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108e3f:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108e44:	05 00 54 00 00       	add    $0x5400,%eax
80108e49:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108e4c:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108e51:	05 04 54 00 00       	add    $0x5404,%eax
80108e56:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108e59:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e5c:	c1 e0 10             	shl    $0x10,%eax
80108e5f:	0b 45 d8             	or     -0x28(%ebp),%eax
80108e62:	89 c2                	mov    %eax,%edx
80108e64:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108e67:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108e69:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e6c:	0d 00 00 00 80       	or     $0x80000000,%eax
80108e71:	89 c2                	mov    %eax,%edx
80108e73:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108e76:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108e78:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108e7d:	05 00 52 00 00       	add    $0x5200,%eax
80108e82:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108e85:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108e8c:	eb 19                	jmp    80108ea7 <i8254_init_recv+0x12c>
    mta[i] = 0;
80108e8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e91:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e98:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108e9b:	01 d0                	add    %edx,%eax
80108e9d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108ea3:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108ea7:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108eab:	7e e1                	jle    80108e8e <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108ead:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108eb2:	05 d0 00 00 00       	add    $0xd0,%eax
80108eb7:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108eba:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108ebd:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108ec3:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108ec8:	05 c8 00 00 00       	add    $0xc8,%eax
80108ecd:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108ed0:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108ed3:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108ed9:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108ede:	05 28 28 00 00       	add    $0x2828,%eax
80108ee3:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108ee6:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108ee9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108eef:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108ef4:	05 00 01 00 00       	add    $0x100,%eax
80108ef9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108efc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108eff:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108f05:	e8 7e 98 ff ff       	call   80102788 <kalloc>
80108f0a:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108f0d:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108f12:	05 00 28 00 00       	add    $0x2800,%eax
80108f17:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108f1a:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108f1f:	05 04 28 00 00       	add    $0x2804,%eax
80108f24:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108f27:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108f2c:	05 08 28 00 00       	add    $0x2808,%eax
80108f31:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108f34:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108f39:	05 10 28 00 00       	add    $0x2810,%eax
80108f3e:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108f41:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108f46:	05 18 28 00 00       	add    $0x2818,%eax
80108f4b:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108f4e:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108f51:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108f57:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108f5a:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108f5c:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108f5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108f65:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108f68:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108f6e:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108f71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108f77:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108f7a:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108f80:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108f83:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108f86:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108f8d:	eb 73                	jmp    80109002 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108f8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f92:	c1 e0 04             	shl    $0x4,%eax
80108f95:	89 c2                	mov    %eax,%edx
80108f97:	8b 45 98             	mov    -0x68(%ebp),%eax
80108f9a:	01 d0                	add    %edx,%eax
80108f9c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108fa3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fa6:	c1 e0 04             	shl    $0x4,%eax
80108fa9:	89 c2                	mov    %eax,%edx
80108fab:	8b 45 98             	mov    -0x68(%ebp),%eax
80108fae:	01 d0                	add    %edx,%eax
80108fb0:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108fb6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fb9:	c1 e0 04             	shl    $0x4,%eax
80108fbc:	89 c2                	mov    %eax,%edx
80108fbe:	8b 45 98             	mov    -0x68(%ebp),%eax
80108fc1:	01 d0                	add    %edx,%eax
80108fc3:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108fc9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fcc:	c1 e0 04             	shl    $0x4,%eax
80108fcf:	89 c2                	mov    %eax,%edx
80108fd1:	8b 45 98             	mov    -0x68(%ebp),%eax
80108fd4:	01 d0                	add    %edx,%eax
80108fd6:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108fda:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fdd:	c1 e0 04             	shl    $0x4,%eax
80108fe0:	89 c2                	mov    %eax,%edx
80108fe2:	8b 45 98             	mov    -0x68(%ebp),%eax
80108fe5:	01 d0                	add    %edx,%eax
80108fe7:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108feb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fee:	c1 e0 04             	shl    $0x4,%eax
80108ff1:	89 c2                	mov    %eax,%edx
80108ff3:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ff6:	01 d0                	add    %edx,%eax
80108ff8:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108ffe:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80109002:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80109009:	7e 84                	jle    80108f8f <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010900b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80109012:	eb 57                	jmp    8010906b <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80109014:	e8 6f 97 ff ff       	call   80102788 <kalloc>
80109019:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
8010901c:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80109020:	75 12                	jne    80109034 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80109022:	83 ec 0c             	sub    $0xc,%esp
80109025:	68 58 c8 10 80       	push   $0x8010c858
8010902a:	e8 c5 73 ff ff       	call   801003f4 <cprintf>
8010902f:	83 c4 10             	add    $0x10,%esp
      break;
80109032:	eb 3d                	jmp    80109071 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80109034:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109037:	c1 e0 04             	shl    $0x4,%eax
8010903a:	89 c2                	mov    %eax,%edx
8010903c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010903f:	01 d0                	add    %edx,%eax
80109041:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109044:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010904a:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010904c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010904f:	83 c0 01             	add    $0x1,%eax
80109052:	c1 e0 04             	shl    $0x4,%eax
80109055:	89 c2                	mov    %eax,%edx
80109057:	8b 45 98             	mov    -0x68(%ebp),%eax
8010905a:	01 d0                	add    %edx,%eax
8010905c:	8b 55 94             	mov    -0x6c(%ebp),%edx
8010905f:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109065:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109067:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
8010906b:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
8010906f:	7e a3                	jle    80109014 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80109071:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109074:	8b 00                	mov    (%eax),%eax
80109076:	83 c8 02             	or     $0x2,%eax
80109079:	89 c2                	mov    %eax,%edx
8010907b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010907e:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80109080:	83 ec 0c             	sub    $0xc,%esp
80109083:	68 78 c8 10 80       	push   $0x8010c878
80109088:	e8 67 73 ff ff       	call   801003f4 <cprintf>
8010908d:	83 c4 10             	add    $0x10,%esp
}
80109090:	90                   	nop
80109091:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109094:	5b                   	pop    %ebx
80109095:	5e                   	pop    %esi
80109096:	5f                   	pop    %edi
80109097:	5d                   	pop    %ebp
80109098:	c3                   	ret    

80109099 <i8254_init_send>:

void i8254_init_send(){
80109099:	55                   	push   %ebp
8010909a:	89 e5                	mov    %esp,%ebp
8010909c:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
8010909f:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
801090a4:	05 28 38 00 00       	add    $0x3828,%eax
801090a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801090ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090af:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801090b5:	e8 ce 96 ff ff       	call   80102788 <kalloc>
801090ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801090bd:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
801090c2:	05 00 38 00 00       	add    $0x3800,%eax
801090c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801090ca:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
801090cf:	05 04 38 00 00       	add    $0x3804,%eax
801090d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
801090d7:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
801090dc:	05 08 38 00 00       	add    $0x3808,%eax
801090e1:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
801090e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090e7:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801090ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801090f0:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
801090f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
801090fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801090fe:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80109104:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80109109:	05 10 38 00 00       	add    $0x3810,%eax
8010910e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109111:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80109116:	05 18 38 00 00       	add    $0x3818,%eax
8010911b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
8010911e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109121:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80109127:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010912a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80109130:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109133:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109136:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010913d:	e9 82 00 00 00       	jmp    801091c4 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80109142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109145:	c1 e0 04             	shl    $0x4,%eax
80109148:	89 c2                	mov    %eax,%edx
8010914a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010914d:	01 d0                	add    %edx,%eax
8010914f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80109156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109159:	c1 e0 04             	shl    $0x4,%eax
8010915c:	89 c2                	mov    %eax,%edx
8010915e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109161:	01 d0                	add    %edx,%eax
80109163:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80109169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010916c:	c1 e0 04             	shl    $0x4,%eax
8010916f:	89 c2                	mov    %eax,%edx
80109171:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109174:	01 d0                	add    %edx,%eax
80109176:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
8010917a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010917d:	c1 e0 04             	shl    $0x4,%eax
80109180:	89 c2                	mov    %eax,%edx
80109182:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109185:	01 d0                	add    %edx,%eax
80109187:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
8010918b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010918e:	c1 e0 04             	shl    $0x4,%eax
80109191:	89 c2                	mov    %eax,%edx
80109193:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109196:	01 d0                	add    %edx,%eax
80109198:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
8010919c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010919f:	c1 e0 04             	shl    $0x4,%eax
801091a2:	89 c2                	mov    %eax,%edx
801091a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091a7:	01 d0                	add    %edx,%eax
801091a9:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801091ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091b0:	c1 e0 04             	shl    $0x4,%eax
801091b3:	89 c2                	mov    %eax,%edx
801091b5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091b8:	01 d0                	add    %edx,%eax
801091ba:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801091c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801091c4:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801091cb:	0f 8e 71 ff ff ff    	jle    80109142 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801091d1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801091d8:	eb 57                	jmp    80109231 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
801091da:	e8 a9 95 ff ff       	call   80102788 <kalloc>
801091df:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
801091e2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
801091e6:	75 12                	jne    801091fa <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
801091e8:	83 ec 0c             	sub    $0xc,%esp
801091eb:	68 58 c8 10 80       	push   $0x8010c858
801091f0:	e8 ff 71 ff ff       	call   801003f4 <cprintf>
801091f5:	83 c4 10             	add    $0x10,%esp
      break;
801091f8:	eb 3d                	jmp    80109237 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
801091fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091fd:	c1 e0 04             	shl    $0x4,%eax
80109200:	89 c2                	mov    %eax,%edx
80109202:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109205:	01 d0                	add    %edx,%eax
80109207:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010920a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109210:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109212:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109215:	83 c0 01             	add    $0x1,%eax
80109218:	c1 e0 04             	shl    $0x4,%eax
8010921b:	89 c2                	mov    %eax,%edx
8010921d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109220:	01 d0                	add    %edx,%eax
80109222:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109225:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010922b:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010922d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109231:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80109235:	7e a3                	jle    801091da <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80109237:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
8010923c:	05 00 04 00 00       	add    $0x400,%eax
80109241:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80109244:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109247:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
8010924d:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80109252:	05 10 04 00 00       	add    $0x410,%eax
80109257:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
8010925a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010925d:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109263:	83 ec 0c             	sub    $0xc,%esp
80109266:	68 98 c8 10 80       	push   $0x8010c898
8010926b:	e8 84 71 ff ff       	call   801003f4 <cprintf>
80109270:	83 c4 10             	add    $0x10,%esp

}
80109273:	90                   	nop
80109274:	c9                   	leave  
80109275:	c3                   	ret    

80109276 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80109276:	55                   	push   %ebp
80109277:	89 e5                	mov    %esp,%ebp
80109279:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
8010927c:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80109281:	83 c0 14             	add    $0x14,%eax
80109284:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80109287:	8b 45 08             	mov    0x8(%ebp),%eax
8010928a:	c1 e0 08             	shl    $0x8,%eax
8010928d:	0f b7 c0             	movzwl %ax,%eax
80109290:	83 c8 01             	or     $0x1,%eax
80109293:	89 c2                	mov    %eax,%edx
80109295:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109298:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
8010929a:	83 ec 0c             	sub    $0xc,%esp
8010929d:	68 b8 c8 10 80       	push   $0x8010c8b8
801092a2:	e8 4d 71 ff ff       	call   801003f4 <cprintf>
801092a7:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801092aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ad:	8b 00                	mov    (%eax),%eax
801092af:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801092b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092b5:	83 e0 10             	and    $0x10,%eax
801092b8:	85 c0                	test   %eax,%eax
801092ba:	75 02                	jne    801092be <i8254_read_eeprom+0x48>
  while(1){
801092bc:	eb dc                	jmp    8010929a <i8254_read_eeprom+0x24>
      break;
801092be:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801092bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092c2:	8b 00                	mov    (%eax),%eax
801092c4:	c1 e8 10             	shr    $0x10,%eax
}
801092c7:	c9                   	leave  
801092c8:	c3                   	ret    

801092c9 <i8254_recv>:
void i8254_recv(){
801092c9:	55                   	push   %ebp
801092ca:	89 e5                	mov    %esp,%ebp
801092cc:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801092cf:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
801092d4:	05 10 28 00 00       	add    $0x2810,%eax
801092d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801092dc:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
801092e1:	05 18 28 00 00       	add    $0x2818,%eax
801092e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
801092e9:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
801092ee:	05 00 28 00 00       	add    $0x2800,%eax
801092f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
801092f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092f9:	8b 00                	mov    (%eax),%eax
801092fb:	05 00 00 00 80       	add    $0x80000000,%eax
80109300:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80109303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109306:	8b 10                	mov    (%eax),%edx
80109308:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010930b:	8b 08                	mov    (%eax),%ecx
8010930d:	89 d0                	mov    %edx,%eax
8010930f:	29 c8                	sub    %ecx,%eax
80109311:	25 ff 00 00 00       	and    $0xff,%eax
80109316:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109319:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010931d:	7e 37                	jle    80109356 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
8010931f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109322:	8b 00                	mov    (%eax),%eax
80109324:	c1 e0 04             	shl    $0x4,%eax
80109327:	89 c2                	mov    %eax,%edx
80109329:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010932c:	01 d0                	add    %edx,%eax
8010932e:	8b 00                	mov    (%eax),%eax
80109330:	05 00 00 00 80       	add    $0x80000000,%eax
80109335:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109338:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010933b:	8b 00                	mov    (%eax),%eax
8010933d:	83 c0 01             	add    $0x1,%eax
80109340:	0f b6 d0             	movzbl %al,%edx
80109343:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109346:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109348:	83 ec 0c             	sub    $0xc,%esp
8010934b:	ff 75 e0             	push   -0x20(%ebp)
8010934e:	e8 15 09 00 00       	call   80109c68 <eth_proc>
80109353:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109356:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109359:	8b 10                	mov    (%eax),%edx
8010935b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010935e:	8b 00                	mov    (%eax),%eax
80109360:	39 c2                	cmp    %eax,%edx
80109362:	75 9f                	jne    80109303 <i8254_recv+0x3a>
      (*rdt)--;
80109364:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109367:	8b 00                	mov    (%eax),%eax
80109369:	8d 50 ff             	lea    -0x1(%eax),%edx
8010936c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010936f:	89 10                	mov    %edx,(%eax)
  while(1){
80109371:	eb 90                	jmp    80109303 <i8254_recv+0x3a>

80109373 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80109373:	55                   	push   %ebp
80109374:	89 e5                	mov    %esp,%ebp
80109376:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109379:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
8010937e:	05 10 38 00 00       	add    $0x3810,%eax
80109383:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109386:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
8010938b:	05 18 38 00 00       	add    $0x3818,%eax
80109390:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109393:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80109398:	05 00 38 00 00       	add    $0x3800,%eax
8010939d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801093a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093a3:	8b 00                	mov    (%eax),%eax
801093a5:	05 00 00 00 80       	add    $0x80000000,%eax
801093aa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801093ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093b0:	8b 10                	mov    (%eax),%edx
801093b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093b5:	8b 08                	mov    (%eax),%ecx
801093b7:	89 d0                	mov    %edx,%eax
801093b9:	29 c8                	sub    %ecx,%eax
801093bb:	0f b6 d0             	movzbl %al,%edx
801093be:	b8 00 01 00 00       	mov    $0x100,%eax
801093c3:	29 d0                	sub    %edx,%eax
801093c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801093c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093cb:	8b 00                	mov    (%eax),%eax
801093cd:	25 ff 00 00 00       	and    $0xff,%eax
801093d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801093d5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801093d9:	0f 8e a8 00 00 00    	jle    80109487 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
801093df:	8b 45 08             	mov    0x8(%ebp),%eax
801093e2:	8b 55 e0             	mov    -0x20(%ebp),%edx
801093e5:	89 d1                	mov    %edx,%ecx
801093e7:	c1 e1 04             	shl    $0x4,%ecx
801093ea:	8b 55 e8             	mov    -0x18(%ebp),%edx
801093ed:	01 ca                	add    %ecx,%edx
801093ef:	8b 12                	mov    (%edx),%edx
801093f1:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801093f7:	83 ec 04             	sub    $0x4,%esp
801093fa:	ff 75 0c             	push   0xc(%ebp)
801093fd:	50                   	push   %eax
801093fe:	52                   	push   %edx
801093ff:	e8 b8 ba ff ff       	call   80104ebc <memmove>
80109404:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109407:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010940a:	c1 e0 04             	shl    $0x4,%eax
8010940d:	89 c2                	mov    %eax,%edx
8010940f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109412:	01 d0                	add    %edx,%eax
80109414:	8b 55 0c             	mov    0xc(%ebp),%edx
80109417:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
8010941b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010941e:	c1 e0 04             	shl    $0x4,%eax
80109421:	89 c2                	mov    %eax,%edx
80109423:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109426:	01 d0                	add    %edx,%eax
80109428:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
8010942c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010942f:	c1 e0 04             	shl    $0x4,%eax
80109432:	89 c2                	mov    %eax,%edx
80109434:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109437:	01 d0                	add    %edx,%eax
80109439:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
8010943d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109440:	c1 e0 04             	shl    $0x4,%eax
80109443:	89 c2                	mov    %eax,%edx
80109445:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109448:	01 d0                	add    %edx,%eax
8010944a:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
8010944e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109451:	c1 e0 04             	shl    $0x4,%eax
80109454:	89 c2                	mov    %eax,%edx
80109456:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109459:	01 d0                	add    %edx,%eax
8010945b:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109461:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109464:	c1 e0 04             	shl    $0x4,%eax
80109467:	89 c2                	mov    %eax,%edx
80109469:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010946c:	01 d0                	add    %edx,%eax
8010946e:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109472:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109475:	8b 00                	mov    (%eax),%eax
80109477:	83 c0 01             	add    $0x1,%eax
8010947a:	0f b6 d0             	movzbl %al,%edx
8010947d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109480:	89 10                	mov    %edx,(%eax)
    return len;
80109482:	8b 45 0c             	mov    0xc(%ebp),%eax
80109485:	eb 05                	jmp    8010948c <i8254_send+0x119>
  }else{
    return -1;
80109487:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010948c:	c9                   	leave  
8010948d:	c3                   	ret    

8010948e <i8254_intr>:

void i8254_intr(){
8010948e:	55                   	push   %ebp
8010948f:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109491:	a1 98 e7 30 80       	mov    0x8030e798,%eax
80109496:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
8010949c:	90                   	nop
8010949d:	5d                   	pop    %ebp
8010949e:	c3                   	ret    

8010949f <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
8010949f:	55                   	push   %ebp
801094a0:	89 e5                	mov    %esp,%ebp
801094a2:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801094a5:	8b 45 08             	mov    0x8(%ebp),%eax
801094a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801094ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ae:	0f b7 00             	movzwl (%eax),%eax
801094b1:	66 3d 00 01          	cmp    $0x100,%ax
801094b5:	74 0a                	je     801094c1 <arp_proc+0x22>
801094b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801094bc:	e9 4f 01 00 00       	jmp    80109610 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801094c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c4:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801094c8:	66 83 f8 08          	cmp    $0x8,%ax
801094cc:	74 0a                	je     801094d8 <arp_proc+0x39>
801094ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801094d3:	e9 38 01 00 00       	jmp    80109610 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
801094d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094db:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801094df:	3c 06                	cmp    $0x6,%al
801094e1:	74 0a                	je     801094ed <arp_proc+0x4e>
801094e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801094e8:	e9 23 01 00 00       	jmp    80109610 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
801094ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f0:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801094f4:	3c 04                	cmp    $0x4,%al
801094f6:	74 0a                	je     80109502 <arp_proc+0x63>
801094f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801094fd:	e9 0e 01 00 00       	jmp    80109610 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109502:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109505:	83 c0 18             	add    $0x18,%eax
80109508:	83 ec 04             	sub    $0x4,%esp
8010950b:	6a 04                	push   $0x4
8010950d:	50                   	push   %eax
8010950e:	68 04 f5 10 80       	push   $0x8010f504
80109513:	e8 4c b9 ff ff       	call   80104e64 <memcmp>
80109518:	83 c4 10             	add    $0x10,%esp
8010951b:	85 c0                	test   %eax,%eax
8010951d:	74 27                	je     80109546 <arp_proc+0xa7>
8010951f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109522:	83 c0 0e             	add    $0xe,%eax
80109525:	83 ec 04             	sub    $0x4,%esp
80109528:	6a 04                	push   $0x4
8010952a:	50                   	push   %eax
8010952b:	68 04 f5 10 80       	push   $0x8010f504
80109530:	e8 2f b9 ff ff       	call   80104e64 <memcmp>
80109535:	83 c4 10             	add    $0x10,%esp
80109538:	85 c0                	test   %eax,%eax
8010953a:	74 0a                	je     80109546 <arp_proc+0xa7>
8010953c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109541:	e9 ca 00 00 00       	jmp    80109610 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109546:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109549:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010954d:	66 3d 00 01          	cmp    $0x100,%ax
80109551:	75 69                	jne    801095bc <arp_proc+0x11d>
80109553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109556:	83 c0 18             	add    $0x18,%eax
80109559:	83 ec 04             	sub    $0x4,%esp
8010955c:	6a 04                	push   $0x4
8010955e:	50                   	push   %eax
8010955f:	68 04 f5 10 80       	push   $0x8010f504
80109564:	e8 fb b8 ff ff       	call   80104e64 <memcmp>
80109569:	83 c4 10             	add    $0x10,%esp
8010956c:	85 c0                	test   %eax,%eax
8010956e:	75 4c                	jne    801095bc <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109570:	e8 13 92 ff ff       	call   80102788 <kalloc>
80109575:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109578:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
8010957f:	83 ec 04             	sub    $0x4,%esp
80109582:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109585:	50                   	push   %eax
80109586:	ff 75 f0             	push   -0x10(%ebp)
80109589:	ff 75 f4             	push   -0xc(%ebp)
8010958c:	e8 1f 04 00 00       	call   801099b0 <arp_reply_pkt_create>
80109591:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109594:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109597:	83 ec 08             	sub    $0x8,%esp
8010959a:	50                   	push   %eax
8010959b:	ff 75 f0             	push   -0x10(%ebp)
8010959e:	e8 d0 fd ff ff       	call   80109373 <i8254_send>
801095a3:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801095a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095a9:	83 ec 0c             	sub    $0xc,%esp
801095ac:	50                   	push   %eax
801095ad:	e8 3c 91 ff ff       	call   801026ee <kfree>
801095b2:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801095b5:	b8 02 00 00 00       	mov    $0x2,%eax
801095ba:	eb 54                	jmp    80109610 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801095bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095bf:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801095c3:	66 3d 00 02          	cmp    $0x200,%ax
801095c7:	75 42                	jne    8010960b <arp_proc+0x16c>
801095c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095cc:	83 c0 18             	add    $0x18,%eax
801095cf:	83 ec 04             	sub    $0x4,%esp
801095d2:	6a 04                	push   $0x4
801095d4:	50                   	push   %eax
801095d5:	68 04 f5 10 80       	push   $0x8010f504
801095da:	e8 85 b8 ff ff       	call   80104e64 <memcmp>
801095df:	83 c4 10             	add    $0x10,%esp
801095e2:	85 c0                	test   %eax,%eax
801095e4:	75 25                	jne    8010960b <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
801095e6:	83 ec 0c             	sub    $0xc,%esp
801095e9:	68 bc c8 10 80       	push   $0x8010c8bc
801095ee:	e8 01 6e ff ff       	call   801003f4 <cprintf>
801095f3:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801095f6:	83 ec 0c             	sub    $0xc,%esp
801095f9:	ff 75 f4             	push   -0xc(%ebp)
801095fc:	e8 af 01 00 00       	call   801097b0 <arp_table_update>
80109601:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109604:	b8 01 00 00 00       	mov    $0x1,%eax
80109609:	eb 05                	jmp    80109610 <arp_proc+0x171>
  }else{
    return -1;
8010960b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109610:	c9                   	leave  
80109611:	c3                   	ret    

80109612 <arp_scan>:

void arp_scan(){
80109612:	55                   	push   %ebp
80109613:	89 e5                	mov    %esp,%ebp
80109615:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109618:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010961f:	eb 6f                	jmp    80109690 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109621:	e8 62 91 ff ff       	call   80102788 <kalloc>
80109626:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109629:	83 ec 04             	sub    $0x4,%esp
8010962c:	ff 75 f4             	push   -0xc(%ebp)
8010962f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109632:	50                   	push   %eax
80109633:	ff 75 ec             	push   -0x14(%ebp)
80109636:	e8 62 00 00 00       	call   8010969d <arp_broadcast>
8010963b:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
8010963e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109641:	83 ec 08             	sub    $0x8,%esp
80109644:	50                   	push   %eax
80109645:	ff 75 ec             	push   -0x14(%ebp)
80109648:	e8 26 fd ff ff       	call   80109373 <i8254_send>
8010964d:	83 c4 10             	add    $0x10,%esp
80109650:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109653:	eb 22                	jmp    80109677 <arp_scan+0x65>
      microdelay(1);
80109655:	83 ec 0c             	sub    $0xc,%esp
80109658:	6a 01                	push   $0x1
8010965a:	e8 c0 94 ff ff       	call   80102b1f <microdelay>
8010965f:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109662:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109665:	83 ec 08             	sub    $0x8,%esp
80109668:	50                   	push   %eax
80109669:	ff 75 ec             	push   -0x14(%ebp)
8010966c:	e8 02 fd ff ff       	call   80109373 <i8254_send>
80109671:	83 c4 10             	add    $0x10,%esp
80109674:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109677:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010967b:	74 d8                	je     80109655 <arp_scan+0x43>
    }
    kfree((char *)send);
8010967d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109680:	83 ec 0c             	sub    $0xc,%esp
80109683:	50                   	push   %eax
80109684:	e8 65 90 ff ff       	call   801026ee <kfree>
80109689:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
8010968c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109690:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109697:	7e 88                	jle    80109621 <arp_scan+0xf>
  }
}
80109699:	90                   	nop
8010969a:	90                   	nop
8010969b:	c9                   	leave  
8010969c:	c3                   	ret    

8010969d <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
8010969d:	55                   	push   %ebp
8010969e:	89 e5                	mov    %esp,%ebp
801096a0:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801096a3:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801096a7:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801096ab:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801096af:	8b 45 10             	mov    0x10(%ebp),%eax
801096b2:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801096b5:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801096bc:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801096c2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801096c9:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801096cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801096d2:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801096d8:	8b 45 08             	mov    0x8(%ebp),%eax
801096db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801096de:	8b 45 08             	mov    0x8(%ebp),%eax
801096e1:	83 c0 0e             	add    $0xe,%eax
801096e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801096e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ea:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801096ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096f1:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801096f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096f8:	83 ec 04             	sub    $0x4,%esp
801096fb:	6a 06                	push   $0x6
801096fd:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109700:	52                   	push   %edx
80109701:	50                   	push   %eax
80109702:	e8 b5 b7 ff ff       	call   80104ebc <memmove>
80109707:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010970a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010970d:	83 c0 06             	add    $0x6,%eax
80109710:	83 ec 04             	sub    $0x4,%esp
80109713:	6a 06                	push   $0x6
80109715:	68 90 e7 30 80       	push   $0x8030e790
8010971a:	50                   	push   %eax
8010971b:	e8 9c b7 ff ff       	call   80104ebc <memmove>
80109720:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109723:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109726:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010972b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010972e:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109734:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109737:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010973b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010973e:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109742:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109745:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
8010974b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010974e:	8d 50 12             	lea    0x12(%eax),%edx
80109751:	83 ec 04             	sub    $0x4,%esp
80109754:	6a 06                	push   $0x6
80109756:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109759:	50                   	push   %eax
8010975a:	52                   	push   %edx
8010975b:	e8 5c b7 ff ff       	call   80104ebc <memmove>
80109760:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109763:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109766:	8d 50 18             	lea    0x18(%eax),%edx
80109769:	83 ec 04             	sub    $0x4,%esp
8010976c:	6a 04                	push   $0x4
8010976e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109771:	50                   	push   %eax
80109772:	52                   	push   %edx
80109773:	e8 44 b7 ff ff       	call   80104ebc <memmove>
80109778:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010977b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010977e:	83 c0 08             	add    $0x8,%eax
80109781:	83 ec 04             	sub    $0x4,%esp
80109784:	6a 06                	push   $0x6
80109786:	68 90 e7 30 80       	push   $0x8030e790
8010978b:	50                   	push   %eax
8010978c:	e8 2b b7 ff ff       	call   80104ebc <memmove>
80109791:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109794:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109797:	83 c0 0e             	add    $0xe,%eax
8010979a:	83 ec 04             	sub    $0x4,%esp
8010979d:	6a 04                	push   $0x4
8010979f:	68 04 f5 10 80       	push   $0x8010f504
801097a4:	50                   	push   %eax
801097a5:	e8 12 b7 ff ff       	call   80104ebc <memmove>
801097aa:	83 c4 10             	add    $0x10,%esp
}
801097ad:	90                   	nop
801097ae:	c9                   	leave  
801097af:	c3                   	ret    

801097b0 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801097b0:	55                   	push   %ebp
801097b1:	89 e5                	mov    %esp,%ebp
801097b3:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801097b6:	8b 45 08             	mov    0x8(%ebp),%eax
801097b9:	83 c0 0e             	add    $0xe,%eax
801097bc:	83 ec 0c             	sub    $0xc,%esp
801097bf:	50                   	push   %eax
801097c0:	e8 bc 00 00 00       	call   80109881 <arp_table_search>
801097c5:	83 c4 10             	add    $0x10,%esp
801097c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801097cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801097cf:	78 2d                	js     801097fe <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801097d1:	8b 45 08             	mov    0x8(%ebp),%eax
801097d4:	8d 48 08             	lea    0x8(%eax),%ecx
801097d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097da:	89 d0                	mov    %edx,%eax
801097dc:	c1 e0 02             	shl    $0x2,%eax
801097df:	01 d0                	add    %edx,%eax
801097e1:	01 c0                	add    %eax,%eax
801097e3:	01 d0                	add    %edx,%eax
801097e5:	05 a0 e7 30 80       	add    $0x8030e7a0,%eax
801097ea:	83 c0 04             	add    $0x4,%eax
801097ed:	83 ec 04             	sub    $0x4,%esp
801097f0:	6a 06                	push   $0x6
801097f2:	51                   	push   %ecx
801097f3:	50                   	push   %eax
801097f4:	e8 c3 b6 ff ff       	call   80104ebc <memmove>
801097f9:	83 c4 10             	add    $0x10,%esp
801097fc:	eb 70                	jmp    8010986e <arp_table_update+0xbe>
  }else{
    index += 1;
801097fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109802:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109805:	8b 45 08             	mov    0x8(%ebp),%eax
80109808:	8d 48 08             	lea    0x8(%eax),%ecx
8010980b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010980e:	89 d0                	mov    %edx,%eax
80109810:	c1 e0 02             	shl    $0x2,%eax
80109813:	01 d0                	add    %edx,%eax
80109815:	01 c0                	add    %eax,%eax
80109817:	01 d0                	add    %edx,%eax
80109819:	05 a0 e7 30 80       	add    $0x8030e7a0,%eax
8010981e:	83 c0 04             	add    $0x4,%eax
80109821:	83 ec 04             	sub    $0x4,%esp
80109824:	6a 06                	push   $0x6
80109826:	51                   	push   %ecx
80109827:	50                   	push   %eax
80109828:	e8 8f b6 ff ff       	call   80104ebc <memmove>
8010982d:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109830:	8b 45 08             	mov    0x8(%ebp),%eax
80109833:	8d 48 0e             	lea    0xe(%eax),%ecx
80109836:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109839:	89 d0                	mov    %edx,%eax
8010983b:	c1 e0 02             	shl    $0x2,%eax
8010983e:	01 d0                	add    %edx,%eax
80109840:	01 c0                	add    %eax,%eax
80109842:	01 d0                	add    %edx,%eax
80109844:	05 a0 e7 30 80       	add    $0x8030e7a0,%eax
80109849:	83 ec 04             	sub    $0x4,%esp
8010984c:	6a 04                	push   $0x4
8010984e:	51                   	push   %ecx
8010984f:	50                   	push   %eax
80109850:	e8 67 b6 ff ff       	call   80104ebc <memmove>
80109855:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109858:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010985b:	89 d0                	mov    %edx,%eax
8010985d:	c1 e0 02             	shl    $0x2,%eax
80109860:	01 d0                	add    %edx,%eax
80109862:	01 c0                	add    %eax,%eax
80109864:	01 d0                	add    %edx,%eax
80109866:	05 aa e7 30 80       	add    $0x8030e7aa,%eax
8010986b:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
8010986e:	83 ec 0c             	sub    $0xc,%esp
80109871:	68 a0 e7 30 80       	push   $0x8030e7a0
80109876:	e8 83 00 00 00       	call   801098fe <print_arp_table>
8010987b:	83 c4 10             	add    $0x10,%esp
}
8010987e:	90                   	nop
8010987f:	c9                   	leave  
80109880:	c3                   	ret    

80109881 <arp_table_search>:

int arp_table_search(uchar *ip){
80109881:	55                   	push   %ebp
80109882:	89 e5                	mov    %esp,%ebp
80109884:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109887:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010988e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109895:	eb 59                	jmp    801098f0 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109897:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010989a:	89 d0                	mov    %edx,%eax
8010989c:	c1 e0 02             	shl    $0x2,%eax
8010989f:	01 d0                	add    %edx,%eax
801098a1:	01 c0                	add    %eax,%eax
801098a3:	01 d0                	add    %edx,%eax
801098a5:	05 a0 e7 30 80       	add    $0x8030e7a0,%eax
801098aa:	83 ec 04             	sub    $0x4,%esp
801098ad:	6a 04                	push   $0x4
801098af:	ff 75 08             	push   0x8(%ebp)
801098b2:	50                   	push   %eax
801098b3:	e8 ac b5 ff ff       	call   80104e64 <memcmp>
801098b8:	83 c4 10             	add    $0x10,%esp
801098bb:	85 c0                	test   %eax,%eax
801098bd:	75 05                	jne    801098c4 <arp_table_search+0x43>
      return i;
801098bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098c2:	eb 38                	jmp    801098fc <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801098c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801098c7:	89 d0                	mov    %edx,%eax
801098c9:	c1 e0 02             	shl    $0x2,%eax
801098cc:	01 d0                	add    %edx,%eax
801098ce:	01 c0                	add    %eax,%eax
801098d0:	01 d0                	add    %edx,%eax
801098d2:	05 aa e7 30 80       	add    $0x8030e7aa,%eax
801098d7:	0f b6 00             	movzbl (%eax),%eax
801098da:	84 c0                	test   %al,%al
801098dc:	75 0e                	jne    801098ec <arp_table_search+0x6b>
801098de:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801098e2:	75 08                	jne    801098ec <arp_table_search+0x6b>
      empty = -i;
801098e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098e7:	f7 d8                	neg    %eax
801098e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801098ec:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801098f0:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801098f4:	7e a1                	jle    80109897 <arp_table_search+0x16>
    }
  }
  return empty-1;
801098f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098f9:	83 e8 01             	sub    $0x1,%eax
}
801098fc:	c9                   	leave  
801098fd:	c3                   	ret    

801098fe <print_arp_table>:

void print_arp_table(){
801098fe:	55                   	push   %ebp
801098ff:	89 e5                	mov    %esp,%ebp
80109901:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109904:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010990b:	e9 92 00 00 00       	jmp    801099a2 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109910:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109913:	89 d0                	mov    %edx,%eax
80109915:	c1 e0 02             	shl    $0x2,%eax
80109918:	01 d0                	add    %edx,%eax
8010991a:	01 c0                	add    %eax,%eax
8010991c:	01 d0                	add    %edx,%eax
8010991e:	05 aa e7 30 80       	add    $0x8030e7aa,%eax
80109923:	0f b6 00             	movzbl (%eax),%eax
80109926:	84 c0                	test   %al,%al
80109928:	74 74                	je     8010999e <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
8010992a:	83 ec 08             	sub    $0x8,%esp
8010992d:	ff 75 f4             	push   -0xc(%ebp)
80109930:	68 cf c8 10 80       	push   $0x8010c8cf
80109935:	e8 ba 6a ff ff       	call   801003f4 <cprintf>
8010993a:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010993d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109940:	89 d0                	mov    %edx,%eax
80109942:	c1 e0 02             	shl    $0x2,%eax
80109945:	01 d0                	add    %edx,%eax
80109947:	01 c0                	add    %eax,%eax
80109949:	01 d0                	add    %edx,%eax
8010994b:	05 a0 e7 30 80       	add    $0x8030e7a0,%eax
80109950:	83 ec 0c             	sub    $0xc,%esp
80109953:	50                   	push   %eax
80109954:	e8 54 02 00 00       	call   80109bad <print_ipv4>
80109959:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
8010995c:	83 ec 0c             	sub    $0xc,%esp
8010995f:	68 de c8 10 80       	push   $0x8010c8de
80109964:	e8 8b 6a ff ff       	call   801003f4 <cprintf>
80109969:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
8010996c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010996f:	89 d0                	mov    %edx,%eax
80109971:	c1 e0 02             	shl    $0x2,%eax
80109974:	01 d0                	add    %edx,%eax
80109976:	01 c0                	add    %eax,%eax
80109978:	01 d0                	add    %edx,%eax
8010997a:	05 a0 e7 30 80       	add    $0x8030e7a0,%eax
8010997f:	83 c0 04             	add    $0x4,%eax
80109982:	83 ec 0c             	sub    $0xc,%esp
80109985:	50                   	push   %eax
80109986:	e8 70 02 00 00       	call   80109bfb <print_mac>
8010998b:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
8010998e:	83 ec 0c             	sub    $0xc,%esp
80109991:	68 e0 c8 10 80       	push   $0x8010c8e0
80109996:	e8 59 6a ff ff       	call   801003f4 <cprintf>
8010999b:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010999e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801099a2:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801099a6:	0f 8e 64 ff ff ff    	jle    80109910 <print_arp_table+0x12>
    }
  }
}
801099ac:	90                   	nop
801099ad:	90                   	nop
801099ae:	c9                   	leave  
801099af:	c3                   	ret    

801099b0 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801099b0:	55                   	push   %ebp
801099b1:	89 e5                	mov    %esp,%ebp
801099b3:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801099b6:	8b 45 10             	mov    0x10(%ebp),%eax
801099b9:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801099bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801099c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801099c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801099c8:	83 c0 0e             	add    $0xe,%eax
801099cb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801099ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d1:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801099d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d8:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801099dc:	8b 45 08             	mov    0x8(%ebp),%eax
801099df:	8d 50 08             	lea    0x8(%eax),%edx
801099e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099e5:	83 ec 04             	sub    $0x4,%esp
801099e8:	6a 06                	push   $0x6
801099ea:	52                   	push   %edx
801099eb:	50                   	push   %eax
801099ec:	e8 cb b4 ff ff       	call   80104ebc <memmove>
801099f1:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801099f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099f7:	83 c0 06             	add    $0x6,%eax
801099fa:	83 ec 04             	sub    $0x4,%esp
801099fd:	6a 06                	push   $0x6
801099ff:	68 90 e7 30 80       	push   $0x8030e790
80109a04:	50                   	push   %eax
80109a05:	e8 b2 b4 ff ff       	call   80104ebc <memmove>
80109a0a:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a10:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a18:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a21:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a28:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a2f:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109a35:	8b 45 08             	mov    0x8(%ebp),%eax
80109a38:	8d 50 08             	lea    0x8(%eax),%edx
80109a3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a3e:	83 c0 12             	add    $0x12,%eax
80109a41:	83 ec 04             	sub    $0x4,%esp
80109a44:	6a 06                	push   $0x6
80109a46:	52                   	push   %edx
80109a47:	50                   	push   %eax
80109a48:	e8 6f b4 ff ff       	call   80104ebc <memmove>
80109a4d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109a50:	8b 45 08             	mov    0x8(%ebp),%eax
80109a53:	8d 50 0e             	lea    0xe(%eax),%edx
80109a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a59:	83 c0 18             	add    $0x18,%eax
80109a5c:	83 ec 04             	sub    $0x4,%esp
80109a5f:	6a 04                	push   $0x4
80109a61:	52                   	push   %edx
80109a62:	50                   	push   %eax
80109a63:	e8 54 b4 ff ff       	call   80104ebc <memmove>
80109a68:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a6e:	83 c0 08             	add    $0x8,%eax
80109a71:	83 ec 04             	sub    $0x4,%esp
80109a74:	6a 06                	push   $0x6
80109a76:	68 90 e7 30 80       	push   $0x8030e790
80109a7b:	50                   	push   %eax
80109a7c:	e8 3b b4 ff ff       	call   80104ebc <memmove>
80109a81:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a87:	83 c0 0e             	add    $0xe,%eax
80109a8a:	83 ec 04             	sub    $0x4,%esp
80109a8d:	6a 04                	push   $0x4
80109a8f:	68 04 f5 10 80       	push   $0x8010f504
80109a94:	50                   	push   %eax
80109a95:	e8 22 b4 ff ff       	call   80104ebc <memmove>
80109a9a:	83 c4 10             	add    $0x10,%esp
}
80109a9d:	90                   	nop
80109a9e:	c9                   	leave  
80109a9f:	c3                   	ret    

80109aa0 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109aa0:	55                   	push   %ebp
80109aa1:	89 e5                	mov    %esp,%ebp
80109aa3:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109aa6:	83 ec 0c             	sub    $0xc,%esp
80109aa9:	68 e2 c8 10 80       	push   $0x8010c8e2
80109aae:	e8 41 69 ff ff       	call   801003f4 <cprintf>
80109ab3:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109ab6:	8b 45 08             	mov    0x8(%ebp),%eax
80109ab9:	83 c0 0e             	add    $0xe,%eax
80109abc:	83 ec 0c             	sub    $0xc,%esp
80109abf:	50                   	push   %eax
80109ac0:	e8 e8 00 00 00       	call   80109bad <print_ipv4>
80109ac5:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109ac8:	83 ec 0c             	sub    $0xc,%esp
80109acb:	68 e0 c8 10 80       	push   $0x8010c8e0
80109ad0:	e8 1f 69 ff ff       	call   801003f4 <cprintf>
80109ad5:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80109adb:	83 c0 08             	add    $0x8,%eax
80109ade:	83 ec 0c             	sub    $0xc,%esp
80109ae1:	50                   	push   %eax
80109ae2:	e8 14 01 00 00       	call   80109bfb <print_mac>
80109ae7:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109aea:	83 ec 0c             	sub    $0xc,%esp
80109aed:	68 e0 c8 10 80       	push   $0x8010c8e0
80109af2:	e8 fd 68 ff ff       	call   801003f4 <cprintf>
80109af7:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109afa:	83 ec 0c             	sub    $0xc,%esp
80109afd:	68 f9 c8 10 80       	push   $0x8010c8f9
80109b02:	e8 ed 68 ff ff       	call   801003f4 <cprintf>
80109b07:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80109b0d:	83 c0 18             	add    $0x18,%eax
80109b10:	83 ec 0c             	sub    $0xc,%esp
80109b13:	50                   	push   %eax
80109b14:	e8 94 00 00 00       	call   80109bad <print_ipv4>
80109b19:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b1c:	83 ec 0c             	sub    $0xc,%esp
80109b1f:	68 e0 c8 10 80       	push   $0x8010c8e0
80109b24:	e8 cb 68 ff ff       	call   801003f4 <cprintf>
80109b29:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80109b2f:	83 c0 12             	add    $0x12,%eax
80109b32:	83 ec 0c             	sub    $0xc,%esp
80109b35:	50                   	push   %eax
80109b36:	e8 c0 00 00 00       	call   80109bfb <print_mac>
80109b3b:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b3e:	83 ec 0c             	sub    $0xc,%esp
80109b41:	68 e0 c8 10 80       	push   $0x8010c8e0
80109b46:	e8 a9 68 ff ff       	call   801003f4 <cprintf>
80109b4b:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109b4e:	83 ec 0c             	sub    $0xc,%esp
80109b51:	68 10 c9 10 80       	push   $0x8010c910
80109b56:	e8 99 68 ff ff       	call   801003f4 <cprintf>
80109b5b:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109b5e:	8b 45 08             	mov    0x8(%ebp),%eax
80109b61:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109b65:	66 3d 00 01          	cmp    $0x100,%ax
80109b69:	75 12                	jne    80109b7d <print_arp_info+0xdd>
80109b6b:	83 ec 0c             	sub    $0xc,%esp
80109b6e:	68 1c c9 10 80       	push   $0x8010c91c
80109b73:	e8 7c 68 ff ff       	call   801003f4 <cprintf>
80109b78:	83 c4 10             	add    $0x10,%esp
80109b7b:	eb 1d                	jmp    80109b9a <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109b7d:	8b 45 08             	mov    0x8(%ebp),%eax
80109b80:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109b84:	66 3d 00 02          	cmp    $0x200,%ax
80109b88:	75 10                	jne    80109b9a <print_arp_info+0xfa>
    cprintf("Reply\n");
80109b8a:	83 ec 0c             	sub    $0xc,%esp
80109b8d:	68 25 c9 10 80       	push   $0x8010c925
80109b92:	e8 5d 68 ff ff       	call   801003f4 <cprintf>
80109b97:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109b9a:	83 ec 0c             	sub    $0xc,%esp
80109b9d:	68 e0 c8 10 80       	push   $0x8010c8e0
80109ba2:	e8 4d 68 ff ff       	call   801003f4 <cprintf>
80109ba7:	83 c4 10             	add    $0x10,%esp
}
80109baa:	90                   	nop
80109bab:	c9                   	leave  
80109bac:	c3                   	ret    

80109bad <print_ipv4>:

void print_ipv4(uchar *ip){
80109bad:	55                   	push   %ebp
80109bae:	89 e5                	mov    %esp,%ebp
80109bb0:	53                   	push   %ebx
80109bb1:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80109bb7:	83 c0 03             	add    $0x3,%eax
80109bba:	0f b6 00             	movzbl (%eax),%eax
80109bbd:	0f b6 d8             	movzbl %al,%ebx
80109bc0:	8b 45 08             	mov    0x8(%ebp),%eax
80109bc3:	83 c0 02             	add    $0x2,%eax
80109bc6:	0f b6 00             	movzbl (%eax),%eax
80109bc9:	0f b6 c8             	movzbl %al,%ecx
80109bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80109bcf:	83 c0 01             	add    $0x1,%eax
80109bd2:	0f b6 00             	movzbl (%eax),%eax
80109bd5:	0f b6 d0             	movzbl %al,%edx
80109bd8:	8b 45 08             	mov    0x8(%ebp),%eax
80109bdb:	0f b6 00             	movzbl (%eax),%eax
80109bde:	0f b6 c0             	movzbl %al,%eax
80109be1:	83 ec 0c             	sub    $0xc,%esp
80109be4:	53                   	push   %ebx
80109be5:	51                   	push   %ecx
80109be6:	52                   	push   %edx
80109be7:	50                   	push   %eax
80109be8:	68 2c c9 10 80       	push   $0x8010c92c
80109bed:	e8 02 68 ff ff       	call   801003f4 <cprintf>
80109bf2:	83 c4 20             	add    $0x20,%esp
}
80109bf5:	90                   	nop
80109bf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109bf9:	c9                   	leave  
80109bfa:	c3                   	ret    

80109bfb <print_mac>:

void print_mac(uchar *mac){
80109bfb:	55                   	push   %ebp
80109bfc:	89 e5                	mov    %esp,%ebp
80109bfe:	57                   	push   %edi
80109bff:	56                   	push   %esi
80109c00:	53                   	push   %ebx
80109c01:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109c04:	8b 45 08             	mov    0x8(%ebp),%eax
80109c07:	83 c0 05             	add    $0x5,%eax
80109c0a:	0f b6 00             	movzbl (%eax),%eax
80109c0d:	0f b6 f8             	movzbl %al,%edi
80109c10:	8b 45 08             	mov    0x8(%ebp),%eax
80109c13:	83 c0 04             	add    $0x4,%eax
80109c16:	0f b6 00             	movzbl (%eax),%eax
80109c19:	0f b6 f0             	movzbl %al,%esi
80109c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80109c1f:	83 c0 03             	add    $0x3,%eax
80109c22:	0f b6 00             	movzbl (%eax),%eax
80109c25:	0f b6 d8             	movzbl %al,%ebx
80109c28:	8b 45 08             	mov    0x8(%ebp),%eax
80109c2b:	83 c0 02             	add    $0x2,%eax
80109c2e:	0f b6 00             	movzbl (%eax),%eax
80109c31:	0f b6 c8             	movzbl %al,%ecx
80109c34:	8b 45 08             	mov    0x8(%ebp),%eax
80109c37:	83 c0 01             	add    $0x1,%eax
80109c3a:	0f b6 00             	movzbl (%eax),%eax
80109c3d:	0f b6 d0             	movzbl %al,%edx
80109c40:	8b 45 08             	mov    0x8(%ebp),%eax
80109c43:	0f b6 00             	movzbl (%eax),%eax
80109c46:	0f b6 c0             	movzbl %al,%eax
80109c49:	83 ec 04             	sub    $0x4,%esp
80109c4c:	57                   	push   %edi
80109c4d:	56                   	push   %esi
80109c4e:	53                   	push   %ebx
80109c4f:	51                   	push   %ecx
80109c50:	52                   	push   %edx
80109c51:	50                   	push   %eax
80109c52:	68 44 c9 10 80       	push   $0x8010c944
80109c57:	e8 98 67 ff ff       	call   801003f4 <cprintf>
80109c5c:	83 c4 20             	add    $0x20,%esp
}
80109c5f:	90                   	nop
80109c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109c63:	5b                   	pop    %ebx
80109c64:	5e                   	pop    %esi
80109c65:	5f                   	pop    %edi
80109c66:	5d                   	pop    %ebp
80109c67:	c3                   	ret    

80109c68 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109c68:	55                   	push   %ebp
80109c69:	89 e5                	mov    %esp,%ebp
80109c6b:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80109c71:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109c74:	8b 45 08             	mov    0x8(%ebp),%eax
80109c77:	83 c0 0e             	add    $0xe,%eax
80109c7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c80:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109c84:	3c 08                	cmp    $0x8,%al
80109c86:	75 1b                	jne    80109ca3 <eth_proc+0x3b>
80109c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c8b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109c8f:	3c 06                	cmp    $0x6,%al
80109c91:	75 10                	jne    80109ca3 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109c93:	83 ec 0c             	sub    $0xc,%esp
80109c96:	ff 75 f0             	push   -0x10(%ebp)
80109c99:	e8 01 f8 ff ff       	call   8010949f <arp_proc>
80109c9e:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109ca1:	eb 24                	jmp    80109cc7 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ca6:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109caa:	3c 08                	cmp    $0x8,%al
80109cac:	75 19                	jne    80109cc7 <eth_proc+0x5f>
80109cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cb1:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109cb5:	84 c0                	test   %al,%al
80109cb7:	75 0e                	jne    80109cc7 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109cb9:	83 ec 0c             	sub    $0xc,%esp
80109cbc:	ff 75 08             	push   0x8(%ebp)
80109cbf:	e8 a3 00 00 00       	call   80109d67 <ipv4_proc>
80109cc4:	83 c4 10             	add    $0x10,%esp
}
80109cc7:	90                   	nop
80109cc8:	c9                   	leave  
80109cc9:	c3                   	ret    

80109cca <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109cca:	55                   	push   %ebp
80109ccb:	89 e5                	mov    %esp,%ebp
80109ccd:	83 ec 04             	sub    $0x4,%esp
80109cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80109cd3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109cd7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109cdb:	c1 e0 08             	shl    $0x8,%eax
80109cde:	89 c2                	mov    %eax,%edx
80109ce0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109ce4:	66 c1 e8 08          	shr    $0x8,%ax
80109ce8:	01 d0                	add    %edx,%eax
}
80109cea:	c9                   	leave  
80109ceb:	c3                   	ret    

80109cec <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109cec:	55                   	push   %ebp
80109ced:	89 e5                	mov    %esp,%ebp
80109cef:	83 ec 04             	sub    $0x4,%esp
80109cf2:	8b 45 08             	mov    0x8(%ebp),%eax
80109cf5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109cf9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109cfd:	c1 e0 08             	shl    $0x8,%eax
80109d00:	89 c2                	mov    %eax,%edx
80109d02:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d06:	66 c1 e8 08          	shr    $0x8,%ax
80109d0a:	01 d0                	add    %edx,%eax
}
80109d0c:	c9                   	leave  
80109d0d:	c3                   	ret    

80109d0e <H2N_uint>:

uint H2N_uint(uint value){
80109d0e:	55                   	push   %ebp
80109d0f:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109d11:	8b 45 08             	mov    0x8(%ebp),%eax
80109d14:	c1 e0 18             	shl    $0x18,%eax
80109d17:	25 00 00 00 0f       	and    $0xf000000,%eax
80109d1c:	89 c2                	mov    %eax,%edx
80109d1e:	8b 45 08             	mov    0x8(%ebp),%eax
80109d21:	c1 e0 08             	shl    $0x8,%eax
80109d24:	25 00 f0 00 00       	and    $0xf000,%eax
80109d29:	09 c2                	or     %eax,%edx
80109d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80109d2e:	c1 e8 08             	shr    $0x8,%eax
80109d31:	83 e0 0f             	and    $0xf,%eax
80109d34:	01 d0                	add    %edx,%eax
}
80109d36:	5d                   	pop    %ebp
80109d37:	c3                   	ret    

80109d38 <N2H_uint>:

uint N2H_uint(uint value){
80109d38:	55                   	push   %ebp
80109d39:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80109d3e:	c1 e0 18             	shl    $0x18,%eax
80109d41:	89 c2                	mov    %eax,%edx
80109d43:	8b 45 08             	mov    0x8(%ebp),%eax
80109d46:	c1 e0 08             	shl    $0x8,%eax
80109d49:	25 00 00 ff 00       	and    $0xff0000,%eax
80109d4e:	01 c2                	add    %eax,%edx
80109d50:	8b 45 08             	mov    0x8(%ebp),%eax
80109d53:	c1 e8 08             	shr    $0x8,%eax
80109d56:	25 00 ff 00 00       	and    $0xff00,%eax
80109d5b:	01 c2                	add    %eax,%edx
80109d5d:	8b 45 08             	mov    0x8(%ebp),%eax
80109d60:	c1 e8 18             	shr    $0x18,%eax
80109d63:	01 d0                	add    %edx,%eax
}
80109d65:	5d                   	pop    %ebp
80109d66:	c3                   	ret    

80109d67 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109d67:	55                   	push   %ebp
80109d68:	89 e5                	mov    %esp,%ebp
80109d6a:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109d6d:	8b 45 08             	mov    0x8(%ebp),%eax
80109d70:	83 c0 0e             	add    $0xe,%eax
80109d73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d79:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109d7d:	0f b7 d0             	movzwl %ax,%edx
80109d80:	a1 08 f5 10 80       	mov    0x8010f508,%eax
80109d85:	39 c2                	cmp    %eax,%edx
80109d87:	74 60                	je     80109de9 <ipv4_proc+0x82>
80109d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d8c:	83 c0 0c             	add    $0xc,%eax
80109d8f:	83 ec 04             	sub    $0x4,%esp
80109d92:	6a 04                	push   $0x4
80109d94:	50                   	push   %eax
80109d95:	68 04 f5 10 80       	push   $0x8010f504
80109d9a:	e8 c5 b0 ff ff       	call   80104e64 <memcmp>
80109d9f:	83 c4 10             	add    $0x10,%esp
80109da2:	85 c0                	test   %eax,%eax
80109da4:	74 43                	je     80109de9 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109da9:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109dad:	0f b7 c0             	movzwl %ax,%eax
80109db0:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109db8:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109dbc:	3c 01                	cmp    $0x1,%al
80109dbe:	75 10                	jne    80109dd0 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109dc0:	83 ec 0c             	sub    $0xc,%esp
80109dc3:	ff 75 08             	push   0x8(%ebp)
80109dc6:	e8 a3 00 00 00       	call   80109e6e <icmp_proc>
80109dcb:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109dce:	eb 19                	jmp    80109de9 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dd3:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109dd7:	3c 06                	cmp    $0x6,%al
80109dd9:	75 0e                	jne    80109de9 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109ddb:	83 ec 0c             	sub    $0xc,%esp
80109dde:	ff 75 08             	push   0x8(%ebp)
80109de1:	e8 b3 03 00 00       	call   8010a199 <tcp_proc>
80109de6:	83 c4 10             	add    $0x10,%esp
}
80109de9:	90                   	nop
80109dea:	c9                   	leave  
80109deb:	c3                   	ret    

80109dec <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109dec:	55                   	push   %ebp
80109ded:	89 e5                	mov    %esp,%ebp
80109def:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109df2:	8b 45 08             	mov    0x8(%ebp),%eax
80109df5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dfb:	0f b6 00             	movzbl (%eax),%eax
80109dfe:	83 e0 0f             	and    $0xf,%eax
80109e01:	01 c0                	add    %eax,%eax
80109e03:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109e06:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109e0d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109e14:	eb 48                	jmp    80109e5e <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e16:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e19:	01 c0                	add    %eax,%eax
80109e1b:	89 c2                	mov    %eax,%edx
80109e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e20:	01 d0                	add    %edx,%eax
80109e22:	0f b6 00             	movzbl (%eax),%eax
80109e25:	0f b6 c0             	movzbl %al,%eax
80109e28:	c1 e0 08             	shl    $0x8,%eax
80109e2b:	89 c2                	mov    %eax,%edx
80109e2d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e30:	01 c0                	add    %eax,%eax
80109e32:	8d 48 01             	lea    0x1(%eax),%ecx
80109e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e38:	01 c8                	add    %ecx,%eax
80109e3a:	0f b6 00             	movzbl (%eax),%eax
80109e3d:	0f b6 c0             	movzbl %al,%eax
80109e40:	01 d0                	add    %edx,%eax
80109e42:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109e45:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109e4c:	76 0c                	jbe    80109e5a <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109e4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109e51:	0f b7 c0             	movzwl %ax,%eax
80109e54:	83 c0 01             	add    $0x1,%eax
80109e57:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109e5a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109e5e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109e62:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109e65:	7c af                	jl     80109e16 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109e67:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109e6a:	f7 d0                	not    %eax
}
80109e6c:	c9                   	leave  
80109e6d:	c3                   	ret    

80109e6e <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109e6e:	55                   	push   %ebp
80109e6f:	89 e5                	mov    %esp,%ebp
80109e71:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109e74:	8b 45 08             	mov    0x8(%ebp),%eax
80109e77:	83 c0 0e             	add    $0xe,%eax
80109e7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e80:	0f b6 00             	movzbl (%eax),%eax
80109e83:	0f b6 c0             	movzbl %al,%eax
80109e86:	83 e0 0f             	and    $0xf,%eax
80109e89:	c1 e0 02             	shl    $0x2,%eax
80109e8c:	89 c2                	mov    %eax,%edx
80109e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e91:	01 d0                	add    %edx,%eax
80109e93:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109e96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e99:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109e9d:	84 c0                	test   %al,%al
80109e9f:	75 4f                	jne    80109ef0 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109ea1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ea4:	0f b6 00             	movzbl (%eax),%eax
80109ea7:	3c 08                	cmp    $0x8,%al
80109ea9:	75 45                	jne    80109ef0 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109eab:	e8 d8 88 ff ff       	call   80102788 <kalloc>
80109eb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109eb3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109eba:	83 ec 04             	sub    $0x4,%esp
80109ebd:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109ec0:	50                   	push   %eax
80109ec1:	ff 75 ec             	push   -0x14(%ebp)
80109ec4:	ff 75 08             	push   0x8(%ebp)
80109ec7:	e8 78 00 00 00       	call   80109f44 <icmp_reply_pkt_create>
80109ecc:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109ecf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ed2:	83 ec 08             	sub    $0x8,%esp
80109ed5:	50                   	push   %eax
80109ed6:	ff 75 ec             	push   -0x14(%ebp)
80109ed9:	e8 95 f4 ff ff       	call   80109373 <i8254_send>
80109ede:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109ee1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ee4:	83 ec 0c             	sub    $0xc,%esp
80109ee7:	50                   	push   %eax
80109ee8:	e8 01 88 ff ff       	call   801026ee <kfree>
80109eed:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109ef0:	90                   	nop
80109ef1:	c9                   	leave  
80109ef2:	c3                   	ret    

80109ef3 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109ef3:	55                   	push   %ebp
80109ef4:	89 e5                	mov    %esp,%ebp
80109ef6:	53                   	push   %ebx
80109ef7:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109efa:	8b 45 08             	mov    0x8(%ebp),%eax
80109efd:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109f01:	0f b7 c0             	movzwl %ax,%eax
80109f04:	83 ec 0c             	sub    $0xc,%esp
80109f07:	50                   	push   %eax
80109f08:	e8 bd fd ff ff       	call   80109cca <N2H_ushort>
80109f0d:	83 c4 10             	add    $0x10,%esp
80109f10:	0f b7 d8             	movzwl %ax,%ebx
80109f13:	8b 45 08             	mov    0x8(%ebp),%eax
80109f16:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109f1a:	0f b7 c0             	movzwl %ax,%eax
80109f1d:	83 ec 0c             	sub    $0xc,%esp
80109f20:	50                   	push   %eax
80109f21:	e8 a4 fd ff ff       	call   80109cca <N2H_ushort>
80109f26:	83 c4 10             	add    $0x10,%esp
80109f29:	0f b7 c0             	movzwl %ax,%eax
80109f2c:	83 ec 04             	sub    $0x4,%esp
80109f2f:	53                   	push   %ebx
80109f30:	50                   	push   %eax
80109f31:	68 63 c9 10 80       	push   $0x8010c963
80109f36:	e8 b9 64 ff ff       	call   801003f4 <cprintf>
80109f3b:	83 c4 10             	add    $0x10,%esp
}
80109f3e:	90                   	nop
80109f3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109f42:	c9                   	leave  
80109f43:	c3                   	ret    

80109f44 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109f44:	55                   	push   %ebp
80109f45:	89 e5                	mov    %esp,%ebp
80109f47:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109f4a:	8b 45 08             	mov    0x8(%ebp),%eax
80109f4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109f50:	8b 45 08             	mov    0x8(%ebp),%eax
80109f53:	83 c0 0e             	add    $0xe,%eax
80109f56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109f59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f5c:	0f b6 00             	movzbl (%eax),%eax
80109f5f:	0f b6 c0             	movzbl %al,%eax
80109f62:	83 e0 0f             	and    $0xf,%eax
80109f65:	c1 e0 02             	shl    $0x2,%eax
80109f68:	89 c2                	mov    %eax,%edx
80109f6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f6d:	01 d0                	add    %edx,%eax
80109f6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109f72:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f75:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109f78:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f7b:	83 c0 0e             	add    $0xe,%eax
80109f7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109f81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f84:	83 c0 14             	add    $0x14,%eax
80109f87:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109f8a:	8b 45 10             	mov    0x10(%ebp),%eax
80109f8d:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f96:	8d 50 06             	lea    0x6(%eax),%edx
80109f99:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f9c:	83 ec 04             	sub    $0x4,%esp
80109f9f:	6a 06                	push   $0x6
80109fa1:	52                   	push   %edx
80109fa2:	50                   	push   %eax
80109fa3:	e8 14 af ff ff       	call   80104ebc <memmove>
80109fa8:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109fab:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fae:	83 c0 06             	add    $0x6,%eax
80109fb1:	83 ec 04             	sub    $0x4,%esp
80109fb4:	6a 06                	push   $0x6
80109fb6:	68 90 e7 30 80       	push   $0x8030e790
80109fbb:	50                   	push   %eax
80109fbc:	e8 fb ae ff ff       	call   80104ebc <memmove>
80109fc1:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109fc4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fc7:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109fcb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fce:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109fd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fd5:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109fd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fdb:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109fdf:	83 ec 0c             	sub    $0xc,%esp
80109fe2:	6a 54                	push   $0x54
80109fe4:	e8 03 fd ff ff       	call   80109cec <H2N_ushort>
80109fe9:	83 c4 10             	add    $0x10,%esp
80109fec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109fef:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109ff3:	0f b7 15 60 ea 30 80 	movzwl 0x8030ea60,%edx
80109ffa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ffd:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a001:	0f b7 05 60 ea 30 80 	movzwl 0x8030ea60,%eax
8010a008:	83 c0 01             	add    $0x1,%eax
8010a00b:	66 a3 60 ea 30 80    	mov    %ax,0x8030ea60
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a011:	83 ec 0c             	sub    $0xc,%esp
8010a014:	68 00 40 00 00       	push   $0x4000
8010a019:	e8 ce fc ff ff       	call   80109cec <H2N_ushort>
8010a01e:	83 c4 10             	add    $0x10,%esp
8010a021:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a024:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a028:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a02b:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a02f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a032:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a036:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a039:	83 c0 0c             	add    $0xc,%eax
8010a03c:	83 ec 04             	sub    $0x4,%esp
8010a03f:	6a 04                	push   $0x4
8010a041:	68 04 f5 10 80       	push   $0x8010f504
8010a046:	50                   	push   %eax
8010a047:	e8 70 ae ff ff       	call   80104ebc <memmove>
8010a04c:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a04f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a052:	8d 50 0c             	lea    0xc(%eax),%edx
8010a055:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a058:	83 c0 10             	add    $0x10,%eax
8010a05b:	83 ec 04             	sub    $0x4,%esp
8010a05e:	6a 04                	push   $0x4
8010a060:	52                   	push   %edx
8010a061:	50                   	push   %eax
8010a062:	e8 55 ae ff ff       	call   80104ebc <memmove>
8010a067:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a06a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a06d:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a073:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a076:	83 ec 0c             	sub    $0xc,%esp
8010a079:	50                   	push   %eax
8010a07a:	e8 6d fd ff ff       	call   80109dec <ipv4_chksum>
8010a07f:	83 c4 10             	add    $0x10,%esp
8010a082:	0f b7 c0             	movzwl %ax,%eax
8010a085:	83 ec 0c             	sub    $0xc,%esp
8010a088:	50                   	push   %eax
8010a089:	e8 5e fc ff ff       	call   80109cec <H2N_ushort>
8010a08e:	83 c4 10             	add    $0x10,%esp
8010a091:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a094:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a098:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a09b:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a09e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0a1:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a0a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0a8:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a0ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0af:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a0b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0b6:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a0ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0bd:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a0c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0c4:	8d 50 08             	lea    0x8(%eax),%edx
8010a0c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0ca:	83 c0 08             	add    $0x8,%eax
8010a0cd:	83 ec 04             	sub    $0x4,%esp
8010a0d0:	6a 08                	push   $0x8
8010a0d2:	52                   	push   %edx
8010a0d3:	50                   	push   %eax
8010a0d4:	e8 e3 ad ff ff       	call   80104ebc <memmove>
8010a0d9:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a0dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0df:	8d 50 10             	lea    0x10(%eax),%edx
8010a0e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0e5:	83 c0 10             	add    $0x10,%eax
8010a0e8:	83 ec 04             	sub    $0x4,%esp
8010a0eb:	6a 30                	push   $0x30
8010a0ed:	52                   	push   %edx
8010a0ee:	50                   	push   %eax
8010a0ef:	e8 c8 ad ff ff       	call   80104ebc <memmove>
8010a0f4:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a0f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0fa:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a100:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a103:	83 ec 0c             	sub    $0xc,%esp
8010a106:	50                   	push   %eax
8010a107:	e8 1c 00 00 00       	call   8010a128 <icmp_chksum>
8010a10c:	83 c4 10             	add    $0x10,%esp
8010a10f:	0f b7 c0             	movzwl %ax,%eax
8010a112:	83 ec 0c             	sub    $0xc,%esp
8010a115:	50                   	push   %eax
8010a116:	e8 d1 fb ff ff       	call   80109cec <H2N_ushort>
8010a11b:	83 c4 10             	add    $0x10,%esp
8010a11e:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a121:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a125:	90                   	nop
8010a126:	c9                   	leave  
8010a127:	c3                   	ret    

8010a128 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a128:	55                   	push   %ebp
8010a129:	89 e5                	mov    %esp,%ebp
8010a12b:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a12e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a131:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a134:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a13b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a142:	eb 48                	jmp    8010a18c <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a144:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a147:	01 c0                	add    %eax,%eax
8010a149:	89 c2                	mov    %eax,%edx
8010a14b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a14e:	01 d0                	add    %edx,%eax
8010a150:	0f b6 00             	movzbl (%eax),%eax
8010a153:	0f b6 c0             	movzbl %al,%eax
8010a156:	c1 e0 08             	shl    $0x8,%eax
8010a159:	89 c2                	mov    %eax,%edx
8010a15b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a15e:	01 c0                	add    %eax,%eax
8010a160:	8d 48 01             	lea    0x1(%eax),%ecx
8010a163:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a166:	01 c8                	add    %ecx,%eax
8010a168:	0f b6 00             	movzbl (%eax),%eax
8010a16b:	0f b6 c0             	movzbl %al,%eax
8010a16e:	01 d0                	add    %edx,%eax
8010a170:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a173:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a17a:	76 0c                	jbe    8010a188 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a17c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a17f:	0f b7 c0             	movzwl %ax,%eax
8010a182:	83 c0 01             	add    $0x1,%eax
8010a185:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a188:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a18c:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a190:	7e b2                	jle    8010a144 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
8010a192:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a195:	f7 d0                	not    %eax
}
8010a197:	c9                   	leave  
8010a198:	c3                   	ret    

8010a199 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a199:	55                   	push   %ebp
8010a19a:	89 e5                	mov    %esp,%ebp
8010a19c:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a19f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1a2:	83 c0 0e             	add    $0xe,%eax
8010a1a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a1a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1ab:	0f b6 00             	movzbl (%eax),%eax
8010a1ae:	0f b6 c0             	movzbl %al,%eax
8010a1b1:	83 e0 0f             	and    $0xf,%eax
8010a1b4:	c1 e0 02             	shl    $0x2,%eax
8010a1b7:	89 c2                	mov    %eax,%edx
8010a1b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1bc:	01 d0                	add    %edx,%eax
8010a1be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a1c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1c4:	83 c0 14             	add    $0x14,%eax
8010a1c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a1ca:	e8 b9 85 ff ff       	call   80102788 <kalloc>
8010a1cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a1d2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a1d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1dc:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a1e0:	0f b6 c0             	movzbl %al,%eax
8010a1e3:	83 e0 02             	and    $0x2,%eax
8010a1e6:	85 c0                	test   %eax,%eax
8010a1e8:	74 3d                	je     8010a227 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a1ea:	83 ec 0c             	sub    $0xc,%esp
8010a1ed:	6a 00                	push   $0x0
8010a1ef:	6a 12                	push   $0x12
8010a1f1:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a1f4:	50                   	push   %eax
8010a1f5:	ff 75 e8             	push   -0x18(%ebp)
8010a1f8:	ff 75 08             	push   0x8(%ebp)
8010a1fb:	e8 a2 01 00 00       	call   8010a3a2 <tcp_pkt_create>
8010a200:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a203:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a206:	83 ec 08             	sub    $0x8,%esp
8010a209:	50                   	push   %eax
8010a20a:	ff 75 e8             	push   -0x18(%ebp)
8010a20d:	e8 61 f1 ff ff       	call   80109373 <i8254_send>
8010a212:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a215:	a1 64 ea 30 80       	mov    0x8030ea64,%eax
8010a21a:	83 c0 01             	add    $0x1,%eax
8010a21d:	a3 64 ea 30 80       	mov    %eax,0x8030ea64
8010a222:	e9 69 01 00 00       	jmp    8010a390 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a227:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a22a:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a22e:	3c 18                	cmp    $0x18,%al
8010a230:	0f 85 10 01 00 00    	jne    8010a346 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a236:	83 ec 04             	sub    $0x4,%esp
8010a239:	6a 03                	push   $0x3
8010a23b:	68 7e c9 10 80       	push   $0x8010c97e
8010a240:	ff 75 ec             	push   -0x14(%ebp)
8010a243:	e8 1c ac ff ff       	call   80104e64 <memcmp>
8010a248:	83 c4 10             	add    $0x10,%esp
8010a24b:	85 c0                	test   %eax,%eax
8010a24d:	74 74                	je     8010a2c3 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a24f:	83 ec 0c             	sub    $0xc,%esp
8010a252:	68 82 c9 10 80       	push   $0x8010c982
8010a257:	e8 98 61 ff ff       	call   801003f4 <cprintf>
8010a25c:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a25f:	83 ec 0c             	sub    $0xc,%esp
8010a262:	6a 00                	push   $0x0
8010a264:	6a 10                	push   $0x10
8010a266:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a269:	50                   	push   %eax
8010a26a:	ff 75 e8             	push   -0x18(%ebp)
8010a26d:	ff 75 08             	push   0x8(%ebp)
8010a270:	e8 2d 01 00 00       	call   8010a3a2 <tcp_pkt_create>
8010a275:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a278:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a27b:	83 ec 08             	sub    $0x8,%esp
8010a27e:	50                   	push   %eax
8010a27f:	ff 75 e8             	push   -0x18(%ebp)
8010a282:	e8 ec f0 ff ff       	call   80109373 <i8254_send>
8010a287:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a28a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a28d:	83 c0 36             	add    $0x36,%eax
8010a290:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a293:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a296:	50                   	push   %eax
8010a297:	ff 75 e0             	push   -0x20(%ebp)
8010a29a:	6a 00                	push   $0x0
8010a29c:	6a 00                	push   $0x0
8010a29e:	e8 5a 04 00 00       	call   8010a6fd <http_proc>
8010a2a3:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a2a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a2a9:	83 ec 0c             	sub    $0xc,%esp
8010a2ac:	50                   	push   %eax
8010a2ad:	6a 18                	push   $0x18
8010a2af:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a2b2:	50                   	push   %eax
8010a2b3:	ff 75 e8             	push   -0x18(%ebp)
8010a2b6:	ff 75 08             	push   0x8(%ebp)
8010a2b9:	e8 e4 00 00 00       	call   8010a3a2 <tcp_pkt_create>
8010a2be:	83 c4 20             	add    $0x20,%esp
8010a2c1:	eb 62                	jmp    8010a325 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a2c3:	83 ec 0c             	sub    $0xc,%esp
8010a2c6:	6a 00                	push   $0x0
8010a2c8:	6a 10                	push   $0x10
8010a2ca:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a2cd:	50                   	push   %eax
8010a2ce:	ff 75 e8             	push   -0x18(%ebp)
8010a2d1:	ff 75 08             	push   0x8(%ebp)
8010a2d4:	e8 c9 00 00 00       	call   8010a3a2 <tcp_pkt_create>
8010a2d9:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a2dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a2df:	83 ec 08             	sub    $0x8,%esp
8010a2e2:	50                   	push   %eax
8010a2e3:	ff 75 e8             	push   -0x18(%ebp)
8010a2e6:	e8 88 f0 ff ff       	call   80109373 <i8254_send>
8010a2eb:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a2ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2f1:	83 c0 36             	add    $0x36,%eax
8010a2f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a2f7:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a2fa:	50                   	push   %eax
8010a2fb:	ff 75 e4             	push   -0x1c(%ebp)
8010a2fe:	6a 00                	push   $0x0
8010a300:	6a 00                	push   $0x0
8010a302:	e8 f6 03 00 00       	call   8010a6fd <http_proc>
8010a307:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a30a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a30d:	83 ec 0c             	sub    $0xc,%esp
8010a310:	50                   	push   %eax
8010a311:	6a 18                	push   $0x18
8010a313:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a316:	50                   	push   %eax
8010a317:	ff 75 e8             	push   -0x18(%ebp)
8010a31a:	ff 75 08             	push   0x8(%ebp)
8010a31d:	e8 80 00 00 00       	call   8010a3a2 <tcp_pkt_create>
8010a322:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a325:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a328:	83 ec 08             	sub    $0x8,%esp
8010a32b:	50                   	push   %eax
8010a32c:	ff 75 e8             	push   -0x18(%ebp)
8010a32f:	e8 3f f0 ff ff       	call   80109373 <i8254_send>
8010a334:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a337:	a1 64 ea 30 80       	mov    0x8030ea64,%eax
8010a33c:	83 c0 01             	add    $0x1,%eax
8010a33f:	a3 64 ea 30 80       	mov    %eax,0x8030ea64
8010a344:	eb 4a                	jmp    8010a390 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a346:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a349:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a34d:	3c 10                	cmp    $0x10,%al
8010a34f:	75 3f                	jne    8010a390 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a351:	a1 68 ea 30 80       	mov    0x8030ea68,%eax
8010a356:	83 f8 01             	cmp    $0x1,%eax
8010a359:	75 35                	jne    8010a390 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a35b:	83 ec 0c             	sub    $0xc,%esp
8010a35e:	6a 00                	push   $0x0
8010a360:	6a 01                	push   $0x1
8010a362:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a365:	50                   	push   %eax
8010a366:	ff 75 e8             	push   -0x18(%ebp)
8010a369:	ff 75 08             	push   0x8(%ebp)
8010a36c:	e8 31 00 00 00       	call   8010a3a2 <tcp_pkt_create>
8010a371:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a374:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a377:	83 ec 08             	sub    $0x8,%esp
8010a37a:	50                   	push   %eax
8010a37b:	ff 75 e8             	push   -0x18(%ebp)
8010a37e:	e8 f0 ef ff ff       	call   80109373 <i8254_send>
8010a383:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a386:	c7 05 68 ea 30 80 00 	movl   $0x0,0x8030ea68
8010a38d:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a390:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a393:	83 ec 0c             	sub    $0xc,%esp
8010a396:	50                   	push   %eax
8010a397:	e8 52 83 ff ff       	call   801026ee <kfree>
8010a39c:	83 c4 10             	add    $0x10,%esp
}
8010a39f:	90                   	nop
8010a3a0:	c9                   	leave  
8010a3a1:	c3                   	ret    

8010a3a2 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a3a2:	55                   	push   %ebp
8010a3a3:	89 e5                	mov    %esp,%ebp
8010a3a5:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a3a8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a3ae:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3b1:	83 c0 0e             	add    $0xe,%eax
8010a3b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a3b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3ba:	0f b6 00             	movzbl (%eax),%eax
8010a3bd:	0f b6 c0             	movzbl %al,%eax
8010a3c0:	83 e0 0f             	and    $0xf,%eax
8010a3c3:	c1 e0 02             	shl    $0x2,%eax
8010a3c6:	89 c2                	mov    %eax,%edx
8010a3c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3cb:	01 d0                	add    %edx,%eax
8010a3cd:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a3d0:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a3d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a3d6:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a3d9:	83 c0 0e             	add    $0xe,%eax
8010a3dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a3df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3e2:	83 c0 14             	add    $0x14,%eax
8010a3e5:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a3e8:	8b 45 18             	mov    0x18(%ebp),%eax
8010a3eb:	8d 50 36             	lea    0x36(%eax),%edx
8010a3ee:	8b 45 10             	mov    0x10(%ebp),%eax
8010a3f1:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a3f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3f6:	8d 50 06             	lea    0x6(%eax),%edx
8010a3f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3fc:	83 ec 04             	sub    $0x4,%esp
8010a3ff:	6a 06                	push   $0x6
8010a401:	52                   	push   %edx
8010a402:	50                   	push   %eax
8010a403:	e8 b4 aa ff ff       	call   80104ebc <memmove>
8010a408:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a40b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a40e:	83 c0 06             	add    $0x6,%eax
8010a411:	83 ec 04             	sub    $0x4,%esp
8010a414:	6a 06                	push   $0x6
8010a416:	68 90 e7 30 80       	push   $0x8030e790
8010a41b:	50                   	push   %eax
8010a41c:	e8 9b aa ff ff       	call   80104ebc <memmove>
8010a421:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a424:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a427:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a42b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a42e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a432:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a435:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a438:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a43b:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a43f:	8b 45 18             	mov    0x18(%ebp),%eax
8010a442:	83 c0 28             	add    $0x28,%eax
8010a445:	0f b7 c0             	movzwl %ax,%eax
8010a448:	83 ec 0c             	sub    $0xc,%esp
8010a44b:	50                   	push   %eax
8010a44c:	e8 9b f8 ff ff       	call   80109cec <H2N_ushort>
8010a451:	83 c4 10             	add    $0x10,%esp
8010a454:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a457:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a45b:	0f b7 15 60 ea 30 80 	movzwl 0x8030ea60,%edx
8010a462:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a465:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a469:	0f b7 05 60 ea 30 80 	movzwl 0x8030ea60,%eax
8010a470:	83 c0 01             	add    $0x1,%eax
8010a473:	66 a3 60 ea 30 80    	mov    %ax,0x8030ea60
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a479:	83 ec 0c             	sub    $0xc,%esp
8010a47c:	6a 00                	push   $0x0
8010a47e:	e8 69 f8 ff ff       	call   80109cec <H2N_ushort>
8010a483:	83 c4 10             	add    $0x10,%esp
8010a486:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a489:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a48d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a490:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a494:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a497:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a49b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a49e:	83 c0 0c             	add    $0xc,%eax
8010a4a1:	83 ec 04             	sub    $0x4,%esp
8010a4a4:	6a 04                	push   $0x4
8010a4a6:	68 04 f5 10 80       	push   $0x8010f504
8010a4ab:	50                   	push   %eax
8010a4ac:	e8 0b aa ff ff       	call   80104ebc <memmove>
8010a4b1:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a4b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4b7:	8d 50 0c             	lea    0xc(%eax),%edx
8010a4ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4bd:	83 c0 10             	add    $0x10,%eax
8010a4c0:	83 ec 04             	sub    $0x4,%esp
8010a4c3:	6a 04                	push   $0x4
8010a4c5:	52                   	push   %edx
8010a4c6:	50                   	push   %eax
8010a4c7:	e8 f0 a9 ff ff       	call   80104ebc <memmove>
8010a4cc:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a4cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4d2:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a4d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4db:	83 ec 0c             	sub    $0xc,%esp
8010a4de:	50                   	push   %eax
8010a4df:	e8 08 f9 ff ff       	call   80109dec <ipv4_chksum>
8010a4e4:	83 c4 10             	add    $0x10,%esp
8010a4e7:	0f b7 c0             	movzwl %ax,%eax
8010a4ea:	83 ec 0c             	sub    $0xc,%esp
8010a4ed:	50                   	push   %eax
8010a4ee:	e8 f9 f7 ff ff       	call   80109cec <H2N_ushort>
8010a4f3:	83 c4 10             	add    $0x10,%esp
8010a4f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a4f9:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a4fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a500:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a504:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a507:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a50a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a50d:	0f b7 10             	movzwl (%eax),%edx
8010a510:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a513:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a517:	a1 64 ea 30 80       	mov    0x8030ea64,%eax
8010a51c:	83 ec 0c             	sub    $0xc,%esp
8010a51f:	50                   	push   %eax
8010a520:	e8 e9 f7 ff ff       	call   80109d0e <H2N_uint>
8010a525:	83 c4 10             	add    $0x10,%esp
8010a528:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a52b:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a52e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a531:	8b 40 04             	mov    0x4(%eax),%eax
8010a534:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a53a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a53d:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a540:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a543:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a547:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a54a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a54e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a551:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a555:	8b 45 14             	mov    0x14(%ebp),%eax
8010a558:	89 c2                	mov    %eax,%edx
8010a55a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a55d:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a560:	83 ec 0c             	sub    $0xc,%esp
8010a563:	68 90 38 00 00       	push   $0x3890
8010a568:	e8 7f f7 ff ff       	call   80109cec <H2N_ushort>
8010a56d:	83 c4 10             	add    $0x10,%esp
8010a570:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a573:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a577:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a57a:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a580:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a583:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a589:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a58c:	83 ec 0c             	sub    $0xc,%esp
8010a58f:	50                   	push   %eax
8010a590:	e8 1f 00 00 00       	call   8010a5b4 <tcp_chksum>
8010a595:	83 c4 10             	add    $0x10,%esp
8010a598:	83 c0 08             	add    $0x8,%eax
8010a59b:	0f b7 c0             	movzwl %ax,%eax
8010a59e:	83 ec 0c             	sub    $0xc,%esp
8010a5a1:	50                   	push   %eax
8010a5a2:	e8 45 f7 ff ff       	call   80109cec <H2N_ushort>
8010a5a7:	83 c4 10             	add    $0x10,%esp
8010a5aa:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a5ad:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a5b1:	90                   	nop
8010a5b2:	c9                   	leave  
8010a5b3:	c3                   	ret    

8010a5b4 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a5b4:	55                   	push   %ebp
8010a5b5:	89 e5                	mov    %esp,%ebp
8010a5b7:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a5ba:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5bd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a5c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5c3:	83 c0 14             	add    $0x14,%eax
8010a5c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a5c9:	83 ec 04             	sub    $0x4,%esp
8010a5cc:	6a 04                	push   $0x4
8010a5ce:	68 04 f5 10 80       	push   $0x8010f504
8010a5d3:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a5d6:	50                   	push   %eax
8010a5d7:	e8 e0 a8 ff ff       	call   80104ebc <memmove>
8010a5dc:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a5df:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5e2:	83 c0 0c             	add    $0xc,%eax
8010a5e5:	83 ec 04             	sub    $0x4,%esp
8010a5e8:	6a 04                	push   $0x4
8010a5ea:	50                   	push   %eax
8010a5eb:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a5ee:	83 c0 04             	add    $0x4,%eax
8010a5f1:	50                   	push   %eax
8010a5f2:	e8 c5 a8 ff ff       	call   80104ebc <memmove>
8010a5f7:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a5fa:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a5fe:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a602:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a605:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a609:	0f b7 c0             	movzwl %ax,%eax
8010a60c:	83 ec 0c             	sub    $0xc,%esp
8010a60f:	50                   	push   %eax
8010a610:	e8 b5 f6 ff ff       	call   80109cca <N2H_ushort>
8010a615:	83 c4 10             	add    $0x10,%esp
8010a618:	83 e8 14             	sub    $0x14,%eax
8010a61b:	0f b7 c0             	movzwl %ax,%eax
8010a61e:	83 ec 0c             	sub    $0xc,%esp
8010a621:	50                   	push   %eax
8010a622:	e8 c5 f6 ff ff       	call   80109cec <H2N_ushort>
8010a627:	83 c4 10             	add    $0x10,%esp
8010a62a:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a62e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a635:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a638:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a63b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a642:	eb 33                	jmp    8010a677 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a644:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a647:	01 c0                	add    %eax,%eax
8010a649:	89 c2                	mov    %eax,%edx
8010a64b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a64e:	01 d0                	add    %edx,%eax
8010a650:	0f b6 00             	movzbl (%eax),%eax
8010a653:	0f b6 c0             	movzbl %al,%eax
8010a656:	c1 e0 08             	shl    $0x8,%eax
8010a659:	89 c2                	mov    %eax,%edx
8010a65b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a65e:	01 c0                	add    %eax,%eax
8010a660:	8d 48 01             	lea    0x1(%eax),%ecx
8010a663:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a666:	01 c8                	add    %ecx,%eax
8010a668:	0f b6 00             	movzbl (%eax),%eax
8010a66b:	0f b6 c0             	movzbl %al,%eax
8010a66e:	01 d0                	add    %edx,%eax
8010a670:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a673:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a677:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a67b:	7e c7                	jle    8010a644 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a67d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a680:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a683:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a68a:	eb 33                	jmp    8010a6bf <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a68c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a68f:	01 c0                	add    %eax,%eax
8010a691:	89 c2                	mov    %eax,%edx
8010a693:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a696:	01 d0                	add    %edx,%eax
8010a698:	0f b6 00             	movzbl (%eax),%eax
8010a69b:	0f b6 c0             	movzbl %al,%eax
8010a69e:	c1 e0 08             	shl    $0x8,%eax
8010a6a1:	89 c2                	mov    %eax,%edx
8010a6a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a6a6:	01 c0                	add    %eax,%eax
8010a6a8:	8d 48 01             	lea    0x1(%eax),%ecx
8010a6ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6ae:	01 c8                	add    %ecx,%eax
8010a6b0:	0f b6 00             	movzbl (%eax),%eax
8010a6b3:	0f b6 c0             	movzbl %al,%eax
8010a6b6:	01 d0                	add    %edx,%eax
8010a6b8:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a6bb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a6bf:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a6c3:	0f b7 c0             	movzwl %ax,%eax
8010a6c6:	83 ec 0c             	sub    $0xc,%esp
8010a6c9:	50                   	push   %eax
8010a6ca:	e8 fb f5 ff ff       	call   80109cca <N2H_ushort>
8010a6cf:	83 c4 10             	add    $0x10,%esp
8010a6d2:	66 d1 e8             	shr    %ax
8010a6d5:	0f b7 c0             	movzwl %ax,%eax
8010a6d8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a6db:	7c af                	jl     8010a68c <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a6dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a6e0:	c1 e8 10             	shr    $0x10,%eax
8010a6e3:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a6e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a6e9:	f7 d0                	not    %eax
}
8010a6eb:	c9                   	leave  
8010a6ec:	c3                   	ret    

8010a6ed <tcp_fin>:

void tcp_fin(){
8010a6ed:	55                   	push   %ebp
8010a6ee:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a6f0:	c7 05 68 ea 30 80 01 	movl   $0x1,0x8030ea68
8010a6f7:	00 00 00 
}
8010a6fa:	90                   	nop
8010a6fb:	5d                   	pop    %ebp
8010a6fc:	c3                   	ret    

8010a6fd <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a6fd:	55                   	push   %ebp
8010a6fe:	89 e5                	mov    %esp,%ebp
8010a700:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a703:	8b 45 10             	mov    0x10(%ebp),%eax
8010a706:	83 ec 04             	sub    $0x4,%esp
8010a709:	6a 00                	push   $0x0
8010a70b:	68 8b c9 10 80       	push   $0x8010c98b
8010a710:	50                   	push   %eax
8010a711:	e8 65 00 00 00       	call   8010a77b <http_strcpy>
8010a716:	83 c4 10             	add    $0x10,%esp
8010a719:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a71c:	8b 45 10             	mov    0x10(%ebp),%eax
8010a71f:	83 ec 04             	sub    $0x4,%esp
8010a722:	ff 75 f4             	push   -0xc(%ebp)
8010a725:	68 9e c9 10 80       	push   $0x8010c99e
8010a72a:	50                   	push   %eax
8010a72b:	e8 4b 00 00 00       	call   8010a77b <http_strcpy>
8010a730:	83 c4 10             	add    $0x10,%esp
8010a733:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a736:	8b 45 10             	mov    0x10(%ebp),%eax
8010a739:	83 ec 04             	sub    $0x4,%esp
8010a73c:	ff 75 f4             	push   -0xc(%ebp)
8010a73f:	68 b9 c9 10 80       	push   $0x8010c9b9
8010a744:	50                   	push   %eax
8010a745:	e8 31 00 00 00       	call   8010a77b <http_strcpy>
8010a74a:	83 c4 10             	add    $0x10,%esp
8010a74d:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a750:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a753:	83 e0 01             	and    $0x1,%eax
8010a756:	85 c0                	test   %eax,%eax
8010a758:	74 11                	je     8010a76b <http_proc+0x6e>
    char *payload = (char *)send;
8010a75a:	8b 45 10             	mov    0x10(%ebp),%eax
8010a75d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a760:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a763:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a766:	01 d0                	add    %edx,%eax
8010a768:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a76b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a76e:	8b 45 14             	mov    0x14(%ebp),%eax
8010a771:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a773:	e8 75 ff ff ff       	call   8010a6ed <tcp_fin>
}
8010a778:	90                   	nop
8010a779:	c9                   	leave  
8010a77a:	c3                   	ret    

8010a77b <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a77b:	55                   	push   %ebp
8010a77c:	89 e5                	mov    %esp,%ebp
8010a77e:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a781:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a788:	eb 20                	jmp    8010a7aa <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a78a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a78d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a790:	01 d0                	add    %edx,%eax
8010a792:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a795:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a798:	01 ca                	add    %ecx,%edx
8010a79a:	89 d1                	mov    %edx,%ecx
8010a79c:	8b 55 08             	mov    0x8(%ebp),%edx
8010a79f:	01 ca                	add    %ecx,%edx
8010a7a1:	0f b6 00             	movzbl (%eax),%eax
8010a7a4:	88 02                	mov    %al,(%edx)
    i++;
8010a7a6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a7aa:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a7ad:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a7b0:	01 d0                	add    %edx,%eax
8010a7b2:	0f b6 00             	movzbl (%eax),%eax
8010a7b5:	84 c0                	test   %al,%al
8010a7b7:	75 d1                	jne    8010a78a <http_strcpy+0xf>
  }
  return i;
8010a7b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a7bc:	c9                   	leave  
8010a7bd:	c3                   	ret    

8010a7be <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a7be:	55                   	push   %ebp
8010a7bf:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a7c1:	c7 05 70 ea 30 80 c2 	movl   $0x8010f5c2,0x8030ea70
8010a7c8:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a7cb:	b8 00 40 1f 00       	mov    $0x1f4000,%eax
8010a7d0:	c1 e8 09             	shr    $0x9,%eax
8010a7d3:	a3 6c ea 30 80       	mov    %eax,0x8030ea6c
}
8010a7d8:	90                   	nop
8010a7d9:	5d                   	pop    %ebp
8010a7da:	c3                   	ret    

8010a7db <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a7db:	55                   	push   %ebp
8010a7dc:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a7de:	90                   	nop
8010a7df:	5d                   	pop    %ebp
8010a7e0:	c3                   	ret    

8010a7e1 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a7e1:	55                   	push   %ebp
8010a7e2:	89 e5                	mov    %esp,%ebp
8010a7e4:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a7e7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a7ea:	83 c0 0c             	add    $0xc,%eax
8010a7ed:	83 ec 0c             	sub    $0xc,%esp
8010a7f0:	50                   	push   %eax
8010a7f1:	e8 00 a3 ff ff       	call   80104af6 <holdingsleep>
8010a7f6:	83 c4 10             	add    $0x10,%esp
8010a7f9:	85 c0                	test   %eax,%eax
8010a7fb:	75 0d                	jne    8010a80a <iderw+0x29>
    panic("iderw: buf not locked");
8010a7fd:	83 ec 0c             	sub    $0xc,%esp
8010a800:	68 ca c9 10 80       	push   $0x8010c9ca
8010a805:	e8 9f 5d ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a80a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a80d:	8b 00                	mov    (%eax),%eax
8010a80f:	83 e0 06             	and    $0x6,%eax
8010a812:	83 f8 02             	cmp    $0x2,%eax
8010a815:	75 0d                	jne    8010a824 <iderw+0x43>
    panic("iderw: nothing to do");
8010a817:	83 ec 0c             	sub    $0xc,%esp
8010a81a:	68 e0 c9 10 80       	push   $0x8010c9e0
8010a81f:	e8 85 5d ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a824:	8b 45 08             	mov    0x8(%ebp),%eax
8010a827:	8b 40 04             	mov    0x4(%eax),%eax
8010a82a:	83 f8 01             	cmp    $0x1,%eax
8010a82d:	74 0d                	je     8010a83c <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a82f:	83 ec 0c             	sub    $0xc,%esp
8010a832:	68 f5 c9 10 80       	push   $0x8010c9f5
8010a837:	e8 6d 5d ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a83c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a83f:	8b 40 08             	mov    0x8(%eax),%eax
8010a842:	8b 15 6c ea 30 80    	mov    0x8030ea6c,%edx
8010a848:	39 d0                	cmp    %edx,%eax
8010a84a:	72 0d                	jb     8010a859 <iderw+0x78>
    panic("iderw: block out of range");
8010a84c:	83 ec 0c             	sub    $0xc,%esp
8010a84f:	68 13 ca 10 80       	push   $0x8010ca13
8010a854:	e8 50 5d ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a859:	8b 15 70 ea 30 80    	mov    0x8030ea70,%edx
8010a85f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a862:	8b 40 08             	mov    0x8(%eax),%eax
8010a865:	c1 e0 09             	shl    $0x9,%eax
8010a868:	01 d0                	add    %edx,%eax
8010a86a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a86d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a870:	8b 00                	mov    (%eax),%eax
8010a872:	83 e0 04             	and    $0x4,%eax
8010a875:	85 c0                	test   %eax,%eax
8010a877:	74 2b                	je     8010a8a4 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a879:	8b 45 08             	mov    0x8(%ebp),%eax
8010a87c:	8b 00                	mov    (%eax),%eax
8010a87e:	83 e0 fb             	and    $0xfffffffb,%eax
8010a881:	89 c2                	mov    %eax,%edx
8010a883:	8b 45 08             	mov    0x8(%ebp),%eax
8010a886:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a888:	8b 45 08             	mov    0x8(%ebp),%eax
8010a88b:	83 c0 5c             	add    $0x5c,%eax
8010a88e:	83 ec 04             	sub    $0x4,%esp
8010a891:	68 00 02 00 00       	push   $0x200
8010a896:	50                   	push   %eax
8010a897:	ff 75 f4             	push   -0xc(%ebp)
8010a89a:	e8 1d a6 ff ff       	call   80104ebc <memmove>
8010a89f:	83 c4 10             	add    $0x10,%esp
8010a8a2:	eb 1a                	jmp    8010a8be <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a8a4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8a7:	83 c0 5c             	add    $0x5c,%eax
8010a8aa:	83 ec 04             	sub    $0x4,%esp
8010a8ad:	68 00 02 00 00       	push   $0x200
8010a8b2:	ff 75 f4             	push   -0xc(%ebp)
8010a8b5:	50                   	push   %eax
8010a8b6:	e8 01 a6 ff ff       	call   80104ebc <memmove>
8010a8bb:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a8be:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8c1:	8b 00                	mov    (%eax),%eax
8010a8c3:	83 c8 02             	or     $0x2,%eax
8010a8c6:	89 c2                	mov    %eax,%edx
8010a8c8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8cb:	89 10                	mov    %edx,(%eax)
}
8010a8cd:	90                   	nop
8010a8ce:	c9                   	leave  
8010a8cf:	c3                   	ret    
