
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
8010006f:	68 a0 a7 10 80       	push   $0x8010a7a0
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 85 4a 00 00       	call   80104b03 <initlock>
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
801000bd:	68 a7 a7 10 80       	push   $0x8010a7a7
801000c2:	50                   	push   %eax
801000c3:	e8 de 48 00 00       	call   801049a6 <initsleeplock>
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
80100101:	e8 1f 4a 00 00       	call   80104b25 <acquire>
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
80100140:	e8 4e 4a 00 00       	call   80104b93 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 8b 48 00 00       	call   801049e2 <acquiresleep>
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
801001c1:	e8 cd 49 00 00       	call   80104b93 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 0a 48 00 00       	call   801049e2 <acquiresleep>
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
801001f5:	68 ae a7 10 80       	push   $0x8010a7ae
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
8010022d:	e8 75 a4 00 00       	call   8010a6a7 <iderw>
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
8010024a:	e8 45 48 00 00       	call   80104a94 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 bf a7 10 80       	push   $0x8010a7bf
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
80100278:	e8 2a a4 00 00       	call   8010a6a7 <iderw>
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
80100293:	e8 fc 47 00 00       	call   80104a94 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 c6 a7 10 80       	push   $0x8010a7c6
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 8b 47 00 00       	call   80104a46 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 5a 48 00 00       	call   80104b25 <acquire>
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
80100336:	e8 58 48 00 00       	call   80104b93 <release>
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
80100410:	e8 10 47 00 00       	call   80104b25 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 cd a7 10 80       	push   $0x8010a7cd
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
80100510:	c7 45 ec d6 a7 10 80 	movl   $0x8010a7d6,-0x14(%ebp)
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
8010059e:	e8 f0 45 00 00       	call   80104b93 <release>
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
801005c7:	68 dd a7 10 80       	push   $0x8010a7dd
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
801005e6:	68 f1 a7 10 80       	push   $0x8010a7f1
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 e2 45 00 00       	call   80104be5 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 f3 a7 10 80       	push   $0x8010a7f3
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
801006a0:	e8 59 7f 00 00       	call   801085fe <graphic_scroll_up>
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
801006f3:	e8 06 7f 00 00       	call   801085fe <graphic_scroll_up>
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
80100757:	e8 0d 7f 00 00       	call   80108669 <font_render>
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
80100793:	e8 dd 62 00 00       	call   80106a75 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 d0 62 00 00       	call   80106a75 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 c3 62 00 00       	call   80106a75 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 b3 62 00 00       	call   80106a75 <uartputc>
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
801007eb:	e8 35 43 00 00       	call   80104b25 <acquire>
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
80100962:	e8 2c 42 00 00       	call   80104b93 <release>
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
8010099a:	e8 86 41 00 00       	call   80104b25 <acquire>
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
801009bb:	e8 d3 41 00 00       	call   80104b93 <release>
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
80100a66:	e8 28 41 00 00       	call   80104b93 <release>
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
80100aa2:	e8 7e 40 00 00       	call   80104b25 <acquire>
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
80100ae4:	e8 aa 40 00 00       	call   80104b93 <release>
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
80100b12:	68 f7 a7 10 80       	push   $0x8010a7f7
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 e2 3f 00 00       	call   80104b03 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 ff a7 10 80 	movl   $0x8010a7ff,-0xc(%ebp)
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
80100bb5:	68 15 a8 10 80       	push   $0x8010a815
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
80100c11:	e8 5b 6e 00 00       	call   80107a71 <setupkvm>
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
80100cb7:	e8 ae 71 00 00       	call   80107e6a <allocuvm>
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
80100cfd:	e8 9b 70 00 00       	call   80107d9d <loaduvm>
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
  //sp = KERNBASE;
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	05 00 20 00 00       	add    $0x2000,%eax
80100d62:	83 ec 04             	sub    $0x4,%esp
80100d65:	50                   	push   %eax
80100d66:	ff 75 e0             	push   -0x20(%ebp)
80100d69:	ff 75 d4             	push   -0x2c(%ebp)
80100d6c:	e8 f9 70 00 00       	call   80107e6a <allocuvm>
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
80100d90:	e8 37 73 00 00       	call   801080cc <clearpteu>
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
80100dc9:	e8 1b 42 00 00       	call   80104fe9 <strlen>
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
80100df6:	e8 ee 41 00 00       	call   80104fe9 <strlen>
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
80100e1c:	e8 4a 74 00 00       	call   8010826b <copyout>
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
80100eb8:	e8 ae 73 00 00       	call   8010826b <copyout>
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
80100f06:	e8 93 40 00 00       	call   80104f9e <safestrcpy>
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
80100f49:	e8 40 6c 00 00       	call   80107b8e <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 d7 70 00 00       	call   80108033 <freevm>
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
80100f97:	e8 97 70 00 00       	call   80108033 <freevm>
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
80100fc8:	68 21 a8 10 80       	push   $0x8010a821
80100fcd:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd2:	e8 2c 3b 00 00       	call   80104b03 <initlock>
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
80100feb:	e8 35 3b 00 00       	call   80104b25 <acquire>
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
80101018:	e8 76 3b 00 00       	call   80104b93 <release>
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
8010103b:	e8 53 3b 00 00       	call   80104b93 <release>
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
80101058:	e8 c8 3a 00 00       	call   80104b25 <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 28 a8 10 80       	push   $0x8010a828
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
8010108e:	e8 00 3b 00 00       	call   80104b93 <release>
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
801010a9:	e8 77 3a 00 00       	call   80104b25 <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 30 a8 10 80       	push   $0x8010a830
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
801010e9:	e8 a5 3a 00 00       	call   80104b93 <release>
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
80101137:	e8 57 3a 00 00       	call   80104b93 <release>
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
80101286:	68 3a a8 10 80       	push   $0x8010a83a
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
80101389:	68 43 a8 10 80       	push   $0x8010a843
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
801013bf:	68 53 a8 10 80       	push   $0x8010a853
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
801013f7:	e8 5e 3a 00 00       	call   80104e5a <memmove>
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
8010143d:	e8 59 39 00 00       	call   80104d9b <memset>
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
8010159c:	68 60 a8 10 80       	push   $0x8010a860
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
80101627:	68 76 a8 10 80       	push   $0x8010a876
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
8010168b:	68 89 a8 10 80       	push   $0x8010a889
80101690:	68 60 24 19 80       	push   $0x80192460
80101695:	e8 69 34 00 00       	call   80104b03 <initlock>
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
801016c1:	68 90 a8 10 80       	push   $0x8010a890
801016c6:	50                   	push   %eax
801016c7:	e8 da 32 00 00       	call   801049a6 <initsleeplock>
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
80101720:	68 98 a8 10 80       	push   $0x8010a898
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
80101799:	e8 fd 35 00 00       	call   80104d9b <memset>
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
80101801:	68 eb a8 10 80       	push   $0x8010a8eb
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
801018a7:	e8 ae 35 00 00       	call   80104e5a <memmove>
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
801018dc:	e8 44 32 00 00       	call   80104b25 <acquire>
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
8010192a:	e8 64 32 00 00       	call   80104b93 <release>
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
80101966:	68 fd a8 10 80       	push   $0x8010a8fd
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
801019a3:	e8 eb 31 00 00       	call   80104b93 <release>
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
801019be:	e8 62 31 00 00       	call   80104b25 <acquire>
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
801019dd:	e8 b1 31 00 00       	call   80104b93 <release>
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
80101a03:	68 0d a9 10 80       	push   $0x8010a90d
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 c6 2f 00 00       	call   801049e2 <acquiresleep>
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
80101ac1:	e8 94 33 00 00       	call   80104e5a <memmove>
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
80101af0:	68 13 a9 10 80       	push   $0x8010a913
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
80101b13:	e8 7c 2f 00 00       	call   80104a94 <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 22 a9 10 80       	push   $0x8010a922
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 01 2f 00 00       	call   80104a46 <releasesleep>
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
80101b5b:	e8 82 2e 00 00       	call   801049e2 <acquiresleep>
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
80101b81:	e8 9f 2f 00 00       	call   80104b25 <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 24 19 80       	push   $0x80192460
80101b9a:	e8 f4 2f 00 00       	call   80104b93 <release>
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
80101be1:	e8 60 2e 00 00       	call   80104a46 <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 24 19 80       	push   $0x80192460
80101bf1:	e8 2f 2f 00 00       	call   80104b25 <acquire>
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
80101c10:	e8 7e 2f 00 00       	call   80104b93 <release>
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
80101d54:	68 2a a9 10 80       	push   $0x8010a92a
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
80101ff2:	e8 63 2e 00 00       	call   80104e5a <memmove>
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
80102142:	e8 13 2d 00 00       	call   80104e5a <memmove>
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
801021c2:	e8 29 2d 00 00       	call   80104ef0 <strncmp>
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
801021e2:	68 3d a9 10 80       	push   $0x8010a93d
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
80102211:	68 4f a9 10 80       	push   $0x8010a94f
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
801022e6:	68 5e a9 10 80       	push   $0x8010a95e
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
80102321:	e8 20 2c 00 00       	call   80104f46 <strncpy>
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
8010234d:	68 6b a9 10 80       	push   $0x8010a96b
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
801023bf:	e8 96 2a 00 00       	call   80104e5a <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 7f 2a 00 00       	call   80104e5a <memmove>
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
801025cd:	68 74 a9 10 80       	push   $0x8010a974
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
80102674:	68 a6 a9 10 80       	push   $0x8010a9a6
80102679:	68 c0 40 19 80       	push   $0x801940c0
8010267e:	e8 80 24 00 00       	call   80104b03 <initlock>
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
80102733:	68 ab a9 10 80       	push   $0x8010a9ab
80102738:	e8 6c de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273d:	83 ec 04             	sub    $0x4,%esp
80102740:	68 00 10 00 00       	push   $0x1000
80102745:	6a 01                	push   $0x1
80102747:	ff 75 08             	push   0x8(%ebp)
8010274a:	e8 4c 26 00 00       	call   80104d9b <memset>
8010274f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102752:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102757:	85 c0                	test   %eax,%eax
80102759:	74 10                	je     8010276b <kfree+0x65>
    acquire(&kmem.lock);
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 c0 40 19 80       	push   $0x801940c0
80102763:	e8 bd 23 00 00       	call   80104b25 <acquire>
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
80102795:	e8 f9 23 00 00       	call   80104b93 <release>
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
801027b7:	e8 69 23 00 00       	call   80104b25 <acquire>
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
801027e8:	e8 a6 23 00 00       	call   80104b93 <release>
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
80102d12:	e8 eb 20 00 00       	call   80104e02 <memcmp>
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
80102e26:	68 b1 a9 10 80       	push   $0x8010a9b1
80102e2b:	68 20 41 19 80       	push   $0x80194120
80102e30:	e8 ce 1c 00 00       	call   80104b03 <initlock>
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
80102edb:	e8 7a 1f 00 00       	call   80104e5a <memmove>
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
8010304a:	e8 d6 1a 00 00       	call   80104b25 <acquire>
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
801030bc:	e8 d2 1a 00 00       	call   80104b93 <release>
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
801030dd:	e8 43 1a 00 00       	call   80104b25 <acquire>
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
801030fe:	68 b5 a9 10 80       	push   $0x8010a9b5
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
8010313c:	e8 52 1a 00 00       	call   80104b93 <release>
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
80103157:	e8 c9 19 00 00       	call   80104b25 <acquire>
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
80103181:	e8 0d 1a 00 00       	call   80104b93 <release>
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
801031fd:	e8 58 1c 00 00       	call   80104e5a <memmove>
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
8010329a:	68 c4 a9 10 80       	push   $0x8010a9c4
8010329f:	e8 05 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a4:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	7f 0d                	jg     801032ba <log_write+0x45>
    panic("log_write outside of trans");
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 da a9 10 80       	push   $0x8010a9da
801032b5:	e8 ef d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ba:	83 ec 0c             	sub    $0xc,%esp
801032bd:	68 20 41 19 80       	push   $0x80194120
801032c2:	e8 5e 18 00 00       	call   80104b25 <acquire>
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
80103340:	e8 4e 18 00 00       	call   80104b93 <release>
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
80103376:	e8 c8 51 00 00       	call   80108543 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337b:	83 ec 08             	sub    $0x8,%esp
8010337e:	68 00 00 40 80       	push   $0x80400000
80103383:	68 00 90 19 80       	push   $0x80199000
80103388:	e8 de f2 ff ff       	call   8010266b <kinit1>
8010338d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103390:	e8 c8 47 00 00       	call   80107b5d <kvmalloc>
  mpinit_uefi();
80103395:	e8 6f 4f 00 00       	call   80108309 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339a:	e8 3c f6 ff ff       	call   801029db <lapicinit>
  seginit();       // segment descriptors
8010339f:	e8 51 42 00 00       	call   801075f5 <seginit>
  picinit();    // disable pic
801033a4:	e8 9d 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033a9:	e8 d8 f1 ff ff       	call   80102586 <ioapicinit>
  consoleinit();   // console hardware
801033ae:	e8 4c d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b3:	e8 d6 35 00 00       	call   8010698e <uartinit>
  pinit();         // process table
801033b8:	e8 c2 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bd:	e8 4a 31 00 00       	call   8010650c <tvinit>
  binit();         // buffer cache
801033c2:	e8 9f cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c7:	e8 f3 db ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801033cc:	e8 b3 72 00 00       	call   8010a684 <ideinit>
  startothers();   // start other processors
801033d1:	e8 8a 00 00 00       	call   80103460 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	68 00 00 00 a0       	push   $0xa0000000
801033de:	68 00 00 40 80       	push   $0x80400000
801033e3:	e8 bc f2 ff ff       	call   801026a4 <kinit2>
801033e8:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033eb:	e8 ac 53 00 00       	call   8010879c <pci_init>
  arp_scan();
801033f0:	e8 e3 60 00 00       	call   801094d8 <arp_scan>
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
80103405:	e8 6b 47 00 00       	call   80107b75 <switchkvm>
  seginit();
8010340a:	e8 e6 41 00 00       	call   801075f5 <seginit>
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
80103431:	68 f5 a9 10 80       	push   $0x8010a9f5
80103436:	e8 b9 cf ff ff       	call   801003f4 <cprintf>
8010343b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343e:	e8 3f 32 00 00       	call   80106682 <idtinit>
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
8010347e:	e8 d7 19 00 00       	call   80104e5a <memmove>
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
80103607:	68 09 aa 10 80       	push   $0x8010aa09
8010360c:	50                   	push   %eax
8010360d:	e8 f1 14 00 00       	call   80104b03 <initlock>
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
801036cc:	e8 54 14 00 00       	call   80104b25 <acquire>
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
8010373f:	e8 4f 14 00 00       	call   80104b93 <release>
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
8010375e:	e8 30 14 00 00       	call   80104b93 <release>
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
80103778:	e8 a8 13 00 00       	call   80104b25 <acquire>
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
801037ac:	e8 e2 13 00 00       	call   80104b93 <release>
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
8010385c:	e8 32 13 00 00       	call   80104b93 <release>
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
80103879:	e8 a7 12 00 00       	call   80104b25 <acquire>
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
80103896:	e8 f8 12 00 00       	call   80104b93 <release>
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
8010395b:	e8 33 12 00 00       	call   80104b93 <release>
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
80103988:	68 10 aa 10 80       	push   $0x8010aa10
8010398d:	68 00 4b 19 80       	push   $0x80194b00
80103992:	e8 6c 11 00 00       	call   80104b03 <initlock>
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
801039cf:	68 18 aa 10 80       	push   $0x8010aa18
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
80103a24:	68 3e aa 10 80       	push   $0x8010aa3e
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
80103a36:	e8 55 12 00 00       	call   80104c90 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 89 12 00 00       	call   80104cdd <popcli>
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
80103a67:	e8 b9 10 00 00       	call   80104b25 <acquire>
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
80103a9a:	e8 f4 10 00 00       	call   80104b93 <release>
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
80103b00:	e8 96 12 00 00       	call   80104d9b <memset>
80103b05:	83 c4 10             	add    $0x10,%esp
  memset(proc_wait_ticks[idx], 0, sizeof(proc_wait_ticks[idx]));
80103b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b0b:	c1 e0 04             	shl    $0x4,%eax
80103b0e:	05 00 47 19 80       	add    $0x80194700,%eax
80103b13:	83 ec 04             	sub    $0x4,%esp
80103b16:	6a 10                	push   $0x10
80103b18:	6a 00                	push   $0x0
80103b1a:	50                   	push   %eax
80103b1b:	e8 7b 12 00 00       	call   80104d9b <memset>
80103b20:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103b23:	83 ec 0c             	sub    $0xc,%esp
80103b26:	68 00 4b 19 80       	push   $0x80194b00
80103b2b:	e8 63 10 00 00       	call   80104b93 <release>
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
80103b78:	ba c6 64 10 80       	mov    $0x801064c6,%edx
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
80103b9d:	e8 f9 11 00 00       	call   80104d9b <memset>
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
80103bce:	e8 9e 3e 00 00       	call   80107a71 <setupkvm>
80103bd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bd6:	89 42 04             	mov    %eax,0x4(%edx)
80103bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bdc:	8b 40 04             	mov    0x4(%eax),%eax
80103bdf:	85 c0                	test   %eax,%eax
80103be1:	75 0d                	jne    80103bf0 <userinit+0x38>
  {
    panic("userinit: out of memory?");
80103be3:	83 ec 0c             	sub    $0xc,%esp
80103be6:	68 4e aa 10 80       	push   $0x8010aa4e
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
80103c05:	e8 23 41 00 00       	call   80107d2d <inituvm>
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
80103c24:	e8 72 11 00 00       	call   80104d9b <memset>
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
80103c9e:	68 67 aa 10 80       	push   $0x8010aa67
80103ca3:	50                   	push   %eax
80103ca4:	e8 f5 12 00 00       	call   80104f9e <safestrcpy>
80103ca9:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103cac:	83 ec 0c             	sub    $0xc,%esp
80103caf:	68 70 aa 10 80       	push   $0x8010aa70
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
80103cca:	e8 56 0e 00 00       	call   80104b25 <acquire>
80103ccf:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103cdc:	83 ec 0c             	sub    $0xc,%esp
80103cdf:	68 00 4b 19 80       	push   $0x80194b00
80103ce4:	e8 aa 0e 00 00       	call   80104b93 <release>
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
80103d21:	e8 44 41 00 00       	call   80107e6a <allocuvm>
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
80103d55:	e8 15 42 00 00       	call   80107f6f <deallocuvm>
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
80103d7b:	e8 0e 3e 00 00       	call   80107b8e <switchuvm>
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
80103dc3:	e8 45 43 00 00       	call   8010810d <copyuvm>
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
80103ebd:	e8 dc 10 00 00       	call   80104f9e <safestrcpy>
80103ec2:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103ec5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ec8:	8b 40 10             	mov    0x10(%eax),%eax
80103ecb:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103ece:	83 ec 0c             	sub    $0xc,%esp
80103ed1:	68 00 4b 19 80       	push   $0x80194b00
80103ed6:	e8 4a 0c 00 00       	call   80104b25 <acquire>
80103edb:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103ede:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ee1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103ee8:	83 ec 0c             	sub    $0xc,%esp
80103eeb:	68 00 4b 19 80       	push   $0x80194b00
80103ef0:	e8 9e 0c 00 00       	call   80104b93 <release>
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
//이거이거 살짝
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
80103f1e:	68 72 aa 10 80       	push   $0x8010aa72
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
80103fa4:	e8 7c 0b 00 00       	call   80104b25 <acquire>
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
8010405d:	68 7f aa 10 80       	push   $0x8010aa7f
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
8010407d:	e8 a3 0a 00 00       	call   80104b25 <acquire>
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
801040e8:	e8 46 3f 00 00       	call   80108033 <freevm>
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
80104127:	e8 67 0a 00 00       	call   80104b93 <release>
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
80104161:	e8 2d 0a 00 00       	call   80104b93 <release>
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
801041b2:	e8 6e 09 00 00       	call   80104b25 <acquire>
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
801041f9:	e8 90 39 00 00       	call   80107b8e <switchuvm>
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
8010421c:	e8 ef 0d 00 00       	call   80105010 <swtch>
80104221:	83 c4 10             	add    $0x10,%esp
        switchkvm();
80104224:	e8 4c 39 00 00       	call   80107b75 <switchkvm>

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
801042e1:	e8 a8 38 00 00       	call   80107b8e <switchuvm>
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
80104304:	e8 07 0d 00 00       	call   80105010 <swtch>
80104309:	83 c4 10             	add    $0x10,%esp
        switchkvm();
8010430c:	e8 64 38 00 00       	call   80107b75 <switchkvm>

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
801043bb:	e8 db 09 00 00       	call   80104d9b <memset>
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
80104520:	e8 76 08 00 00       	call   80104d9b <memset>
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
80104544:	e8 4a 06 00 00       	call   80104b93 <release>
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
80104567:	e8 f4 06 00 00       	call   80104c60 <holding>
8010456c:	83 c4 10             	add    $0x10,%esp
8010456f:	85 c0                	test   %eax,%eax
80104571:	75 0d                	jne    80104580 <sched+0x2f>
    panic("sched ptable.lock");
80104573:	83 ec 0c             	sub    $0xc,%esp
80104576:	68 8b aa 10 80       	push   $0x8010aa8b
8010457b:	e8 29 c0 ff ff       	call   801005a9 <panic>
  if (mycpu()->ncli != 1)
80104580:	e8 33 f4 ff ff       	call   801039b8 <mycpu>
80104585:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010458b:	83 f8 01             	cmp    $0x1,%eax
8010458e:	74 0d                	je     8010459d <sched+0x4c>
    panic("sched locks");
80104590:	83 ec 0c             	sub    $0xc,%esp
80104593:	68 9d aa 10 80       	push   $0x8010aa9d
80104598:	e8 0c c0 ff ff       	call   801005a9 <panic>
  if (p->state == RUNNING)
8010459d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a0:	8b 40 0c             	mov    0xc(%eax),%eax
801045a3:	83 f8 04             	cmp    $0x4,%eax
801045a6:	75 0d                	jne    801045b5 <sched+0x64>
    panic("sched running");
801045a8:	83 ec 0c             	sub    $0xc,%esp
801045ab:	68 a9 aa 10 80       	push   $0x8010aaa9
801045b0:	e8 f4 bf ff ff       	call   801005a9 <panic>
  if (readeflags() & FL_IF)
801045b5:	e8 ae f3 ff ff       	call   80103968 <readeflags>
801045ba:	25 00 02 00 00       	and    $0x200,%eax
801045bf:	85 c0                	test   %eax,%eax
801045c1:	74 0d                	je     801045d0 <sched+0x7f>
    panic("sched interruptible");
801045c3:	83 ec 0c             	sub    $0xc,%esp
801045c6:	68 b7 aa 10 80       	push   $0x8010aab7
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
801045f1:	e8 1a 0a 00 00       	call   80105010 <swtch>
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

// 이거이거거
// Give up the CPU for one scheduling round.
void yield(void)
{
8010460a:	55                   	push   %ebp
8010460b:	89 e5                	mov    %esp,%ebp
8010460d:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock); // DOC: yieldlock
80104610:	83 ec 0c             	sub    $0xc,%esp
80104613:	68 00 4b 19 80       	push   $0x80194b00
80104618:	e8 08 05 00 00       	call   80104b25 <acquire>
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
8010467a:	e8 14 05 00 00       	call   80104b93 <release>
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
80104693:	e8 fb 04 00 00       	call   80104b93 <release>
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
801046e2:	68 cb aa 10 80       	push   $0x8010aacb
801046e7:	e8 bd be ff ff       	call   801005a9 <panic>

  if (lk == 0)
801046ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801046f0:	75 0d                	jne    801046ff <sleep+0x34>
    panic("sleep without lk");
801046f2:	83 ec 0c             	sub    $0xc,%esp
801046f5:	68 d1 aa 10 80       	push   $0x8010aad1
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
80104710:	e8 10 04 00 00       	call   80104b25 <acquire>
80104715:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104718:	83 ec 0c             	sub    $0xc,%esp
8010471b:	ff 75 0c             	push   0xc(%ebp)
8010471e:	e8 70 04 00 00       	call   80104b93 <release>
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
80104759:	e8 35 04 00 00       	call   80104b93 <release>
8010475e:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104761:	83 ec 0c             	sub    $0xc,%esp
80104764:	ff 75 0c             	push   0xc(%ebp)
80104767:	e8 b9 03 00 00       	call   80104b25 <acquire>
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
801047c3:	e8 5d 03 00 00       	call   80104b25 <acquire>
801047c8:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801047cb:	83 ec 0c             	sub    $0xc,%esp
801047ce:	ff 75 08             	push   0x8(%ebp)
801047d1:	e8 9c ff ff ff       	call   80104772 <wakeup1>
801047d6:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801047d9:	83 ec 0c             	sub    $0xc,%esp
801047dc:	68 00 4b 19 80       	push   $0x80194b00
801047e1:	e8 ad 03 00 00       	call   80104b93 <release>
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
801047fa:	e8 26 03 00 00       	call   80104b25 <acquire>
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
8010483d:	e8 51 03 00 00       	call   80104b93 <release>
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
80104864:	e8 2a 03 00 00       	call   80104b93 <release>
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
801048c1:	c7 45 ec e2 aa 10 80 	movl   $0x8010aae2,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801048c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048cb:	8d 50 6c             	lea    0x6c(%eax),%edx
801048ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048d1:	8b 40 10             	mov    0x10(%eax),%eax
801048d4:	52                   	push   %edx
801048d5:	ff 75 ec             	push   -0x14(%ebp)
801048d8:	50                   	push   %eax
801048d9:	68 e6 aa 10 80       	push   $0x8010aae6
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
80104907:	e8 d9 02 00 00       	call   80104be5 <getcallerpcs>
8010490c:	83 c4 10             	add    $0x10,%esp
      for (i = 0; i < 10 && pc[i] != 0; i++)
8010490f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104916:	eb 1c                	jmp    80104934 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010491f:	83 ec 08             	sub    $0x8,%esp
80104922:	50                   	push   %eax
80104923:	68 ef aa 10 80       	push   $0x8010aaef
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
80104948:	68 f3 aa 10 80       	push   $0x8010aaf3
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

80104970 <find_proc_by_pid>:

struct proc* find_proc_by_pid(int pid) {
80104970:	55                   	push   %ebp
80104971:	89 e5                	mov    %esp,%ebp
80104973:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104976:	c7 45 fc 34 4b 19 80 	movl   $0x80194b34,-0x4(%ebp)
8010497d:	eb 17                	jmp    80104996 <find_proc_by_pid+0x26>
    if(p->pid == pid)
8010497f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104982:	8b 40 10             	mov    0x10(%eax),%eax
80104985:	39 45 08             	cmp    %eax,0x8(%ebp)
80104988:	75 05                	jne    8010498f <find_proc_by_pid+0x1f>
      return p;
8010498a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010498d:	eb 15                	jmp    801049a4 <find_proc_by_pid+0x34>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010498f:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104996:	81 7d fc 34 6c 19 80 	cmpl   $0x80196c34,-0x4(%ebp)
8010499d:	72 e0                	jb     8010497f <find_proc_by_pid+0xf>
  }
  return 0;
8010499f:	b8 00 00 00 00       	mov    $0x0,%eax
801049a4:	c9                   	leave  
801049a5:	c3                   	ret    

801049a6 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801049a6:	55                   	push   %ebp
801049a7:	89 e5                	mov    %esp,%ebp
801049a9:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801049ac:	8b 45 08             	mov    0x8(%ebp),%eax
801049af:	83 c0 04             	add    $0x4,%eax
801049b2:	83 ec 08             	sub    $0x8,%esp
801049b5:	68 1f ab 10 80       	push   $0x8010ab1f
801049ba:	50                   	push   %eax
801049bb:	e8 43 01 00 00       	call   80104b03 <initlock>
801049c0:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801049c3:	8b 45 08             	mov    0x8(%ebp),%eax
801049c6:	8b 55 0c             	mov    0xc(%ebp),%edx
801049c9:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801049cc:	8b 45 08             	mov    0x8(%ebp),%eax
801049cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801049d5:	8b 45 08             	mov    0x8(%ebp),%eax
801049d8:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801049df:	90                   	nop
801049e0:	c9                   	leave  
801049e1:	c3                   	ret    

801049e2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801049e2:	55                   	push   %ebp
801049e3:	89 e5                	mov    %esp,%ebp
801049e5:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801049e8:	8b 45 08             	mov    0x8(%ebp),%eax
801049eb:	83 c0 04             	add    $0x4,%eax
801049ee:	83 ec 0c             	sub    $0xc,%esp
801049f1:	50                   	push   %eax
801049f2:	e8 2e 01 00 00       	call   80104b25 <acquire>
801049f7:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801049fa:	eb 15                	jmp    80104a11 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801049fc:	8b 45 08             	mov    0x8(%ebp),%eax
801049ff:	83 c0 04             	add    $0x4,%eax
80104a02:	83 ec 08             	sub    $0x8,%esp
80104a05:	50                   	push   %eax
80104a06:	ff 75 08             	push   0x8(%ebp)
80104a09:	e8 bd fc ff ff       	call   801046cb <sleep>
80104a0e:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104a11:	8b 45 08             	mov    0x8(%ebp),%eax
80104a14:	8b 00                	mov    (%eax),%eax
80104a16:	85 c0                	test   %eax,%eax
80104a18:	75 e2                	jne    801049fc <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a1d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104a23:	e8 08 f0 ff ff       	call   80103a30 <myproc>
80104a28:	8b 50 10             	mov    0x10(%eax),%edx
80104a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a2e:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104a31:	8b 45 08             	mov    0x8(%ebp),%eax
80104a34:	83 c0 04             	add    $0x4,%eax
80104a37:	83 ec 0c             	sub    $0xc,%esp
80104a3a:	50                   	push   %eax
80104a3b:	e8 53 01 00 00       	call   80104b93 <release>
80104a40:	83 c4 10             	add    $0x10,%esp
}
80104a43:	90                   	nop
80104a44:	c9                   	leave  
80104a45:	c3                   	ret    

80104a46 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104a46:	55                   	push   %ebp
80104a47:	89 e5                	mov    %esp,%ebp
80104a49:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4f:	83 c0 04             	add    $0x4,%eax
80104a52:	83 ec 0c             	sub    $0xc,%esp
80104a55:	50                   	push   %eax
80104a56:	e8 ca 00 00 00       	call   80104b25 <acquire>
80104a5b:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a61:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104a67:	8b 45 08             	mov    0x8(%ebp),%eax
80104a6a:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104a71:	83 ec 0c             	sub    $0xc,%esp
80104a74:	ff 75 08             	push   0x8(%ebp)
80104a77:	e8 39 fd ff ff       	call   801047b5 <wakeup>
80104a7c:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a82:	83 c0 04             	add    $0x4,%eax
80104a85:	83 ec 0c             	sub    $0xc,%esp
80104a88:	50                   	push   %eax
80104a89:	e8 05 01 00 00       	call   80104b93 <release>
80104a8e:	83 c4 10             	add    $0x10,%esp
}
80104a91:	90                   	nop
80104a92:	c9                   	leave  
80104a93:	c3                   	ret    

80104a94 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104a94:	55                   	push   %ebp
80104a95:	89 e5                	mov    %esp,%ebp
80104a97:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a9d:	83 c0 04             	add    $0x4,%eax
80104aa0:	83 ec 0c             	sub    $0xc,%esp
80104aa3:	50                   	push   %eax
80104aa4:	e8 7c 00 00 00       	call   80104b25 <acquire>
80104aa9:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104aac:	8b 45 08             	mov    0x8(%ebp),%eax
80104aaf:	8b 00                	mov    (%eax),%eax
80104ab1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab7:	83 c0 04             	add    $0x4,%eax
80104aba:	83 ec 0c             	sub    $0xc,%esp
80104abd:	50                   	push   %eax
80104abe:	e8 d0 00 00 00       	call   80104b93 <release>
80104ac3:	83 c4 10             	add    $0x10,%esp
  return r;
80104ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104ac9:	c9                   	leave  
80104aca:	c3                   	ret    

80104acb <readeflags>:
{
80104acb:	55                   	push   %ebp
80104acc:	89 e5                	mov    %esp,%ebp
80104ace:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104ad1:	9c                   	pushf  
80104ad2:	58                   	pop    %eax
80104ad3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104ad6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ad9:	c9                   	leave  
80104ada:	c3                   	ret    

80104adb <cli>:
{
80104adb:	55                   	push   %ebp
80104adc:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104ade:	fa                   	cli    
}
80104adf:	90                   	nop
80104ae0:	5d                   	pop    %ebp
80104ae1:	c3                   	ret    

80104ae2 <sti>:
{
80104ae2:	55                   	push   %ebp
80104ae3:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104ae5:	fb                   	sti    
}
80104ae6:	90                   	nop
80104ae7:	5d                   	pop    %ebp
80104ae8:	c3                   	ret    

80104ae9 <xchg>:
{
80104ae9:	55                   	push   %ebp
80104aea:	89 e5                	mov    %esp,%ebp
80104aec:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104aef:	8b 55 08             	mov    0x8(%ebp),%edx
80104af2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104af8:	f0 87 02             	lock xchg %eax,(%edx)
80104afb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104afe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b01:	c9                   	leave  
80104b02:	c3                   	ret    

80104b03 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104b03:	55                   	push   %ebp
80104b04:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104b06:	8b 45 08             	mov    0x8(%ebp),%eax
80104b09:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b0c:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104b0f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b12:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104b18:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104b22:	90                   	nop
80104b23:	5d                   	pop    %ebp
80104b24:	c3                   	ret    

80104b25 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104b25:	55                   	push   %ebp
80104b26:	89 e5                	mov    %esp,%ebp
80104b28:	53                   	push   %ebx
80104b29:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104b2c:	e8 5f 01 00 00       	call   80104c90 <pushcli>
  if(holding(lk)){
80104b31:	8b 45 08             	mov    0x8(%ebp),%eax
80104b34:	83 ec 0c             	sub    $0xc,%esp
80104b37:	50                   	push   %eax
80104b38:	e8 23 01 00 00       	call   80104c60 <holding>
80104b3d:	83 c4 10             	add    $0x10,%esp
80104b40:	85 c0                	test   %eax,%eax
80104b42:	74 0d                	je     80104b51 <acquire+0x2c>
    panic("acquire");
80104b44:	83 ec 0c             	sub    $0xc,%esp
80104b47:	68 2a ab 10 80       	push   $0x8010ab2a
80104b4c:	e8 58 ba ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104b51:	90                   	nop
80104b52:	8b 45 08             	mov    0x8(%ebp),%eax
80104b55:	83 ec 08             	sub    $0x8,%esp
80104b58:	6a 01                	push   $0x1
80104b5a:	50                   	push   %eax
80104b5b:	e8 89 ff ff ff       	call   80104ae9 <xchg>
80104b60:	83 c4 10             	add    $0x10,%esp
80104b63:	85 c0                	test   %eax,%eax
80104b65:	75 eb                	jne    80104b52 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104b67:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104b6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104b6f:	e8 44 ee ff ff       	call   801039b8 <mycpu>
80104b74:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104b77:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7a:	83 c0 0c             	add    $0xc,%eax
80104b7d:	83 ec 08             	sub    $0x8,%esp
80104b80:	50                   	push   %eax
80104b81:	8d 45 08             	lea    0x8(%ebp),%eax
80104b84:	50                   	push   %eax
80104b85:	e8 5b 00 00 00       	call   80104be5 <getcallerpcs>
80104b8a:	83 c4 10             	add    $0x10,%esp
}
80104b8d:	90                   	nop
80104b8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b91:	c9                   	leave  
80104b92:	c3                   	ret    

80104b93 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104b93:	55                   	push   %ebp
80104b94:	89 e5                	mov    %esp,%ebp
80104b96:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104b99:	83 ec 0c             	sub    $0xc,%esp
80104b9c:	ff 75 08             	push   0x8(%ebp)
80104b9f:	e8 bc 00 00 00       	call   80104c60 <holding>
80104ba4:	83 c4 10             	add    $0x10,%esp
80104ba7:	85 c0                	test   %eax,%eax
80104ba9:	75 0d                	jne    80104bb8 <release+0x25>
    panic("release");
80104bab:	83 ec 0c             	sub    $0xc,%esp
80104bae:	68 32 ab 10 80       	push   $0x8010ab32
80104bb3:	e8 f1 b9 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104bb8:	8b 45 08             	mov    0x8(%ebp),%eax
80104bbb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104bcc:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104bd1:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd4:	8b 55 08             	mov    0x8(%ebp),%edx
80104bd7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104bdd:	e8 fb 00 00 00       	call   80104cdd <popcli>
}
80104be2:	90                   	nop
80104be3:	c9                   	leave  
80104be4:	c3                   	ret    

80104be5 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104be5:	55                   	push   %ebp
80104be6:	89 e5                	mov    %esp,%ebp
80104be8:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104beb:	8b 45 08             	mov    0x8(%ebp),%eax
80104bee:	83 e8 08             	sub    $0x8,%eax
80104bf1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104bf4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104bfb:	eb 38                	jmp    80104c35 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104bfd:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104c01:	74 53                	je     80104c56 <getcallerpcs+0x71>
80104c03:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104c0a:	76 4a                	jbe    80104c56 <getcallerpcs+0x71>
80104c0c:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104c10:	74 44                	je     80104c56 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104c12:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c15:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c1f:	01 c2                	add    %eax,%edx
80104c21:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c24:	8b 40 04             	mov    0x4(%eax),%eax
80104c27:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104c29:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c2c:	8b 00                	mov    (%eax),%eax
80104c2e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104c31:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c35:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c39:	7e c2                	jle    80104bfd <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104c3b:	eb 19                	jmp    80104c56 <getcallerpcs+0x71>
    pcs[i] = 0;
80104c3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c40:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c47:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c4a:	01 d0                	add    %edx,%eax
80104c4c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104c52:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c56:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c5a:	7e e1                	jle    80104c3d <getcallerpcs+0x58>
}
80104c5c:	90                   	nop
80104c5d:	90                   	nop
80104c5e:	c9                   	leave  
80104c5f:	c3                   	ret    

80104c60 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104c60:	55                   	push   %ebp
80104c61:	89 e5                	mov    %esp,%ebp
80104c63:	53                   	push   %ebx
80104c64:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104c67:	8b 45 08             	mov    0x8(%ebp),%eax
80104c6a:	8b 00                	mov    (%eax),%eax
80104c6c:	85 c0                	test   %eax,%eax
80104c6e:	74 16                	je     80104c86 <holding+0x26>
80104c70:	8b 45 08             	mov    0x8(%ebp),%eax
80104c73:	8b 58 08             	mov    0x8(%eax),%ebx
80104c76:	e8 3d ed ff ff       	call   801039b8 <mycpu>
80104c7b:	39 c3                	cmp    %eax,%ebx
80104c7d:	75 07                	jne    80104c86 <holding+0x26>
80104c7f:	b8 01 00 00 00       	mov    $0x1,%eax
80104c84:	eb 05                	jmp    80104c8b <holding+0x2b>
80104c86:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c8e:	c9                   	leave  
80104c8f:	c3                   	ret    

80104c90 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104c90:	55                   	push   %ebp
80104c91:	89 e5                	mov    %esp,%ebp
80104c93:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104c96:	e8 30 fe ff ff       	call   80104acb <readeflags>
80104c9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104c9e:	e8 38 fe ff ff       	call   80104adb <cli>
  if(mycpu()->ncli == 0)
80104ca3:	e8 10 ed ff ff       	call   801039b8 <mycpu>
80104ca8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104cae:	85 c0                	test   %eax,%eax
80104cb0:	75 14                	jne    80104cc6 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104cb2:	e8 01 ed ff ff       	call   801039b8 <mycpu>
80104cb7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cba:	81 e2 00 02 00 00    	and    $0x200,%edx
80104cc0:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104cc6:	e8 ed ec ff ff       	call   801039b8 <mycpu>
80104ccb:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104cd1:	83 c2 01             	add    $0x1,%edx
80104cd4:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104cda:	90                   	nop
80104cdb:	c9                   	leave  
80104cdc:	c3                   	ret    

80104cdd <popcli>:

void
popcli(void)
{
80104cdd:	55                   	push   %ebp
80104cde:	89 e5                	mov    %esp,%ebp
80104ce0:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104ce3:	e8 e3 fd ff ff       	call   80104acb <readeflags>
80104ce8:	25 00 02 00 00       	and    $0x200,%eax
80104ced:	85 c0                	test   %eax,%eax
80104cef:	74 0d                	je     80104cfe <popcli+0x21>
    panic("popcli - interruptible");
80104cf1:	83 ec 0c             	sub    $0xc,%esp
80104cf4:	68 3a ab 10 80       	push   $0x8010ab3a
80104cf9:	e8 ab b8 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104cfe:	e8 b5 ec ff ff       	call   801039b8 <mycpu>
80104d03:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d09:	83 ea 01             	sub    $0x1,%edx
80104d0c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104d12:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d18:	85 c0                	test   %eax,%eax
80104d1a:	79 0d                	jns    80104d29 <popcli+0x4c>
    panic("popcli");
80104d1c:	83 ec 0c             	sub    $0xc,%esp
80104d1f:	68 51 ab 10 80       	push   $0x8010ab51
80104d24:	e8 80 b8 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104d29:	e8 8a ec ff ff       	call   801039b8 <mycpu>
80104d2e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d34:	85 c0                	test   %eax,%eax
80104d36:	75 14                	jne    80104d4c <popcli+0x6f>
80104d38:	e8 7b ec ff ff       	call   801039b8 <mycpu>
80104d3d:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104d43:	85 c0                	test   %eax,%eax
80104d45:	74 05                	je     80104d4c <popcli+0x6f>
    sti();
80104d47:	e8 96 fd ff ff       	call   80104ae2 <sti>
}
80104d4c:	90                   	nop
80104d4d:	c9                   	leave  
80104d4e:	c3                   	ret    

80104d4f <stosb>:
{
80104d4f:	55                   	push   %ebp
80104d50:	89 e5                	mov    %esp,%ebp
80104d52:	57                   	push   %edi
80104d53:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104d54:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d57:	8b 55 10             	mov    0x10(%ebp),%edx
80104d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d5d:	89 cb                	mov    %ecx,%ebx
80104d5f:	89 df                	mov    %ebx,%edi
80104d61:	89 d1                	mov    %edx,%ecx
80104d63:	fc                   	cld    
80104d64:	f3 aa                	rep stos %al,%es:(%edi)
80104d66:	89 ca                	mov    %ecx,%edx
80104d68:	89 fb                	mov    %edi,%ebx
80104d6a:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d6d:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d70:	90                   	nop
80104d71:	5b                   	pop    %ebx
80104d72:	5f                   	pop    %edi
80104d73:	5d                   	pop    %ebp
80104d74:	c3                   	ret    

80104d75 <stosl>:
{
80104d75:	55                   	push   %ebp
80104d76:	89 e5                	mov    %esp,%ebp
80104d78:	57                   	push   %edi
80104d79:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104d7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d7d:	8b 55 10             	mov    0x10(%ebp),%edx
80104d80:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d83:	89 cb                	mov    %ecx,%ebx
80104d85:	89 df                	mov    %ebx,%edi
80104d87:	89 d1                	mov    %edx,%ecx
80104d89:	fc                   	cld    
80104d8a:	f3 ab                	rep stos %eax,%es:(%edi)
80104d8c:	89 ca                	mov    %ecx,%edx
80104d8e:	89 fb                	mov    %edi,%ebx
80104d90:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d93:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d96:	90                   	nop
80104d97:	5b                   	pop    %ebx
80104d98:	5f                   	pop    %edi
80104d99:	5d                   	pop    %ebp
80104d9a:	c3                   	ret    

80104d9b <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104d9b:	55                   	push   %ebp
80104d9c:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104d9e:	8b 45 08             	mov    0x8(%ebp),%eax
80104da1:	83 e0 03             	and    $0x3,%eax
80104da4:	85 c0                	test   %eax,%eax
80104da6:	75 43                	jne    80104deb <memset+0x50>
80104da8:	8b 45 10             	mov    0x10(%ebp),%eax
80104dab:	83 e0 03             	and    $0x3,%eax
80104dae:	85 c0                	test   %eax,%eax
80104db0:	75 39                	jne    80104deb <memset+0x50>
    c &= 0xFF;
80104db2:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104db9:	8b 45 10             	mov    0x10(%ebp),%eax
80104dbc:	c1 e8 02             	shr    $0x2,%eax
80104dbf:	89 c2                	mov    %eax,%edx
80104dc1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dc4:	c1 e0 18             	shl    $0x18,%eax
80104dc7:	89 c1                	mov    %eax,%ecx
80104dc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dcc:	c1 e0 10             	shl    $0x10,%eax
80104dcf:	09 c1                	or     %eax,%ecx
80104dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dd4:	c1 e0 08             	shl    $0x8,%eax
80104dd7:	09 c8                	or     %ecx,%eax
80104dd9:	0b 45 0c             	or     0xc(%ebp),%eax
80104ddc:	52                   	push   %edx
80104ddd:	50                   	push   %eax
80104dde:	ff 75 08             	push   0x8(%ebp)
80104de1:	e8 8f ff ff ff       	call   80104d75 <stosl>
80104de6:	83 c4 0c             	add    $0xc,%esp
80104de9:	eb 12                	jmp    80104dfd <memset+0x62>
  } else
    stosb(dst, c, n);
80104deb:	8b 45 10             	mov    0x10(%ebp),%eax
80104dee:	50                   	push   %eax
80104def:	ff 75 0c             	push   0xc(%ebp)
80104df2:	ff 75 08             	push   0x8(%ebp)
80104df5:	e8 55 ff ff ff       	call   80104d4f <stosb>
80104dfa:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104dfd:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e00:	c9                   	leave  
80104e01:	c3                   	ret    

80104e02 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104e02:	55                   	push   %ebp
80104e03:	89 e5                	mov    %esp,%ebp
80104e05:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104e08:	8b 45 08             	mov    0x8(%ebp),%eax
80104e0b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e11:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104e14:	eb 30                	jmp    80104e46 <memcmp+0x44>
    if(*s1 != *s2)
80104e16:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e19:	0f b6 10             	movzbl (%eax),%edx
80104e1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e1f:	0f b6 00             	movzbl (%eax),%eax
80104e22:	38 c2                	cmp    %al,%dl
80104e24:	74 18                	je     80104e3e <memcmp+0x3c>
      return *s1 - *s2;
80104e26:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e29:	0f b6 00             	movzbl (%eax),%eax
80104e2c:	0f b6 d0             	movzbl %al,%edx
80104e2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e32:	0f b6 00             	movzbl (%eax),%eax
80104e35:	0f b6 c8             	movzbl %al,%ecx
80104e38:	89 d0                	mov    %edx,%eax
80104e3a:	29 c8                	sub    %ecx,%eax
80104e3c:	eb 1a                	jmp    80104e58 <memcmp+0x56>
    s1++, s2++;
80104e3e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104e42:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104e46:	8b 45 10             	mov    0x10(%ebp),%eax
80104e49:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e4c:	89 55 10             	mov    %edx,0x10(%ebp)
80104e4f:	85 c0                	test   %eax,%eax
80104e51:	75 c3                	jne    80104e16 <memcmp+0x14>
  }

  return 0;
80104e53:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e58:	c9                   	leave  
80104e59:	c3                   	ret    

80104e5a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104e5a:	55                   	push   %ebp
80104e5b:	89 e5                	mov    %esp,%ebp
80104e5d:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104e60:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e63:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104e66:	8b 45 08             	mov    0x8(%ebp),%eax
80104e69:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104e6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e6f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e72:	73 54                	jae    80104ec8 <memmove+0x6e>
80104e74:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e77:	8b 45 10             	mov    0x10(%ebp),%eax
80104e7a:	01 d0                	add    %edx,%eax
80104e7c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104e7f:	73 47                	jae    80104ec8 <memmove+0x6e>
    s += n;
80104e81:	8b 45 10             	mov    0x10(%ebp),%eax
80104e84:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104e87:	8b 45 10             	mov    0x10(%ebp),%eax
80104e8a:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104e8d:	eb 13                	jmp    80104ea2 <memmove+0x48>
      *--d = *--s;
80104e8f:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104e93:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104e97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e9a:	0f b6 10             	movzbl (%eax),%edx
80104e9d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ea0:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104ea2:	8b 45 10             	mov    0x10(%ebp),%eax
80104ea5:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ea8:	89 55 10             	mov    %edx,0x10(%ebp)
80104eab:	85 c0                	test   %eax,%eax
80104ead:	75 e0                	jne    80104e8f <memmove+0x35>
  if(s < d && s + n > d){
80104eaf:	eb 24                	jmp    80104ed5 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104eb1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104eb4:	8d 42 01             	lea    0x1(%edx),%eax
80104eb7:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104eba:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ebd:	8d 48 01             	lea    0x1(%eax),%ecx
80104ec0:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104ec3:	0f b6 12             	movzbl (%edx),%edx
80104ec6:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104ec8:	8b 45 10             	mov    0x10(%ebp),%eax
80104ecb:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ece:	89 55 10             	mov    %edx,0x10(%ebp)
80104ed1:	85 c0                	test   %eax,%eax
80104ed3:	75 dc                	jne    80104eb1 <memmove+0x57>

  return dst;
80104ed5:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ed8:	c9                   	leave  
80104ed9:	c3                   	ret    

80104eda <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104eda:	55                   	push   %ebp
80104edb:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104edd:	ff 75 10             	push   0x10(%ebp)
80104ee0:	ff 75 0c             	push   0xc(%ebp)
80104ee3:	ff 75 08             	push   0x8(%ebp)
80104ee6:	e8 6f ff ff ff       	call   80104e5a <memmove>
80104eeb:	83 c4 0c             	add    $0xc,%esp
}
80104eee:	c9                   	leave  
80104eef:	c3                   	ret    

80104ef0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104ef0:	55                   	push   %ebp
80104ef1:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ef3:	eb 0c                	jmp    80104f01 <strncmp+0x11>
    n--, p++, q++;
80104ef5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ef9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104efd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104f01:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f05:	74 1a                	je     80104f21 <strncmp+0x31>
80104f07:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0a:	0f b6 00             	movzbl (%eax),%eax
80104f0d:	84 c0                	test   %al,%al
80104f0f:	74 10                	je     80104f21 <strncmp+0x31>
80104f11:	8b 45 08             	mov    0x8(%ebp),%eax
80104f14:	0f b6 10             	movzbl (%eax),%edx
80104f17:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f1a:	0f b6 00             	movzbl (%eax),%eax
80104f1d:	38 c2                	cmp    %al,%dl
80104f1f:	74 d4                	je     80104ef5 <strncmp+0x5>
  if(n == 0)
80104f21:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f25:	75 07                	jne    80104f2e <strncmp+0x3e>
    return 0;
80104f27:	b8 00 00 00 00       	mov    $0x0,%eax
80104f2c:	eb 16                	jmp    80104f44 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f31:	0f b6 00             	movzbl (%eax),%eax
80104f34:	0f b6 d0             	movzbl %al,%edx
80104f37:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f3a:	0f b6 00             	movzbl (%eax),%eax
80104f3d:	0f b6 c8             	movzbl %al,%ecx
80104f40:	89 d0                	mov    %edx,%eax
80104f42:	29 c8                	sub    %ecx,%eax
}
80104f44:	5d                   	pop    %ebp
80104f45:	c3                   	ret    

80104f46 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104f46:	55                   	push   %ebp
80104f47:	89 e5                	mov    %esp,%ebp
80104f49:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f4c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f4f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104f52:	90                   	nop
80104f53:	8b 45 10             	mov    0x10(%ebp),%eax
80104f56:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f59:	89 55 10             	mov    %edx,0x10(%ebp)
80104f5c:	85 c0                	test   %eax,%eax
80104f5e:	7e 2c                	jle    80104f8c <strncpy+0x46>
80104f60:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f63:	8d 42 01             	lea    0x1(%edx),%eax
80104f66:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f69:	8b 45 08             	mov    0x8(%ebp),%eax
80104f6c:	8d 48 01             	lea    0x1(%eax),%ecx
80104f6f:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104f72:	0f b6 12             	movzbl (%edx),%edx
80104f75:	88 10                	mov    %dl,(%eax)
80104f77:	0f b6 00             	movzbl (%eax),%eax
80104f7a:	84 c0                	test   %al,%al
80104f7c:	75 d5                	jne    80104f53 <strncpy+0xd>
    ;
  while(n-- > 0)
80104f7e:	eb 0c                	jmp    80104f8c <strncpy+0x46>
    *s++ = 0;
80104f80:	8b 45 08             	mov    0x8(%ebp),%eax
80104f83:	8d 50 01             	lea    0x1(%eax),%edx
80104f86:	89 55 08             	mov    %edx,0x8(%ebp)
80104f89:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104f8c:	8b 45 10             	mov    0x10(%ebp),%eax
80104f8f:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f92:	89 55 10             	mov    %edx,0x10(%ebp)
80104f95:	85 c0                	test   %eax,%eax
80104f97:	7f e7                	jg     80104f80 <strncpy+0x3a>
  return os;
80104f99:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f9c:	c9                   	leave  
80104f9d:	c3                   	ret    

80104f9e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104f9e:	55                   	push   %ebp
80104f9f:	89 e5                	mov    %esp,%ebp
80104fa1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104faa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fae:	7f 05                	jg     80104fb5 <safestrcpy+0x17>
    return os;
80104fb0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fb3:	eb 32                	jmp    80104fe7 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104fb5:	90                   	nop
80104fb6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104fba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fbe:	7e 1e                	jle    80104fde <safestrcpy+0x40>
80104fc0:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fc3:	8d 42 01             	lea    0x1(%edx),%eax
80104fc6:	89 45 0c             	mov    %eax,0xc(%ebp)
80104fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80104fcc:	8d 48 01             	lea    0x1(%eax),%ecx
80104fcf:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104fd2:	0f b6 12             	movzbl (%edx),%edx
80104fd5:	88 10                	mov    %dl,(%eax)
80104fd7:	0f b6 00             	movzbl (%eax),%eax
80104fda:	84 c0                	test   %al,%al
80104fdc:	75 d8                	jne    80104fb6 <safestrcpy+0x18>
    ;
  *s = 0;
80104fde:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe1:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104fe4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fe7:	c9                   	leave  
80104fe8:	c3                   	ret    

80104fe9 <strlen>:

int
strlen(const char *s)
{
80104fe9:	55                   	push   %ebp
80104fea:	89 e5                	mov    %esp,%ebp
80104fec:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104fef:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104ff6:	eb 04                	jmp    80104ffc <strlen+0x13>
80104ff8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104ffc:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104fff:	8b 45 08             	mov    0x8(%ebp),%eax
80105002:	01 d0                	add    %edx,%eax
80105004:	0f b6 00             	movzbl (%eax),%eax
80105007:	84 c0                	test   %al,%al
80105009:	75 ed                	jne    80104ff8 <strlen+0xf>
    ;
  return n;
8010500b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010500e:	c9                   	leave  
8010500f:	c3                   	ret    

80105010 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105010:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105014:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105018:	55                   	push   %ebp
  pushl %ebx
80105019:	53                   	push   %ebx
  pushl %esi
8010501a:	56                   	push   %esi
  pushl %edi
8010501b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010501c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010501e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105020:	5f                   	pop    %edi
  popl %esi
80105021:	5e                   	pop    %esi
  popl %ebx
80105022:	5b                   	pop    %ebx
  popl %ebp
80105023:	5d                   	pop    %ebp
  ret
80105024:	c3                   	ret    

80105025 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105025:	55                   	push   %ebp
80105026:	89 e5                	mov    %esp,%ebp
80105028:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010502b:	e8 00 ea ff ff       	call   80103a30 <myproc>
80105030:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105036:	8b 00                	mov    (%eax),%eax
80105038:	39 45 08             	cmp    %eax,0x8(%ebp)
8010503b:	73 0f                	jae    8010504c <fetchint+0x27>
8010503d:	8b 45 08             	mov    0x8(%ebp),%eax
80105040:	8d 50 04             	lea    0x4(%eax),%edx
80105043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105046:	8b 00                	mov    (%eax),%eax
80105048:	39 c2                	cmp    %eax,%edx
8010504a:	76 07                	jbe    80105053 <fetchint+0x2e>
    return -1;
8010504c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105051:	eb 0f                	jmp    80105062 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105053:	8b 45 08             	mov    0x8(%ebp),%eax
80105056:	8b 10                	mov    (%eax),%edx
80105058:	8b 45 0c             	mov    0xc(%ebp),%eax
8010505b:	89 10                	mov    %edx,(%eax)
  return 0;
8010505d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105062:	c9                   	leave  
80105063:	c3                   	ret    

80105064 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105064:	55                   	push   %ebp
80105065:	89 e5                	mov    %esp,%ebp
80105067:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010506a:	e8 c1 e9 ff ff       	call   80103a30 <myproc>
8010506f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105072:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105075:	8b 00                	mov    (%eax),%eax
80105077:	39 45 08             	cmp    %eax,0x8(%ebp)
8010507a:	72 07                	jb     80105083 <fetchstr+0x1f>
    return -1;
8010507c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105081:	eb 41                	jmp    801050c4 <fetchstr+0x60>
  *pp = (char*)addr;
80105083:	8b 55 08             	mov    0x8(%ebp),%edx
80105086:	8b 45 0c             	mov    0xc(%ebp),%eax
80105089:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010508b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010508e:	8b 00                	mov    (%eax),%eax
80105090:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105093:	8b 45 0c             	mov    0xc(%ebp),%eax
80105096:	8b 00                	mov    (%eax),%eax
80105098:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010509b:	eb 1a                	jmp    801050b7 <fetchstr+0x53>
    if(*s == 0)
8010509d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a0:	0f b6 00             	movzbl (%eax),%eax
801050a3:	84 c0                	test   %al,%al
801050a5:	75 0c                	jne    801050b3 <fetchstr+0x4f>
      return s - *pp;
801050a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801050aa:	8b 10                	mov    (%eax),%edx
801050ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050af:	29 d0                	sub    %edx,%eax
801050b1:	eb 11                	jmp    801050c4 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
801050b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801050bd:	72 de                	jb     8010509d <fetchstr+0x39>
  }
  return -1;
801050bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050c4:	c9                   	leave  
801050c5:	c3                   	ret    

801050c6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801050c6:	55                   	push   %ebp
801050c7:	89 e5                	mov    %esp,%ebp
801050c9:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801050cc:	e8 5f e9 ff ff       	call   80103a30 <myproc>
801050d1:	8b 40 18             	mov    0x18(%eax),%eax
801050d4:	8b 50 44             	mov    0x44(%eax),%edx
801050d7:	8b 45 08             	mov    0x8(%ebp),%eax
801050da:	c1 e0 02             	shl    $0x2,%eax
801050dd:	01 d0                	add    %edx,%eax
801050df:	83 c0 04             	add    $0x4,%eax
801050e2:	83 ec 08             	sub    $0x8,%esp
801050e5:	ff 75 0c             	push   0xc(%ebp)
801050e8:	50                   	push   %eax
801050e9:	e8 37 ff ff ff       	call   80105025 <fetchint>
801050ee:	83 c4 10             	add    $0x10,%esp
}
801050f1:	c9                   	leave  
801050f2:	c3                   	ret    

801050f3 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801050f3:	55                   	push   %ebp
801050f4:	89 e5                	mov    %esp,%ebp
801050f6:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801050f9:	e8 32 e9 ff ff       	call   80103a30 <myproc>
801050fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105101:	83 ec 08             	sub    $0x8,%esp
80105104:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105107:	50                   	push   %eax
80105108:	ff 75 08             	push   0x8(%ebp)
8010510b:	e8 b6 ff ff ff       	call   801050c6 <argint>
80105110:	83 c4 10             	add    $0x10,%esp
80105113:	85 c0                	test   %eax,%eax
80105115:	79 07                	jns    8010511e <argptr+0x2b>
    return -1;
80105117:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010511c:	eb 3b                	jmp    80105159 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010511e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105122:	78 1f                	js     80105143 <argptr+0x50>
80105124:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105127:	8b 00                	mov    (%eax),%eax
80105129:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010512c:	39 d0                	cmp    %edx,%eax
8010512e:	76 13                	jbe    80105143 <argptr+0x50>
80105130:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105133:	89 c2                	mov    %eax,%edx
80105135:	8b 45 10             	mov    0x10(%ebp),%eax
80105138:	01 c2                	add    %eax,%edx
8010513a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513d:	8b 00                	mov    (%eax),%eax
8010513f:	39 c2                	cmp    %eax,%edx
80105141:	76 07                	jbe    8010514a <argptr+0x57>
    return -1;
80105143:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105148:	eb 0f                	jmp    80105159 <argptr+0x66>
  *pp = (char*)i;
8010514a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010514d:	89 c2                	mov    %eax,%edx
8010514f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105152:	89 10                	mov    %edx,(%eax)
  return 0;
80105154:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105159:	c9                   	leave  
8010515a:	c3                   	ret    

8010515b <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010515b:	55                   	push   %ebp
8010515c:	89 e5                	mov    %esp,%ebp
8010515e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105161:	83 ec 08             	sub    $0x8,%esp
80105164:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105167:	50                   	push   %eax
80105168:	ff 75 08             	push   0x8(%ebp)
8010516b:	e8 56 ff ff ff       	call   801050c6 <argint>
80105170:	83 c4 10             	add    $0x10,%esp
80105173:	85 c0                	test   %eax,%eax
80105175:	79 07                	jns    8010517e <argstr+0x23>
    return -1;
80105177:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010517c:	eb 12                	jmp    80105190 <argstr+0x35>
  return fetchstr(addr, pp);
8010517e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105181:	83 ec 08             	sub    $0x8,%esp
80105184:	ff 75 0c             	push   0xc(%ebp)
80105187:	50                   	push   %eax
80105188:	e8 d7 fe ff ff       	call   80105064 <fetchstr>
8010518d:	83 c4 10             	add    $0x10,%esp
}
80105190:	c9                   	leave  
80105191:	c3                   	ret    

80105192 <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80105192:	55                   	push   %ebp
80105193:	89 e5                	mov    %esp,%ebp
80105195:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105198:	e8 93 e8 ff ff       	call   80103a30 <myproc>
8010519d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801051a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a3:	8b 40 18             	mov    0x18(%eax),%eax
801051a6:	8b 40 1c             	mov    0x1c(%eax),%eax
801051a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801051ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801051b0:	7e 2f                	jle    801051e1 <syscall+0x4f>
801051b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051b5:	83 f8 1b             	cmp    $0x1b,%eax
801051b8:	77 27                	ja     801051e1 <syscall+0x4f>
801051ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051bd:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801051c4:	85 c0                	test   %eax,%eax
801051c6:	74 19                	je     801051e1 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
801051c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051cb:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801051d2:	ff d0                	call   *%eax
801051d4:	89 c2                	mov    %eax,%edx
801051d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d9:	8b 40 18             	mov    0x18(%eax),%eax
801051dc:	89 50 1c             	mov    %edx,0x1c(%eax)
801051df:	eb 2c                	jmp    8010520d <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801051e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e4:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801051e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ea:	8b 40 10             	mov    0x10(%eax),%eax
801051ed:	ff 75 f0             	push   -0x10(%ebp)
801051f0:	52                   	push   %edx
801051f1:	50                   	push   %eax
801051f2:	68 58 ab 10 80       	push   $0x8010ab58
801051f7:	e8 f8 b1 ff ff       	call   801003f4 <cprintf>
801051fc:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801051ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105202:	8b 40 18             	mov    0x18(%eax),%eax
80105205:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010520c:	90                   	nop
8010520d:	90                   	nop
8010520e:	c9                   	leave  
8010520f:	c3                   	ret    

80105210 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105210:	55                   	push   %ebp
80105211:	89 e5                	mov    %esp,%ebp
80105213:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105216:	83 ec 08             	sub    $0x8,%esp
80105219:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010521c:	50                   	push   %eax
8010521d:	ff 75 08             	push   0x8(%ebp)
80105220:	e8 a1 fe ff ff       	call   801050c6 <argint>
80105225:	83 c4 10             	add    $0x10,%esp
80105228:	85 c0                	test   %eax,%eax
8010522a:	79 07                	jns    80105233 <argfd+0x23>
    return -1;
8010522c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105231:	eb 4f                	jmp    80105282 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105233:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105236:	85 c0                	test   %eax,%eax
80105238:	78 20                	js     8010525a <argfd+0x4a>
8010523a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010523d:	83 f8 0f             	cmp    $0xf,%eax
80105240:	7f 18                	jg     8010525a <argfd+0x4a>
80105242:	e8 e9 e7 ff ff       	call   80103a30 <myproc>
80105247:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010524a:	83 c2 08             	add    $0x8,%edx
8010524d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105251:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105254:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105258:	75 07                	jne    80105261 <argfd+0x51>
    return -1;
8010525a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010525f:	eb 21                	jmp    80105282 <argfd+0x72>
  if(pfd)
80105261:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105265:	74 08                	je     8010526f <argfd+0x5f>
    *pfd = fd;
80105267:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010526a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010526d:	89 10                	mov    %edx,(%eax)
  if(pf)
8010526f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105273:	74 08                	je     8010527d <argfd+0x6d>
    *pf = f;
80105275:	8b 45 10             	mov    0x10(%ebp),%eax
80105278:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010527b:	89 10                	mov    %edx,(%eax)
  return 0;
8010527d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105282:	c9                   	leave  
80105283:	c3                   	ret    

80105284 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105284:	55                   	push   %ebp
80105285:	89 e5                	mov    %esp,%ebp
80105287:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010528a:	e8 a1 e7 ff ff       	call   80103a30 <myproc>
8010528f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105292:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105299:	eb 2a                	jmp    801052c5 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
8010529b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010529e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052a1:	83 c2 08             	add    $0x8,%edx
801052a4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801052a8:	85 c0                	test   %eax,%eax
801052aa:	75 15                	jne    801052c1 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801052ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052b2:	8d 4a 08             	lea    0x8(%edx),%ecx
801052b5:	8b 55 08             	mov    0x8(%ebp),%edx
801052b8:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801052bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052bf:	eb 0f                	jmp    801052d0 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
801052c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801052c5:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801052c9:	7e d0                	jle    8010529b <fdalloc+0x17>
    }
  }
  return -1;
801052cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052d0:	c9                   	leave  
801052d1:	c3                   	ret    

801052d2 <sys_dup>:

int
sys_dup(void)
{
801052d2:	55                   	push   %ebp
801052d3:	89 e5                	mov    %esp,%ebp
801052d5:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801052d8:	83 ec 04             	sub    $0x4,%esp
801052db:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052de:	50                   	push   %eax
801052df:	6a 00                	push   $0x0
801052e1:	6a 00                	push   $0x0
801052e3:	e8 28 ff ff ff       	call   80105210 <argfd>
801052e8:	83 c4 10             	add    $0x10,%esp
801052eb:	85 c0                	test   %eax,%eax
801052ed:	79 07                	jns    801052f6 <sys_dup+0x24>
    return -1;
801052ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052f4:	eb 31                	jmp    80105327 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801052f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052f9:	83 ec 0c             	sub    $0xc,%esp
801052fc:	50                   	push   %eax
801052fd:	e8 82 ff ff ff       	call   80105284 <fdalloc>
80105302:	83 c4 10             	add    $0x10,%esp
80105305:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105308:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010530c:	79 07                	jns    80105315 <sys_dup+0x43>
    return -1;
8010530e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105313:	eb 12                	jmp    80105327 <sys_dup+0x55>
  filedup(f);
80105315:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105318:	83 ec 0c             	sub    $0xc,%esp
8010531b:	50                   	push   %eax
8010531c:	e8 29 bd ff ff       	call   8010104a <filedup>
80105321:	83 c4 10             	add    $0x10,%esp
  return fd;
80105324:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105327:	c9                   	leave  
80105328:	c3                   	ret    

80105329 <sys_read>:

int
sys_read(void)
{
80105329:	55                   	push   %ebp
8010532a:	89 e5                	mov    %esp,%ebp
8010532c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010532f:	83 ec 04             	sub    $0x4,%esp
80105332:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105335:	50                   	push   %eax
80105336:	6a 00                	push   $0x0
80105338:	6a 00                	push   $0x0
8010533a:	e8 d1 fe ff ff       	call   80105210 <argfd>
8010533f:	83 c4 10             	add    $0x10,%esp
80105342:	85 c0                	test   %eax,%eax
80105344:	78 2e                	js     80105374 <sys_read+0x4b>
80105346:	83 ec 08             	sub    $0x8,%esp
80105349:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010534c:	50                   	push   %eax
8010534d:	6a 02                	push   $0x2
8010534f:	e8 72 fd ff ff       	call   801050c6 <argint>
80105354:	83 c4 10             	add    $0x10,%esp
80105357:	85 c0                	test   %eax,%eax
80105359:	78 19                	js     80105374 <sys_read+0x4b>
8010535b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010535e:	83 ec 04             	sub    $0x4,%esp
80105361:	50                   	push   %eax
80105362:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105365:	50                   	push   %eax
80105366:	6a 01                	push   $0x1
80105368:	e8 86 fd ff ff       	call   801050f3 <argptr>
8010536d:	83 c4 10             	add    $0x10,%esp
80105370:	85 c0                	test   %eax,%eax
80105372:	79 07                	jns    8010537b <sys_read+0x52>
    return -1;
80105374:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105379:	eb 17                	jmp    80105392 <sys_read+0x69>
  return fileread(f, p, n);
8010537b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010537e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105384:	83 ec 04             	sub    $0x4,%esp
80105387:	51                   	push   %ecx
80105388:	52                   	push   %edx
80105389:	50                   	push   %eax
8010538a:	e8 4b be ff ff       	call   801011da <fileread>
8010538f:	83 c4 10             	add    $0x10,%esp
}
80105392:	c9                   	leave  
80105393:	c3                   	ret    

80105394 <sys_write>:

int
sys_write(void)
{
80105394:	55                   	push   %ebp
80105395:	89 e5                	mov    %esp,%ebp
80105397:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010539a:	83 ec 04             	sub    $0x4,%esp
8010539d:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053a0:	50                   	push   %eax
801053a1:	6a 00                	push   $0x0
801053a3:	6a 00                	push   $0x0
801053a5:	e8 66 fe ff ff       	call   80105210 <argfd>
801053aa:	83 c4 10             	add    $0x10,%esp
801053ad:	85 c0                	test   %eax,%eax
801053af:	78 2e                	js     801053df <sys_write+0x4b>
801053b1:	83 ec 08             	sub    $0x8,%esp
801053b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053b7:	50                   	push   %eax
801053b8:	6a 02                	push   $0x2
801053ba:	e8 07 fd ff ff       	call   801050c6 <argint>
801053bf:	83 c4 10             	add    $0x10,%esp
801053c2:	85 c0                	test   %eax,%eax
801053c4:	78 19                	js     801053df <sys_write+0x4b>
801053c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053c9:	83 ec 04             	sub    $0x4,%esp
801053cc:	50                   	push   %eax
801053cd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801053d0:	50                   	push   %eax
801053d1:	6a 01                	push   $0x1
801053d3:	e8 1b fd ff ff       	call   801050f3 <argptr>
801053d8:	83 c4 10             	add    $0x10,%esp
801053db:	85 c0                	test   %eax,%eax
801053dd:	79 07                	jns    801053e6 <sys_write+0x52>
    return -1;
801053df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053e4:	eb 17                	jmp    801053fd <sys_write+0x69>
  return filewrite(f, p, n);
801053e6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053e9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ef:	83 ec 04             	sub    $0x4,%esp
801053f2:	51                   	push   %ecx
801053f3:	52                   	push   %edx
801053f4:	50                   	push   %eax
801053f5:	e8 98 be ff ff       	call   80101292 <filewrite>
801053fa:	83 c4 10             	add    $0x10,%esp
}
801053fd:	c9                   	leave  
801053fe:	c3                   	ret    

801053ff <sys_close>:

int
sys_close(void)
{
801053ff:	55                   	push   %ebp
80105400:	89 e5                	mov    %esp,%ebp
80105402:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105405:	83 ec 04             	sub    $0x4,%esp
80105408:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010540b:	50                   	push   %eax
8010540c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010540f:	50                   	push   %eax
80105410:	6a 00                	push   $0x0
80105412:	e8 f9 fd ff ff       	call   80105210 <argfd>
80105417:	83 c4 10             	add    $0x10,%esp
8010541a:	85 c0                	test   %eax,%eax
8010541c:	79 07                	jns    80105425 <sys_close+0x26>
    return -1;
8010541e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105423:	eb 27                	jmp    8010544c <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105425:	e8 06 e6 ff ff       	call   80103a30 <myproc>
8010542a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010542d:	83 c2 08             	add    $0x8,%edx
80105430:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105437:	00 
  fileclose(f);
80105438:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010543b:	83 ec 0c             	sub    $0xc,%esp
8010543e:	50                   	push   %eax
8010543f:	e8 57 bc ff ff       	call   8010109b <fileclose>
80105444:	83 c4 10             	add    $0x10,%esp
  return 0;
80105447:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010544c:	c9                   	leave  
8010544d:	c3                   	ret    

8010544e <sys_fstat>:

int
sys_fstat(void)
{
8010544e:	55                   	push   %ebp
8010544f:	89 e5                	mov    %esp,%ebp
80105451:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105454:	83 ec 04             	sub    $0x4,%esp
80105457:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010545a:	50                   	push   %eax
8010545b:	6a 00                	push   $0x0
8010545d:	6a 00                	push   $0x0
8010545f:	e8 ac fd ff ff       	call   80105210 <argfd>
80105464:	83 c4 10             	add    $0x10,%esp
80105467:	85 c0                	test   %eax,%eax
80105469:	78 17                	js     80105482 <sys_fstat+0x34>
8010546b:	83 ec 04             	sub    $0x4,%esp
8010546e:	6a 14                	push   $0x14
80105470:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105473:	50                   	push   %eax
80105474:	6a 01                	push   $0x1
80105476:	e8 78 fc ff ff       	call   801050f3 <argptr>
8010547b:	83 c4 10             	add    $0x10,%esp
8010547e:	85 c0                	test   %eax,%eax
80105480:	79 07                	jns    80105489 <sys_fstat+0x3b>
    return -1;
80105482:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105487:	eb 13                	jmp    8010549c <sys_fstat+0x4e>
  return filestat(f, st);
80105489:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010548c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010548f:	83 ec 08             	sub    $0x8,%esp
80105492:	52                   	push   %edx
80105493:	50                   	push   %eax
80105494:	e8 ea bc ff ff       	call   80101183 <filestat>
80105499:	83 c4 10             	add    $0x10,%esp
}
8010549c:	c9                   	leave  
8010549d:	c3                   	ret    

8010549e <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010549e:	55                   	push   %ebp
8010549f:	89 e5                	mov    %esp,%ebp
801054a1:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801054a4:	83 ec 08             	sub    $0x8,%esp
801054a7:	8d 45 d8             	lea    -0x28(%ebp),%eax
801054aa:	50                   	push   %eax
801054ab:	6a 00                	push   $0x0
801054ad:	e8 a9 fc ff ff       	call   8010515b <argstr>
801054b2:	83 c4 10             	add    $0x10,%esp
801054b5:	85 c0                	test   %eax,%eax
801054b7:	78 15                	js     801054ce <sys_link+0x30>
801054b9:	83 ec 08             	sub    $0x8,%esp
801054bc:	8d 45 dc             	lea    -0x24(%ebp),%eax
801054bf:	50                   	push   %eax
801054c0:	6a 01                	push   $0x1
801054c2:	e8 94 fc ff ff       	call   8010515b <argstr>
801054c7:	83 c4 10             	add    $0x10,%esp
801054ca:	85 c0                	test   %eax,%eax
801054cc:	79 0a                	jns    801054d8 <sys_link+0x3a>
    return -1;
801054ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054d3:	e9 68 01 00 00       	jmp    80105640 <sys_link+0x1a2>

  begin_op();
801054d8:	e8 5f db ff ff       	call   8010303c <begin_op>
  if((ip = namei(old)) == 0){
801054dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801054e0:	83 ec 0c             	sub    $0xc,%esp
801054e3:	50                   	push   %eax
801054e4:	e8 34 d0 ff ff       	call   8010251d <namei>
801054e9:	83 c4 10             	add    $0x10,%esp
801054ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054f3:	75 0f                	jne    80105504 <sys_link+0x66>
    end_op();
801054f5:	e8 ce db ff ff       	call   801030c8 <end_op>
    return -1;
801054fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054ff:	e9 3c 01 00 00       	jmp    80105640 <sys_link+0x1a2>
  }

  ilock(ip);
80105504:	83 ec 0c             	sub    $0xc,%esp
80105507:	ff 75 f4             	push   -0xc(%ebp)
8010550a:	e8 db c4 ff ff       	call   801019ea <ilock>
8010550f:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105515:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105519:	66 83 f8 01          	cmp    $0x1,%ax
8010551d:	75 1d                	jne    8010553c <sys_link+0x9e>
    iunlockput(ip);
8010551f:	83 ec 0c             	sub    $0xc,%esp
80105522:	ff 75 f4             	push   -0xc(%ebp)
80105525:	e8 f1 c6 ff ff       	call   80101c1b <iunlockput>
8010552a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010552d:	e8 96 db ff ff       	call   801030c8 <end_op>
    return -1;
80105532:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105537:	e9 04 01 00 00       	jmp    80105640 <sys_link+0x1a2>
  }

  ip->nlink++;
8010553c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010553f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105543:	83 c0 01             	add    $0x1,%eax
80105546:	89 c2                	mov    %eax,%edx
80105548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010554b:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010554f:	83 ec 0c             	sub    $0xc,%esp
80105552:	ff 75 f4             	push   -0xc(%ebp)
80105555:	e8 b3 c2 ff ff       	call   8010180d <iupdate>
8010555a:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010555d:	83 ec 0c             	sub    $0xc,%esp
80105560:	ff 75 f4             	push   -0xc(%ebp)
80105563:	e8 95 c5 ff ff       	call   80101afd <iunlock>
80105568:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010556b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010556e:	83 ec 08             	sub    $0x8,%esp
80105571:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105574:	52                   	push   %edx
80105575:	50                   	push   %eax
80105576:	e8 be cf ff ff       	call   80102539 <nameiparent>
8010557b:	83 c4 10             	add    $0x10,%esp
8010557e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105581:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105585:	74 71                	je     801055f8 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105587:	83 ec 0c             	sub    $0xc,%esp
8010558a:	ff 75 f0             	push   -0x10(%ebp)
8010558d:	e8 58 c4 ff ff       	call   801019ea <ilock>
80105592:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105595:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105598:	8b 10                	mov    (%eax),%edx
8010559a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010559d:	8b 00                	mov    (%eax),%eax
8010559f:	39 c2                	cmp    %eax,%edx
801055a1:	75 1d                	jne    801055c0 <sys_link+0x122>
801055a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a6:	8b 40 04             	mov    0x4(%eax),%eax
801055a9:	83 ec 04             	sub    $0x4,%esp
801055ac:	50                   	push   %eax
801055ad:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801055b0:	50                   	push   %eax
801055b1:	ff 75 f0             	push   -0x10(%ebp)
801055b4:	e8 cd cc ff ff       	call   80102286 <dirlink>
801055b9:	83 c4 10             	add    $0x10,%esp
801055bc:	85 c0                	test   %eax,%eax
801055be:	79 10                	jns    801055d0 <sys_link+0x132>
    iunlockput(dp);
801055c0:	83 ec 0c             	sub    $0xc,%esp
801055c3:	ff 75 f0             	push   -0x10(%ebp)
801055c6:	e8 50 c6 ff ff       	call   80101c1b <iunlockput>
801055cb:	83 c4 10             	add    $0x10,%esp
    goto bad;
801055ce:	eb 29                	jmp    801055f9 <sys_link+0x15b>
  }
  iunlockput(dp);
801055d0:	83 ec 0c             	sub    $0xc,%esp
801055d3:	ff 75 f0             	push   -0x10(%ebp)
801055d6:	e8 40 c6 ff ff       	call   80101c1b <iunlockput>
801055db:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801055de:	83 ec 0c             	sub    $0xc,%esp
801055e1:	ff 75 f4             	push   -0xc(%ebp)
801055e4:	e8 62 c5 ff ff       	call   80101b4b <iput>
801055e9:	83 c4 10             	add    $0x10,%esp

  end_op();
801055ec:	e8 d7 da ff ff       	call   801030c8 <end_op>

  return 0;
801055f1:	b8 00 00 00 00       	mov    $0x0,%eax
801055f6:	eb 48                	jmp    80105640 <sys_link+0x1a2>
    goto bad;
801055f8:	90                   	nop

bad:
  ilock(ip);
801055f9:	83 ec 0c             	sub    $0xc,%esp
801055fc:	ff 75 f4             	push   -0xc(%ebp)
801055ff:	e8 e6 c3 ff ff       	call   801019ea <ilock>
80105604:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010560e:	83 e8 01             	sub    $0x1,%eax
80105611:	89 c2                	mov    %eax,%edx
80105613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105616:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010561a:	83 ec 0c             	sub    $0xc,%esp
8010561d:	ff 75 f4             	push   -0xc(%ebp)
80105620:	e8 e8 c1 ff ff       	call   8010180d <iupdate>
80105625:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105628:	83 ec 0c             	sub    $0xc,%esp
8010562b:	ff 75 f4             	push   -0xc(%ebp)
8010562e:	e8 e8 c5 ff ff       	call   80101c1b <iunlockput>
80105633:	83 c4 10             	add    $0x10,%esp
  end_op();
80105636:	e8 8d da ff ff       	call   801030c8 <end_op>
  return -1;
8010563b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105640:	c9                   	leave  
80105641:	c3                   	ret    

80105642 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105642:	55                   	push   %ebp
80105643:	89 e5                	mov    %esp,%ebp
80105645:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105648:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010564f:	eb 40                	jmp    80105691 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105654:	6a 10                	push   $0x10
80105656:	50                   	push   %eax
80105657:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010565a:	50                   	push   %eax
8010565b:	ff 75 08             	push   0x8(%ebp)
8010565e:	e8 73 c8 ff ff       	call   80101ed6 <readi>
80105663:	83 c4 10             	add    $0x10,%esp
80105666:	83 f8 10             	cmp    $0x10,%eax
80105669:	74 0d                	je     80105678 <isdirempty+0x36>
      panic("isdirempty: readi");
8010566b:	83 ec 0c             	sub    $0xc,%esp
8010566e:	68 74 ab 10 80       	push   $0x8010ab74
80105673:	e8 31 af ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105678:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010567c:	66 85 c0             	test   %ax,%ax
8010567f:	74 07                	je     80105688 <isdirempty+0x46>
      return 0;
80105681:	b8 00 00 00 00       	mov    $0x0,%eax
80105686:	eb 1b                	jmp    801056a3 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568b:	83 c0 10             	add    $0x10,%eax
8010568e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105691:	8b 45 08             	mov    0x8(%ebp),%eax
80105694:	8b 50 58             	mov    0x58(%eax),%edx
80105697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010569a:	39 c2                	cmp    %eax,%edx
8010569c:	77 b3                	ja     80105651 <isdirempty+0xf>
  }
  return 1;
8010569e:	b8 01 00 00 00       	mov    $0x1,%eax
}
801056a3:	c9                   	leave  
801056a4:	c3                   	ret    

801056a5 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801056a5:	55                   	push   %ebp
801056a6:	89 e5                	mov    %esp,%ebp
801056a8:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801056ab:	83 ec 08             	sub    $0x8,%esp
801056ae:	8d 45 cc             	lea    -0x34(%ebp),%eax
801056b1:	50                   	push   %eax
801056b2:	6a 00                	push   $0x0
801056b4:	e8 a2 fa ff ff       	call   8010515b <argstr>
801056b9:	83 c4 10             	add    $0x10,%esp
801056bc:	85 c0                	test   %eax,%eax
801056be:	79 0a                	jns    801056ca <sys_unlink+0x25>
    return -1;
801056c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c5:	e9 bf 01 00 00       	jmp    80105889 <sys_unlink+0x1e4>

  begin_op();
801056ca:	e8 6d d9 ff ff       	call   8010303c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801056cf:	8b 45 cc             	mov    -0x34(%ebp),%eax
801056d2:	83 ec 08             	sub    $0x8,%esp
801056d5:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801056d8:	52                   	push   %edx
801056d9:	50                   	push   %eax
801056da:	e8 5a ce ff ff       	call   80102539 <nameiparent>
801056df:	83 c4 10             	add    $0x10,%esp
801056e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056e9:	75 0f                	jne    801056fa <sys_unlink+0x55>
    end_op();
801056eb:	e8 d8 d9 ff ff       	call   801030c8 <end_op>
    return -1;
801056f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f5:	e9 8f 01 00 00       	jmp    80105889 <sys_unlink+0x1e4>
  }

  ilock(dp);
801056fa:	83 ec 0c             	sub    $0xc,%esp
801056fd:	ff 75 f4             	push   -0xc(%ebp)
80105700:	e8 e5 c2 ff ff       	call   801019ea <ilock>
80105705:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105708:	83 ec 08             	sub    $0x8,%esp
8010570b:	68 86 ab 10 80       	push   $0x8010ab86
80105710:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105713:	50                   	push   %eax
80105714:	e8 98 ca ff ff       	call   801021b1 <namecmp>
80105719:	83 c4 10             	add    $0x10,%esp
8010571c:	85 c0                	test   %eax,%eax
8010571e:	0f 84 49 01 00 00    	je     8010586d <sys_unlink+0x1c8>
80105724:	83 ec 08             	sub    $0x8,%esp
80105727:	68 88 ab 10 80       	push   $0x8010ab88
8010572c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010572f:	50                   	push   %eax
80105730:	e8 7c ca ff ff       	call   801021b1 <namecmp>
80105735:	83 c4 10             	add    $0x10,%esp
80105738:	85 c0                	test   %eax,%eax
8010573a:	0f 84 2d 01 00 00    	je     8010586d <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105740:	83 ec 04             	sub    $0x4,%esp
80105743:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105746:	50                   	push   %eax
80105747:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010574a:	50                   	push   %eax
8010574b:	ff 75 f4             	push   -0xc(%ebp)
8010574e:	e8 79 ca ff ff       	call   801021cc <dirlookup>
80105753:	83 c4 10             	add    $0x10,%esp
80105756:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105759:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010575d:	0f 84 0d 01 00 00    	je     80105870 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105763:	83 ec 0c             	sub    $0xc,%esp
80105766:	ff 75 f0             	push   -0x10(%ebp)
80105769:	e8 7c c2 ff ff       	call   801019ea <ilock>
8010576e:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105771:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105774:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105778:	66 85 c0             	test   %ax,%ax
8010577b:	7f 0d                	jg     8010578a <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010577d:	83 ec 0c             	sub    $0xc,%esp
80105780:	68 8b ab 10 80       	push   $0x8010ab8b
80105785:	e8 1f ae ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010578a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010578d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105791:	66 83 f8 01          	cmp    $0x1,%ax
80105795:	75 25                	jne    801057bc <sys_unlink+0x117>
80105797:	83 ec 0c             	sub    $0xc,%esp
8010579a:	ff 75 f0             	push   -0x10(%ebp)
8010579d:	e8 a0 fe ff ff       	call   80105642 <isdirempty>
801057a2:	83 c4 10             	add    $0x10,%esp
801057a5:	85 c0                	test   %eax,%eax
801057a7:	75 13                	jne    801057bc <sys_unlink+0x117>
    iunlockput(ip);
801057a9:	83 ec 0c             	sub    $0xc,%esp
801057ac:	ff 75 f0             	push   -0x10(%ebp)
801057af:	e8 67 c4 ff ff       	call   80101c1b <iunlockput>
801057b4:	83 c4 10             	add    $0x10,%esp
    goto bad;
801057b7:	e9 b5 00 00 00       	jmp    80105871 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801057bc:	83 ec 04             	sub    $0x4,%esp
801057bf:	6a 10                	push   $0x10
801057c1:	6a 00                	push   $0x0
801057c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057c6:	50                   	push   %eax
801057c7:	e8 cf f5 ff ff       	call   80104d9b <memset>
801057cc:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801057cf:	8b 45 c8             	mov    -0x38(%ebp),%eax
801057d2:	6a 10                	push   $0x10
801057d4:	50                   	push   %eax
801057d5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057d8:	50                   	push   %eax
801057d9:	ff 75 f4             	push   -0xc(%ebp)
801057dc:	e8 4a c8 ff ff       	call   8010202b <writei>
801057e1:	83 c4 10             	add    $0x10,%esp
801057e4:	83 f8 10             	cmp    $0x10,%eax
801057e7:	74 0d                	je     801057f6 <sys_unlink+0x151>
    panic("unlink: writei");
801057e9:	83 ec 0c             	sub    $0xc,%esp
801057ec:	68 9d ab 10 80       	push   $0x8010ab9d
801057f1:	e8 b3 ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801057f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801057fd:	66 83 f8 01          	cmp    $0x1,%ax
80105801:	75 21                	jne    80105824 <sys_unlink+0x17f>
    dp->nlink--;
80105803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105806:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010580a:	83 e8 01             	sub    $0x1,%eax
8010580d:	89 c2                	mov    %eax,%edx
8010580f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105812:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105816:	83 ec 0c             	sub    $0xc,%esp
80105819:	ff 75 f4             	push   -0xc(%ebp)
8010581c:	e8 ec bf ff ff       	call   8010180d <iupdate>
80105821:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105824:	83 ec 0c             	sub    $0xc,%esp
80105827:	ff 75 f4             	push   -0xc(%ebp)
8010582a:	e8 ec c3 ff ff       	call   80101c1b <iunlockput>
8010582f:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105832:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105835:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105839:	83 e8 01             	sub    $0x1,%eax
8010583c:	89 c2                	mov    %eax,%edx
8010583e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105841:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105845:	83 ec 0c             	sub    $0xc,%esp
80105848:	ff 75 f0             	push   -0x10(%ebp)
8010584b:	e8 bd bf ff ff       	call   8010180d <iupdate>
80105850:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105853:	83 ec 0c             	sub    $0xc,%esp
80105856:	ff 75 f0             	push   -0x10(%ebp)
80105859:	e8 bd c3 ff ff       	call   80101c1b <iunlockput>
8010585e:	83 c4 10             	add    $0x10,%esp

  end_op();
80105861:	e8 62 d8 ff ff       	call   801030c8 <end_op>

  return 0;
80105866:	b8 00 00 00 00       	mov    $0x0,%eax
8010586b:	eb 1c                	jmp    80105889 <sys_unlink+0x1e4>
    goto bad;
8010586d:	90                   	nop
8010586e:	eb 01                	jmp    80105871 <sys_unlink+0x1cc>
    goto bad;
80105870:	90                   	nop

bad:
  iunlockput(dp);
80105871:	83 ec 0c             	sub    $0xc,%esp
80105874:	ff 75 f4             	push   -0xc(%ebp)
80105877:	e8 9f c3 ff ff       	call   80101c1b <iunlockput>
8010587c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010587f:	e8 44 d8 ff ff       	call   801030c8 <end_op>
  return -1;
80105884:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105889:	c9                   	leave  
8010588a:	c3                   	ret    

8010588b <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010588b:	55                   	push   %ebp
8010588c:	89 e5                	mov    %esp,%ebp
8010588e:	83 ec 38             	sub    $0x38,%esp
80105891:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105894:	8b 55 10             	mov    0x10(%ebp),%edx
80105897:	8b 45 14             	mov    0x14(%ebp),%eax
8010589a:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010589e:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801058a2:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801058a6:	83 ec 08             	sub    $0x8,%esp
801058a9:	8d 45 de             	lea    -0x22(%ebp),%eax
801058ac:	50                   	push   %eax
801058ad:	ff 75 08             	push   0x8(%ebp)
801058b0:	e8 84 cc ff ff       	call   80102539 <nameiparent>
801058b5:	83 c4 10             	add    $0x10,%esp
801058b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058bf:	75 0a                	jne    801058cb <create+0x40>
    return 0;
801058c1:	b8 00 00 00 00       	mov    $0x0,%eax
801058c6:	e9 90 01 00 00       	jmp    80105a5b <create+0x1d0>
  ilock(dp);
801058cb:	83 ec 0c             	sub    $0xc,%esp
801058ce:	ff 75 f4             	push   -0xc(%ebp)
801058d1:	e8 14 c1 ff ff       	call   801019ea <ilock>
801058d6:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801058d9:	83 ec 04             	sub    $0x4,%esp
801058dc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058df:	50                   	push   %eax
801058e0:	8d 45 de             	lea    -0x22(%ebp),%eax
801058e3:	50                   	push   %eax
801058e4:	ff 75 f4             	push   -0xc(%ebp)
801058e7:	e8 e0 c8 ff ff       	call   801021cc <dirlookup>
801058ec:	83 c4 10             	add    $0x10,%esp
801058ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
801058f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058f6:	74 50                	je     80105948 <create+0xbd>
    iunlockput(dp);
801058f8:	83 ec 0c             	sub    $0xc,%esp
801058fb:	ff 75 f4             	push   -0xc(%ebp)
801058fe:	e8 18 c3 ff ff       	call   80101c1b <iunlockput>
80105903:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105906:	83 ec 0c             	sub    $0xc,%esp
80105909:	ff 75 f0             	push   -0x10(%ebp)
8010590c:	e8 d9 c0 ff ff       	call   801019ea <ilock>
80105911:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105914:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105919:	75 15                	jne    80105930 <create+0xa5>
8010591b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010591e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105922:	66 83 f8 02          	cmp    $0x2,%ax
80105926:	75 08                	jne    80105930 <create+0xa5>
      return ip;
80105928:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010592b:	e9 2b 01 00 00       	jmp    80105a5b <create+0x1d0>
    iunlockput(ip);
80105930:	83 ec 0c             	sub    $0xc,%esp
80105933:	ff 75 f0             	push   -0x10(%ebp)
80105936:	e8 e0 c2 ff ff       	call   80101c1b <iunlockput>
8010593b:	83 c4 10             	add    $0x10,%esp
    return 0;
8010593e:	b8 00 00 00 00       	mov    $0x0,%eax
80105943:	e9 13 01 00 00       	jmp    80105a5b <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105948:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010594c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594f:	8b 00                	mov    (%eax),%eax
80105951:	83 ec 08             	sub    $0x8,%esp
80105954:	52                   	push   %edx
80105955:	50                   	push   %eax
80105956:	e8 db bd ff ff       	call   80101736 <ialloc>
8010595b:	83 c4 10             	add    $0x10,%esp
8010595e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105961:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105965:	75 0d                	jne    80105974 <create+0xe9>
    panic("create: ialloc");
80105967:	83 ec 0c             	sub    $0xc,%esp
8010596a:	68 ac ab 10 80       	push   $0x8010abac
8010596f:	e8 35 ac ff ff       	call   801005a9 <panic>

  ilock(ip);
80105974:	83 ec 0c             	sub    $0xc,%esp
80105977:	ff 75 f0             	push   -0x10(%ebp)
8010597a:	e8 6b c0 ff ff       	call   801019ea <ilock>
8010597f:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105982:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105985:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105989:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
8010598d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105990:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105994:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105998:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010599b:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801059a1:	83 ec 0c             	sub    $0xc,%esp
801059a4:	ff 75 f0             	push   -0x10(%ebp)
801059a7:	e8 61 be ff ff       	call   8010180d <iupdate>
801059ac:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801059af:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801059b4:	75 6a                	jne    80105a20 <create+0x195>
    dp->nlink++;  // for ".."
801059b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059bd:	83 c0 01             	add    $0x1,%eax
801059c0:	89 c2                	mov    %eax,%edx
801059c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c5:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801059c9:	83 ec 0c             	sub    $0xc,%esp
801059cc:	ff 75 f4             	push   -0xc(%ebp)
801059cf:	e8 39 be ff ff       	call   8010180d <iupdate>
801059d4:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801059d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059da:	8b 40 04             	mov    0x4(%eax),%eax
801059dd:	83 ec 04             	sub    $0x4,%esp
801059e0:	50                   	push   %eax
801059e1:	68 86 ab 10 80       	push   $0x8010ab86
801059e6:	ff 75 f0             	push   -0x10(%ebp)
801059e9:	e8 98 c8 ff ff       	call   80102286 <dirlink>
801059ee:	83 c4 10             	add    $0x10,%esp
801059f1:	85 c0                	test   %eax,%eax
801059f3:	78 1e                	js     80105a13 <create+0x188>
801059f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f8:	8b 40 04             	mov    0x4(%eax),%eax
801059fb:	83 ec 04             	sub    $0x4,%esp
801059fe:	50                   	push   %eax
801059ff:	68 88 ab 10 80       	push   $0x8010ab88
80105a04:	ff 75 f0             	push   -0x10(%ebp)
80105a07:	e8 7a c8 ff ff       	call   80102286 <dirlink>
80105a0c:	83 c4 10             	add    $0x10,%esp
80105a0f:	85 c0                	test   %eax,%eax
80105a11:	79 0d                	jns    80105a20 <create+0x195>
      panic("create dots");
80105a13:	83 ec 0c             	sub    $0xc,%esp
80105a16:	68 bb ab 10 80       	push   $0x8010abbb
80105a1b:	e8 89 ab ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a23:	8b 40 04             	mov    0x4(%eax),%eax
80105a26:	83 ec 04             	sub    $0x4,%esp
80105a29:	50                   	push   %eax
80105a2a:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a2d:	50                   	push   %eax
80105a2e:	ff 75 f4             	push   -0xc(%ebp)
80105a31:	e8 50 c8 ff ff       	call   80102286 <dirlink>
80105a36:	83 c4 10             	add    $0x10,%esp
80105a39:	85 c0                	test   %eax,%eax
80105a3b:	79 0d                	jns    80105a4a <create+0x1bf>
    panic("create: dirlink");
80105a3d:	83 ec 0c             	sub    $0xc,%esp
80105a40:	68 c7 ab 10 80       	push   $0x8010abc7
80105a45:	e8 5f ab ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105a4a:	83 ec 0c             	sub    $0xc,%esp
80105a4d:	ff 75 f4             	push   -0xc(%ebp)
80105a50:	e8 c6 c1 ff ff       	call   80101c1b <iunlockput>
80105a55:	83 c4 10             	add    $0x10,%esp

  return ip;
80105a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105a5b:	c9                   	leave  
80105a5c:	c3                   	ret    

80105a5d <sys_open>:

int
sys_open(void)
{
80105a5d:	55                   	push   %ebp
80105a5e:	89 e5                	mov    %esp,%ebp
80105a60:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105a63:	83 ec 08             	sub    $0x8,%esp
80105a66:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105a69:	50                   	push   %eax
80105a6a:	6a 00                	push   $0x0
80105a6c:	e8 ea f6 ff ff       	call   8010515b <argstr>
80105a71:	83 c4 10             	add    $0x10,%esp
80105a74:	85 c0                	test   %eax,%eax
80105a76:	78 15                	js     80105a8d <sys_open+0x30>
80105a78:	83 ec 08             	sub    $0x8,%esp
80105a7b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a7e:	50                   	push   %eax
80105a7f:	6a 01                	push   $0x1
80105a81:	e8 40 f6 ff ff       	call   801050c6 <argint>
80105a86:	83 c4 10             	add    $0x10,%esp
80105a89:	85 c0                	test   %eax,%eax
80105a8b:	79 0a                	jns    80105a97 <sys_open+0x3a>
    return -1;
80105a8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a92:	e9 61 01 00 00       	jmp    80105bf8 <sys_open+0x19b>

  begin_op();
80105a97:	e8 a0 d5 ff ff       	call   8010303c <begin_op>

  if(omode & O_CREATE){
80105a9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a9f:	25 00 02 00 00       	and    $0x200,%eax
80105aa4:	85 c0                	test   %eax,%eax
80105aa6:	74 2a                	je     80105ad2 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105aa8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105aab:	6a 00                	push   $0x0
80105aad:	6a 00                	push   $0x0
80105aaf:	6a 02                	push   $0x2
80105ab1:	50                   	push   %eax
80105ab2:	e8 d4 fd ff ff       	call   8010588b <create>
80105ab7:	83 c4 10             	add    $0x10,%esp
80105aba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105abd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ac1:	75 75                	jne    80105b38 <sys_open+0xdb>
      end_op();
80105ac3:	e8 00 d6 ff ff       	call   801030c8 <end_op>
      return -1;
80105ac8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105acd:	e9 26 01 00 00       	jmp    80105bf8 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105ad2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ad5:	83 ec 0c             	sub    $0xc,%esp
80105ad8:	50                   	push   %eax
80105ad9:	e8 3f ca ff ff       	call   8010251d <namei>
80105ade:	83 c4 10             	add    $0x10,%esp
80105ae1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ae4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ae8:	75 0f                	jne    80105af9 <sys_open+0x9c>
      end_op();
80105aea:	e8 d9 d5 ff ff       	call   801030c8 <end_op>
      return -1;
80105aef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af4:	e9 ff 00 00 00       	jmp    80105bf8 <sys_open+0x19b>
    }
    ilock(ip);
80105af9:	83 ec 0c             	sub    $0xc,%esp
80105afc:	ff 75 f4             	push   -0xc(%ebp)
80105aff:	e8 e6 be ff ff       	call   801019ea <ilock>
80105b04:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b0e:	66 83 f8 01          	cmp    $0x1,%ax
80105b12:	75 24                	jne    80105b38 <sys_open+0xdb>
80105b14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b17:	85 c0                	test   %eax,%eax
80105b19:	74 1d                	je     80105b38 <sys_open+0xdb>
      iunlockput(ip);
80105b1b:	83 ec 0c             	sub    $0xc,%esp
80105b1e:	ff 75 f4             	push   -0xc(%ebp)
80105b21:	e8 f5 c0 ff ff       	call   80101c1b <iunlockput>
80105b26:	83 c4 10             	add    $0x10,%esp
      end_op();
80105b29:	e8 9a d5 ff ff       	call   801030c8 <end_op>
      return -1;
80105b2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b33:	e9 c0 00 00 00       	jmp    80105bf8 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105b38:	e8 a0 b4 ff ff       	call   80100fdd <filealloc>
80105b3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b44:	74 17                	je     80105b5d <sys_open+0x100>
80105b46:	83 ec 0c             	sub    $0xc,%esp
80105b49:	ff 75 f0             	push   -0x10(%ebp)
80105b4c:	e8 33 f7 ff ff       	call   80105284 <fdalloc>
80105b51:	83 c4 10             	add    $0x10,%esp
80105b54:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105b57:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105b5b:	79 2e                	jns    80105b8b <sys_open+0x12e>
    if(f)
80105b5d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b61:	74 0e                	je     80105b71 <sys_open+0x114>
      fileclose(f);
80105b63:	83 ec 0c             	sub    $0xc,%esp
80105b66:	ff 75 f0             	push   -0x10(%ebp)
80105b69:	e8 2d b5 ff ff       	call   8010109b <fileclose>
80105b6e:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105b71:	83 ec 0c             	sub    $0xc,%esp
80105b74:	ff 75 f4             	push   -0xc(%ebp)
80105b77:	e8 9f c0 ff ff       	call   80101c1b <iunlockput>
80105b7c:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b7f:	e8 44 d5 ff ff       	call   801030c8 <end_op>
    return -1;
80105b84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b89:	eb 6d                	jmp    80105bf8 <sys_open+0x19b>
  }
  iunlock(ip);
80105b8b:	83 ec 0c             	sub    $0xc,%esp
80105b8e:	ff 75 f4             	push   -0xc(%ebp)
80105b91:	e8 67 bf ff ff       	call   80101afd <iunlock>
80105b96:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b99:	e8 2a d5 ff ff       	call   801030c8 <end_op>

  f->type = FD_INODE;
80105b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba1:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105baa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bad:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105bb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105bba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bbd:	83 e0 01             	and    $0x1,%eax
80105bc0:	85 c0                	test   %eax,%eax
80105bc2:	0f 94 c0             	sete   %al
80105bc5:	89 c2                	mov    %eax,%edx
80105bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bca:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105bcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bd0:	83 e0 01             	and    $0x1,%eax
80105bd3:	85 c0                	test   %eax,%eax
80105bd5:	75 0a                	jne    80105be1 <sys_open+0x184>
80105bd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bda:	83 e0 02             	and    $0x2,%eax
80105bdd:	85 c0                	test   %eax,%eax
80105bdf:	74 07                	je     80105be8 <sys_open+0x18b>
80105be1:	b8 01 00 00 00       	mov    $0x1,%eax
80105be6:	eb 05                	jmp    80105bed <sys_open+0x190>
80105be8:	b8 00 00 00 00       	mov    $0x0,%eax
80105bed:	89 c2                	mov    %eax,%edx
80105bef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf2:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105bf5:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105bf8:	c9                   	leave  
80105bf9:	c3                   	ret    

80105bfa <sys_mkdir>:

int
sys_mkdir(void)
{
80105bfa:	55                   	push   %ebp
80105bfb:	89 e5                	mov    %esp,%ebp
80105bfd:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105c00:	e8 37 d4 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105c05:	83 ec 08             	sub    $0x8,%esp
80105c08:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c0b:	50                   	push   %eax
80105c0c:	6a 00                	push   $0x0
80105c0e:	e8 48 f5 ff ff       	call   8010515b <argstr>
80105c13:	83 c4 10             	add    $0x10,%esp
80105c16:	85 c0                	test   %eax,%eax
80105c18:	78 1b                	js     80105c35 <sys_mkdir+0x3b>
80105c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1d:	6a 00                	push   $0x0
80105c1f:	6a 00                	push   $0x0
80105c21:	6a 01                	push   $0x1
80105c23:	50                   	push   %eax
80105c24:	e8 62 fc ff ff       	call   8010588b <create>
80105c29:	83 c4 10             	add    $0x10,%esp
80105c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c33:	75 0c                	jne    80105c41 <sys_mkdir+0x47>
    end_op();
80105c35:	e8 8e d4 ff ff       	call   801030c8 <end_op>
    return -1;
80105c3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c3f:	eb 18                	jmp    80105c59 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105c41:	83 ec 0c             	sub    $0xc,%esp
80105c44:	ff 75 f4             	push   -0xc(%ebp)
80105c47:	e8 cf bf ff ff       	call   80101c1b <iunlockput>
80105c4c:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c4f:	e8 74 d4 ff ff       	call   801030c8 <end_op>
  return 0;
80105c54:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c59:	c9                   	leave  
80105c5a:	c3                   	ret    

80105c5b <sys_mknod>:

int
sys_mknod(void)
{
80105c5b:	55                   	push   %ebp
80105c5c:	89 e5                	mov    %esp,%ebp
80105c5e:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105c61:	e8 d6 d3 ff ff       	call   8010303c <begin_op>
  if((argstr(0, &path)) < 0 ||
80105c66:	83 ec 08             	sub    $0x8,%esp
80105c69:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c6c:	50                   	push   %eax
80105c6d:	6a 00                	push   $0x0
80105c6f:	e8 e7 f4 ff ff       	call   8010515b <argstr>
80105c74:	83 c4 10             	add    $0x10,%esp
80105c77:	85 c0                	test   %eax,%eax
80105c79:	78 4f                	js     80105cca <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105c7b:	83 ec 08             	sub    $0x8,%esp
80105c7e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c81:	50                   	push   %eax
80105c82:	6a 01                	push   $0x1
80105c84:	e8 3d f4 ff ff       	call   801050c6 <argint>
80105c89:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105c8c:	85 c0                	test   %eax,%eax
80105c8e:	78 3a                	js     80105cca <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105c90:	83 ec 08             	sub    $0x8,%esp
80105c93:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c96:	50                   	push   %eax
80105c97:	6a 02                	push   $0x2
80105c99:	e8 28 f4 ff ff       	call   801050c6 <argint>
80105c9e:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105ca1:	85 c0                	test   %eax,%eax
80105ca3:	78 25                	js     80105cca <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105ca5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ca8:	0f bf c8             	movswl %ax,%ecx
80105cab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105cae:	0f bf d0             	movswl %ax,%edx
80105cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb4:	51                   	push   %ecx
80105cb5:	52                   	push   %edx
80105cb6:	6a 03                	push   $0x3
80105cb8:	50                   	push   %eax
80105cb9:	e8 cd fb ff ff       	call   8010588b <create>
80105cbe:	83 c4 10             	add    $0x10,%esp
80105cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105cc4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cc8:	75 0c                	jne    80105cd6 <sys_mknod+0x7b>
    end_op();
80105cca:	e8 f9 d3 ff ff       	call   801030c8 <end_op>
    return -1;
80105ccf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd4:	eb 18                	jmp    80105cee <sys_mknod+0x93>
  }
  iunlockput(ip);
80105cd6:	83 ec 0c             	sub    $0xc,%esp
80105cd9:	ff 75 f4             	push   -0xc(%ebp)
80105cdc:	e8 3a bf ff ff       	call   80101c1b <iunlockput>
80105ce1:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ce4:	e8 df d3 ff ff       	call   801030c8 <end_op>
  return 0;
80105ce9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cee:	c9                   	leave  
80105cef:	c3                   	ret    

80105cf0 <sys_chdir>:

int
sys_chdir(void)
{
80105cf0:	55                   	push   %ebp
80105cf1:	89 e5                	mov    %esp,%ebp
80105cf3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105cf6:	e8 35 dd ff ff       	call   80103a30 <myproc>
80105cfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105cfe:	e8 39 d3 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105d03:	83 ec 08             	sub    $0x8,%esp
80105d06:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d09:	50                   	push   %eax
80105d0a:	6a 00                	push   $0x0
80105d0c:	e8 4a f4 ff ff       	call   8010515b <argstr>
80105d11:	83 c4 10             	add    $0x10,%esp
80105d14:	85 c0                	test   %eax,%eax
80105d16:	78 18                	js     80105d30 <sys_chdir+0x40>
80105d18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d1b:	83 ec 0c             	sub    $0xc,%esp
80105d1e:	50                   	push   %eax
80105d1f:	e8 f9 c7 ff ff       	call   8010251d <namei>
80105d24:	83 c4 10             	add    $0x10,%esp
80105d27:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d2a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d2e:	75 0c                	jne    80105d3c <sys_chdir+0x4c>
    end_op();
80105d30:	e8 93 d3 ff ff       	call   801030c8 <end_op>
    return -1;
80105d35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d3a:	eb 68                	jmp    80105da4 <sys_chdir+0xb4>
  }
  ilock(ip);
80105d3c:	83 ec 0c             	sub    $0xc,%esp
80105d3f:	ff 75 f0             	push   -0x10(%ebp)
80105d42:	e8 a3 bc ff ff       	call   801019ea <ilock>
80105d47:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105d4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d4d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d51:	66 83 f8 01          	cmp    $0x1,%ax
80105d55:	74 1a                	je     80105d71 <sys_chdir+0x81>
    iunlockput(ip);
80105d57:	83 ec 0c             	sub    $0xc,%esp
80105d5a:	ff 75 f0             	push   -0x10(%ebp)
80105d5d:	e8 b9 be ff ff       	call   80101c1b <iunlockput>
80105d62:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d65:	e8 5e d3 ff ff       	call   801030c8 <end_op>
    return -1;
80105d6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6f:	eb 33                	jmp    80105da4 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105d71:	83 ec 0c             	sub    $0xc,%esp
80105d74:	ff 75 f0             	push   -0x10(%ebp)
80105d77:	e8 81 bd ff ff       	call   80101afd <iunlock>
80105d7c:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d82:	8b 40 68             	mov    0x68(%eax),%eax
80105d85:	83 ec 0c             	sub    $0xc,%esp
80105d88:	50                   	push   %eax
80105d89:	e8 bd bd ff ff       	call   80101b4b <iput>
80105d8e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d91:	e8 32 d3 ff ff       	call   801030c8 <end_op>
  curproc->cwd = ip;
80105d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d99:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d9c:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105d9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105da4:	c9                   	leave  
80105da5:	c3                   	ret    

80105da6 <sys_exec>:

int
sys_exec(void)
{
80105da6:	55                   	push   %ebp
80105da7:	89 e5                	mov    %esp,%ebp
80105da9:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105daf:	83 ec 08             	sub    $0x8,%esp
80105db2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105db5:	50                   	push   %eax
80105db6:	6a 00                	push   $0x0
80105db8:	e8 9e f3 ff ff       	call   8010515b <argstr>
80105dbd:	83 c4 10             	add    $0x10,%esp
80105dc0:	85 c0                	test   %eax,%eax
80105dc2:	78 18                	js     80105ddc <sys_exec+0x36>
80105dc4:	83 ec 08             	sub    $0x8,%esp
80105dc7:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105dcd:	50                   	push   %eax
80105dce:	6a 01                	push   $0x1
80105dd0:	e8 f1 f2 ff ff       	call   801050c6 <argint>
80105dd5:	83 c4 10             	add    $0x10,%esp
80105dd8:	85 c0                	test   %eax,%eax
80105dda:	79 0a                	jns    80105de6 <sys_exec+0x40>
    return -1;
80105ddc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de1:	e9 c6 00 00 00       	jmp    80105eac <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105de6:	83 ec 04             	sub    $0x4,%esp
80105de9:	68 80 00 00 00       	push   $0x80
80105dee:	6a 00                	push   $0x0
80105df0:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105df6:	50                   	push   %eax
80105df7:	e8 9f ef ff ff       	call   80104d9b <memset>
80105dfc:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105dff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e09:	83 f8 1f             	cmp    $0x1f,%eax
80105e0c:	76 0a                	jbe    80105e18 <sys_exec+0x72>
      return -1;
80105e0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e13:	e9 94 00 00 00       	jmp    80105eac <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1b:	c1 e0 02             	shl    $0x2,%eax
80105e1e:	89 c2                	mov    %eax,%edx
80105e20:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105e26:	01 c2                	add    %eax,%edx
80105e28:	83 ec 08             	sub    $0x8,%esp
80105e2b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105e31:	50                   	push   %eax
80105e32:	52                   	push   %edx
80105e33:	e8 ed f1 ff ff       	call   80105025 <fetchint>
80105e38:	83 c4 10             	add    $0x10,%esp
80105e3b:	85 c0                	test   %eax,%eax
80105e3d:	79 07                	jns    80105e46 <sys_exec+0xa0>
      return -1;
80105e3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e44:	eb 66                	jmp    80105eac <sys_exec+0x106>
    if(uarg == 0){
80105e46:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e4c:	85 c0                	test   %eax,%eax
80105e4e:	75 27                	jne    80105e77 <sys_exec+0xd1>
      argv[i] = 0;
80105e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e53:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105e5a:	00 00 00 00 
      break;
80105e5e:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e62:	83 ec 08             	sub    $0x8,%esp
80105e65:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e6b:	52                   	push   %edx
80105e6c:	50                   	push   %eax
80105e6d:	e8 0e ad ff ff       	call   80100b80 <exec>
80105e72:	83 c4 10             	add    $0x10,%esp
80105e75:	eb 35                	jmp    80105eac <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105e77:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e80:	c1 e0 02             	shl    $0x2,%eax
80105e83:	01 c2                	add    %eax,%edx
80105e85:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e8b:	83 ec 08             	sub    $0x8,%esp
80105e8e:	52                   	push   %edx
80105e8f:	50                   	push   %eax
80105e90:	e8 cf f1 ff ff       	call   80105064 <fetchstr>
80105e95:	83 c4 10             	add    $0x10,%esp
80105e98:	85 c0                	test   %eax,%eax
80105e9a:	79 07                	jns    80105ea3 <sys_exec+0xfd>
      return -1;
80105e9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ea1:	eb 09                	jmp    80105eac <sys_exec+0x106>
  for(i=0;; i++){
80105ea3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ea7:	e9 5a ff ff ff       	jmp    80105e06 <sys_exec+0x60>
}
80105eac:	c9                   	leave  
80105ead:	c3                   	ret    

80105eae <sys_pipe>:

int
sys_pipe(void)
{
80105eae:	55                   	push   %ebp
80105eaf:	89 e5                	mov    %esp,%ebp
80105eb1:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105eb4:	83 ec 04             	sub    $0x4,%esp
80105eb7:	6a 08                	push   $0x8
80105eb9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ebc:	50                   	push   %eax
80105ebd:	6a 00                	push   $0x0
80105ebf:	e8 2f f2 ff ff       	call   801050f3 <argptr>
80105ec4:	83 c4 10             	add    $0x10,%esp
80105ec7:	85 c0                	test   %eax,%eax
80105ec9:	79 0a                	jns    80105ed5 <sys_pipe+0x27>
    return -1;
80105ecb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed0:	e9 ae 00 00 00       	jmp    80105f83 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105ed5:	83 ec 08             	sub    $0x8,%esp
80105ed8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105edb:	50                   	push   %eax
80105edc:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105edf:	50                   	push   %eax
80105ee0:	e8 88 d6 ff ff       	call   8010356d <pipealloc>
80105ee5:	83 c4 10             	add    $0x10,%esp
80105ee8:	85 c0                	test   %eax,%eax
80105eea:	79 0a                	jns    80105ef6 <sys_pipe+0x48>
    return -1;
80105eec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef1:	e9 8d 00 00 00       	jmp    80105f83 <sys_pipe+0xd5>
  fd0 = -1;
80105ef6:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105efd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f00:	83 ec 0c             	sub    $0xc,%esp
80105f03:	50                   	push   %eax
80105f04:	e8 7b f3 ff ff       	call   80105284 <fdalloc>
80105f09:	83 c4 10             	add    $0x10,%esp
80105f0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f13:	78 18                	js     80105f2d <sys_pipe+0x7f>
80105f15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f18:	83 ec 0c             	sub    $0xc,%esp
80105f1b:	50                   	push   %eax
80105f1c:	e8 63 f3 ff ff       	call   80105284 <fdalloc>
80105f21:	83 c4 10             	add    $0x10,%esp
80105f24:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f2b:	79 3e                	jns    80105f6b <sys_pipe+0xbd>
    if(fd0 >= 0)
80105f2d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f31:	78 13                	js     80105f46 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105f33:	e8 f8 da ff ff       	call   80103a30 <myproc>
80105f38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f3b:	83 c2 08             	add    $0x8,%edx
80105f3e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105f45:	00 
    fileclose(rf);
80105f46:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f49:	83 ec 0c             	sub    $0xc,%esp
80105f4c:	50                   	push   %eax
80105f4d:	e8 49 b1 ff ff       	call   8010109b <fileclose>
80105f52:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105f55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f58:	83 ec 0c             	sub    $0xc,%esp
80105f5b:	50                   	push   %eax
80105f5c:	e8 3a b1 ff ff       	call   8010109b <fileclose>
80105f61:	83 c4 10             	add    $0x10,%esp
    return -1;
80105f64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f69:	eb 18                	jmp    80105f83 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105f6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f71:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105f73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f76:	8d 50 04             	lea    0x4(%eax),%edx
80105f79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f7c:	89 02                	mov    %eax,(%edx)
  return 0;
80105f7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f83:	c9                   	leave  
80105f84:	c3                   	ret    

80105f85 <sys_fork>:
  struct proc proc[NPROC];
} ptable;

int
sys_fork(void)
{
80105f85:	55                   	push   %ebp
80105f86:	89 e5                	mov    %esp,%ebp
80105f88:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105f8b:	e8 fa dd ff ff       	call   80103d8a <fork>
}
80105f90:	c9                   	leave  
80105f91:	c3                   	ret    

80105f92 <sys_exit>:

int
sys_exit(void)
{
80105f92:	55                   	push   %ebp
80105f93:	89 e5                	mov    %esp,%ebp
80105f95:	83 ec 08             	sub    $0x8,%esp
  exit();
80105f98:	e8 66 df ff ff       	call   80103f03 <exit>
  return 0;  // not reached
80105f9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fa2:	c9                   	leave  
80105fa3:	c3                   	ret    

80105fa4 <sys_wait>:

int
sys_wait(void)
{
80105fa4:	55                   	push   %ebp
80105fa5:	89 e5                	mov    %esp,%ebp
80105fa7:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105faa:	e8 b8 e0 ff ff       	call   80104067 <wait>
}
80105faf:	c9                   	leave  
80105fb0:	c3                   	ret    

80105fb1 <sys_kill>:

int
sys_kill(void)
{
80105fb1:	55                   	push   %ebp
80105fb2:	89 e5                	mov    %esp,%ebp
80105fb4:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105fb7:	83 ec 08             	sub    $0x8,%esp
80105fba:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fbd:	50                   	push   %eax
80105fbe:	6a 00                	push   $0x0
80105fc0:	e8 01 f1 ff ff       	call   801050c6 <argint>
80105fc5:	83 c4 10             	add    $0x10,%esp
80105fc8:	85 c0                	test   %eax,%eax
80105fca:	79 07                	jns    80105fd3 <sys_kill+0x22>
    return -1;
80105fcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd1:	eb 0f                	jmp    80105fe2 <sys_kill+0x31>
  return kill(pid);
80105fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd6:	83 ec 0c             	sub    $0xc,%esp
80105fd9:	50                   	push   %eax
80105fda:	e8 0d e8 ff ff       	call   801047ec <kill>
80105fdf:	83 c4 10             	add    $0x10,%esp
}
80105fe2:	c9                   	leave  
80105fe3:	c3                   	ret    

80105fe4 <sys_getpid>:

int
sys_getpid(void)
{
80105fe4:	55                   	push   %ebp
80105fe5:	89 e5                	mov    %esp,%ebp
80105fe7:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105fea:	e8 41 da ff ff       	call   80103a30 <myproc>
80105fef:	8b 40 10             	mov    0x10(%eax),%eax
}
80105ff2:	c9                   	leave  
80105ff3:	c3                   	ret    

80105ff4 <sys_sbrk>:

int
sys_sbrk(void)
{
80105ff4:	55                   	push   %ebp
80105ff5:	89 e5                	mov    %esp,%ebp
80105ff7:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105ffa:	83 ec 08             	sub    $0x8,%esp
80105ffd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106000:	50                   	push   %eax
80106001:	6a 00                	push   $0x0
80106003:	e8 be f0 ff ff       	call   801050c6 <argint>
80106008:	83 c4 10             	add    $0x10,%esp
8010600b:	85 c0                	test   %eax,%eax
8010600d:	79 07                	jns    80106016 <sys_sbrk+0x22>
    return -1;
8010600f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106014:	eb 27                	jmp    8010603d <sys_sbrk+0x49>
  addr = myproc()->sz;
80106016:	e8 15 da ff ff       	call   80103a30 <myproc>
8010601b:	8b 00                	mov    (%eax),%eax
8010601d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106020:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106023:	83 ec 0c             	sub    $0xc,%esp
80106026:	50                   	push   %eax
80106027:	e8 c3 dc ff ff       	call   80103cef <growproc>
8010602c:	83 c4 10             	add    $0x10,%esp
8010602f:	85 c0                	test   %eax,%eax
80106031:	79 07                	jns    8010603a <sys_sbrk+0x46>
    return -1;
80106033:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106038:	eb 03                	jmp    8010603d <sys_sbrk+0x49>
  return addr;
8010603a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010603d:	c9                   	leave  
8010603e:	c3                   	ret    

8010603f <sys_sleep>:

int
sys_sleep(void)
{
8010603f:	55                   	push   %ebp
80106040:	89 e5                	mov    %esp,%ebp
80106042:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106045:	83 ec 08             	sub    $0x8,%esp
80106048:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010604b:	50                   	push   %eax
8010604c:	6a 00                	push   $0x0
8010604e:	e8 73 f0 ff ff       	call   801050c6 <argint>
80106053:	83 c4 10             	add    $0x10,%esp
80106056:	85 c0                	test   %eax,%eax
80106058:	79 07                	jns    80106061 <sys_sleep+0x22>
    return -1;
8010605a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010605f:	eb 76                	jmp    801060d7 <sys_sleep+0x98>
  acquire(&tickslock);
80106061:	83 ec 0c             	sub    $0xc,%esp
80106064:	68 40 74 19 80       	push   $0x80197440
80106069:	e8 b7 ea ff ff       	call   80104b25 <acquire>
8010606e:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106071:	a1 74 74 19 80       	mov    0x80197474,%eax
80106076:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106079:	eb 38                	jmp    801060b3 <sys_sleep+0x74>
    if(myproc()->killed){
8010607b:	e8 b0 d9 ff ff       	call   80103a30 <myproc>
80106080:	8b 40 24             	mov    0x24(%eax),%eax
80106083:	85 c0                	test   %eax,%eax
80106085:	74 17                	je     8010609e <sys_sleep+0x5f>
      release(&tickslock);
80106087:	83 ec 0c             	sub    $0xc,%esp
8010608a:	68 40 74 19 80       	push   $0x80197440
8010608f:	e8 ff ea ff ff       	call   80104b93 <release>
80106094:	83 c4 10             	add    $0x10,%esp
      return -1;
80106097:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010609c:	eb 39                	jmp    801060d7 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
8010609e:	83 ec 08             	sub    $0x8,%esp
801060a1:	68 40 74 19 80       	push   $0x80197440
801060a6:	68 74 74 19 80       	push   $0x80197474
801060ab:	e8 1b e6 ff ff       	call   801046cb <sleep>
801060b0:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801060b3:	a1 74 74 19 80       	mov    0x80197474,%eax
801060b8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801060bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060be:	39 d0                	cmp    %edx,%eax
801060c0:	72 b9                	jb     8010607b <sys_sleep+0x3c>
  }
  release(&tickslock);
801060c2:	83 ec 0c             	sub    $0xc,%esp
801060c5:	68 40 74 19 80       	push   $0x80197440
801060ca:	e8 c4 ea ff ff       	call   80104b93 <release>
801060cf:	83 c4 10             	add    $0x10,%esp
  return 0;
801060d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060d7:	c9                   	leave  
801060d8:	c3                   	ret    

801060d9 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801060d9:	55                   	push   %ebp
801060da:	89 e5                	mov    %esp,%ebp
801060dc:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801060df:	83 ec 0c             	sub    $0xc,%esp
801060e2:	68 40 74 19 80       	push   $0x80197440
801060e7:	e8 39 ea ff ff       	call   80104b25 <acquire>
801060ec:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801060ef:	a1 74 74 19 80       	mov    0x80197474,%eax
801060f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801060f7:	83 ec 0c             	sub    $0xc,%esp
801060fa:	68 40 74 19 80       	push   $0x80197440
801060ff:	e8 8f ea ff ff       	call   80104b93 <release>
80106104:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106107:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010610a:	c9                   	leave  
8010610b:	c3                   	ret    

8010610c <sys_uthread_init>:

// 이거 추가
int
sys_uthread_init(void)
{
8010610c:	55                   	push   %ebp
8010610d:	89 e5                	mov    %esp,%ebp
8010610f:	53                   	push   %ebx
80106110:	83 ec 14             	sub    $0x14,%esp
  int addr;
  if (argint(0, &addr) < 0)
80106113:	83 ec 08             	sub    $0x8,%esp
80106116:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106119:	50                   	push   %eax
8010611a:	6a 00                	push   $0x0
8010611c:	e8 a5 ef ff ff       	call   801050c6 <argint>
80106121:	83 c4 10             	add    $0x10,%esp
80106124:	85 c0                	test   %eax,%eax
80106126:	79 07                	jns    8010612f <sys_uthread_init+0x23>
    return -1;
80106128:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010612d:	eb 12                	jmp    80106141 <sys_uthread_init+0x35>
  myproc()->scheduler = addr;
8010612f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80106132:	e8 f9 d8 ff ff       	call   80103a30 <myproc>
80106137:	89 da                	mov    %ebx,%edx
80106139:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
8010613c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106141:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106144:	c9                   	leave  
80106145:	c3                   	ret    

80106146 <sys_check_thread>:



int
sys_check_thread(void) {
80106146:	55                   	push   %ebp
80106147:	89 e5                	mov    %esp,%ebp
80106149:	83 ec 18             	sub    $0x18,%esp
  int op;
  if (argint(0, &op) < 0)  // 사용자로부터 인자 하나 받음
8010614c:	83 ec 08             	sub    $0x8,%esp
8010614f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106152:	50                   	push   %eax
80106153:	6a 00                	push   $0x0
80106155:	e8 6c ef ff ff       	call   801050c6 <argint>
8010615a:	83 c4 10             	add    $0x10,%esp
8010615d:	85 c0                	test   %eax,%eax
8010615f:	79 07                	jns    80106168 <sys_check_thread+0x22>
    return -1;
80106161:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106166:	eb 24                	jmp    8010618c <sys_check_thread+0x46>

  struct proc* p = myproc();
80106168:	e8 c3 d8 ff ff       	call   80103a30 <myproc>
8010616d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p->check_thread += op;  // +1 또는 -1
80106170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106173:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80106179:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617c:	01 c2                	add    %eax,%edx
8010617e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106181:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  return 0;
80106187:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010618c:	c9                   	leave  
8010618d:	c3                   	ret    

8010618e <sys_getpinfo>:


int
sys_getpinfo(void) {
8010618e:	55                   	push   %ebp
8010618f:	89 e5                	mov    %esp,%ebp
80106191:	53                   	push   %ebx
80106192:	83 ec 14             	sub    $0x14,%esp
  struct pstat *ps;
  if (argptr(0, (void *)&ps, sizeof(*ps)) < 0)
80106195:	83 ec 04             	sub    $0x4,%esp
80106198:	68 00 0c 00 00       	push   $0xc00
8010619d:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061a0:	50                   	push   %eax
801061a1:	6a 00                	push   $0x0
801061a3:	e8 4b ef ff ff       	call   801050f3 <argptr>
801061a8:	83 c4 10             	add    $0x10,%esp
801061ab:	85 c0                	test   %eax,%eax
801061ad:	79 0a                	jns    801061b9 <sys_getpinfo+0x2b>
    return -1;
801061af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061b4:	e9 21 01 00 00       	jmp    801062da <sys_getpinfo+0x14c>

  acquire(&ptable.lock);
801061b9:	83 ec 0c             	sub    $0xc,%esp
801061bc:	68 00 4b 19 80       	push   $0x80194b00
801061c1:	e8 5f e9 ff ff       	call   80104b25 <acquire>
801061c6:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
801061c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801061d0:	e9 e6 00 00 00       	jmp    801062bb <sys_getpinfo+0x12d>
    struct proc *p = &ptable.proc[i];
801061d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d8:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
801061de:	83 c0 30             	add    $0x30,%eax
801061e1:	05 00 4b 19 80       	add    $0x80194b00,%eax
801061e6:	83 c0 04             	add    $0x4,%eax
801061e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    ps->inuse[i] = (p->state != UNUSED);
801061ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061ef:	8b 40 0c             	mov    0xc(%eax),%eax
801061f2:	85 c0                	test   %eax,%eax
801061f4:	0f 95 c2             	setne  %dl
801061f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061fa:	0f b6 ca             	movzbl %dl,%ecx
801061fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106200:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    ps->pid[i] = p->pid;
80106203:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106206:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106209:	8b 52 10             	mov    0x10(%edx),%edx
8010620c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010620f:	83 c1 40             	add    $0x40,%ecx
80106212:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->priority[i] = proc_priority[i];
80106215:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106218:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010621b:	8b 14 95 00 42 19 80 	mov    -0x7fe6be00(,%edx,4),%edx
80106222:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80106225:	83 e9 80             	sub    $0xffffff80,%ecx
80106228:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->state[i] = p->state;
8010622b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010622e:	8b 50 0c             	mov    0xc(%eax),%edx
80106231:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106234:	89 d1                	mov    %edx,%ecx
80106236:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106239:	81 c2 c0 00 00 00    	add    $0xc0,%edx
8010623f:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    for (int j = 0; j < 4; j++) {
80106242:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106249:	eb 66                	jmp    801062b1 <sys_getpinfo+0x123>
      ps->ticks[i][j] = proc_ticks[i][j];
8010624b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010624e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106251:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
80106258:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010625b:	01 ca                	add    %ecx,%edx
8010625d:	8b 14 95 00 43 19 80 	mov    -0x7fe6bd00(,%edx,4),%edx
80106264:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80106267:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
8010626e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106271:	01 d9                	add    %ebx,%ecx
80106273:	81 c1 00 01 00 00    	add    $0x100,%ecx
80106279:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = proc_wait_ticks[i][j];
8010627c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010627f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106282:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
80106289:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010628c:	01 ca                	add    %ecx,%edx
8010628e:	8b 14 95 00 47 19 80 	mov    -0x7fe6b900(,%edx,4),%edx
80106295:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80106298:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
8010629f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801062a2:	01 d9                	add    %ebx,%ecx
801062a4:	81 c1 00 02 00 00    	add    $0x200,%ecx
801062aa:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
801062ad:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801062b1:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
801062b5:	7e 94                	jle    8010624b <sys_getpinfo+0xbd>
  for (int i = 0; i < NPROC; i++) {
801062b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801062bb:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801062bf:	0f 8e 10 ff ff ff    	jle    801061d5 <sys_getpinfo+0x47>
    }
  }
  release(&ptable.lock);
801062c5:	83 ec 0c             	sub    $0xc,%esp
801062c8:	68 00 4b 19 80       	push   $0x80194b00
801062cd:	e8 c1 e8 ff ff       	call   80104b93 <release>
801062d2:	83 c4 10             	add    $0x10,%esp
  return 0;
801062d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801062dd:	c9                   	leave  
801062de:	c3                   	ret    

801062df <sys_setSchedPolicy>:


int
sys_setSchedPolicy(void) {
801062df:	55                   	push   %ebp
801062e0:	89 e5                	mov    %esp,%ebp
801062e2:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
801062e5:	83 ec 08             	sub    $0x8,%esp
801062e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801062eb:	50                   	push   %eax
801062ec:	6a 00                	push   $0x0
801062ee:	e8 d3 ed ff ff       	call   801050c6 <argint>
801062f3:	83 c4 10             	add    $0x10,%esp
801062f6:	85 c0                	test   %eax,%eax
801062f8:	79 07                	jns    80106301 <sys_setSchedPolicy+0x22>
    return -1;
801062fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ff:	eb 31                	jmp    80106332 <sys_setSchedPolicy+0x53>
  
  pushcli();
80106301:	e8 8a e9 ff ff       	call   80104c90 <pushcli>
  mycpu()->sched_policy = policy;
80106306:	e8 ad d6 ff ff       	call   801039b8 <mycpu>
8010630b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010630e:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
80106314:	e8 c4 e9 ff ff       	call   80104cdd <popcli>

  cprintf("✅ sched_policy set to %d\n", policy);
80106319:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631c:	83 ec 08             	sub    $0x8,%esp
8010631f:	50                   	push   %eax
80106320:	68 d7 ab 10 80       	push   $0x8010abd7
80106325:	e8 ca a0 ff ff       	call   801003f4 <cprintf>
8010632a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010632d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106332:	c9                   	leave  
80106333:	c3                   	ret    

80106334 <sys_yield>:

int
sys_yield(void)
{
80106334:	55                   	push   %ebp
80106335:	89 e5                	mov    %esp,%ebp
80106337:	83 ec 08             	sub    $0x8,%esp
  yield();
8010633a:	e8 cb e2 ff ff       	call   8010460a <yield>
  return 0;
8010633f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106344:	c9                   	leave  
80106345:	c3                   	ret    

80106346 <print_user_page_table>:
//     // cprintf("%d P %c %c %x\n", vpn, uork, w, ppn);
//   }
//   cprintf("END PAGE TABLE\n");
// }

void print_user_page_table(struct proc *p) {
80106346:	55                   	push   %ebp
80106347:	89 e5                	mov    %esp,%ebp
80106349:	83 ec 28             	sub    $0x28,%esp
  cprintf("START PAGE TABLE (pid %d)\n", p->pid);
8010634c:	8b 45 08             	mov    0x8(%ebp),%eax
8010634f:	8b 40 10             	mov    0x10(%eax),%eax
80106352:	83 ec 08             	sub    $0x8,%esp
80106355:	50                   	push   %eax
80106356:	68 f3 ab 10 80       	push   $0x8010abf3
8010635b:	e8 94 a0 ff ff       	call   801003f4 <cprintf>
80106360:	83 c4 10             	add    $0x10,%esp
  pde_t *pgdir = p->pgdir;
80106363:	8b 45 08             	mov    0x8(%ebp),%eax
80106366:	8b 40 04             	mov    0x4(%eax),%eax
80106369:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(uint va = 0; va < KERNBASE; va += PGSIZE) {
8010636c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106373:	e9 c2 00 00 00       	jmp    8010643a <print_user_page_table+0xf4>
    pte_t *pte = walkpgdir(pgdir, (void*)va, 0);
80106378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637b:	83 ec 04             	sub    $0x4,%esp
8010637e:	6a 00                	push   $0x0
80106380:	50                   	push   %eax
80106381:	ff 75 f0             	push   -0x10(%ebp)
80106384:	e8 c2 15 00 00       	call   8010794b <walkpgdir>
80106389:	83 c4 10             	add    $0x10,%esp
8010638c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(!pte) continue;
8010638f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106393:	0f 84 96 00 00 00    	je     8010642f <print_user_page_table+0xe9>
    if(!(*pte & PTE_P)) continue;
80106399:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010639c:	8b 00                	mov    (%eax),%eax
8010639e:	83 e0 01             	and    $0x1,%eax
801063a1:	85 c0                	test   %eax,%eax
801063a3:	0f 84 89 00 00 00    	je     80106432 <print_user_page_table+0xec>
    uint vpn = va / PGSIZE;
801063a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063ac:	c1 e8 0c             	shr    $0xc,%eax
801063af:	89 45 e8             	mov    %eax,-0x18(%ebp)
    char *uork = (*pte & PTE_U) ? "U" : "K";
801063b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063b5:	8b 00                	mov    (%eax),%eax
801063b7:	83 e0 04             	and    $0x4,%eax
801063ba:	85 c0                	test   %eax,%eax
801063bc:	74 07                	je     801063c5 <print_user_page_table+0x7f>
801063be:	b8 0e ac 10 80       	mov    $0x8010ac0e,%eax
801063c3:	eb 05                	jmp    801063ca <print_user_page_table+0x84>
801063c5:	b8 10 ac 10 80       	mov    $0x8010ac10,%eax
801063ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    char *w = (*pte & PTE_W) ? "W" : "-";
801063cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063d0:	8b 00                	mov    (%eax),%eax
801063d2:	83 e0 02             	and    $0x2,%eax
801063d5:	85 c0                	test   %eax,%eax
801063d7:	74 07                	je     801063e0 <print_user_page_table+0x9a>
801063d9:	b8 12 ac 10 80       	mov    $0x8010ac12,%eax
801063de:	eb 05                	jmp    801063e5 <print_user_page_table+0x9f>
801063e0:	b8 14 ac 10 80       	mov    $0x8010ac14,%eax
801063e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    uint pa = PTE_ADDR(*pte);
801063e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063eb:	8b 00                	mov    (%eax),%eax
801063ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801063f2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    uint ppn = pa >> 12;
801063f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801063f8:	c1 e8 0c             	shr    $0xc,%eax
801063fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
    cprintf("ppn = %x\n", ppn);
801063fe:	83 ec 08             	sub    $0x8,%esp
80106401:	ff 75 d8             	push   -0x28(%ebp)
80106404:	68 16 ac 10 80       	push   $0x8010ac16
80106409:	e8 e6 9f ff ff       	call   801003f4 <cprintf>
8010640e:	83 c4 10             	add    $0x10,%esp
    cprintf("%x P %s %s %x\n", vpn, uork, w, ppn);
80106411:	83 ec 0c             	sub    $0xc,%esp
80106414:	ff 75 d8             	push   -0x28(%ebp)
80106417:	ff 75 e0             	push   -0x20(%ebp)
8010641a:	ff 75 e4             	push   -0x1c(%ebp)
8010641d:	ff 75 e8             	push   -0x18(%ebp)
80106420:	68 20 ac 10 80       	push   $0x8010ac20
80106425:	e8 ca 9f ff ff       	call   801003f4 <cprintf>
8010642a:	83 c4 20             	add    $0x20,%esp
8010642d:	eb 04                	jmp    80106433 <print_user_page_table+0xed>
    if(!pte) continue;
8010642f:	90                   	nop
80106430:	eb 01                	jmp    80106433 <print_user_page_table+0xed>
    if(!(*pte & PTE_P)) continue;
80106432:	90                   	nop
  for(uint va = 0; va < KERNBASE; va += PGSIZE) {
80106433:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010643a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010643d:	85 c0                	test   %eax,%eax
8010643f:	0f 89 33 ff ff ff    	jns    80106378 <print_user_page_table+0x32>
  }
  cprintf("END PAGE TABLE\n");
80106445:	83 ec 0c             	sub    $0xc,%esp
80106448:	68 2f ac 10 80       	push   $0x8010ac2f
8010644d:	e8 a2 9f ff ff       	call   801003f4 <cprintf>
80106452:	83 c4 10             	add    $0x10,%esp
}
80106455:	90                   	nop
80106456:	c9                   	leave  
80106457:	c3                   	ret    

80106458 <sys_printpt>:

int 
sys_printpt(void) {
80106458:	55                   	push   %ebp
80106459:	89 e5                	mov    %esp,%ebp
8010645b:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if(argint(0, &pid) < 0)
8010645e:	83 ec 08             	sub    $0x8,%esp
80106461:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106464:	50                   	push   %eax
80106465:	6a 00                	push   $0x0
80106467:	e8 5a ec ff ff       	call   801050c6 <argint>
8010646c:	83 c4 10             	add    $0x10,%esp
8010646f:	85 c0                	test   %eax,%eax
80106471:	79 07                	jns    8010647a <sys_printpt+0x22>
    return -1;
80106473:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106478:	eb 32                	jmp    801064ac <sys_printpt+0x54>
  struct proc *p = find_proc_by_pid(pid);
8010647a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010647d:	83 ec 0c             	sub    $0xc,%esp
80106480:	50                   	push   %eax
80106481:	e8 ea e4 ff ff       	call   80104970 <find_proc_by_pid>
80106486:	83 c4 10             	add    $0x10,%esp
80106489:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!p)
8010648c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106490:	75 07                	jne    80106499 <sys_printpt+0x41>
    return -1;
80106492:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106497:	eb 13                	jmp    801064ac <sys_printpt+0x54>
  print_user_page_table(p);
80106499:	83 ec 0c             	sub    $0xc,%esp
8010649c:	ff 75 f4             	push   -0xc(%ebp)
8010649f:	e8 a2 fe ff ff       	call   80106346 <print_user_page_table>
801064a4:	83 c4 10             	add    $0x10,%esp
  return 0;
801064a7:	b8 00 00 00 00       	mov    $0x0,%eax
801064ac:	c9                   	leave  
801064ad:	c3                   	ret    

801064ae <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801064ae:	1e                   	push   %ds
  pushl %es
801064af:	06                   	push   %es
  pushl %fs
801064b0:	0f a0                	push   %fs
  pushl %gs
801064b2:	0f a8                	push   %gs
  pushal
801064b4:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801064b5:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801064b9:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801064bb:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801064bd:	54                   	push   %esp
  call trap
801064be:	e8 d7 01 00 00       	call   8010669a <trap>
  addl $4, %esp
801064c3:	83 c4 04             	add    $0x4,%esp

801064c6 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801064c6:	61                   	popa   
  popl %gs
801064c7:	0f a9                	pop    %gs
  popl %fs
801064c9:	0f a1                	pop    %fs
  popl %es
801064cb:	07                   	pop    %es
  popl %ds
801064cc:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801064cd:	83 c4 08             	add    $0x8,%esp
  iret
801064d0:	cf                   	iret   

801064d1 <lidt>:
{
801064d1:	55                   	push   %ebp
801064d2:	89 e5                	mov    %esp,%ebp
801064d4:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801064d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801064da:	83 e8 01             	sub    $0x1,%eax
801064dd:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801064e1:	8b 45 08             	mov    0x8(%ebp),%eax
801064e4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801064e8:	8b 45 08             	mov    0x8(%ebp),%eax
801064eb:	c1 e8 10             	shr    $0x10,%eax
801064ee:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801064f2:	8d 45 fa             	lea    -0x6(%ebp),%eax
801064f5:	0f 01 18             	lidtl  (%eax)
}
801064f8:	90                   	nop
801064f9:	c9                   	leave  
801064fa:	c3                   	ret    

801064fb <rcr2>:

static inline uint
rcr2(void)
{
801064fb:	55                   	push   %ebp
801064fc:	89 e5                	mov    %esp,%ebp
801064fe:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106501:	0f 20 d0             	mov    %cr2,%eax
80106504:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106507:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010650a:	c9                   	leave  
8010650b:	c3                   	ret    

8010650c <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010650c:	55                   	push   %ebp
8010650d:	89 e5                	mov    %esp,%ebp
8010650f:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106512:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106519:	e9 c3 00 00 00       	jmp    801065e1 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010651e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106521:	8b 04 85 90 f0 10 80 	mov    -0x7fef0f70(,%eax,4),%eax
80106528:	89 c2                	mov    %eax,%edx
8010652a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010652d:	66 89 14 c5 40 6c 19 	mov    %dx,-0x7fe693c0(,%eax,8)
80106534:	80 
80106535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106538:	66 c7 04 c5 42 6c 19 	movw   $0x8,-0x7fe693be(,%eax,8)
8010653f:	80 08 00 
80106542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106545:	0f b6 14 c5 44 6c 19 	movzbl -0x7fe693bc(,%eax,8),%edx
8010654c:	80 
8010654d:	83 e2 e0             	and    $0xffffffe0,%edx
80106550:	88 14 c5 44 6c 19 80 	mov    %dl,-0x7fe693bc(,%eax,8)
80106557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010655a:	0f b6 14 c5 44 6c 19 	movzbl -0x7fe693bc(,%eax,8),%edx
80106561:	80 
80106562:	83 e2 1f             	and    $0x1f,%edx
80106565:	88 14 c5 44 6c 19 80 	mov    %dl,-0x7fe693bc(,%eax,8)
8010656c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010656f:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
80106576:	80 
80106577:	83 e2 f0             	and    $0xfffffff0,%edx
8010657a:	83 ca 0e             	or     $0xe,%edx
8010657d:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
80106584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106587:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
8010658e:	80 
8010658f:	83 e2 ef             	and    $0xffffffef,%edx
80106592:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
80106599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010659c:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
801065a3:	80 
801065a4:	83 e2 9f             	and    $0xffffff9f,%edx
801065a7:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
801065ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b1:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
801065b8:	80 
801065b9:	83 ca 80             	or     $0xffffff80,%edx
801065bc:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
801065c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c6:	8b 04 85 90 f0 10 80 	mov    -0x7fef0f70(,%eax,4),%eax
801065cd:	c1 e8 10             	shr    $0x10,%eax
801065d0:	89 c2                	mov    %eax,%edx
801065d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d5:	66 89 14 c5 46 6c 19 	mov    %dx,-0x7fe693ba(,%eax,8)
801065dc:	80 
  for(i = 0; i < 256; i++)
801065dd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801065e1:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801065e8:	0f 8e 30 ff ff ff    	jle    8010651e <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801065ee:	a1 90 f1 10 80       	mov    0x8010f190,%eax
801065f3:	66 a3 40 6e 19 80    	mov    %ax,0x80196e40
801065f9:	66 c7 05 42 6e 19 80 	movw   $0x8,0x80196e42
80106600:	08 00 
80106602:	0f b6 05 44 6e 19 80 	movzbl 0x80196e44,%eax
80106609:	83 e0 e0             	and    $0xffffffe0,%eax
8010660c:	a2 44 6e 19 80       	mov    %al,0x80196e44
80106611:	0f b6 05 44 6e 19 80 	movzbl 0x80196e44,%eax
80106618:	83 e0 1f             	and    $0x1f,%eax
8010661b:	a2 44 6e 19 80       	mov    %al,0x80196e44
80106620:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
80106627:	83 c8 0f             	or     $0xf,%eax
8010662a:	a2 45 6e 19 80       	mov    %al,0x80196e45
8010662f:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
80106636:	83 e0 ef             	and    $0xffffffef,%eax
80106639:	a2 45 6e 19 80       	mov    %al,0x80196e45
8010663e:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
80106645:	83 c8 60             	or     $0x60,%eax
80106648:	a2 45 6e 19 80       	mov    %al,0x80196e45
8010664d:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
80106654:	83 c8 80             	or     $0xffffff80,%eax
80106657:	a2 45 6e 19 80       	mov    %al,0x80196e45
8010665c:	a1 90 f1 10 80       	mov    0x8010f190,%eax
80106661:	c1 e8 10             	shr    $0x10,%eax
80106664:	66 a3 46 6e 19 80    	mov    %ax,0x80196e46

  initlock(&tickslock, "time");
8010666a:	83 ec 08             	sub    $0x8,%esp
8010666d:	68 40 ac 10 80       	push   $0x8010ac40
80106672:	68 40 74 19 80       	push   $0x80197440
80106677:	e8 87 e4 ff ff       	call   80104b03 <initlock>
8010667c:	83 c4 10             	add    $0x10,%esp
}
8010667f:	90                   	nop
80106680:	c9                   	leave  
80106681:	c3                   	ret    

80106682 <idtinit>:

void
idtinit(void)
{
80106682:	55                   	push   %ebp
80106683:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106685:	68 00 08 00 00       	push   $0x800
8010668a:	68 40 6c 19 80       	push   $0x80196c40
8010668f:	e8 3d fe ff ff       	call   801064d1 <lidt>
80106694:	83 c4 08             	add    $0x8,%esp
}
80106697:	90                   	nop
80106698:	c9                   	leave  
80106699:	c3                   	ret    

8010669a <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010669a:	55                   	push   %ebp
8010669b:	89 e5                	mov    %esp,%ebp
8010669d:	57                   	push   %edi
8010669e:	56                   	push   %esi
8010669f:	53                   	push   %ebx
801066a0:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801066a3:	8b 45 08             	mov    0x8(%ebp),%eax
801066a6:	8b 40 30             	mov    0x30(%eax),%eax
801066a9:	83 f8 40             	cmp    $0x40,%eax
801066ac:	75 3b                	jne    801066e9 <trap+0x4f>
    if(myproc()->killed)
801066ae:	e8 7d d3 ff ff       	call   80103a30 <myproc>
801066b3:	8b 40 24             	mov    0x24(%eax),%eax
801066b6:	85 c0                	test   %eax,%eax
801066b8:	74 05                	je     801066bf <trap+0x25>
      exit();
801066ba:	e8 44 d8 ff ff       	call   80103f03 <exit>
    myproc()->tf = tf;
801066bf:	e8 6c d3 ff ff       	call   80103a30 <myproc>
801066c4:	8b 55 08             	mov    0x8(%ebp),%edx
801066c7:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801066ca:	e8 c3 ea ff ff       	call   80105192 <syscall>
    if(myproc()->killed)
801066cf:	e8 5c d3 ff ff       	call   80103a30 <myproc>
801066d4:	8b 40 24             	mov    0x24(%eax),%eax
801066d7:	85 c0                	test   %eax,%eax
801066d9:	0f 84 68 02 00 00    	je     80106947 <trap+0x2ad>
      exit();
801066df:	e8 1f d8 ff ff       	call   80103f03 <exit>
    return;
801066e4:	e9 5e 02 00 00       	jmp    80106947 <trap+0x2ad>
  }

  switch(tf->trapno){
801066e9:	8b 45 08             	mov    0x8(%ebp),%eax
801066ec:	8b 40 30             	mov    0x30(%eax),%eax
801066ef:	83 e8 20             	sub    $0x20,%eax
801066f2:	83 f8 1f             	cmp    $0x1f,%eax
801066f5:	0f 87 14 01 00 00    	ja     8010680f <trap+0x175>
801066fb:	8b 04 85 e8 ac 10 80 	mov    -0x7fef5318(,%eax,4),%eax
80106702:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106704:	e8 94 d2 ff ff       	call   8010399d <cpuid>
80106709:	85 c0                	test   %eax,%eax
8010670b:	75 3d                	jne    8010674a <trap+0xb0>
      acquire(&tickslock);
8010670d:	83 ec 0c             	sub    $0xc,%esp
80106710:	68 40 74 19 80       	push   $0x80197440
80106715:	e8 0b e4 ff ff       	call   80104b25 <acquire>
8010671a:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010671d:	a1 74 74 19 80       	mov    0x80197474,%eax
80106722:	83 c0 01             	add    $0x1,%eax
80106725:	a3 74 74 19 80       	mov    %eax,0x80197474
      wakeup(&ticks);
8010672a:	83 ec 0c             	sub    $0xc,%esp
8010672d:	68 74 74 19 80       	push   $0x80197474
80106732:	e8 7e e0 ff ff       	call   801047b5 <wakeup>
80106737:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010673a:	83 ec 0c             	sub    $0xc,%esp
8010673d:	68 40 74 19 80       	push   $0x80197440
80106742:	e8 4c e4 ff ff       	call   80104b93 <release>
80106747:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010674a:	e8 cd c3 ff ff       	call   80102b1c <lapiceoi>

    // 🔥 유저모드 + scheduler 설정된 경우만 실행
    struct proc *p = myproc();
8010674f:	e8 dc d2 ff ff       	call   80103a30 <myproc>
80106754:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p && p->state == RUNNING && p->scheduler) {
80106757:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010675b:	0f 84 65 01 00 00    	je     801068c6 <trap+0x22c>
80106761:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106764:	8b 40 0c             	mov    0xc(%eax),%eax
80106767:	83 f8 04             	cmp    $0x4,%eax
8010676a:	0f 85 56 01 00 00    	jne    801068c6 <trap+0x22c>
80106770:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106773:	8b 40 7c             	mov    0x7c(%eax),%eax
80106776:	85 c0                	test   %eax,%eax
80106778:	0f 84 48 01 00 00    	je     801068c6 <trap+0x22c>
      if(p->check_thread >= 2){
8010677e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106781:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106787:	83 f8 01             	cmp    $0x1,%eax
8010678a:	0f 8e 36 01 00 00    	jle    801068c6 <trap+0x22c>
        p->tf->eip = p->scheduler;
80106790:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106793:	8b 40 18             	mov    0x18(%eax),%eax
80106796:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106799:	8b 52 7c             	mov    0x7c(%edx),%edx
8010679c:	89 50 38             	mov    %edx,0x38(%eax)
      }
    }
    

    break;
8010679f:	e9 22 01 00 00       	jmp    801068c6 <trap+0x22c>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801067a4:	e8 f8 3e 00 00       	call   8010a6a1 <ideintr>
    lapiceoi();
801067a9:	e8 6e c3 ff ff       	call   80102b1c <lapiceoi>
    break;
801067ae:	e9 14 01 00 00       	jmp    801068c7 <trap+0x22d>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801067b3:	e8 a9 c1 ff ff       	call   80102961 <kbdintr>
    lapiceoi();
801067b8:	e8 5f c3 ff ff       	call   80102b1c <lapiceoi>
    break;
801067bd:	e9 05 01 00 00       	jmp    801068c7 <trap+0x22d>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801067c2:	e8 56 03 00 00       	call   80106b1d <uartintr>
    lapiceoi();
801067c7:	e8 50 c3 ff ff       	call   80102b1c <lapiceoi>
    break;
801067cc:	e9 f6 00 00 00       	jmp    801068c7 <trap+0x22d>
  case T_IRQ0 + 0xB:
    i8254_intr();
801067d1:	e8 7e 2b 00 00       	call   80109354 <i8254_intr>
    lapiceoi();
801067d6:	e8 41 c3 ff ff       	call   80102b1c <lapiceoi>
    break;
801067db:	e9 e7 00 00 00       	jmp    801068c7 <trap+0x22d>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067e0:	8b 45 08             	mov    0x8(%ebp),%eax
801067e3:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801067e6:	8b 45 08             	mov    0x8(%ebp),%eax
801067e9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067ed:	0f b7 d8             	movzwl %ax,%ebx
801067f0:	e8 a8 d1 ff ff       	call   8010399d <cpuid>
801067f5:	56                   	push   %esi
801067f6:	53                   	push   %ebx
801067f7:	50                   	push   %eax
801067f8:	68 48 ac 10 80       	push   $0x8010ac48
801067fd:	e8 f2 9b ff ff       	call   801003f4 <cprintf>
80106802:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106805:	e8 12 c3 ff ff       	call   80102b1c <lapiceoi>
    break;
8010680a:	e9 b8 00 00 00       	jmp    801068c7 <trap+0x22d>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010680f:	e8 1c d2 ff ff       	call   80103a30 <myproc>
80106814:	85 c0                	test   %eax,%eax
80106816:	74 11                	je     80106829 <trap+0x18f>
80106818:	8b 45 08             	mov    0x8(%ebp),%eax
8010681b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010681f:	0f b7 c0             	movzwl %ax,%eax
80106822:	83 e0 03             	and    $0x3,%eax
80106825:	85 c0                	test   %eax,%eax
80106827:	75 39                	jne    80106862 <trap+0x1c8>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106829:	e8 cd fc ff ff       	call   801064fb <rcr2>
8010682e:	89 c3                	mov    %eax,%ebx
80106830:	8b 45 08             	mov    0x8(%ebp),%eax
80106833:	8b 70 38             	mov    0x38(%eax),%esi
80106836:	e8 62 d1 ff ff       	call   8010399d <cpuid>
8010683b:	8b 55 08             	mov    0x8(%ebp),%edx
8010683e:	8b 52 30             	mov    0x30(%edx),%edx
80106841:	83 ec 0c             	sub    $0xc,%esp
80106844:	53                   	push   %ebx
80106845:	56                   	push   %esi
80106846:	50                   	push   %eax
80106847:	52                   	push   %edx
80106848:	68 6c ac 10 80       	push   $0x8010ac6c
8010684d:	e8 a2 9b ff ff       	call   801003f4 <cprintf>
80106852:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106855:	83 ec 0c             	sub    $0xc,%esp
80106858:	68 9e ac 10 80       	push   $0x8010ac9e
8010685d:	e8 47 9d ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106862:	e8 94 fc ff ff       	call   801064fb <rcr2>
80106867:	89 c6                	mov    %eax,%esi
80106869:	8b 45 08             	mov    0x8(%ebp),%eax
8010686c:	8b 40 38             	mov    0x38(%eax),%eax
8010686f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106872:	e8 26 d1 ff ff       	call   8010399d <cpuid>
80106877:	89 c3                	mov    %eax,%ebx
80106879:	8b 45 08             	mov    0x8(%ebp),%eax
8010687c:	8b 48 34             	mov    0x34(%eax),%ecx
8010687f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106882:	8b 45 08             	mov    0x8(%ebp),%eax
80106885:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106888:	e8 a3 d1 ff ff       	call   80103a30 <myproc>
8010688d:	8d 50 6c             	lea    0x6c(%eax),%edx
80106890:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106893:	e8 98 d1 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106898:	8b 40 10             	mov    0x10(%eax),%eax
8010689b:	56                   	push   %esi
8010689c:	ff 75 d4             	push   -0x2c(%ebp)
8010689f:	53                   	push   %ebx
801068a0:	ff 75 d0             	push   -0x30(%ebp)
801068a3:	57                   	push   %edi
801068a4:	ff 75 cc             	push   -0x34(%ebp)
801068a7:	50                   	push   %eax
801068a8:	68 a4 ac 10 80       	push   $0x8010aca4
801068ad:	e8 42 9b ff ff       	call   801003f4 <cprintf>
801068b2:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801068b5:	e8 76 d1 ff ff       	call   80103a30 <myproc>
801068ba:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801068c1:	eb 04                	jmp    801068c7 <trap+0x22d>
    break;
801068c3:	90                   	nop
801068c4:	eb 01                	jmp    801068c7 <trap+0x22d>
    break;
801068c6:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801068c7:	e8 64 d1 ff ff       	call   80103a30 <myproc>
801068cc:	85 c0                	test   %eax,%eax
801068ce:	74 23                	je     801068f3 <trap+0x259>
801068d0:	e8 5b d1 ff ff       	call   80103a30 <myproc>
801068d5:	8b 40 24             	mov    0x24(%eax),%eax
801068d8:	85 c0                	test   %eax,%eax
801068da:	74 17                	je     801068f3 <trap+0x259>
801068dc:	8b 45 08             	mov    0x8(%ebp),%eax
801068df:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801068e3:	0f b7 c0             	movzwl %ax,%eax
801068e6:	83 e0 03             	and    $0x3,%eax
801068e9:	83 f8 03             	cmp    $0x3,%eax
801068ec:	75 05                	jne    801068f3 <trap+0x259>
    exit();
801068ee:	e8 10 d6 ff ff       	call   80103f03 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801068f3:	e8 38 d1 ff ff       	call   80103a30 <myproc>
801068f8:	85 c0                	test   %eax,%eax
801068fa:	74 1d                	je     80106919 <trap+0x27f>
801068fc:	e8 2f d1 ff ff       	call   80103a30 <myproc>
80106901:	8b 40 0c             	mov    0xc(%eax),%eax
80106904:	83 f8 04             	cmp    $0x4,%eax
80106907:	75 10                	jne    80106919 <trap+0x27f>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106909:	8b 45 08             	mov    0x8(%ebp),%eax
8010690c:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
8010690f:	83 f8 20             	cmp    $0x20,%eax
80106912:	75 05                	jne    80106919 <trap+0x27f>
    yield();
80106914:	e8 f1 dc ff ff       	call   8010460a <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106919:	e8 12 d1 ff ff       	call   80103a30 <myproc>
8010691e:	85 c0                	test   %eax,%eax
80106920:	74 26                	je     80106948 <trap+0x2ae>
80106922:	e8 09 d1 ff ff       	call   80103a30 <myproc>
80106927:	8b 40 24             	mov    0x24(%eax),%eax
8010692a:	85 c0                	test   %eax,%eax
8010692c:	74 1a                	je     80106948 <trap+0x2ae>
8010692e:	8b 45 08             	mov    0x8(%ebp),%eax
80106931:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106935:	0f b7 c0             	movzwl %ax,%eax
80106938:	83 e0 03             	and    $0x3,%eax
8010693b:	83 f8 03             	cmp    $0x3,%eax
8010693e:	75 08                	jne    80106948 <trap+0x2ae>
    exit();
80106940:	e8 be d5 ff ff       	call   80103f03 <exit>
80106945:	eb 01                	jmp    80106948 <trap+0x2ae>
    return;
80106947:	90                   	nop
}
80106948:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010694b:	5b                   	pop    %ebx
8010694c:	5e                   	pop    %esi
8010694d:	5f                   	pop    %edi
8010694e:	5d                   	pop    %ebp
8010694f:	c3                   	ret    

80106950 <inb>:
{
80106950:	55                   	push   %ebp
80106951:	89 e5                	mov    %esp,%ebp
80106953:	83 ec 14             	sub    $0x14,%esp
80106956:	8b 45 08             	mov    0x8(%ebp),%eax
80106959:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010695d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106961:	89 c2                	mov    %eax,%edx
80106963:	ec                   	in     (%dx),%al
80106964:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106967:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010696b:	c9                   	leave  
8010696c:	c3                   	ret    

8010696d <outb>:
{
8010696d:	55                   	push   %ebp
8010696e:	89 e5                	mov    %esp,%ebp
80106970:	83 ec 08             	sub    $0x8,%esp
80106973:	8b 45 08             	mov    0x8(%ebp),%eax
80106976:	8b 55 0c             	mov    0xc(%ebp),%edx
80106979:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010697d:	89 d0                	mov    %edx,%eax
8010697f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106982:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106986:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010698a:	ee                   	out    %al,(%dx)
}
8010698b:	90                   	nop
8010698c:	c9                   	leave  
8010698d:	c3                   	ret    

8010698e <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010698e:	55                   	push   %ebp
8010698f:	89 e5                	mov    %esp,%ebp
80106991:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106994:	6a 00                	push   $0x0
80106996:	68 fa 03 00 00       	push   $0x3fa
8010699b:	e8 cd ff ff ff       	call   8010696d <outb>
801069a0:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801069a3:	68 80 00 00 00       	push   $0x80
801069a8:	68 fb 03 00 00       	push   $0x3fb
801069ad:	e8 bb ff ff ff       	call   8010696d <outb>
801069b2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801069b5:	6a 0c                	push   $0xc
801069b7:	68 f8 03 00 00       	push   $0x3f8
801069bc:	e8 ac ff ff ff       	call   8010696d <outb>
801069c1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801069c4:	6a 00                	push   $0x0
801069c6:	68 f9 03 00 00       	push   $0x3f9
801069cb:	e8 9d ff ff ff       	call   8010696d <outb>
801069d0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801069d3:	6a 03                	push   $0x3
801069d5:	68 fb 03 00 00       	push   $0x3fb
801069da:	e8 8e ff ff ff       	call   8010696d <outb>
801069df:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801069e2:	6a 00                	push   $0x0
801069e4:	68 fc 03 00 00       	push   $0x3fc
801069e9:	e8 7f ff ff ff       	call   8010696d <outb>
801069ee:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801069f1:	6a 01                	push   $0x1
801069f3:	68 f9 03 00 00       	push   $0x3f9
801069f8:	e8 70 ff ff ff       	call   8010696d <outb>
801069fd:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106a00:	68 fd 03 00 00       	push   $0x3fd
80106a05:	e8 46 ff ff ff       	call   80106950 <inb>
80106a0a:	83 c4 04             	add    $0x4,%esp
80106a0d:	3c ff                	cmp    $0xff,%al
80106a0f:	74 61                	je     80106a72 <uartinit+0xe4>
    return;
  uart = 1;
80106a11:	c7 05 78 74 19 80 01 	movl   $0x1,0x80197478
80106a18:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106a1b:	68 fa 03 00 00       	push   $0x3fa
80106a20:	e8 2b ff ff ff       	call   80106950 <inb>
80106a25:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106a28:	68 f8 03 00 00       	push   $0x3f8
80106a2d:	e8 1e ff ff ff       	call   80106950 <inb>
80106a32:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106a35:	83 ec 08             	sub    $0x8,%esp
80106a38:	6a 00                	push   $0x0
80106a3a:	6a 04                	push   $0x4
80106a3c:	e8 ed bb ff ff       	call   8010262e <ioapicenable>
80106a41:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106a44:	c7 45 f4 68 ad 10 80 	movl   $0x8010ad68,-0xc(%ebp)
80106a4b:	eb 19                	jmp    80106a66 <uartinit+0xd8>
    uartputc(*p);
80106a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a50:	0f b6 00             	movzbl (%eax),%eax
80106a53:	0f be c0             	movsbl %al,%eax
80106a56:	83 ec 0c             	sub    $0xc,%esp
80106a59:	50                   	push   %eax
80106a5a:	e8 16 00 00 00       	call   80106a75 <uartputc>
80106a5f:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106a62:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a69:	0f b6 00             	movzbl (%eax),%eax
80106a6c:	84 c0                	test   %al,%al
80106a6e:	75 dd                	jne    80106a4d <uartinit+0xbf>
80106a70:	eb 01                	jmp    80106a73 <uartinit+0xe5>
    return;
80106a72:	90                   	nop
}
80106a73:	c9                   	leave  
80106a74:	c3                   	ret    

80106a75 <uartputc>:

void
uartputc(int c)
{
80106a75:	55                   	push   %ebp
80106a76:	89 e5                	mov    %esp,%ebp
80106a78:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106a7b:	a1 78 74 19 80       	mov    0x80197478,%eax
80106a80:	85 c0                	test   %eax,%eax
80106a82:	74 53                	je     80106ad7 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a84:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a8b:	eb 11                	jmp    80106a9e <uartputc+0x29>
    microdelay(10);
80106a8d:	83 ec 0c             	sub    $0xc,%esp
80106a90:	6a 0a                	push   $0xa
80106a92:	e8 a0 c0 ff ff       	call   80102b37 <microdelay>
80106a97:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a9a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a9e:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106aa2:	7f 1a                	jg     80106abe <uartputc+0x49>
80106aa4:	83 ec 0c             	sub    $0xc,%esp
80106aa7:	68 fd 03 00 00       	push   $0x3fd
80106aac:	e8 9f fe ff ff       	call   80106950 <inb>
80106ab1:	83 c4 10             	add    $0x10,%esp
80106ab4:	0f b6 c0             	movzbl %al,%eax
80106ab7:	83 e0 20             	and    $0x20,%eax
80106aba:	85 c0                	test   %eax,%eax
80106abc:	74 cf                	je     80106a8d <uartputc+0x18>
  outb(COM1+0, c);
80106abe:	8b 45 08             	mov    0x8(%ebp),%eax
80106ac1:	0f b6 c0             	movzbl %al,%eax
80106ac4:	83 ec 08             	sub    $0x8,%esp
80106ac7:	50                   	push   %eax
80106ac8:	68 f8 03 00 00       	push   $0x3f8
80106acd:	e8 9b fe ff ff       	call   8010696d <outb>
80106ad2:	83 c4 10             	add    $0x10,%esp
80106ad5:	eb 01                	jmp    80106ad8 <uartputc+0x63>
    return;
80106ad7:	90                   	nop
}
80106ad8:	c9                   	leave  
80106ad9:	c3                   	ret    

80106ada <uartgetc>:

static int
uartgetc(void)
{
80106ada:	55                   	push   %ebp
80106adb:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106add:	a1 78 74 19 80       	mov    0x80197478,%eax
80106ae2:	85 c0                	test   %eax,%eax
80106ae4:	75 07                	jne    80106aed <uartgetc+0x13>
    return -1;
80106ae6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aeb:	eb 2e                	jmp    80106b1b <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106aed:	68 fd 03 00 00       	push   $0x3fd
80106af2:	e8 59 fe ff ff       	call   80106950 <inb>
80106af7:	83 c4 04             	add    $0x4,%esp
80106afa:	0f b6 c0             	movzbl %al,%eax
80106afd:	83 e0 01             	and    $0x1,%eax
80106b00:	85 c0                	test   %eax,%eax
80106b02:	75 07                	jne    80106b0b <uartgetc+0x31>
    return -1;
80106b04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b09:	eb 10                	jmp    80106b1b <uartgetc+0x41>
  return inb(COM1+0);
80106b0b:	68 f8 03 00 00       	push   $0x3f8
80106b10:	e8 3b fe ff ff       	call   80106950 <inb>
80106b15:	83 c4 04             	add    $0x4,%esp
80106b18:	0f b6 c0             	movzbl %al,%eax
}
80106b1b:	c9                   	leave  
80106b1c:	c3                   	ret    

80106b1d <uartintr>:

void
uartintr(void)
{
80106b1d:	55                   	push   %ebp
80106b1e:	89 e5                	mov    %esp,%ebp
80106b20:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106b23:	83 ec 0c             	sub    $0xc,%esp
80106b26:	68 da 6a 10 80       	push   $0x80106ada
80106b2b:	e8 a6 9c ff ff       	call   801007d6 <consoleintr>
80106b30:	83 c4 10             	add    $0x10,%esp
}
80106b33:	90                   	nop
80106b34:	c9                   	leave  
80106b35:	c3                   	ret    

80106b36 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106b36:	6a 00                	push   $0x0
  pushl $0
80106b38:	6a 00                	push   $0x0
  jmp alltraps
80106b3a:	e9 6f f9 ff ff       	jmp    801064ae <alltraps>

80106b3f <vector1>:
.globl vector1
vector1:
  pushl $0
80106b3f:	6a 00                	push   $0x0
  pushl $1
80106b41:	6a 01                	push   $0x1
  jmp alltraps
80106b43:	e9 66 f9 ff ff       	jmp    801064ae <alltraps>

80106b48 <vector2>:
.globl vector2
vector2:
  pushl $0
80106b48:	6a 00                	push   $0x0
  pushl $2
80106b4a:	6a 02                	push   $0x2
  jmp alltraps
80106b4c:	e9 5d f9 ff ff       	jmp    801064ae <alltraps>

80106b51 <vector3>:
.globl vector3
vector3:
  pushl $0
80106b51:	6a 00                	push   $0x0
  pushl $3
80106b53:	6a 03                	push   $0x3
  jmp alltraps
80106b55:	e9 54 f9 ff ff       	jmp    801064ae <alltraps>

80106b5a <vector4>:
.globl vector4
vector4:
  pushl $0
80106b5a:	6a 00                	push   $0x0
  pushl $4
80106b5c:	6a 04                	push   $0x4
  jmp alltraps
80106b5e:	e9 4b f9 ff ff       	jmp    801064ae <alltraps>

80106b63 <vector5>:
.globl vector5
vector5:
  pushl $0
80106b63:	6a 00                	push   $0x0
  pushl $5
80106b65:	6a 05                	push   $0x5
  jmp alltraps
80106b67:	e9 42 f9 ff ff       	jmp    801064ae <alltraps>

80106b6c <vector6>:
.globl vector6
vector6:
  pushl $0
80106b6c:	6a 00                	push   $0x0
  pushl $6
80106b6e:	6a 06                	push   $0x6
  jmp alltraps
80106b70:	e9 39 f9 ff ff       	jmp    801064ae <alltraps>

80106b75 <vector7>:
.globl vector7
vector7:
  pushl $0
80106b75:	6a 00                	push   $0x0
  pushl $7
80106b77:	6a 07                	push   $0x7
  jmp alltraps
80106b79:	e9 30 f9 ff ff       	jmp    801064ae <alltraps>

80106b7e <vector8>:
.globl vector8
vector8:
  pushl $8
80106b7e:	6a 08                	push   $0x8
  jmp alltraps
80106b80:	e9 29 f9 ff ff       	jmp    801064ae <alltraps>

80106b85 <vector9>:
.globl vector9
vector9:
  pushl $0
80106b85:	6a 00                	push   $0x0
  pushl $9
80106b87:	6a 09                	push   $0x9
  jmp alltraps
80106b89:	e9 20 f9 ff ff       	jmp    801064ae <alltraps>

80106b8e <vector10>:
.globl vector10
vector10:
  pushl $10
80106b8e:	6a 0a                	push   $0xa
  jmp alltraps
80106b90:	e9 19 f9 ff ff       	jmp    801064ae <alltraps>

80106b95 <vector11>:
.globl vector11
vector11:
  pushl $11
80106b95:	6a 0b                	push   $0xb
  jmp alltraps
80106b97:	e9 12 f9 ff ff       	jmp    801064ae <alltraps>

80106b9c <vector12>:
.globl vector12
vector12:
  pushl $12
80106b9c:	6a 0c                	push   $0xc
  jmp alltraps
80106b9e:	e9 0b f9 ff ff       	jmp    801064ae <alltraps>

80106ba3 <vector13>:
.globl vector13
vector13:
  pushl $13
80106ba3:	6a 0d                	push   $0xd
  jmp alltraps
80106ba5:	e9 04 f9 ff ff       	jmp    801064ae <alltraps>

80106baa <vector14>:
.globl vector14
vector14:
  pushl $14
80106baa:	6a 0e                	push   $0xe
  jmp alltraps
80106bac:	e9 fd f8 ff ff       	jmp    801064ae <alltraps>

80106bb1 <vector15>:
.globl vector15
vector15:
  pushl $0
80106bb1:	6a 00                	push   $0x0
  pushl $15
80106bb3:	6a 0f                	push   $0xf
  jmp alltraps
80106bb5:	e9 f4 f8 ff ff       	jmp    801064ae <alltraps>

80106bba <vector16>:
.globl vector16
vector16:
  pushl $0
80106bba:	6a 00                	push   $0x0
  pushl $16
80106bbc:	6a 10                	push   $0x10
  jmp alltraps
80106bbe:	e9 eb f8 ff ff       	jmp    801064ae <alltraps>

80106bc3 <vector17>:
.globl vector17
vector17:
  pushl $17
80106bc3:	6a 11                	push   $0x11
  jmp alltraps
80106bc5:	e9 e4 f8 ff ff       	jmp    801064ae <alltraps>

80106bca <vector18>:
.globl vector18
vector18:
  pushl $0
80106bca:	6a 00                	push   $0x0
  pushl $18
80106bcc:	6a 12                	push   $0x12
  jmp alltraps
80106bce:	e9 db f8 ff ff       	jmp    801064ae <alltraps>

80106bd3 <vector19>:
.globl vector19
vector19:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $19
80106bd5:	6a 13                	push   $0x13
  jmp alltraps
80106bd7:	e9 d2 f8 ff ff       	jmp    801064ae <alltraps>

80106bdc <vector20>:
.globl vector20
vector20:
  pushl $0
80106bdc:	6a 00                	push   $0x0
  pushl $20
80106bde:	6a 14                	push   $0x14
  jmp alltraps
80106be0:	e9 c9 f8 ff ff       	jmp    801064ae <alltraps>

80106be5 <vector21>:
.globl vector21
vector21:
  pushl $0
80106be5:	6a 00                	push   $0x0
  pushl $21
80106be7:	6a 15                	push   $0x15
  jmp alltraps
80106be9:	e9 c0 f8 ff ff       	jmp    801064ae <alltraps>

80106bee <vector22>:
.globl vector22
vector22:
  pushl $0
80106bee:	6a 00                	push   $0x0
  pushl $22
80106bf0:	6a 16                	push   $0x16
  jmp alltraps
80106bf2:	e9 b7 f8 ff ff       	jmp    801064ae <alltraps>

80106bf7 <vector23>:
.globl vector23
vector23:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $23
80106bf9:	6a 17                	push   $0x17
  jmp alltraps
80106bfb:	e9 ae f8 ff ff       	jmp    801064ae <alltraps>

80106c00 <vector24>:
.globl vector24
vector24:
  pushl $0
80106c00:	6a 00                	push   $0x0
  pushl $24
80106c02:	6a 18                	push   $0x18
  jmp alltraps
80106c04:	e9 a5 f8 ff ff       	jmp    801064ae <alltraps>

80106c09 <vector25>:
.globl vector25
vector25:
  pushl $0
80106c09:	6a 00                	push   $0x0
  pushl $25
80106c0b:	6a 19                	push   $0x19
  jmp alltraps
80106c0d:	e9 9c f8 ff ff       	jmp    801064ae <alltraps>

80106c12 <vector26>:
.globl vector26
vector26:
  pushl $0
80106c12:	6a 00                	push   $0x0
  pushl $26
80106c14:	6a 1a                	push   $0x1a
  jmp alltraps
80106c16:	e9 93 f8 ff ff       	jmp    801064ae <alltraps>

80106c1b <vector27>:
.globl vector27
vector27:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $27
80106c1d:	6a 1b                	push   $0x1b
  jmp alltraps
80106c1f:	e9 8a f8 ff ff       	jmp    801064ae <alltraps>

80106c24 <vector28>:
.globl vector28
vector28:
  pushl $0
80106c24:	6a 00                	push   $0x0
  pushl $28
80106c26:	6a 1c                	push   $0x1c
  jmp alltraps
80106c28:	e9 81 f8 ff ff       	jmp    801064ae <alltraps>

80106c2d <vector29>:
.globl vector29
vector29:
  pushl $0
80106c2d:	6a 00                	push   $0x0
  pushl $29
80106c2f:	6a 1d                	push   $0x1d
  jmp alltraps
80106c31:	e9 78 f8 ff ff       	jmp    801064ae <alltraps>

80106c36 <vector30>:
.globl vector30
vector30:
  pushl $0
80106c36:	6a 00                	push   $0x0
  pushl $30
80106c38:	6a 1e                	push   $0x1e
  jmp alltraps
80106c3a:	e9 6f f8 ff ff       	jmp    801064ae <alltraps>

80106c3f <vector31>:
.globl vector31
vector31:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $31
80106c41:	6a 1f                	push   $0x1f
  jmp alltraps
80106c43:	e9 66 f8 ff ff       	jmp    801064ae <alltraps>

80106c48 <vector32>:
.globl vector32
vector32:
  pushl $0
80106c48:	6a 00                	push   $0x0
  pushl $32
80106c4a:	6a 20                	push   $0x20
  jmp alltraps
80106c4c:	e9 5d f8 ff ff       	jmp    801064ae <alltraps>

80106c51 <vector33>:
.globl vector33
vector33:
  pushl $0
80106c51:	6a 00                	push   $0x0
  pushl $33
80106c53:	6a 21                	push   $0x21
  jmp alltraps
80106c55:	e9 54 f8 ff ff       	jmp    801064ae <alltraps>

80106c5a <vector34>:
.globl vector34
vector34:
  pushl $0
80106c5a:	6a 00                	push   $0x0
  pushl $34
80106c5c:	6a 22                	push   $0x22
  jmp alltraps
80106c5e:	e9 4b f8 ff ff       	jmp    801064ae <alltraps>

80106c63 <vector35>:
.globl vector35
vector35:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $35
80106c65:	6a 23                	push   $0x23
  jmp alltraps
80106c67:	e9 42 f8 ff ff       	jmp    801064ae <alltraps>

80106c6c <vector36>:
.globl vector36
vector36:
  pushl $0
80106c6c:	6a 00                	push   $0x0
  pushl $36
80106c6e:	6a 24                	push   $0x24
  jmp alltraps
80106c70:	e9 39 f8 ff ff       	jmp    801064ae <alltraps>

80106c75 <vector37>:
.globl vector37
vector37:
  pushl $0
80106c75:	6a 00                	push   $0x0
  pushl $37
80106c77:	6a 25                	push   $0x25
  jmp alltraps
80106c79:	e9 30 f8 ff ff       	jmp    801064ae <alltraps>

80106c7e <vector38>:
.globl vector38
vector38:
  pushl $0
80106c7e:	6a 00                	push   $0x0
  pushl $38
80106c80:	6a 26                	push   $0x26
  jmp alltraps
80106c82:	e9 27 f8 ff ff       	jmp    801064ae <alltraps>

80106c87 <vector39>:
.globl vector39
vector39:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $39
80106c89:	6a 27                	push   $0x27
  jmp alltraps
80106c8b:	e9 1e f8 ff ff       	jmp    801064ae <alltraps>

80106c90 <vector40>:
.globl vector40
vector40:
  pushl $0
80106c90:	6a 00                	push   $0x0
  pushl $40
80106c92:	6a 28                	push   $0x28
  jmp alltraps
80106c94:	e9 15 f8 ff ff       	jmp    801064ae <alltraps>

80106c99 <vector41>:
.globl vector41
vector41:
  pushl $0
80106c99:	6a 00                	push   $0x0
  pushl $41
80106c9b:	6a 29                	push   $0x29
  jmp alltraps
80106c9d:	e9 0c f8 ff ff       	jmp    801064ae <alltraps>

80106ca2 <vector42>:
.globl vector42
vector42:
  pushl $0
80106ca2:	6a 00                	push   $0x0
  pushl $42
80106ca4:	6a 2a                	push   $0x2a
  jmp alltraps
80106ca6:	e9 03 f8 ff ff       	jmp    801064ae <alltraps>

80106cab <vector43>:
.globl vector43
vector43:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $43
80106cad:	6a 2b                	push   $0x2b
  jmp alltraps
80106caf:	e9 fa f7 ff ff       	jmp    801064ae <alltraps>

80106cb4 <vector44>:
.globl vector44
vector44:
  pushl $0
80106cb4:	6a 00                	push   $0x0
  pushl $44
80106cb6:	6a 2c                	push   $0x2c
  jmp alltraps
80106cb8:	e9 f1 f7 ff ff       	jmp    801064ae <alltraps>

80106cbd <vector45>:
.globl vector45
vector45:
  pushl $0
80106cbd:	6a 00                	push   $0x0
  pushl $45
80106cbf:	6a 2d                	push   $0x2d
  jmp alltraps
80106cc1:	e9 e8 f7 ff ff       	jmp    801064ae <alltraps>

80106cc6 <vector46>:
.globl vector46
vector46:
  pushl $0
80106cc6:	6a 00                	push   $0x0
  pushl $46
80106cc8:	6a 2e                	push   $0x2e
  jmp alltraps
80106cca:	e9 df f7 ff ff       	jmp    801064ae <alltraps>

80106ccf <vector47>:
.globl vector47
vector47:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $47
80106cd1:	6a 2f                	push   $0x2f
  jmp alltraps
80106cd3:	e9 d6 f7 ff ff       	jmp    801064ae <alltraps>

80106cd8 <vector48>:
.globl vector48
vector48:
  pushl $0
80106cd8:	6a 00                	push   $0x0
  pushl $48
80106cda:	6a 30                	push   $0x30
  jmp alltraps
80106cdc:	e9 cd f7 ff ff       	jmp    801064ae <alltraps>

80106ce1 <vector49>:
.globl vector49
vector49:
  pushl $0
80106ce1:	6a 00                	push   $0x0
  pushl $49
80106ce3:	6a 31                	push   $0x31
  jmp alltraps
80106ce5:	e9 c4 f7 ff ff       	jmp    801064ae <alltraps>

80106cea <vector50>:
.globl vector50
vector50:
  pushl $0
80106cea:	6a 00                	push   $0x0
  pushl $50
80106cec:	6a 32                	push   $0x32
  jmp alltraps
80106cee:	e9 bb f7 ff ff       	jmp    801064ae <alltraps>

80106cf3 <vector51>:
.globl vector51
vector51:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $51
80106cf5:	6a 33                	push   $0x33
  jmp alltraps
80106cf7:	e9 b2 f7 ff ff       	jmp    801064ae <alltraps>

80106cfc <vector52>:
.globl vector52
vector52:
  pushl $0
80106cfc:	6a 00                	push   $0x0
  pushl $52
80106cfe:	6a 34                	push   $0x34
  jmp alltraps
80106d00:	e9 a9 f7 ff ff       	jmp    801064ae <alltraps>

80106d05 <vector53>:
.globl vector53
vector53:
  pushl $0
80106d05:	6a 00                	push   $0x0
  pushl $53
80106d07:	6a 35                	push   $0x35
  jmp alltraps
80106d09:	e9 a0 f7 ff ff       	jmp    801064ae <alltraps>

80106d0e <vector54>:
.globl vector54
vector54:
  pushl $0
80106d0e:	6a 00                	push   $0x0
  pushl $54
80106d10:	6a 36                	push   $0x36
  jmp alltraps
80106d12:	e9 97 f7 ff ff       	jmp    801064ae <alltraps>

80106d17 <vector55>:
.globl vector55
vector55:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $55
80106d19:	6a 37                	push   $0x37
  jmp alltraps
80106d1b:	e9 8e f7 ff ff       	jmp    801064ae <alltraps>

80106d20 <vector56>:
.globl vector56
vector56:
  pushl $0
80106d20:	6a 00                	push   $0x0
  pushl $56
80106d22:	6a 38                	push   $0x38
  jmp alltraps
80106d24:	e9 85 f7 ff ff       	jmp    801064ae <alltraps>

80106d29 <vector57>:
.globl vector57
vector57:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $57
80106d2b:	6a 39                	push   $0x39
  jmp alltraps
80106d2d:	e9 7c f7 ff ff       	jmp    801064ae <alltraps>

80106d32 <vector58>:
.globl vector58
vector58:
  pushl $0
80106d32:	6a 00                	push   $0x0
  pushl $58
80106d34:	6a 3a                	push   $0x3a
  jmp alltraps
80106d36:	e9 73 f7 ff ff       	jmp    801064ae <alltraps>

80106d3b <vector59>:
.globl vector59
vector59:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $59
80106d3d:	6a 3b                	push   $0x3b
  jmp alltraps
80106d3f:	e9 6a f7 ff ff       	jmp    801064ae <alltraps>

80106d44 <vector60>:
.globl vector60
vector60:
  pushl $0
80106d44:	6a 00                	push   $0x0
  pushl $60
80106d46:	6a 3c                	push   $0x3c
  jmp alltraps
80106d48:	e9 61 f7 ff ff       	jmp    801064ae <alltraps>

80106d4d <vector61>:
.globl vector61
vector61:
  pushl $0
80106d4d:	6a 00                	push   $0x0
  pushl $61
80106d4f:	6a 3d                	push   $0x3d
  jmp alltraps
80106d51:	e9 58 f7 ff ff       	jmp    801064ae <alltraps>

80106d56 <vector62>:
.globl vector62
vector62:
  pushl $0
80106d56:	6a 00                	push   $0x0
  pushl $62
80106d58:	6a 3e                	push   $0x3e
  jmp alltraps
80106d5a:	e9 4f f7 ff ff       	jmp    801064ae <alltraps>

80106d5f <vector63>:
.globl vector63
vector63:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $63
80106d61:	6a 3f                	push   $0x3f
  jmp alltraps
80106d63:	e9 46 f7 ff ff       	jmp    801064ae <alltraps>

80106d68 <vector64>:
.globl vector64
vector64:
  pushl $0
80106d68:	6a 00                	push   $0x0
  pushl $64
80106d6a:	6a 40                	push   $0x40
  jmp alltraps
80106d6c:	e9 3d f7 ff ff       	jmp    801064ae <alltraps>

80106d71 <vector65>:
.globl vector65
vector65:
  pushl $0
80106d71:	6a 00                	push   $0x0
  pushl $65
80106d73:	6a 41                	push   $0x41
  jmp alltraps
80106d75:	e9 34 f7 ff ff       	jmp    801064ae <alltraps>

80106d7a <vector66>:
.globl vector66
vector66:
  pushl $0
80106d7a:	6a 00                	push   $0x0
  pushl $66
80106d7c:	6a 42                	push   $0x42
  jmp alltraps
80106d7e:	e9 2b f7 ff ff       	jmp    801064ae <alltraps>

80106d83 <vector67>:
.globl vector67
vector67:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $67
80106d85:	6a 43                	push   $0x43
  jmp alltraps
80106d87:	e9 22 f7 ff ff       	jmp    801064ae <alltraps>

80106d8c <vector68>:
.globl vector68
vector68:
  pushl $0
80106d8c:	6a 00                	push   $0x0
  pushl $68
80106d8e:	6a 44                	push   $0x44
  jmp alltraps
80106d90:	e9 19 f7 ff ff       	jmp    801064ae <alltraps>

80106d95 <vector69>:
.globl vector69
vector69:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $69
80106d97:	6a 45                	push   $0x45
  jmp alltraps
80106d99:	e9 10 f7 ff ff       	jmp    801064ae <alltraps>

80106d9e <vector70>:
.globl vector70
vector70:
  pushl $0
80106d9e:	6a 00                	push   $0x0
  pushl $70
80106da0:	6a 46                	push   $0x46
  jmp alltraps
80106da2:	e9 07 f7 ff ff       	jmp    801064ae <alltraps>

80106da7 <vector71>:
.globl vector71
vector71:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $71
80106da9:	6a 47                	push   $0x47
  jmp alltraps
80106dab:	e9 fe f6 ff ff       	jmp    801064ae <alltraps>

80106db0 <vector72>:
.globl vector72
vector72:
  pushl $0
80106db0:	6a 00                	push   $0x0
  pushl $72
80106db2:	6a 48                	push   $0x48
  jmp alltraps
80106db4:	e9 f5 f6 ff ff       	jmp    801064ae <alltraps>

80106db9 <vector73>:
.globl vector73
vector73:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $73
80106dbb:	6a 49                	push   $0x49
  jmp alltraps
80106dbd:	e9 ec f6 ff ff       	jmp    801064ae <alltraps>

80106dc2 <vector74>:
.globl vector74
vector74:
  pushl $0
80106dc2:	6a 00                	push   $0x0
  pushl $74
80106dc4:	6a 4a                	push   $0x4a
  jmp alltraps
80106dc6:	e9 e3 f6 ff ff       	jmp    801064ae <alltraps>

80106dcb <vector75>:
.globl vector75
vector75:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $75
80106dcd:	6a 4b                	push   $0x4b
  jmp alltraps
80106dcf:	e9 da f6 ff ff       	jmp    801064ae <alltraps>

80106dd4 <vector76>:
.globl vector76
vector76:
  pushl $0
80106dd4:	6a 00                	push   $0x0
  pushl $76
80106dd6:	6a 4c                	push   $0x4c
  jmp alltraps
80106dd8:	e9 d1 f6 ff ff       	jmp    801064ae <alltraps>

80106ddd <vector77>:
.globl vector77
vector77:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $77
80106ddf:	6a 4d                	push   $0x4d
  jmp alltraps
80106de1:	e9 c8 f6 ff ff       	jmp    801064ae <alltraps>

80106de6 <vector78>:
.globl vector78
vector78:
  pushl $0
80106de6:	6a 00                	push   $0x0
  pushl $78
80106de8:	6a 4e                	push   $0x4e
  jmp alltraps
80106dea:	e9 bf f6 ff ff       	jmp    801064ae <alltraps>

80106def <vector79>:
.globl vector79
vector79:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $79
80106df1:	6a 4f                	push   $0x4f
  jmp alltraps
80106df3:	e9 b6 f6 ff ff       	jmp    801064ae <alltraps>

80106df8 <vector80>:
.globl vector80
vector80:
  pushl $0
80106df8:	6a 00                	push   $0x0
  pushl $80
80106dfa:	6a 50                	push   $0x50
  jmp alltraps
80106dfc:	e9 ad f6 ff ff       	jmp    801064ae <alltraps>

80106e01 <vector81>:
.globl vector81
vector81:
  pushl $0
80106e01:	6a 00                	push   $0x0
  pushl $81
80106e03:	6a 51                	push   $0x51
  jmp alltraps
80106e05:	e9 a4 f6 ff ff       	jmp    801064ae <alltraps>

80106e0a <vector82>:
.globl vector82
vector82:
  pushl $0
80106e0a:	6a 00                	push   $0x0
  pushl $82
80106e0c:	6a 52                	push   $0x52
  jmp alltraps
80106e0e:	e9 9b f6 ff ff       	jmp    801064ae <alltraps>

80106e13 <vector83>:
.globl vector83
vector83:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $83
80106e15:	6a 53                	push   $0x53
  jmp alltraps
80106e17:	e9 92 f6 ff ff       	jmp    801064ae <alltraps>

80106e1c <vector84>:
.globl vector84
vector84:
  pushl $0
80106e1c:	6a 00                	push   $0x0
  pushl $84
80106e1e:	6a 54                	push   $0x54
  jmp alltraps
80106e20:	e9 89 f6 ff ff       	jmp    801064ae <alltraps>

80106e25 <vector85>:
.globl vector85
vector85:
  pushl $0
80106e25:	6a 00                	push   $0x0
  pushl $85
80106e27:	6a 55                	push   $0x55
  jmp alltraps
80106e29:	e9 80 f6 ff ff       	jmp    801064ae <alltraps>

80106e2e <vector86>:
.globl vector86
vector86:
  pushl $0
80106e2e:	6a 00                	push   $0x0
  pushl $86
80106e30:	6a 56                	push   $0x56
  jmp alltraps
80106e32:	e9 77 f6 ff ff       	jmp    801064ae <alltraps>

80106e37 <vector87>:
.globl vector87
vector87:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $87
80106e39:	6a 57                	push   $0x57
  jmp alltraps
80106e3b:	e9 6e f6 ff ff       	jmp    801064ae <alltraps>

80106e40 <vector88>:
.globl vector88
vector88:
  pushl $0
80106e40:	6a 00                	push   $0x0
  pushl $88
80106e42:	6a 58                	push   $0x58
  jmp alltraps
80106e44:	e9 65 f6 ff ff       	jmp    801064ae <alltraps>

80106e49 <vector89>:
.globl vector89
vector89:
  pushl $0
80106e49:	6a 00                	push   $0x0
  pushl $89
80106e4b:	6a 59                	push   $0x59
  jmp alltraps
80106e4d:	e9 5c f6 ff ff       	jmp    801064ae <alltraps>

80106e52 <vector90>:
.globl vector90
vector90:
  pushl $0
80106e52:	6a 00                	push   $0x0
  pushl $90
80106e54:	6a 5a                	push   $0x5a
  jmp alltraps
80106e56:	e9 53 f6 ff ff       	jmp    801064ae <alltraps>

80106e5b <vector91>:
.globl vector91
vector91:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $91
80106e5d:	6a 5b                	push   $0x5b
  jmp alltraps
80106e5f:	e9 4a f6 ff ff       	jmp    801064ae <alltraps>

80106e64 <vector92>:
.globl vector92
vector92:
  pushl $0
80106e64:	6a 00                	push   $0x0
  pushl $92
80106e66:	6a 5c                	push   $0x5c
  jmp alltraps
80106e68:	e9 41 f6 ff ff       	jmp    801064ae <alltraps>

80106e6d <vector93>:
.globl vector93
vector93:
  pushl $0
80106e6d:	6a 00                	push   $0x0
  pushl $93
80106e6f:	6a 5d                	push   $0x5d
  jmp alltraps
80106e71:	e9 38 f6 ff ff       	jmp    801064ae <alltraps>

80106e76 <vector94>:
.globl vector94
vector94:
  pushl $0
80106e76:	6a 00                	push   $0x0
  pushl $94
80106e78:	6a 5e                	push   $0x5e
  jmp alltraps
80106e7a:	e9 2f f6 ff ff       	jmp    801064ae <alltraps>

80106e7f <vector95>:
.globl vector95
vector95:
  pushl $0
80106e7f:	6a 00                	push   $0x0
  pushl $95
80106e81:	6a 5f                	push   $0x5f
  jmp alltraps
80106e83:	e9 26 f6 ff ff       	jmp    801064ae <alltraps>

80106e88 <vector96>:
.globl vector96
vector96:
  pushl $0
80106e88:	6a 00                	push   $0x0
  pushl $96
80106e8a:	6a 60                	push   $0x60
  jmp alltraps
80106e8c:	e9 1d f6 ff ff       	jmp    801064ae <alltraps>

80106e91 <vector97>:
.globl vector97
vector97:
  pushl $0
80106e91:	6a 00                	push   $0x0
  pushl $97
80106e93:	6a 61                	push   $0x61
  jmp alltraps
80106e95:	e9 14 f6 ff ff       	jmp    801064ae <alltraps>

80106e9a <vector98>:
.globl vector98
vector98:
  pushl $0
80106e9a:	6a 00                	push   $0x0
  pushl $98
80106e9c:	6a 62                	push   $0x62
  jmp alltraps
80106e9e:	e9 0b f6 ff ff       	jmp    801064ae <alltraps>

80106ea3 <vector99>:
.globl vector99
vector99:
  pushl $0
80106ea3:	6a 00                	push   $0x0
  pushl $99
80106ea5:	6a 63                	push   $0x63
  jmp alltraps
80106ea7:	e9 02 f6 ff ff       	jmp    801064ae <alltraps>

80106eac <vector100>:
.globl vector100
vector100:
  pushl $0
80106eac:	6a 00                	push   $0x0
  pushl $100
80106eae:	6a 64                	push   $0x64
  jmp alltraps
80106eb0:	e9 f9 f5 ff ff       	jmp    801064ae <alltraps>

80106eb5 <vector101>:
.globl vector101
vector101:
  pushl $0
80106eb5:	6a 00                	push   $0x0
  pushl $101
80106eb7:	6a 65                	push   $0x65
  jmp alltraps
80106eb9:	e9 f0 f5 ff ff       	jmp    801064ae <alltraps>

80106ebe <vector102>:
.globl vector102
vector102:
  pushl $0
80106ebe:	6a 00                	push   $0x0
  pushl $102
80106ec0:	6a 66                	push   $0x66
  jmp alltraps
80106ec2:	e9 e7 f5 ff ff       	jmp    801064ae <alltraps>

80106ec7 <vector103>:
.globl vector103
vector103:
  pushl $0
80106ec7:	6a 00                	push   $0x0
  pushl $103
80106ec9:	6a 67                	push   $0x67
  jmp alltraps
80106ecb:	e9 de f5 ff ff       	jmp    801064ae <alltraps>

80106ed0 <vector104>:
.globl vector104
vector104:
  pushl $0
80106ed0:	6a 00                	push   $0x0
  pushl $104
80106ed2:	6a 68                	push   $0x68
  jmp alltraps
80106ed4:	e9 d5 f5 ff ff       	jmp    801064ae <alltraps>

80106ed9 <vector105>:
.globl vector105
vector105:
  pushl $0
80106ed9:	6a 00                	push   $0x0
  pushl $105
80106edb:	6a 69                	push   $0x69
  jmp alltraps
80106edd:	e9 cc f5 ff ff       	jmp    801064ae <alltraps>

80106ee2 <vector106>:
.globl vector106
vector106:
  pushl $0
80106ee2:	6a 00                	push   $0x0
  pushl $106
80106ee4:	6a 6a                	push   $0x6a
  jmp alltraps
80106ee6:	e9 c3 f5 ff ff       	jmp    801064ae <alltraps>

80106eeb <vector107>:
.globl vector107
vector107:
  pushl $0
80106eeb:	6a 00                	push   $0x0
  pushl $107
80106eed:	6a 6b                	push   $0x6b
  jmp alltraps
80106eef:	e9 ba f5 ff ff       	jmp    801064ae <alltraps>

80106ef4 <vector108>:
.globl vector108
vector108:
  pushl $0
80106ef4:	6a 00                	push   $0x0
  pushl $108
80106ef6:	6a 6c                	push   $0x6c
  jmp alltraps
80106ef8:	e9 b1 f5 ff ff       	jmp    801064ae <alltraps>

80106efd <vector109>:
.globl vector109
vector109:
  pushl $0
80106efd:	6a 00                	push   $0x0
  pushl $109
80106eff:	6a 6d                	push   $0x6d
  jmp alltraps
80106f01:	e9 a8 f5 ff ff       	jmp    801064ae <alltraps>

80106f06 <vector110>:
.globl vector110
vector110:
  pushl $0
80106f06:	6a 00                	push   $0x0
  pushl $110
80106f08:	6a 6e                	push   $0x6e
  jmp alltraps
80106f0a:	e9 9f f5 ff ff       	jmp    801064ae <alltraps>

80106f0f <vector111>:
.globl vector111
vector111:
  pushl $0
80106f0f:	6a 00                	push   $0x0
  pushl $111
80106f11:	6a 6f                	push   $0x6f
  jmp alltraps
80106f13:	e9 96 f5 ff ff       	jmp    801064ae <alltraps>

80106f18 <vector112>:
.globl vector112
vector112:
  pushl $0
80106f18:	6a 00                	push   $0x0
  pushl $112
80106f1a:	6a 70                	push   $0x70
  jmp alltraps
80106f1c:	e9 8d f5 ff ff       	jmp    801064ae <alltraps>

80106f21 <vector113>:
.globl vector113
vector113:
  pushl $0
80106f21:	6a 00                	push   $0x0
  pushl $113
80106f23:	6a 71                	push   $0x71
  jmp alltraps
80106f25:	e9 84 f5 ff ff       	jmp    801064ae <alltraps>

80106f2a <vector114>:
.globl vector114
vector114:
  pushl $0
80106f2a:	6a 00                	push   $0x0
  pushl $114
80106f2c:	6a 72                	push   $0x72
  jmp alltraps
80106f2e:	e9 7b f5 ff ff       	jmp    801064ae <alltraps>

80106f33 <vector115>:
.globl vector115
vector115:
  pushl $0
80106f33:	6a 00                	push   $0x0
  pushl $115
80106f35:	6a 73                	push   $0x73
  jmp alltraps
80106f37:	e9 72 f5 ff ff       	jmp    801064ae <alltraps>

80106f3c <vector116>:
.globl vector116
vector116:
  pushl $0
80106f3c:	6a 00                	push   $0x0
  pushl $116
80106f3e:	6a 74                	push   $0x74
  jmp alltraps
80106f40:	e9 69 f5 ff ff       	jmp    801064ae <alltraps>

80106f45 <vector117>:
.globl vector117
vector117:
  pushl $0
80106f45:	6a 00                	push   $0x0
  pushl $117
80106f47:	6a 75                	push   $0x75
  jmp alltraps
80106f49:	e9 60 f5 ff ff       	jmp    801064ae <alltraps>

80106f4e <vector118>:
.globl vector118
vector118:
  pushl $0
80106f4e:	6a 00                	push   $0x0
  pushl $118
80106f50:	6a 76                	push   $0x76
  jmp alltraps
80106f52:	e9 57 f5 ff ff       	jmp    801064ae <alltraps>

80106f57 <vector119>:
.globl vector119
vector119:
  pushl $0
80106f57:	6a 00                	push   $0x0
  pushl $119
80106f59:	6a 77                	push   $0x77
  jmp alltraps
80106f5b:	e9 4e f5 ff ff       	jmp    801064ae <alltraps>

80106f60 <vector120>:
.globl vector120
vector120:
  pushl $0
80106f60:	6a 00                	push   $0x0
  pushl $120
80106f62:	6a 78                	push   $0x78
  jmp alltraps
80106f64:	e9 45 f5 ff ff       	jmp    801064ae <alltraps>

80106f69 <vector121>:
.globl vector121
vector121:
  pushl $0
80106f69:	6a 00                	push   $0x0
  pushl $121
80106f6b:	6a 79                	push   $0x79
  jmp alltraps
80106f6d:	e9 3c f5 ff ff       	jmp    801064ae <alltraps>

80106f72 <vector122>:
.globl vector122
vector122:
  pushl $0
80106f72:	6a 00                	push   $0x0
  pushl $122
80106f74:	6a 7a                	push   $0x7a
  jmp alltraps
80106f76:	e9 33 f5 ff ff       	jmp    801064ae <alltraps>

80106f7b <vector123>:
.globl vector123
vector123:
  pushl $0
80106f7b:	6a 00                	push   $0x0
  pushl $123
80106f7d:	6a 7b                	push   $0x7b
  jmp alltraps
80106f7f:	e9 2a f5 ff ff       	jmp    801064ae <alltraps>

80106f84 <vector124>:
.globl vector124
vector124:
  pushl $0
80106f84:	6a 00                	push   $0x0
  pushl $124
80106f86:	6a 7c                	push   $0x7c
  jmp alltraps
80106f88:	e9 21 f5 ff ff       	jmp    801064ae <alltraps>

80106f8d <vector125>:
.globl vector125
vector125:
  pushl $0
80106f8d:	6a 00                	push   $0x0
  pushl $125
80106f8f:	6a 7d                	push   $0x7d
  jmp alltraps
80106f91:	e9 18 f5 ff ff       	jmp    801064ae <alltraps>

80106f96 <vector126>:
.globl vector126
vector126:
  pushl $0
80106f96:	6a 00                	push   $0x0
  pushl $126
80106f98:	6a 7e                	push   $0x7e
  jmp alltraps
80106f9a:	e9 0f f5 ff ff       	jmp    801064ae <alltraps>

80106f9f <vector127>:
.globl vector127
vector127:
  pushl $0
80106f9f:	6a 00                	push   $0x0
  pushl $127
80106fa1:	6a 7f                	push   $0x7f
  jmp alltraps
80106fa3:	e9 06 f5 ff ff       	jmp    801064ae <alltraps>

80106fa8 <vector128>:
.globl vector128
vector128:
  pushl $0
80106fa8:	6a 00                	push   $0x0
  pushl $128
80106faa:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106faf:	e9 fa f4 ff ff       	jmp    801064ae <alltraps>

80106fb4 <vector129>:
.globl vector129
vector129:
  pushl $0
80106fb4:	6a 00                	push   $0x0
  pushl $129
80106fb6:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106fbb:	e9 ee f4 ff ff       	jmp    801064ae <alltraps>

80106fc0 <vector130>:
.globl vector130
vector130:
  pushl $0
80106fc0:	6a 00                	push   $0x0
  pushl $130
80106fc2:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106fc7:	e9 e2 f4 ff ff       	jmp    801064ae <alltraps>

80106fcc <vector131>:
.globl vector131
vector131:
  pushl $0
80106fcc:	6a 00                	push   $0x0
  pushl $131
80106fce:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106fd3:	e9 d6 f4 ff ff       	jmp    801064ae <alltraps>

80106fd8 <vector132>:
.globl vector132
vector132:
  pushl $0
80106fd8:	6a 00                	push   $0x0
  pushl $132
80106fda:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106fdf:	e9 ca f4 ff ff       	jmp    801064ae <alltraps>

80106fe4 <vector133>:
.globl vector133
vector133:
  pushl $0
80106fe4:	6a 00                	push   $0x0
  pushl $133
80106fe6:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106feb:	e9 be f4 ff ff       	jmp    801064ae <alltraps>

80106ff0 <vector134>:
.globl vector134
vector134:
  pushl $0
80106ff0:	6a 00                	push   $0x0
  pushl $134
80106ff2:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106ff7:	e9 b2 f4 ff ff       	jmp    801064ae <alltraps>

80106ffc <vector135>:
.globl vector135
vector135:
  pushl $0
80106ffc:	6a 00                	push   $0x0
  pushl $135
80106ffe:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107003:	e9 a6 f4 ff ff       	jmp    801064ae <alltraps>

80107008 <vector136>:
.globl vector136
vector136:
  pushl $0
80107008:	6a 00                	push   $0x0
  pushl $136
8010700a:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010700f:	e9 9a f4 ff ff       	jmp    801064ae <alltraps>

80107014 <vector137>:
.globl vector137
vector137:
  pushl $0
80107014:	6a 00                	push   $0x0
  pushl $137
80107016:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010701b:	e9 8e f4 ff ff       	jmp    801064ae <alltraps>

80107020 <vector138>:
.globl vector138
vector138:
  pushl $0
80107020:	6a 00                	push   $0x0
  pushl $138
80107022:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107027:	e9 82 f4 ff ff       	jmp    801064ae <alltraps>

8010702c <vector139>:
.globl vector139
vector139:
  pushl $0
8010702c:	6a 00                	push   $0x0
  pushl $139
8010702e:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107033:	e9 76 f4 ff ff       	jmp    801064ae <alltraps>

80107038 <vector140>:
.globl vector140
vector140:
  pushl $0
80107038:	6a 00                	push   $0x0
  pushl $140
8010703a:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010703f:	e9 6a f4 ff ff       	jmp    801064ae <alltraps>

80107044 <vector141>:
.globl vector141
vector141:
  pushl $0
80107044:	6a 00                	push   $0x0
  pushl $141
80107046:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010704b:	e9 5e f4 ff ff       	jmp    801064ae <alltraps>

80107050 <vector142>:
.globl vector142
vector142:
  pushl $0
80107050:	6a 00                	push   $0x0
  pushl $142
80107052:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107057:	e9 52 f4 ff ff       	jmp    801064ae <alltraps>

8010705c <vector143>:
.globl vector143
vector143:
  pushl $0
8010705c:	6a 00                	push   $0x0
  pushl $143
8010705e:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107063:	e9 46 f4 ff ff       	jmp    801064ae <alltraps>

80107068 <vector144>:
.globl vector144
vector144:
  pushl $0
80107068:	6a 00                	push   $0x0
  pushl $144
8010706a:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010706f:	e9 3a f4 ff ff       	jmp    801064ae <alltraps>

80107074 <vector145>:
.globl vector145
vector145:
  pushl $0
80107074:	6a 00                	push   $0x0
  pushl $145
80107076:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010707b:	e9 2e f4 ff ff       	jmp    801064ae <alltraps>

80107080 <vector146>:
.globl vector146
vector146:
  pushl $0
80107080:	6a 00                	push   $0x0
  pushl $146
80107082:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107087:	e9 22 f4 ff ff       	jmp    801064ae <alltraps>

8010708c <vector147>:
.globl vector147
vector147:
  pushl $0
8010708c:	6a 00                	push   $0x0
  pushl $147
8010708e:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107093:	e9 16 f4 ff ff       	jmp    801064ae <alltraps>

80107098 <vector148>:
.globl vector148
vector148:
  pushl $0
80107098:	6a 00                	push   $0x0
  pushl $148
8010709a:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010709f:	e9 0a f4 ff ff       	jmp    801064ae <alltraps>

801070a4 <vector149>:
.globl vector149
vector149:
  pushl $0
801070a4:	6a 00                	push   $0x0
  pushl $149
801070a6:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801070ab:	e9 fe f3 ff ff       	jmp    801064ae <alltraps>

801070b0 <vector150>:
.globl vector150
vector150:
  pushl $0
801070b0:	6a 00                	push   $0x0
  pushl $150
801070b2:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801070b7:	e9 f2 f3 ff ff       	jmp    801064ae <alltraps>

801070bc <vector151>:
.globl vector151
vector151:
  pushl $0
801070bc:	6a 00                	push   $0x0
  pushl $151
801070be:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801070c3:	e9 e6 f3 ff ff       	jmp    801064ae <alltraps>

801070c8 <vector152>:
.globl vector152
vector152:
  pushl $0
801070c8:	6a 00                	push   $0x0
  pushl $152
801070ca:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801070cf:	e9 da f3 ff ff       	jmp    801064ae <alltraps>

801070d4 <vector153>:
.globl vector153
vector153:
  pushl $0
801070d4:	6a 00                	push   $0x0
  pushl $153
801070d6:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801070db:	e9 ce f3 ff ff       	jmp    801064ae <alltraps>

801070e0 <vector154>:
.globl vector154
vector154:
  pushl $0
801070e0:	6a 00                	push   $0x0
  pushl $154
801070e2:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801070e7:	e9 c2 f3 ff ff       	jmp    801064ae <alltraps>

801070ec <vector155>:
.globl vector155
vector155:
  pushl $0
801070ec:	6a 00                	push   $0x0
  pushl $155
801070ee:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801070f3:	e9 b6 f3 ff ff       	jmp    801064ae <alltraps>

801070f8 <vector156>:
.globl vector156
vector156:
  pushl $0
801070f8:	6a 00                	push   $0x0
  pushl $156
801070fa:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801070ff:	e9 aa f3 ff ff       	jmp    801064ae <alltraps>

80107104 <vector157>:
.globl vector157
vector157:
  pushl $0
80107104:	6a 00                	push   $0x0
  pushl $157
80107106:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010710b:	e9 9e f3 ff ff       	jmp    801064ae <alltraps>

80107110 <vector158>:
.globl vector158
vector158:
  pushl $0
80107110:	6a 00                	push   $0x0
  pushl $158
80107112:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107117:	e9 92 f3 ff ff       	jmp    801064ae <alltraps>

8010711c <vector159>:
.globl vector159
vector159:
  pushl $0
8010711c:	6a 00                	push   $0x0
  pushl $159
8010711e:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107123:	e9 86 f3 ff ff       	jmp    801064ae <alltraps>

80107128 <vector160>:
.globl vector160
vector160:
  pushl $0
80107128:	6a 00                	push   $0x0
  pushl $160
8010712a:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010712f:	e9 7a f3 ff ff       	jmp    801064ae <alltraps>

80107134 <vector161>:
.globl vector161
vector161:
  pushl $0
80107134:	6a 00                	push   $0x0
  pushl $161
80107136:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010713b:	e9 6e f3 ff ff       	jmp    801064ae <alltraps>

80107140 <vector162>:
.globl vector162
vector162:
  pushl $0
80107140:	6a 00                	push   $0x0
  pushl $162
80107142:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107147:	e9 62 f3 ff ff       	jmp    801064ae <alltraps>

8010714c <vector163>:
.globl vector163
vector163:
  pushl $0
8010714c:	6a 00                	push   $0x0
  pushl $163
8010714e:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107153:	e9 56 f3 ff ff       	jmp    801064ae <alltraps>

80107158 <vector164>:
.globl vector164
vector164:
  pushl $0
80107158:	6a 00                	push   $0x0
  pushl $164
8010715a:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010715f:	e9 4a f3 ff ff       	jmp    801064ae <alltraps>

80107164 <vector165>:
.globl vector165
vector165:
  pushl $0
80107164:	6a 00                	push   $0x0
  pushl $165
80107166:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010716b:	e9 3e f3 ff ff       	jmp    801064ae <alltraps>

80107170 <vector166>:
.globl vector166
vector166:
  pushl $0
80107170:	6a 00                	push   $0x0
  pushl $166
80107172:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107177:	e9 32 f3 ff ff       	jmp    801064ae <alltraps>

8010717c <vector167>:
.globl vector167
vector167:
  pushl $0
8010717c:	6a 00                	push   $0x0
  pushl $167
8010717e:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107183:	e9 26 f3 ff ff       	jmp    801064ae <alltraps>

80107188 <vector168>:
.globl vector168
vector168:
  pushl $0
80107188:	6a 00                	push   $0x0
  pushl $168
8010718a:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010718f:	e9 1a f3 ff ff       	jmp    801064ae <alltraps>

80107194 <vector169>:
.globl vector169
vector169:
  pushl $0
80107194:	6a 00                	push   $0x0
  pushl $169
80107196:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010719b:	e9 0e f3 ff ff       	jmp    801064ae <alltraps>

801071a0 <vector170>:
.globl vector170
vector170:
  pushl $0
801071a0:	6a 00                	push   $0x0
  pushl $170
801071a2:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801071a7:	e9 02 f3 ff ff       	jmp    801064ae <alltraps>

801071ac <vector171>:
.globl vector171
vector171:
  pushl $0
801071ac:	6a 00                	push   $0x0
  pushl $171
801071ae:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801071b3:	e9 f6 f2 ff ff       	jmp    801064ae <alltraps>

801071b8 <vector172>:
.globl vector172
vector172:
  pushl $0
801071b8:	6a 00                	push   $0x0
  pushl $172
801071ba:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801071bf:	e9 ea f2 ff ff       	jmp    801064ae <alltraps>

801071c4 <vector173>:
.globl vector173
vector173:
  pushl $0
801071c4:	6a 00                	push   $0x0
  pushl $173
801071c6:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801071cb:	e9 de f2 ff ff       	jmp    801064ae <alltraps>

801071d0 <vector174>:
.globl vector174
vector174:
  pushl $0
801071d0:	6a 00                	push   $0x0
  pushl $174
801071d2:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801071d7:	e9 d2 f2 ff ff       	jmp    801064ae <alltraps>

801071dc <vector175>:
.globl vector175
vector175:
  pushl $0
801071dc:	6a 00                	push   $0x0
  pushl $175
801071de:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801071e3:	e9 c6 f2 ff ff       	jmp    801064ae <alltraps>

801071e8 <vector176>:
.globl vector176
vector176:
  pushl $0
801071e8:	6a 00                	push   $0x0
  pushl $176
801071ea:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801071ef:	e9 ba f2 ff ff       	jmp    801064ae <alltraps>

801071f4 <vector177>:
.globl vector177
vector177:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $177
801071f6:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801071fb:	e9 ae f2 ff ff       	jmp    801064ae <alltraps>

80107200 <vector178>:
.globl vector178
vector178:
  pushl $0
80107200:	6a 00                	push   $0x0
  pushl $178
80107202:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107207:	e9 a2 f2 ff ff       	jmp    801064ae <alltraps>

8010720c <vector179>:
.globl vector179
vector179:
  pushl $0
8010720c:	6a 00                	push   $0x0
  pushl $179
8010720e:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107213:	e9 96 f2 ff ff       	jmp    801064ae <alltraps>

80107218 <vector180>:
.globl vector180
vector180:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $180
8010721a:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010721f:	e9 8a f2 ff ff       	jmp    801064ae <alltraps>

80107224 <vector181>:
.globl vector181
vector181:
  pushl $0
80107224:	6a 00                	push   $0x0
  pushl $181
80107226:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010722b:	e9 7e f2 ff ff       	jmp    801064ae <alltraps>

80107230 <vector182>:
.globl vector182
vector182:
  pushl $0
80107230:	6a 00                	push   $0x0
  pushl $182
80107232:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107237:	e9 72 f2 ff ff       	jmp    801064ae <alltraps>

8010723c <vector183>:
.globl vector183
vector183:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $183
8010723e:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107243:	e9 66 f2 ff ff       	jmp    801064ae <alltraps>

80107248 <vector184>:
.globl vector184
vector184:
  pushl $0
80107248:	6a 00                	push   $0x0
  pushl $184
8010724a:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010724f:	e9 5a f2 ff ff       	jmp    801064ae <alltraps>

80107254 <vector185>:
.globl vector185
vector185:
  pushl $0
80107254:	6a 00                	push   $0x0
  pushl $185
80107256:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010725b:	e9 4e f2 ff ff       	jmp    801064ae <alltraps>

80107260 <vector186>:
.globl vector186
vector186:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $186
80107262:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107267:	e9 42 f2 ff ff       	jmp    801064ae <alltraps>

8010726c <vector187>:
.globl vector187
vector187:
  pushl $0
8010726c:	6a 00                	push   $0x0
  pushl $187
8010726e:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107273:	e9 36 f2 ff ff       	jmp    801064ae <alltraps>

80107278 <vector188>:
.globl vector188
vector188:
  pushl $0
80107278:	6a 00                	push   $0x0
  pushl $188
8010727a:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010727f:	e9 2a f2 ff ff       	jmp    801064ae <alltraps>

80107284 <vector189>:
.globl vector189
vector189:
  pushl $0
80107284:	6a 00                	push   $0x0
  pushl $189
80107286:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010728b:	e9 1e f2 ff ff       	jmp    801064ae <alltraps>

80107290 <vector190>:
.globl vector190
vector190:
  pushl $0
80107290:	6a 00                	push   $0x0
  pushl $190
80107292:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107297:	e9 12 f2 ff ff       	jmp    801064ae <alltraps>

8010729c <vector191>:
.globl vector191
vector191:
  pushl $0
8010729c:	6a 00                	push   $0x0
  pushl $191
8010729e:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801072a3:	e9 06 f2 ff ff       	jmp    801064ae <alltraps>

801072a8 <vector192>:
.globl vector192
vector192:
  pushl $0
801072a8:	6a 00                	push   $0x0
  pushl $192
801072aa:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801072af:	e9 fa f1 ff ff       	jmp    801064ae <alltraps>

801072b4 <vector193>:
.globl vector193
vector193:
  pushl $0
801072b4:	6a 00                	push   $0x0
  pushl $193
801072b6:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801072bb:	e9 ee f1 ff ff       	jmp    801064ae <alltraps>

801072c0 <vector194>:
.globl vector194
vector194:
  pushl $0
801072c0:	6a 00                	push   $0x0
  pushl $194
801072c2:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801072c7:	e9 e2 f1 ff ff       	jmp    801064ae <alltraps>

801072cc <vector195>:
.globl vector195
vector195:
  pushl $0
801072cc:	6a 00                	push   $0x0
  pushl $195
801072ce:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801072d3:	e9 d6 f1 ff ff       	jmp    801064ae <alltraps>

801072d8 <vector196>:
.globl vector196
vector196:
  pushl $0
801072d8:	6a 00                	push   $0x0
  pushl $196
801072da:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801072df:	e9 ca f1 ff ff       	jmp    801064ae <alltraps>

801072e4 <vector197>:
.globl vector197
vector197:
  pushl $0
801072e4:	6a 00                	push   $0x0
  pushl $197
801072e6:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801072eb:	e9 be f1 ff ff       	jmp    801064ae <alltraps>

801072f0 <vector198>:
.globl vector198
vector198:
  pushl $0
801072f0:	6a 00                	push   $0x0
  pushl $198
801072f2:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801072f7:	e9 b2 f1 ff ff       	jmp    801064ae <alltraps>

801072fc <vector199>:
.globl vector199
vector199:
  pushl $0
801072fc:	6a 00                	push   $0x0
  pushl $199
801072fe:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107303:	e9 a6 f1 ff ff       	jmp    801064ae <alltraps>

80107308 <vector200>:
.globl vector200
vector200:
  pushl $0
80107308:	6a 00                	push   $0x0
  pushl $200
8010730a:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010730f:	e9 9a f1 ff ff       	jmp    801064ae <alltraps>

80107314 <vector201>:
.globl vector201
vector201:
  pushl $0
80107314:	6a 00                	push   $0x0
  pushl $201
80107316:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010731b:	e9 8e f1 ff ff       	jmp    801064ae <alltraps>

80107320 <vector202>:
.globl vector202
vector202:
  pushl $0
80107320:	6a 00                	push   $0x0
  pushl $202
80107322:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107327:	e9 82 f1 ff ff       	jmp    801064ae <alltraps>

8010732c <vector203>:
.globl vector203
vector203:
  pushl $0
8010732c:	6a 00                	push   $0x0
  pushl $203
8010732e:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107333:	e9 76 f1 ff ff       	jmp    801064ae <alltraps>

80107338 <vector204>:
.globl vector204
vector204:
  pushl $0
80107338:	6a 00                	push   $0x0
  pushl $204
8010733a:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010733f:	e9 6a f1 ff ff       	jmp    801064ae <alltraps>

80107344 <vector205>:
.globl vector205
vector205:
  pushl $0
80107344:	6a 00                	push   $0x0
  pushl $205
80107346:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010734b:	e9 5e f1 ff ff       	jmp    801064ae <alltraps>

80107350 <vector206>:
.globl vector206
vector206:
  pushl $0
80107350:	6a 00                	push   $0x0
  pushl $206
80107352:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107357:	e9 52 f1 ff ff       	jmp    801064ae <alltraps>

8010735c <vector207>:
.globl vector207
vector207:
  pushl $0
8010735c:	6a 00                	push   $0x0
  pushl $207
8010735e:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107363:	e9 46 f1 ff ff       	jmp    801064ae <alltraps>

80107368 <vector208>:
.globl vector208
vector208:
  pushl $0
80107368:	6a 00                	push   $0x0
  pushl $208
8010736a:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010736f:	e9 3a f1 ff ff       	jmp    801064ae <alltraps>

80107374 <vector209>:
.globl vector209
vector209:
  pushl $0
80107374:	6a 00                	push   $0x0
  pushl $209
80107376:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010737b:	e9 2e f1 ff ff       	jmp    801064ae <alltraps>

80107380 <vector210>:
.globl vector210
vector210:
  pushl $0
80107380:	6a 00                	push   $0x0
  pushl $210
80107382:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107387:	e9 22 f1 ff ff       	jmp    801064ae <alltraps>

8010738c <vector211>:
.globl vector211
vector211:
  pushl $0
8010738c:	6a 00                	push   $0x0
  pushl $211
8010738e:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107393:	e9 16 f1 ff ff       	jmp    801064ae <alltraps>

80107398 <vector212>:
.globl vector212
vector212:
  pushl $0
80107398:	6a 00                	push   $0x0
  pushl $212
8010739a:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010739f:	e9 0a f1 ff ff       	jmp    801064ae <alltraps>

801073a4 <vector213>:
.globl vector213
vector213:
  pushl $0
801073a4:	6a 00                	push   $0x0
  pushl $213
801073a6:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801073ab:	e9 fe f0 ff ff       	jmp    801064ae <alltraps>

801073b0 <vector214>:
.globl vector214
vector214:
  pushl $0
801073b0:	6a 00                	push   $0x0
  pushl $214
801073b2:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801073b7:	e9 f2 f0 ff ff       	jmp    801064ae <alltraps>

801073bc <vector215>:
.globl vector215
vector215:
  pushl $0
801073bc:	6a 00                	push   $0x0
  pushl $215
801073be:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801073c3:	e9 e6 f0 ff ff       	jmp    801064ae <alltraps>

801073c8 <vector216>:
.globl vector216
vector216:
  pushl $0
801073c8:	6a 00                	push   $0x0
  pushl $216
801073ca:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801073cf:	e9 da f0 ff ff       	jmp    801064ae <alltraps>

801073d4 <vector217>:
.globl vector217
vector217:
  pushl $0
801073d4:	6a 00                	push   $0x0
  pushl $217
801073d6:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801073db:	e9 ce f0 ff ff       	jmp    801064ae <alltraps>

801073e0 <vector218>:
.globl vector218
vector218:
  pushl $0
801073e0:	6a 00                	push   $0x0
  pushl $218
801073e2:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801073e7:	e9 c2 f0 ff ff       	jmp    801064ae <alltraps>

801073ec <vector219>:
.globl vector219
vector219:
  pushl $0
801073ec:	6a 00                	push   $0x0
  pushl $219
801073ee:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801073f3:	e9 b6 f0 ff ff       	jmp    801064ae <alltraps>

801073f8 <vector220>:
.globl vector220
vector220:
  pushl $0
801073f8:	6a 00                	push   $0x0
  pushl $220
801073fa:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801073ff:	e9 aa f0 ff ff       	jmp    801064ae <alltraps>

80107404 <vector221>:
.globl vector221
vector221:
  pushl $0
80107404:	6a 00                	push   $0x0
  pushl $221
80107406:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010740b:	e9 9e f0 ff ff       	jmp    801064ae <alltraps>

80107410 <vector222>:
.globl vector222
vector222:
  pushl $0
80107410:	6a 00                	push   $0x0
  pushl $222
80107412:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107417:	e9 92 f0 ff ff       	jmp    801064ae <alltraps>

8010741c <vector223>:
.globl vector223
vector223:
  pushl $0
8010741c:	6a 00                	push   $0x0
  pushl $223
8010741e:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107423:	e9 86 f0 ff ff       	jmp    801064ae <alltraps>

80107428 <vector224>:
.globl vector224
vector224:
  pushl $0
80107428:	6a 00                	push   $0x0
  pushl $224
8010742a:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010742f:	e9 7a f0 ff ff       	jmp    801064ae <alltraps>

80107434 <vector225>:
.globl vector225
vector225:
  pushl $0
80107434:	6a 00                	push   $0x0
  pushl $225
80107436:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010743b:	e9 6e f0 ff ff       	jmp    801064ae <alltraps>

80107440 <vector226>:
.globl vector226
vector226:
  pushl $0
80107440:	6a 00                	push   $0x0
  pushl $226
80107442:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107447:	e9 62 f0 ff ff       	jmp    801064ae <alltraps>

8010744c <vector227>:
.globl vector227
vector227:
  pushl $0
8010744c:	6a 00                	push   $0x0
  pushl $227
8010744e:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107453:	e9 56 f0 ff ff       	jmp    801064ae <alltraps>

80107458 <vector228>:
.globl vector228
vector228:
  pushl $0
80107458:	6a 00                	push   $0x0
  pushl $228
8010745a:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010745f:	e9 4a f0 ff ff       	jmp    801064ae <alltraps>

80107464 <vector229>:
.globl vector229
vector229:
  pushl $0
80107464:	6a 00                	push   $0x0
  pushl $229
80107466:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010746b:	e9 3e f0 ff ff       	jmp    801064ae <alltraps>

80107470 <vector230>:
.globl vector230
vector230:
  pushl $0
80107470:	6a 00                	push   $0x0
  pushl $230
80107472:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107477:	e9 32 f0 ff ff       	jmp    801064ae <alltraps>

8010747c <vector231>:
.globl vector231
vector231:
  pushl $0
8010747c:	6a 00                	push   $0x0
  pushl $231
8010747e:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107483:	e9 26 f0 ff ff       	jmp    801064ae <alltraps>

80107488 <vector232>:
.globl vector232
vector232:
  pushl $0
80107488:	6a 00                	push   $0x0
  pushl $232
8010748a:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010748f:	e9 1a f0 ff ff       	jmp    801064ae <alltraps>

80107494 <vector233>:
.globl vector233
vector233:
  pushl $0
80107494:	6a 00                	push   $0x0
  pushl $233
80107496:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010749b:	e9 0e f0 ff ff       	jmp    801064ae <alltraps>

801074a0 <vector234>:
.globl vector234
vector234:
  pushl $0
801074a0:	6a 00                	push   $0x0
  pushl $234
801074a2:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801074a7:	e9 02 f0 ff ff       	jmp    801064ae <alltraps>

801074ac <vector235>:
.globl vector235
vector235:
  pushl $0
801074ac:	6a 00                	push   $0x0
  pushl $235
801074ae:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801074b3:	e9 f6 ef ff ff       	jmp    801064ae <alltraps>

801074b8 <vector236>:
.globl vector236
vector236:
  pushl $0
801074b8:	6a 00                	push   $0x0
  pushl $236
801074ba:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801074bf:	e9 ea ef ff ff       	jmp    801064ae <alltraps>

801074c4 <vector237>:
.globl vector237
vector237:
  pushl $0
801074c4:	6a 00                	push   $0x0
  pushl $237
801074c6:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801074cb:	e9 de ef ff ff       	jmp    801064ae <alltraps>

801074d0 <vector238>:
.globl vector238
vector238:
  pushl $0
801074d0:	6a 00                	push   $0x0
  pushl $238
801074d2:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801074d7:	e9 d2 ef ff ff       	jmp    801064ae <alltraps>

801074dc <vector239>:
.globl vector239
vector239:
  pushl $0
801074dc:	6a 00                	push   $0x0
  pushl $239
801074de:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801074e3:	e9 c6 ef ff ff       	jmp    801064ae <alltraps>

801074e8 <vector240>:
.globl vector240
vector240:
  pushl $0
801074e8:	6a 00                	push   $0x0
  pushl $240
801074ea:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801074ef:	e9 ba ef ff ff       	jmp    801064ae <alltraps>

801074f4 <vector241>:
.globl vector241
vector241:
  pushl $0
801074f4:	6a 00                	push   $0x0
  pushl $241
801074f6:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801074fb:	e9 ae ef ff ff       	jmp    801064ae <alltraps>

80107500 <vector242>:
.globl vector242
vector242:
  pushl $0
80107500:	6a 00                	push   $0x0
  pushl $242
80107502:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107507:	e9 a2 ef ff ff       	jmp    801064ae <alltraps>

8010750c <vector243>:
.globl vector243
vector243:
  pushl $0
8010750c:	6a 00                	push   $0x0
  pushl $243
8010750e:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107513:	e9 96 ef ff ff       	jmp    801064ae <alltraps>

80107518 <vector244>:
.globl vector244
vector244:
  pushl $0
80107518:	6a 00                	push   $0x0
  pushl $244
8010751a:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010751f:	e9 8a ef ff ff       	jmp    801064ae <alltraps>

80107524 <vector245>:
.globl vector245
vector245:
  pushl $0
80107524:	6a 00                	push   $0x0
  pushl $245
80107526:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010752b:	e9 7e ef ff ff       	jmp    801064ae <alltraps>

80107530 <vector246>:
.globl vector246
vector246:
  pushl $0
80107530:	6a 00                	push   $0x0
  pushl $246
80107532:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107537:	e9 72 ef ff ff       	jmp    801064ae <alltraps>

8010753c <vector247>:
.globl vector247
vector247:
  pushl $0
8010753c:	6a 00                	push   $0x0
  pushl $247
8010753e:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107543:	e9 66 ef ff ff       	jmp    801064ae <alltraps>

80107548 <vector248>:
.globl vector248
vector248:
  pushl $0
80107548:	6a 00                	push   $0x0
  pushl $248
8010754a:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010754f:	e9 5a ef ff ff       	jmp    801064ae <alltraps>

80107554 <vector249>:
.globl vector249
vector249:
  pushl $0
80107554:	6a 00                	push   $0x0
  pushl $249
80107556:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010755b:	e9 4e ef ff ff       	jmp    801064ae <alltraps>

80107560 <vector250>:
.globl vector250
vector250:
  pushl $0
80107560:	6a 00                	push   $0x0
  pushl $250
80107562:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107567:	e9 42 ef ff ff       	jmp    801064ae <alltraps>

8010756c <vector251>:
.globl vector251
vector251:
  pushl $0
8010756c:	6a 00                	push   $0x0
  pushl $251
8010756e:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107573:	e9 36 ef ff ff       	jmp    801064ae <alltraps>

80107578 <vector252>:
.globl vector252
vector252:
  pushl $0
80107578:	6a 00                	push   $0x0
  pushl $252
8010757a:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010757f:	e9 2a ef ff ff       	jmp    801064ae <alltraps>

80107584 <vector253>:
.globl vector253
vector253:
  pushl $0
80107584:	6a 00                	push   $0x0
  pushl $253
80107586:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010758b:	e9 1e ef ff ff       	jmp    801064ae <alltraps>

80107590 <vector254>:
.globl vector254
vector254:
  pushl $0
80107590:	6a 00                	push   $0x0
  pushl $254
80107592:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107597:	e9 12 ef ff ff       	jmp    801064ae <alltraps>

8010759c <vector255>:
.globl vector255
vector255:
  pushl $0
8010759c:	6a 00                	push   $0x0
  pushl $255
8010759e:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801075a3:	e9 06 ef ff ff       	jmp    801064ae <alltraps>

801075a8 <lgdt>:
{
801075a8:	55                   	push   %ebp
801075a9:	89 e5                	mov    %esp,%ebp
801075ab:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801075ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801075b1:	83 e8 01             	sub    $0x1,%eax
801075b4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801075b8:	8b 45 08             	mov    0x8(%ebp),%eax
801075bb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801075bf:	8b 45 08             	mov    0x8(%ebp),%eax
801075c2:	c1 e8 10             	shr    $0x10,%eax
801075c5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801075c9:	8d 45 fa             	lea    -0x6(%ebp),%eax
801075cc:	0f 01 10             	lgdtl  (%eax)
}
801075cf:	90                   	nop
801075d0:	c9                   	leave  
801075d1:	c3                   	ret    

801075d2 <ltr>:
{
801075d2:	55                   	push   %ebp
801075d3:	89 e5                	mov    %esp,%ebp
801075d5:	83 ec 04             	sub    $0x4,%esp
801075d8:	8b 45 08             	mov    0x8(%ebp),%eax
801075db:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801075df:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801075e3:	0f 00 d8             	ltr    %ax
}
801075e6:	90                   	nop
801075e7:	c9                   	leave  
801075e8:	c3                   	ret    

801075e9 <lcr3>:

static inline void
lcr3(uint val)
{
801075e9:	55                   	push   %ebp
801075ea:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801075ec:	8b 45 08             	mov    0x8(%ebp),%eax
801075ef:	0f 22 d8             	mov    %eax,%cr3
}
801075f2:	90                   	nop
801075f3:	5d                   	pop    %ebp
801075f4:	c3                   	ret    

801075f5 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801075f5:	55                   	push   %ebp
801075f6:	89 e5                	mov    %esp,%ebp
801075f8:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801075fb:	e8 9d c3 ff ff       	call   8010399d <cpuid>
80107600:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107606:	05 80 74 19 80       	add    $0x80197480,%eax
8010760b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010760e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107611:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761a:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107623:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010762e:	83 e2 f0             	and    $0xfffffff0,%edx
80107631:	83 ca 0a             	or     $0xa,%edx
80107634:	88 50 7d             	mov    %dl,0x7d(%eax)
80107637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010763e:	83 ca 10             	or     $0x10,%edx
80107641:	88 50 7d             	mov    %dl,0x7d(%eax)
80107644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107647:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010764b:	83 e2 9f             	and    $0xffffff9f,%edx
8010764e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107654:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107658:	83 ca 80             	or     $0xffffff80,%edx
8010765b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010765e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107661:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107665:	83 ca 0f             	or     $0xf,%edx
80107668:	88 50 7e             	mov    %dl,0x7e(%eax)
8010766b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107672:	83 e2 ef             	and    $0xffffffef,%edx
80107675:	88 50 7e             	mov    %dl,0x7e(%eax)
80107678:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010767f:	83 e2 df             	and    $0xffffffdf,%edx
80107682:	88 50 7e             	mov    %dl,0x7e(%eax)
80107685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107688:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010768c:	83 ca 40             	or     $0x40,%edx
8010768f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107692:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107695:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107699:	83 ca 80             	or     $0xffffff80,%edx
8010769c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010769f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a2:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801076a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a9:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801076b0:	ff ff 
801076b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b5:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801076bc:	00 00 
801076be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c1:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801076c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cb:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076d2:	83 e2 f0             	and    $0xfffffff0,%edx
801076d5:	83 ca 02             	or     $0x2,%edx
801076d8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e1:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076e8:	83 ca 10             	or     $0x10,%edx
801076eb:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076fb:	83 e2 9f             	and    $0xffffff9f,%edx
801076fe:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107707:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010770e:	83 ca 80             	or     $0xffffff80,%edx
80107711:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107721:	83 ca 0f             	or     $0xf,%edx
80107724:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010772a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107734:	83 e2 ef             	and    $0xffffffef,%edx
80107737:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010773d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107740:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107747:	83 e2 df             	and    $0xffffffdf,%edx
8010774a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107753:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010775a:	83 ca 40             	or     $0x40,%edx
8010775d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107766:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010776d:	83 ca 80             	or     $0xffffff80,%edx
80107770:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107779:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107783:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010778a:	ff ff 
8010778c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778f:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107796:	00 00 
80107798:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779b:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801077a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077ac:	83 e2 f0             	and    $0xfffffff0,%edx
801077af:	83 ca 0a             	or     $0xa,%edx
801077b2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801077b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077bb:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077c2:	83 ca 10             	or     $0x10,%edx
801077c5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801077cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ce:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077d5:	83 ca 60             	or     $0x60,%edx
801077d8:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801077de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e1:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077e8:	83 ca 80             	or     $0xffffff80,%edx
801077eb:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801077f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077fb:	83 ca 0f             	or     $0xf,%edx
801077fe:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107807:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010780e:	83 e2 ef             	and    $0xffffffef,%edx
80107811:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107821:	83 e2 df             	and    $0xffffffdf,%edx
80107824:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010782a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107834:	83 ca 40             	or     $0x40,%edx
80107837:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010783d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107840:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107847:	83 ca 80             	or     $0xffffff80,%edx
8010784a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107853:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010785a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785d:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107864:	ff ff 
80107866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107869:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107870:	00 00 
80107872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107875:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010787c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107886:	83 e2 f0             	and    $0xfffffff0,%edx
80107889:	83 ca 02             	or     $0x2,%edx
8010788c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107895:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010789c:	83 ca 10             	or     $0x10,%edx
8010789f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801078af:	83 ca 60             	or     $0x60,%edx
801078b2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bb:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801078c2:	83 ca 80             	or     $0xffffff80,%edx
801078c5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ce:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078d5:	83 ca 0f             	or     $0xf,%edx
801078d8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078e8:	83 e2 ef             	and    $0xffffffef,%edx
801078eb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078fb:	83 e2 df             	and    $0xffffffdf,%edx
801078fe:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107907:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010790e:	83 ca 40             	or     $0x40,%edx
80107911:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107921:	83 ca 80             	or     $0xffffff80,%edx
80107924:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010792a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792d:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107937:	83 c0 70             	add    $0x70,%eax
8010793a:	83 ec 08             	sub    $0x8,%esp
8010793d:	6a 30                	push   $0x30
8010793f:	50                   	push   %eax
80107940:	e8 63 fc ff ff       	call   801075a8 <lgdt>
80107945:	83 c4 10             	add    $0x10,%esp
}
80107948:	90                   	nop
80107949:	c9                   	leave  
8010794a:	c3                   	ret    

8010794b <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010794b:	55                   	push   %ebp
8010794c:	89 e5                	mov    %esp,%ebp
8010794e:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107951:	8b 45 0c             	mov    0xc(%ebp),%eax
80107954:	c1 e8 16             	shr    $0x16,%eax
80107957:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010795e:	8b 45 08             	mov    0x8(%ebp),%eax
80107961:	01 d0                	add    %edx,%eax
80107963:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107966:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107969:	8b 00                	mov    (%eax),%eax
8010796b:	83 e0 01             	and    $0x1,%eax
8010796e:	85 c0                	test   %eax,%eax
80107970:	74 14                	je     80107986 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107972:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107975:	8b 00                	mov    (%eax),%eax
80107977:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010797c:	05 00 00 00 80       	add    $0x80000000,%eax
80107981:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107984:	eb 42                	jmp    801079c8 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107986:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010798a:	74 0e                	je     8010799a <walkpgdir+0x4f>
8010798c:	e8 0f ae ff ff       	call   801027a0 <kalloc>
80107991:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107994:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107998:	75 07                	jne    801079a1 <walkpgdir+0x56>
      return 0;
8010799a:	b8 00 00 00 00       	mov    $0x0,%eax
8010799f:	eb 3e                	jmp    801079df <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801079a1:	83 ec 04             	sub    $0x4,%esp
801079a4:	68 00 10 00 00       	push   $0x1000
801079a9:	6a 00                	push   $0x0
801079ab:	ff 75 f4             	push   -0xc(%ebp)
801079ae:	e8 e8 d3 ff ff       	call   80104d9b <memset>
801079b3:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801079b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b9:	05 00 00 00 80       	add    $0x80000000,%eax
801079be:	83 c8 07             	or     $0x7,%eax
801079c1:	89 c2                	mov    %eax,%edx
801079c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079c6:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801079c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801079cb:	c1 e8 0c             	shr    $0xc,%eax
801079ce:	25 ff 03 00 00       	and    $0x3ff,%eax
801079d3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801079da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079dd:	01 d0                	add    %edx,%eax
}
801079df:	c9                   	leave  
801079e0:	c3                   	ret    

801079e1 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801079e1:	55                   	push   %ebp
801079e2:	89 e5                	mov    %esp,%ebp
801079e4:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801079e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801079ea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801079f2:	8b 55 0c             	mov    0xc(%ebp),%edx
801079f5:	8b 45 10             	mov    0x10(%ebp),%eax
801079f8:	01 d0                	add    %edx,%eax
801079fa:	83 e8 01             	sub    $0x1,%eax
801079fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107a05:	83 ec 04             	sub    $0x4,%esp
80107a08:	6a 01                	push   $0x1
80107a0a:	ff 75 f4             	push   -0xc(%ebp)
80107a0d:	ff 75 08             	push   0x8(%ebp)
80107a10:	e8 36 ff ff ff       	call   8010794b <walkpgdir>
80107a15:	83 c4 10             	add    $0x10,%esp
80107a18:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107a1b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107a1f:	75 07                	jne    80107a28 <mappages+0x47>
      return -1;
80107a21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a26:	eb 47                	jmp    80107a6f <mappages+0x8e>
    if(*pte & PTE_P)
80107a28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a2b:	8b 00                	mov    (%eax),%eax
80107a2d:	83 e0 01             	and    $0x1,%eax
80107a30:	85 c0                	test   %eax,%eax
80107a32:	74 0d                	je     80107a41 <mappages+0x60>
      panic("remap");
80107a34:	83 ec 0c             	sub    $0xc,%esp
80107a37:	68 70 ad 10 80       	push   $0x8010ad70
80107a3c:	e8 68 8b ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107a41:	8b 45 18             	mov    0x18(%ebp),%eax
80107a44:	0b 45 14             	or     0x14(%ebp),%eax
80107a47:	83 c8 01             	or     $0x1,%eax
80107a4a:	89 c2                	mov    %eax,%edx
80107a4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a4f:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a54:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107a57:	74 10                	je     80107a69 <mappages+0x88>
      break;
    a += PGSIZE;
80107a59:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107a60:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107a67:	eb 9c                	jmp    80107a05 <mappages+0x24>
      break;
80107a69:	90                   	nop
  }
  return 0;
80107a6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a6f:	c9                   	leave  
80107a70:	c3                   	ret    

80107a71 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107a71:	55                   	push   %ebp
80107a72:	89 e5                	mov    %esp,%ebp
80107a74:	53                   	push   %ebx
80107a75:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107a78:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107a7f:	8b 15 60 77 19 80    	mov    0x80197760,%edx
80107a85:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107a8a:	29 d0                	sub    %edx,%eax
80107a8c:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107a8f:	a1 58 77 19 80       	mov    0x80197758,%eax
80107a94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107a97:	8b 15 58 77 19 80    	mov    0x80197758,%edx
80107a9d:	a1 60 77 19 80       	mov    0x80197760,%eax
80107aa2:	01 d0                	add    %edx,%eax
80107aa4:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107aa7:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab1:	83 c0 30             	add    $0x30,%eax
80107ab4:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107ab7:	89 10                	mov    %edx,(%eax)
80107ab9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107abc:	89 50 04             	mov    %edx,0x4(%eax)
80107abf:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107ac2:	89 50 08             	mov    %edx,0x8(%eax)
80107ac5:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107ac8:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107acb:	e8 d0 ac ff ff       	call   801027a0 <kalloc>
80107ad0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ad3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ad7:	75 07                	jne    80107ae0 <setupkvm+0x6f>
    return 0;
80107ad9:	b8 00 00 00 00       	mov    $0x0,%eax
80107ade:	eb 78                	jmp    80107b58 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107ae0:	83 ec 04             	sub    $0x4,%esp
80107ae3:	68 00 10 00 00       	push   $0x1000
80107ae8:	6a 00                	push   $0x0
80107aea:	ff 75 f0             	push   -0x10(%ebp)
80107aed:	e8 a9 d2 ff ff       	call   80104d9b <memset>
80107af2:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107af5:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107afc:	eb 4e                	jmp    80107b4c <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b01:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b07:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0d:	8b 58 08             	mov    0x8(%eax),%ebx
80107b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b13:	8b 40 04             	mov    0x4(%eax),%eax
80107b16:	29 c3                	sub    %eax,%ebx
80107b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1b:	8b 00                	mov    (%eax),%eax
80107b1d:	83 ec 0c             	sub    $0xc,%esp
80107b20:	51                   	push   %ecx
80107b21:	52                   	push   %edx
80107b22:	53                   	push   %ebx
80107b23:	50                   	push   %eax
80107b24:	ff 75 f0             	push   -0x10(%ebp)
80107b27:	e8 b5 fe ff ff       	call   801079e1 <mappages>
80107b2c:	83 c4 20             	add    $0x20,%esp
80107b2f:	85 c0                	test   %eax,%eax
80107b31:	79 15                	jns    80107b48 <setupkvm+0xd7>
      freevm(pgdir);
80107b33:	83 ec 0c             	sub    $0xc,%esp
80107b36:	ff 75 f0             	push   -0x10(%ebp)
80107b39:	e8 f5 04 00 00       	call   80108033 <freevm>
80107b3e:	83 c4 10             	add    $0x10,%esp
      return 0;
80107b41:	b8 00 00 00 00       	mov    $0x0,%eax
80107b46:	eb 10                	jmp    80107b58 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107b48:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107b4c:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107b53:	72 a9                	jb     80107afe <setupkvm+0x8d>
    }
  return pgdir;
80107b55:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107b58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107b5b:	c9                   	leave  
80107b5c:	c3                   	ret    

80107b5d <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107b5d:	55                   	push   %ebp
80107b5e:	89 e5                	mov    %esp,%ebp
80107b60:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107b63:	e8 09 ff ff ff       	call   80107a71 <setupkvm>
80107b68:	a3 7c 74 19 80       	mov    %eax,0x8019747c
  switchkvm();
80107b6d:	e8 03 00 00 00       	call   80107b75 <switchkvm>
}
80107b72:	90                   	nop
80107b73:	c9                   	leave  
80107b74:	c3                   	ret    

80107b75 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107b75:	55                   	push   %ebp
80107b76:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107b78:	a1 7c 74 19 80       	mov    0x8019747c,%eax
80107b7d:	05 00 00 00 80       	add    $0x80000000,%eax
80107b82:	50                   	push   %eax
80107b83:	e8 61 fa ff ff       	call   801075e9 <lcr3>
80107b88:	83 c4 04             	add    $0x4,%esp
}
80107b8b:	90                   	nop
80107b8c:	c9                   	leave  
80107b8d:	c3                   	ret    

80107b8e <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107b8e:	55                   	push   %ebp
80107b8f:	89 e5                	mov    %esp,%ebp
80107b91:	56                   	push   %esi
80107b92:	53                   	push   %ebx
80107b93:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107b96:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107b9a:	75 0d                	jne    80107ba9 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107b9c:	83 ec 0c             	sub    $0xc,%esp
80107b9f:	68 76 ad 10 80       	push   $0x8010ad76
80107ba4:	e8 00 8a ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80107bac:	8b 40 08             	mov    0x8(%eax),%eax
80107baf:	85 c0                	test   %eax,%eax
80107bb1:	75 0d                	jne    80107bc0 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107bb3:	83 ec 0c             	sub    $0xc,%esp
80107bb6:	68 8c ad 10 80       	push   $0x8010ad8c
80107bbb:	e8 e9 89 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107bc0:	8b 45 08             	mov    0x8(%ebp),%eax
80107bc3:	8b 40 04             	mov    0x4(%eax),%eax
80107bc6:	85 c0                	test   %eax,%eax
80107bc8:	75 0d                	jne    80107bd7 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107bca:	83 ec 0c             	sub    $0xc,%esp
80107bcd:	68 a1 ad 10 80       	push   $0x8010ada1
80107bd2:	e8 d2 89 ff ff       	call   801005a9 <panic>

  pushcli();
80107bd7:	e8 b4 d0 ff ff       	call   80104c90 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107bdc:	e8 d7 bd ff ff       	call   801039b8 <mycpu>
80107be1:	89 c3                	mov    %eax,%ebx
80107be3:	e8 d0 bd ff ff       	call   801039b8 <mycpu>
80107be8:	83 c0 08             	add    $0x8,%eax
80107beb:	89 c6                	mov    %eax,%esi
80107bed:	e8 c6 bd ff ff       	call   801039b8 <mycpu>
80107bf2:	83 c0 08             	add    $0x8,%eax
80107bf5:	c1 e8 10             	shr    $0x10,%eax
80107bf8:	88 45 f7             	mov    %al,-0x9(%ebp)
80107bfb:	e8 b8 bd ff ff       	call   801039b8 <mycpu>
80107c00:	83 c0 08             	add    $0x8,%eax
80107c03:	c1 e8 18             	shr    $0x18,%eax
80107c06:	89 c2                	mov    %eax,%edx
80107c08:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107c0f:	67 00 
80107c11:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107c18:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107c1c:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107c22:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c29:	83 e0 f0             	and    $0xfffffff0,%eax
80107c2c:	83 c8 09             	or     $0x9,%eax
80107c2f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c35:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c3c:	83 c8 10             	or     $0x10,%eax
80107c3f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c45:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c4c:	83 e0 9f             	and    $0xffffff9f,%eax
80107c4f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c55:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c5c:	83 c8 80             	or     $0xffffff80,%eax
80107c5f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c65:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c6c:	83 e0 f0             	and    $0xfffffff0,%eax
80107c6f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c75:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c7c:	83 e0 ef             	and    $0xffffffef,%eax
80107c7f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c85:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c8c:	83 e0 df             	and    $0xffffffdf,%eax
80107c8f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c95:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c9c:	83 c8 40             	or     $0x40,%eax
80107c9f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ca5:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107cac:	83 e0 7f             	and    $0x7f,%eax
80107caf:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107cb5:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107cbb:	e8 f8 bc ff ff       	call   801039b8 <mycpu>
80107cc0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cc7:	83 e2 ef             	and    $0xffffffef,%edx
80107cca:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107cd0:	e8 e3 bc ff ff       	call   801039b8 <mycpu>
80107cd5:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80107cde:	8b 40 08             	mov    0x8(%eax),%eax
80107ce1:	89 c3                	mov    %eax,%ebx
80107ce3:	e8 d0 bc ff ff       	call   801039b8 <mycpu>
80107ce8:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107cee:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107cf1:	e8 c2 bc ff ff       	call   801039b8 <mycpu>
80107cf6:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107cfc:	83 ec 0c             	sub    $0xc,%esp
80107cff:	6a 28                	push   $0x28
80107d01:	e8 cc f8 ff ff       	call   801075d2 <ltr>
80107d06:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107d09:	8b 45 08             	mov    0x8(%ebp),%eax
80107d0c:	8b 40 04             	mov    0x4(%eax),%eax
80107d0f:	05 00 00 00 80       	add    $0x80000000,%eax
80107d14:	83 ec 0c             	sub    $0xc,%esp
80107d17:	50                   	push   %eax
80107d18:	e8 cc f8 ff ff       	call   801075e9 <lcr3>
80107d1d:	83 c4 10             	add    $0x10,%esp
  popcli();
80107d20:	e8 b8 cf ff ff       	call   80104cdd <popcli>
}
80107d25:	90                   	nop
80107d26:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107d29:	5b                   	pop    %ebx
80107d2a:	5e                   	pop    %esi
80107d2b:	5d                   	pop    %ebp
80107d2c:	c3                   	ret    

80107d2d <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107d2d:	55                   	push   %ebp
80107d2e:	89 e5                	mov    %esp,%ebp
80107d30:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107d33:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107d3a:	76 0d                	jbe    80107d49 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107d3c:	83 ec 0c             	sub    $0xc,%esp
80107d3f:	68 b5 ad 10 80       	push   $0x8010adb5
80107d44:	e8 60 88 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107d49:	e8 52 aa ff ff       	call   801027a0 <kalloc>
80107d4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107d51:	83 ec 04             	sub    $0x4,%esp
80107d54:	68 00 10 00 00       	push   $0x1000
80107d59:	6a 00                	push   $0x0
80107d5b:	ff 75 f4             	push   -0xc(%ebp)
80107d5e:	e8 38 d0 ff ff       	call   80104d9b <memset>
80107d63:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d69:	05 00 00 00 80       	add    $0x80000000,%eax
80107d6e:	83 ec 0c             	sub    $0xc,%esp
80107d71:	6a 06                	push   $0x6
80107d73:	50                   	push   %eax
80107d74:	68 00 10 00 00       	push   $0x1000
80107d79:	6a 00                	push   $0x0
80107d7b:	ff 75 08             	push   0x8(%ebp)
80107d7e:	e8 5e fc ff ff       	call   801079e1 <mappages>
80107d83:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107d86:	83 ec 04             	sub    $0x4,%esp
80107d89:	ff 75 10             	push   0x10(%ebp)
80107d8c:	ff 75 0c             	push   0xc(%ebp)
80107d8f:	ff 75 f4             	push   -0xc(%ebp)
80107d92:	e8 c3 d0 ff ff       	call   80104e5a <memmove>
80107d97:	83 c4 10             	add    $0x10,%esp
}
80107d9a:	90                   	nop
80107d9b:	c9                   	leave  
80107d9c:	c3                   	ret    

80107d9d <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107d9d:	55                   	push   %ebp
80107d9e:	89 e5                	mov    %esp,%ebp
80107da0:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107da3:	8b 45 0c             	mov    0xc(%ebp),%eax
80107da6:	25 ff 0f 00 00       	and    $0xfff,%eax
80107dab:	85 c0                	test   %eax,%eax
80107dad:	74 0d                	je     80107dbc <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107daf:	83 ec 0c             	sub    $0xc,%esp
80107db2:	68 d0 ad 10 80       	push   $0x8010add0
80107db7:	e8 ed 87 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107dbc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107dc3:	e9 8f 00 00 00       	jmp    80107e57 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107dc8:	8b 55 0c             	mov    0xc(%ebp),%edx
80107dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dce:	01 d0                	add    %edx,%eax
80107dd0:	83 ec 04             	sub    $0x4,%esp
80107dd3:	6a 00                	push   $0x0
80107dd5:	50                   	push   %eax
80107dd6:	ff 75 08             	push   0x8(%ebp)
80107dd9:	e8 6d fb ff ff       	call   8010794b <walkpgdir>
80107dde:	83 c4 10             	add    $0x10,%esp
80107de1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107de4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107de8:	75 0d                	jne    80107df7 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107dea:	83 ec 0c             	sub    $0xc,%esp
80107ded:	68 f3 ad 10 80       	push   $0x8010adf3
80107df2:	e8 b2 87 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107df7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107dfa:	8b 00                	mov    (%eax),%eax
80107dfc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e01:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107e04:	8b 45 18             	mov    0x18(%ebp),%eax
80107e07:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107e0a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107e0f:	77 0b                	ja     80107e1c <loaduvm+0x7f>
      n = sz - i;
80107e11:	8b 45 18             	mov    0x18(%ebp),%eax
80107e14:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107e17:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e1a:	eb 07                	jmp    80107e23 <loaduvm+0x86>
    else
      n = PGSIZE;
80107e1c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107e23:	8b 55 14             	mov    0x14(%ebp),%edx
80107e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e29:	01 d0                	add    %edx,%eax
80107e2b:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107e2e:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107e34:	ff 75 f0             	push   -0x10(%ebp)
80107e37:	50                   	push   %eax
80107e38:	52                   	push   %edx
80107e39:	ff 75 10             	push   0x10(%ebp)
80107e3c:	e8 95 a0 ff ff       	call   80101ed6 <readi>
80107e41:	83 c4 10             	add    $0x10,%esp
80107e44:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107e47:	74 07                	je     80107e50 <loaduvm+0xb3>
      return -1;
80107e49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e4e:	eb 18                	jmp    80107e68 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107e50:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5a:	3b 45 18             	cmp    0x18(%ebp),%eax
80107e5d:	0f 82 65 ff ff ff    	jb     80107dc8 <loaduvm+0x2b>
  }
  return 0;
80107e63:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e68:	c9                   	leave  
80107e69:	c3                   	ret    

80107e6a <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107e6a:	55                   	push   %ebp
80107e6b:	89 e5                	mov    %esp,%ebp
80107e6d:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107e70:	8b 45 10             	mov    0x10(%ebp),%eax
80107e73:	85 c0                	test   %eax,%eax
80107e75:	79 0a                	jns    80107e81 <allocuvm+0x17>
    return 0;
80107e77:	b8 00 00 00 00       	mov    $0x0,%eax
80107e7c:	e9 ec 00 00 00       	jmp    80107f6d <allocuvm+0x103>
  if(newsz < oldsz)
80107e81:	8b 45 10             	mov    0x10(%ebp),%eax
80107e84:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e87:	73 08                	jae    80107e91 <allocuvm+0x27>
    return oldsz;
80107e89:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e8c:	e9 dc 00 00 00       	jmp    80107f6d <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107e91:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e94:	05 ff 0f 00 00       	add    $0xfff,%eax
80107e99:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107ea1:	e9 b8 00 00 00       	jmp    80107f5e <allocuvm+0xf4>
    mem = kalloc();
80107ea6:	e8 f5 a8 ff ff       	call   801027a0 <kalloc>
80107eab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107eae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107eb2:	75 2e                	jne    80107ee2 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107eb4:	83 ec 0c             	sub    $0xc,%esp
80107eb7:	68 11 ae 10 80       	push   $0x8010ae11
80107ebc:	e8 33 85 ff ff       	call   801003f4 <cprintf>
80107ec1:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107ec4:	83 ec 04             	sub    $0x4,%esp
80107ec7:	ff 75 0c             	push   0xc(%ebp)
80107eca:	ff 75 10             	push   0x10(%ebp)
80107ecd:	ff 75 08             	push   0x8(%ebp)
80107ed0:	e8 9a 00 00 00       	call   80107f6f <deallocuvm>
80107ed5:	83 c4 10             	add    $0x10,%esp
      return 0;
80107ed8:	b8 00 00 00 00       	mov    $0x0,%eax
80107edd:	e9 8b 00 00 00       	jmp    80107f6d <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107ee2:	83 ec 04             	sub    $0x4,%esp
80107ee5:	68 00 10 00 00       	push   $0x1000
80107eea:	6a 00                	push   $0x0
80107eec:	ff 75 f0             	push   -0x10(%ebp)
80107eef:	e8 a7 ce ff ff       	call   80104d9b <memset>
80107ef4:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107efa:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f03:	83 ec 0c             	sub    $0xc,%esp
80107f06:	6a 06                	push   $0x6
80107f08:	52                   	push   %edx
80107f09:	68 00 10 00 00       	push   $0x1000
80107f0e:	50                   	push   %eax
80107f0f:	ff 75 08             	push   0x8(%ebp)
80107f12:	e8 ca fa ff ff       	call   801079e1 <mappages>
80107f17:	83 c4 20             	add    $0x20,%esp
80107f1a:	85 c0                	test   %eax,%eax
80107f1c:	79 39                	jns    80107f57 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107f1e:	83 ec 0c             	sub    $0xc,%esp
80107f21:	68 29 ae 10 80       	push   $0x8010ae29
80107f26:	e8 c9 84 ff ff       	call   801003f4 <cprintf>
80107f2b:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107f2e:	83 ec 04             	sub    $0x4,%esp
80107f31:	ff 75 0c             	push   0xc(%ebp)
80107f34:	ff 75 10             	push   0x10(%ebp)
80107f37:	ff 75 08             	push   0x8(%ebp)
80107f3a:	e8 30 00 00 00       	call   80107f6f <deallocuvm>
80107f3f:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107f42:	83 ec 0c             	sub    $0xc,%esp
80107f45:	ff 75 f0             	push   -0x10(%ebp)
80107f48:	e8 b9 a7 ff ff       	call   80102706 <kfree>
80107f4d:	83 c4 10             	add    $0x10,%esp
      return 0;
80107f50:	b8 00 00 00 00       	mov    $0x0,%eax
80107f55:	eb 16                	jmp    80107f6d <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107f57:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f61:	3b 45 10             	cmp    0x10(%ebp),%eax
80107f64:	0f 82 3c ff ff ff    	jb     80107ea6 <allocuvm+0x3c>
    }
  }
  return newsz;
80107f6a:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f6d:	c9                   	leave  
80107f6e:	c3                   	ret    

80107f6f <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107f6f:	55                   	push   %ebp
80107f70:	89 e5                	mov    %esp,%ebp
80107f72:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107f75:	8b 45 10             	mov    0x10(%ebp),%eax
80107f78:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f7b:	72 08                	jb     80107f85 <deallocuvm+0x16>
    return oldsz;
80107f7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f80:	e9 ac 00 00 00       	jmp    80108031 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107f85:	8b 45 10             	mov    0x10(%ebp),%eax
80107f88:	05 ff 0f 00 00       	add    $0xfff,%eax
80107f8d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f92:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107f95:	e9 88 00 00 00       	jmp    80108022 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9d:	83 ec 04             	sub    $0x4,%esp
80107fa0:	6a 00                	push   $0x0
80107fa2:	50                   	push   %eax
80107fa3:	ff 75 08             	push   0x8(%ebp)
80107fa6:	e8 a0 f9 ff ff       	call   8010794b <walkpgdir>
80107fab:	83 c4 10             	add    $0x10,%esp
80107fae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107fb1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fb5:	75 16                	jne    80107fcd <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fba:	c1 e8 16             	shr    $0x16,%eax
80107fbd:	83 c0 01             	add    $0x1,%eax
80107fc0:	c1 e0 16             	shl    $0x16,%eax
80107fc3:	2d 00 10 00 00       	sub    $0x1000,%eax
80107fc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fcb:	eb 4e                	jmp    8010801b <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107fcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fd0:	8b 00                	mov    (%eax),%eax
80107fd2:	83 e0 01             	and    $0x1,%eax
80107fd5:	85 c0                	test   %eax,%eax
80107fd7:	74 42                	je     8010801b <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107fd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fdc:	8b 00                	mov    (%eax),%eax
80107fde:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fe3:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107fe6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fea:	75 0d                	jne    80107ff9 <deallocuvm+0x8a>
        panic("kfree");
80107fec:	83 ec 0c             	sub    $0xc,%esp
80107fef:	68 45 ae 10 80       	push   $0x8010ae45
80107ff4:	e8 b0 85 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107ff9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ffc:	05 00 00 00 80       	add    $0x80000000,%eax
80108001:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108004:	83 ec 0c             	sub    $0xc,%esp
80108007:	ff 75 e8             	push   -0x18(%ebp)
8010800a:	e8 f7 a6 ff ff       	call   80102706 <kfree>
8010800f:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108012:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108015:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010801b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108025:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108028:	0f 82 6c ff ff ff    	jb     80107f9a <deallocuvm+0x2b>
    }
  }
  return newsz;
8010802e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108031:	c9                   	leave  
80108032:	c3                   	ret    

80108033 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108033:	55                   	push   %ebp
80108034:	89 e5                	mov    %esp,%ebp
80108036:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108039:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010803d:	75 0d                	jne    8010804c <freevm+0x19>
    panic("freevm: no pgdir");
8010803f:	83 ec 0c             	sub    $0xc,%esp
80108042:	68 4b ae 10 80       	push   $0x8010ae4b
80108047:	e8 5d 85 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010804c:	83 ec 04             	sub    $0x4,%esp
8010804f:	6a 00                	push   $0x0
80108051:	68 00 00 00 80       	push   $0x80000000
80108056:	ff 75 08             	push   0x8(%ebp)
80108059:	e8 11 ff ff ff       	call   80107f6f <deallocuvm>
8010805e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108061:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108068:	eb 48                	jmp    801080b2 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
8010806a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108074:	8b 45 08             	mov    0x8(%ebp),%eax
80108077:	01 d0                	add    %edx,%eax
80108079:	8b 00                	mov    (%eax),%eax
8010807b:	83 e0 01             	and    $0x1,%eax
8010807e:	85 c0                	test   %eax,%eax
80108080:	74 2c                	je     801080ae <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108085:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010808c:	8b 45 08             	mov    0x8(%ebp),%eax
8010808f:	01 d0                	add    %edx,%eax
80108091:	8b 00                	mov    (%eax),%eax
80108093:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108098:	05 00 00 00 80       	add    $0x80000000,%eax
8010809d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801080a0:	83 ec 0c             	sub    $0xc,%esp
801080a3:	ff 75 f0             	push   -0x10(%ebp)
801080a6:	e8 5b a6 ff ff       	call   80102706 <kfree>
801080ab:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801080ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801080b2:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801080b9:	76 af                	jbe    8010806a <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
801080bb:	83 ec 0c             	sub    $0xc,%esp
801080be:	ff 75 08             	push   0x8(%ebp)
801080c1:	e8 40 a6 ff ff       	call   80102706 <kfree>
801080c6:	83 c4 10             	add    $0x10,%esp
}
801080c9:	90                   	nop
801080ca:	c9                   	leave  
801080cb:	c3                   	ret    

801080cc <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801080cc:	55                   	push   %ebp
801080cd:	89 e5                	mov    %esp,%ebp
801080cf:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801080d2:	83 ec 04             	sub    $0x4,%esp
801080d5:	6a 00                	push   $0x0
801080d7:	ff 75 0c             	push   0xc(%ebp)
801080da:	ff 75 08             	push   0x8(%ebp)
801080dd:	e8 69 f8 ff ff       	call   8010794b <walkpgdir>
801080e2:	83 c4 10             	add    $0x10,%esp
801080e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801080e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801080ec:	75 0d                	jne    801080fb <clearpteu+0x2f>
    panic("clearpteu");
801080ee:	83 ec 0c             	sub    $0xc,%esp
801080f1:	68 5c ae 10 80       	push   $0x8010ae5c
801080f6:	e8 ae 84 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
801080fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080fe:	8b 00                	mov    (%eax),%eax
80108100:	83 e0 fb             	and    $0xfffffffb,%eax
80108103:	89 c2                	mov    %eax,%edx
80108105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108108:	89 10                	mov    %edx,(%eax)
}
8010810a:	90                   	nop
8010810b:	c9                   	leave  
8010810c:	c3                   	ret    

8010810d <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010810d:	55                   	push   %ebp
8010810e:	89 e5                	mov    %esp,%ebp
80108110:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108113:	e8 59 f9 ff ff       	call   80107a71 <setupkvm>
80108118:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010811b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010811f:	75 0a                	jne    8010812b <copyuvm+0x1e>
    return 0;
80108121:	b8 00 00 00 00       	mov    $0x0,%eax
80108126:	e9 eb 00 00 00       	jmp    80108216 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
8010812b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108132:	e9 b7 00 00 00       	jmp    801081ee <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813a:	83 ec 04             	sub    $0x4,%esp
8010813d:	6a 00                	push   $0x0
8010813f:	50                   	push   %eax
80108140:	ff 75 08             	push   0x8(%ebp)
80108143:	e8 03 f8 ff ff       	call   8010794b <walkpgdir>
80108148:	83 c4 10             	add    $0x10,%esp
8010814b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010814e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108152:	75 0d                	jne    80108161 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80108154:	83 ec 0c             	sub    $0xc,%esp
80108157:	68 66 ae 10 80       	push   $0x8010ae66
8010815c:	e8 48 84 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80108161:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108164:	8b 00                	mov    (%eax),%eax
80108166:	83 e0 01             	and    $0x1,%eax
80108169:	85 c0                	test   %eax,%eax
8010816b:	75 0d                	jne    8010817a <copyuvm+0x6d>
      panic("copyuvm: page not present");
8010816d:	83 ec 0c             	sub    $0xc,%esp
80108170:	68 80 ae 10 80       	push   $0x8010ae80
80108175:	e8 2f 84 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
8010817a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010817d:	8b 00                	mov    (%eax),%eax
8010817f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108184:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108187:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010818a:	8b 00                	mov    (%eax),%eax
8010818c:	25 ff 0f 00 00       	and    $0xfff,%eax
80108191:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108194:	e8 07 a6 ff ff       	call   801027a0 <kalloc>
80108199:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010819c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801081a0:	74 5d                	je     801081ff <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801081a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081a5:	05 00 00 00 80       	add    $0x80000000,%eax
801081aa:	83 ec 04             	sub    $0x4,%esp
801081ad:	68 00 10 00 00       	push   $0x1000
801081b2:	50                   	push   %eax
801081b3:	ff 75 e0             	push   -0x20(%ebp)
801081b6:	e8 9f cc ff ff       	call   80104e5a <memmove>
801081bb:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801081be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801081c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801081c4:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801081ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081cd:	83 ec 0c             	sub    $0xc,%esp
801081d0:	52                   	push   %edx
801081d1:	51                   	push   %ecx
801081d2:	68 00 10 00 00       	push   $0x1000
801081d7:	50                   	push   %eax
801081d8:	ff 75 f0             	push   -0x10(%ebp)
801081db:	e8 01 f8 ff ff       	call   801079e1 <mappages>
801081e0:	83 c4 20             	add    $0x20,%esp
801081e3:	85 c0                	test   %eax,%eax
801081e5:	78 1b                	js     80108202 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
801081e7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081f4:	0f 82 3d ff ff ff    	jb     80108137 <copyuvm+0x2a>
      goto bad;
  }
  return d;
801081fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081fd:	eb 17                	jmp    80108216 <copyuvm+0x109>
      goto bad;
801081ff:	90                   	nop
80108200:	eb 01                	jmp    80108203 <copyuvm+0xf6>
      goto bad;
80108202:	90                   	nop

bad:
  freevm(d);
80108203:	83 ec 0c             	sub    $0xc,%esp
80108206:	ff 75 f0             	push   -0x10(%ebp)
80108209:	e8 25 fe ff ff       	call   80108033 <freevm>
8010820e:	83 c4 10             	add    $0x10,%esp
  return 0;
80108211:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108216:	c9                   	leave  
80108217:	c3                   	ret    

80108218 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108218:	55                   	push   %ebp
80108219:	89 e5                	mov    %esp,%ebp
8010821b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010821e:	83 ec 04             	sub    $0x4,%esp
80108221:	6a 00                	push   $0x0
80108223:	ff 75 0c             	push   0xc(%ebp)
80108226:	ff 75 08             	push   0x8(%ebp)
80108229:	e8 1d f7 ff ff       	call   8010794b <walkpgdir>
8010822e:	83 c4 10             	add    $0x10,%esp
80108231:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108237:	8b 00                	mov    (%eax),%eax
80108239:	83 e0 01             	and    $0x1,%eax
8010823c:	85 c0                	test   %eax,%eax
8010823e:	75 07                	jne    80108247 <uva2ka+0x2f>
    return 0;
80108240:	b8 00 00 00 00       	mov    $0x0,%eax
80108245:	eb 22                	jmp    80108269 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108247:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824a:	8b 00                	mov    (%eax),%eax
8010824c:	83 e0 04             	and    $0x4,%eax
8010824f:	85 c0                	test   %eax,%eax
80108251:	75 07                	jne    8010825a <uva2ka+0x42>
    return 0;
80108253:	b8 00 00 00 00       	mov    $0x0,%eax
80108258:	eb 0f                	jmp    80108269 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
8010825a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825d:	8b 00                	mov    (%eax),%eax
8010825f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108264:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108269:	c9                   	leave  
8010826a:	c3                   	ret    

8010826b <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010826b:	55                   	push   %ebp
8010826c:	89 e5                	mov    %esp,%ebp
8010826e:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108271:	8b 45 10             	mov    0x10(%ebp),%eax
80108274:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108277:	eb 7f                	jmp    801082f8 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108279:	8b 45 0c             	mov    0xc(%ebp),%eax
8010827c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108281:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108284:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108287:	83 ec 08             	sub    $0x8,%esp
8010828a:	50                   	push   %eax
8010828b:	ff 75 08             	push   0x8(%ebp)
8010828e:	e8 85 ff ff ff       	call   80108218 <uva2ka>
80108293:	83 c4 10             	add    $0x10,%esp
80108296:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108299:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010829d:	75 07                	jne    801082a6 <copyout+0x3b>
      return -1;
8010829f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082a4:	eb 61                	jmp    80108307 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801082a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082a9:	2b 45 0c             	sub    0xc(%ebp),%eax
801082ac:	05 00 10 00 00       	add    $0x1000,%eax
801082b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801082b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082b7:	3b 45 14             	cmp    0x14(%ebp),%eax
801082ba:	76 06                	jbe    801082c2 <copyout+0x57>
      n = len;
801082bc:	8b 45 14             	mov    0x14(%ebp),%eax
801082bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801082c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801082c5:	2b 45 ec             	sub    -0x14(%ebp),%eax
801082c8:	89 c2                	mov    %eax,%edx
801082ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082cd:	01 d0                	add    %edx,%eax
801082cf:	83 ec 04             	sub    $0x4,%esp
801082d2:	ff 75 f0             	push   -0x10(%ebp)
801082d5:	ff 75 f4             	push   -0xc(%ebp)
801082d8:	50                   	push   %eax
801082d9:	e8 7c cb ff ff       	call   80104e5a <memmove>
801082de:	83 c4 10             	add    $0x10,%esp
    len -= n;
801082e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082e4:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801082e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082ea:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801082ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082f0:	05 00 10 00 00       	add    $0x1000,%eax
801082f5:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801082f8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801082fc:	0f 85 77 ff ff ff    	jne    80108279 <copyout+0xe>
  }
  return 0;
80108302:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108307:	c9                   	leave  
80108308:	c3                   	ret    

80108309 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108309:	55                   	push   %ebp
8010830a:	89 e5                	mov    %esp,%ebp
8010830c:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010830f:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108316:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108319:	8b 40 08             	mov    0x8(%eax),%eax
8010831c:	05 00 00 00 80       	add    $0x80000000,%eax
80108321:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108324:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
8010832b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832e:	8b 40 24             	mov    0x24(%eax),%eax
80108331:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80108336:	c7 05 50 77 19 80 00 	movl   $0x0,0x80197750
8010833d:	00 00 00 

  while(i<madt->len){
80108340:	90                   	nop
80108341:	e9 bd 00 00 00       	jmp    80108403 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80108346:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108349:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010834c:	01 d0                	add    %edx,%eax
8010834e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108351:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108354:	0f b6 00             	movzbl (%eax),%eax
80108357:	0f b6 c0             	movzbl %al,%eax
8010835a:	83 f8 05             	cmp    $0x5,%eax
8010835d:	0f 87 a0 00 00 00    	ja     80108403 <mpinit_uefi+0xfa>
80108363:	8b 04 85 9c ae 10 80 	mov    -0x7fef5164(,%eax,4),%eax
8010836a:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
8010836c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010836f:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108372:	a1 50 77 19 80       	mov    0x80197750,%eax
80108377:	83 f8 03             	cmp    $0x3,%eax
8010837a:	7f 28                	jg     801083a4 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
8010837c:	8b 15 50 77 19 80    	mov    0x80197750,%edx
80108382:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108385:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108389:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
8010838f:	81 c2 80 74 19 80    	add    $0x80197480,%edx
80108395:	88 02                	mov    %al,(%edx)
          ncpu++;
80108397:	a1 50 77 19 80       	mov    0x80197750,%eax
8010839c:	83 c0 01             	add    $0x1,%eax
8010839f:	a3 50 77 19 80       	mov    %eax,0x80197750
        }
        i += lapic_entry->record_len;
801083a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801083a7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083ab:	0f b6 c0             	movzbl %al,%eax
801083ae:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801083b1:	eb 50                	jmp    80108403 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801083b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801083b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801083bc:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801083c0:	a2 54 77 19 80       	mov    %al,0x80197754
        i += ioapic->record_len;
801083c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801083c8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083cc:	0f b6 c0             	movzbl %al,%eax
801083cf:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801083d2:	eb 2f                	jmp    80108403 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801083d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083d7:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801083da:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083dd:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083e1:	0f b6 c0             	movzbl %al,%eax
801083e4:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801083e7:	eb 1a                	jmp    80108403 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801083e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801083ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083f2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083f6:	0f b6 c0             	movzbl %al,%eax
801083f9:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801083fc:	eb 05                	jmp    80108403 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
801083fe:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108402:	90                   	nop
  while(i<madt->len){
80108403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108406:	8b 40 04             	mov    0x4(%eax),%eax
80108409:	39 45 fc             	cmp    %eax,-0x4(%ebp)
8010840c:	0f 82 34 ff ff ff    	jb     80108346 <mpinit_uefi+0x3d>
    }
  }

}
80108412:	90                   	nop
80108413:	90                   	nop
80108414:	c9                   	leave  
80108415:	c3                   	ret    

80108416 <inb>:
{
80108416:	55                   	push   %ebp
80108417:	89 e5                	mov    %esp,%ebp
80108419:	83 ec 14             	sub    $0x14,%esp
8010841c:	8b 45 08             	mov    0x8(%ebp),%eax
8010841f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108423:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108427:	89 c2                	mov    %eax,%edx
80108429:	ec                   	in     (%dx),%al
8010842a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010842d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108431:	c9                   	leave  
80108432:	c3                   	ret    

80108433 <outb>:
{
80108433:	55                   	push   %ebp
80108434:	89 e5                	mov    %esp,%ebp
80108436:	83 ec 08             	sub    $0x8,%esp
80108439:	8b 45 08             	mov    0x8(%ebp),%eax
8010843c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010843f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108443:	89 d0                	mov    %edx,%eax
80108445:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108448:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010844c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108450:	ee                   	out    %al,(%dx)
}
80108451:	90                   	nop
80108452:	c9                   	leave  
80108453:	c3                   	ret    

80108454 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108454:	55                   	push   %ebp
80108455:	89 e5                	mov    %esp,%ebp
80108457:	83 ec 28             	sub    $0x28,%esp
8010845a:	8b 45 08             	mov    0x8(%ebp),%eax
8010845d:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108460:	6a 00                	push   $0x0
80108462:	68 fa 03 00 00       	push   $0x3fa
80108467:	e8 c7 ff ff ff       	call   80108433 <outb>
8010846c:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010846f:	68 80 00 00 00       	push   $0x80
80108474:	68 fb 03 00 00       	push   $0x3fb
80108479:	e8 b5 ff ff ff       	call   80108433 <outb>
8010847e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108481:	6a 0c                	push   $0xc
80108483:	68 f8 03 00 00       	push   $0x3f8
80108488:	e8 a6 ff ff ff       	call   80108433 <outb>
8010848d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108490:	6a 00                	push   $0x0
80108492:	68 f9 03 00 00       	push   $0x3f9
80108497:	e8 97 ff ff ff       	call   80108433 <outb>
8010849c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010849f:	6a 03                	push   $0x3
801084a1:	68 fb 03 00 00       	push   $0x3fb
801084a6:	e8 88 ff ff ff       	call   80108433 <outb>
801084ab:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801084ae:	6a 00                	push   $0x0
801084b0:	68 fc 03 00 00       	push   $0x3fc
801084b5:	e8 79 ff ff ff       	call   80108433 <outb>
801084ba:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801084bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084c4:	eb 11                	jmp    801084d7 <uart_debug+0x83>
801084c6:	83 ec 0c             	sub    $0xc,%esp
801084c9:	6a 0a                	push   $0xa
801084cb:	e8 67 a6 ff ff       	call   80102b37 <microdelay>
801084d0:	83 c4 10             	add    $0x10,%esp
801084d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801084d7:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801084db:	7f 1a                	jg     801084f7 <uart_debug+0xa3>
801084dd:	83 ec 0c             	sub    $0xc,%esp
801084e0:	68 fd 03 00 00       	push   $0x3fd
801084e5:	e8 2c ff ff ff       	call   80108416 <inb>
801084ea:	83 c4 10             	add    $0x10,%esp
801084ed:	0f b6 c0             	movzbl %al,%eax
801084f0:	83 e0 20             	and    $0x20,%eax
801084f3:	85 c0                	test   %eax,%eax
801084f5:	74 cf                	je     801084c6 <uart_debug+0x72>
  outb(COM1+0, p);
801084f7:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801084fb:	0f b6 c0             	movzbl %al,%eax
801084fe:	83 ec 08             	sub    $0x8,%esp
80108501:	50                   	push   %eax
80108502:	68 f8 03 00 00       	push   $0x3f8
80108507:	e8 27 ff ff ff       	call   80108433 <outb>
8010850c:	83 c4 10             	add    $0x10,%esp
}
8010850f:	90                   	nop
80108510:	c9                   	leave  
80108511:	c3                   	ret    

80108512 <uart_debugs>:

void uart_debugs(char *p){
80108512:	55                   	push   %ebp
80108513:	89 e5                	mov    %esp,%ebp
80108515:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108518:	eb 1b                	jmp    80108535 <uart_debugs+0x23>
    uart_debug(*p++);
8010851a:	8b 45 08             	mov    0x8(%ebp),%eax
8010851d:	8d 50 01             	lea    0x1(%eax),%edx
80108520:	89 55 08             	mov    %edx,0x8(%ebp)
80108523:	0f b6 00             	movzbl (%eax),%eax
80108526:	0f be c0             	movsbl %al,%eax
80108529:	83 ec 0c             	sub    $0xc,%esp
8010852c:	50                   	push   %eax
8010852d:	e8 22 ff ff ff       	call   80108454 <uart_debug>
80108532:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108535:	8b 45 08             	mov    0x8(%ebp),%eax
80108538:	0f b6 00             	movzbl (%eax),%eax
8010853b:	84 c0                	test   %al,%al
8010853d:	75 db                	jne    8010851a <uart_debugs+0x8>
  }
}
8010853f:	90                   	nop
80108540:	90                   	nop
80108541:	c9                   	leave  
80108542:	c3                   	ret    

80108543 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108543:	55                   	push   %ebp
80108544:	89 e5                	mov    %esp,%ebp
80108546:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108549:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108550:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108553:	8b 50 14             	mov    0x14(%eax),%edx
80108556:	8b 40 10             	mov    0x10(%eax),%eax
80108559:	a3 58 77 19 80       	mov    %eax,0x80197758
  gpu.vram_size = boot_param->graphic_config.frame_size;
8010855e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108561:	8b 50 1c             	mov    0x1c(%eax),%edx
80108564:	8b 40 18             	mov    0x18(%eax),%eax
80108567:	a3 60 77 19 80       	mov    %eax,0x80197760
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
8010856c:	8b 15 60 77 19 80    	mov    0x80197760,%edx
80108572:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80108577:	29 d0                	sub    %edx,%eax
80108579:	a3 5c 77 19 80       	mov    %eax,0x8019775c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010857e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108581:	8b 50 24             	mov    0x24(%eax),%edx
80108584:	8b 40 20             	mov    0x20(%eax),%eax
80108587:	a3 64 77 19 80       	mov    %eax,0x80197764
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
8010858c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010858f:	8b 50 2c             	mov    0x2c(%eax),%edx
80108592:	8b 40 28             	mov    0x28(%eax),%eax
80108595:	a3 68 77 19 80       	mov    %eax,0x80197768
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
8010859a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010859d:	8b 50 34             	mov    0x34(%eax),%edx
801085a0:	8b 40 30             	mov    0x30(%eax),%eax
801085a3:	a3 6c 77 19 80       	mov    %eax,0x8019776c
}
801085a8:	90                   	nop
801085a9:	c9                   	leave  
801085aa:	c3                   	ret    

801085ab <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801085ab:	55                   	push   %ebp
801085ac:	89 e5                	mov    %esp,%ebp
801085ae:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801085b1:	8b 15 6c 77 19 80    	mov    0x8019776c,%edx
801085b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801085ba:	0f af d0             	imul   %eax,%edx
801085bd:	8b 45 08             	mov    0x8(%ebp),%eax
801085c0:	01 d0                	add    %edx,%eax
801085c2:	c1 e0 02             	shl    $0x2,%eax
801085c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801085c8:	8b 15 5c 77 19 80    	mov    0x8019775c,%edx
801085ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801085d1:	01 d0                	add    %edx,%eax
801085d3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801085d6:	8b 45 10             	mov    0x10(%ebp),%eax
801085d9:	0f b6 10             	movzbl (%eax),%edx
801085dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801085df:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801085e1:	8b 45 10             	mov    0x10(%ebp),%eax
801085e4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801085e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801085eb:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801085ee:	8b 45 10             	mov    0x10(%ebp),%eax
801085f1:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801085f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801085f8:	88 50 02             	mov    %dl,0x2(%eax)
}
801085fb:	90                   	nop
801085fc:	c9                   	leave  
801085fd:	c3                   	ret    

801085fe <graphic_scroll_up>:

void graphic_scroll_up(int height){
801085fe:	55                   	push   %ebp
801085ff:	89 e5                	mov    %esp,%ebp
80108601:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108604:	8b 15 6c 77 19 80    	mov    0x8019776c,%edx
8010860a:	8b 45 08             	mov    0x8(%ebp),%eax
8010860d:	0f af c2             	imul   %edx,%eax
80108610:	c1 e0 02             	shl    $0x2,%eax
80108613:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108616:	a1 60 77 19 80       	mov    0x80197760,%eax
8010861b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010861e:	29 d0                	sub    %edx,%eax
80108620:	8b 0d 5c 77 19 80    	mov    0x8019775c,%ecx
80108626:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108629:	01 ca                	add    %ecx,%edx
8010862b:	89 d1                	mov    %edx,%ecx
8010862d:	8b 15 5c 77 19 80    	mov    0x8019775c,%edx
80108633:	83 ec 04             	sub    $0x4,%esp
80108636:	50                   	push   %eax
80108637:	51                   	push   %ecx
80108638:	52                   	push   %edx
80108639:	e8 1c c8 ff ff       	call   80104e5a <memmove>
8010863e:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108641:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108644:	8b 0d 5c 77 19 80    	mov    0x8019775c,%ecx
8010864a:	8b 15 60 77 19 80    	mov    0x80197760,%edx
80108650:	01 ca                	add    %ecx,%edx
80108652:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108655:	29 ca                	sub    %ecx,%edx
80108657:	83 ec 04             	sub    $0x4,%esp
8010865a:	50                   	push   %eax
8010865b:	6a 00                	push   $0x0
8010865d:	52                   	push   %edx
8010865e:	e8 38 c7 ff ff       	call   80104d9b <memset>
80108663:	83 c4 10             	add    $0x10,%esp
}
80108666:	90                   	nop
80108667:	c9                   	leave  
80108668:	c3                   	ret    

80108669 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108669:	55                   	push   %ebp
8010866a:	89 e5                	mov    %esp,%ebp
8010866c:	53                   	push   %ebx
8010866d:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108670:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108677:	e9 b1 00 00 00       	jmp    8010872d <font_render+0xc4>
    for(int j=14;j>-1;j--){
8010867c:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108683:	e9 97 00 00 00       	jmp    8010871f <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108688:	8b 45 10             	mov    0x10(%ebp),%eax
8010868b:	83 e8 20             	sub    $0x20,%eax
8010868e:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108694:	01 d0                	add    %edx,%eax
80108696:	0f b7 84 00 c0 ae 10 	movzwl -0x7fef5140(%eax,%eax,1),%eax
8010869d:	80 
8010869e:	0f b7 d0             	movzwl %ax,%edx
801086a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086a4:	bb 01 00 00 00       	mov    $0x1,%ebx
801086a9:	89 c1                	mov    %eax,%ecx
801086ab:	d3 e3                	shl    %cl,%ebx
801086ad:	89 d8                	mov    %ebx,%eax
801086af:	21 d0                	and    %edx,%eax
801086b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801086b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086b7:	ba 01 00 00 00       	mov    $0x1,%edx
801086bc:	89 c1                	mov    %eax,%ecx
801086be:	d3 e2                	shl    %cl,%edx
801086c0:	89 d0                	mov    %edx,%eax
801086c2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801086c5:	75 2b                	jne    801086f2 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801086c7:	8b 55 0c             	mov    0xc(%ebp),%edx
801086ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cd:	01 c2                	add    %eax,%edx
801086cf:	b8 0e 00 00 00       	mov    $0xe,%eax
801086d4:	2b 45 f0             	sub    -0x10(%ebp),%eax
801086d7:	89 c1                	mov    %eax,%ecx
801086d9:	8b 45 08             	mov    0x8(%ebp),%eax
801086dc:	01 c8                	add    %ecx,%eax
801086de:	83 ec 04             	sub    $0x4,%esp
801086e1:	68 00 f5 10 80       	push   $0x8010f500
801086e6:	52                   	push   %edx
801086e7:	50                   	push   %eax
801086e8:	e8 be fe ff ff       	call   801085ab <graphic_draw_pixel>
801086ed:	83 c4 10             	add    $0x10,%esp
801086f0:	eb 29                	jmp    8010871b <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801086f2:	8b 55 0c             	mov    0xc(%ebp),%edx
801086f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f8:	01 c2                	add    %eax,%edx
801086fa:	b8 0e 00 00 00       	mov    $0xe,%eax
801086ff:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108702:	89 c1                	mov    %eax,%ecx
80108704:	8b 45 08             	mov    0x8(%ebp),%eax
80108707:	01 c8                	add    %ecx,%eax
80108709:	83 ec 04             	sub    $0x4,%esp
8010870c:	68 70 77 19 80       	push   $0x80197770
80108711:	52                   	push   %edx
80108712:	50                   	push   %eax
80108713:	e8 93 fe ff ff       	call   801085ab <graphic_draw_pixel>
80108718:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
8010871b:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010871f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108723:	0f 89 5f ff ff ff    	jns    80108688 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108729:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010872d:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108731:	0f 8e 45 ff ff ff    	jle    8010867c <font_render+0x13>
      }
    }
  }
}
80108737:	90                   	nop
80108738:	90                   	nop
80108739:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010873c:	c9                   	leave  
8010873d:	c3                   	ret    

8010873e <font_render_string>:

void font_render_string(char *string,int row){
8010873e:	55                   	push   %ebp
8010873f:	89 e5                	mov    %esp,%ebp
80108741:	53                   	push   %ebx
80108742:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108745:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010874c:	eb 33                	jmp    80108781 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
8010874e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108751:	8b 45 08             	mov    0x8(%ebp),%eax
80108754:	01 d0                	add    %edx,%eax
80108756:	0f b6 00             	movzbl (%eax),%eax
80108759:	0f be c8             	movsbl %al,%ecx
8010875c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010875f:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108762:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80108765:	89 d8                	mov    %ebx,%eax
80108767:	c1 e0 04             	shl    $0x4,%eax
8010876a:	29 d8                	sub    %ebx,%eax
8010876c:	83 c0 02             	add    $0x2,%eax
8010876f:	83 ec 04             	sub    $0x4,%esp
80108772:	51                   	push   %ecx
80108773:	52                   	push   %edx
80108774:	50                   	push   %eax
80108775:	e8 ef fe ff ff       	call   80108669 <font_render>
8010877a:	83 c4 10             	add    $0x10,%esp
    i++;
8010877d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108781:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108784:	8b 45 08             	mov    0x8(%ebp),%eax
80108787:	01 d0                	add    %edx,%eax
80108789:	0f b6 00             	movzbl (%eax),%eax
8010878c:	84 c0                	test   %al,%al
8010878e:	74 06                	je     80108796 <font_render_string+0x58>
80108790:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108794:	7e b8                	jle    8010874e <font_render_string+0x10>
  }
}
80108796:	90                   	nop
80108797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010879a:	c9                   	leave  
8010879b:	c3                   	ret    

8010879c <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010879c:	55                   	push   %ebp
8010879d:	89 e5                	mov    %esp,%ebp
8010879f:	53                   	push   %ebx
801087a0:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801087a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801087aa:	eb 6b                	jmp    80108817 <pci_init+0x7b>
    for(int j=0;j<32;j++){
801087ac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801087b3:	eb 58                	jmp    8010880d <pci_init+0x71>
      for(int k=0;k<8;k++){
801087b5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801087bc:	eb 45                	jmp    80108803 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801087be:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801087c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801087c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c7:	83 ec 0c             	sub    $0xc,%esp
801087ca:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801087cd:	53                   	push   %ebx
801087ce:	6a 00                	push   $0x0
801087d0:	51                   	push   %ecx
801087d1:	52                   	push   %edx
801087d2:	50                   	push   %eax
801087d3:	e8 b0 00 00 00       	call   80108888 <pci_access_config>
801087d8:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801087db:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087de:	0f b7 c0             	movzwl %ax,%eax
801087e1:	3d ff ff 00 00       	cmp    $0xffff,%eax
801087e6:	74 17                	je     801087ff <pci_init+0x63>
        pci_init_device(i,j,k);
801087e8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801087eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801087ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f1:	83 ec 04             	sub    $0x4,%esp
801087f4:	51                   	push   %ecx
801087f5:	52                   	push   %edx
801087f6:	50                   	push   %eax
801087f7:	e8 37 01 00 00       	call   80108933 <pci_init_device>
801087fc:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801087ff:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108803:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108807:	7e b5                	jle    801087be <pci_init+0x22>
    for(int j=0;j<32;j++){
80108809:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010880d:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108811:	7e a2                	jle    801087b5 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108813:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108817:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010881e:	7e 8c                	jle    801087ac <pci_init+0x10>
      }
      }
    }
  }
}
80108820:	90                   	nop
80108821:	90                   	nop
80108822:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108825:	c9                   	leave  
80108826:	c3                   	ret    

80108827 <pci_write_config>:

void pci_write_config(uint config){
80108827:	55                   	push   %ebp
80108828:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010882a:	8b 45 08             	mov    0x8(%ebp),%eax
8010882d:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108832:	89 c0                	mov    %eax,%eax
80108834:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108835:	90                   	nop
80108836:	5d                   	pop    %ebp
80108837:	c3                   	ret    

80108838 <pci_write_data>:

void pci_write_data(uint config){
80108838:	55                   	push   %ebp
80108839:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
8010883b:	8b 45 08             	mov    0x8(%ebp),%eax
8010883e:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108843:	89 c0                	mov    %eax,%eax
80108845:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108846:	90                   	nop
80108847:	5d                   	pop    %ebp
80108848:	c3                   	ret    

80108849 <pci_read_config>:
uint pci_read_config(){
80108849:	55                   	push   %ebp
8010884a:	89 e5                	mov    %esp,%ebp
8010884c:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
8010884f:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108854:	ed                   	in     (%dx),%eax
80108855:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108858:	83 ec 0c             	sub    $0xc,%esp
8010885b:	68 c8 00 00 00       	push   $0xc8
80108860:	e8 d2 a2 ff ff       	call   80102b37 <microdelay>
80108865:	83 c4 10             	add    $0x10,%esp
  return data;
80108868:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010886b:	c9                   	leave  
8010886c:	c3                   	ret    

8010886d <pci_test>:


void pci_test(){
8010886d:	55                   	push   %ebp
8010886e:	89 e5                	mov    %esp,%ebp
80108870:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108873:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
8010887a:	ff 75 fc             	push   -0x4(%ebp)
8010887d:	e8 a5 ff ff ff       	call   80108827 <pci_write_config>
80108882:	83 c4 04             	add    $0x4,%esp
}
80108885:	90                   	nop
80108886:	c9                   	leave  
80108887:	c3                   	ret    

80108888 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108888:	55                   	push   %ebp
80108889:	89 e5                	mov    %esp,%ebp
8010888b:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010888e:	8b 45 08             	mov    0x8(%ebp),%eax
80108891:	c1 e0 10             	shl    $0x10,%eax
80108894:	25 00 00 ff 00       	and    $0xff0000,%eax
80108899:	89 c2                	mov    %eax,%edx
8010889b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010889e:	c1 e0 0b             	shl    $0xb,%eax
801088a1:	0f b7 c0             	movzwl %ax,%eax
801088a4:	09 c2                	or     %eax,%edx
801088a6:	8b 45 10             	mov    0x10(%ebp),%eax
801088a9:	c1 e0 08             	shl    $0x8,%eax
801088ac:	25 00 07 00 00       	and    $0x700,%eax
801088b1:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801088b3:	8b 45 14             	mov    0x14(%ebp),%eax
801088b6:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801088bb:	09 d0                	or     %edx,%eax
801088bd:	0d 00 00 00 80       	or     $0x80000000,%eax
801088c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801088c5:	ff 75 f4             	push   -0xc(%ebp)
801088c8:	e8 5a ff ff ff       	call   80108827 <pci_write_config>
801088cd:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801088d0:	e8 74 ff ff ff       	call   80108849 <pci_read_config>
801088d5:	8b 55 18             	mov    0x18(%ebp),%edx
801088d8:	89 02                	mov    %eax,(%edx)
}
801088da:	90                   	nop
801088db:	c9                   	leave  
801088dc:	c3                   	ret    

801088dd <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801088dd:	55                   	push   %ebp
801088de:	89 e5                	mov    %esp,%ebp
801088e0:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801088e3:	8b 45 08             	mov    0x8(%ebp),%eax
801088e6:	c1 e0 10             	shl    $0x10,%eax
801088e9:	25 00 00 ff 00       	and    $0xff0000,%eax
801088ee:	89 c2                	mov    %eax,%edx
801088f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801088f3:	c1 e0 0b             	shl    $0xb,%eax
801088f6:	0f b7 c0             	movzwl %ax,%eax
801088f9:	09 c2                	or     %eax,%edx
801088fb:	8b 45 10             	mov    0x10(%ebp),%eax
801088fe:	c1 e0 08             	shl    $0x8,%eax
80108901:	25 00 07 00 00       	and    $0x700,%eax
80108906:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108908:	8b 45 14             	mov    0x14(%ebp),%eax
8010890b:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108910:	09 d0                	or     %edx,%eax
80108912:	0d 00 00 00 80       	or     $0x80000000,%eax
80108917:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010891a:	ff 75 fc             	push   -0x4(%ebp)
8010891d:	e8 05 ff ff ff       	call   80108827 <pci_write_config>
80108922:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108925:	ff 75 18             	push   0x18(%ebp)
80108928:	e8 0b ff ff ff       	call   80108838 <pci_write_data>
8010892d:	83 c4 04             	add    $0x4,%esp
}
80108930:	90                   	nop
80108931:	c9                   	leave  
80108932:	c3                   	ret    

80108933 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108933:	55                   	push   %ebp
80108934:	89 e5                	mov    %esp,%ebp
80108936:	53                   	push   %ebx
80108937:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
8010893a:	8b 45 08             	mov    0x8(%ebp),%eax
8010893d:	a2 74 77 19 80       	mov    %al,0x80197774
  dev.device_num = device_num;
80108942:	8b 45 0c             	mov    0xc(%ebp),%eax
80108945:	a2 75 77 19 80       	mov    %al,0x80197775
  dev.function_num = function_num;
8010894a:	8b 45 10             	mov    0x10(%ebp),%eax
8010894d:	a2 76 77 19 80       	mov    %al,0x80197776
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108952:	ff 75 10             	push   0x10(%ebp)
80108955:	ff 75 0c             	push   0xc(%ebp)
80108958:	ff 75 08             	push   0x8(%ebp)
8010895b:	68 04 c5 10 80       	push   $0x8010c504
80108960:	e8 8f 7a ff ff       	call   801003f4 <cprintf>
80108965:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108968:	83 ec 0c             	sub    $0xc,%esp
8010896b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010896e:	50                   	push   %eax
8010896f:	6a 00                	push   $0x0
80108971:	ff 75 10             	push   0x10(%ebp)
80108974:	ff 75 0c             	push   0xc(%ebp)
80108977:	ff 75 08             	push   0x8(%ebp)
8010897a:	e8 09 ff ff ff       	call   80108888 <pci_access_config>
8010897f:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108982:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108985:	c1 e8 10             	shr    $0x10,%eax
80108988:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010898b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010898e:	25 ff ff 00 00       	and    $0xffff,%eax
80108993:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108999:	a3 78 77 19 80       	mov    %eax,0x80197778
  dev.vendor_id = vendor_id;
8010899e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089a1:	a3 7c 77 19 80       	mov    %eax,0x8019777c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801089a6:	83 ec 04             	sub    $0x4,%esp
801089a9:	ff 75 f0             	push   -0x10(%ebp)
801089ac:	ff 75 f4             	push   -0xc(%ebp)
801089af:	68 38 c5 10 80       	push   $0x8010c538
801089b4:	e8 3b 7a ff ff       	call   801003f4 <cprintf>
801089b9:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801089bc:	83 ec 0c             	sub    $0xc,%esp
801089bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
801089c2:	50                   	push   %eax
801089c3:	6a 08                	push   $0x8
801089c5:	ff 75 10             	push   0x10(%ebp)
801089c8:	ff 75 0c             	push   0xc(%ebp)
801089cb:	ff 75 08             	push   0x8(%ebp)
801089ce:	e8 b5 fe ff ff       	call   80108888 <pci_access_config>
801089d3:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801089d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089d9:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801089dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089df:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801089e2:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801089e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089e8:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801089eb:	0f b6 c0             	movzbl %al,%eax
801089ee:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801089f1:	c1 eb 18             	shr    $0x18,%ebx
801089f4:	83 ec 0c             	sub    $0xc,%esp
801089f7:	51                   	push   %ecx
801089f8:	52                   	push   %edx
801089f9:	50                   	push   %eax
801089fa:	53                   	push   %ebx
801089fb:	68 5c c5 10 80       	push   $0x8010c55c
80108a00:	e8 ef 79 ff ff       	call   801003f4 <cprintf>
80108a05:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108a08:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a0b:	c1 e8 18             	shr    $0x18,%eax
80108a0e:	a2 80 77 19 80       	mov    %al,0x80197780
  dev.sub_class = (data>>16)&0xFF;
80108a13:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a16:	c1 e8 10             	shr    $0x10,%eax
80108a19:	a2 81 77 19 80       	mov    %al,0x80197781
  dev.interface = (data>>8)&0xFF;
80108a1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a21:	c1 e8 08             	shr    $0x8,%eax
80108a24:	a2 82 77 19 80       	mov    %al,0x80197782
  dev.revision_id = data&0xFF;
80108a29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a2c:	a2 83 77 19 80       	mov    %al,0x80197783
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108a31:	83 ec 0c             	sub    $0xc,%esp
80108a34:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a37:	50                   	push   %eax
80108a38:	6a 10                	push   $0x10
80108a3a:	ff 75 10             	push   0x10(%ebp)
80108a3d:	ff 75 0c             	push   0xc(%ebp)
80108a40:	ff 75 08             	push   0x8(%ebp)
80108a43:	e8 40 fe ff ff       	call   80108888 <pci_access_config>
80108a48:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108a4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a4e:	a3 84 77 19 80       	mov    %eax,0x80197784
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108a53:	83 ec 0c             	sub    $0xc,%esp
80108a56:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a59:	50                   	push   %eax
80108a5a:	6a 14                	push   $0x14
80108a5c:	ff 75 10             	push   0x10(%ebp)
80108a5f:	ff 75 0c             	push   0xc(%ebp)
80108a62:	ff 75 08             	push   0x8(%ebp)
80108a65:	e8 1e fe ff ff       	call   80108888 <pci_access_config>
80108a6a:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108a6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a70:	a3 88 77 19 80       	mov    %eax,0x80197788
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108a75:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108a7c:	75 5a                	jne    80108ad8 <pci_init_device+0x1a5>
80108a7e:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108a85:	75 51                	jne    80108ad8 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108a87:	83 ec 0c             	sub    $0xc,%esp
80108a8a:	68 a1 c5 10 80       	push   $0x8010c5a1
80108a8f:	e8 60 79 ff ff       	call   801003f4 <cprintf>
80108a94:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108a97:	83 ec 0c             	sub    $0xc,%esp
80108a9a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a9d:	50                   	push   %eax
80108a9e:	68 f0 00 00 00       	push   $0xf0
80108aa3:	ff 75 10             	push   0x10(%ebp)
80108aa6:	ff 75 0c             	push   0xc(%ebp)
80108aa9:	ff 75 08             	push   0x8(%ebp)
80108aac:	e8 d7 fd ff ff       	call   80108888 <pci_access_config>
80108ab1:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108ab4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ab7:	83 ec 08             	sub    $0x8,%esp
80108aba:	50                   	push   %eax
80108abb:	68 bb c5 10 80       	push   $0x8010c5bb
80108ac0:	e8 2f 79 ff ff       	call   801003f4 <cprintf>
80108ac5:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108ac8:	83 ec 0c             	sub    $0xc,%esp
80108acb:	68 74 77 19 80       	push   $0x80197774
80108ad0:	e8 09 00 00 00       	call   80108ade <i8254_init>
80108ad5:	83 c4 10             	add    $0x10,%esp
  }
}
80108ad8:	90                   	nop
80108ad9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108adc:	c9                   	leave  
80108add:	c3                   	ret    

80108ade <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108ade:	55                   	push   %ebp
80108adf:	89 e5                	mov    %esp,%ebp
80108ae1:	53                   	push   %ebx
80108ae2:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80108ae8:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108aec:	0f b6 c8             	movzbl %al,%ecx
80108aef:	8b 45 08             	mov    0x8(%ebp),%eax
80108af2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108af6:	0f b6 d0             	movzbl %al,%edx
80108af9:	8b 45 08             	mov    0x8(%ebp),%eax
80108afc:	0f b6 00             	movzbl (%eax),%eax
80108aff:	0f b6 c0             	movzbl %al,%eax
80108b02:	83 ec 0c             	sub    $0xc,%esp
80108b05:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108b08:	53                   	push   %ebx
80108b09:	6a 04                	push   $0x4
80108b0b:	51                   	push   %ecx
80108b0c:	52                   	push   %edx
80108b0d:	50                   	push   %eax
80108b0e:	e8 75 fd ff ff       	call   80108888 <pci_access_config>
80108b13:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108b16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b19:	83 c8 04             	or     $0x4,%eax
80108b1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108b1f:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108b22:	8b 45 08             	mov    0x8(%ebp),%eax
80108b25:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108b29:	0f b6 c8             	movzbl %al,%ecx
80108b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80108b2f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108b33:	0f b6 d0             	movzbl %al,%edx
80108b36:	8b 45 08             	mov    0x8(%ebp),%eax
80108b39:	0f b6 00             	movzbl (%eax),%eax
80108b3c:	0f b6 c0             	movzbl %al,%eax
80108b3f:	83 ec 0c             	sub    $0xc,%esp
80108b42:	53                   	push   %ebx
80108b43:	6a 04                	push   $0x4
80108b45:	51                   	push   %ecx
80108b46:	52                   	push   %edx
80108b47:	50                   	push   %eax
80108b48:	e8 90 fd ff ff       	call   801088dd <pci_write_config_register>
80108b4d:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108b50:	8b 45 08             	mov    0x8(%ebp),%eax
80108b53:	8b 40 10             	mov    0x10(%eax),%eax
80108b56:	05 00 00 00 40       	add    $0x40000000,%eax
80108b5b:	a3 8c 77 19 80       	mov    %eax,0x8019778c
  uint *ctrl = (uint *)base_addr;
80108b60:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b65:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108b68:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b6d:	05 d8 00 00 00       	add    $0xd8,%eax
80108b72:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b78:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b81:	8b 00                	mov    (%eax),%eax
80108b83:	0d 00 00 00 04       	or     $0x4000000,%eax
80108b88:	89 c2                	mov    %eax,%edx
80108b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b8d:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108b8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b92:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b9b:	8b 00                	mov    (%eax),%eax
80108b9d:	83 c8 40             	or     $0x40,%eax
80108ba0:	89 c2                	mov    %eax,%edx
80108ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba5:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108baa:	8b 10                	mov    (%eax),%edx
80108bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108baf:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108bb1:	83 ec 0c             	sub    $0xc,%esp
80108bb4:	68 d0 c5 10 80       	push   $0x8010c5d0
80108bb9:	e8 36 78 ff ff       	call   801003f4 <cprintf>
80108bbe:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108bc1:	e8 da 9b ff ff       	call   801027a0 <kalloc>
80108bc6:	a3 98 77 19 80       	mov    %eax,0x80197798
  *intr_addr = 0;
80108bcb:	a1 98 77 19 80       	mov    0x80197798,%eax
80108bd0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108bd6:	a1 98 77 19 80       	mov    0x80197798,%eax
80108bdb:	83 ec 08             	sub    $0x8,%esp
80108bde:	50                   	push   %eax
80108bdf:	68 f2 c5 10 80       	push   $0x8010c5f2
80108be4:	e8 0b 78 ff ff       	call   801003f4 <cprintf>
80108be9:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108bec:	e8 50 00 00 00       	call   80108c41 <i8254_init_recv>
  i8254_init_send();
80108bf1:	e8 69 03 00 00       	call   80108f5f <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108bf6:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108bfd:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108c00:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108c07:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108c0a:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108c11:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108c14:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108c1b:	0f b6 c0             	movzbl %al,%eax
80108c1e:	83 ec 0c             	sub    $0xc,%esp
80108c21:	53                   	push   %ebx
80108c22:	51                   	push   %ecx
80108c23:	52                   	push   %edx
80108c24:	50                   	push   %eax
80108c25:	68 00 c6 10 80       	push   $0x8010c600
80108c2a:	e8 c5 77 ff ff       	call   801003f4 <cprintf>
80108c2f:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c35:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108c3b:	90                   	nop
80108c3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c3f:	c9                   	leave  
80108c40:	c3                   	ret    

80108c41 <i8254_init_recv>:

void i8254_init_recv(){
80108c41:	55                   	push   %ebp
80108c42:	89 e5                	mov    %esp,%ebp
80108c44:	57                   	push   %edi
80108c45:	56                   	push   %esi
80108c46:	53                   	push   %ebx
80108c47:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108c4a:	83 ec 0c             	sub    $0xc,%esp
80108c4d:	6a 00                	push   $0x0
80108c4f:	e8 e8 04 00 00       	call   8010913c <i8254_read_eeprom>
80108c54:	83 c4 10             	add    $0x10,%esp
80108c57:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108c5a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108c5d:	a2 90 77 19 80       	mov    %al,0x80197790
  mac_addr[1] = data_l>>8;
80108c62:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108c65:	c1 e8 08             	shr    $0x8,%eax
80108c68:	a2 91 77 19 80       	mov    %al,0x80197791
  uint data_m = i8254_read_eeprom(0x1);
80108c6d:	83 ec 0c             	sub    $0xc,%esp
80108c70:	6a 01                	push   $0x1
80108c72:	e8 c5 04 00 00       	call   8010913c <i8254_read_eeprom>
80108c77:	83 c4 10             	add    $0x10,%esp
80108c7a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108c7d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c80:	a2 92 77 19 80       	mov    %al,0x80197792
  mac_addr[3] = data_m>>8;
80108c85:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c88:	c1 e8 08             	shr    $0x8,%eax
80108c8b:	a2 93 77 19 80       	mov    %al,0x80197793
  uint data_h = i8254_read_eeprom(0x2);
80108c90:	83 ec 0c             	sub    $0xc,%esp
80108c93:	6a 02                	push   $0x2
80108c95:	e8 a2 04 00 00       	call   8010913c <i8254_read_eeprom>
80108c9a:	83 c4 10             	add    $0x10,%esp
80108c9d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108ca0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ca3:	a2 94 77 19 80       	mov    %al,0x80197794
  mac_addr[5] = data_h>>8;
80108ca8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cab:	c1 e8 08             	shr    $0x8,%eax
80108cae:	a2 95 77 19 80       	mov    %al,0x80197795
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108cb3:	0f b6 05 95 77 19 80 	movzbl 0x80197795,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cba:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108cbd:	0f b6 05 94 77 19 80 	movzbl 0x80197794,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cc4:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108cc7:	0f b6 05 93 77 19 80 	movzbl 0x80197793,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cce:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108cd1:	0f b6 05 92 77 19 80 	movzbl 0x80197792,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cd8:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108cdb:	0f b6 05 91 77 19 80 	movzbl 0x80197791,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ce2:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108ce5:	0f b6 05 90 77 19 80 	movzbl 0x80197790,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cec:	0f b6 c0             	movzbl %al,%eax
80108cef:	83 ec 04             	sub    $0x4,%esp
80108cf2:	57                   	push   %edi
80108cf3:	56                   	push   %esi
80108cf4:	53                   	push   %ebx
80108cf5:	51                   	push   %ecx
80108cf6:	52                   	push   %edx
80108cf7:	50                   	push   %eax
80108cf8:	68 18 c6 10 80       	push   $0x8010c618
80108cfd:	e8 f2 76 ff ff       	call   801003f4 <cprintf>
80108d02:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108d05:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d0a:	05 00 54 00 00       	add    $0x5400,%eax
80108d0f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108d12:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d17:	05 04 54 00 00       	add    $0x5404,%eax
80108d1c:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108d1f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d22:	c1 e0 10             	shl    $0x10,%eax
80108d25:	0b 45 d8             	or     -0x28(%ebp),%eax
80108d28:	89 c2                	mov    %eax,%edx
80108d2a:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108d2d:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108d2f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d32:	0d 00 00 00 80       	or     $0x80000000,%eax
80108d37:	89 c2                	mov    %eax,%edx
80108d39:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108d3c:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108d3e:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d43:	05 00 52 00 00       	add    $0x5200,%eax
80108d48:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108d4b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108d52:	eb 19                	jmp    80108d6d <i8254_init_recv+0x12c>
    mta[i] = 0;
80108d54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d57:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d5e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108d61:	01 d0                	add    %edx,%eax
80108d63:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108d69:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108d6d:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108d71:	7e e1                	jle    80108d54 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108d73:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d78:	05 d0 00 00 00       	add    $0xd0,%eax
80108d7d:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108d80:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108d83:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108d89:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d8e:	05 c8 00 00 00       	add    $0xc8,%eax
80108d93:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108d96:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108d99:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108d9f:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108da4:	05 28 28 00 00       	add    $0x2828,%eax
80108da9:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108dac:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108daf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108db5:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108dba:	05 00 01 00 00       	add    $0x100,%eax
80108dbf:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108dc2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108dc5:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108dcb:	e8 d0 99 ff ff       	call   801027a0 <kalloc>
80108dd0:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108dd3:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108dd8:	05 00 28 00 00       	add    $0x2800,%eax
80108ddd:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108de0:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108de5:	05 04 28 00 00       	add    $0x2804,%eax
80108dea:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108ded:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108df2:	05 08 28 00 00       	add    $0x2808,%eax
80108df7:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108dfa:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108dff:	05 10 28 00 00       	add    $0x2810,%eax
80108e04:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108e07:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108e0c:	05 18 28 00 00       	add    $0x2818,%eax
80108e11:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108e14:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108e17:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108e1d:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108e20:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108e22:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108e25:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108e2b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108e2e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108e34:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108e37:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108e3d:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108e40:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108e46:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108e49:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108e4c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108e53:	eb 73                	jmp    80108ec8 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108e55:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e58:	c1 e0 04             	shl    $0x4,%eax
80108e5b:	89 c2                	mov    %eax,%edx
80108e5d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e60:	01 d0                	add    %edx,%eax
80108e62:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108e69:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e6c:	c1 e0 04             	shl    $0x4,%eax
80108e6f:	89 c2                	mov    %eax,%edx
80108e71:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e74:	01 d0                	add    %edx,%eax
80108e76:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108e7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e7f:	c1 e0 04             	shl    $0x4,%eax
80108e82:	89 c2                	mov    %eax,%edx
80108e84:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e87:	01 d0                	add    %edx,%eax
80108e89:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108e8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e92:	c1 e0 04             	shl    $0x4,%eax
80108e95:	89 c2                	mov    %eax,%edx
80108e97:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e9a:	01 d0                	add    %edx,%eax
80108e9c:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108ea0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ea3:	c1 e0 04             	shl    $0x4,%eax
80108ea6:	89 c2                	mov    %eax,%edx
80108ea8:	8b 45 98             	mov    -0x68(%ebp),%eax
80108eab:	01 d0                	add    %edx,%eax
80108ead:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108eb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108eb4:	c1 e0 04             	shl    $0x4,%eax
80108eb7:	89 c2                	mov    %eax,%edx
80108eb9:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ebc:	01 d0                	add    %edx,%eax
80108ebe:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108ec4:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108ec8:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108ecf:	7e 84                	jle    80108e55 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108ed1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108ed8:	eb 57                	jmp    80108f31 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108eda:	e8 c1 98 ff ff       	call   801027a0 <kalloc>
80108edf:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108ee2:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108ee6:	75 12                	jne    80108efa <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108ee8:	83 ec 0c             	sub    $0xc,%esp
80108eeb:	68 38 c6 10 80       	push   $0x8010c638
80108ef0:	e8 ff 74 ff ff       	call   801003f4 <cprintf>
80108ef5:	83 c4 10             	add    $0x10,%esp
      break;
80108ef8:	eb 3d                	jmp    80108f37 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108efa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108efd:	c1 e0 04             	shl    $0x4,%eax
80108f00:	89 c2                	mov    %eax,%edx
80108f02:	8b 45 98             	mov    -0x68(%ebp),%eax
80108f05:	01 d0                	add    %edx,%eax
80108f07:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108f0a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108f10:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108f12:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f15:	83 c0 01             	add    $0x1,%eax
80108f18:	c1 e0 04             	shl    $0x4,%eax
80108f1b:	89 c2                	mov    %eax,%edx
80108f1d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108f20:	01 d0                	add    %edx,%eax
80108f22:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108f25:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108f2b:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108f2d:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108f31:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108f35:	7e a3                	jle    80108eda <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108f37:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108f3a:	8b 00                	mov    (%eax),%eax
80108f3c:	83 c8 02             	or     $0x2,%eax
80108f3f:	89 c2                	mov    %eax,%edx
80108f41:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108f44:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108f46:	83 ec 0c             	sub    $0xc,%esp
80108f49:	68 58 c6 10 80       	push   $0x8010c658
80108f4e:	e8 a1 74 ff ff       	call   801003f4 <cprintf>
80108f53:	83 c4 10             	add    $0x10,%esp
}
80108f56:	90                   	nop
80108f57:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108f5a:	5b                   	pop    %ebx
80108f5b:	5e                   	pop    %esi
80108f5c:	5f                   	pop    %edi
80108f5d:	5d                   	pop    %ebp
80108f5e:	c3                   	ret    

80108f5f <i8254_init_send>:

void i8254_init_send(){
80108f5f:	55                   	push   %ebp
80108f60:	89 e5                	mov    %esp,%ebp
80108f62:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108f65:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108f6a:	05 28 38 00 00       	add    $0x3828,%eax
80108f6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108f72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f75:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108f7b:	e8 20 98 ff ff       	call   801027a0 <kalloc>
80108f80:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108f83:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108f88:	05 00 38 00 00       	add    $0x3800,%eax
80108f8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108f90:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108f95:	05 04 38 00 00       	add    $0x3804,%eax
80108f9a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108f9d:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108fa2:	05 08 38 00 00       	add    $0x3808,%eax
80108fa7:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108faa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fad:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108fb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108fb6:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108fb8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fbb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108fc1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108fc4:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108fca:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108fcf:	05 10 38 00 00       	add    $0x3810,%eax
80108fd4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108fd7:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108fdc:	05 18 38 00 00       	add    $0x3818,%eax
80108fe1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108fe4:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108fe7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108fed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ff0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108ff6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ff9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108ffc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109003:	e9 82 00 00 00       	jmp    8010908a <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80109008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010900b:	c1 e0 04             	shl    $0x4,%eax
8010900e:	89 c2                	mov    %eax,%edx
80109010:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109013:	01 d0                	add    %edx,%eax
80109015:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
8010901c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010901f:	c1 e0 04             	shl    $0x4,%eax
80109022:	89 c2                	mov    %eax,%edx
80109024:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109027:	01 d0                	add    %edx,%eax
80109029:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
8010902f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109032:	c1 e0 04             	shl    $0x4,%eax
80109035:	89 c2                	mov    %eax,%edx
80109037:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010903a:	01 d0                	add    %edx,%eax
8010903c:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80109040:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109043:	c1 e0 04             	shl    $0x4,%eax
80109046:	89 c2                	mov    %eax,%edx
80109048:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010904b:	01 d0                	add    %edx,%eax
8010904d:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80109051:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109054:	c1 e0 04             	shl    $0x4,%eax
80109057:	89 c2                	mov    %eax,%edx
80109059:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010905c:	01 d0                	add    %edx,%eax
8010905e:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80109062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109065:	c1 e0 04             	shl    $0x4,%eax
80109068:	89 c2                	mov    %eax,%edx
8010906a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010906d:	01 d0                	add    %edx,%eax
8010906f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80109073:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109076:	c1 e0 04             	shl    $0x4,%eax
80109079:	89 c2                	mov    %eax,%edx
8010907b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010907e:	01 d0                	add    %edx,%eax
80109080:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109086:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010908a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109091:	0f 8e 71 ff ff ff    	jle    80109008 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109097:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010909e:	eb 57                	jmp    801090f7 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
801090a0:	e8 fb 96 ff ff       	call   801027a0 <kalloc>
801090a5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
801090a8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
801090ac:	75 12                	jne    801090c0 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
801090ae:	83 ec 0c             	sub    $0xc,%esp
801090b1:	68 38 c6 10 80       	push   $0x8010c638
801090b6:	e8 39 73 ff ff       	call   801003f4 <cprintf>
801090bb:	83 c4 10             	add    $0x10,%esp
      break;
801090be:	eb 3d                	jmp    801090fd <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
801090c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090c3:	c1 e0 04             	shl    $0x4,%eax
801090c6:	89 c2                	mov    %eax,%edx
801090c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090cb:	01 d0                	add    %edx,%eax
801090cd:	8b 55 cc             	mov    -0x34(%ebp),%edx
801090d0:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801090d6:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801090d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090db:	83 c0 01             	add    $0x1,%eax
801090de:	c1 e0 04             	shl    $0x4,%eax
801090e1:	89 c2                	mov    %eax,%edx
801090e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090e6:	01 d0                	add    %edx,%eax
801090e8:	8b 55 cc             	mov    -0x34(%ebp),%edx
801090eb:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801090f1:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801090f3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801090f7:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801090fb:	7e a3                	jle    801090a0 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
801090fd:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80109102:	05 00 04 00 00       	add    $0x400,%eax
80109107:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
8010910a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010910d:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80109113:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80109118:	05 10 04 00 00       	add    $0x410,%eax
8010911d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80109120:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109123:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109129:	83 ec 0c             	sub    $0xc,%esp
8010912c:	68 78 c6 10 80       	push   $0x8010c678
80109131:	e8 be 72 ff ff       	call   801003f4 <cprintf>
80109136:	83 c4 10             	add    $0x10,%esp

}
80109139:	90                   	nop
8010913a:	c9                   	leave  
8010913b:	c3                   	ret    

8010913c <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
8010913c:	55                   	push   %ebp
8010913d:	89 e5                	mov    %esp,%ebp
8010913f:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80109142:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80109147:	83 c0 14             	add    $0x14,%eax
8010914a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
8010914d:	8b 45 08             	mov    0x8(%ebp),%eax
80109150:	c1 e0 08             	shl    $0x8,%eax
80109153:	0f b7 c0             	movzwl %ax,%eax
80109156:	83 c8 01             	or     $0x1,%eax
80109159:	89 c2                	mov    %eax,%edx
8010915b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010915e:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80109160:	83 ec 0c             	sub    $0xc,%esp
80109163:	68 98 c6 10 80       	push   $0x8010c698
80109168:	e8 87 72 ff ff       	call   801003f4 <cprintf>
8010916d:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80109170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109173:	8b 00                	mov    (%eax),%eax
80109175:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109178:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010917b:	83 e0 10             	and    $0x10,%eax
8010917e:	85 c0                	test   %eax,%eax
80109180:	75 02                	jne    80109184 <i8254_read_eeprom+0x48>
  while(1){
80109182:	eb dc                	jmp    80109160 <i8254_read_eeprom+0x24>
      break;
80109184:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80109185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109188:	8b 00                	mov    (%eax),%eax
8010918a:	c1 e8 10             	shr    $0x10,%eax
}
8010918d:	c9                   	leave  
8010918e:	c3                   	ret    

8010918f <i8254_recv>:
void i8254_recv(){
8010918f:	55                   	push   %ebp
80109190:	89 e5                	mov    %esp,%ebp
80109192:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80109195:	a1 8c 77 19 80       	mov    0x8019778c,%eax
8010919a:	05 10 28 00 00       	add    $0x2810,%eax
8010919f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801091a2:	a1 8c 77 19 80       	mov    0x8019778c,%eax
801091a7:	05 18 28 00 00       	add    $0x2818,%eax
801091ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
801091af:	a1 8c 77 19 80       	mov    0x8019778c,%eax
801091b4:	05 00 28 00 00       	add    $0x2800,%eax
801091b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
801091bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091bf:	8b 00                	mov    (%eax),%eax
801091c1:	05 00 00 00 80       	add    $0x80000000,%eax
801091c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
801091c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091cc:	8b 10                	mov    (%eax),%edx
801091ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091d1:	8b 08                	mov    (%eax),%ecx
801091d3:	89 d0                	mov    %edx,%eax
801091d5:	29 c8                	sub    %ecx,%eax
801091d7:	25 ff 00 00 00       	and    $0xff,%eax
801091dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
801091df:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801091e3:	7e 37                	jle    8010921c <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
801091e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091e8:	8b 00                	mov    (%eax),%eax
801091ea:	c1 e0 04             	shl    $0x4,%eax
801091ed:	89 c2                	mov    %eax,%edx
801091ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091f2:	01 d0                	add    %edx,%eax
801091f4:	8b 00                	mov    (%eax),%eax
801091f6:	05 00 00 00 80       	add    $0x80000000,%eax
801091fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
801091fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109201:	8b 00                	mov    (%eax),%eax
80109203:	83 c0 01             	add    $0x1,%eax
80109206:	0f b6 d0             	movzbl %al,%edx
80109209:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010920c:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
8010920e:	83 ec 0c             	sub    $0xc,%esp
80109211:	ff 75 e0             	push   -0x20(%ebp)
80109214:	e8 15 09 00 00       	call   80109b2e <eth_proc>
80109219:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
8010921c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010921f:	8b 10                	mov    (%eax),%edx
80109221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109224:	8b 00                	mov    (%eax),%eax
80109226:	39 c2                	cmp    %eax,%edx
80109228:	75 9f                	jne    801091c9 <i8254_recv+0x3a>
      (*rdt)--;
8010922a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010922d:	8b 00                	mov    (%eax),%eax
8010922f:	8d 50 ff             	lea    -0x1(%eax),%edx
80109232:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109235:	89 10                	mov    %edx,(%eax)
  while(1){
80109237:	eb 90                	jmp    801091c9 <i8254_recv+0x3a>

80109239 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80109239:	55                   	push   %ebp
8010923a:	89 e5                	mov    %esp,%ebp
8010923c:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
8010923f:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80109244:	05 10 38 00 00       	add    $0x3810,%eax
80109249:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010924c:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80109251:	05 18 38 00 00       	add    $0x3818,%eax
80109256:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109259:	a1 8c 77 19 80       	mov    0x8019778c,%eax
8010925e:	05 00 38 00 00       	add    $0x3800,%eax
80109263:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109266:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109269:	8b 00                	mov    (%eax),%eax
8010926b:	05 00 00 00 80       	add    $0x80000000,%eax
80109270:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109273:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109276:	8b 10                	mov    (%eax),%edx
80109278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010927b:	8b 08                	mov    (%eax),%ecx
8010927d:	89 d0                	mov    %edx,%eax
8010927f:	29 c8                	sub    %ecx,%eax
80109281:	0f b6 d0             	movzbl %al,%edx
80109284:	b8 00 01 00 00       	mov    $0x100,%eax
80109289:	29 d0                	sub    %edx,%eax
8010928b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
8010928e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109291:	8b 00                	mov    (%eax),%eax
80109293:	25 ff 00 00 00       	and    $0xff,%eax
80109298:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
8010929b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010929f:	0f 8e a8 00 00 00    	jle    8010934d <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
801092a5:	8b 45 08             	mov    0x8(%ebp),%eax
801092a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
801092ab:	89 d1                	mov    %edx,%ecx
801092ad:	c1 e1 04             	shl    $0x4,%ecx
801092b0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801092b3:	01 ca                	add    %ecx,%edx
801092b5:	8b 12                	mov    (%edx),%edx
801092b7:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801092bd:	83 ec 04             	sub    $0x4,%esp
801092c0:	ff 75 0c             	push   0xc(%ebp)
801092c3:	50                   	push   %eax
801092c4:	52                   	push   %edx
801092c5:	e8 90 bb ff ff       	call   80104e5a <memmove>
801092ca:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801092cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092d0:	c1 e0 04             	shl    $0x4,%eax
801092d3:	89 c2                	mov    %eax,%edx
801092d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092d8:	01 d0                	add    %edx,%eax
801092da:	8b 55 0c             	mov    0xc(%ebp),%edx
801092dd:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
801092e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092e4:	c1 e0 04             	shl    $0x4,%eax
801092e7:	89 c2                	mov    %eax,%edx
801092e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092ec:	01 d0                	add    %edx,%eax
801092ee:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
801092f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092f5:	c1 e0 04             	shl    $0x4,%eax
801092f8:	89 c2                	mov    %eax,%edx
801092fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092fd:	01 d0                	add    %edx,%eax
801092ff:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109303:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109306:	c1 e0 04             	shl    $0x4,%eax
80109309:	89 c2                	mov    %eax,%edx
8010930b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010930e:	01 d0                	add    %edx,%eax
80109310:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109314:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109317:	c1 e0 04             	shl    $0x4,%eax
8010931a:	89 c2                	mov    %eax,%edx
8010931c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010931f:	01 d0                	add    %edx,%eax
80109321:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109327:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010932a:	c1 e0 04             	shl    $0x4,%eax
8010932d:	89 c2                	mov    %eax,%edx
8010932f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109332:	01 d0                	add    %edx,%eax
80109334:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109338:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010933b:	8b 00                	mov    (%eax),%eax
8010933d:	83 c0 01             	add    $0x1,%eax
80109340:	0f b6 d0             	movzbl %al,%edx
80109343:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109346:	89 10                	mov    %edx,(%eax)
    return len;
80109348:	8b 45 0c             	mov    0xc(%ebp),%eax
8010934b:	eb 05                	jmp    80109352 <i8254_send+0x119>
  }else{
    return -1;
8010934d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109352:	c9                   	leave  
80109353:	c3                   	ret    

80109354 <i8254_intr>:

void i8254_intr(){
80109354:	55                   	push   %ebp
80109355:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109357:	a1 98 77 19 80       	mov    0x80197798,%eax
8010935c:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109362:	90                   	nop
80109363:	5d                   	pop    %ebp
80109364:	c3                   	ret    

80109365 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109365:	55                   	push   %ebp
80109366:	89 e5                	mov    %esp,%ebp
80109368:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
8010936b:	8b 45 08             	mov    0x8(%ebp),%eax
8010936e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109374:	0f b7 00             	movzwl (%eax),%eax
80109377:	66 3d 00 01          	cmp    $0x100,%ax
8010937b:	74 0a                	je     80109387 <arp_proc+0x22>
8010937d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109382:	e9 4f 01 00 00       	jmp    801094d6 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109387:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010938a:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010938e:	66 83 f8 08          	cmp    $0x8,%ax
80109392:	74 0a                	je     8010939e <arp_proc+0x39>
80109394:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109399:	e9 38 01 00 00       	jmp    801094d6 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
8010939e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093a1:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801093a5:	3c 06                	cmp    $0x6,%al
801093a7:	74 0a                	je     801093b3 <arp_proc+0x4e>
801093a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801093ae:	e9 23 01 00 00       	jmp    801094d6 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
801093b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093b6:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801093ba:	3c 04                	cmp    $0x4,%al
801093bc:	74 0a                	je     801093c8 <arp_proc+0x63>
801093be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801093c3:	e9 0e 01 00 00       	jmp    801094d6 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801093c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093cb:	83 c0 18             	add    $0x18,%eax
801093ce:	83 ec 04             	sub    $0x4,%esp
801093d1:	6a 04                	push   $0x4
801093d3:	50                   	push   %eax
801093d4:	68 04 f5 10 80       	push   $0x8010f504
801093d9:	e8 24 ba ff ff       	call   80104e02 <memcmp>
801093de:	83 c4 10             	add    $0x10,%esp
801093e1:	85 c0                	test   %eax,%eax
801093e3:	74 27                	je     8010940c <arp_proc+0xa7>
801093e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093e8:	83 c0 0e             	add    $0xe,%eax
801093eb:	83 ec 04             	sub    $0x4,%esp
801093ee:	6a 04                	push   $0x4
801093f0:	50                   	push   %eax
801093f1:	68 04 f5 10 80       	push   $0x8010f504
801093f6:	e8 07 ba ff ff       	call   80104e02 <memcmp>
801093fb:	83 c4 10             	add    $0x10,%esp
801093fe:	85 c0                	test   %eax,%eax
80109400:	74 0a                	je     8010940c <arp_proc+0xa7>
80109402:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109407:	e9 ca 00 00 00       	jmp    801094d6 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010940c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010940f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109413:	66 3d 00 01          	cmp    $0x100,%ax
80109417:	75 69                	jne    80109482 <arp_proc+0x11d>
80109419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010941c:	83 c0 18             	add    $0x18,%eax
8010941f:	83 ec 04             	sub    $0x4,%esp
80109422:	6a 04                	push   $0x4
80109424:	50                   	push   %eax
80109425:	68 04 f5 10 80       	push   $0x8010f504
8010942a:	e8 d3 b9 ff ff       	call   80104e02 <memcmp>
8010942f:	83 c4 10             	add    $0x10,%esp
80109432:	85 c0                	test   %eax,%eax
80109434:	75 4c                	jne    80109482 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109436:	e8 65 93 ff ff       	call   801027a0 <kalloc>
8010943b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
8010943e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109445:	83 ec 04             	sub    $0x4,%esp
80109448:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010944b:	50                   	push   %eax
8010944c:	ff 75 f0             	push   -0x10(%ebp)
8010944f:	ff 75 f4             	push   -0xc(%ebp)
80109452:	e8 1f 04 00 00       	call   80109876 <arp_reply_pkt_create>
80109457:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
8010945a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010945d:	83 ec 08             	sub    $0x8,%esp
80109460:	50                   	push   %eax
80109461:	ff 75 f0             	push   -0x10(%ebp)
80109464:	e8 d0 fd ff ff       	call   80109239 <i8254_send>
80109469:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
8010946c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010946f:	83 ec 0c             	sub    $0xc,%esp
80109472:	50                   	push   %eax
80109473:	e8 8e 92 ff ff       	call   80102706 <kfree>
80109478:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010947b:	b8 02 00 00 00       	mov    $0x2,%eax
80109480:	eb 54                	jmp    801094d6 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109482:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109485:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109489:	66 3d 00 02          	cmp    $0x200,%ax
8010948d:	75 42                	jne    801094d1 <arp_proc+0x16c>
8010948f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109492:	83 c0 18             	add    $0x18,%eax
80109495:	83 ec 04             	sub    $0x4,%esp
80109498:	6a 04                	push   $0x4
8010949a:	50                   	push   %eax
8010949b:	68 04 f5 10 80       	push   $0x8010f504
801094a0:	e8 5d b9 ff ff       	call   80104e02 <memcmp>
801094a5:	83 c4 10             	add    $0x10,%esp
801094a8:	85 c0                	test   %eax,%eax
801094aa:	75 25                	jne    801094d1 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
801094ac:	83 ec 0c             	sub    $0xc,%esp
801094af:	68 9c c6 10 80       	push   $0x8010c69c
801094b4:	e8 3b 6f ff ff       	call   801003f4 <cprintf>
801094b9:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801094bc:	83 ec 0c             	sub    $0xc,%esp
801094bf:	ff 75 f4             	push   -0xc(%ebp)
801094c2:	e8 af 01 00 00       	call   80109676 <arp_table_update>
801094c7:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801094ca:	b8 01 00 00 00       	mov    $0x1,%eax
801094cf:	eb 05                	jmp    801094d6 <arp_proc+0x171>
  }else{
    return -1;
801094d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801094d6:	c9                   	leave  
801094d7:	c3                   	ret    

801094d8 <arp_scan>:

void arp_scan(){
801094d8:	55                   	push   %ebp
801094d9:	89 e5                	mov    %esp,%ebp
801094db:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801094de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801094e5:	eb 6f                	jmp    80109556 <arp_scan+0x7e>
    uint send = (uint)kalloc();
801094e7:	e8 b4 92 ff ff       	call   801027a0 <kalloc>
801094ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801094ef:	83 ec 04             	sub    $0x4,%esp
801094f2:	ff 75 f4             	push   -0xc(%ebp)
801094f5:	8d 45 e8             	lea    -0x18(%ebp),%eax
801094f8:	50                   	push   %eax
801094f9:	ff 75 ec             	push   -0x14(%ebp)
801094fc:	e8 62 00 00 00       	call   80109563 <arp_broadcast>
80109501:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109504:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109507:	83 ec 08             	sub    $0x8,%esp
8010950a:	50                   	push   %eax
8010950b:	ff 75 ec             	push   -0x14(%ebp)
8010950e:	e8 26 fd ff ff       	call   80109239 <i8254_send>
80109513:	83 c4 10             	add    $0x10,%esp
80109516:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109519:	eb 22                	jmp    8010953d <arp_scan+0x65>
      microdelay(1);
8010951b:	83 ec 0c             	sub    $0xc,%esp
8010951e:	6a 01                	push   $0x1
80109520:	e8 12 96 ff ff       	call   80102b37 <microdelay>
80109525:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109528:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010952b:	83 ec 08             	sub    $0x8,%esp
8010952e:	50                   	push   %eax
8010952f:	ff 75 ec             	push   -0x14(%ebp)
80109532:	e8 02 fd ff ff       	call   80109239 <i8254_send>
80109537:	83 c4 10             	add    $0x10,%esp
8010953a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010953d:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109541:	74 d8                	je     8010951b <arp_scan+0x43>
    }
    kfree((char *)send);
80109543:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109546:	83 ec 0c             	sub    $0xc,%esp
80109549:	50                   	push   %eax
8010954a:	e8 b7 91 ff ff       	call   80102706 <kfree>
8010954f:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109552:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109556:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010955d:	7e 88                	jle    801094e7 <arp_scan+0xf>
  }
}
8010955f:	90                   	nop
80109560:	90                   	nop
80109561:	c9                   	leave  
80109562:	c3                   	ret    

80109563 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109563:	55                   	push   %ebp
80109564:	89 e5                	mov    %esp,%ebp
80109566:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109569:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
8010956d:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109571:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109575:	8b 45 10             	mov    0x10(%ebp),%eax
80109578:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
8010957b:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109582:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109588:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010958f:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109595:	8b 45 0c             	mov    0xc(%ebp),%eax
80109598:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010959e:	8b 45 08             	mov    0x8(%ebp),%eax
801095a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801095a4:	8b 45 08             	mov    0x8(%ebp),%eax
801095a7:	83 c0 0e             	add    $0xe,%eax
801095aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801095ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095b0:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801095b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095b7:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801095bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095be:	83 ec 04             	sub    $0x4,%esp
801095c1:	6a 06                	push   $0x6
801095c3:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801095c6:	52                   	push   %edx
801095c7:	50                   	push   %eax
801095c8:	e8 8d b8 ff ff       	call   80104e5a <memmove>
801095cd:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801095d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d3:	83 c0 06             	add    $0x6,%eax
801095d6:	83 ec 04             	sub    $0x4,%esp
801095d9:	6a 06                	push   $0x6
801095db:	68 90 77 19 80       	push   $0x80197790
801095e0:	50                   	push   %eax
801095e1:	e8 74 b8 ff ff       	call   80104e5a <memmove>
801095e6:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801095e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095ec:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801095f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095f4:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801095fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095fd:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109601:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109604:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109608:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010960b:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109611:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109614:	8d 50 12             	lea    0x12(%eax),%edx
80109617:	83 ec 04             	sub    $0x4,%esp
8010961a:	6a 06                	push   $0x6
8010961c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010961f:	50                   	push   %eax
80109620:	52                   	push   %edx
80109621:	e8 34 b8 ff ff       	call   80104e5a <memmove>
80109626:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109629:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010962c:	8d 50 18             	lea    0x18(%eax),%edx
8010962f:	83 ec 04             	sub    $0x4,%esp
80109632:	6a 04                	push   $0x4
80109634:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109637:	50                   	push   %eax
80109638:	52                   	push   %edx
80109639:	e8 1c b8 ff ff       	call   80104e5a <memmove>
8010963e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109641:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109644:	83 c0 08             	add    $0x8,%eax
80109647:	83 ec 04             	sub    $0x4,%esp
8010964a:	6a 06                	push   $0x6
8010964c:	68 90 77 19 80       	push   $0x80197790
80109651:	50                   	push   %eax
80109652:	e8 03 b8 ff ff       	call   80104e5a <memmove>
80109657:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010965a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010965d:	83 c0 0e             	add    $0xe,%eax
80109660:	83 ec 04             	sub    $0x4,%esp
80109663:	6a 04                	push   $0x4
80109665:	68 04 f5 10 80       	push   $0x8010f504
8010966a:	50                   	push   %eax
8010966b:	e8 ea b7 ff ff       	call   80104e5a <memmove>
80109670:	83 c4 10             	add    $0x10,%esp
}
80109673:	90                   	nop
80109674:	c9                   	leave  
80109675:	c3                   	ret    

80109676 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109676:	55                   	push   %ebp
80109677:	89 e5                	mov    %esp,%ebp
80109679:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
8010967c:	8b 45 08             	mov    0x8(%ebp),%eax
8010967f:	83 c0 0e             	add    $0xe,%eax
80109682:	83 ec 0c             	sub    $0xc,%esp
80109685:	50                   	push   %eax
80109686:	e8 bc 00 00 00       	call   80109747 <arp_table_search>
8010968b:	83 c4 10             	add    $0x10,%esp
8010968e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109691:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109695:	78 2d                	js     801096c4 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109697:	8b 45 08             	mov    0x8(%ebp),%eax
8010969a:	8d 48 08             	lea    0x8(%eax),%ecx
8010969d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801096a0:	89 d0                	mov    %edx,%eax
801096a2:	c1 e0 02             	shl    $0x2,%eax
801096a5:	01 d0                	add    %edx,%eax
801096a7:	01 c0                	add    %eax,%eax
801096a9:	01 d0                	add    %edx,%eax
801096ab:	05 a0 77 19 80       	add    $0x801977a0,%eax
801096b0:	83 c0 04             	add    $0x4,%eax
801096b3:	83 ec 04             	sub    $0x4,%esp
801096b6:	6a 06                	push   $0x6
801096b8:	51                   	push   %ecx
801096b9:	50                   	push   %eax
801096ba:	e8 9b b7 ff ff       	call   80104e5a <memmove>
801096bf:	83 c4 10             	add    $0x10,%esp
801096c2:	eb 70                	jmp    80109734 <arp_table_update+0xbe>
  }else{
    index += 1;
801096c4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801096c8:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801096cb:	8b 45 08             	mov    0x8(%ebp),%eax
801096ce:	8d 48 08             	lea    0x8(%eax),%ecx
801096d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801096d4:	89 d0                	mov    %edx,%eax
801096d6:	c1 e0 02             	shl    $0x2,%eax
801096d9:	01 d0                	add    %edx,%eax
801096db:	01 c0                	add    %eax,%eax
801096dd:	01 d0                	add    %edx,%eax
801096df:	05 a0 77 19 80       	add    $0x801977a0,%eax
801096e4:	83 c0 04             	add    $0x4,%eax
801096e7:	83 ec 04             	sub    $0x4,%esp
801096ea:	6a 06                	push   $0x6
801096ec:	51                   	push   %ecx
801096ed:	50                   	push   %eax
801096ee:	e8 67 b7 ff ff       	call   80104e5a <memmove>
801096f3:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801096f6:	8b 45 08             	mov    0x8(%ebp),%eax
801096f9:	8d 48 0e             	lea    0xe(%eax),%ecx
801096fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801096ff:	89 d0                	mov    %edx,%eax
80109701:	c1 e0 02             	shl    $0x2,%eax
80109704:	01 d0                	add    %edx,%eax
80109706:	01 c0                	add    %eax,%eax
80109708:	01 d0                	add    %edx,%eax
8010970a:	05 a0 77 19 80       	add    $0x801977a0,%eax
8010970f:	83 ec 04             	sub    $0x4,%esp
80109712:	6a 04                	push   $0x4
80109714:	51                   	push   %ecx
80109715:	50                   	push   %eax
80109716:	e8 3f b7 ff ff       	call   80104e5a <memmove>
8010971b:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010971e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109721:	89 d0                	mov    %edx,%eax
80109723:	c1 e0 02             	shl    $0x2,%eax
80109726:	01 d0                	add    %edx,%eax
80109728:	01 c0                	add    %eax,%eax
8010972a:	01 d0                	add    %edx,%eax
8010972c:	05 aa 77 19 80       	add    $0x801977aa,%eax
80109731:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109734:	83 ec 0c             	sub    $0xc,%esp
80109737:	68 a0 77 19 80       	push   $0x801977a0
8010973c:	e8 83 00 00 00       	call   801097c4 <print_arp_table>
80109741:	83 c4 10             	add    $0x10,%esp
}
80109744:	90                   	nop
80109745:	c9                   	leave  
80109746:	c3                   	ret    

80109747 <arp_table_search>:

int arp_table_search(uchar *ip){
80109747:	55                   	push   %ebp
80109748:	89 e5                	mov    %esp,%ebp
8010974a:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
8010974d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109754:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010975b:	eb 59                	jmp    801097b6 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
8010975d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109760:	89 d0                	mov    %edx,%eax
80109762:	c1 e0 02             	shl    $0x2,%eax
80109765:	01 d0                	add    %edx,%eax
80109767:	01 c0                	add    %eax,%eax
80109769:	01 d0                	add    %edx,%eax
8010976b:	05 a0 77 19 80       	add    $0x801977a0,%eax
80109770:	83 ec 04             	sub    $0x4,%esp
80109773:	6a 04                	push   $0x4
80109775:	ff 75 08             	push   0x8(%ebp)
80109778:	50                   	push   %eax
80109779:	e8 84 b6 ff ff       	call   80104e02 <memcmp>
8010977e:	83 c4 10             	add    $0x10,%esp
80109781:	85 c0                	test   %eax,%eax
80109783:	75 05                	jne    8010978a <arp_table_search+0x43>
      return i;
80109785:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109788:	eb 38                	jmp    801097c2 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010978a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010978d:	89 d0                	mov    %edx,%eax
8010978f:	c1 e0 02             	shl    $0x2,%eax
80109792:	01 d0                	add    %edx,%eax
80109794:	01 c0                	add    %eax,%eax
80109796:	01 d0                	add    %edx,%eax
80109798:	05 aa 77 19 80       	add    $0x801977aa,%eax
8010979d:	0f b6 00             	movzbl (%eax),%eax
801097a0:	84 c0                	test   %al,%al
801097a2:	75 0e                	jne    801097b2 <arp_table_search+0x6b>
801097a4:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801097a8:	75 08                	jne    801097b2 <arp_table_search+0x6b>
      empty = -i;
801097aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097ad:	f7 d8                	neg    %eax
801097af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801097b2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801097b6:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801097ba:	7e a1                	jle    8010975d <arp_table_search+0x16>
    }
  }
  return empty-1;
801097bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097bf:	83 e8 01             	sub    $0x1,%eax
}
801097c2:	c9                   	leave  
801097c3:	c3                   	ret    

801097c4 <print_arp_table>:

void print_arp_table(){
801097c4:	55                   	push   %ebp
801097c5:	89 e5                	mov    %esp,%ebp
801097c7:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801097ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801097d1:	e9 92 00 00 00       	jmp    80109868 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
801097d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097d9:	89 d0                	mov    %edx,%eax
801097db:	c1 e0 02             	shl    $0x2,%eax
801097de:	01 d0                	add    %edx,%eax
801097e0:	01 c0                	add    %eax,%eax
801097e2:	01 d0                	add    %edx,%eax
801097e4:	05 aa 77 19 80       	add    $0x801977aa,%eax
801097e9:	0f b6 00             	movzbl (%eax),%eax
801097ec:	84 c0                	test   %al,%al
801097ee:	74 74                	je     80109864 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
801097f0:	83 ec 08             	sub    $0x8,%esp
801097f3:	ff 75 f4             	push   -0xc(%ebp)
801097f6:	68 af c6 10 80       	push   $0x8010c6af
801097fb:	e8 f4 6b ff ff       	call   801003f4 <cprintf>
80109800:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109803:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109806:	89 d0                	mov    %edx,%eax
80109808:	c1 e0 02             	shl    $0x2,%eax
8010980b:	01 d0                	add    %edx,%eax
8010980d:	01 c0                	add    %eax,%eax
8010980f:	01 d0                	add    %edx,%eax
80109811:	05 a0 77 19 80       	add    $0x801977a0,%eax
80109816:	83 ec 0c             	sub    $0xc,%esp
80109819:	50                   	push   %eax
8010981a:	e8 54 02 00 00       	call   80109a73 <print_ipv4>
8010981f:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109822:	83 ec 0c             	sub    $0xc,%esp
80109825:	68 be c6 10 80       	push   $0x8010c6be
8010982a:	e8 c5 6b ff ff       	call   801003f4 <cprintf>
8010982f:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109832:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109835:	89 d0                	mov    %edx,%eax
80109837:	c1 e0 02             	shl    $0x2,%eax
8010983a:	01 d0                	add    %edx,%eax
8010983c:	01 c0                	add    %eax,%eax
8010983e:	01 d0                	add    %edx,%eax
80109840:	05 a0 77 19 80       	add    $0x801977a0,%eax
80109845:	83 c0 04             	add    $0x4,%eax
80109848:	83 ec 0c             	sub    $0xc,%esp
8010984b:	50                   	push   %eax
8010984c:	e8 70 02 00 00       	call   80109ac1 <print_mac>
80109851:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109854:	83 ec 0c             	sub    $0xc,%esp
80109857:	68 c0 c6 10 80       	push   $0x8010c6c0
8010985c:	e8 93 6b ff ff       	call   801003f4 <cprintf>
80109861:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109864:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109868:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010986c:	0f 8e 64 ff ff ff    	jle    801097d6 <print_arp_table+0x12>
    }
  }
}
80109872:	90                   	nop
80109873:	90                   	nop
80109874:	c9                   	leave  
80109875:	c3                   	ret    

80109876 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109876:	55                   	push   %ebp
80109877:	89 e5                	mov    %esp,%ebp
80109879:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010987c:	8b 45 10             	mov    0x10(%ebp),%eax
8010987f:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109885:	8b 45 0c             	mov    0xc(%ebp),%eax
80109888:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010988b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010988e:	83 c0 0e             	add    $0xe,%eax
80109891:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109897:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010989b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010989e:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801098a2:	8b 45 08             	mov    0x8(%ebp),%eax
801098a5:	8d 50 08             	lea    0x8(%eax),%edx
801098a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098ab:	83 ec 04             	sub    $0x4,%esp
801098ae:	6a 06                	push   $0x6
801098b0:	52                   	push   %edx
801098b1:	50                   	push   %eax
801098b2:	e8 a3 b5 ff ff       	call   80104e5a <memmove>
801098b7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801098ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098bd:	83 c0 06             	add    $0x6,%eax
801098c0:	83 ec 04             	sub    $0x4,%esp
801098c3:	6a 06                	push   $0x6
801098c5:	68 90 77 19 80       	push   $0x80197790
801098ca:	50                   	push   %eax
801098cb:	e8 8a b5 ff ff       	call   80104e5a <memmove>
801098d0:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801098d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098d6:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801098db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098de:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801098e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098e7:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801098eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098ee:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801098f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098f5:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801098fb:	8b 45 08             	mov    0x8(%ebp),%eax
801098fe:	8d 50 08             	lea    0x8(%eax),%edx
80109901:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109904:	83 c0 12             	add    $0x12,%eax
80109907:	83 ec 04             	sub    $0x4,%esp
8010990a:	6a 06                	push   $0x6
8010990c:	52                   	push   %edx
8010990d:	50                   	push   %eax
8010990e:	e8 47 b5 ff ff       	call   80104e5a <memmove>
80109913:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109916:	8b 45 08             	mov    0x8(%ebp),%eax
80109919:	8d 50 0e             	lea    0xe(%eax),%edx
8010991c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010991f:	83 c0 18             	add    $0x18,%eax
80109922:	83 ec 04             	sub    $0x4,%esp
80109925:	6a 04                	push   $0x4
80109927:	52                   	push   %edx
80109928:	50                   	push   %eax
80109929:	e8 2c b5 ff ff       	call   80104e5a <memmove>
8010992e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109931:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109934:	83 c0 08             	add    $0x8,%eax
80109937:	83 ec 04             	sub    $0x4,%esp
8010993a:	6a 06                	push   $0x6
8010993c:	68 90 77 19 80       	push   $0x80197790
80109941:	50                   	push   %eax
80109942:	e8 13 b5 ff ff       	call   80104e5a <memmove>
80109947:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010994a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010994d:	83 c0 0e             	add    $0xe,%eax
80109950:	83 ec 04             	sub    $0x4,%esp
80109953:	6a 04                	push   $0x4
80109955:	68 04 f5 10 80       	push   $0x8010f504
8010995a:	50                   	push   %eax
8010995b:	e8 fa b4 ff ff       	call   80104e5a <memmove>
80109960:	83 c4 10             	add    $0x10,%esp
}
80109963:	90                   	nop
80109964:	c9                   	leave  
80109965:	c3                   	ret    

80109966 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109966:	55                   	push   %ebp
80109967:	89 e5                	mov    %esp,%ebp
80109969:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
8010996c:	83 ec 0c             	sub    $0xc,%esp
8010996f:	68 c2 c6 10 80       	push   $0x8010c6c2
80109974:	e8 7b 6a ff ff       	call   801003f4 <cprintf>
80109979:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
8010997c:	8b 45 08             	mov    0x8(%ebp),%eax
8010997f:	83 c0 0e             	add    $0xe,%eax
80109982:	83 ec 0c             	sub    $0xc,%esp
80109985:	50                   	push   %eax
80109986:	e8 e8 00 00 00       	call   80109a73 <print_ipv4>
8010998b:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010998e:	83 ec 0c             	sub    $0xc,%esp
80109991:	68 c0 c6 10 80       	push   $0x8010c6c0
80109996:	e8 59 6a ff ff       	call   801003f4 <cprintf>
8010999b:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010999e:	8b 45 08             	mov    0x8(%ebp),%eax
801099a1:	83 c0 08             	add    $0x8,%eax
801099a4:	83 ec 0c             	sub    $0xc,%esp
801099a7:	50                   	push   %eax
801099a8:	e8 14 01 00 00       	call   80109ac1 <print_mac>
801099ad:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801099b0:	83 ec 0c             	sub    $0xc,%esp
801099b3:	68 c0 c6 10 80       	push   $0x8010c6c0
801099b8:	e8 37 6a ff ff       	call   801003f4 <cprintf>
801099bd:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801099c0:	83 ec 0c             	sub    $0xc,%esp
801099c3:	68 d9 c6 10 80       	push   $0x8010c6d9
801099c8:	e8 27 6a ff ff       	call   801003f4 <cprintf>
801099cd:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801099d0:	8b 45 08             	mov    0x8(%ebp),%eax
801099d3:	83 c0 18             	add    $0x18,%eax
801099d6:	83 ec 0c             	sub    $0xc,%esp
801099d9:	50                   	push   %eax
801099da:	e8 94 00 00 00       	call   80109a73 <print_ipv4>
801099df:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801099e2:	83 ec 0c             	sub    $0xc,%esp
801099e5:	68 c0 c6 10 80       	push   $0x8010c6c0
801099ea:	e8 05 6a ff ff       	call   801003f4 <cprintf>
801099ef:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
801099f2:	8b 45 08             	mov    0x8(%ebp),%eax
801099f5:	83 c0 12             	add    $0x12,%eax
801099f8:	83 ec 0c             	sub    $0xc,%esp
801099fb:	50                   	push   %eax
801099fc:	e8 c0 00 00 00       	call   80109ac1 <print_mac>
80109a01:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109a04:	83 ec 0c             	sub    $0xc,%esp
80109a07:	68 c0 c6 10 80       	push   $0x8010c6c0
80109a0c:	e8 e3 69 ff ff       	call   801003f4 <cprintf>
80109a11:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109a14:	83 ec 0c             	sub    $0xc,%esp
80109a17:	68 f0 c6 10 80       	push   $0x8010c6f0
80109a1c:	e8 d3 69 ff ff       	call   801003f4 <cprintf>
80109a21:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109a24:	8b 45 08             	mov    0x8(%ebp),%eax
80109a27:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109a2b:	66 3d 00 01          	cmp    $0x100,%ax
80109a2f:	75 12                	jne    80109a43 <print_arp_info+0xdd>
80109a31:	83 ec 0c             	sub    $0xc,%esp
80109a34:	68 fc c6 10 80       	push   $0x8010c6fc
80109a39:	e8 b6 69 ff ff       	call   801003f4 <cprintf>
80109a3e:	83 c4 10             	add    $0x10,%esp
80109a41:	eb 1d                	jmp    80109a60 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109a43:	8b 45 08             	mov    0x8(%ebp),%eax
80109a46:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109a4a:	66 3d 00 02          	cmp    $0x200,%ax
80109a4e:	75 10                	jne    80109a60 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109a50:	83 ec 0c             	sub    $0xc,%esp
80109a53:	68 05 c7 10 80       	push   $0x8010c705
80109a58:	e8 97 69 ff ff       	call   801003f4 <cprintf>
80109a5d:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109a60:	83 ec 0c             	sub    $0xc,%esp
80109a63:	68 c0 c6 10 80       	push   $0x8010c6c0
80109a68:	e8 87 69 ff ff       	call   801003f4 <cprintf>
80109a6d:	83 c4 10             	add    $0x10,%esp
}
80109a70:	90                   	nop
80109a71:	c9                   	leave  
80109a72:	c3                   	ret    

80109a73 <print_ipv4>:

void print_ipv4(uchar *ip){
80109a73:	55                   	push   %ebp
80109a74:	89 e5                	mov    %esp,%ebp
80109a76:	53                   	push   %ebx
80109a77:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80109a7d:	83 c0 03             	add    $0x3,%eax
80109a80:	0f b6 00             	movzbl (%eax),%eax
80109a83:	0f b6 d8             	movzbl %al,%ebx
80109a86:	8b 45 08             	mov    0x8(%ebp),%eax
80109a89:	83 c0 02             	add    $0x2,%eax
80109a8c:	0f b6 00             	movzbl (%eax),%eax
80109a8f:	0f b6 c8             	movzbl %al,%ecx
80109a92:	8b 45 08             	mov    0x8(%ebp),%eax
80109a95:	83 c0 01             	add    $0x1,%eax
80109a98:	0f b6 00             	movzbl (%eax),%eax
80109a9b:	0f b6 d0             	movzbl %al,%edx
80109a9e:	8b 45 08             	mov    0x8(%ebp),%eax
80109aa1:	0f b6 00             	movzbl (%eax),%eax
80109aa4:	0f b6 c0             	movzbl %al,%eax
80109aa7:	83 ec 0c             	sub    $0xc,%esp
80109aaa:	53                   	push   %ebx
80109aab:	51                   	push   %ecx
80109aac:	52                   	push   %edx
80109aad:	50                   	push   %eax
80109aae:	68 0c c7 10 80       	push   $0x8010c70c
80109ab3:	e8 3c 69 ff ff       	call   801003f4 <cprintf>
80109ab8:	83 c4 20             	add    $0x20,%esp
}
80109abb:	90                   	nop
80109abc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109abf:	c9                   	leave  
80109ac0:	c3                   	ret    

80109ac1 <print_mac>:

void print_mac(uchar *mac){
80109ac1:	55                   	push   %ebp
80109ac2:	89 e5                	mov    %esp,%ebp
80109ac4:	57                   	push   %edi
80109ac5:	56                   	push   %esi
80109ac6:	53                   	push   %ebx
80109ac7:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109aca:	8b 45 08             	mov    0x8(%ebp),%eax
80109acd:	83 c0 05             	add    $0x5,%eax
80109ad0:	0f b6 00             	movzbl (%eax),%eax
80109ad3:	0f b6 f8             	movzbl %al,%edi
80109ad6:	8b 45 08             	mov    0x8(%ebp),%eax
80109ad9:	83 c0 04             	add    $0x4,%eax
80109adc:	0f b6 00             	movzbl (%eax),%eax
80109adf:	0f b6 f0             	movzbl %al,%esi
80109ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80109ae5:	83 c0 03             	add    $0x3,%eax
80109ae8:	0f b6 00             	movzbl (%eax),%eax
80109aeb:	0f b6 d8             	movzbl %al,%ebx
80109aee:	8b 45 08             	mov    0x8(%ebp),%eax
80109af1:	83 c0 02             	add    $0x2,%eax
80109af4:	0f b6 00             	movzbl (%eax),%eax
80109af7:	0f b6 c8             	movzbl %al,%ecx
80109afa:	8b 45 08             	mov    0x8(%ebp),%eax
80109afd:	83 c0 01             	add    $0x1,%eax
80109b00:	0f b6 00             	movzbl (%eax),%eax
80109b03:	0f b6 d0             	movzbl %al,%edx
80109b06:	8b 45 08             	mov    0x8(%ebp),%eax
80109b09:	0f b6 00             	movzbl (%eax),%eax
80109b0c:	0f b6 c0             	movzbl %al,%eax
80109b0f:	83 ec 04             	sub    $0x4,%esp
80109b12:	57                   	push   %edi
80109b13:	56                   	push   %esi
80109b14:	53                   	push   %ebx
80109b15:	51                   	push   %ecx
80109b16:	52                   	push   %edx
80109b17:	50                   	push   %eax
80109b18:	68 24 c7 10 80       	push   $0x8010c724
80109b1d:	e8 d2 68 ff ff       	call   801003f4 <cprintf>
80109b22:	83 c4 20             	add    $0x20,%esp
}
80109b25:	90                   	nop
80109b26:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109b29:	5b                   	pop    %ebx
80109b2a:	5e                   	pop    %esi
80109b2b:	5f                   	pop    %edi
80109b2c:	5d                   	pop    %ebp
80109b2d:	c3                   	ret    

80109b2e <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109b2e:	55                   	push   %ebp
80109b2f:	89 e5                	mov    %esp,%ebp
80109b31:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109b34:	8b 45 08             	mov    0x8(%ebp),%eax
80109b37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80109b3d:	83 c0 0e             	add    $0xe,%eax
80109b40:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b46:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109b4a:	3c 08                	cmp    $0x8,%al
80109b4c:	75 1b                	jne    80109b69 <eth_proc+0x3b>
80109b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b51:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b55:	3c 06                	cmp    $0x6,%al
80109b57:	75 10                	jne    80109b69 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109b59:	83 ec 0c             	sub    $0xc,%esp
80109b5c:	ff 75 f0             	push   -0x10(%ebp)
80109b5f:	e8 01 f8 ff ff       	call   80109365 <arp_proc>
80109b64:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109b67:	eb 24                	jmp    80109b8d <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b6c:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109b70:	3c 08                	cmp    $0x8,%al
80109b72:	75 19                	jne    80109b8d <eth_proc+0x5f>
80109b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b77:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b7b:	84 c0                	test   %al,%al
80109b7d:	75 0e                	jne    80109b8d <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109b7f:	83 ec 0c             	sub    $0xc,%esp
80109b82:	ff 75 08             	push   0x8(%ebp)
80109b85:	e8 a3 00 00 00       	call   80109c2d <ipv4_proc>
80109b8a:	83 c4 10             	add    $0x10,%esp
}
80109b8d:	90                   	nop
80109b8e:	c9                   	leave  
80109b8f:	c3                   	ret    

80109b90 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109b90:	55                   	push   %ebp
80109b91:	89 e5                	mov    %esp,%ebp
80109b93:	83 ec 04             	sub    $0x4,%esp
80109b96:	8b 45 08             	mov    0x8(%ebp),%eax
80109b99:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109b9d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109ba1:	c1 e0 08             	shl    $0x8,%eax
80109ba4:	89 c2                	mov    %eax,%edx
80109ba6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109baa:	66 c1 e8 08          	shr    $0x8,%ax
80109bae:	01 d0                	add    %edx,%eax
}
80109bb0:	c9                   	leave  
80109bb1:	c3                   	ret    

80109bb2 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109bb2:	55                   	push   %ebp
80109bb3:	89 e5                	mov    %esp,%ebp
80109bb5:	83 ec 04             	sub    $0x4,%esp
80109bb8:	8b 45 08             	mov    0x8(%ebp),%eax
80109bbb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109bbf:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109bc3:	c1 e0 08             	shl    $0x8,%eax
80109bc6:	89 c2                	mov    %eax,%edx
80109bc8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109bcc:	66 c1 e8 08          	shr    $0x8,%ax
80109bd0:	01 d0                	add    %edx,%eax
}
80109bd2:	c9                   	leave  
80109bd3:	c3                   	ret    

80109bd4 <H2N_uint>:

uint H2N_uint(uint value){
80109bd4:	55                   	push   %ebp
80109bd5:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80109bda:	c1 e0 18             	shl    $0x18,%eax
80109bdd:	25 00 00 00 0f       	and    $0xf000000,%eax
80109be2:	89 c2                	mov    %eax,%edx
80109be4:	8b 45 08             	mov    0x8(%ebp),%eax
80109be7:	c1 e0 08             	shl    $0x8,%eax
80109bea:	25 00 f0 00 00       	and    $0xf000,%eax
80109bef:	09 c2                	or     %eax,%edx
80109bf1:	8b 45 08             	mov    0x8(%ebp),%eax
80109bf4:	c1 e8 08             	shr    $0x8,%eax
80109bf7:	83 e0 0f             	and    $0xf,%eax
80109bfa:	01 d0                	add    %edx,%eax
}
80109bfc:	5d                   	pop    %ebp
80109bfd:	c3                   	ret    

80109bfe <N2H_uint>:

uint N2H_uint(uint value){
80109bfe:	55                   	push   %ebp
80109bff:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109c01:	8b 45 08             	mov    0x8(%ebp),%eax
80109c04:	c1 e0 18             	shl    $0x18,%eax
80109c07:	89 c2                	mov    %eax,%edx
80109c09:	8b 45 08             	mov    0x8(%ebp),%eax
80109c0c:	c1 e0 08             	shl    $0x8,%eax
80109c0f:	25 00 00 ff 00       	and    $0xff0000,%eax
80109c14:	01 c2                	add    %eax,%edx
80109c16:	8b 45 08             	mov    0x8(%ebp),%eax
80109c19:	c1 e8 08             	shr    $0x8,%eax
80109c1c:	25 00 ff 00 00       	and    $0xff00,%eax
80109c21:	01 c2                	add    %eax,%edx
80109c23:	8b 45 08             	mov    0x8(%ebp),%eax
80109c26:	c1 e8 18             	shr    $0x18,%eax
80109c29:	01 d0                	add    %edx,%eax
}
80109c2b:	5d                   	pop    %ebp
80109c2c:	c3                   	ret    

80109c2d <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109c2d:	55                   	push   %ebp
80109c2e:	89 e5                	mov    %esp,%ebp
80109c30:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109c33:	8b 45 08             	mov    0x8(%ebp),%eax
80109c36:	83 c0 0e             	add    $0xe,%eax
80109c39:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c3f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c43:	0f b7 d0             	movzwl %ax,%edx
80109c46:	a1 08 f5 10 80       	mov    0x8010f508,%eax
80109c4b:	39 c2                	cmp    %eax,%edx
80109c4d:	74 60                	je     80109caf <ipv4_proc+0x82>
80109c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c52:	83 c0 0c             	add    $0xc,%eax
80109c55:	83 ec 04             	sub    $0x4,%esp
80109c58:	6a 04                	push   $0x4
80109c5a:	50                   	push   %eax
80109c5b:	68 04 f5 10 80       	push   $0x8010f504
80109c60:	e8 9d b1 ff ff       	call   80104e02 <memcmp>
80109c65:	83 c4 10             	add    $0x10,%esp
80109c68:	85 c0                	test   %eax,%eax
80109c6a:	74 43                	je     80109caf <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c6f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c73:	0f b7 c0             	movzwl %ax,%eax
80109c76:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c7e:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109c82:	3c 01                	cmp    $0x1,%al
80109c84:	75 10                	jne    80109c96 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109c86:	83 ec 0c             	sub    $0xc,%esp
80109c89:	ff 75 08             	push   0x8(%ebp)
80109c8c:	e8 a3 00 00 00       	call   80109d34 <icmp_proc>
80109c91:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109c94:	eb 19                	jmp    80109caf <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c99:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109c9d:	3c 06                	cmp    $0x6,%al
80109c9f:	75 0e                	jne    80109caf <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109ca1:	83 ec 0c             	sub    $0xc,%esp
80109ca4:	ff 75 08             	push   0x8(%ebp)
80109ca7:	e8 b3 03 00 00       	call   8010a05f <tcp_proc>
80109cac:	83 c4 10             	add    $0x10,%esp
}
80109caf:	90                   	nop
80109cb0:	c9                   	leave  
80109cb1:	c3                   	ret    

80109cb2 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109cb2:	55                   	push   %ebp
80109cb3:	89 e5                	mov    %esp,%ebp
80109cb5:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109cb8:	8b 45 08             	mov    0x8(%ebp),%eax
80109cbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cc1:	0f b6 00             	movzbl (%eax),%eax
80109cc4:	83 e0 0f             	and    $0xf,%eax
80109cc7:	01 c0                	add    %eax,%eax
80109cc9:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109ccc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109cd3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109cda:	eb 48                	jmp    80109d24 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109cdc:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109cdf:	01 c0                	add    %eax,%eax
80109ce1:	89 c2                	mov    %eax,%edx
80109ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ce6:	01 d0                	add    %edx,%eax
80109ce8:	0f b6 00             	movzbl (%eax),%eax
80109ceb:	0f b6 c0             	movzbl %al,%eax
80109cee:	c1 e0 08             	shl    $0x8,%eax
80109cf1:	89 c2                	mov    %eax,%edx
80109cf3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109cf6:	01 c0                	add    %eax,%eax
80109cf8:	8d 48 01             	lea    0x1(%eax),%ecx
80109cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cfe:	01 c8                	add    %ecx,%eax
80109d00:	0f b6 00             	movzbl (%eax),%eax
80109d03:	0f b6 c0             	movzbl %al,%eax
80109d06:	01 d0                	add    %edx,%eax
80109d08:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109d0b:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109d12:	76 0c                	jbe    80109d20 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109d14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d17:	0f b7 c0             	movzwl %ax,%eax
80109d1a:	83 c0 01             	add    $0x1,%eax
80109d1d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109d20:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109d24:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109d28:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109d2b:	7c af                	jl     80109cdc <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109d2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d30:	f7 d0                	not    %eax
}
80109d32:	c9                   	leave  
80109d33:	c3                   	ret    

80109d34 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109d34:	55                   	push   %ebp
80109d35:	89 e5                	mov    %esp,%ebp
80109d37:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109d3a:	8b 45 08             	mov    0x8(%ebp),%eax
80109d3d:	83 c0 0e             	add    $0xe,%eax
80109d40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d46:	0f b6 00             	movzbl (%eax),%eax
80109d49:	0f b6 c0             	movzbl %al,%eax
80109d4c:	83 e0 0f             	and    $0xf,%eax
80109d4f:	c1 e0 02             	shl    $0x2,%eax
80109d52:	89 c2                	mov    %eax,%edx
80109d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d57:	01 d0                	add    %edx,%eax
80109d59:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d5f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109d63:	84 c0                	test   %al,%al
80109d65:	75 4f                	jne    80109db6 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d6a:	0f b6 00             	movzbl (%eax),%eax
80109d6d:	3c 08                	cmp    $0x8,%al
80109d6f:	75 45                	jne    80109db6 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109d71:	e8 2a 8a ff ff       	call   801027a0 <kalloc>
80109d76:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109d79:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109d80:	83 ec 04             	sub    $0x4,%esp
80109d83:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109d86:	50                   	push   %eax
80109d87:	ff 75 ec             	push   -0x14(%ebp)
80109d8a:	ff 75 08             	push   0x8(%ebp)
80109d8d:	e8 78 00 00 00       	call   80109e0a <icmp_reply_pkt_create>
80109d92:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109d95:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d98:	83 ec 08             	sub    $0x8,%esp
80109d9b:	50                   	push   %eax
80109d9c:	ff 75 ec             	push   -0x14(%ebp)
80109d9f:	e8 95 f4 ff ff       	call   80109239 <i8254_send>
80109da4:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109da7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109daa:	83 ec 0c             	sub    $0xc,%esp
80109dad:	50                   	push   %eax
80109dae:	e8 53 89 ff ff       	call   80102706 <kfree>
80109db3:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109db6:	90                   	nop
80109db7:	c9                   	leave  
80109db8:	c3                   	ret    

80109db9 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109db9:	55                   	push   %ebp
80109dba:	89 e5                	mov    %esp,%ebp
80109dbc:	53                   	push   %ebx
80109dbd:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80109dc3:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109dc7:	0f b7 c0             	movzwl %ax,%eax
80109dca:	83 ec 0c             	sub    $0xc,%esp
80109dcd:	50                   	push   %eax
80109dce:	e8 bd fd ff ff       	call   80109b90 <N2H_ushort>
80109dd3:	83 c4 10             	add    $0x10,%esp
80109dd6:	0f b7 d8             	movzwl %ax,%ebx
80109dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80109ddc:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109de0:	0f b7 c0             	movzwl %ax,%eax
80109de3:	83 ec 0c             	sub    $0xc,%esp
80109de6:	50                   	push   %eax
80109de7:	e8 a4 fd ff ff       	call   80109b90 <N2H_ushort>
80109dec:	83 c4 10             	add    $0x10,%esp
80109def:	0f b7 c0             	movzwl %ax,%eax
80109df2:	83 ec 04             	sub    $0x4,%esp
80109df5:	53                   	push   %ebx
80109df6:	50                   	push   %eax
80109df7:	68 43 c7 10 80       	push   $0x8010c743
80109dfc:	e8 f3 65 ff ff       	call   801003f4 <cprintf>
80109e01:	83 c4 10             	add    $0x10,%esp
}
80109e04:	90                   	nop
80109e05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109e08:	c9                   	leave  
80109e09:	c3                   	ret    

80109e0a <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109e0a:	55                   	push   %ebp
80109e0b:	89 e5                	mov    %esp,%ebp
80109e0d:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109e10:	8b 45 08             	mov    0x8(%ebp),%eax
80109e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109e16:	8b 45 08             	mov    0x8(%ebp),%eax
80109e19:	83 c0 0e             	add    $0xe,%eax
80109e1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e22:	0f b6 00             	movzbl (%eax),%eax
80109e25:	0f b6 c0             	movzbl %al,%eax
80109e28:	83 e0 0f             	and    $0xf,%eax
80109e2b:	c1 e0 02             	shl    $0x2,%eax
80109e2e:	89 c2                	mov    %eax,%edx
80109e30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e33:	01 d0                	add    %edx,%eax
80109e35:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109e38:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e3b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e41:	83 c0 0e             	add    $0xe,%eax
80109e44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e4a:	83 c0 14             	add    $0x14,%eax
80109e4d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109e50:	8b 45 10             	mov    0x10(%ebp),%eax
80109e53:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e5c:	8d 50 06             	lea    0x6(%eax),%edx
80109e5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e62:	83 ec 04             	sub    $0x4,%esp
80109e65:	6a 06                	push   $0x6
80109e67:	52                   	push   %edx
80109e68:	50                   	push   %eax
80109e69:	e8 ec af ff ff       	call   80104e5a <memmove>
80109e6e:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109e71:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e74:	83 c0 06             	add    $0x6,%eax
80109e77:	83 ec 04             	sub    $0x4,%esp
80109e7a:	6a 06                	push   $0x6
80109e7c:	68 90 77 19 80       	push   $0x80197790
80109e81:	50                   	push   %eax
80109e82:	e8 d3 af ff ff       	call   80104e5a <memmove>
80109e87:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109e8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e8d:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109e91:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e94:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109e98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e9b:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109e9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ea1:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109ea5:	83 ec 0c             	sub    $0xc,%esp
80109ea8:	6a 54                	push   $0x54
80109eaa:	e8 03 fd ff ff       	call   80109bb2 <H2N_ushort>
80109eaf:	83 c4 10             	add    $0x10,%esp
80109eb2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109eb5:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109eb9:	0f b7 15 60 7a 19 80 	movzwl 0x80197a60,%edx
80109ec0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ec3:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109ec7:	0f b7 05 60 7a 19 80 	movzwl 0x80197a60,%eax
80109ece:	83 c0 01             	add    $0x1,%eax
80109ed1:	66 a3 60 7a 19 80    	mov    %ax,0x80197a60
  ipv4_send->fragment = H2N_ushort(0x4000);
80109ed7:	83 ec 0c             	sub    $0xc,%esp
80109eda:	68 00 40 00 00       	push   $0x4000
80109edf:	e8 ce fc ff ff       	call   80109bb2 <H2N_ushort>
80109ee4:	83 c4 10             	add    $0x10,%esp
80109ee7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109eea:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109eee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ef1:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109ef5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ef8:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109efc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109eff:	83 c0 0c             	add    $0xc,%eax
80109f02:	83 ec 04             	sub    $0x4,%esp
80109f05:	6a 04                	push   $0x4
80109f07:	68 04 f5 10 80       	push   $0x8010f504
80109f0c:	50                   	push   %eax
80109f0d:	e8 48 af ff ff       	call   80104e5a <memmove>
80109f12:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109f15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f18:	8d 50 0c             	lea    0xc(%eax),%edx
80109f1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f1e:	83 c0 10             	add    $0x10,%eax
80109f21:	83 ec 04             	sub    $0x4,%esp
80109f24:	6a 04                	push   $0x4
80109f26:	52                   	push   %edx
80109f27:	50                   	push   %eax
80109f28:	e8 2d af ff ff       	call   80104e5a <memmove>
80109f2d:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109f30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f33:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109f39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f3c:	83 ec 0c             	sub    $0xc,%esp
80109f3f:	50                   	push   %eax
80109f40:	e8 6d fd ff ff       	call   80109cb2 <ipv4_chksum>
80109f45:	83 c4 10             	add    $0x10,%esp
80109f48:	0f b7 c0             	movzwl %ax,%eax
80109f4b:	83 ec 0c             	sub    $0xc,%esp
80109f4e:	50                   	push   %eax
80109f4f:	e8 5e fc ff ff       	call   80109bb2 <H2N_ushort>
80109f54:	83 c4 10             	add    $0x10,%esp
80109f57:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109f5a:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109f5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f61:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109f64:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f67:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109f6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f6e:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109f72:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f75:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109f79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f7c:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109f80:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f83:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109f87:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f8a:	8d 50 08             	lea    0x8(%eax),%edx
80109f8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f90:	83 c0 08             	add    $0x8,%eax
80109f93:	83 ec 04             	sub    $0x4,%esp
80109f96:	6a 08                	push   $0x8
80109f98:	52                   	push   %edx
80109f99:	50                   	push   %eax
80109f9a:	e8 bb ae ff ff       	call   80104e5a <memmove>
80109f9f:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109fa2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109fa5:	8d 50 10             	lea    0x10(%eax),%edx
80109fa8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fab:	83 c0 10             	add    $0x10,%eax
80109fae:	83 ec 04             	sub    $0x4,%esp
80109fb1:	6a 30                	push   $0x30
80109fb3:	52                   	push   %edx
80109fb4:	50                   	push   %eax
80109fb5:	e8 a0 ae ff ff       	call   80104e5a <memmove>
80109fba:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109fbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fc0:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109fc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fc9:	83 ec 0c             	sub    $0xc,%esp
80109fcc:	50                   	push   %eax
80109fcd:	e8 1c 00 00 00       	call   80109fee <icmp_chksum>
80109fd2:	83 c4 10             	add    $0x10,%esp
80109fd5:	0f b7 c0             	movzwl %ax,%eax
80109fd8:	83 ec 0c             	sub    $0xc,%esp
80109fdb:	50                   	push   %eax
80109fdc:	e8 d1 fb ff ff       	call   80109bb2 <H2N_ushort>
80109fe1:	83 c4 10             	add    $0x10,%esp
80109fe4:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109fe7:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109feb:	90                   	nop
80109fec:	c9                   	leave  
80109fed:	c3                   	ret    

80109fee <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109fee:	55                   	push   %ebp
80109fef:	89 e5                	mov    %esp,%ebp
80109ff1:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109ff4:	8b 45 08             	mov    0x8(%ebp),%eax
80109ff7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109ffa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a001:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a008:	eb 48                	jmp    8010a052 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a00a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a00d:	01 c0                	add    %eax,%eax
8010a00f:	89 c2                	mov    %eax,%edx
8010a011:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a014:	01 d0                	add    %edx,%eax
8010a016:	0f b6 00             	movzbl (%eax),%eax
8010a019:	0f b6 c0             	movzbl %al,%eax
8010a01c:	c1 e0 08             	shl    $0x8,%eax
8010a01f:	89 c2                	mov    %eax,%edx
8010a021:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a024:	01 c0                	add    %eax,%eax
8010a026:	8d 48 01             	lea    0x1(%eax),%ecx
8010a029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a02c:	01 c8                	add    %ecx,%eax
8010a02e:	0f b6 00             	movzbl (%eax),%eax
8010a031:	0f b6 c0             	movzbl %al,%eax
8010a034:	01 d0                	add    %edx,%eax
8010a036:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a039:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a040:	76 0c                	jbe    8010a04e <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a042:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a045:	0f b7 c0             	movzwl %ax,%eax
8010a048:	83 c0 01             	add    $0x1,%eax
8010a04b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a04e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a052:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a056:	7e b2                	jle    8010a00a <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
8010a058:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a05b:	f7 d0                	not    %eax
}
8010a05d:	c9                   	leave  
8010a05e:	c3                   	ret    

8010a05f <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a05f:	55                   	push   %ebp
8010a060:	89 e5                	mov    %esp,%ebp
8010a062:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a065:	8b 45 08             	mov    0x8(%ebp),%eax
8010a068:	83 c0 0e             	add    $0xe,%eax
8010a06b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a06e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a071:	0f b6 00             	movzbl (%eax),%eax
8010a074:	0f b6 c0             	movzbl %al,%eax
8010a077:	83 e0 0f             	and    $0xf,%eax
8010a07a:	c1 e0 02             	shl    $0x2,%eax
8010a07d:	89 c2                	mov    %eax,%edx
8010a07f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a082:	01 d0                	add    %edx,%eax
8010a084:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a087:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a08a:	83 c0 14             	add    $0x14,%eax
8010a08d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a090:	e8 0b 87 ff ff       	call   801027a0 <kalloc>
8010a095:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a098:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a09f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0a2:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a0a6:	0f b6 c0             	movzbl %al,%eax
8010a0a9:	83 e0 02             	and    $0x2,%eax
8010a0ac:	85 c0                	test   %eax,%eax
8010a0ae:	74 3d                	je     8010a0ed <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a0b0:	83 ec 0c             	sub    $0xc,%esp
8010a0b3:	6a 00                	push   $0x0
8010a0b5:	6a 12                	push   $0x12
8010a0b7:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a0ba:	50                   	push   %eax
8010a0bb:	ff 75 e8             	push   -0x18(%ebp)
8010a0be:	ff 75 08             	push   0x8(%ebp)
8010a0c1:	e8 a2 01 00 00       	call   8010a268 <tcp_pkt_create>
8010a0c6:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a0c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0cc:	83 ec 08             	sub    $0x8,%esp
8010a0cf:	50                   	push   %eax
8010a0d0:	ff 75 e8             	push   -0x18(%ebp)
8010a0d3:	e8 61 f1 ff ff       	call   80109239 <i8254_send>
8010a0d8:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a0db:	a1 64 7a 19 80       	mov    0x80197a64,%eax
8010a0e0:	83 c0 01             	add    $0x1,%eax
8010a0e3:	a3 64 7a 19 80       	mov    %eax,0x80197a64
8010a0e8:	e9 69 01 00 00       	jmp    8010a256 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a0ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0f0:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a0f4:	3c 18                	cmp    $0x18,%al
8010a0f6:	0f 85 10 01 00 00    	jne    8010a20c <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a0fc:	83 ec 04             	sub    $0x4,%esp
8010a0ff:	6a 03                	push   $0x3
8010a101:	68 5e c7 10 80       	push   $0x8010c75e
8010a106:	ff 75 ec             	push   -0x14(%ebp)
8010a109:	e8 f4 ac ff ff       	call   80104e02 <memcmp>
8010a10e:	83 c4 10             	add    $0x10,%esp
8010a111:	85 c0                	test   %eax,%eax
8010a113:	74 74                	je     8010a189 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a115:	83 ec 0c             	sub    $0xc,%esp
8010a118:	68 62 c7 10 80       	push   $0x8010c762
8010a11d:	e8 d2 62 ff ff       	call   801003f4 <cprintf>
8010a122:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a125:	83 ec 0c             	sub    $0xc,%esp
8010a128:	6a 00                	push   $0x0
8010a12a:	6a 10                	push   $0x10
8010a12c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a12f:	50                   	push   %eax
8010a130:	ff 75 e8             	push   -0x18(%ebp)
8010a133:	ff 75 08             	push   0x8(%ebp)
8010a136:	e8 2d 01 00 00       	call   8010a268 <tcp_pkt_create>
8010a13b:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a13e:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a141:	83 ec 08             	sub    $0x8,%esp
8010a144:	50                   	push   %eax
8010a145:	ff 75 e8             	push   -0x18(%ebp)
8010a148:	e8 ec f0 ff ff       	call   80109239 <i8254_send>
8010a14d:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a150:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a153:	83 c0 36             	add    $0x36,%eax
8010a156:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a159:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a15c:	50                   	push   %eax
8010a15d:	ff 75 e0             	push   -0x20(%ebp)
8010a160:	6a 00                	push   $0x0
8010a162:	6a 00                	push   $0x0
8010a164:	e8 5a 04 00 00       	call   8010a5c3 <http_proc>
8010a169:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a16c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a16f:	83 ec 0c             	sub    $0xc,%esp
8010a172:	50                   	push   %eax
8010a173:	6a 18                	push   $0x18
8010a175:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a178:	50                   	push   %eax
8010a179:	ff 75 e8             	push   -0x18(%ebp)
8010a17c:	ff 75 08             	push   0x8(%ebp)
8010a17f:	e8 e4 00 00 00       	call   8010a268 <tcp_pkt_create>
8010a184:	83 c4 20             	add    $0x20,%esp
8010a187:	eb 62                	jmp    8010a1eb <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a189:	83 ec 0c             	sub    $0xc,%esp
8010a18c:	6a 00                	push   $0x0
8010a18e:	6a 10                	push   $0x10
8010a190:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a193:	50                   	push   %eax
8010a194:	ff 75 e8             	push   -0x18(%ebp)
8010a197:	ff 75 08             	push   0x8(%ebp)
8010a19a:	e8 c9 00 00 00       	call   8010a268 <tcp_pkt_create>
8010a19f:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a1a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a1a5:	83 ec 08             	sub    $0x8,%esp
8010a1a8:	50                   	push   %eax
8010a1a9:	ff 75 e8             	push   -0x18(%ebp)
8010a1ac:	e8 88 f0 ff ff       	call   80109239 <i8254_send>
8010a1b1:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a1b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1b7:	83 c0 36             	add    $0x36,%eax
8010a1ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a1bd:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a1c0:	50                   	push   %eax
8010a1c1:	ff 75 e4             	push   -0x1c(%ebp)
8010a1c4:	6a 00                	push   $0x0
8010a1c6:	6a 00                	push   $0x0
8010a1c8:	e8 f6 03 00 00       	call   8010a5c3 <http_proc>
8010a1cd:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a1d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a1d3:	83 ec 0c             	sub    $0xc,%esp
8010a1d6:	50                   	push   %eax
8010a1d7:	6a 18                	push   $0x18
8010a1d9:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a1dc:	50                   	push   %eax
8010a1dd:	ff 75 e8             	push   -0x18(%ebp)
8010a1e0:	ff 75 08             	push   0x8(%ebp)
8010a1e3:	e8 80 00 00 00       	call   8010a268 <tcp_pkt_create>
8010a1e8:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a1eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a1ee:	83 ec 08             	sub    $0x8,%esp
8010a1f1:	50                   	push   %eax
8010a1f2:	ff 75 e8             	push   -0x18(%ebp)
8010a1f5:	e8 3f f0 ff ff       	call   80109239 <i8254_send>
8010a1fa:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a1fd:	a1 64 7a 19 80       	mov    0x80197a64,%eax
8010a202:	83 c0 01             	add    $0x1,%eax
8010a205:	a3 64 7a 19 80       	mov    %eax,0x80197a64
8010a20a:	eb 4a                	jmp    8010a256 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a20c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a20f:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a213:	3c 10                	cmp    $0x10,%al
8010a215:	75 3f                	jne    8010a256 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a217:	a1 68 7a 19 80       	mov    0x80197a68,%eax
8010a21c:	83 f8 01             	cmp    $0x1,%eax
8010a21f:	75 35                	jne    8010a256 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a221:	83 ec 0c             	sub    $0xc,%esp
8010a224:	6a 00                	push   $0x0
8010a226:	6a 01                	push   $0x1
8010a228:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a22b:	50                   	push   %eax
8010a22c:	ff 75 e8             	push   -0x18(%ebp)
8010a22f:	ff 75 08             	push   0x8(%ebp)
8010a232:	e8 31 00 00 00       	call   8010a268 <tcp_pkt_create>
8010a237:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a23a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a23d:	83 ec 08             	sub    $0x8,%esp
8010a240:	50                   	push   %eax
8010a241:	ff 75 e8             	push   -0x18(%ebp)
8010a244:	e8 f0 ef ff ff       	call   80109239 <i8254_send>
8010a249:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a24c:	c7 05 68 7a 19 80 00 	movl   $0x0,0x80197a68
8010a253:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a256:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a259:	83 ec 0c             	sub    $0xc,%esp
8010a25c:	50                   	push   %eax
8010a25d:	e8 a4 84 ff ff       	call   80102706 <kfree>
8010a262:	83 c4 10             	add    $0x10,%esp
}
8010a265:	90                   	nop
8010a266:	c9                   	leave  
8010a267:	c3                   	ret    

8010a268 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a268:	55                   	push   %ebp
8010a269:	89 e5                	mov    %esp,%ebp
8010a26b:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a26e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a271:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a274:	8b 45 08             	mov    0x8(%ebp),%eax
8010a277:	83 c0 0e             	add    $0xe,%eax
8010a27a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a27d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a280:	0f b6 00             	movzbl (%eax),%eax
8010a283:	0f b6 c0             	movzbl %al,%eax
8010a286:	83 e0 0f             	and    $0xf,%eax
8010a289:	c1 e0 02             	shl    $0x2,%eax
8010a28c:	89 c2                	mov    %eax,%edx
8010a28e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a291:	01 d0                	add    %edx,%eax
8010a293:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a296:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a299:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a29c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a29f:	83 c0 0e             	add    $0xe,%eax
8010a2a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a2a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2a8:	83 c0 14             	add    $0x14,%eax
8010a2ab:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a2ae:	8b 45 18             	mov    0x18(%ebp),%eax
8010a2b1:	8d 50 36             	lea    0x36(%eax),%edx
8010a2b4:	8b 45 10             	mov    0x10(%ebp),%eax
8010a2b7:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a2b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2bc:	8d 50 06             	lea    0x6(%eax),%edx
8010a2bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2c2:	83 ec 04             	sub    $0x4,%esp
8010a2c5:	6a 06                	push   $0x6
8010a2c7:	52                   	push   %edx
8010a2c8:	50                   	push   %eax
8010a2c9:	e8 8c ab ff ff       	call   80104e5a <memmove>
8010a2ce:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a2d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2d4:	83 c0 06             	add    $0x6,%eax
8010a2d7:	83 ec 04             	sub    $0x4,%esp
8010a2da:	6a 06                	push   $0x6
8010a2dc:	68 90 77 19 80       	push   $0x80197790
8010a2e1:	50                   	push   %eax
8010a2e2:	e8 73 ab ff ff       	call   80104e5a <memmove>
8010a2e7:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a2ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2ed:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a2f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2f4:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a2f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2fb:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a2fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a301:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a305:	8b 45 18             	mov    0x18(%ebp),%eax
8010a308:	83 c0 28             	add    $0x28,%eax
8010a30b:	0f b7 c0             	movzwl %ax,%eax
8010a30e:	83 ec 0c             	sub    $0xc,%esp
8010a311:	50                   	push   %eax
8010a312:	e8 9b f8 ff ff       	call   80109bb2 <H2N_ushort>
8010a317:	83 c4 10             	add    $0x10,%esp
8010a31a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a31d:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a321:	0f b7 15 60 7a 19 80 	movzwl 0x80197a60,%edx
8010a328:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a32b:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a32f:	0f b7 05 60 7a 19 80 	movzwl 0x80197a60,%eax
8010a336:	83 c0 01             	add    $0x1,%eax
8010a339:	66 a3 60 7a 19 80    	mov    %ax,0x80197a60
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a33f:	83 ec 0c             	sub    $0xc,%esp
8010a342:	6a 00                	push   $0x0
8010a344:	e8 69 f8 ff ff       	call   80109bb2 <H2N_ushort>
8010a349:	83 c4 10             	add    $0x10,%esp
8010a34c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a34f:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a353:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a356:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a35a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a35d:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a361:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a364:	83 c0 0c             	add    $0xc,%eax
8010a367:	83 ec 04             	sub    $0x4,%esp
8010a36a:	6a 04                	push   $0x4
8010a36c:	68 04 f5 10 80       	push   $0x8010f504
8010a371:	50                   	push   %eax
8010a372:	e8 e3 aa ff ff       	call   80104e5a <memmove>
8010a377:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a37a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a37d:	8d 50 0c             	lea    0xc(%eax),%edx
8010a380:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a383:	83 c0 10             	add    $0x10,%eax
8010a386:	83 ec 04             	sub    $0x4,%esp
8010a389:	6a 04                	push   $0x4
8010a38b:	52                   	push   %edx
8010a38c:	50                   	push   %eax
8010a38d:	e8 c8 aa ff ff       	call   80104e5a <memmove>
8010a392:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a395:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a398:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a39e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3a1:	83 ec 0c             	sub    $0xc,%esp
8010a3a4:	50                   	push   %eax
8010a3a5:	e8 08 f9 ff ff       	call   80109cb2 <ipv4_chksum>
8010a3aa:	83 c4 10             	add    $0x10,%esp
8010a3ad:	0f b7 c0             	movzwl %ax,%eax
8010a3b0:	83 ec 0c             	sub    $0xc,%esp
8010a3b3:	50                   	push   %eax
8010a3b4:	e8 f9 f7 ff ff       	call   80109bb2 <H2N_ushort>
8010a3b9:	83 c4 10             	add    $0x10,%esp
8010a3bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a3bf:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a3c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3c6:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a3ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3cd:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a3d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3d3:	0f b7 10             	movzwl (%eax),%edx
8010a3d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3d9:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a3dd:	a1 64 7a 19 80       	mov    0x80197a64,%eax
8010a3e2:	83 ec 0c             	sub    $0xc,%esp
8010a3e5:	50                   	push   %eax
8010a3e6:	e8 e9 f7 ff ff       	call   80109bd4 <H2N_uint>
8010a3eb:	83 c4 10             	add    $0x10,%esp
8010a3ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a3f1:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a3f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3f7:	8b 40 04             	mov    0x4(%eax),%eax
8010a3fa:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a400:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a403:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a406:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a409:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a40d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a410:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a414:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a417:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a41b:	8b 45 14             	mov    0x14(%ebp),%eax
8010a41e:	89 c2                	mov    %eax,%edx
8010a420:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a423:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a426:	83 ec 0c             	sub    $0xc,%esp
8010a429:	68 90 38 00 00       	push   $0x3890
8010a42e:	e8 7f f7 ff ff       	call   80109bb2 <H2N_ushort>
8010a433:	83 c4 10             	add    $0x10,%esp
8010a436:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a439:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a43d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a440:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a446:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a449:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a44f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a452:	83 ec 0c             	sub    $0xc,%esp
8010a455:	50                   	push   %eax
8010a456:	e8 1f 00 00 00       	call   8010a47a <tcp_chksum>
8010a45b:	83 c4 10             	add    $0x10,%esp
8010a45e:	83 c0 08             	add    $0x8,%eax
8010a461:	0f b7 c0             	movzwl %ax,%eax
8010a464:	83 ec 0c             	sub    $0xc,%esp
8010a467:	50                   	push   %eax
8010a468:	e8 45 f7 ff ff       	call   80109bb2 <H2N_ushort>
8010a46d:	83 c4 10             	add    $0x10,%esp
8010a470:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a473:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a477:	90                   	nop
8010a478:	c9                   	leave  
8010a479:	c3                   	ret    

8010a47a <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a47a:	55                   	push   %ebp
8010a47b:	89 e5                	mov    %esp,%ebp
8010a47d:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a480:	8b 45 08             	mov    0x8(%ebp),%eax
8010a483:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a486:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a489:	83 c0 14             	add    $0x14,%eax
8010a48c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a48f:	83 ec 04             	sub    $0x4,%esp
8010a492:	6a 04                	push   $0x4
8010a494:	68 04 f5 10 80       	push   $0x8010f504
8010a499:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a49c:	50                   	push   %eax
8010a49d:	e8 b8 a9 ff ff       	call   80104e5a <memmove>
8010a4a2:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a4a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a4a8:	83 c0 0c             	add    $0xc,%eax
8010a4ab:	83 ec 04             	sub    $0x4,%esp
8010a4ae:	6a 04                	push   $0x4
8010a4b0:	50                   	push   %eax
8010a4b1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a4b4:	83 c0 04             	add    $0x4,%eax
8010a4b7:	50                   	push   %eax
8010a4b8:	e8 9d a9 ff ff       	call   80104e5a <memmove>
8010a4bd:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a4c0:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a4c4:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a4c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a4cb:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a4cf:	0f b7 c0             	movzwl %ax,%eax
8010a4d2:	83 ec 0c             	sub    $0xc,%esp
8010a4d5:	50                   	push   %eax
8010a4d6:	e8 b5 f6 ff ff       	call   80109b90 <N2H_ushort>
8010a4db:	83 c4 10             	add    $0x10,%esp
8010a4de:	83 e8 14             	sub    $0x14,%eax
8010a4e1:	0f b7 c0             	movzwl %ax,%eax
8010a4e4:	83 ec 0c             	sub    $0xc,%esp
8010a4e7:	50                   	push   %eax
8010a4e8:	e8 c5 f6 ff ff       	call   80109bb2 <H2N_ushort>
8010a4ed:	83 c4 10             	add    $0x10,%esp
8010a4f0:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a4f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a4fb:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a4fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a501:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a508:	eb 33                	jmp    8010a53d <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a50a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a50d:	01 c0                	add    %eax,%eax
8010a50f:	89 c2                	mov    %eax,%edx
8010a511:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a514:	01 d0                	add    %edx,%eax
8010a516:	0f b6 00             	movzbl (%eax),%eax
8010a519:	0f b6 c0             	movzbl %al,%eax
8010a51c:	c1 e0 08             	shl    $0x8,%eax
8010a51f:	89 c2                	mov    %eax,%edx
8010a521:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a524:	01 c0                	add    %eax,%eax
8010a526:	8d 48 01             	lea    0x1(%eax),%ecx
8010a529:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a52c:	01 c8                	add    %ecx,%eax
8010a52e:	0f b6 00             	movzbl (%eax),%eax
8010a531:	0f b6 c0             	movzbl %al,%eax
8010a534:	01 d0                	add    %edx,%eax
8010a536:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a539:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a53d:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a541:	7e c7                	jle    8010a50a <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a543:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a546:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a549:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a550:	eb 33                	jmp    8010a585 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a552:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a555:	01 c0                	add    %eax,%eax
8010a557:	89 c2                	mov    %eax,%edx
8010a559:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a55c:	01 d0                	add    %edx,%eax
8010a55e:	0f b6 00             	movzbl (%eax),%eax
8010a561:	0f b6 c0             	movzbl %al,%eax
8010a564:	c1 e0 08             	shl    $0x8,%eax
8010a567:	89 c2                	mov    %eax,%edx
8010a569:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a56c:	01 c0                	add    %eax,%eax
8010a56e:	8d 48 01             	lea    0x1(%eax),%ecx
8010a571:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a574:	01 c8                	add    %ecx,%eax
8010a576:	0f b6 00             	movzbl (%eax),%eax
8010a579:	0f b6 c0             	movzbl %al,%eax
8010a57c:	01 d0                	add    %edx,%eax
8010a57e:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a581:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a585:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a589:	0f b7 c0             	movzwl %ax,%eax
8010a58c:	83 ec 0c             	sub    $0xc,%esp
8010a58f:	50                   	push   %eax
8010a590:	e8 fb f5 ff ff       	call   80109b90 <N2H_ushort>
8010a595:	83 c4 10             	add    $0x10,%esp
8010a598:	66 d1 e8             	shr    %ax
8010a59b:	0f b7 c0             	movzwl %ax,%eax
8010a59e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a5a1:	7c af                	jl     8010a552 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a5a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a5a6:	c1 e8 10             	shr    $0x10,%eax
8010a5a9:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a5ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a5af:	f7 d0                	not    %eax
}
8010a5b1:	c9                   	leave  
8010a5b2:	c3                   	ret    

8010a5b3 <tcp_fin>:

void tcp_fin(){
8010a5b3:	55                   	push   %ebp
8010a5b4:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a5b6:	c7 05 68 7a 19 80 01 	movl   $0x1,0x80197a68
8010a5bd:	00 00 00 
}
8010a5c0:	90                   	nop
8010a5c1:	5d                   	pop    %ebp
8010a5c2:	c3                   	ret    

8010a5c3 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a5c3:	55                   	push   %ebp
8010a5c4:	89 e5                	mov    %esp,%ebp
8010a5c6:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a5c9:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5cc:	83 ec 04             	sub    $0x4,%esp
8010a5cf:	6a 00                	push   $0x0
8010a5d1:	68 6b c7 10 80       	push   $0x8010c76b
8010a5d6:	50                   	push   %eax
8010a5d7:	e8 65 00 00 00       	call   8010a641 <http_strcpy>
8010a5dc:	83 c4 10             	add    $0x10,%esp
8010a5df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a5e2:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5e5:	83 ec 04             	sub    $0x4,%esp
8010a5e8:	ff 75 f4             	push   -0xc(%ebp)
8010a5eb:	68 7e c7 10 80       	push   $0x8010c77e
8010a5f0:	50                   	push   %eax
8010a5f1:	e8 4b 00 00 00       	call   8010a641 <http_strcpy>
8010a5f6:	83 c4 10             	add    $0x10,%esp
8010a5f9:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a5fc:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5ff:	83 ec 04             	sub    $0x4,%esp
8010a602:	ff 75 f4             	push   -0xc(%ebp)
8010a605:	68 99 c7 10 80       	push   $0x8010c799
8010a60a:	50                   	push   %eax
8010a60b:	e8 31 00 00 00       	call   8010a641 <http_strcpy>
8010a610:	83 c4 10             	add    $0x10,%esp
8010a613:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a616:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a619:	83 e0 01             	and    $0x1,%eax
8010a61c:	85 c0                	test   %eax,%eax
8010a61e:	74 11                	je     8010a631 <http_proc+0x6e>
    char *payload = (char *)send;
8010a620:	8b 45 10             	mov    0x10(%ebp),%eax
8010a623:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a626:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a629:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a62c:	01 d0                	add    %edx,%eax
8010a62e:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a631:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a634:	8b 45 14             	mov    0x14(%ebp),%eax
8010a637:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a639:	e8 75 ff ff ff       	call   8010a5b3 <tcp_fin>
}
8010a63e:	90                   	nop
8010a63f:	c9                   	leave  
8010a640:	c3                   	ret    

8010a641 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a641:	55                   	push   %ebp
8010a642:	89 e5                	mov    %esp,%ebp
8010a644:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a647:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a64e:	eb 20                	jmp    8010a670 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a650:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a653:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a656:	01 d0                	add    %edx,%eax
8010a658:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a65b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a65e:	01 ca                	add    %ecx,%edx
8010a660:	89 d1                	mov    %edx,%ecx
8010a662:	8b 55 08             	mov    0x8(%ebp),%edx
8010a665:	01 ca                	add    %ecx,%edx
8010a667:	0f b6 00             	movzbl (%eax),%eax
8010a66a:	88 02                	mov    %al,(%edx)
    i++;
8010a66c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a670:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a673:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a676:	01 d0                	add    %edx,%eax
8010a678:	0f b6 00             	movzbl (%eax),%eax
8010a67b:	84 c0                	test   %al,%al
8010a67d:	75 d1                	jne    8010a650 <http_strcpy+0xf>
  }
  return i;
8010a67f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a682:	c9                   	leave  
8010a683:	c3                   	ret    

8010a684 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a684:	55                   	push   %ebp
8010a685:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a687:	c7 05 70 7a 19 80 c2 	movl   $0x8010f5c2,0x80197a70
8010a68e:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a691:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a696:	c1 e8 09             	shr    $0x9,%eax
8010a699:	a3 6c 7a 19 80       	mov    %eax,0x80197a6c
}
8010a69e:	90                   	nop
8010a69f:	5d                   	pop    %ebp
8010a6a0:	c3                   	ret    

8010a6a1 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a6a1:	55                   	push   %ebp
8010a6a2:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a6a4:	90                   	nop
8010a6a5:	5d                   	pop    %ebp
8010a6a6:	c3                   	ret    

8010a6a7 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a6a7:	55                   	push   %ebp
8010a6a8:	89 e5                	mov    %esp,%ebp
8010a6aa:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a6ad:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6b0:	83 c0 0c             	add    $0xc,%eax
8010a6b3:	83 ec 0c             	sub    $0xc,%esp
8010a6b6:	50                   	push   %eax
8010a6b7:	e8 d8 a3 ff ff       	call   80104a94 <holdingsleep>
8010a6bc:	83 c4 10             	add    $0x10,%esp
8010a6bf:	85 c0                	test   %eax,%eax
8010a6c1:	75 0d                	jne    8010a6d0 <iderw+0x29>
    panic("iderw: buf not locked");
8010a6c3:	83 ec 0c             	sub    $0xc,%esp
8010a6c6:	68 aa c7 10 80       	push   $0x8010c7aa
8010a6cb:	e8 d9 5e ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a6d0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6d3:	8b 00                	mov    (%eax),%eax
8010a6d5:	83 e0 06             	and    $0x6,%eax
8010a6d8:	83 f8 02             	cmp    $0x2,%eax
8010a6db:	75 0d                	jne    8010a6ea <iderw+0x43>
    panic("iderw: nothing to do");
8010a6dd:	83 ec 0c             	sub    $0xc,%esp
8010a6e0:	68 c0 c7 10 80       	push   $0x8010c7c0
8010a6e5:	e8 bf 5e ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a6ea:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6ed:	8b 40 04             	mov    0x4(%eax),%eax
8010a6f0:	83 f8 01             	cmp    $0x1,%eax
8010a6f3:	74 0d                	je     8010a702 <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a6f5:	83 ec 0c             	sub    $0xc,%esp
8010a6f8:	68 d5 c7 10 80       	push   $0x8010c7d5
8010a6fd:	e8 a7 5e ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a702:	8b 45 08             	mov    0x8(%ebp),%eax
8010a705:	8b 40 08             	mov    0x8(%eax),%eax
8010a708:	8b 15 6c 7a 19 80    	mov    0x80197a6c,%edx
8010a70e:	39 d0                	cmp    %edx,%eax
8010a710:	72 0d                	jb     8010a71f <iderw+0x78>
    panic("iderw: block out of range");
8010a712:	83 ec 0c             	sub    $0xc,%esp
8010a715:	68 f3 c7 10 80       	push   $0x8010c7f3
8010a71a:	e8 8a 5e ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a71f:	8b 15 70 7a 19 80    	mov    0x80197a70,%edx
8010a725:	8b 45 08             	mov    0x8(%ebp),%eax
8010a728:	8b 40 08             	mov    0x8(%eax),%eax
8010a72b:	c1 e0 09             	shl    $0x9,%eax
8010a72e:	01 d0                	add    %edx,%eax
8010a730:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a733:	8b 45 08             	mov    0x8(%ebp),%eax
8010a736:	8b 00                	mov    (%eax),%eax
8010a738:	83 e0 04             	and    $0x4,%eax
8010a73b:	85 c0                	test   %eax,%eax
8010a73d:	74 2b                	je     8010a76a <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a73f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a742:	8b 00                	mov    (%eax),%eax
8010a744:	83 e0 fb             	and    $0xfffffffb,%eax
8010a747:	89 c2                	mov    %eax,%edx
8010a749:	8b 45 08             	mov    0x8(%ebp),%eax
8010a74c:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a74e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a751:	83 c0 5c             	add    $0x5c,%eax
8010a754:	83 ec 04             	sub    $0x4,%esp
8010a757:	68 00 02 00 00       	push   $0x200
8010a75c:	50                   	push   %eax
8010a75d:	ff 75 f4             	push   -0xc(%ebp)
8010a760:	e8 f5 a6 ff ff       	call   80104e5a <memmove>
8010a765:	83 c4 10             	add    $0x10,%esp
8010a768:	eb 1a                	jmp    8010a784 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a76a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a76d:	83 c0 5c             	add    $0x5c,%eax
8010a770:	83 ec 04             	sub    $0x4,%esp
8010a773:	68 00 02 00 00       	push   $0x200
8010a778:	ff 75 f4             	push   -0xc(%ebp)
8010a77b:	50                   	push   %eax
8010a77c:	e8 d9 a6 ff ff       	call   80104e5a <memmove>
8010a781:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a784:	8b 45 08             	mov    0x8(%ebp),%eax
8010a787:	8b 00                	mov    (%eax),%eax
8010a789:	83 c8 02             	or     $0x2,%eax
8010a78c:	89 c2                	mov    %eax,%edx
8010a78e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a791:	89 10                	mov    %edx,(%eax)
}
8010a793:	90                   	nop
8010a794:	c9                   	leave  
8010a795:	c3                   	ret    
