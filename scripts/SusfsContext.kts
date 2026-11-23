#!/usr/bin/env kotlin
import java.io.File
import kotlin.system.exitProcess

val workDir = args.getOrNull(0) ?: "kernel_workspace/kernel_platform/common"
val patchPath = args.getOrNull(1) ?: run {
    println("Usage: kotlin SusfsContext.kts <workDir> <patchFile>")
    exitProcess(1)
}

fun f(relPath: String) = File(workDir, relPath)
fun File.rel(): String = this.path.removePrefix("$workDir/").removePrefix("$workDir\\")
val useColor = System.getenv("NO_COLOR") == null
fun tag(name: String, code: String) =
    if (useColor) "\u001B[${code}m[$name]\u001B[0m" else "[$name]"
fun logContext(file: File, detail: String) = println("${tag("context", "32")}-${file.rel()}: $detail")

val traceHookInclude = Regex("""^#include\s+(<trace/hooks/[^>]+>)""")
val anyInclude = Regex("""^#include\s+([<"][^>"]+[>"])""")

fun firstHunkContextIncludes(hunk: List<String>): List<String> =
    hunk.filter { it.firstOrNull() == ' ' }
        .mapNotNull { anyInclude.find(it.substring(1).trim())?.groupValues?.get(1) }
fun parsePatchContext(patchLines: List<String>): Map<String, List<String>> {
    val files = LinkedHashMap<String, List<String>>()
    var cur: String? = null
    var hunk = mutableListOf<String>()
    var inFirst = false

    fun flush() {
        val c = cur
        if (c != null && inFirst) {
            val incs = firstHunkContextIncludes(hunk)
            if (incs.isNotEmpty()) files[c] = incs
        }
        hunk = mutableListOf()
        inFirst = false
    }

    for (line in patchLines) {
        if (line.startsWith("diff --git ")) {
            flush()
            cur = Regex("""^diff --git a/(\S+) b/""").find(line)?.groupValues?.get(1)
            continue
        }
        if (line.startsWith("@@")) {
            if (inFirst) {
                flush()
                cur = null
                continue
            }
            inFirst = true
            continue
        }
        if (inFirst) hunk.add(line)
    }
    flush()
    return files
}

// 树里已不存在的 trace hook 头文件:建一个空桩
fun ensureContextStub(inc: String): File? {
    val rel = inc.trim('<', '>')
    val header = File(workDir, "include/$rel")
    if (header.exists()) return null
    header.parentFile.mkdirs()
    val guard = "_SUSFS_CONTEXT_STUB_" + rel.replace(Regex("""\W"""), "_").uppercase()
    header.writeText(
        "/* Stub created by SusfsContext.\n" +
        " * The SUSFS patch lists #include <$rel> as hunk context only; this\n" +
        " * GKI sublevel no longer ships the header. No symbols are used. */\n" +
        "#ifndef $guard\n#define $guard\n#endif\n"
    )
    return header
}

fun restoreContext(patch: File) {
    if (!patch.exists()) {
        println("${tag("context", "32")} patch not found: ${patch.path}")
        exitProcess(2)
    }
    val plan = parsePatchContext(patch.readLines())
    var touched = false

    for ((rel, includes) in plan) {
        if (includes.none { traceHookInclude.containsMatchIn("#include $it") }) continue
        val target = f(rel)
        if (!target.exists()) continue

        val lines = target.readLines().toMutableList()
        val present = lines.map { it.trim() }.toMutableList()
        var changed = false
        var cursor = 0

        for (inc in includes) {
            val want = "#include $inc"
            val found = present.subList(cursor, present.size).indexOf(want)
            if (found >= 0) {
                cursor += found + 1
                continue
            }
            if (!traceHookInclude.containsMatchIn(want)) continue // 只补 trace/hooks 这一类

            lines.add(cursor, want)
            present.add(cursor, want)
            logContext(target, "restored missing patch context: $want")
            ensureContextStub(inc)?.let { logContext(it, "created empty stub header for context-only include $inc") }
            cursor++
            changed = true
        }
        if (changed) {
            target.writeText(lines.joinToString("\n") + "\n")
            touched = true
        }
    }
    if (!touched) println("${tag("context", "32")} already complete, nothing to restore")
}

restoreContext(File(patchPath))