//
//  Mathomatic.m
//  Mathomatic
//
//  Created by Mike Griebling on 6 Apr 2015.
//  Copyright (c) 2015 Computer Inspirations. All rights reserved.
//

#import "Matho.h"
#import "includes.h"

@implementation Matho

+ (long)cur_equation {
	return cur_equation;
}

+ (long)result_en {
	return result_en;
}

+ (NSString *)warning_str {
	return [NSString stringWithUTF8String:warning_str];
}

+ (BOOL)init {
	init_gvars();
	default_out = stdout;	/* if default_out is a file that is not stdout, output is logged to that file */
	gfp = default_out;
	if (!init_mem()) {
		return false;
	}
	signal(SIGFPE, fphandler);	/* handle floating point exceptions, currently ignored */
	return true;
}

+ (BOOL)process:(NSString *)input toOutput:(NSString **)outputp {
	char *minput;
	int	i;
	int	rv;
	
	if (outputp) *outputp = NULL;
	result_str = NULL;
	result_en = -1;
	error_str = NULL;
	warning_str = NULL;
	if (input == NULL) return false;
	minput = strdup(input.UTF8String);
	if ((i = setjmp(jmp_save)) != 0) {
		clean_up();	/* Mathomatic processing was interrupted, so do a clean up. */
		if (i == 14) {
			error(_("Expression too large."));
		}
		if (outputp) {
			if (error_str) {
				*outputp = [NSString stringWithCString:result_str encoding:NSStringEncodingConversionAllowLossy];
			} else {
				*outputp = @"Processing was interrupted.";
			}
		}
		free_result_str();
		free(minput);
		previous_return_value = 0;
		return false;
	}
	set_error_level(minput);
	rv = process(minput);
	if (rv) {
		if (outputp) {
			*outputp = [NSString stringWithCString:result_str encoding:NSStringEncodingConversionAllowLossy];
		} else {
			if (result_str) {
				free(result_str);
				result_str = NULL;
			}
		}
	} else {
		if (outputp) {
			if (error_str) {
				*outputp = [NSString stringWithCString:result_str encoding:NSStringEncodingConversionAllowLossy];
			} else {
				*outputp = @"Unknown error.";
			}
		}
		free_result_str();
	}
	free(minput);
	return rv;
}

+ (BOOL)parse:(NSString *)input toOutput:(NSString **)outputp {
	char *minput;
	int	i;
	int	rv;
	
	if (outputp) *outputp = NULL;
	result_str = NULL;
	result_en = -1;
	error_str = NULL;
	warning_str = NULL;
	if (input == NULL) return false;
	minput = strdup(input.UTF8String);
	if ((i = setjmp(jmp_save)) != 0) {
		clean_up();	/* Mathomatic processing was interrupted, so do a clean up. */
		if (i == 14) {
			error(_("Expression too large."));
		}
		if (outputp) {
			if (error_str) {
				*outputp = [NSString stringWithCString:error_str encoding:NSStringEncodingConversionAllowLossy];
			} else {
				*outputp = @"Processing was interrupted.";
			}
		}
		free_result_str();
		free(minput);
		return false;
	}
	set_error_level(minput);
	i = next_espace();
#if	1	/* Leave this as 1 if you want to be able to enter single variable or constant expressions with no solving or selecting. */
	rv = parse(i, minput);	/* All set auto options ignored. */
#else
	rv = process_parse(i, minput);	/* All set auto options respected. */
#endif
	if (rv) {
		if (outputp) {
			*outputp = [NSString stringWithCString:result_str encoding:NSStringEncodingConversionAllowLossy];
		} else {
			if (result_str) {
				free(result_str);
				result_str = NULL;
			}
		}
	} else {
		if (outputp) {
			if (error_str) {
				*outputp = [NSString stringWithCString:result_str encoding:NSStringEncodingConversionAllowLossy];
			} else {
				*outputp = @"Unknown error.";
			}
		}
		free_result_str();
	}
	free(minput);
	return rv;
}

+ (BOOL)load_rc:(int)return_true_if_no_file fromFile:(FILE *)ofp {
	return load_rc(return_true_if_no_file, ofp);
}

+ (void)clear {
	clear_all();
}

extern void free_mem(void);

+ (void)free_mem {
	free_mem();
}

/*
 * Floating point exception handler.
 * Usually doesn't work in most operating systems, so just ignore it.
 */
void fphandler(int sig) {
	/*	error(_("Floating point exception.")); */
}

@end
